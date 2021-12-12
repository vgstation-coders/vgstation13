/*	The reaction procs must ALWAYS set src = null, this detaches the proc from the object (the reagent)
	so that it can continue working when the reagent is deleted while the proc is still active.

	Always call parent on reaction_mob, reaction_obj, reaction_turf, on_mob_life and Destroy() so that the sanities can be handled
	Failure to do so will lead to serious problems

	Are you adding a toxic reagent? Remember to update bees_apiary.dm 's lists of toxic reagents accordingly.

	Not sure what to have your density and SHC as? No IRL equivalent you can google? Use the components of the reagent
		density = (for(components of recipe) total_mass += component density* component volume)/volume of result. E.G
			6 SALINE = 3 SODIUMCHLORIDE, 5 WATER, 1 AMMONIA
				density = ((1 + (2.09*3) + (1*5) + (0.51*1))/6) = 2.22 (rounded to 2dp)

		SHC = (for(components of recipe) total_SHC *= component SHC)


*/

/datum/reagent
	var/name = "Reagent"
	var/id = REAGENT
	var/description = ""
	var/datum/reagents/holder = null
	var/reagent_state = REAGENT_STATE_SOLID
	var/data = null
	var/volume = 0
	var/nutriment_factor = 0
	var/pain_resistance = 0
	var/sport = SPORTINESS_NONE //High sport helps you show off on a treadmill. Multiplicative
	var/custom_metabolism = REAGENTS_METABOLISM
	var/custom_plant_metabolism = HYDRO_SPEED_MULTIPLIER
	var/overdose_am = 0
	var/overdose_tick = 0
	var/tick
	//var/list/viruses = list()
	var/color = "#000000" //rgb: 0, 0, 0 (does not support alpha channels - yet!)
	var/alpha = 255
	var/dupeable = TRUE	//whether the reagent can be duplicated by standard reagent duplication methods such as a service borg shaker or odysseus
	var/flags = 0
	var/density = 1 //(g/cm^3) Everything is water unless specified otherwise. round to 2dp
	var/specheatcap = 1 //how much energy in joules it takes to heat this thing up by 1 degree (J/g). round to 2dp
	var/glass_icon_state = null
	var/glass_desc = null //for reagents with a different desc in a glass
	var/glass_name = null //defaults to "glass of [reagent name]"
	var/light_color = null
	var/flammable = 0
	var/glass_isGlass = 1
	var/mug_icon_state = null
	var/mug_name = null
	var/mug_desc = null

/datum/reagent/proc/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)
	set waitfor = 0

	if(!holder)
		return 1
	if(!istype(M))
		return 1

	var/datum/reagent/self = src //Note : You need to declare self again (before the parent call) to use it in your chemical, see blood
	src = null

	//If the chemicals are in a smoke cloud, do not let the chemicals "penetrate" into the mob's system (balance station 13) -- Doohl
	if(self.holder && !istype(self.holder.my_atom, /obj/effect/smoke/chem))
		if(method == TOUCH)

			var/chance = 1
			var/block  = 0

			for(var/obj/item/clothing/C in M.get_equipped_items())
				if(C.permeability_coefficient < chance)
					chance = C.permeability_coefficient

				//Hardcode, but convenient until protection is fixed
				if(istype(C, /obj/item/clothing/suit/bio_suit))
					if(prob(75))
						block = 1

				if(istype(C, /obj/item/clothing/head/bio_hood))
					if(prob(75))
						block = 1

			chance = chance * 100

			if(self.id == HOLYWATER && istype(self.holder.my_atom, /obj/item/weapon/reagent_containers/food/drinks/bottle/holywater))
				if(M.reagents)
					M.reagents.add_reagent(self.id, min(5,self.volume/2)) //holy water flasks only splash 5u at a time. But for deconversion purposes they will always be ingested.
			else if(prob(chance) && !block)
				if(M.reagents)
					M.reagents.add_reagent(self.id, self.volume/2) //Hardcoded, transfer half of volume

	if (M.mind)
		for (var/role in M.mind.antag_roles)
			var/datum/role/R = M.mind.antag_roles[role]
			R.handle_splashed_reagent(self.id)

/datum/reagent/proc/reaction_dropper_mob(var/mob/living/M, var/method = TOUCH, var/volume)
	var/datum/reagent/self = src //Note : You need to declare self again (before the parent call) to use it in your chemical, see blood
	src = null
	if(M.reagents)
		M.reagents.add_reagent(self.id, self.volume) //Hardcoded, transfer half of volume

	if (M.mind)
		for (var/role in M.mind.antag_roles)
			var/datum/role/R = M.mind.antag_roles[role]
			R.handle_splashed_reagent(self.id)

/datum/reagent/proc/reaction_dropper_obj(var/obj/O, var/volume)
	reaction_obj(O, volume)

/datum/reagent/proc/reaction_animal(var/mob/living/simple_animal/M, var/method=TOUCH, var/volume)
	set waitfor = 0

	if(!holder)
		return 1
	if(!istype(M))
		return 1

	var/datum/reagent/self = src
	src = null

	M.reagent_act(self.id, method, volume)

/datum/reagent/proc/reaction_obj(var/obj/O, var/volume)
	set waitfor = 0

	if(!holder)
		return 1
	if(!istype(O))
		return 1

	src = null

/datum/reagent/proc/reaction_turf(var/turf/simulated/T, var/volume)
	set waitfor = 0

	if(!holder)
		return 1
	if(!istype(T))
		return 1

	src = null

/datum/reagent/proc/metabolize(var/mob/living/M)
	tick++
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
		if(L)
			L.metabolize_reagent(src.id, custom_metabolism)
			return
	if(holder)
		holder.remove_reagent(src.id, custom_metabolism) // If we aren't human, we don't have a liver, so just metabolize it the old fashioned way.

/datum/reagent/proc/on_mob_life(var/mob/living/M, var/alien)
	set waitfor = 0

	if(!holder)
		return 1
	if(!M)
		M = holder.my_atom //Try to find the mob through the holder
	if(!istype(M)) //Still can't find it, abort
		return 1
	if(M.mind)
		if((M.mind.special_role == HIGHLANDER || M.mind.special_role == BOMBERMAN) && src.flags & CHEMFLAG_DISHONORABLE)
			// TODO: HONORABLE_* checks.
			return 1
		if(dupeable && reagent_state == REAGENT_STATE_LIQUID && volume>=5 && ischangeling(M))
			var/datum/role/changeling/C = M.mind.GetRole(CHANGELING)
			if(!C.absorbed_chems.Find(id))
				C.absorbed_chems.Add(id)
				to_chat(M, "<span class = 'notice'>We have learned [src].</span>")

	if(is_overdosing())
		on_overdose(M)

	if (M.mind)
		for (var/role in M.mind.antag_roles)
			var/datum/role/R = M.mind.antag_roles[role]
			R.handle_reagent(id)

/datum/reagent/proc/is_overdosing() //Too much chems, or been in your system too long
	return (overdose_am && volume >= overdose_am) || (overdose_tick && tick >= overdose_tick)

/datum/reagent/proc/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	if(!holder)
		return
	if(!T)
		T = holder.my_atom //Try to find the mob through the holder
	if(!istype(T)) //Still can't find it, abort
		return

	holder.remove_reagent(src.id, custom_plant_metabolism)

//Called after add_reagents creates a new reagent
/datum/reagent/proc/on_introduced(var/data)
	return

/datum/reagent/proc/on_removal(var/data)
	return 1

//Completely unimplemented as of 2021, commenting out
///datum/reagent/proc/on_move(var/mob/M)
//	return
///datum/reagent/proc/on_merge(var/data)
///	return
///datum/reagent/proc/on_update(var/atom/A)
//	return

/datum/reagent/proc/on_overdose(var/mob/living/M)
	M.adjustToxLoss(1)

//Called when reagentcontainer A transfers into reagentcontainer B (this /datum/reagent belongs to B, i.e. we are the catchers here)
/datum/reagent/proc/post_transfer(var/datum/reagents/donor)
	return

/datum/reagent/send_to_past(var/duration)
	var/static/list/resettable_vars = list(
		"being_sent_to_past",
		"name",
		"id",
		"description",
		"holder",
		"reagent_state",
		"data",
		"volume",
		"gcDestroyed",
		"tick")

	reset_vars_after_duration(resettable_vars, duration, TRUE)

/datum/reagent/Destroy()
	if(istype(holder))
		holder.reagent_list -= src
		holder = null
	..()

/datum/reagent/proc/handle_special_behavior(var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/D) //rip steve
	return

/datum/reagent/piccolyn
	name = "Piccolyn"
	id = PICCOLYN
	description = "Prescribed daily."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#00FF00"
	custom_metabolism = 0.01

/datum/reagent/piccolyn/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(M.stat || M.health < 90 || M.getBrainLoss() >= 10)
		return 1

	var/list/nearest_doctor = null
	for(var/mob/living/L in view(M))
		if(L == M)
			continue
		if(L.stat)
			continue
		if(nearest_doctor && get_dist(L,M)>=get_dist(nearest_doctor,M))
			continue //We already have a closer living target
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			var/list/medical_uniforms_list = list(/obj/item/clothing/under/rank/chief_medical_officer,
													/obj/item/clothing/under/rank/medical,
													/obj/item/clothing/under/rank/nursesuit,
													/obj/item/clothing/under/rank/nurse,
													/obj/item/clothing/under/rank/orderly,
													/obj/item/clothing/under/rank/chemist,
													/obj/item/clothing/under/rank/pharma,
													/obj/item/clothing/under/rank/geneticist,
													/obj/item/clothing/under/rank/virologist)
			if(H.is_wearing_any(medical_uniforms_list,slot_w_uniform))
				//Check to see if it's wearing the right stuff
				nearest_doctor = H
		else if(isrobot(L))
			var/mob/living/silicon/robot/R = L
			if(HAS_MODULE_QUIRK(R, MODULE_CAN_HANDLE_MEDICAL))
				nearest_doctor = R
	if(!nearest_doctor)
		return 1
	var/D = "doctor"
	if(ishuman(nearest_doctor))
		var/mob/living/carbon/human/H = nearest_doctor
		D = get_first_word(H.name)
	else
		D = pick("bot","borg","borgo","autodoc","roboticist","cyborg","robot")
	var/list/thanks = list("Thanks, doc.",
							"You're alright, doc.",
							"'Preciate it, doc.",
							"Cheers, doctor.",
							"Thank you, doctor.",
							"Much appreciated, doctor.",
							"Thanks, mate!",
							"Thanks, doc!",
							"Zank you, Herr Doktor!",
							"Danke, Herr Doktor!",
							"Thank you doctor!",
							"You are great doctor!",
							"I love this doctor!",
							"Aye, thanks doc!",
							"Thank ye, doctor!",
							"You deserve a medal, doc.",
							"Thanks for the aid.",
							"Yeah, thanks doc!",
							"All right, [D], I feel good!",
							"Thanks, [D].",
							"Thank you, [D].",
							"'Preciate it, [D].",
							"Thanks for the aid, [D]."
							)
	M.say(pick(thanks))
	holder.del_reagent(PICCOLYN)

/datum/reagent/muhhardcores
	name = "Hardcores"
	id = BUSTANUT
	description = "Concentrated hardcore beliefs."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFF000"
	custom_metabolism = 0.01

/datum/reagent/muhhardcores/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(1))
		if(prob(90))
			to_chat(M, "<span class='notice'>[pick("You feel quite hardcore", "Coderbased is your god", "Fucking kickscammers Bustration will be the best")].")
		else
			M.say(pick("Muh hardcores.", "Falling down is a feature.", "Gorrillionaires and Booty Borgs when?"))

/datum/reagent/rogan
	name = "Rogan"
	id = ROGAN
	description = "Smells older than your grandpa."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#0000FF"
	custom_metabolism = 0.01

/datum/reagent/rogan/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(1))
		if(prob(42))
			to_chat(M, "<span class='notice'>[pick("Rogan?", "ROGAN.", "Food please.", "Wood please.", "Gold please.", "All hail, king of the losers!", "I'll beat you back to Age of Empires.", "Sure, blame it on your ISP.", "Start the game already!", "It is good to be the king.", "Long time, no siege.", "Nice town, I'll take it.", "Raiding party!", "Dadgum.", "Wololo.", "Attack an enemy now.", "Cease creating extra villagers.", "Create extra villagers.", "Build a navy.", "	Stop building a navy.", "Wait for my signal to attack.", "Build a wonder.", "Give me your extra resources.", "What age are you in?")]")
		else
			M.say("Rogan?")

/datum/reagent/bluegoo
	name = "Blue Goo"
	id = BLUEGOO
	description = "A viscous blue substance of unknown origin."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#64D2E6"
	custom_metabolism = 0.01

/datum/reagent/bluegoo/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(2))
		if(prob(75))
			to_chat(M, "<span class='notice'>[pick("The mothership is always watching.","All hail the Chairman.","You should buy more Zam snacks.","You would love to get some alien tissue samples under a microscope.","You feel exceptionally loyal to the mothership.","You feel the mothership's psychic presence.","The mothership will ensure your prosperity.","Maybe the commissary will dispense extra ration vouchers this cloning cycle.","Humans really do behave like apes sometimes.","A refreshing sip of acid would be delightful.")]</span>")
		else
			M.say(pick("Praise the mothership!", "Be productive this quarter, fellow denizens.", "Grey minds are naturally superior.", "I work for the happiness of all greykind.", "Alert the local battalion about any socially unstable behavior."))

/datum/reagent/slimejelly
	name = "Slime Jelly"
	id = SLIMEJELLY
	description = "A gooey semi-liquid produced from one of the deadliest lifeforms in existence. SO REAL."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#801E28" //rgb: 128, 30, 40
	density = 0.8
	specheatcap = 1.24

/datum/reagent/slimejelly/on_mob_life(var/mob/living/M, var/alien)
	if(..())
		return 1
	var/mob/living/carbon/human/human = M
	if(!isslimeperson(human))
		if(prob(10))
			to_chat(M, "<span class='warning'>Your insides are burning!</span>")
			M.adjustToxLoss(rand(20, 60) * REM)
	if(prob(40))
		M.heal_organ_damage(5 * REM, 0)

/datum/reagent/blood
	name = "Blood"
	description = "Tomatoes made into juice. Probably. What a waste of big, juicy tomatoes, huh?"
	id = BLOOD
	reagent_state = REAGENT_STATE_LIQUID
	color = DEFAULT_BLOOD //rgb: 161, 8, 8
	density = 1.05
	specheatcap = 3.49
	glass_name = "Tomato Juice Glass"
	glass_desc = "Are you sure this is tomato juice?"
	mug_name = "mug of tomato juice"
	mug_desc = "Are you sure this is tomato juice?"

	data = list(
		"viruses" = null,
		"blood_DNA" = null,
		"blood_type" = null,
		"blood_colour" = DEFAULT_BLOOD,
		"resistances" = null,
		"trace_chem" = null,
		"virus2" = null,
		"immunity" = null,
		"occult" = null,
		)

/datum/reagent/blood/handle_special_behavior(var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/D)
	var/totally_not_blood = "Tomato Juice"

	switch(color)
		if (VOX_BLOOD)//#2299FC
			totally_not_blood = "Space Lube"
		if (INSECT_BLOOD)//#EBECE6
			totally_not_blood = "Milk"
		if (MUSHROOM_BLOOD)//#D3D3D3
			totally_not_blood = "Milk"
		if (PALE_BLOOD)//#272727
			totally_not_blood = "Carbon"
		if (GHOUL_BLOOD)//#7FFF00
			totally_not_blood = "Piccolyn"

	glass_name = "glass of [totally_not_blood]"
	glass_desc = "Are you sure this is [totally_not_blood]?"
	mug_name = "mug of [totally_not_blood]"
	mug_desc = "Are you sure this is [totally_not_blood]?"


/datum/reagent/blood/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	var/datum/reagent/blood/self = src
	if(..())
		return 1

	//--------------OLD DISEASE CODE----------------------
	if(self.data && self.data["viruses"])
		for(var/datum/disease/D in self.data["viruses"])
			//var/datum/disease/virus = new D.type(0, D, 1)
			if(D.spread_type == SPECIAL || D.spread_type == NON_CONTAGIOUS) //We don't spread
				continue
			if(method == TOUCH)
				M.contract_disease(D)
			else //Injected
				M.contract_disease(D, 1, 0)
	//----------------------------------------------------

	if(iscarbon(M))
		var/mob/living/L = M
		if(L.can_be_infected() && self.data && self.data["virus2"]) //Infecting
			var/list/blood_viruses = self.data["virus2"]
			if (istype(blood_viruses) && blood_viruses.len > 0)
				for (var/ID in blood_viruses)
					var/datum/disease2/disease/D = blood_viruses[ID]
					if(method == TOUCH)
						var/block = L.check_contact_sterility(FULL_TORSO)
						var/bleeding = L.check_bodypart_bleeding(FULL_TORSO)
						if(attempt_colony(L,D,"splashed with infected blood"))
						else if (!block)
							if (D.spread & SPREAD_CONTACT)
								L.infect_disease2(D, notes="(Contact, splashed with infected blood)")
							else if (bleeding && (D.spread & SPREAD_BLOOD))
								L.infect_disease2(D, notes="(Blood, splashed with infected blood)")
					else
						L.infect_disease2(D, 1, notes="(Drank/Injected with infected blood)")

		if(ishuman(L) && (method == TOUCH))
			var/mob/living/carbon/human/H = L
			H.bloody_body_from_data(data,0,src)
			H.bloody_hands_from_data(data,2,src)
			spawn() //Bloody feet, result of the blood that fell on the floor
				var/obj/effect/decal/cleanable/blood/B = locate() in get_turf(H)

				if(B)
					B.Crossed(H)

			H.update_icons()

/datum/reagent/blood/reaction_animal(var/mob/living/simple_animal/M, var/method = TOUCH, var/volume)

	var/datum/reagent/blood/self = src
	if(..())
		return 1

	if(M.can_be_infected())//for now, only mice can be infected among simple_animals.
		var/mob/living/L = M
		if(self.data && self.data["virus2"]) //Infecting
			var/list/blood_viruses = self.data["virus2"]
			if (istype(blood_viruses) && blood_viruses.len > 0)
				for (var/ID in blood_viruses)
					var/datum/disease2/disease/D = blood_viruses[ID]
					if(method == TOUCH)
						var/block = L.check_contact_sterility(FULL_TORSO)
						var/bleeding = L.check_bodypart_bleeding(FULL_TORSO)
						if (!block)
							if (D.spread & SPREAD_CONTACT)
								L.infect_disease2(D, notes="(Contact, splashed with infected blood)")
							else if (bleeding && (D.spread & SPREAD_BLOOD))
								L.infect_disease2(D, notes="(Blood, splashed with infected blood)")
					else
						L.infect_disease2(D, 1, notes="(Drank/Injected with infected blood)")

// Was unused as of 2021
///datum/reagent/blood/on_merge(var/data)
//	if(data["blood_colour"])
//		color = data["blood_colour"]
//	return ..()
///datum/reagent/blood/on_update(var/atom/A)
//	if(data["blood_colour"])
//		color = data["blood_colour"]
//	return ..()

/datum/reagent/blood/reaction_turf(var/turf/simulated/T, var/volume) //Splash the blood all over the place

	var/datum/reagent/self = src
	if(..())
		return TRUE

	if(volume < 3) //Hardcoded
		return

	blood_splatter(T, self, 1)
	T.had_blood = TRUE
	if(volume >= 5 && !istype(T.loc, /area/chapel)) //Blood desanctifies non-chapel tiles
		T.holy = 0
	return

/datum/reagent/blood/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	O.add_blood_from_data(data)

	if(istype(O, /obj/item/clothing/mask/stone))
		var/obj/item/clothing/mask/stone/S = O
		S.spikes()

/datum/reagent/blood/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.5, bloody=1)
	T.adjust_water(0.7)

/datum/reagent/water
	name = "Water"
	id = WATER
	description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#DEF7F5" //rgb: 192, 227, 233
	alpha = 128
	specheatcap = 4.184
	density = 1
	glass_desc = "The father of all refreshments."

/datum/reagent/water/on_mob_life(var/mob/living/M, var/alien)

	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species && H.species.anatomy_flags & ACID4WATER)
			M.adjustToxLoss(REM)
			M.take_organ_damage(0, REM, ignore_inorganics = TRUE)

/datum/reagent/water/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	if(..())
		return 1

	//Put out fire
	if(method == TOUCH)
		M.ExtinguishMob()
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			var/datum/disease2/effect/E = C.has_active_symptom(/datum/disease2/effect/thick_skin)
			if(E)
				E.multiplier = max(E.multiplier - rand(1,3), 1)
				to_chat(C, "<span class='notice'>The water quenches your dry skin.</span>")
		if(ishuman(M) || ismonkey(M))
			var/mob/living/carbon/C = M
			if(C.body_alphas[INVISIBLESPRAY])
				C.body_alphas.Remove(INVISIBLESPRAY)
				C.regenerate_icons()
		else if(M.alphas[INVISIBLESPRAY])
			M.alpha = initial(M.alpha)
			M.alphas.Remove(INVISIBLESPRAY)

	//Water now directly damages slimes instead of being a turf check
	if(isslime(M))
		M.adjustToxLoss(rand(15, 20))

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species && H.species.anatomy_flags & ACID4WATER) //oof ouch, water is spicy now
			if(method == TOUCH)
				if(H.check_body_part_coverage(EYES|MOUTH))
					to_chat(H, "<span class='warning'>Your face is protected from a splash of water!</span>")
					return

				if(prob(15) && volume >= 30)
					var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
					if(head_organ)
						if(head_organ.take_damage(0, 25))
							H.UpdateDamageIcon(1)
						head_organ.disfigure("burn")
						H.audible_scream()
				else
					M.take_organ_damage(0, min(15, volume * 2)) //Uses min() and volume to make sure they aren't being sprayed in trace amounts (1 unit != insta rape) -- Doohl
			else
				M.take_organ_damage(0, min(15, volume * 2))

		else if(isslimeperson(H))

			H.adjustToxLoss(rand(1,3))

/datum/reagent/water/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(volume >= 3) //Hardcoded
		T.wet(800)

	var/hotspot = (locate(/obj/effect/fire) in T)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = T.remove_air(T:air:total_moles())
		lowertemp.temperature = max(min(lowertemp.temperature-2000, lowertemp.temperature / 2), 0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

/datum/reagent/water/reaction_obj(var/obj/O, var/volume)

	var/datum/reagent/self = src
	if(..())
		return 1

	if(O.has_been_invisible_sprayed)
		O.alpha = initial(O.alpha)
		O.has_been_invisible_sprayed = FALSE
		if(ismob(O.loc))
			var/mob/M = O.loc
			M.regenerate_icons()
	if(isturf(O.loc))
		var/turf/T = get_turf(O)
		self.reaction_turf(T, volume)

	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/monkeycube))
		var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/cube = O
		if(!cube.wrapped)
			cube.Expand()
	else if(istype(O,/obj/machinery/space_heater/campfire))
		var/obj/machinery/space_heater/campfire/campfire = O
		campfire.snuff()
	else if(istype(O, /obj/item/weapon/book/manual/snow))
		var/obj/item/weapon/book/manual/snow/S = O
		S.trigger()
	else if(O.on_fire) // For extinguishing objects on fire
		O.extinguish()
	else if(O.molten) // Molten shit.
		O.molten=0
		O.solidify()

/datum/reagent/water/reaction_animal(var/mob/living/simple_animal/M, var/method=TOUCH, var/volume)
	..()

	if(istype(M,/mob/living/simple_animal/hostile/slime))
		var/mob/living/simple_animal/hostile/slime/S = M
		S.calm()

	if(istype(M,/mob/living/simple_animal/bee))
		var/mob/living/simple_animal/bee/B = M
		B.calming()

/datum/reagent/water/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_water(1)

/datum/reagent/lube
	name = "Space Lube"
	id = LUBE
	description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#009CA8" //rgb: 0, 156, 168
	overdose_am = REAGENTS_OVERDOSE
	density = 1.11775
	specheatcap = 2.71388

/datum/reagent/lube/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(volume >= 1)
		T.wet(800, TURF_WET_LUBE)

/datum/reagent/sodium_polyacrylate
	name = "Sodium Polyacrylate"
	id = SODIUM_POLYACRYLATE
	description = "A super absorbent polymer that can absorb water based substances."
	reagent_state = REAGENT_STATE_SOLID
	color = "#FFFFFF"
	density = 1.22
	specheatcap = 4.14

/datum/reagent/sodium_polyacrylate/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(T.is_wet())
		if(!locate(/obj/effect/decal/cleanable/molten_item) in T)
			var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(T)
			I.desc = "A bit of gel left over from sodium polyacrylate absorbing liquid."
		T.dry(TURF_WET_LUBE) //Absorbs water or lube

/datum/reagent/anti_toxin
	name = "Dylovene"
	id = ANTI_TOXIN
	description = "Dylovene is a broad-spectrum antitoxin."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 1.49033
	specheatcap = 0.55536
	overdose_am = 60

/datum/reagent/anti_toxin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.drowsyness = max(M.drowsyness - 2 * REM, 0)
	if(holder.has_any_reagents(list(TOXIN, PLANTBGONE, INSECTICIDE, SOLANINE)))
		holder.remove_reagents(list(TOXIN, PLANTBGONE, INSECTICIDE, SOLANINE), 2 * REM)
	if(holder.has_any_reagents(STOXINS))
		holder.remove_reagents(STOXINS, 2 * REM)
	if(holder.has_reagent(PLASMA))
		holder.remove_reagent(PLASMA, REM)
	if(holder.has_any_reagents(SACIDS))
		holder.remove_reagents(SACIDS, REM)
	if(holder.has_reagent(POTASSIUM_HYDROXIDE))
		holder.remove_reagent(POTASSIUM_HYDROXIDE, 2 * REM)
	if(holder.has_reagent(CYANIDE))
		holder.remove_reagent(CYANIDE, REM)
	if(holder.has_reagent(AMATOXIN))
		holder.remove_reagent(AMATOXIN, 2 * REM)
	if(holder.has_reagent(CHLORALHYDRATE))
		holder.remove_reagent(CHLORALHYDRATE, 5 * REM)
	if(holder.has_reagent(SUX))
		holder.remove_reagent(SUX, REM)
	if(holder.has_reagent(CARPOTOXIN))
		holder.remove_reagent(CARPOTOXIN, REM)
	if(holder.has_reagent(ZOMBIEPOWDER))
		holder.remove_reagent(ZOMBIEPOWDER, 0.5 * REM)
	if(holder.has_reagent(MINDBREAKER))
		holder.remove_reagent(MINDBREAKER, 2 * REM)
	var/lucidmod = M.sleeping ? 3 : M.lying + 1 //3x as effective if they're sleeping, 2x if they're lying down
	M.hallucination = max(0, M.hallucination - 5 * REM * lucidmod)
	M.adjustToxLoss(-2 * REM)

/datum/reagent/anti_toxin/on_overdose(var/mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		if(prob(min(tick / 10, 35)))
			H.vomit()

		switch(volume)
			if(60 to 75)
				H.dizziness = max(H.dizziness, 10)
				if(prob(5))
					to_chat(H,"<span class='warning'>Your stomach grumbles and you feel a little nauseous.</span>")
			if(75 to INFINITY)
				H.dizziness = max(H.dizziness, 20)
				if(prob(10))
					H.custom_pain("You feel a horrible throbbing pain in your stomach!",1)

/datum/reagent/anti_toxin/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins -= 10
	if(T.seed && !T.dead)
		T.health += 1

/datum/reagent/phalanximine
	name = "Phalanximine"
	id = PHALANXIMINE
	description = "Phalanximine is a powerful chemotherapy agent."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#1A1A1A" //rgb: 26, 26, 26
	density = 2.46
	specheatcap = 12439.3 //Good fucking luck

/datum/reagent/phalanximine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustToxLoss(-2 * REM)
	M.apply_radiation(4 * REM,RAD_INTERNAL)

/datum/reagent/toxin
	name = "Toxin"
	id = TOXIN
	description = "A Toxic chemical."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#CF3600" //rgb: 207, 54, 0
	custom_metabolism = 0.01
	density = 1.4 //Let's just assume it's alpha-solanine

/datum/reagent/toxin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	//Toxins are really weak, but without being treated, last very long
	M.adjustToxLoss(0.2)

/datum/reagent/toxin/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins += 10

/datum/reagent/plasticide
	name = "Plasticide"
	id = PLASTICIDE
	description = "Liquid plastic, do not eat."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#CF3600" //rgb: 207, 54, 0
	custom_metabolism = 0.01
	density = 0.4
	specheatcap = 1.67

/datum/reagent/plasticide/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	//Toxins are really weak, but without being treated, last very long
	M.adjustToxLoss(0.2)

//Fast and lethal
/datum/reagent/cyanide
	name = "Cyanide"
	id = CYANIDE
	description = "A highly toxic chemical."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#CF3600" //rgb: 207, 54, 0
	custom_metabolism = 0.4
	flags = CHEMFLAG_DISHONORABLE // NO CHEATING
	density = 0.699
	specheatcap = 1.328

/datum/reagent/cyanide/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustToxLoss(4)
	M.adjustOxyLoss(4)
	M.sleeping += 1

/datum/reagent/potassium_hydroxide
	name = "Potassium Hydroxide"
	id = POTASSIUM_HYDROXIDE
	description = "A corrosive chemical used in making soap and batteries."
	reagent_state = REAGENT_STATE_SOLID
	overdose_am = REAGENTS_OVERDOSE
	custom_metabolism = 0.1
	color = "#ffffff" //rgb: 255, 255, 255
	density = 2.12
	specheatcap = 65.87 //how much energy in joules it takes to heat this thing up by 1 degree (J/g). round to 2dp

/datum/reagent/potassium_hydroxide/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustFireLoss(1.5 * REM)

//Quiet and lethal, needs at least 4 units in the person before they'll die
/datum/reagent/chefspecial
	name = "Chef's Special"
	id = CHEFSPECIAL
	description = "An extremely toxic chemical that will surely end in death."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#CF3600" //rgb: 207, 54, 0
	custom_metabolism = 0.01
	overdose_tick = 165
	density = 0.687 //Let's assume it's a compound of cyanide
	specheatcap = 1.335

/datum/reagent/chefspecial/on_overdose(var/mob/living/M)
	M.death(0)
	M.attack_log += "\[[time_stamp()]\]<font color='red'>Died a quick and painless death by <font color='green'>Chef Excellence's Special Sauce</font>.</font>"

/datum/reagent/minttoxin
	name = "Mint Toxin"
	id = MINTTOXIN
	description = "Useful for dealing with undesirable customers."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#CF3600" //rgb: 207, 54, 0
	density = 0.898
	specheatcap = 3.58

/datum/reagent/minttoxin/on_mob_life(var/mob/living/M, var/alien)

	if(..())
		return 1

	if(M_FAT in M.mutations)
		M.gib()

/datum/reagent/slimetoxin
	name = "Mutation Toxin"
	id = MUTATIONTOXIN
	description = "A corruptive toxin produced by slimes."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#13BC5E" //rgb: 19, 188, 94
	overdose_am = REAGENTS_OVERDOSE
	density = 1.245
	specheatcap = 0.25

/datum/reagent/slimetoxin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(ismanifested(M))
		to_chat(M, "<span class='warning'>You can feel intriguing reagents seeping into your body, but they don't seem to react at all.</span>")
		M.reagents.del_reagent("mutationtoxin")

	if(ishuman(M))

		var/mob/living/carbon/human/human = M
		if(!isslimeperson(human))

			to_chat(M, "<span class='warning'>Your flesh rapidly mutates!</span>")
			human.set_species("Slime")

			human.regenerate_icons()

			//Let the player choose their new appearance
			var/list/species_hair = valid_sprite_accessories(hair_styles_list, null, (human.species.name || null))
			if(human.my_appearance.f_style && species_hair.len)
				var/new_hstyle = input(M, "Select an ooze style", "Grooming")  as null|anything in species_hair
				if(new_hstyle)
					human.my_appearance.h_style = new_hstyle

			var/list/species_facial_hair = valid_sprite_accessories(facial_hair_styles_list, null, (human.species.name || null))
			if(human.my_appearance.f_style && species_facial_hair.len)
				var/new_fstyle = input(M, "Select a facial ooze style", "Grooming")  as null|anything in species_facial_hair
				if(new_fstyle)
					human.my_appearance.f_style = new_fstyle

			//Slime hair color is just darkened slime skin color (for now)
			human.my_appearance.r_hair = round(human.multicolor_skin_r * 0.8)
			human.my_appearance.g_hair = round(human.multicolor_skin_g * 0.8)
			human.my_appearance.b_hair = round(human.multicolor_skin_b * 0.8)

			human.regenerate_icons()
			M.setCloneLoss(0)


/datum/reagent/aslimetoxin
	name = "Advanced Mutation Toxin"
	id = AMUTATIONTOXIN
	description = "An advanced corruptive toxin produced by slimes."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#13BC5E" //rgb: 19, 188, 94
	overdose_am = REAGENTS_OVERDOSE
	density = 1.35
	specheatcap = 0.135

/datum/reagent/aslimetoxin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(iscarbon(M) && M.stat != DEAD)

		var/mob/living/carbon/C = M

		if(ismanifested(C))
			to_chat(C, "<span class='warning'>You can feel intriguing reagents seeping into your body, but they don't seem to react at all.</span>")
			C.reagents.del_reagent("amutationtoxin")

		else
			if(C.monkeyizing)
				return
			to_chat(M, "<span class='warning'>Your flesh rapidly mutates!</span>")
			C.monkeyizing = 1
			C.canmove = 0
			C.icon = null
			C.overlays.len = 0
			C.invisibility = 101
			for(var/obj/item/W in C)
				if(istype(W, /obj/item/weapon/implant))	//TODO: Carn. give implants a dropped() or something
					qdel(W)
					continue
				W.reset_plane_and_layer()
				W.forceMove(C.loc)
				W.dropped(C)
			var/mob/living/carbon/slime/new_mob = new /mob/living/carbon/slime(C.loc)
			new_mob.a_intent = I_HURT
			if(C.mind)
				C.mind.transfer_to(new_mob)
			else
				new_mob.key = C.key
			C.transferBorers(new_mob)
			qdel(C)

/datum/reagent/stoxin
	name = "Sleep Toxin"
	id = STOXIN
	description = "An effective hypnotic used to treat insomnia."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#E895CC" //rgb: 232, 149, 204
	custom_metabolism = 0.1
	data = 1 //Used as a tally
	density = 3.56
	specheatcap = 17.15

/datum/reagent/stoxin/on_mob_life(var/mob/living/M, var/alien)

	if(..())
		return 1

	switch(data)
		if(1 to 15)
			M.eye_blurry = max(M.eye_blurry, 10)
		if(15 to 25)
			M.drowsyness  = max(M.drowsyness, 20)
		if(25 to INFINITY)
			M.Paralyse(20)
			M.drowsyness  = max(M.drowsyness, 30)
	data++

/datum/reagent/srejuvenate
	name = "Soporific Rejuvenant"
	id = STOXIN2
	description = "Put people to sleep, and heals them."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	overdose_am = REAGENTS_OVERDOSE
	custom_metabolism = 0.2
	data = 1 //Used as a tally
	density = 1.564
	specheatcap = 1.725

/datum/reagent/srejuvenate/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.losebreath >= 10)
		M.losebreath = max(10, M.losebreath - 10)
	switch(data)
		if(1 to 15)
			M.eye_blurry = max(M.eye_blurry, 10)
		if(15 to 25)
			M.drowsyness  = max(M.drowsyness, 20)
		if(25 to INFINITY)
			M.sleeping += 1
			M.adjustOxyLoss(-M.getOxyLoss())
			M.SetKnockdown(0)
			M.SetStunned(0)
			M.SetParalysis(0)
			M.dizziness = 0
			M.drowsyness = 0
			M.stuttering = 0
			M.confused = 0
			M.remove_jitter()
			M.hallucination = 0
	data++

/datum/reagent/inaprovaline
	name = "Inaprovaline"
	id = INAPROVALINE
	description = "Inaprovaline is a synaptic stimulant and cardiostimulant. Commonly used to stabilize patients."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	custom_metabolism = 0.2
	pain_resistance = 25
	density = 1.66
	specheatcap = 0.8

/datum/reagent/inaprovaline/on_mob_life(var/mob/living/M, var/alien)

	if(..())
		return 1

	if(alien && alien == IS_VOX)
		M.adjustToxLoss(REM)
	else
		if(M.losebreath >= 10)
			M.losebreath = max(10, M.losebreath - 5)

/datum/reagent/space_drugs
	name = "Space drugs"
	id = SPACE_DRUGS
	description = "An illegal chemical compound used as drug."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#60A584" //rgb: 96, 165, 132
	custom_metabolism = 0.5
	overdose_am = REAGENTS_OVERDOSE
	density = 5.23
	specheatcap = 0.62

/datum/reagent/space_drugs/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.druggy = max(M.druggy, 15)
	if(isturf(M.loc) && !istype(M.loc, /turf/space))
		if(M.canmove && !M.restrained())
			if(prob(10))
				step(M, pick(cardinal))

	if(prob(7))
		M.emote(pick("twitch", "drool", "moan", "giggle"), null, null, TRUE)

/datum/reagent/holywater
	name = "Holy Water"
	id = HOLYWATER
	description = "An ashen-obsidian-water mix, this solution will alter certain sections of the brain's rationality."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#8497A9" //rgb: 52, 59, 63
	custom_metabolism = 2
	specheatcap = 4.183
	alpha = 128

/datum/reagent/holywater/reaction_obj(var/obj/O, var/volume)

	if(..())
		return 1

	if(volume >= 1)
		O.bless()

/datum/reagent/holywater/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1
	if(volume >= 5)
		T.bless()

/datum/reagent/holywater/reaction_animal(var/mob/living/simple_animal/M, var/method=TOUCH, var/volume)
	..()

	if(volume >= 5)
		if(istype(M,/mob/living/simple_animal/construct) || istype(M,/mob/living/simple_animal/shade))
			var/mob/living/simple_animal/C = M
			C.purge = 3
			C.adjustBruteLoss(5)
			C.visible_message("<span class='danger'>The holy water erodes \the [src].</span>")

/datum/reagent/holysalts
	name = "Holy Salts"
	id = HOLYSALTS
	description = "Blessed salts have been used for centuries as a sacramental. Pouring it on the floor in large enough quantity will offer protection from sources of evil and mend boundaries."
	reagent_state = REAGENT_STATE_SOLID
	color = "#C1CCD7" //rgb: 80, 80, 84
	density = 2.09
	specheatcap = 1.65

/datum/reagent/holysalts/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1
	if(volume >= 1)
		O.bless()

/datum/reagent/holysalts/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1
	if(!T.has_dense_content() && volume >= 10 && !(locate(/obj/effect/decal/cleanable/salt/holy) in T))
		if(!T.density)
			T.bless()
			new /obj/effect/decal/cleanable/salt/holy(T)

/datum/reagent/holysalts/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	var/list/borers = M.get_brain_worms()
	if(borers)
		for(var/mob/living/simple_animal/borer/B in borers)
			B.health -= 1
			to_chat(B, "<span class='warning'>Something in your host's bloodstream burns you!</span>")

/datum/reagent/holysalts/reaction_animal(var/mob/living/simple_animal/M, var/method=TOUCH, var/volume)
	..()
	if(volume >= 5)
		if(istype(M,/mob/living/simple_animal/construct) || istype(M,/mob/living/simple_animal/shade))
			var/mob/living/simple_animal/C = M
			C.purge = 3
			C.adjustBruteLoss(5)
			C.visible_message("<span class='danger'>The holy salts erode \the [src].</span>")

/datum/reagent/holysalts/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_water(-3)
	T.adjust_nutrient(-0.3)
	T.toxins += 8
	T.weedlevel -= 2
	T.pestlevel -= 1
	if(T.seed && !T.dead)
		T.health -= 2


/datum/reagent/serotrotium
	name = "Serotrotium"
	id = SEROTROTIUM
	description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#202040" //rgb: 20, 20, 40
	custom_metabolism = 0.25
	overdose_am = REAGENTS_OVERDOSE
	density = 1.8
	specheatcap = 2.84

/datum/reagent/serotrotium/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(7))
		M.emote(pick("twitch", "drool", "moan", "gasp"), null, null, TRUE)

	M.druggy = max(M.druggy, 50)

/datum/reagent/silicate
	name = "Silicate"
	id = SILICATE
	description = "A compound that can be used to repair and reinforce glass."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C7FFFF" //rgb: 199, 255, 255
	overdose_am = 0
	density = 0.69
	specheatcap =  0.59

/datum/reagent/oxygen
	name = "Oxygen"
	id = OXYGEN
	description = "A colorless, odorless gas."
	reagent_state = REAGENT_STATE_GAS
	color = "#808080" //rgb: 128, 128, 128
	density = 1.141
	specheatcap = 0.911

/datum/reagent/oxygen/on_mob_life(var/mob/living/M, var/alien)

	if(..())
		return 1

	if(alien && alien == IS_VOX)
		M.adjustToxLoss(REM)

/datum/reagent/copper
	name = "Copper"
	id = COPPER
	description = "A highly ductile metal."
	color = "#6E3B08" //rgb: 110, 59, 8
	specheatcap = 0.385
	density = 8.96

/datum/reagent/nitrogen
	name = "Nitrogen"
	id = NITROGEN
	description = "A colorless, odorless, tasteless gas."
	reagent_state = REAGENT_STATE_GAS
	color = "#808080" //rgb: 128, 128, 128
	density = 1.251
	specheatcap = 1.040

/datum/reagent/nitrogen/on_mob_life(var/mob/living/M, var/alien)

	if(..())
		return 1

	if(alien && alien == IS_VOX)
		M.adjustOxyLoss(-2 * REM)
		M.adjustToxLoss(-2 * REM)

/datum/reagent/hydrogen
	name = "Hydrogen"
	id = HYDROGEN
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	reagent_state = REAGENT_STATE_GAS
	color = "#808080" //rgb: 128, 128, 128
	density = 0.08988
	specheatcap = 13.83

/datum/reagent/potassium
	name = "Potassium"
	id = POTASSIUM
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	reagent_state = REAGENT_STATE_SOLID
	color = "#A0A0A0" //rgb: 160, 160, 160
	specheatcap = 0.75
	density = 0.89

/datum/reagent/potassiumcarbonate
	name = "Potassium Carbonate"
	id = POTASSIUMCARBONATE
	description = "A primary component of potash, usually acquired by reducing potassium-rich organics."
	reagent_state = REAGENT_STATE_SOLID
	color = "#A0A0A0"
	density = 2.43
	specheatcap = 0.96

/datum/reagent/mercury
	name = "Mercury"
	id = MERCURY
	description = "A chemical element."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#484848" //rgb: 72, 72, 72
	overdose_am = REAGENTS_OVERDOSE
	specheatcap = 0.14
	density = 13.56

/datum/reagent/mercury/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
		step(M, pick(cardinal))

	if(prob(5))
		M.emote(pick("twitch","drool","moan"), null, null, TRUE)

	M.adjustBrainLoss(2)

/datum/reagent/sulfur
	name = "Sulfur"
	id = SULFUR
	description = "A chemical element with a pungent smell."
	reagent_state = REAGENT_STATE_SOLID
	color = "#BF8C00" //rgb: 191, 140, 0
	specheatcap = 0.73
	density = 1.96

/datum/reagent/carbon
	name = "Carbon"
	id = CARBON
	description = "A chemical element, the builing block of life."
	reagent_state = REAGENT_STATE_SOLID
	color = "#1C1300" //rgb: 30, 20, 0
	specheatcap = 0.71
	density = 2.26

/datum/reagent/carbon/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	//Only add one dirt per turf.  Was causing people to crash
	if(!(locate(/obj/effect/decal/cleanable/dirt) in T))
		new /obj/effect/decal/cleanable/dirt(T)

/datum/reagent/chlorine
	name = "Chlorine"
	id = CHLORINE
	description = "A chemical element with a characteristic odour."
	reagent_state = REAGENT_STATE_GAS
	color = "#808080" //rgb: 128, 128, 128
	overdose_am = REAGENTS_OVERDOSE
	density = 3.214
	specheatcap = 1.34

/datum/reagent/chlorine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.take_organ_damage(REM, 0, ignore_inorganics = TRUE)

/datum/reagent/chlorine/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_water(-0.5)
	T.toxins += 15
	T.weedlevel -= 3
	if(T.seed && !T.dead)
		T.health -= 1

/datum/reagent/fluorine
	name = "Fluorine"
	id = FLUORINE
	description = "A highly-reactive chemical element."
	reagent_state = REAGENT_STATE_GAS
	color = "#808080" //rgb: 128, 128, 128
	overdose_am = REAGENTS_OVERDOSE
	density = 1.696
	specheatcap = 0.824

/datum/reagent/fluorine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustToxLoss(REM)
	if(prob(5) && !M.isUnconscious())
		M.emote("stare")

/datum/reagent/fluorine/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_water(-0.5)
	T.toxins += 25
	T.weedlevel -= 4
	if(T.seed && !T.dead)
		T.health -= 2

/datum/reagent/chloramine
	name = "Chloramine"
	id = CHLORAMINE
	description = "A chemical compound consisting of chlorine and ammonia. Very dangerous when inhaled."
	reagent_state = REAGENT_STATE_GAS
	color = "#808080" //rgb: 128, 128, 128
	overdose_am = REAGENTS_OVERDOSE
	density = 3.68
	specheatcap = 1299.23

/datum/reagent/chloramine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.take_organ_damage(REM, 0)

/datum/reagent/chloramine/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	if(..())
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if((H.species && H.species.flags & NO_BREATHE) || (M_NO_BREATH in H.mutations))
			return
		for(var/datum/organ/internal/lungs/L in H.internal_organs)
			L.take_damage(REM, 1)

/datum/reagent/sodium
	name = "Sodium"
	id = SODIUM
	description = "A chemical element, readily reacts with water."
	reagent_state = REAGENT_STATE_SOLID
	color = "#808080" //rgb: 128, 128, 128
	specheatcap = 1.23
	density = 0.968

/datum/reagent/phosphorus
	name = "Phosphorus"
	id = PHOSPHORUS
	description = "A chemical element, the backbone of biological energy carriers."
	reagent_state = REAGENT_STATE_SOLID
	color = "#832828" //rgb: 131, 40, 40
	density = 1.823
	specheatcap = 0.769

/datum/reagent/phosphorus/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.1)
	T.adjust_water(-0.5)
	T.weedlevel -= 2

/datum/reagent/lithium
	name = "Lithium"
	id = LITHIUM
	description = "A chemical element, used as antidepressant."
	reagent_state = REAGENT_STATE_SOLID
	color = "#808080" //rgb: 128, 128, 128
	overdose_am = REAGENTS_OVERDOSE
	specheatcap = 3.56
	density = 0.535

/datum/reagent/lithium/on_mob_life(var/mob/living/M)

	if(..())
		return 1
	if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
		step(M, pick(cardinal))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"), null, null, TRUE)

/datum/reagent/sugar
	name = "Sugar"
	id = SUGAR
	description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
	reagent_state = REAGENT_STATE_SOLID
	color = "#FFFFFF" //rgb: 255, 255, 255
	sport = SPORTINESS_SUGAR
	density = 1.59
	specheatcap = 1.244

/datum/reagent/sugar/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.nutrition += REM

/datum/reagent/sugar/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.1)
	T.weedlevel += 2
	T.pestlevel += 2

/datum/reagent/caramel
	name = "Caramel"
	id = CARAMEL
	description = "Created from the removal of water from sugar."
	reagent_state = REAGENT_STATE_SOLID
	color = "#844b06" //rgb: 132, 75, 6
	specheatcap = 1.244
	density = 1.59

/datum/reagent/caramel/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += (2 * REM)

/datum/reagent/honey
	name = "Honey"
	id = HONEY
	description = "A golden yellow syrup, loaded with sugary sweetness."
	color = "#FEAE00"
	alpha = 200
	nutriment_factor = 15 * REAGENTS_METABOLISM
	var/quality = 2
	density = 1.59
	specheatcap = 1.244

/datum/reagent/honey/on_mob_life(var/mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!holder)
			return
		H.nutrition += nutriment_factor
		if(H.getBruteLoss() && prob(60))
			H.heal_organ_damage(quality, 0)
		if(H.getFireLoss() && prob(50))
			H.heal_organ_damage(0, quality)
		if(H.getToxLoss() && prob(50))
			H.adjustToxLoss(-quality)
		..()

/datum/reagent/honey/royal_jelly
	name = "Royal Jelly"
	id = ROYALJELLY
	description = "A pale yellow liquid that is both spicy and acidic, yet also sweet."
	color = "#FFDA6A"
	alpha = 220
	nutriment_factor = 15 * REAGENTS_METABOLISM
	quality = 3

/datum/reagent/honey/chillwax
	name = "Chill Wax"
	id = CHILLWAX
	description = "A bluish wax produced by insects found on Vox worlds. Sweet to the taste, albeit trippy."
	color = "#4C78C1"
	alpha = 250
	nutriment_factor = 10 * REAGENTS_METABOLISM
	density = 1.59
	quality = 1
	specheatcap = 1.244

/datum/reagent/honey/chillwax/on_mob_life(var/mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.druggy = max(H.druggy, 5)
		H.Dizzy(2)
		if(prob(10))
			H.emote(pick("stare", "giggle"), null, null, TRUE)
		if(prob(5))
			to_chat(H, "<span class='notice'>[pick("You feel at peace with the world.","Everyone is nice, everything is awesome.","You feel high and ecstatic.")]</span>")
		..()

/datum/reagent/sacid
	name = "Sulphuric acid"
	id = SACID
	description = "A strong mineral acid with the molecular formula H2SO4."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#DB5008" //rgb: 219, 80, 8
	custom_metabolism = 0.5
	density = 1.84
	specheatcap = 1.38

/datum/reagent/sacid/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.acidable())
		M.adjustFireLoss(REM)
		M.take_organ_damage(0, REM)

/datum/reagent/sacid/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	if(..())
		return 1

	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.wear_mask)
				if(H.wear_mask.acidable())
					qdel(H.wear_mask)
					H.wear_mask = null
					H.update_inv_wear_mask()
					to_chat(H, "<span class='warning'>Your mask melts away but protects you from the acid!</span>")
				else
					to_chat(H, "<span class='warning'>Your mask protects you from the acid!</span>")
				return

			if(H.head && !istype(H.head, /obj/item/weapon/reagent_containers/glass/bucket))
				if(prob(15) && H.head.acidable())
					qdel(H.head)
					H.head = null
					H.update_inv_head()
					to_chat(H, "<span class='warning'>Your helmet melts away but protects you from the acid</span>")
				else
					to_chat(H, "<span class='warning'>Your helmet protects you from the acid!</span>")
				return

		else if(ismonkey(M))
			var/mob/living/carbon/monkey/MK = M
			if(MK.wear_mask)
				if(MK.wear_mask.acidable())
					qdel(MK.wear_mask)
					MK.wear_mask = null
					MK.update_inv_wear_mask()
					to_chat(MK, "<span class='warning'>Your mask melts away but protects you from the acid!</span>")
				else
					to_chat(MK, "<span class='warning'>Your mask protects you from the acid!</span>")
				return

		if(M.acidable())
			if(prob(15) && ishuman(M) && volume >= 30)
				var/mob/living/carbon/human/H = M
				var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
				if(head_organ)
					if(head_organ.take_damage(25, 0))
						H.UpdateDamageIcon(1)
					head_organ.disfigure("burn")
					H.audible_scream()
			else
				M.take_organ_damage(min(15, volume * 2)) //uses min() and volume to make sure they aren't being sprayed in trace amounts (1 unit != insta rape) -- Doohl
	else
		if(M.acidable())
			M.take_organ_damage(min(15, volume * 2))

/datum/reagent/sacid/reaction_obj(var/obj/O, var/volume)

	if(..())
		return 1

	if(!O.acidable())
		return

	if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)) && prob(10))
		var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
		I.desc = "Looks like this was \an [O] some time ago."
		O.visible_message("<span class='warning'>\The [O] melts.</span>")
		qdel(O)
	else if(istype(O,/obj/effect/dummy/chameleon))
		var/obj/effect/dummy/chameleon/projection = O
		projection.disrupt()

/datum/reagent/sacid/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins += 10
	T.weedlevel -= 2
	if(T.seed && !T.dead)
		T.health -= 4

/datum/reagent/pacid
	name = "Polytrinic acid"
	id = PACID
	description = "Polytrinic acid is a an extremely corrosive chemical substance."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#8E18A9" //rgb: 142, 24, 169
	custom_metabolism = 0.5
	density = 1.98
	specheatcap = 1.39

/datum/reagent/pacid/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustFireLoss(3 * REM)

/datum/reagent/pacid/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	if(..())
		return 1

	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.wear_mask)
				if(H.wear_mask.acidable())
					qdel(H.wear_mask)
					H.wear_mask = null
					H.update_inv_wear_mask()
					to_chat(H, "<span class='warning'>Your mask melts away but protects you from the acid!</span>")
				else
					to_chat(H, "<span class='warning'>Your mask protects you from the acid!</span>")
				return

			if(H.head && !istype(H.head, /obj/item/weapon/reagent_containers/glass/bucket))
				if(prob(15) && H.head.acidable())
					qdel(H.head)
					H.head = null
					H.update_inv_head()
					to_chat(H, "<span class='warning'>Your helmet melts away but protects you from the acid</span>")
				else
					to_chat(H, "<span class='warning'>Your helmet protects you from the acid!</span>")
				return

			if(H.acidable())
				var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
				if(head_organ.take_damage(15, 0))
					H.UpdateDamageIcon(1)
				H.audible_scream()

		else if(ismonkey(M))
			var/mob/living/carbon/monkey/MK = M
			if(MK.wear_mask)
				if(MK.wear_mask.acidable())
					qdel(MK.wear_mask)
					MK.wear_mask = null
					MK.update_inv_wear_mask()
					to_chat(MK, "<span class='warning'>Your mask melts away but protects you from the acid!</span>")
				else
					to_chat(MK, "<span class='warning'>Your mask protects you from the acid!</span>")
				return

			if(MK.acidable())
				MK.take_organ_damage(min(15, volume * 4)) //Same deal as sulphuric acid
	else
		if(M.acidable()) //I think someone doesn't know what this does
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
				if(head_organ.take_damage(15, 0))
					H.UpdateDamageIcon(1)
				H.audible_scream()
				head_organ.disfigure("burn")
			else
				M.take_organ_damage(min(15, volume * 4))

/datum/reagent/pacid/reaction_obj(var/obj/O, var/volume)

	if(..())
		return 1

	if(!O.acidable())
		return

	if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)))
		O.visible_message("<span class='warning'>\The [O] melts.</span>")
		O.acid_melt()
	else if(istype(O,/obj/effect/plantsegment))
		var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(get_turf(O))
		I.desc = "Looks like these were some [O.name] some time ago."
		var/obj/effect/plantsegment/K = O
		K.die_off()
	else if(istype(O,/obj/effect/dummy/chameleon))
		var/obj/effect/dummy/chameleon/projection = O
		projection.disrupt()

/datum/reagent/pacid/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins += 20
	T.weedlevel -= 4
	if(T.seed && !T.dead)
		T.health -= 8

/datum/reagent/glycerol
	name = "Glycerol"
	id = GLYCEROL
	description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#808080" //rgb: 128, 128, 128
	density = 4.84
	specheatcap = 1.38

/datum/reagent/nitroglycerin
	name = "Nitroglycerin"
	id = NITROGLYCERIN
	description = "Nitroglycerin is a heavy, colorless, oily, explosive liquid obtained by nitrating glycerol."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#808080" //rgb: 128, 128, 128
	density = 4.33
	specheatcap = 2.64

/datum/reagent/nitroglycerin/on_mob_life(var/mob/living/M)
	M.adjustToxLoss(2 * REM)
	if(prob(80))
		M.adjustOxyLoss(2 * REM)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/heart/E = H.internal_organs_by_name["heart"]
		if(istype(E) && !E.robotic)
			if(E.damage > 0)
				E.damage = max(0, E.damage - 0.2)
		if(prob(15))
			H.custom_pain("You feel a throbbing pain in your head", 1)
			M.adjustBrainLoss(2 * REM)
	if(prob(50))
		M.drowsyness = max(M.drowsyness, 4)

/datum/reagent/radium
	name = "Radium"
	id = RADIUM
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = REAGENT_STATE_SOLID
	color = "#669966" //rgb: 102, 153, 102
	density = 5
	specheatcap = 94
	custom_plant_metabolism = 2

/datum/reagent/radium/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.apply_radiation(2 * REM, RAD_INTERNAL)

	if (!M.immune_system.overloaded && M.virus2.len)
		for(var/ID in M.virus2)
			var/datum/disease2/disease/V = M.virus2[ID]
			if (prob(V.strength / 2))//the stronger the virus, the better higher the chance to trigger
				M.immune_system.Overload()
				return

/datum/reagent/radium/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(volume >= 3)
		if(!(locate(/obj/effect/decal/cleanable/greenglow) in T))
			new /obj/effect/decal/cleanable/greenglow(T)

/datum/reagent/radium/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.mutation_level += 0.6*T.mutation_mod*custom_plant_metabolism
	T.toxins += 4
	if(T.seed && !T.dead)
		T.health -= 1.5
		if(prob(20))
			T.mutation_mod += 0.1 //ha ha

/datum/reagent/ryetalyn
	name = "Ryetalyn"
	id = RYETALYN
	description = "Ryetalyn can cure all genetic abnomalities."
	reagent_state = REAGENT_STATE_SOLID
	color = "#C8A5DC" //rgb: 200, 165, 220
	overdose_am = REAGENTS_OVERDOSE
	density = 1.97
	specheatcap = 512.61

/datum/reagent/ryetalyn/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	var/needs_update = M.mutations.len > 0

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.hulk_time = 0
		for(var/gene_type in H.active_genes)
			var/datum/dna/gene/gene = dna_genes[gene_type]
			var/tempflag = 0
			if(H.species && (gene.block in H.species.default_blocks))
				tempflag |= GENE_NATURAL
			if(gene.name == "Hulk")
				gene.OnMobLife(H)
			if(gene.can_deactivate(H, tempflag))
				gene.deactivate(H, 0, tempflag)
	else
		for(var/gene_type in M.active_genes)
			if(gene_type == /datum/dna/gene/monkey)
				continue
			var/datum/dna/gene/gene = dna_genes[gene_type]
			if(gene.can_deactivate(M, 0))
				gene.deactivate(M, 0, 0)

	M.alpha = 255
	M.disabilities = 0
	M.sdisabilities = 0

	//Makes it more obvious that it worked.
	M.remove_jitter()

	//Might need to update appearance for hulk etc.
	if(needs_update)
		M.update_mutations()

/datum/reagent/paismoke
	name = "Smoke"
	id = PAISMOKE
	description = "A chemical smoke synthesized by personal AIs."
	reagent_state = REAGENT_STATE_GAS
	color = "#FFFFFF" //rgb: 255, 255, 255

//When inside a person, instantly decomposes into the ingredients for smoke
/datum/reagent/paismoke/on_mob_life(var/mob/living/M)
	M.reagents.del_reagent(src.id)
	M.reagents.add_reagent("potassium", 5)
	M.reagents.add_reagent("sugar", 5)
	M.reagents.add_reagent("phosphorus", 5)

/datum/reagent/thermite
	name = "Thermite"
	id = THERMITE
	description = "Thermite produces an aluminothermic reaction known as a thermite reaction. Can be used to melt walls."
	reagent_state = REAGENT_STATE_SOLID
	color = "#673910" //rgb: 103, 57, 16
	density = 3.91
	specheatcap = 0.37

/datum/reagent/thermite/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(volume >= 5 && T.can_thermite)
		T.thermite = 1
		T.overlays.len = 0
		T.overlays = image('icons/effects/effects.dmi', icon_state = "thermite")

/datum/reagent/thermite/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustFireLoss(2 * REM)

/datum/reagent/paracetamol
	name = "Paracetamol"
	id = PARACETAMOL
	description = "Most commonly know this as Tylenol, but this chemical is a mild, simple painkiller."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C855DC"
	pain_resistance = 60
	density = 1.26

/datum/reagent/mutagen
	name = "Unstable mutagen"
	id = MUTAGEN
	description = "Might cause unpredictable mutations. Keep away from children."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#13BC5E" //rgb: 19, 188, 94
	density = 3.35
	specheatcap = 96.86
	custom_plant_metabolism = 2

/datum/reagent/mutagen/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	if(..())
		return 1

	if(!M.dna) //No robots, AIs, aliens, Ians or other mobs should be affected by this.
		return
	if((method == TOUCH && prob(33)) || method == INGEST)
		if(prob(98))
			randmutb(M)
		else
			randmutg(M)
		domutcheck(M, null)
		if(M.last_appearance_mutation + 1 SECONDS < world.time)
			randmuti(M)
			M.UpdateAppearance()

/datum/reagent/mutagen/on_mob_life(var/mob/living/M)
	if(!M.dna)
		return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	if(!M)
		M = holder.my_atom
	if(..())
		return 1
	M.apply_radiation(10,RAD_INTERNAL)

/datum/reagent/mutagen/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.mutation_level += 1*T.mutation_mod*custom_plant_metabolism

/datum/reagent/tramadol
	name = "Tramadol"
	id = TRAMADOL
	description = "A simple, yet effective painkiller."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC"
	pain_resistance = 80
	custom_metabolism = 0.1
	density = 1.2
	specheatcap = 1.79

/datum/reagent/tramadol/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.pain_level < BASE_CARBON_PAIN_RESIST) //If we're already recovering from shock, let's speed the process up
			C.pain_shock_stage--

/datum/reagent/oxycodone
	name = "Oxycodone"
	id = OXYCODONE
	description = "An effective and very addictive painkiller."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C805DC"
	custom_metabolism = 0.05
	density = 1.26
	specheatcap = 24.59

/datum/reagent/oxycodone/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.pain_numb = max(5, C.pain_numb)
		C.pain_shock_stage -= 3 //We don't FEEL the shock now, but make it go away quick in case we run out of oxycodone.
		if(!M.sleeping && prob(2))
			to_chat(M, pick("<span class='numb'>You feel like you're floating...</span>", \
							"<span class='numb'>You feel a little lightheaded... but it's okay.</span>", \
							"<span class='numb'>Your face itches a little bit... and it feels so good to scratch it...</span>", \
							"<span class='numb'>Your whole body buzzes slightly, but it doesn't seem to bother you...</span>", \
							"<span class='numb'>You feel a little high of energy, and it makes you smile...</span>", \
							"<span class='numb'>You nod to yourself... it's nothing, it just feels good to nod a little...</span>", \
							"<span class='numb'>Hello?... Is there anybody in there?...</span>", \
							"<span class='numb'>You feel... comfortably numb.</span>"))

/datum/reagent/virus_food
	name = "Virus Food"
	id = VIRUSFOOD
	description = "A mixture of water, milk, and oxygen. Virus cells can use this mixture to reproduce."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#899613" //rgb: 137, 150, 19
	density = 0.67
	specheatcap = 4.18

/datum/reagent/virus_food/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor*REM

/datum/reagent/sterilizine
	name = "Sterilizine"
	id = STERILIZINE
	description = "Sterilizes wounds in preparation for surgery."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 1.83
	specheatcap = 1.83

/datum/reagent/sterilizine/reaction_obj(var/obj/O, var/volume)

	if(..())
		return 1

	if (isitem(O))
		var/obj/item/I = O
		I.sterility = min(100,initial(I.sterility)+30)
	O.clean_blood()
	if(istype(O, /obj/effect/decal/cleanable))
		qdel(O)
	else if(O.color && istype(O, /obj/item/weapon/paper))
		O.color = null

/datum/reagent/vaporsalt
	name = "Vapor Salts"
	id = VAPORSALT
	description = "A strange mineral found in alien plantlife that has been observed to vaporize some liquids."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#BDE5F2"
	specheatcap = 1.02 //SHC of air
	density = 1.225


/datum/reagent/vaporsalt/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(T.is_wet())
		T.dry(TURF_WET_LUBE) //Cleans water or lube
		var/obj/effect/smoke/S = new /obj/effect/smoke(T)
		S.time_to_live = 10 //unusually short smoke
		//We don't need to start up the system because we only want to smoke one tile.

/datum/reagent/iron
	name = "Iron"
	id = IRON
	description = "Pure iron in powdered form, a metal."
	reagent_state = REAGENT_STATE_SOLID
	color = "#666666" //rgb: 102, 102, 102
	specheatcap = 0.45
	density = 7.874

/datum/reagent/gold
	name = "Gold powder"
	id = GOLD
	description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
	reagent_state = REAGENT_STATE_SOLID
	color = "#F7C430" //rgb: 247, 196, 48
	specheatcap = 0.129
	density = 19.3

/datum/reagent/silver
	name = "Silver powder"
	id = SILVER
	description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
	reagent_state = REAGENT_STATE_SOLID
	color = "#D0D0D0" //rgb: 208, 208, 208
	specheatcap = 0.24
	density = 10.49

/datum/reagent/uranium
	name ="Uranium salt"
	id = URANIUM
	description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
	reagent_state = REAGENT_STATE_SOLID
	color = "#B8B8C0" //rgb: 184, 184, 192
	density = 19.05
	specheatcap = 124

/datum/reagent/uranium/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.apply_radiation(1, RAD_INTERNAL)

/datum/reagent/uranium/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(volume >= 3)
		if(!(locate(/obj/effect/decal/cleanable/greenglow) in T))
			new /obj/effect/decal/cleanable/greenglow(T)

/datum/reagent/diamond
	name = "Diamond dust"
	id = DIAMONDDUST
	description = "An allotrope of carbon, one of the hardest minerals known."
	reagent_state = REAGENT_STATE_SOLID
	color = "c4d4e0" //196 212 224
	density = 3.51
	specheatcap = 6.57

/datum/reagent/diamond/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustBruteLoss(5 * REM) //Not a good idea to eat crystal powder
	if(prob(30))
		M.audible_scream()

/datum/reagent/phazon
	name = "Phazon salt"
	id = PHAZON
	description = "The properties of this rare metal are not well-known."
	reagent_state = REAGENT_STATE_SOLID
	color = "#5E02F8" //rgb: 94, 2, 248
	dupeable = FALSE

/datum/reagent/phazon/New()
	..()
	density = rand(1,250)/rand(1,35)
	specheatcap = rand(1,250)/rand(1,35)

/datum/reagent/phazon/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.apply_radiation(5, RAD_INTERNAL)
	if(prob(20))
		M.advanced_mutate()

/datum/reagent/phazon/reaction_animal(var/mob/living/M)
	on_mob_life(M)

/datum/reagent/aluminum
	name = "Aluminum"
	id = ALUMINUM
	description = "A silvery white and ductile member of the boron group of chemical elements."
	reagent_state = REAGENT_STATE_SOLID
	color = "#A8A8A8" //rgb: 168, 168, 168
	specheatcap = 0.902
	density = 2.7

/datum/reagent/silicon
	name = "Silicon"
	id = SILICON
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	reagent_state = REAGENT_STATE_SOLID
	color = "#A8A8A8" //rgb: 168, 168, 168
	density = 2.33
	specheatcap = 0.712

/datum/reagent/fuel
	name = "Welding fuel"
	id = FUEL
	description = "Required for welders. Flamable."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#660000" //rgb: 102, 0, 0
	density = 1.1
	specheatcap = 0.68
	glass_icon_state = "dr_gibb_glass"
	glass_desc = "Unless you are an industrial tool, this is probably not safe for consumption."

/datum/reagent/fuel/reaction_obj(var/obj/O, var/volume)

	var/datum/reagent/self = src
	if(..())
		return 1
	if(isturf(O.loc))
		var/turf/T = get_turf(O)
		self.reaction_turf(T, volume)


/datum/reagent/fuel/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(!(locate(/obj/effect/decal/cleanable/liquid_fuel) in T))
		new /obj/effect/decal/cleanable/liquid_fuel(T, volume)

/datum/reagent/fuel/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustToxLoss(1)

/datum/reagent/vomit
	name = "Vomit"
	id = VOMIT
	description = "Stomach acid mixed with partially digested chunks of food."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#EACF9D" //rgb: 234, 207, 157. Pale yellow
	density = 1.35
	specheatcap = 5.2

/datum/reagent/vomit/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.adjustToxLoss(0.1)

/datum/reagent/vomit/reaction_turf(turf/simulated/T, volume)
	if(..())
		return 1

	if(volume >= 3)
		if(!(locate(/obj/effect/decal/cleanable/vomit) in T))
			new /obj/effect/decal/cleanable/vomit(T)

/datum/reagent/space_cleaner
	name = "Space Cleaner"
	id = CLEANER
	description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A5F0EE" //rgb: 165, 240, 238
	density = 0.76
	specheatcap = 60.17

/datum/reagent/space_cleaner/reaction_obj(var/obj/O, var/volume)

	if(..())
		return 1

	O.clean_blood()
	if(istype(O, /obj/effect/rune))
		var/obj/effect/rune/R = O
		if (!R.activated)
			qdel(O)
	else if(istype(O, /obj/effect/decal/cleanable))
		qdel(O)
	else if(O.color)
		O.color = ""
	..()

/datum/reagent/space_cleaner/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(volume >= 1)
		T.clean_blood()

		for(var/mob/living/carbon/slime/M in T)
			M.adjustToxLoss(rand(5, 10))

		for(var/mob/living/carbon/human/H in T)
			if(isslimeperson(H))
				H.adjustToxLoss(rand(5, 10)/10)

	T.color = ""

/datum/reagent/space_cleaner/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	if(..())
		return 1

	if(iscarbon(M))
		var/mob/living/carbon/C = M

		for(var/obj/item/I in C.held_items)
			I.clean_blood()

		if(C.wear_mask)
			if(C.wear_mask.clean_blood())
				C.update_inv_wear_mask(0)
		if(ishuman(M))
			var/mob/living/carbon/human/H = C
			if(H.head)
				if(H.head.clean_blood())
					H.update_inv_head(0)
			if(H.wear_suit)
				if(H.wear_suit.clean_blood())
					H.update_inv_wear_suit(0)
			else if(H.w_uniform)
				if(H.w_uniform.clean_blood())
					H.update_inv_w_uniform(0)
			if(H.shoes)
				if(H.shoes.clean_blood())
					H.update_inv_shoes(0)
		M.clean_blood()
		M.color = ""

/datum/reagent/space_cleaner/bleach
	name = "Bleach"
	id = BLEACH
	description = "A strong cleaning compound. Corrosive and toxic when applied to soft tissue. Do not swallow."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FBFCFF" //rgb: 251, 252, 255
	density = 6.84
	specheatcap = 90.35

/datum/reagent/space_cleaner/bleach/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	for(var/atom/A in T)
		A.clean_blood()

	for(var/obj/item/I in T)
		I.decontaminate()

	T.color = ""

/datum/reagent/space_cleaner/bleach/reaction_obj(obj/O, var/volume)
	if(O)
		O.color = ""
	..()

/datum/reagent/space_cleaner/bleach/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	switch(data)
		if(1 to 10)
			M.adjustBruteLoss(3 * REM) //soft tissue damage
		if(10 to INFINITY)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(prob(5))
					H.emote("me", 1, "coughs up blood!")
					H.drip(10)
				else if(prob(5))
					H.vomit()
	data++
	M.color = ""
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.anatomy_flags & MULTICOLOR && !(initial(H.species.anatomy_flags) & MULTICOLOR))
			H.species.anatomy_flags &= ~MULTICOLOR
			H.update_body()
	M.adjustToxLoss(4 * REM)

/datum/reagent/space_cleaner/bleach/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	if(..())
		return 1

	M.color = ""

	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/eyes_covered = H.get_body_part_coverage(EYES)
			if(eyes_covered)
				to_chat(H,"<span class='warning'>Your [eyes_covered] protects your eyes from the bleach!</span>")
				return
			else //This stuff is a little more corrosive but less irritative than pepperspray
				H.audible_scream()
				to_chat(H,"<span class='danger'>You are sprayed directly in the eyes with bleach!</span>")
				H.eye_blurry = max(M.eye_blurry, 15)
				H.eye_blind = max(M.eye_blind, 5)
				H.adjustBruteLoss(2)
				var/datum/organ/internal/eyes/E = H.internal_organs_by_name["eyes"]
				E.take_damage(5, 1)
				H.custom_pain("Your [E] burn horribly!", 1)
				H.apply_damage(2, BRUTE, LIMB_HEAD)

//Reagents used for plant fertilizers.
//WHY, just WHY, were fertilizers declared as a child of toxin and later snowflaked to work differently in the hydrotray's process_reagents()?

/datum/reagent/fertilizer
	name = "fertilizer"
	id = FERTILIZER
	description = "A chemical mix good for growing plants with."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664330" // rgb: 102, 67, 48
	density = 5.4
	specheatcap = 15

/datum/reagent/fertilizer/eznutrient
	name = "EZ Nutrient"
	id = EZNUTRIENT
	color = "#A4AF1C" // rgb: 164, 175, 28
	density = 1.32
	specheatcap = 0.60

/datum/reagent/fertilizer/eznutrient/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(1)

/datum/reagent/fertilizer/left4zed
	name = "Left-4-Zed"
	id = LEFT4ZED
	description = "A cocktail of mutagenic compounds, which cause plant life to become highly unstable."
	color = "#5B406C" // rgb: 91, 64, 108
	density = 1.32
	specheatcap = 0.60

/datum/reagent/fertilizer/left4zed/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(1)
	if(T.seed && !T.dead)
		T.health -= 0.5
		if(prob(30))
			T.mutation_mod += 0.2

/datum/reagent/fertilizer/robustharvest
	name = "Robust Harvest"
	id = ROBUSTHARVEST
	description = "Plant-enhancing hormones, good for increasing potency."
	color = "#3E901C" // rgb: 62, 144, 28
	density = 1.32
	specheatcap = 0.60
	custom_plant_metabolism = 0.1

/datum/reagent/fertilizer/robustharvest/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.05)
	if(prob(25*custom_plant_metabolism))
		T.weedlevel += 1
	if(T.seed && !T.dead && prob(25*custom_plant_metabolism))
		T.pestlevel += 1
	if(T.seed && !T.dead && !T.seed.immutable)
		var/chance
		chance = unmix(T.seed.potency, 15, 150)*350*custom_plant_metabolism
		if(prob(chance))
			T.check_for_divergence(1)
			T.seed.potency++
		chance = unmix(T.seed.yield, 6, 2)*15*custom_plant_metabolism
		if(prob(chance))
			T.check_for_divergence(1)
			T.seed.yield--

/datum/reagent/toxin/plantbgone
	name = "Plant-B-Gone"
	id = PLANTBGONE
	description = "A harmful toxic mixture to kill plantlife. Do not ingest!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#49002E" //rgb: 73, 0, 46
	density = 1.08
	specheatcap = 4.18

//Clear off wallrot fungi
/datum/reagent/toxin/plantbgone/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(istype(T, /turf/simulated/wall))
		var/turf/simulated/wall/W = T
		if(W.rotting)
			W.remove_rot()
			W.visible_message("<span class='notice'>The fungi are burned away by the solution!</span>")

/datum/reagent/toxin/plantbgone/reaction_obj(var/obj/O, var/volume)

	if(..())
		return 1

	if(istype(O, /obj/effect/alien/weeds/))
		var/obj/effect/alien/weeds/alien_weeds = O
		alien_weeds.health -= rand(15, 35) //Kills alien weeds pretty fast
		alien_weeds.healthcheck()
	else if(istype(O,/obj/effect/glowshroom)) //even a small amount is enough to kill it
		qdel(O)
	else if(istype(O,/obj/effect/plantsegment)) //Kills kudzu too.
		var/obj/effect/plantsegment/K = O
		var/dmg = 200
		if(K.seed)
			dmg -= K.seed.toxins_tolerance*20
		for(var/obj/effect/plantsegment/KV in orange(O,1))
			KV.health -= dmg*0.4
			KV.check_health()
			SSplant.add_plant(KV)
		K.health -= dmg
		K.check_health()
		SSplant.add_plant(K)
	else if(istype(O,/obj/machinery/portable_atmospherics/hydroponics))
		var/obj/machinery/portable_atmospherics/hydroponics/tray = O
		if(tray.seed)
			tray.health -= rand(30,50)
		tray.pestlevel -= 2
		tray.weedlevel -= 3
		tray.toxins += 15
		tray.check_level_sanity()
	else if(istype(O, /obj/structure/cable/powercreeper))
		var/obj/structure/cable/powercreeper/PC = O
		if(prob(1*(PC.powernet.avail/1000))) //The less there is, the hardier it gets
			PC.die()

/datum/reagent/toxin/plantbgone/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	if(..())
		return 1
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(!C.wear_mask) //If not wearing a mask
			C.adjustToxLoss(REM) //4 toxic damage per application, doubled for some reason
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.dna)
				if(H.species.flags & IS_PLANT) //Plantmen take a LOT of damage //aren't they toxin-proof anyways?
					H.adjustToxLoss(10 * REM)

/datum/reagent/toxin/plantbgone/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins += 6
	T.weedlevel -= 8
	if(T.seed && !T.dead)
		T.health -= 20
		T.mutation_mod += 0.1

/datum/reagent/toxin/insecticide
	name = "Insecticide"
	id = INSECTICIDE
	description = "A broad pesticide. Do not ingest!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#49002E" //rgb: 73, 0, 46
	density = 1.08
	specheatcap = 4.18

/datum/reagent/toxin/insecticide/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	if(..())
		return 1
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(!C.wear_mask) //If not wearing a mask
			C.adjustToxLoss(REM) //4 toxic damage per application, doubled for some reason
		if(isinsectoid(C) || istype(C, /mob/living/carbon/monkey/roach)) //Insecticide being poisonous to bugmen, who'd've thunk
			M.adjustToxLoss(10 * REM)

/datum/reagent/toxin/insecticide/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()

	T.pestlevel -= 8


/datum/reagent/plasma
	name = "Plasma"
	id = PLASMA
	description = "Plasma in its liquid form."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#500064" //rgb: 80, 0, 100

/datum/reagent/plasma/New()
	..()
	specheatcap = rand(1,150)/rand(1,25)
	density = rand(1,150)/rand(1,25)

/datum/reagent/plasma/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	var/mob/living/carbon/human/H = M
	if(isplasmaman(H) || H.species.flags & PLASMA_IMMUNE)
		return 1
	else
		M.adjustToxLoss(3 * REM)
	if(holder.has_reagent("inaprovaline"))
		holder.remove_reagent("inaprovaline", 2 * REM)


/datum/reagent/leporazine
	name = "Leporazine"
	id = LEPORAZINE
	description = "Leporazine can be use to stabilize an individuals body temperature."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 5.65
	specheatcap = ARBITRARILY_LARGE_NUMBER //Good luck heating something with leporazine in it

/datum/reagent/leporazine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(M.bodytemperature < 311)
		M.bodytemperature = min(310, M.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/cryptobiolin
	name = "Cryptobiolin"
	id = CRYPTOBIOLIN
	description = "Cryptobiolin causes confusion and dizzyness."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	custom_metabolism = 0.2
	density = 1.21
	specheatcap = 0.85

/datum/reagent/cryptobiolin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.Dizzy(1)
	M.confused = max(M.confused, 20)

/datum/reagent/lexorin
	name = "Lexorin"
	id = LEXORIN
	description = "Lexorin temporarily stops respiration. Causes tissue damage."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 0.655293
	specheatcap = 7.549

/datum/reagent/lexorin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(33))
		M.take_organ_damage(REM, 0, ignore_inorganics = TRUE)
	M.adjustOxyLoss(3)
	if(prob(20))
		M.emote("gasp", null, null, TRUE)

/datum/reagent/kelotane
	name = "Kelotane"
	id = KELOTANE
	description = "Kelotane is a drug used to treat burns."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 2.3
	specheatcap = 0.51

/datum/reagent/kelotane/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.heal_organ_damage(0, 2 * REM)

/datum/reagent/dermaline
	name = "Dermaline"
	id = DERMALINE
	description = "Dermaline is the next step in burn medication. Works twice as good as kelotane and enables the body to restore even the direst heat-damaged tissue."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 1.75
	specheatcap = 0.36

/datum/reagent/dermaline/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.heal_organ_damage(0, 3 * REM)

/datum/reagent/dexalin
	name = "Dexalin"
	id = DEXALIN
	description = "Dexalin is used in the treatment of oxygen deprivation."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 2.28
	specheatcap = 0.91

/datum/reagent/dexalin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustOxyLoss(-2 * REM)

	if(holder.has_any_reagents(LEXORINS))
		holder.remove_reagents(LEXORINS, 2 * REM)

/datum/reagent/dexalinp
	name = "Dexalin Plus"
	id = DEXALINP
	description = "Dexalin Plus is used in the treatment of oxygen deprivation. Its highly effective."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 4.14
	specheatcap = 0.29

/datum/reagent/dexalinp/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustOxyLoss(-M.getOxyLoss())

	if(holder.has_any_reagents(LEXORINS))
		holder.remove_reagents(LEXORINS, 2 * REM)

/datum/reagent/tricordrazine
	name = "Tricordrazine"
	id = TRICORDRAZINE
	description = "Tricordrazine is a highly potent stimulant, originally derived from cordrazine. Can be used to treat a wide range of injuries."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 1.58
	specheatcap = 0.44

/datum/reagent/tricordrazine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.getOxyLoss())
		M.adjustOxyLoss(-REM)
	if(M.getBruteLoss())
		M.heal_organ_damage(REM, 0)
	if(M.getFireLoss())
		M.heal_organ_damage(0, REM)
	if(M.getToxLoss())
		M.adjustToxLoss(-REM)

/datum/reagent/simpolinol
	name = "Simpolinol"
	id = SIMPOLINOL
	description = "A broad spectrum rejuvenant used to heal fauna with less complex cardiovascular systems. Not for human injestion."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A5A5FF" //rgb: 165, 165, 255
	density = 1.58
	specheatcap = 0.44

/datum/reagent/simpolinol/on_mob_life(var/mob/living/M)

	if(..())
		return 1
	if(isanimal(M))
		M.health = min(M.maxHealth, M.health + REM)
	else
		M.adjustToxLoss(5)

//An OP chemical for admins and detecting exploits
/datum/reagent/adminordrazine
	name = "Adminordrazine"
	id = ADMINORDRAZINE
	description = "It's magic. We don't have to explain it."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = ARBITRARILY_LARGE_NUMBER
	specheatcap = ARBITRARILY_LARGE_NUMBER

/datum/reagent/adminordrazine/on_mob_life(var/mob/living/carbon/M)

	if(..())
		return 1

	M.setCloneLoss(0)
	M.setOxyLoss(0)
	M.rad_tick = 0
	M.radiation = 0
	M.heal_organ_damage(5,5)
	M.adjustToxLoss(-5)
	if(holder.has_any_reagents(TOXINS))
		holder.remove_reagents(TOXINS, 5)
	if(holder.has_any_reagents(STOXINS))
		holder.remove_reagents(STOXINS, 5)
	if(holder.has_reagent(PLASMA))
		holder.remove_reagent(PLASMA, 5)
	if(holder.has_any_reagents(SACIDS))
		holder.remove_reagents(SACIDS, 5)
	if(holder.has_any_reagents(PACIDS))
		holder.remove_reagent(PACIDS, 5)
	if(holder.has_reagent(CYANIDE))
		holder.remove_reagent(CYANIDE, 5)
	if(holder.has_any_reagents(LEXORINS))
		holder.remove_reagents(LEXORINS, 5)
	if(holder.has_reagent(AMATOXIN))
		holder.remove_reagent(AMATOXIN, 5)
	if(holder.has_reagent(CHLORALHYDRATE))
		holder.remove_reagent(CHLORALHYDRATE, 5)
	if(holder.has_reagent(CARPOTOXIN))
		holder.remove_reagent(CARPOTOXIN, 5)
	if(holder.has_reagent(ZOMBIEPOWDER))
		holder.remove_reagent(ZOMBIEPOWDER, 5)
	if(holder.has_reagent(MINDBREAKER))
		holder.remove_reagent(MINDBREAKER, 5)
	if(holder.has_reagent(SPIRITBREAKER))
		holder.remove_reagent(SPIRITBREAKER, 5)
	M.hallucination = 0
	M.setBrainLoss(0)
	M.disabilities = 0
	M.sdisabilities = 0
	M.eye_blurry = 0
	M.eye_blind = 0
	M.SetKnockdown(0)
	M.SetStunned(0)
	M.SetParalysis(0)
	M.silent = 0
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.confused = 0
	M.sleeping = 0
	M.remove_jitter()
	for(var/datum/disease/D in M.viruses)
		D.spread = "Remissive"
		D.stage--
		if(D.stage < 1)
			D.cure()
	for(var/A in M.virus2)
		var/datum/disease2/disease/D2 = M.virus2[A]
		D2.stage--
		if(D2.stage < 1)
			D2.cure(M)

/datum/reagent/adminordrazine/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(1)
	T.adjust_water(1)
	T.weedlevel -= 5
	T.pestlevel -= 5
	T.toxins -= 5
	if(T.seed && !T.dead)
		T.health += 50

/datum/reagent/synaptizine
	name = "Synaptizine"
	id = SYNAPTIZINE
	description = "Synaptizine is used to treat various diseases."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	custom_metabolism = 0.01
	overdose_am = REAGENTS_OVERDOSE
	pain_resistance = 40
	density = 1.04
	specheatcap = 18.53

/datum/reagent/synaptizine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.drowsyness = max(M.drowsyness-  5, 0)
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustKnockdown(-1)
	if(holder.has_reagent("mindbreaker"))
		holder.remove_reagent("mindbreaker", 5)
	var/lucidmod = M.sleeping ? 3 : M.lying + 1
	M.hallucination = max(0, M.hallucination - 10 * lucidmod)
	if(prob(60))
		M.adjustToxLoss(1)

/datum/reagent/impedrezene
	name = "Impedrezene"
	id = IMPEDREZENE
	description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	overdose_am = REAGENTS_OVERDOSE
	density = 8.15
	specheatcap = 0.16

/datum/reagent/impedrezene/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.jitteriness = max(M.jitteriness - 5,0)
	if(prob(80))
		M.adjustBrainLoss(5 * REM)
	if(prob(50))
		M.drowsyness = max(M.drowsyness, 3)
	if(prob(10))
		M.emote("drool", null, null, TRUE)

/datum/reagent/hyronalin
	name = "Hyronalin"
	id = HYRONALIN
	description = "Hyronalin is a medicinal drug used to counter the effect of radiation poisoning."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	custom_metabolism = 0.05
	overdose_am = REAGENTS_OVERDOSE
	density = 3.25
	specheatcap = 52.20

/datum/reagent/hyronalin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.radiation = max(M.radiation - 3 * REM, 0)

/datum/reagent/arithrazine
	name = "Arithrazine"
	id = ARITHRAZINE
	description = "Arithrazine is an unstable medication used for the most extreme cases of radiation poisoning."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	custom_metabolism = 0.05
	overdose_am = REAGENTS_OVERDOSE
	density = 1.67
	specheatcap = 721.98

/datum/reagent/arithrazine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.radiation = max(M.radiation - 7 * REM, 0)
	M.adjustToxLoss(-REM)
	if(prob(15))
		M.take_organ_damage(1, 0, ignore_inorganics = TRUE)

/datum/reagent/lithotorcrazine
	name = "Lithotorcrazine"
	id = LITHOTORCRAZINE
	description = "A derivative of Arithrazine. Rather than reducing radiation in a host, actively impedes the host from being irradiated instead."
	reagent_state = REAGENT_STATE_SOLID
	color = "#C0C0C0"
	custom_metabolism = 0.2
	density = 4.92
	specheatcap = 150.53

/datum/reagent/alkysine
	name = "Alkysine"
	id = ALKYSINE
	description = "Alkysine is a drug used to lessen the damage to neurological tissue after a catastrophic injury. Can heal brain tissue."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	custom_metabolism = 0.05
	overdose_am = REAGENTS_OVERDOSE
	pain_resistance = 10
	density = 2.98
	specheatcap = 0.77

/datum/reagent/alkysine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustBrainLoss(-3 * REM)

/datum/reagent/alkycosine
	name = "Alkycosine"
	id = ALKYCOSINE
	description = "A mind stablizing brain bleach."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#EDEDED" //rgb: 237, 237, 237
	custom_metabolism = 0.05
	overdose_am = REAGENTS_OVERDOSE
	pain_resistance = 15
	density = 5.98
	specheatcap = 1.75

/datum/reagent/alkycosine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustBrainLoss(-4 * REM)

/datum/reagent/imidazoline
	name = "Imidazoline"
	id = IMIDAZOLINE
	description = "Heals eye damage"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 1.92
	specheatcap = 5.45

/datum/reagent/imidazoline/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.eye_blurry = max(M.eye_blurry - 5, 0)
	M.eye_blind = max(M.eye_blind - 5, 0)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/eyes/E = H.internal_organs_by_name["eyes"]
		if(istype(E) && !E.robotic)
			if(E.damage > 0)
				E.damage = max(0, E.damage - 1)

/datum/reagent/imidazoline/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	if(..())
		return 1

	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/eyes_covered = H.get_body_part_coverage(EYES)
			if(eyes_covered)
				return
			else //eyedrops, why not
				var/datum/organ/internal/eyes/E = H.internal_organs_by_name["eyes"]
				if(istype(E) && !E.robotic)
					M.eye_blurry = 0
					M.eye_blind = 0
					if(E.damage > 0)
						E.damage = 0 //cosmic technologies
					to_chat(H,"<span class='notice'>Your eyes feel better.</span>")

/datum/reagent/imidazoline/reaction_dropper_mob(var/mob/living/M)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/eyes_covered = H.get_body_part_coverage(EYES)
		if(eyes_covered)
			return
		else //eyedrops, why not
			var/datum/organ/internal/eyes/E = H.internal_organs_by_name["eyes"]
			if(istype(E) && !E.robotic)
				M.eye_blurry = 0
				M.eye_blind = 0
				if(E.damage > 0)
					E.damage = 0 //cosmic technologies
				to_chat(H,"<span class='notice'>Your eyes feel better.</span>")

/datum/reagent/inacusiate
	name = "Inacusiate"
	id = INACUSIATE
	description = "Rapidly heals ear damage"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6600FF" //rgb: 100, 165, 255
	overdose_am = REAGENTS_OVERDOSE
	density = 1.58
	specheatcap = 1.65

/datum/reagent/inacusiate/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.ear_damage = 0
	M.ear_deaf = 0

/datum/reagent/peridaxon
	name = "Peridaxon"
	id = PERIDAXON
	description = "Used to encourage recovery of internal organs and nervous systems. Medicate cautiously."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	overdose_am = 10

/datum/reagent/peridaxon/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/chest/C = H.get_organ(LIMB_CHEST)
		for(var/datum/organ/internal/I in C.internal_organs)
			if(I.damage > 0)
				I.damage = max(0,I.damage-0.2)


/datum/reagent/peridaxon/reaction_obj(var/obj/O, var/volume)

	if(..())
		return 1

	if(istype(O, /obj/item/organ/internal))
		var/obj/item/organ/internal/I = O
		if(I.health <= 0)
			I.revive()
		if(I.health < initial(I.health))
			I.health = min(I.health+rand(1,3), initial(I.health))
		if(I.organ_data)
			var/datum/organ/internal/OD = I.organ_data
			if(OD.damage > 0)
				OD.damage = max(0, OD.damage-0.4)


/datum/reagent/bicaridine
	name = "Bicaridine"
	id = BICARIDINE
	description = "Bicaridine is an analgesic medication and can be used to treat blunt trauma."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	overdose_am = REAGENTS_OVERDOSE
	density = 1.96
	specheatcap = 0.57

/datum/reagent/bicaridine/on_mob_life(var/mob/living/M, var/alien)

	if(..())
		return 1

	if(alien != IS_DIONA)
		M.heal_organ_damage(2 * REM,0)


/datum/reagent/bicaridine/on_overdose(var/mob/living/M)
	M.adjustToxLoss(1)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/datum/organ/external/E in H.organs)
			for(var/datum/wound/W in E.wounds)
				W.heal_damage(0.2, TRUE)

/datum/reagent/synthocarisol
	name = "Synthocarisol"
	id = SYNTHOCARISOL
	description = "Synthocarisol is a synthetic version of Carisol, a powerful analgesic that used to be found in traditional medicines made from the horn of the now-extinct Space African Rhino. Tragically, the horns also contained an equal amount of Anticarisol, which led to the medical community dismissing the remedies as nothing more than placebo and overlooking this reagent for several centuries."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#580082" //rgb: 88, 0, 130
	overdose_am = REAGENTS_OVERDOSE
	density = 4.67
	specheatcap = 0.57

/datum/reagent/synthocarisol/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.heal_organ_damage(2 * REM)


/datum/reagent/drink/blisterol
	name = "Blisterol"
	id = BLISTEROL
	description = "Blisterol is a deprecated drug used to treat wounds. Renamed and marked as deprecated due to its tendency to cause blisters."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC"
	density = 1.8
	specheatcap = 3
	adj_temp = 40
	custom_metabolism = 1 //goes through you fast

/datum/reagent/drink/blisterol/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.heal_organ_damage(4 * REM, -1 * REM) //heal 2 brute, cause 0.5 burn

/datum/reagent/hyperzine
	name = "Hyperzine"
	id = HYPERZINE
	description = "Hyperzine is a highly effective, long lasting, muscle stimulant."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	custom_metabolism = 0.03
	overdose_am = REAGENTS_OVERDOSE/2
	density = 1.79
	specheatcap = 0.70

/datum/reagent/hyperzine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(5) && M.stat == CONSCIOUS)
		M.emote(pick("twitch","blink_r","shiver"))

/datum/reagent/hyperzine/on_overdose(var/mob/living/M)
	if(ishuman(M) && M.get_heart()) // Got a heart?
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/heart/damagedheart = H.get_heart()
		if(H.species.name != "Diona" && damagedheart) // Not on dionae
			if(prob(5) && M.stat == CONSCIOUS)
				to_chat(H, "<span class='danger'>You feel a sharp pain in your chest!</span>")
			damagedheart.damage += 1
		else
			M.adjustFireLoss(1) // Burn damage for dionae
	else
		M.adjustToxLoss(1) // Toxins for everyone else

/datum/reagent/hypozine //syndie hyperzine
	name = "Hypozine"
	id = HYPOZINE
	description = "Hypozine is an extremely effective, short lasting, muscle stimulant."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	var/has_been_hypozined = 0
	var/has_had_heart_explode = 0 //We've applied permanent damage.
	custom_metabolism = 0.04
	var/oldspeed = 0
	data = 0

/datum/reagent/hypozine/reagent_deleted()

	if(..())
		return 1

	if(!holder)
		return
	var/mob/M =  holder.my_atom

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!has_been_hypozined)
			return
		var/timedmg = ((data - 60) / 2)
		if (timedmg > 0)
			dehypozine(H, timedmg, 1, 0)

/datum/reagent/hypozine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.reagents.add_reagent ("hyperzine", 0.03) //To pretend it's all okay.
	if(ishuman(M))
		if(data<121 && !has_been_hypozined)
			has_been_hypozined = 1
			has_had_heart_explode = 0 //Fuck them UP after they're done going fast.

	switch(data)
		if(60 to 99)	//Speed up after a minute
			if(data==60)
				to_chat(M, "<span class='notice'>You feel faster.")
				M.movement_speed_modifier += 0.5
				oldspeed += 0.5
			if(prob(5))
				to_chat(M, "<span class='notice'>[pick("Your leg muscles pulsate", "You feel invigorated", "You feel like running")].")
		if(100 to 114)	//painfully fast
			if(data==100)
				to_chat(M, "<span class='notice'>Your muscles start to feel pretty hot.")
				M.movement_speed_modifier += 0.5
				oldspeed += 0.5
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(prob(10))
					if (M.get_heart())
						to_chat(M, "<span class='notice'>[pick("Your legs are heating up", "You feel your heart racing", "You feel like running as far as you can")]!")
					else
						to_chat(M, "<span class='notice'>[pick("Your legs are heating up", "Your body is aching to move", "You feel like running as far as you can")]!")
				H.adjustFireLoss(0.1)
		if(115 to 120)	//traverse at a velocity exceeding the norm
			if(data==115)
				to_chat(M, "<span class='alert'>Your muscles are burning up!")
				M.movement_speed_modifier += 2
				oldspeed += 2

			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(prob(25))
					if (M.get_heart())
						to_chat(M, "<span class='alert'>[pick("Your legs are burning", "All you feel is your heart racing", "Run! Run through the pain")]!")
					else
						to_chat(M, "<span class='alert'>[pick("Your legs are burning", "You feel like you're on fire", "Run! Run through the heat")]!")
				H.adjustToxLoss(1)
				H.adjustFireLoss(2)
		if(121 to INFINITY)	//went2fast
			dehypozine(M)
	data++

/datum/reagent/hypozine/proc/dehypozine(var/mob/living/M, heartdamage = 30, override_remove = 0, explodeheart = 1)
	M.movement_speed_modifier -= oldspeed
	if(has_been_hypozined && !has_had_heart_explode)
		has_had_heart_explode = 1
		if(!override_remove)
			holder.remove_reagent(src.id) //Clean them out

		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.get_heart())//Got a heart?
				var/datum/organ/internal/heart/damagedheart = H.get_heart()
				if (heartdamage >= 30)
					if(H.species.name != "Diona" && damagedheart) //fuck dionae
						to_chat(H, "<span class='danger'>You feel a terrible pain in your chest!</span>")
						damagedheart.damage += heartdamage //Bye heart.
						if(explodeheart)
							qdel(H.remove_internal_organ(H,damagedheart,H.get_organ(LIMB_CHEST)))
						H.adjustOxyLoss(heartdamage*2)
						H.adjustBruteLoss(heartdamage)
					else
						to_chat(H, "<span class='danger'>The heat engulfs you!</span>")
						for(var/datum/organ/external/E in H.organs)
							E.droplimb(1, 1) //Bye limbs!
							H.adjustFireLoss(heartdamage)
							H.adjustBruteLoss(heartdamage)
							H.adjustToxLoss(heartdamage)
							if(explodeheart)
								qdel(H.remove_internal_organ(H,damagedheart,H.get_organ(LIMB_CHEST))) //and heart!
				else if (heartdamage < 30)
					if(H.species.name != "Diona")
						to_chat(H, "<span class='danger'>You feel a sharp pain in your chest!</span>")
					else
						to_chat(H, "<span class='danger'>The heat engulfs you!</span>")
						H.adjustFireLoss(heartdamage)
					damagedheart.damage += heartdamage
					H.adjustToxLoss(heartdamage)
					H.adjustBruteLoss(heartdamage)
			else//No heart?
				to_chat(H, "<span class='danger'>The heat engulfs you!</span>")
				if (heartdamage >= 30)
					for(var/datum/organ/external/E in H.organs)
						E.droplimb(1, 1) //Bye limbs!
						H.adjustBruteLoss(heartdamage)
						H.adjustFireLoss(heartdamage)
				else if (heartdamage < 30)
					H.adjustBruteLoss(heartdamage)
					H.adjustFireLoss(heartdamage)
					H.adjustToxLoss(heartdamage)
		else
			M.gib()
		data = 0
		oldspeed = 0

/datum/reagent/cryoxadone
	name = "Cryoxadone"
	id = CRYOXADONE
	description = "A chemical mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 170K for it to metabolise correctly."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 1.47
	specheatcap = 3.47

/datum/reagent/cryoxadone/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.bodytemperature < 170)
		M.adjustCloneLoss(-1)
		M.adjustOxyLoss(-1)
		M.heal_organ_damage(1,1)
		M.adjustToxLoss(-1)

/datum/reagent/cryoxadone/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins -= 3
	if(T.seed && !T.dead)
		T.health += 3

/datum/reagent/clonexadone
	name = "Clonexadone"
	id = CLONEXADONE
	description = "A liquid compound similar to that used in the cloning process. Can be used to 'finish' the cloning process when used in conjunction with a cryo tube."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 1.22
	specheatcap = 4.27
	custom_plant_metabolism = 0.5

/datum/reagent/clonexadone/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(M.bodytemperature < 170)
		M.adjustCloneLoss(-3)
		M.adjustOxyLoss(-3)
		M.heal_organ_damage(3,3)
		M.adjustToxLoss(-3)

/datum/reagent/clonexadone/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins -= 5
	if(T.seed && !T.dead)
		T.health += 5
		var/datum/seed/S = T.seed
		var/deviation
		if(T.age > S.maturation)
			deviation = max(S.maturation-1, T.age-rand(7,10))
		else
			deviation = S.maturation/S.growth_stages
		T.age -= deviation
		T.skip_aging++
		T.force_update = 1

/datum/reagent/rezadone
	name = "Rezadone"
	id = REZADONE
	description = "A powder derived from fish toxin, this substance can effectively treat genetic damage in humanoids, though excessive consumption has side effects."
	reagent_state = REAGENT_STATE_SOLID
	color = "#669900" //rgb: 102, 153, 0
	overdose_am = REAGENTS_OVERDOSE
	overdose_tick = 35
	data = 1 //Used as a tally
	density = 109.81
	specheatcap = 13.59

/datum/reagent/rezadone/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	switch(data)
		if(1 to 15)
			M.adjustCloneLoss(-1)
			M.heal_organ_damage(1, 1)
		if(15 to 35)
			M.adjustCloneLoss(-2)
			M.heal_organ_damage(2, 1)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
				if(head_organ.disfigured)
					head_organ.disfigured = FALSE
					if(H.get_face_name() != "Unknown")
						H.visible_message("<span class='notice'>[H]'s face shifts and knits itself back into shape!</span>","<span class='notice'>You feel your face shifting and repairing itself!</span>")
					else if(!H.isUnconscious())
						to_chat(H,"<span class='notice'>You feel your face shifting and repairing itself!</span>")

	data++

/datum/reagent/rezadone/on_overdose(var/mob/living/M)
	M.adjustToxLoss(1)
	M.Dizzy(5)
	M.Jitter(5)



//lol homeopathy, surely I'll find somewhere to spawn these
/datum/reagent/antipathogenic
	name = "Placebo"
	id = PLACEBO
	description = "Highly ineffective, don't bet on those to keep you healthy."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#006600" //rgb: 000, 102, 000
	custom_metabolism = 0.01
	overdose_am = 0
	density = 1.44
	specheatcap = 0.68
	data = list(
		"threshold" = 0,
		)

/datum/reagent/antipathogenic/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.immune_system.ApplyAntipathogenics(data["threshold"])



/datum/reagent/antipathogenic/tomato_soup
	name = "Tomato Soup"
	id = TOMATO_SOUP
	description = "Water, tomato extract, and maybe some other stuff. Great for when you're feeling under the weather."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#731008" //rgb: 115, 16, 8
	density = 0.63
	specheatcap = 4.21
	data = list(
		"threshold" = 10,
		)

/datum/reagent/antipathogenic/tomato_soup/on_mob_life(var/mob/living/M)

	..()

	M.nutrition += nutriment_factor
	if(M.bodytemperature < 310) //310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))



//natural antipathogenic, found in garlic and kudzu
/datum/reagent/antipathogenic/allicin
	name = "Allicin"
	id = ALLICIN
	description = "A natural antipathogenic."
	color = "#F1DEB4" //rgb: 241, 222, 180
	custom_metabolism = 0.2
	overdose_am = REAGENTS_OVERDOSE//30u
	data = list(
		"threshold" = 30,
		)

/datum/reagent/antipathogenic/allicin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.drowsyness = max(M.drowsyness - 2 * REM, 0)
	if(holder.has_any_reagents(list(TOXIN, PLANTBGONE, INSECTICIDE, SOLANINE)))
		holder.remove_reagents(list(TOXIN, PLANTBGONE, INSECTICIDE, SOLANINE), 2 * REM)
	if(holder.has_any_reagents(STOXINS))
		holder.remove_reagents(STOXINS, 2 * REM)
	if(holder.has_reagent(PLASMA))
		holder.remove_reagent(PLASMA, REM)
	if(holder.has_any_reagents(SACIDS))
		holder.remove_reagents(SACIDS, REM)
	if(holder.has_reagent(POTASSIUM_HYDROXIDE))
		holder.remove_reagent(POTASSIUM_HYDROXIDE, 2 * REM)
	if(holder.has_reagent(CYANIDE))
		holder.remove_reagent(CYANIDE, REM)
	if(holder.has_reagent(AMATOXIN))
		holder.remove_reagent(AMATOXIN, 2 * REM)
	if(holder.has_reagent(CHLORALHYDRATE))
		holder.remove_reagent(CHLORALHYDRATE, 5 * REM)
	if(holder.has_reagent(CARPOTOXIN))
		holder.remove_reagent(CARPOTOXIN, REM)
	if(holder.has_reagent(ZOMBIEPOWDER))
		holder.remove_reagent(ZOMBIEPOWDER, 0.5 * REM)
	if(holder.has_reagent(MINDBREAKER))
		holder.remove_reagent(MINDBREAKER, 2 * REM)
	var/lucidmod = M.sleeping ? 3 : M.lying + 1 //3x as effective if they're sleeping, 2x if they're lying down
	M.hallucination = max(0, M.hallucination - 5 * REM * lucidmod)
	M.adjustToxLoss(-2 * REM)

/datum/reagent/antipathogenic/allicin/on_overdose(var/mob/living/M)
	if (prob(30))
		M.say("*cough")
	M.Dizzy(5)

//brewed from cryptobiolins and inaprovaline, wards off from most diseases
/datum/reagent/antipathogenic/spaceacillin
	name = "Spaceacillin"
	description = "A generic antipathogenic agent."
	id = SPACEACILLIN
	color = "#C81040" //rgb: 200, 16, 64
	overdose_am = REAGENTS_OVERDOSE / 2//15u
	data = list(
		"threshold" = 50,
		)

/datum/reagent/antipathogenic/spaceacillin/on_overdose(var/mob/living/M)
	M.adjustToxLoss(0.2)
	M.Dizzy(5)

//brewed from spaceacillin and nanobots, can cure any diseases given enough time, but has to be taken in very low quantities.
/datum/reagent/antipathogenic/nanofloxacin
	name = "Nanofloxacin"
	description = "An extremely powerful antipathogenic. To take in equally extremely small doses, or face a variety of adverse effects."
	id = NANOFLOXACIN
	color = "#969696" //rgb: 189, 189, 189
	overdose_am = REAGENTS_OVERDOSE / 10//3u
	data = list(
		"threshold" = 95,
		)

/datum/reagent/antipathogenic/nanofloxacin/on_overdose(var/mob/living/M)
	M.adjustToxLoss(1)
	M.adjustBrainLoss(5)
	M.hallucination += 100
	M.dizziness += 100

/datum/reagent/vaccine
	name = "Vaccine"
	description = "A subunit vaccine. Introduces antigens without pathogenic particles to the body, allowing the immune system to produce enough antibodies to prevent any current or future infection."
	id = VACCINE
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A6A6A6" //rgb: 166, 166, 166
	alpha = 200
	density = 1.05
	specheatcap = 3.49
	custom_metabolism = 1
	data = list(
		"antigen" = list(),
		)

/datum/reagent/vaccine/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.immune_system.ApplyVaccine(data["antigen"])



/datum/reagent/carpotoxin
	name = "Carpotoxin"
	id = CARPOTOXIN
	description = "A deadly neurotoxin produced by the dreaded spess carp."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#003333" //rgb: 0, 51, 51
	density = 319.27 //Assuming it's Tetrodotoxin
	specheatcap = 41.53

/datum/reagent/carpotoxin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustToxLoss(2 * REM)

/datum/reagent/zombiepowder
	name = "Zombie Powder"
	id = ZOMBIEPOWDER
	description = "A strong neurotoxin that puts the subject into a death-like state."
	color = "#669900" //rgb: 102, 153, 0
	density = 829.48
	specheatcap = 274.21

/datum/reagent/zombiepowder/on_mob_life(var/mob/living/carbon/M)

	if(..())
		return 1

	if(volume >= 1) //Hotfix for Fakedeath never ending.
		M.status_flags |= FAKEDEATH
	else
		M.status_flags &= ~FAKEDEATH
	M.adjustOxyLoss(0.5 * REM)
	M.adjustToxLoss(0.5 * REM)
	M.Knockdown(10)
	M.Stun(10)
	M.silent = max(M.silent, 10)
	M.tod = worldtime2text()

/datum/reagent/zombiepowder/reagent_deleted()
	return on_removal(volume)

//Hotfix for Fakedeath never ending.
/datum/reagent/zombiepowder/on_removal(var/amount)
	if(!..(amount))
		return 0

	var/newvol = max(0, volume - amount)
	if(iscarbon(holder.my_atom))
		var/mob/living/carbon/M = holder.my_atom
		if(newvol >= 1)
			M.status_flags |= FAKEDEATH
		else
			M.status_flags &= ~FAKEDEATH
	return 1

/datum/reagent/mindbreaker
	name = "Mindbreaker Toxin"
	id = MINDBREAKER
	description = "A powerful hallucinogen. Not a thing to be messed with."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#B31008" //rgb: 139, 166, 233
	custom_metabolism = 0.05
	density = 0.78
	specheatcap = 5.47

/datum/reagent/mindbreaker/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.hallucination += 10

/datum/reagent/heartbreaker
	name = "Heartbreaker Toxin"
	id = HEARTBREAKER
	description = "A powerful hallucinogen and suffocant. Not a thing to be messed with."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#ff91b7" //rgb: 255, 145, 183
	density = 0.78
	specheatcap = 5.47

/datum/reagent/heartbreaker/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.hallucination += 5
	M.adjustOxyLoss(4 * REM)

/datum/reagent/spiritbreaker
	name = "Spiritbreaker Toxin"
	id = SPIRITBREAKER
	description = "An extremely dangerous hallucinogen often used for torture. Extracted from the leaves of the rare Ambrosia Cruciatus plant."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#3B0805" //rgb: 59, 8, 5
	custom_metabolism = 0.05

/datum/reagent/spiritbreaker/on_mob_life(var/mob/living/M)

	if(..())
		return 1
	if(data >= 165)
		M.adjustToxLoss(0.2)
		M.adjustBrainLoss(5)
		M.hallucination += 100
		M.dizziness += 100
		M.confused += 2
	data++

/datum/reagent/methylin
	name = "Methylin"
	id = METHYLIN
	description = "An intelligence enhancer, also used in the treatment of attention deficit hyperactivity disorder. Also known as Ritalin."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#CC1122"
	custom_metabolism = 0.03
	overdose_am = REAGENTS_OVERDOSE/2
	density = 4.09
	specheatcap = 45.59

/datum/reagent/methylin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(5))
		M.emote(pick("twitch", "blink_r", "shiver"))

/datum/reagent/methylin/on_overdose(var/mob/living/M)
	M.adjustToxLoss(1)
	M.adjustBrainLoss(1)

/datum/reagent/bicarodyne
	name = "Bicarodyne"
	id = BICARODYNE
	description = "Not to be confused with Bicaridine, Bicarodyne is a volatile chemical that reacts violently in the presence of most human endorphins."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	overdose_am = REAGENTS_OVERDOSE * 2 //No need for anyone to get suspicious.
	custom_metabolism = 0.01

/datum/reagent/stabilizine
	name = "Stabilizine"
	id = STABILIZINE
	description = "A stabilizing chemical produced by alien nests to keep their occupants barely alive."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#833484" //rgb: 131, 52, 132
	custom_metabolism = 0.1

/datum/reagent/stabilizine/on_mob_life(var/mob/living/M, var/alien)

	if(..())
		return 1

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		for(var/datum/organ/external/temp in H.organs)
			if(temp.status & ORGAN_BLEEDING)
				temp.clamp_wounds()

	if(M.losebreath >= 10)
		M.losebreath = max(10, M.losebreath - 5)

	M.adjustOxyLoss(-2 * REM)

	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(M.bodytemperature < 311)
		M.bodytemperature = min(310, M.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/preslomite
	name = "Preslomite"
	id = PRESLOMITE
	description = "A stabilizing chemical used in industrial relief efforts."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFFFFF" //rgb: 255, 255, 255
	custom_metabolism = 0.05

/datum/reagent/preslomite/on_mob_life(var/mob/living/M, var/alien)

	if(..())
		return 1
	if(M.losebreath>10)
		M.losebreath = max(10, M.losebreath - 5)
	if(!iscarbon(M))
		return //We can't do anything else for you
	var/mob/living/carbon/C = M
	if(C.health < config.health_threshold_crit + 10)
		C.adjustToxLoss(-2 * REM)
		C.heal_organ_damage(0, 2 * REM)


///////////////////////////////////////////////////////////////////////////////////////////////////////////////



/datum/reagent/nanites
	name = "Nanites"
	id = NANITES
	description = "Microscopic construction robots."
	reagent_state = REAGENT_STATE_SOLID
	dupeable = FALSE
	color = "#535E66" //rgb: 83, 94, 102
	var/disease_type = DISEASE_CYBORG

/datum/reagent/nanites/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)
	if(..())
		return 1

	if((prob(10) && method == TOUCH) || method == INGEST)
		M.infect_disease2_predefined(disease_type, 1, "Robotic Nanites")

/datum/reagent/nanites/reaction_dropper_mob(var/mob/living/M)
	if(prob(30))
		M.infect_disease2_predefined(disease_type, 1, "Robotic Nanites")
	return ..()

/datum/reagent/nanites/autist
	name = "Autist nanites"
	id = AUTISTNANITES
	description = "Microscopic construction robots. They look more autistic than usual."
	disease_type = DISEASE_MOMMI

/datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	id = XENOMICROBES
	description = "Microbes with an entirely alien cellular structure."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#535E66" //rgb: 83, 94, 102

/datum/reagent/xenomicrobes/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	if(..())
		return 1
	if((prob(10) && method == TOUCH) || method == INGEST)
		M.infect_disease2_predefined(DISEASE_XENO, 1, "Xenimicrobes")

/datum/reagent/xenomicrobes/reaction_dropper_mob(var/mob/living/M)
	if(prob(30))
		M.infect_disease2_predefined(DISEASE_XENO, 1, "Xenimicrobes")
	return ..()

/datum/reagent/nanobots
	name = "Nanobots"
	id = NANOBOTS
	description = "Microscopic robots intended for use in humans. Must be loaded with further chemicals to be useful."
	reagent_state = REAGENT_STATE_SOLID
	dupeable = FALSE
	color = "#3E3959" //rgb: 62, 57, 89
	density = 236.6
	specheatcap = 199.99

//Great healing powers. Metabolizes extremely slowly, but gets used up when it heals damage.
//Dangerous in amounts over 5 units, healing that occurs while over 5 units adds to a counter. That counter affects gib chance. Guaranteed gib over 20 units.
/datum/reagent/mednanobots
	name = "Medical Nanobots"
	id = MEDNANOBOTS
	description = "Microscopic robots intended for use in humans. Configured for rapid healing upon infiltration into the body."
	reagent_state = REAGENT_STATE_SOLID
	dupeable = FALSE
	color = "#593948" //rgb: 89, 57, 72
	custom_metabolism = 0.005 //One unit every two hundred ticks, or 400-500 seconds.
	var/spawning_horror = 0
	var/percent_machine = 0
	density = 96.64
	specheatcap = 199.99

/datum/reagent/mednanobots/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(ishuman(M)) //Human type mob, so it has a wound system.
		var/mob/living/carbon/human/H = M
		for(var/datum/organ/external/E in H.organs)
			for(var/datum/wound/internal_bleeding/W in E.wounds)
				W.heal_damage(0.8, TRUE)
				holder.remove_reagent(MEDNANOBOTS, 0.25)
		for(var/datum/organ/internal/I in H.organs)
			if(I.damage)
				I.damage = max(0, I.damage - 5) //Heals a whooping 5 organ damage.
				holder.remove_reagent(MEDNANOBOTS, 0.10) //Less so it doesn't vanish the nanobot supply
			I.status &= ~ORGAN_BROKEN //What do I owe you?
			I.status &= ~ORGAN_SPLINTED //Nothing, it's for free!
			I.status &= ~ORGAN_BLEEDING //FOR FREE?!
	if(M.getOxyLoss() || M.getBruteLoss(TRUE) || M.getToxLoss() || M.getFireLoss(TRUE) || M.getCloneLoss())
		M.adjustOxyLoss(-5)
		M.heal_organ_damage(5, 5) //Heals Brute and Burn. It heals the mob, not individual organs.
		M.adjustToxLoss(-5)
		M.adjustCloneLoss(-5) //Repairs DNA!
		holder.remove_reagent(MEDNANOBOTS, 0.25) //Consumes a quarter of an unit every time it heals.
	if(M.dizziness)
		M.dizziness = max(0, M.dizziness - 15)
	if(M.confused)
		M.remove_confused(5)
	for(var/datum/disease/D in M.viruses) //Diseases that work under the second rework of viruses, or "Viro 3"
		D.spread = "Remissive"
		D.stage--
		if(D.stage < 1)
			D.cure()
	if(iscarbon(M)) //Can we support "Viro 2" diseases?
		var/mob/living/carbon/C = M
		for(var/A in C.virus2)
			var/datum/disease2/disease/D2 = C.virus2[A]
			D2.stage--
			if(D2.stage < 1)
				D2.cure(M)
	switch(volume)
		if(0.1 to 5)
			if(percent_machine>5) //Slowly lowers the percent machine to a minimum of 5 when you aren't above 5 units.
				percent_machine -= 1
				if(prob(20))
					to_chat(M, pick("You feel more like yourself again."))

		if(5 to 20)	//Processing above 5 units runs the risk of getting a big enough dose of nanobots to turn you into a cyberhorror.
			percent_machine += 0.5 //The longer it metabolizes at this stage the more likely.
			if(prob(20))
				to_chat(M, pick("<span class='warning'>Something shifts inside you...</span>",
								"<span class='warning'>You feel different, somehow...</span>"))
			if(prob(percent_machine))
				holder.add_reagent(MEDNANOBOTS, 20)
				to_chat(M, pick("<b><span class='warning'>Your body lurches!</b></span>"))
		if(20 to INFINITY) //Now you've done it.
			if(istype(M, /mob/living/simple_animal/hostile/monster/cyber_horror))
				return
			spawning_horror = 1
			to_chat(M, pick("<b><span class='warning'>Something doesn't feel right...</span></b>", "<b><span class='warning'>Something is growing inside you!</span></b>", "<b><span class='warning'>You feel your insides rearrange!</span></b>"))
			spawn(60)
				if(spawning_horror == 1)
					to_chat(M, "<b><span class='warning'>Something bursts out from inside you!</span></b>")
					message_admins("[key_name(M)] [M] has gibbed and spawned a new cyber horror due to nanobots. ([formatJumpTo(M)])")
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						var/typepath
						typepath = text2path("/mob/living/simple_animal/hostile/monster/cyber_horror/[H.species.name]")
						if(ispath(typepath))
							new typepath(M.loc)
						else
							new /mob/living/simple_animal/hostile/monster/cyber_horror(M.loc)
					else
						new /mob/living/simple_animal/hostile/monster/cyber_horror/monster(M.loc,M)
					spawning_horror = 0
					M.gib()

/datum/reagent/comnanobots
	name = "Combat Nanobots"
	id = COMNANOBOTS
	description = "Microscopic robots intended for use in humans. Configured to grant great resistance to damage."
	reagent_state = REAGENT_STATE_SOLID
	dupeable = FALSE
	color = "#343F42" //rgb: 52, 63, 66
	custom_metabolism = 0.01
	var/has_been_armstrong = 0
	var/armstronged_at = 0 //world.time
	data = 1 //Used as a tally
	density = 134.21
	specheatcap = 5143.18

/datum/reagent/comnanobots/reagent_deleted()

	if(..())
		return 1

	if(!holder)
		return
	var/mob/M =  holder.my_atom

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!has_been_armstrong || (!(M_HULK in H.mutations)))
			return
		dehulk(H, 0, 1, 0)

/datum/reagent/comnanobots/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	switch(volume)
		if(1 to 4.5)
			M.Jitter(5)
			if(prob(10))
				to_chat(M, "You feel slightly energized, but nothing happens")
			if(has_been_armstrong>0) //Added in case person metabolizes below 5 units to prevent infinite hulk
				dehulk(M)
		if(4.5 to 15)
			if(ishuman(M)) //Does nothing to non-humans.
				var/mob/living/carbon/human/H = M
				if(H.species.name != "Diona") //Dionae are broken as fuck
					if(H.hulk_time<world.time && !has_been_armstrong)
						H.hulk_time = world.time + (45 SECONDS)
						armstronged_at = H.hulk_time
						if(!(M_HULK in H.mutations))
							has_been_armstrong = 1
							H.mutations.Add(M_HULK)
							H.update_mutations() //Update our mutation overlays
							H.update_body()
							message_admins("[key_name(M)] is hopped up on combat nanobots! ([formatJumpTo(M)])")
							to_chat(H, "The nanobots supercharge your body!")
					else if(H.hulk_time<world.time && has_been_armstrong) //TIME'S UP
						dehulk(H)
		if(15 to INFINITY)
			to_chat(M, "<b><big>The nanobots tear your body apart!</b></big>")
			M.gib()
			message_admins("[key_name(M)] took too many nanobots and gibbed!([formatJumpTo(M)])")


	data++


/datum/reagent/comnanobots/proc/dehulk(var/mob/living/carbon/human/H, damage = 0, override_remove = 1, gib = 0)

		H.hulk_time = 0 //Just to be sure.
		H.mutations.Remove(M_HULK)
		holder.remove_reagent("comnanobots", holder.get_reagent_amount("comnanobots"))
		//M.dna.SetSEState(HULKBLOCK,0)
		H.update_mutations()		//update our mutation overlays
		H.update_body()
		to_chat(H, "The nanobots burn themselves out in your body.")

//Foam precursor
/datum/reagent/fluorosurfactant
	name = "Fluorosurfactant"
	id = FLUOROSURFACTANT
	description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#9E6B38" //rgb: 158, 107, 56
	density = 1.95
	specheatcap = 0.81

//Metal foaming agent
//This is lithium hydride. Add other recipies (e.g. LiH + H2O -> LiOH + H2) eventually
/datum/reagent/foaming_agent
	name = "Foaming agent"
	id = FOAMING_AGENT
	description = "A agent that yields metallic foam when mixed with light metal and a strong acid."
	reagent_state = REAGENT_STATE_SOLID
	color = "#664B63" //rgb: 102, 75, 99
	density = 0.62
	specheatcap = 49.23

/datum/reagent/nicotine
	name = "Nicotine"
	id = NICOTINE
	description = "A highly addictive stimulant extracted from the tobacco plant."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#181818" //rgb: 24, 24, 24
	density = 1.01

//Solely for flavor.
/datum/reagent/tobacco
	name = "Tobacco"
	id = TOBACCO
	description = "The cured and ground leaves of a tobacco plant."
	reagent_state = REAGENT_STATE_SOLID
	color = "#4c1e00" //rgb: 76, 30, 0
	density = 1.01

/datum/reagent/danbacco
	name = "Tobacco"
	id = DANBACCO //This product may or may not cause cancer.
	description = "The cured and ground leaves of a tobacco plant with additional Discount Dan flavors."
	reagent_state = REAGENT_STATE_SOLID
	color = "#4c1e00" //rgb: 76, 30, 0
	density = 1.01

/datum/reagent/danbacco/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(prob(50)) //Discount dan's special blend.
			H.add_cancer(1, LIMB_CHEST)

/datum/reagent/ammonia
	name = "Ammonia"
	id = AMMONIA
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	reagent_state = REAGENT_STATE_GAS
	color = "#404030" //rgb: 64, 64, 48
	density = 0.51
	specheatcap = 14.38

/datum/reagent/ammonia/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(1)
	if(T.seed && !T.dead)
		T.health += 0.5

/datum/reagent/ultraglue
	name = "Ultra Glue"
	id = GLUE
	description = "An extremely powerful bonding agent."
	color = "#FFFFCC" //rgb: 255, 255, 204

/datum/reagent/diethylamine
	name = "Diethylamine"
	id = DIETHYLAMINE
	description = "A secondary amine, mildly corrosive."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#604030" //rgb: 96, 64, 48
	density = 0.65
	specheatcap = 35.37
	custom_plant_metabolism = 0.1

/datum/reagent/diethylamine/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.1)
	if(prob(100*custom_plant_metabolism))
		T.pestlevel -= 1
	if(T.seed && !T.dead)
		T.health += 0.1
		if(prob(200*custom_plant_metabolism))
			T.affect_growth(1)
		if(!T.seed.immutable)
			var/chance
			chance = unmix(T.seed.lifespan, 15, 125)*200*custom_plant_metabolism
			if(prob(chance))
				T.check_for_divergence(1)
				T.seed.lifespan++
			chance = unmix(T.seed.lifespan, 15, 125)*200*custom_plant_metabolism
			if(prob(chance))
				T.check_for_divergence(1)
				T.seed.endurance++
//Fuck you, alcohol
/datum/reagent/ethylredoxrazine
	name = "Ethylredoxrazine"
	id = ETHYLREDOXRAZINE
	description = "A powerful oxidizer that reacts with ethanol."
	reagent_state = REAGENT_STATE_SOLID
	color = "#605048" //rgb: 96, 80, 72
	density = 1.63
	specheatcap = 0.36

/datum/reagent/ethylredoxrazine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.slurring = 0
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.confused = 0
	holder.convert_some_of_type(/datum/reagent/ethanol, /datum/reagent/water, 2 * REM) //booze-b-gone

//Otherwise known as a "Mickey Finn"
/datum/reagent/chloralhydrate
	name = "Chloral Hydrate"
	id = CHLORALHYDRATE
	description = "A powerful sedative."
	reagent_state = REAGENT_STATE_SOLID
	color = "#000067" //rgb: 0, 0, 103
	// There used to be a bug: if someone was injected with chloral once,
	// and then injected with chloral a second time, this person would
	// briefly wake up. proc/add_reagent, called by proc/trans_to, sets the
	// data var of the destination reagent to the one of the source reagent
	// if the new data was not null. Since this var was set to 1, it ended up
	// resetting the data var of the existing chloralhydrate in the spessman's
	// body, waking them up until the following tick.
	data = null //Used as a tally
	flags = CHEMFLAG_DISHONORABLE // NO CHEATING
	density = 11.43
	specheatcap = 13.79

/datum/reagent/chloralhydrate/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(isnull(data))
		// This is technically not needed: the switch could check for
		// null instead of 0 and "data++" would automatically convert a null
		// to a 0, then increase it to 1. It would work. But this is clearer.
		data = 0
	switch(data)
		if(0)
			M.confused += 2
			M.drowsyness += 2
		if(1 to 79)
			M.sleeping++
		if(80 to INFINITY)
			M.sleeping++
			M.toxloss += (data - 50)
	data++

//Chloral hydrate disguised as normal beer for use by emagged brobots
/datum/reagent/chloralhydrate/beer2
	name = "Beer"
	id = BEER2
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "beerglass"
	glass_desc = "A cold pint of pale lager."

/datum/reagent/suxameth
	name = "Suxameth"
	id = SUX
	description = "A name for Suxamethonium chloride. A medical full-body paralytic preferred because it is easy to purge."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#CFC5E9" //rgb: 207, 197, 223
	data = null
	flags = CHEMFLAG_DISHONORABLE
	overdose_am = 21
	custom_metabolism = 1

/datum/reagent/suxameth/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(isnull(data))
		// copied from chloral for the same reasons
		data = 0
	if(data >= 2)
		M.SetStunned(2)
		M.SetKnockdown(2)
	data++

/datum/reagent/suxameth/on_overdose(var/mob/living/M)
	M.adjustOxyLoss(6) //Paralyzes the diaphragm if they go over 20 units

/////////////////////////Food Reagents////////////////////////////

//Part of the food code. Nutriment is used instead of the old "heal_amt" code
//Also is where all the food condiments, additives, and such go.
/datum/reagent/nutriment
	name = "Nutriment"
	id = NUTRIMENT
	description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#664330" //rgb: 102, 67, 48
	density = 6.54
	specheatcap = 17.56

/datum/reagent/nutriment/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(50))
		M.heal_organ_damage(1, 0)

	M.nutrition += nutriment_factor	//For hunger and fatness

/datum/reagent/nutriment/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(1)
	if(T.seed && !T.dead)
		T.health += 0.5

//The anti-nutriment
/datum/reagent/lipozine
	name = "Lipozine"
	id = LIPOZINE
	description = "A chemical compound that causes a powerful fat-burning reaction."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 10 * REAGENTS_METABOLISM
	color = "#BBEDA4" //rgb: 187, 237, 164
	density = 2.63
	specheatcap = 381.13

/datum/reagent/lipozine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition -= nutriment_factor
	M.overeatduration = 0
	if(M.nutrition < 0) //Prevent from going into negatives
		M.nutrition = 0

/datum/reagent/dietine
	name = "Dietine"
	id = DIETINE
	description = "An uncommon makeshift weight loss aid. Mildly toxic, moreso in larger doses."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#BBEDA4" //rgb: 187, 237, 164
	density = 1.44
	specheatcap = 60
	overdose_am = 5

	var/on_a_diet
	var/oldmetabolism

/datum/reagent/dietine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(5))
		M.adjustToxLoss(1)

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!on_a_diet)
			oldmetabolism = H.calorie_burn_rate
			on_a_diet = TRUE
			H.calorie_burn_rate += H.calorie_burn_rate * 3
		if(prob(8))
			H.vomit(0,1)

/datum/reagent/dietine/reagent_deleted()
	if(ishuman(holder.my_atom))
		var/mob/living/carbon/human/H = holder.my_atom
		H.calorie_burn_rate -= oldmetabolism / 3
		on_a_diet = FALSE

/datum/reagent/dietine/on_overdose(var/mob/living/M)
	M.adjustToxLoss(1)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.vomit(0,1)

/datum/reagent/soysauce
	name = "Soysauce"
	id = SOYSAUCE
	description = "A salty sauce made from the soy plant."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#792300" //rgb: 121, 35, 0
	density = 1.17
	specheatcap = 1.38

/datum/reagent/ketchup
	name = "Ketchup"
	id = KETCHUP
	description = "Ketchup, catsup, whatever. It's tomato paste."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#731008" //rgb: 115, 16, 8

/datum/reagent/mustard
	name = "Mustard"
	id = MUSTARD
	description = "A spicy yellow paste."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#cccc33" //rgb: 204, 204, 51

/datum/reagent/relish
	name = "Relish"
	id = RELISH
	description = "A pickled cucumber jam. Tasty!"
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 4 * REAGENTS_METABOLISM
	color = "#336600" //rgb: 51, 102, 0

/datum/reagent/dipping_sauce
	name = "Dipping Sauce"
	id = DIPPING_SAUCE
	description = "Adds extra, delicious texture to a snack."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#33cc33" //rgb: 51, 204, 51

/datum/reagent/mayo
	name = "Mayonnaise"
	id = MAYO
	description = "A substance of unspeakable suffering."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 4 * REAGENTS_METABOLISM
	color = "#FAF0E6" //rgb: 51, 102, 0

/datum/reagent/zamspices
	name = "Zam Spices"
	id = ZAMSPICES
	description = "A blend of several mothership spices. It has a sharp, tangy aroma."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#850E0E" //rgb: 133, 14, 14

/datum/reagent/zammild
	name = "Zam's Mild Sauce"
	id = ZAMMILD
	description = "A tasty sauce made from mothership spices and acid."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 4 * REAGENTS_METABOLISM
	color = "#B38B26" //rgb: 179, 139, 38

/datum/reagent/zamspicytoxin
	name = "Zam's Spicy Sauce"
	id = ZAMSPICYTOXIN
	description = "A dangerously flavorful sauce made from mothership spices and powerful acid."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 6 * REAGENTS_METABOLISM
	color = "#D35A0D" //rgb: 211, 90, 13

/datum/reagent/zamspicytoxin/on_mob_life(var/mob/living/M, var/alien)

	if(..())
		return 1

	if(alien && alien == IS_GREY)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			M.bodytemperature += 1.4 * TEMPERATURE_DAMAGE_COEFFICIENT
			switch(volume)
				if(1 to 15)
					if(prob(10))
						to_chat(M,"<span class='notice'>Your throat feels a little hot!</span>")
					if(prob(5))
						to_chat(M,"<span class='notice'>[pick("Now that's a Zam zing!","By the mothership, that was a perfect spice level.","That was an excellent flavor.","Spicy goodness is flowing through your system.")]</span>")
				if(15 to 30)
					if(prob(10))
						to_chat(M,"<span class='notice'>Your throat feels like it's on fire!</span>")
						M.visible_message("<span class='warning'>[M] [pick("dry heaves!", "coughs!", "splutters!")]</span>")
					if(prob(5))
						to_chat(M,"<span class='warning'>[pick("That's a serious Zam zing!", "This is really starting to burn.", "The spice is overpowering the flavor.", "Spicy embers are starting to flare up in your chest.")]</span>")
					if(prob(5))
						to_chat(M,"<span class='warning'>You feel a slight burning in your chest.</span>")
						M.adjustToxLoss(1)
				if(30 to INFINITY)
					M.Jitter(5)
					if(prob(15))
						H.custom_pain("You feel an awful burning in your chest.",1)
						M.adjustToxLoss(3)
					if(prob(10))
						H.vomit()
					if(prob(5))
						to_chat(M,"<span class='warning'>[pick("That's way too much zing!", "By the mothership, that burns!", "You can't taste anything but flaming spice!", "There's a fire in your gut!")]</span>")
					if(prob(5))
						var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
						if(istype(L))
							L.take_damage(1, 0)

	else
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			M.bodytemperature += 1.6 * TEMPERATURE_DAMAGE_COEFFICIENT
			switch(volume)
				if(1 to 15)
					if(prob(10))
						to_chat(M,"<span class='notice'>Your throat feels like it's on fire!</span>")
						M.visible_message("<span class='warning'>[M] [pick("dry heaves!", "coughs!", "splutters!")]</span>")
					if(prob(5))
						to_chat(M,"<span class='warning'>You feel a slight burning in your chest.</span>")
						M.adjustToxLoss(1)
				if(15 to 30)
					M.Jitter(5)
					if(prob(15))
						H.custom_pain("You feel an awful burning in your chest.",1)
						M.adjustToxLoss(3)
					if(prob(10))
						H.vomit()
					if(prob(5))
						var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
						if(istype(L))
							L.take_damage(1, 0)
				if(30 to INFINITY)
					M.Jitter(5)
					if(prob(40))
						M.adjustToxLoss(6)
					if(prob(25))
						H.vomit()
					if(prob(15))
						var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
						if(istype(L))
							L.take_damage(5, 0)
					if(prob(10))
						H.custom_pain("Your chest feels like its on fire!",1)
						M.audible_scream()

/datum/reagent/egg_yolk
	name = "Egg Yolk"
	id = EGG_YOLK
	description = "A chicken before it could become a chicken."
	nutriment_factor = 15 * REAGENTS_METABOLISM
	reagent_state = REAGENT_STATE_LIQUID
	color = "#ffcd42"

/datum/reagent/spaghetti
	name = "Spaghetti"
	id = SPAGHETTI
	description = "Bursts into treats on consumption."
	nutriment_factor = 8 * REAGENTS_METABOLISM
	reagent_state = REAGENT_STATE_SOLID
	color = "#FFCD9A"

/datum/reagent/spaghetti/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(prob(80))
			H.apply_effect(1, STUTTER)
		else
			if(prob(50))
				H.Mute(1)
			else
				H.visible_message("<span class='notice'>[src] spills their spaghetti.</span>","<span class='notice'>You spill your spaghetti.</span>")
				var/turf/T = get_turf(M)
				new /obj/effect/decal/cleanable/spaghetti_spill(T)
				playsound(M, 'sound/effects/splat.ogg', 50, 1)

/datum/reagent/drink/gatormix
	name = "Gator Mix"
	id = GATORMIX
	description = "A vile sludge of mixed carbohydrates. Makes people more alert. May cause kidney damage in large doses."
	nutriment_factor = 8 * REAGENTS_METABOLISM //get fat, son
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A41D77"
	adj_dizzy = -5
	adj_drowsy = -5
	adj_sleepy = -5
	adj_temp = 10
	overdose_am = 50

/datum/reagent/drink/gatormix/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M) && prob(20))
		var/mob/living/carbon/human/H = M
		H.Jitter(5)

/datum/reagent/drink/gatormix/on_overdose(var/mob/living/M)
	if(ishuman(M) && prob(5))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/kidney/killdney = H.get_kidneys()
		killdney.damage++


/datum/reagent/capsaicin
	name = "Capsaicin Oil"
	id = CAPSAICIN
	description = "This is what makes chilis hot."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#B31008" //rgb: 179, 16, 8
	data = 1 //Used as a tally
	custom_metabolism = FOOD_METABOLISM
	density = 0.53
	specheatcap = 3.49

/datum/reagent/mustard_powder
	name = "Mustard Powder"
	id = MUSTARD_POWDER
	description = "A deep yellow powder, unrelated the gas variant"
	nutriment_factor = 3 * REAGENTS_METABOLISM
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8D07D" // dark dirty yellow


/datum/reagent/capsaicin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(5))
		to_chat(M,"<span class='notice'>Your face feels a little hot!</span>")

	var/mob/living/carbon/human/H
	if(ishuman(M))
		H = M
	switch(data)
		if(1 to 15)
			M.bodytemperature += 0.6 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("frostoil"))
				holder.remove_reagent("frostoil", 5)
			if(isslime(M))
				M.bodytemperature += rand(5,20)
			if(isslimeperson(H))
				M.bodytemperature += rand(5,20)
		if(15 to 25)
			M.bodytemperature += 0.9 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature += rand(10,20)
			if(isslimeperson(H))
				M.bodytemperature += rand(10,20)
		if(25 to INFINITY)
			M.bodytemperature += 1.2 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature += rand(15,20)
			if(isslimeperson(H))
				M.bodytemperature += rand(15,20)
	data++

/datum/reagent/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = CONDENSEDCAPSAICIN
	description = "This shit goes in pepperspray."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#B31008" //rgb: 179, 16, 8
	density = 0.9
	specheatcap = 8.59
	data = 1

/datum/reagent/condensedcapsaicin/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	if(..())
		return 1

	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/mouth_covered = H.get_body_part_coverage(MOUTH)
			var/obj/item/eyes_covered = H.get_body_part_coverage(EYES)
			if(eyes_covered && mouth_covered)
				H << "<span class='warning'>Your [mouth_covered == eyes_covered ? "[mouth_covered] protects" : "[mouth_covered] and [eyes_covered] protect"] you from the pepperspray!</span>"
				return
			else if(mouth_covered)	//Reduced effects if partially protected
				H << "<span class='warning'>Your [mouth_covered] protects your mouth from the pepperspray!</span>"
				H.eye_blurry = max(M.eye_blurry, 15)
				H.eye_blind = max(M.eye_blind, 5)
				H.Paralyse(1)
				H.drop_item()
				return
			else if(eyes_covered) //Eye cover is better than mouth cover
				H << "<span class='warning'>Your [eyes_covered] protects your eyes from the pepperspray!</span>"
				H.audible_scream()
				H.eye_blurry = max(M.eye_blurry, 5)
				return
			else //Oh dear
				H.audible_scream()
				to_chat(H, "<span class='danger'>You are sprayed directly in the eyes with pepperspray!</span>")
				H.eye_blurry = max(M.eye_blurry, 25)
				H.eye_blind = max(M.eye_blind, 10)
				H.Paralyse(1)
				H.drop_item()

/datum/reagent/condensedcapsaicin/reaction_dropper_mob(var/mob/living/M)
	M.audible_scream()
	to_chat(M, "<span class='danger'>Pure solid peppespray is dropped directly in your eyes!</span>")
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.eye_blurry = max(M.eye_blurry, 25)
		H.eye_blind = max(M.eye_blind, 10)
		H.Paralyse(1)
		H.drop_item()
	return ..()

/datum/reagent/condensedcapsaicin/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(5))
		to_chat(M,"<span class='notice'>Your face feels like it's on fire!</span>")
		M.visible_message("<span class='warning'>[M] [pick("dry heaves!", "coughs!", "splutters!")]</span>")

	//let's just copy capsaicin/on_mob_life does, but make it worse.
	var/mob/living/carbon/human/H
	if(ishuman(M))
		H = M
	switch(data)
		if(1 to 15)
			M.bodytemperature += 0.9 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("frostoil"))
				holder.remove_reagent("frostoil", 5)
			if(isslime(M))
				M.bodytemperature += rand(10,20)
			if(isslimeperson(H))
				M.bodytemperature += rand(10,20)
		if(15 to 30)
			M.bodytemperature += 1.1 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(prob(6))//Start vomiting
				H.vomit(0,1)
			if(isslime(M))
				M.bodytemperature += rand(20,25)
			if(isslimeperson(H))
				M.bodytemperature += rand(20,25)
		if(30 to 45)//Reagent dies out at about 50. Set up the vomiting to "fade out".
			if(prob(9))
				H.vomit()
	data++


/datum/reagent/blackcolor
	name = "Black Food Coloring"
	id = BLACKCOLOR
	description = "A black coloring used to dye food and drinks."
	reagent_state = REAGENT_STATE_LIQUID
	flags = CHEMFLAG_OBSCURING
	color = "#000000" //rgb: 0, 0, 0

/datum/reagent/frostoil
	name = "Frost Oil"
	id = FROSTOIL
	description = "A special oil that noticably chills the body. Extraced from Icepeppers."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#8BA6E9" //rgb: 139, 166, 233
	data = 1 //Used as a tally
	custom_metabolism = FOOD_METABOLISM

/datum/reagent/frostoil/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	var/mob/living/carbon/human/H
	if(ishuman(M))
		H = M
	switch(data)
		if(1 to 15)
			M.bodytemperature = max(M.bodytemperature-0.3 * TEMPERATURE_DAMAGE_COEFFICIENT,T20C)
			if(holder.has_reagent("capsaicin"))
				holder.remove_reagent("capsaicin", 5)
			if(isslime(M))
				M.bodytemperature -= rand(5,20)
			if(isslimeperson(H))
				M.bodytemperature -= rand(5,20)
		if(15 to 25)
			M.bodytemperature = max(M.bodytemperature-0.6 * TEMPERATURE_DAMAGE_COEFFICIENT,T20C)
			if(isslime(M))
				M.bodytemperature -= rand(10,20)
			if(isslimeperson(H))
				M.bodytemperature -= rand(10,20)
		if(25 to INFINITY)
			M.bodytemperature = max(M.bodytemperature-0.9 * TEMPERATURE_DAMAGE_COEFFICIENT,T20C)
			if(prob(1))
				M.emote("shiver")
			if(isslime(M))
				M.bodytemperature -= rand(15,20)
			if(isslimeperson(H))
				M.bodytemperature -= rand(15,20)
	data++

/datum/reagent/frostoil/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	for(var/mob/living/carbon/slime/M in T)
		M.adjustToxLoss(rand(15, 30))
	for(var/mob/living/carbon/human/H in T)
		if(isslimeperson(H))
			H.adjustToxLoss(rand(5, 15))

/datum/reagent/sodiumchloride
	name = "Table Salt"
	id = SODIUMCHLORIDE
	description = "A salt made of sodium chloride. Commonly used to season food."
	reagent_state = REAGENT_STATE_SOLID
	color = "#FFFFFF" //rgb: 255, 255, 255
	density = 2.09
	specheatcap = 1.65

/datum/reagent/sodiumchloride/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1
	if(!T.has_dense_content() && volume >= 10 && !(locate(/obj/effect/decal/cleanable/salt) in T))
		if(!T.density)
			new /obj/effect/decal/cleanable/salt(T)


/datum/reagent/sodiumchloride/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	var/list/borers = M.get_brain_worms()
	if(borers)
		for(var/mob/living/simple_animal/borer/B in borers)
			B.health -= 1
			to_chat(B, "<span class='warning'>Something in your host's bloodstream burns you!</span>")

/datum/reagent/sodiumchloride/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_water(-3)
	T.adjust_nutrient(-0.3)
	T.toxins += 8
	T.weedlevel -= 2
	T.pestlevel -= 1
	if(T.seed && !T.dead)
		T.health -= 2

/datum/reagent/creatine
	name = "Creatine"
	id = CREATINE
	description = "Highly toxic substance that grants the user enormous strength, before their muscles seize and tear their own body to shreds."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255, 255, 255
	var/has_been_hulk = 0
	var/has_ripped_and_torn = 0 //We've applied permanent damage.
	var/hulked_at = 0 //world.time
	custom_metabolism = 0.1
	data = 1 //Used as a tally
	density = 6.82
	specheatcap = 678.67

/datum/reagent/creatine/reagent_deleted()

	if(..())
		return 1

	if(!holder)
		return
	var/mob/M =  holder.my_atom

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!has_been_hulk || has_ripped_and_torn || (!(M_HULK in H.mutations)))
			return
		var/timedmg = ((30 SECONDS) - (H.hulk_time - world.time)) / 10
		dehulk(H, timedmg * 3, 1, 0)

/datum/reagent/creatine/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	switch(volume)
		if(1 to 25)
			M.adjustToxLoss(1)
			M.Dizzy(5)
			M.Jitter(5)
			if(prob(5) && M.feels_pain())
				to_chat(M, "<span class='warning'>Oh god, the pain!</span>")
		if(25 to INFINITY)
			if(ishuman(M)) //Does nothing to non-humans.
				var/mob/living/carbon/human/H = M
				if(H.species.name != "Diona") //Dionae are broken as fuck
					if(H.hulk_time<world.time && !has_been_hulk)
						H.hulk_time = world.time + (30 SECONDS)
						hulked_at = H.hulk_time
						if(!(M_HULK in H.mutations))
							has_been_hulk = 1
							has_ripped_and_torn = 0 //Fuck them UP after they dehulk.
							H.mutations.Add(M_HULK)
							H.update_mutations() //Update our mutation overlays
							H.update_body()
							message_admins("[key_name(M)] is TOO SWOLE TO CONTROL (on creatine)! ([formatJumpTo(M)])")
					else if(H.hulk_time<world.time && has_been_hulk) //TIME'S UP
						dehulk(H)
					else if(prob(1))
						H.say(pick("YOU TRYIN' BUILD SUM MUSSLE?", "TOO SWOLE TO CONTROL", "HEY MANG", "HEY MAAAANG"))

	data++

/datum/reagent/creatine/proc/dehulk(var/mob/living/carbon/human/H, damage = 200, override_remove = 0, gib = 1)

	if(has_been_hulk && !has_ripped_and_torn)
		to_chat(H, "<span class='warning'>You feel like your muscles are ripping apart!</span>")
		has_ripped_and_torn = 1
		if(!override_remove)
			holder.remove_reagent(src.id) //Clean them out
		H.adjustBruteLoss(damage) //Crit

		if(gib)
			for(var/datum/organ/external/E in H.organs)
				if(prob(50))
					//Override the current limb status and don't cause an explosion
					E.droplimb(1, 1)

			if(H.species)
				hgibs(H.loc, H.virus2, H.dna, H.species.flesh_color, H.species.blood_color)
			else
				hgibs(H.loc, H.virus2, H.dna)

		H.hulk_time = 0 //Just to be sure.
		H.mutations.Remove(M_HULK)
		//M.dna.SetSEState(HULKBLOCK,0)
		H.update_mutations()		//update our mutation overlays
		H.update_body()

/datum/reagent/carp_pheromones
	name = "Carp Pheromones"
	id = CARPPHEROMONES
	description = "A disgusting liquid with a horrible smell, which is used by space carps to mark their territory and food."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6AAA96" //rgb: 106, 170, 150
	custom_metabolism = 0.05
	data = 0 //Used as a tally
	density = 109.06
	specheatcap = ARBITRARILY_LARGE_NUMBER //Contains leporazine, better this than 6 digits

/datum/reagent/carp_pheromones/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(!data)
		to_chat(M,"<span class='good'><b>You feel more carplike! [pick("Do you, perhaps...?","Maybe... just maybe...")]</b></span>")

	if(volume < 3)
		if(volume <= custom_metabolism)
			to_chat(M,"<span class='danger'>You feel not at all carplike!</span>")
		else if(!(data%4))
			to_chat(M,"<span class='warning'>You feel less carplike...</span>")

	data++

	var/stench_radius = clamp(data * 0.1, 1, 6) //Stench starts out with 1 tile radius and grows after every 10 life ticks

	if(prob(5)) //5% chance of stinking per life()
		for(var/mob/living/carbon/C in oview(stench_radius, M)) //All other carbons in 4 tile radius (excluding our mob)
			if(C.stat)
				return
			if(istype(C.wear_mask))
				var/obj/item/clothing/mask/c_mask = C.wear_mask
				if(c_mask.body_parts_covered & MOUTH)
					continue //If the carbon's mouth is covered, let's assume they don't smell it

			to_chat(C, "<span class='warning'>You are engulfed by a [pick("tremendous", "foul", "disgusting", "horrible")] stench emanating from [M]!</span>")

/datum/reagent/blackpepper
	name = "Black Pepper"
	id = BLACKPEPPER
	description = "A powder ground from peppercorns. *AAAACHOOO*"
	reagent_state = REAGENT_STATE_SOLID
	color = "#664C3E" //rgb: 40, 30, 24


/datum/reagent/blackpepper/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1
	if(!T.has_dense_content() && volume >= 10 && !(locate(/obj/effect/decal/cleanable/pepper) in T))
		new /obj/effect/decal/cleanable/pepper(T)

/datum/reagent/cinnamon
	name = "Cinnamon Powder"
	id = CINNAMON
	description = "A spice, obtained from the bark of cinnamomum trees."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#D2691E" //rgb: 210, 105, 30

/datum/reagent/coco
	name = "Coco Powder"
	id = COCO
	description = "A fatty, bitter paste made from coco beans."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" //rgb: 48, 32, 0

/datum/reagent/coco/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor

/datum/reagent/drink/hot_coco
	name = "Hot Chocolate"
	id = HOT_COCO
	description = "Made with love! And cocoa beans."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 2 * FOOD_METABOLISM
	color = "#403010" //rgb: 64, 48, 16
	adj_temp = 5
	density = 1.2
	specheatcap = 4.18
	mug_desc = "A delicious warm brew of milk and chocolate."

/datum/reagent/drink/hot_coco/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(M.bodytemperature < 310) //310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))

	M.nutrition += nutriment_factor

/datum/reagent/drink/hot_coco/subhuman
	id = HOT_COCO_SUBHUMAN
	description = "Made with hate! And coco beans."
	data = 0

/datum/reagent/drink/hot_coco/subhuman/on_mob_life(var/mob/living/M)
	..()
	if(prob(1))
		to_chat(M, "<span class='notice'>You are suddenly reminded that you are subhuman.</span>")

/datum/reagent/drink/creamy_hot_coco
	name = "Creamy Hot Chocolate"
	id = CREAMY_HOT_COCO
	description = "Never ever let it cool."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 2 * FOOD_METABOLISM
	color = "#403010" //rgb: 64, 48, 16
	glass_icon_state = "creamyhotchocolate"
	glass_name = "\improper Creamy Hot Chocolate"
	adj_temp = 5
	density = 1.2
	specheatcap = 4.18
	mug_desc = "A delicious warm brew of milk and chocolate. Never ever let it cool."

/datum/reagent/amatoxin
	name = "Amatoxin"
	id = AMATOXIN
	description = "A powerful poison derived from certain species of mushroom."
	color = "#792300" //rgb: 121, 35, 0

/datum/reagent/amatoxin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustToxLoss(1.5)

/datum/reagent/amanatin
	name = "Alpha-Amanatin"
	id = AMANATIN
	description = "A deadly poison derived from certain species of Amanita. Sits in the victim's system for a long period of time, then ravages the body."
	color = "#792300" //rgb: 121, 35, 0
	custom_metabolism = 0.01
	data = 1 //Used as a tally
	var/activated = 0

/datum/reagent/amanatin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(volume <= 3 && data >= 60 && !activated)	//Minimum of 1 minute required to be useful
		activated = 1
	if(activated)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(prob(8))
				H << "<span class='warning'>You feel violently ill.</span>"
			if(prob(min(data / 10, 100)))
				H.vomit()
			var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
			if(istype(L) && !L.is_broken())
				L.take_damage(data * 0.01, 0)
				H.adjustToxLoss(round(data / 20, 1))
			else
				H.adjustToxLoss(round(data / 10, 1))
				data += 4
	switch(data)
		if(1 to 30)
			M.druggy = max(M.druggy, 10)
		if(540 to 600)	//Start barfing violently after 9 minutes
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(prob(12))
					H << "<span class='warning'>You feel violently ill.</span>"
				H.adjustToxLoss(0.1)
				if(prob(8))
					H.vomit()
		if(600 to INFINITY)	//Ded in 10 minutes with a minimum of 6 units
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(prob(20))
					H << "<span class='sinister'>You feel deathly ill.</span>"
				var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
				if(istype(L) && !L.is_broken())
					L.take_damage(10, 0)
				else
					H.adjustToxLoss(60)
	data++

/datum/reagent/psilocybin
	name = "Psilocybin"
	id = PSILOCYBIN
	description = "A strong psycotropic derived from certain species of mushroom."
	color = "#E700E7" //rgb: 231, 0, 231
	data = 1 //Used as a tally

/datum/reagent/psilocybin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.druggy = max(M.druggy, 30)
	switch(data)
		if(1 to 5)
			if(!M.stuttering)
				M.stuttering = 1
			M.Dizzy(5)
			if(prob(10))
				M.emote(pick("twitch", "giggle"))
		if(5 to 10)
			if(!M.stuttering)
				M.stuttering = 1
			M.Jitter(10)
			M.Dizzy(10)
			M.druggy = max(M.druggy, 35)
			if(prob(20))
				M.emote(pick("twitch", "giggle"))
		if (10 to INFINITY)
			if(!M.stuttering)
				M.stuttering = 1
			M.Jitter(20)
			M.Dizzy(20)
			M.druggy = max(M.druggy, 40)
			if(prob(30))
				M.emote(pick("twitch", "giggle"))
	data++

/datum/reagent/sprinkles
	name = "Sprinkles"
	id = SPRINKLES
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
	nutriment_factor = REAGENTS_METABOLISM
	color = "#FF00FF" //rgb: 255, 0, 255
	density = 1.59
	specheatcap = 1.24

/datum/reagent/sprinkles/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += REM * nutriment_factor
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.job in list("Security Officer", "Head of Security", "Detective", "Warden"))
			H.heal_organ_damage(1, 1)
			H.nutrition += REM * nutriment_factor //Double nutrition

/*
//Removed because of meta bullshit. this is why we can't have nice things.
/datum/reagent/syndicream
	name = "Cream filling"
	id = SYNDICREAM
	description = "Delicious cream filling of a mysterious origin. Tastes criminally good."
	nutriment_factor = FOOD_METABOLISM
	color = "#AB7878" //RGB: 171, 120, 120
	custom_metabolism = FOOD_METABOLISM

/datum/reagent/syndicream/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.nutrition += REM * nutriment_factor
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.mind && H.mind.special_role)
			H.heal_organ_damage(1, 1)
			H.nutrition += REM * nutriment_factor
*/

/datum/reagent/cornoil
	name = "Corn Oil"
	id = CORNOIL
	description = "An oil derived from various types of corn."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 20 * REAGENTS_METABOLISM
	color = "#302000" //rgb: 48, 32, 0
	var/has_had_heart_explode = 0

/datum/reagent/cornoil/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor

//Now handle corn oil interactions
	if(!has_had_heart_explode && ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/heart/heart = H.internal_organs_by_name["heart"]
		switch(volume)
			if(1 to 15)
				if(prob(5))
					H.emote("me", 1, "burps.")
					holder.remove_reagent(id, 0.1 * FOOD_METABOLISM)
			if(15 to 100)
				if(prob(10))
					to_chat(H,"<span class='warning'>You really don't feel very good.</span>")
				if(prob(5))
					if(heart && !heart.robotic)
						to_chat(H,"<span class='warning'>You feel a burn in your chest.</span>")
						heart.take_damage(0.2, 1)
			if(100 to INFINITY)//Too much corn oil holy shit, no one should ever get this high
				if(heart && !heart.robotic)
					to_chat(H, "<span class='danger'>You feel a terrible pain in your chest!</span>")
					has_had_heart_explode = 1 //That way it doesn't blow up any new transplant hearts
					qdel(H.remove_internal_organ(H,heart,H.get_organ(LIMB_CHEST)))
					H.adjustOxyLoss(60)
					H.adjustBruteLoss(30)

/datum/reagent/cornoil/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(volume >= 3)
		T.wet(800)
	var/hotspot = (locate(/obj/effect/fire) in T)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = T.remove_air(T:air:total_moles())
		lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2), 0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

/datum/reagent/enzyme
	name = "Universal Enzyme"
	id = ENZYME
	description = "A universal enzyme used in the preperation of certain chemicals and foods."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#365E30" //rgb: 54, 94, 48
	density = 9.68
	specheatcap = 101.01

/datum/reagent/dry_ramen
	name = "Dry Ramen"
	id = DRY_RAMEN
	description = "Space age food, since August 25, 1958. Contains dried noodles and vegetables, best cooked in boiling water."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = REAGENTS_METABOLISM
	color = "#302000" //rgb: 48, 32, 0

/datum/reagent/dry_ramen/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor

/datum/reagent/hot_ramen
	name = "Hot Ramen"
	id = HOT_RAMEN
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" //rgb: 48, 32, 0
	density = 1.33
	specheatcap = 4.18

/datum/reagent/hot_ramen/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor
	if(M.bodytemperature < 310) //310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (10 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/hell_ramen
	name = "Hell Ramen"
	id = HELL_RAMEN
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" //rgb: 48, 32, 0
	density = 1.42
	specheatcap = 14.59

/datum/reagent/hell_ramen/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor
	M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT

/datum/reagent/flour
	name = "flour"
	id = FLOUR
	description = "This is what you rub all over yourself to pretend to be a ghost."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = REAGENTS_METABOLISM
	color = "#FFFFFF" //rgb: 0, 0, 0

/datum/reagent/flour/on_mob_life(var/mob/living/M)

	if(..())
		return 1
	M.nutrition += nutriment_factor

/datum/reagent/flour/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(!(locate(/obj/effect/decal/cleanable/flour) in T))
		new /obj/effect/decal/cleanable/flour(T)

/datum/reagent/flour/nova_flour
	name = "nova flour"
	id = NOVAFLOUR
	description = "This is what you rub all over yourself to set on fire."
	color = "#B22222" //rgb: 178, 34, 34

/datum/reagent/flour/nova_flour/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.bodytemperature += 3 * TEMPERATURE_DAMAGE_COEFFICIENT

/datum/reagent/pancake_mix
	name = "pancake mix"
	id = PANCAKE
	description = "A mix of flour, milk, butter, and egg yolk. ready to be cooked into delicious pancakes."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#E6C968" //rgb: 90, 78, 40

/datum/reagent/pancake_mix/on_mob_life(var/mob/living/M)

	if(..())
		return 1
	M.nutrition += nutriment_factor

/datum/reagent/pancake_mix/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(!(locate(/obj/effect/decal/cleanable/flour) in T))
		var/obj/effect/decal/cleanable/flour/F = new (T)
		F.color = "#E6C968"

/datum/reagent/rice
	name = "Rice"
	id = RICE
	description = "Enjoy the great taste of nothing."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#FFFFFF" //rgb: 0, 0, 0

/datum/reagent/rice/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor

/datum/reagent/cherryjelly
	name = "Cherry Jelly"
	id = CHERRYJELLY
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#801E28" //rgb: 128, 30, 40

/datum/reagent/cherryjelly/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor

/datum/reagent/discount
	name = "Discount Dan's Special Sauce"
	id = DISCOUNT
	description = "You can almost feel your liver failing, just by looking at it."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 111, 136, 79
	data = 1 //Used as a tally
	nutriment_factor = 4 * REAGENTS_METABOLISM

/datum/reagent/discount/New()
	..()
	density = rand(12,48)
	specheatcap = rand(25,2500)/100

/datum/reagent/discount/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		switch(volume)
			if(1 to 20)
				if(prob(5))
					to_chat(H,"<span class='warning'>You don't feel very good.</span>")
					holder.remove_reagent(src.id, 0.1 * FOOD_METABOLISM)
			if(20 to 35)
				if(prob(10))
					to_chat(H,"<span class='warning'>You really don't feel very good.</span>")
				if(prob(5))
					H.adjustToxLoss(0.1)
					H.visible_message("[H] groans.")
					holder.remove_reagent(src.id, 0.3 * FOOD_METABOLISM)
			if(35 to INFINITY)
				if(prob(10))
					to_chat(H,"<span class='warning'>Your stomach grumbles unsettlingly.</span>")
				if(prob(5))
					to_chat(H,"<span class='warning'>Something feels wrong with your body.</span>")
					var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
					if(istype(L))
						L.take_damage(0.1, 1)
					H.adjustToxLoss(0.13)
					holder.remove_reagent(src.id, 0.5 * FOOD_METABOLISM)

/datum/reagent/discount/mannitol
	name = "Mannitol"
	id = MANNITOL
	description = "The only medicine a <B>REAL MAN</B> needs."

/datum/reagent/irradiatedbeans
	name = "Irradiated Beans"
	id = IRRADIATEDBEANS
	description = "You can almost taste the lead sheet behind it!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = 1 * REAGENTS_METABOLISM

/datum/reagent/irradiatedbeans/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(5))
		M.apply_radiation(2, RAD_INTERNAL)

/datum/reagent/toxicwaste
	name = "Toxic Waste"
	id = TOXICWASTE
	description = "A type of sludge."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	density = 5.59
	specheatcap = 2.71

/datum/reagent/toxicwaste/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(20))
		M.adjustToxLoss(1)

/datum/reagent/refriedbeans
	name = "Re-Fried Beans"
	id = REFRIEDBEANS
	description = "Mmm.."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = 1 * REAGENTS_METABOLISM

/datum/reagent/mutatedbeans
	name = "Mutated Beans"
	id = MUTATEDBEANS
	description = "Mutated flavor."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = 1 * REAGENTS_METABOLISM

/datum/reagent/mutatedbeans/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(10))
		M.adjustToxLoss(1)

/datum/reagent/beff
	name = "Beff"
	id = BEFF
	description = "What's beff? Find out!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = 2 * REAGENTS_METABOLISM

/datum/reagent/horsemeat
	name = "Horse Meat"
	id = HORSEMEAT
	description = "Tastes excellent in lasagna."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = 3 * REAGENTS_METABOLISM

/datum/reagent/moonrocks
	name = "Moon Rocks"
	id = MOONROCKS
	description = "We don't know much about it, but we damn well know that it hates the human skeleton."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/moonrocks/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(15))
		M.adjustBruteLoss(2) //Brute damage since it hates the human skeleton

/datum/reagent/offcolorcheese
	name = "Off-Color Cheese"
	id = OFFCOLORCHEESE
	description = "American Cheese."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = REAGENTS_METABOLISM

/datum/reagent/bonemarrow
	name = "Bone Marrow"
	id = BONEMARROW
	description = "Looks like a skeleton got stuck in the production line."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = REAGENTS_METABOLISM

/datum/reagent/greenramen
	name = "Greenish Ramen Noodles"
	id = GREENRAMEN
	description = "That green isn't organic."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = 2 * REAGENTS_METABOLISM

/datum/reagent/greenramen/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(5))
		M.adjustToxLoss(1)

	if(prob(5))
		M.apply_radiation(1, RAD_INTERNAL) //Call it uranium contamination so heavy metal poisoning for the tox and the uranium radiation for the radiation damage

/datum/reagent/glowingramen
	name = "Glowing Ramen Noodles"
	id = GLOWINGRAMEN
	description = "That glow 'aint healthy."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = 2 * REAGENTS_METABOLISM

/datum/reagent/glowingramen/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(10))
		M.apply_radiation(1, RAD_INTERNAL)

/datum/reagent/deepfriedramen
	name = "Deep Fried Ramen Noodles"
	id = DEEPFRIEDRAMEN
	description = "Ramen, deep fried."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	nutriment_factor = 2 * REAGENTS_METABOLISM

/datum/reagent/peptobismol
	name = "Peptobismol"
	id = PEPTOBISMOL
	description = "Jesus juice." //You're welcome, guy in the thread that rolled a 69.
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 22.25
	specheatcap = 10.55

/datum/reagent/peptobismol/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.drowsyness = max(M.drowsyness - 2 * REM, 0)
	if(holder.has_reagent("discount"))
		holder.remove_reagent("discount", 2 * REM)
	var/lucidmod = M.sleeping ? 3 : M.lying + 1
	M.hallucination = max(0, M.hallucination - 5 * REM * lucidmod)
	M.adjustToxLoss(-2 * REM)

/datum/reagent/clottingagent
	name = "Clotting Agent"
	id = CLOTTING_AGENT
	description = "Concentrated blood platelets, capable of stemming bleeding."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#a00000" //rgb: 160, 0, 0
	custom_metabolism = 0.1

/datum/reagent/biofoam	//Does exactly what clotting agent does but our reagent system won't let two chems with the same behavior share an ID.
	name = "Biofoam"
	id = BIOFOAM
	description = "A fast-hardening, biocompatible foam used to stem internal bleeding for a short time."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#D9C0E7" //rgb: 217, 192, 231
	custom_metabolism = 0.1

/datum/reagent/caffeine
	name = "Caffeine"
	id = CAFFEINE
	description = "Caffeine is a common stimulant. It works by making your metabolism faster so it also increases your appetite."
	color = "#E8E8E8" //rgb: 232, 232, 232
	density = 1.23
	specheatcap = 0.89
	custom_metabolism = 0.1

/datum/reagent/caffeine/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	// you just ingested pure caffeine so you're gonna get the BIG shakes
	M.Jitter(10)
	// it also makes you hungry because it speeds up your metabolism
	M.nutrition--

/datum/reagent/tendies
	name = "Tendies"
	id = TENDIES
	description = "Gimme gimme chicken tendies, be they crispy or from Wendys."
	nutriment_factor = REAGENTS_METABOLISM
	color = "#AB6F0E" //rgb: 171, 111, 14
	density = 5
	specheatcap = 1

/datum/reagent/tendies/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += REM * nutriment_factor
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.mind.assigned_role == "Janitor")
			H.heal_organ_damage(1, 1)
			H.nutrition += REM * nutriment_factor //Double nutrition


/////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////DRINKS BELOW, Beer is up there though, along with cola. Cap'n Pete's Cuban Spiced Rum//////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/drink
	name = "Drink"
	id = DRINK
	description = "Uh, some kind of drink."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = REAGENTS_METABOLISM
	color = "#E78108" //rgb: 231, 129, 8
	custom_metabolism = FOOD_METABOLISM
	var/adj_dizzy = 0
	var/adj_drowsy = 0
	var/adj_sleepy = 0
	var/adj_temp = 0

/datum/reagent/drink/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor * REM

	if(adj_dizzy)
		M.dizziness = max(0,M.dizziness + adj_dizzy)
	if(adj_drowsy)
		M.drowsyness = max(0,M.drowsyness + adj_drowsy)
	if(adj_sleepy)
		M.sleeping = max(0,M.sleeping + adj_sleepy)
	if(adj_temp > 0 && M.bodytemperature < 310) //310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(adj_temp < 0 && M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature + (adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/drink/orangejuice
	name = "Orange juice"
	id = ORANGEJUICE
	description = "Both delicious AND rich in Vitamin C. What more do you need?"
	color = "#E78108" //rgb: 231, 129, 8
	nutriment_factor = 5 * REAGENTS_METABOLISM
	glass_desc = "Vitamins! Yay!"

/datum/reagent/drink/orangejuice/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-REM)

/datum/reagent/drink/opokjuice
	name = "Opok Juice"
	id = OPOKJUICE
	description = "A fruit from the mothership pulped into bitter juice, with a very slight undertone of sweetness."
	color = "#FF9191" //rgb: 255, 145, 145
	nutriment_factor = 5 * REAGENTS_METABOLISM
	glass_desc = "Vitamins from the mothership!"

/datum/reagent/drink/opokjuice/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-REM)

/datum/reagent/drink/tomatojuice
	name = "Tomato Juice"
	id = TOMATOJUICE
	description = "Tomatoes made into juice. What a waste of good tomatoes, huh?"
	color = "#731008" //rgb: 115, 16, 8
	nutriment_factor = 5 * REAGENTS_METABOLISM
	glass_desc = "Are you sure this is tomato juice?"
	mug_desc = "Are you sure this is tomato juice?"

/datum/reagent/drink/tomatojuice/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.getFireLoss() && prob(20))
		M.heal_organ_damage(0, 1)

/datum/reagent/drink/limejuice
	name = "Lime Juice"
	id = LIMEJUICE
	description = "The sweet-sour juice of limes."
	color = "#99bb43" //rgb: 153, 187, 67
	alpha = 170
	nutriment_factor = 5 * REAGENTS_METABOLISM
	glass_desc = "A glass of sweet-sour lime juice."

/datum/reagent/drink/limejuice/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1)

/datum/reagent/drink/carrotjuice
	name = "Carrot juice"
	id = CARROTJUICE
	description = "It's like a carrot, but less crunchy."
	color = "#FF8820" //rgb: 255, 136, 32
	nutriment_factor = 5 * REAGENTS_METABOLISM
	data = 1 //Used as a tally
	glass_desc = "It's like a carrot, but less crunchy."

/datum/reagent/drink/carrotjuice/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.eye_blurry = max(M.eye_blurry - 1 , 0)
	M.eye_blind = max(M.eye_blind - 1 , 0)
	switch(data)
		if(21 to INFINITY)
			if(prob(data - 10))
				M.disabilities &= ~NEARSIGHTED
	data++

/datum/reagent/drink/grapejuice
	name = "Grape Juice"
	id = GRAPEJUICE
	description = "Freshly squeezed juice from red grapes. Quite sweet."
	color = "#512284" //rgb: 81, 34, 132
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/ggrapejuice
	name = "Green Grape Juice"
	id = GGRAPEJUICE
	description = "Freshly squeezed juice from green grapes. Smoothly sweet."
	color = "#B79E42" //rgb: 183, 158, 66
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/berryjuice
	name = "Berry Juice"
	id = BERRYJUICE
	description = "A delicious blend of several different kinds of berries."
	color = "#660099" //rgb: 102, 0, 153
	nutriment_factor = 5 * REAGENTS_METABOLISM
	glass_desc = "Berry juice. Or maybe it's jam. Who cares?"

/datum/reagent/drink/poisonberryjuice
	name = "Poison Berry Juice"
	id = POISONBERRYJUICE
	description = "A surprisingly tasty juice blended from various kinds of very deadly and toxic berries."
	color = "#6600CC" //rgb: 102, 0, 204
	glass_desc = "Drinking this may not be a good idea."

/datum/reagent/drink/poisonberryjuice/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustToxLoss(1)

/datum/reagent/drink/watermelonjuice
	name = "Watermelon Juice"
	id = WATERMELONJUICE
	description = "The delicious juice of a watermelon."
	color = "#EF3520" //rgb: 239, 53, 32
	alpha = 240
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/applejuice
	name = "Apple Juice"
	id = APPLEJUICE
	description = "Tastes of New York."
	color = "#FDAD01" //rgb: 253, 173, 1
	alpha = 150
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/lemonjuice
	name = "Lemon Juice"
	id = LEMONJUICE
	description = "This juice is VERY sour."
	color = "#fff690" //rgb: 255, 246, 144
	alpha = 170
	nutriment_factor = 5 * REAGENTS_METABOLISM
	glass_desc = "Sour..."

/datum/reagent/drink/banana
	name = "Banana Juice"
	id = BANANA
	description = "The raw essence of a banana. HONK"
	color = "#FFE777" //rgb: 255, 230, 119
	alpha = 255
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/nothing
	name = "Nothing"
	id = NOTHING
	description = "Absolutely nothing."
	color = "#FFFFFF" //rgb: 255, 255, 255
	nutriment_factor = 0
	glass_name = "nothing"

/datum/reagent/drink/nothing/on_mob_life(var/mob/living/M)

    if(ishuman(M))
        var/mob/living/carbon/human/H = M
        if(H.mind.miming)
            if(M.getOxyLoss() && prob(80))
                M.adjustOxyLoss(-REM)
            if(M.getBruteLoss() && prob(80))
                M.heal_organ_damage(REM, 0)
            if(M.getFireLoss() && prob(80))
                M.heal_organ_damage(0, REM)
            if(M.getToxLoss() && prob(80))
                M.adjustToxLoss(-REM)

/datum/reagent/drink/potato_juice
	name = "Potato Juice"
	id = POTATO
	description = "Juice of the potato. Bleh."
	nutriment_factor = 5 * FOOD_METABOLISM
	color = "#302000" //rgb: 48, 32, 0

/datum/reagent/drink/plumphjuice
	name = "Plump Helmet Juice"
	id = PLUMPHJUICE
	description = "Eeeewwwww."
	nutriment_factor = 5 * FOOD_METABOLISM
	color = "#A28691" //rgb: 162, 134, 145
	glass_name = "glass of plump helmet wine"
	glass_desc = "An absolute staple to get through a day's work."
	glass_icon_state = "plumphwineglass"

/datum/reagent/drink/milk
	name = "Milk"
	id = MILK
	description = "An opaque white liquid produced by the mammary glands of mammals."
	color = "#DFDFDF" //rgb: 223, 223, 223
	alpha = 240
	nutriment_factor = 5 * REAGENTS_METABOLISM
	glass_desc = "White and nutritious goodness!"

/datum/reagent/drink/milk/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.getBruteLoss() && prob(20))
		M.heal_organ_damage(1, 0)
	if(holder.has_reagent("capsaicin"))
		holder.remove_reagent("capsaicin", 10 * REAGENTS_METABOLISM)
	if(holder.has_reagent("zamspicytoxin"))
		holder.remove_reagent("zamspicytoxin", 10 * REAGENTS_METABOLISM)
	if(prob(50))
		M.heal_organ_damage(1, 0)

/datum/reagent/drink/milk/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.1)
	T.adjust_water(0.9)


/datum/reagent/drink/milk/mommimilk
	name = "MoMMI Milk"
	id = MOMMIMILK
	description = "Milk from a MoMMI, but how is it produced?"
	color = "#eaeaea" //rgb(234, 234, 234)
	nutriment_factor = 5 * REAGENTS_METABOLISM
	glass_desc = "Artificially white nutrition!"


/datum/reagent/drink/milk/mommimilk/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.adjustToxLoss(1)
/datum/reagent/drink/milk/mommimilk/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.toxins += 10
	if(T.seed && !T.dead)
		T.health -= 20

/datum/reagent/drink/milk/soymilk
	name = "Soy Milk"
	id = SOYMILK
	description = "An opaque white liquid made from soybeans."
	color = "#e8e8d8" //rgb: 232, 232, 216
	nutriment_factor = 5 * REAGENTS_METABOLISM
	glass_desc = "White and nutritious soy goodness!"

/datum/reagent/drink/milk/cream
	name = "Cream"
	id = CREAM
	description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
	color = "#DFD7AF" //rgb: 223, 215, 175
	nutriment_factor = 5 * REAGENTS_METABOLISM
	density = 2.37
	specheatcap = 1.38
	glass_desc = "Like milk, but thicker."

/datum/reagent/drink/coffee
	name = "Coffee"
	id = COFFEE
	description = "Coffee is a brewed drink prepared from the roasted seeds, commonly called coffee beans, of the coffee plant."
	color = "#482000" //rgb: 72, 32, 0
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2
	adj_temp = 25
	custom_metabolism = 0.1
	var/causes_jitteriness = 1
	glass_desc = "Careful, it's hot!"
	mug_icon_state = "coffee"
	mug_desc = "A warm mug of coffee."

/datum/reagent/drink/coffee/on_mob_life(var/mob/living/M)

	if(..())
		return 1
	if(causes_jitteriness)
		M.Jitter(5)
	if(adj_temp > 0 && holder.has_reagent("frostoil"))
		holder.remove_reagent("frostoil", 10 * REAGENTS_METABOLISM)

/datum/reagent/drink/coffee/icecoffee
	name = "Iced Coffee"
	id = ICECOFFEE
	description = "Coffee and ice. Refreshing and cool."
	color = "#102838" //rgb: 16, 40, 56
	adj_temp = -5
	glass_icon_state = "icedcoffeeglass"
	glass_desc = "For when you need a coffee without the warmth."

/datum/reagent/drink/coffee/soy_latte
	name = "Soy Latte"
	id = SOY_LATTE
	description = "The hipster version of the classic cafe latte."
	color = "#664300" //rgb: 102, 67, 0
	adj_sleepy = 0
	adj_temp = 5
	glass_icon_state = "soy_latte"
	glass_name = "soy latte"
	mug_icon_state = "latte"

/datum/reagent/drink/coffee/soy_latte/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.sleeping = 0

	if(M.getBruteLoss() && prob(20))
		M.heal_organ_damage(1, 0)

/datum/reagent/drink/coffee/cafe_latte
	name = "Latte"
	id = CAFE_LATTE
	description = "A true classic: steamed milk, some espresso, and foamed milk to top it all off."
	color = "#664300" //rgb: 102, 67, 0
	adj_sleepy = 0
	adj_temp = 5
	glass_icon_state = "cafe_latte"
	glass_name = "cafe latte"
	mug_icon_state = "latte"

/datum/reagent/drink/coffee/cafe_latte/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.sleeping = 0

	if(M.getBruteLoss() && prob(20))
		M.heal_organ_damage(1, 0)

/datum/reagent/drink/tea
	name = "Tea"
	id = TEA
	description = "Tasty black tea. It has antioxidants and is good for you!"
	color = "#101000" //rgb: 16, 16, 0
	adj_dizzy = -2
	adj_drowsy = -1
	adj_sleepy = -3
	adj_temp = 20
	mug_icon_state = "tea"
	mug_desc = "A warm mug of tea."

/datum/reagent/drink/tea/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1)

/datum/reagent/drink/tea/icetea
	name = "Iced Tea"
	id = ICETEA
	description = "Like tea, but refreshes rather than relaxes."
	color = "#104038" //rgb: 16, 64, 56
	adj_temp = -5
	density = 1
	specheatcap = 1
	glass_icon_state = "icedteaglass"

/datum/reagent/drink/tea/arnoldpalmer
	name = "Arnold Palmer"
	id = ARNOLDPALMER
	description = "Known as half and half to some. A mix of ice tea and lemonade."
	color = "#104038" //rgb: 16, 64, 56
	adj_temp = -5
	adj_sleepy = -3
	adj_dizzy = -1
	adj_drowsy = -3
	glass_icon_state = "arnoldpalmer"
	glass_name = "\improper Arnold Palmer"

/datum/reagent/drink/kahlua
	name = "Kahlua"
	id = KAHLUA
	description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
	color = "#664300" //rgb: 102, 67, 0
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2
	glass_icon_state = "kahluaglass"
	glass_name = "glass of coffee liqueur"
	glass_desc = "DAMN, THIS STUFF LOOKS ROBUST."

/datum/reagent/drink/kahlua/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.Jitter(5)

/datum/reagent/drink/cold
	id = EXPLICITLY_INVALID_REAGENT_ID
	name = "Cold drink"
	adj_temp = -5

/datum/reagent/drink/cold/tonic
	name = "Tonic Water"
	id = TONIC
	description = "It tastes strange but at least the quinine keeps the space malaria at bay."
	color = "#bafffd" //rgb: 186, 255, 253
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2

/datum/reagent/drink/cold/sodawater
	name = "Soda Water"
	id = SODAWATER
	description = "Effervescent water used in many cocktails and drinks."
	color = "#bafffd" //rgb: 186, 255, 253
	adj_dizzy = -5
	adj_drowsy = -3
	glass_desc = "Soda water. Why not make a scotch and soda?"

/datum/reagent/drink/cold/sodawater/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.1)
	T.adjust_water(1)
	if(T.seed && !T.dead)
		T.health += 0.1

/datum/reagent/drink/cold/ice
	name = "Ice"
	id = ICE
	description = "Frozen water. Your dentist wouldn't like you chewing this."
	reagent_state = REAGENT_STATE_SOLID
	color = "#619494" //rgb: 97, 148, 148
	density = 0.91
	specheatcap = 4.18
	glass_icon_state = "iceglass"
	glass_desc = "Generally, you're supposed to put something else in there too..."

/datum/reagent/drink/cold/space_cola
	name = "Cola"
	id = COLA
	description = "A refreshing beverage."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6e6450" //rgb: 110, 100, 80
	adj_drowsy 	= 	-3
	glass_desc = "A glass of refreshing Space Cola."

/datum/reagent/drink/cold/nuka_cola
	name = "Nuka Cola"
	id = NUKA_COLA
	description = "Cola. Cola never changes."
	color = "#100800" //rgb: 16, 8, 0
	adj_sleepy = -2
	density = 4.17
	specheatcap = 124
	glass_icon_state = "nuka_colaglass"
	glass_name = "\improper Nuka Cola"
	glass_desc = "Don't cry. Don't raise your eye. It's only nuclear wasteland."

/datum/reagent/drink/cold/nuka_cola/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.Jitter(20)
	M.druggy = max(M.druggy, 30)
	M.dizziness += 5
	M.drowsyness = 0

/datum/reagent/drink/cold/geometer
	name = "Geometer"
	id = GEOMETER
	description = "Summon the Beast."
	color = "#ffd700"
	adj_sleepy = -2

/datum/reagent/drink/cold/spacemountainwind
	name = "Space Mountain Wind"
	id = SPACEMOUNTAINWIND
	description = "Blows right through you like a space wind."
	color = "#A4FF8F" //rgb: 164, 255, 143
	adj_drowsy = -7
	adj_sleepy = -1
	glass_icon_state = "Space_mountain_wind_glass"
	glass_desc = "Space Mountain Wind. As you know, there are no mountains in space, only wind."

/datum/reagent/drink/cold/dr_gibb
	name = "Dr. Gibb"
	id = DR_GIBB
	description = "A delicious blend of 42 different flavors."
	color = "#102000" //rgb: 16, 32, 0
	adj_drowsy = -6
	glass_icon_state = "dr_gibb_glass"
	glass_desc = "Dr. Gibb. Not as dangerous as the name might imply."

/datum/reagent/drink/cold/space_up
	name = "Space-Up"
	id = SPACE_UP
	description = "Tastes like a hull breach in your mouth."
	color = "#202800" //rgb: 32, 40, 0
	adj_temp = -8
	glass_icon_state = "space-up_glass"
	glass_desc = "Space-up. It helps keep your cool."

/datum/reagent/drink/cold/lemon_lime
	name = "Lemon Lime"
	description = "A tangy substance made of 0.5% natural citrus!"
	id = LEMON_LIME
	color = "#878F00" //rgb: 135, 40, 0
	adj_temp = -8

/datum/reagent/drink/cold/lemonade
	name = "Lemonade"
	description = "Oh, the nostalgia..."
	id = LEMONADE
	color = "#FFFF00" //rgb: 255, 255, 0
	glass_icon_state = "lemonadeglass"

/datum/reagent/drink/cold/kiraspecial
	name = "Kira Special"
	description = "Long live the guy who everyone had mistaken for a girl. Baka!"
	id = KIRASPECIAL
	color = "#CCCC99" //rgb: 204, 204, 153
	glass_icon_state = "kiraspecial"
	glass_name = "\improper Kira Special"

/datum/reagent/drink/cold/brownstar
	name = "Brown Star"
	description = "Its not what it sounds like..."
	id = BROWNSTAR
	color = "#9F3400" //rgb: 159, 052, 000
	adj_temp = -2
	glass_icon_state = "brownstar"
	glass_name = "\improper Brown Star"

/datum/reagent/drink/cold/milkshake
	name = "Milkshake"
	description = "Glorious brainfreezing mixture."
	id = MILKSHAKE
	color = "#AEE5E4" //rgb" 174, 229, 228
	adj_temp = -9
	custom_metabolism = FOOD_METABOLISM
	data = 1 //Used as a tally
	glass_icon_state = "milkshake"
	glass_desc = "Brings all the boys to the yard."

/datum/reagent/drink/cold/milkshake/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	var/mob/living/carbon/human/H
	if(ishuman(M))
		H = M
	switch(data)
		if(1 to 15)
			M.bodytemperature -= 0.1 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("capsaicin"))
				holder.remove_reagent("capsaicin", 5)
			if(isslime(M))
				M.bodytemperature -= rand(5,20)
			if(isslimeperson(H))
				M.bodytemperature -= rand(5,20)
		if(15 to 25)
			M.bodytemperature -= 0.2 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature -= rand(10,20)
			if(isslimeperson(H))
				M.bodytemperature -= rand(10,20)
		if(25 to INFINITY)
			M.bodytemperature -= 0.3 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(prob(1))
				M.emote("shiver")
			if(isslime(M))
				M.bodytemperature -= rand(15,20)
			if(isslimeperson(H))
				M.bodytemperature -= rand(15,20)
	data++

/datum/reagent/drink/cold/rewriter
	name = "Rewriter"
	description = "The librarian's special."
	id = REWRITER
	color = "#485000" //rgb:72, 080, 0
	glass_icon_state = "rewriter"
	glass_name = "\improper Rewriter"
	glass_desc = "This will cure your dyslexia and cause your arrhythmia."

/datum/reagent/drink/cold/rewriter/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.Jitter(5)

/datum/reagent/drink/cold/diy_soda
	name = "Dr. Pecker's DIY Soda"
	description = "Tastes like a science fair experiment."
	id = DIY_SODA
	color = "#7566FF" //rgb: 117, 102, 255
	adj_temp = -2
	adj_drowsy = -6

/datum/reagent/drink/cold/diy_soda/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.Jitter(5)

/datum/reagent/hippies_delight
	name = "Hippie's Delight"
	id = HIPPIESDELIGHT
	description = "You just don't get it, maaaan."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	data = 1 //Used as a tally
	glass_icon_state = "hippiesdelightglass"
	glass_name = "\improper Hippie's Delight"
	glass_desc = "A drink popular in the 1960s."

/datum/reagent/hippies_delight/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.druggy = max(M.druggy, 50)
	switch(data)
		if(1 to 5)
			if(!M.stuttering)
				M.stuttering = 1
			M.Dizzy(10)
			if(prob(10))
				M.emote(pick("twitch", "giggle"))
		if(5 to 10)
			if(!M.stuttering)
				M.stuttering = 1
			M.Jitter(20)
			M.Dizzy(20)
			M.druggy = max(M.druggy, 45)
			if(prob(20))
				M.emote(pick("twitch", "giggle"))
		if(10 to INFINITY)
			if(!M.stuttering)
				M.stuttering = 1
			M.Jitter(40)
			M.Dizzy(40)
			M.druggy = max(M.druggy, 60)
			if(prob(30))
				M.emote(pick("twitch", "giggle"))
	data++

//ALCOHOL WOO
/datum/reagent/ethanol
	name = "Ethanol" //Parent class for all alcoholic reagents.
	id = ETHANOL
	description = "A well-known alcohol with a variety of applications."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 0 //So alcohol can fill you up! If they want to.
	color = "#404030" //RGB: 64, 64, 48
	custom_metabolism = FOOD_METABOLISM
	density = 0.79
	specheatcap = 2.46
	var/dizzy_adj = 3
	var/slurr_adj = 3
	var/confused_adj = 2
	var/slur_start = 65 //Amount absorbed after which mob starts slurring
	var/confused_start = 130 //Amount absorbed after which mob starts confusing directions
	var/blur_start = 260 //Amount absorbed after which mob starts getting blurred vision
	var/pass_out = 450 //Amount absorbed after which mob starts passing out
	var/common_data = 1 //Needed to add all ethanol subtype's datas

/datum/reagent/ethanol/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	//Sobering multiplier
	//Sober block makes it more difficult to get drunk
	var/sober_str =! (M_SOBER in M.mutations) ? 1 : 2

	M.nutrition += REM*nutriment_factor
	data++

	data /= sober_str

	//Make all the ethanol-based beverages work together
	common_data = 0

	if(holder.reagent_list) //Sanity
		for(var/datum/reagent/ethanol/A in holder.reagent_list)
			if(isnum(A.data))
				common_data += A.data

	M.dizziness += dizzy_adj
	if(common_data >= slur_start && data < pass_out)
		if(!M.slurring)
			M.slurring = 1
		M.slurring += slurr_adj/sober_str
	if(common_data >= confused_start && prob(33))
		if(!M.confused)
			M.confused = 1
		M.confused = max(M.confused+(confused_adj/sober_str), 0)
	if(common_data >= blur_start)
		M.eye_blurry = max(M.eye_blurry, 10/sober_str)
		M.drowsyness  = max(M.drowsyness, 0)
	if(common_data >= pass_out)
		M.paralysis = max(M.paralysis, 20/sober_str)
		M.drowsyness  = max(M.drowsyness, 30/sober_str)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
			if(!L)
				H.adjustToxLoss(5)
			else if(istype(L))
				L.take_damage(0.05, 0.5)
			H.adjustToxLoss(0.5)

/datum/reagent/ethanol/reaction_obj(var/obj/O, var/volume)

	if(..())
		return 1

	if(istype(O, /obj/item/weapon/paper))
		var/obj/item/weapon/paper/paperaffected = O
		if(paperaffected.info || paperaffected.stamps)
			paperaffected.clearpaper()
			O.visible_message("<span class='warning'>The solution melts away \the [O]'s ink.</span>")

	if(istype(O, /obj/item/weapon/book))
		if(volume >= 5)
			var/obj/item/weapon/book/affectedbook = O
			if(affectedbook.dat)
				affectedbook.dat = null
				O.visible_message("<span class='warning'>The solution melts away \the [O]'s ink.</span>")

//It's really much more stronger than other drinks
/datum/reagent/ethanol/beer
	name = "Beer"
	id = BEER
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	nutriment_factor = 2 * FOOD_METABOLISM
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "beerglass"
	glass_desc = "A cold pint of pale lager."

/datum/reagent/ethanol/beer/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.jitteriness = max(M.jitteriness - 3, 0)

/datum/reagent/ethanol/beer/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.adjust_nutrient(0.25)
	T.adjust_water(0.7)

/datum/reagent/ethanol/whiskey
	name = "Whiskey"
	id = WHISKEY
	description = "A superb and well-aged single-malt whiskey. Damn."
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 4
	pass_out = 225
	glass_icon_state = "whiskeyglass"
	glass_desc = "The silky, smokey whiskey goodness inside the glass makes the drink look very classy."

/datum/reagent/ethanol/specialwhiskey
	name = "Special Blend Whiskey"
	id = SPECIALWHISKEY
	description = "Just when you thought regular station whiskey was good..."
	color = "#664300" //rgb: 102, 67, 0
	slur_start = 30
	pass_out = 225

/datum/reagent/ethanol/gin
	name = "Gin"
	id = GIN
	description = "It's gin. In space. I say, good sir."
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 3
	pass_out = 260
	glass_icon_state = "ginvodkaglass"
	glass_desc = "A crystal clear glass of Griffeater gin."

/datum/reagent/ethanol/absinthe
	name = "Absinthe"
	id = ABSINTHE
	description = "Watch out that the Green Fairy doesn't get you!"
	color = "#33EE00" //rgb: lots, ??, ??
	dizzy_adj = 5
	slur_start = 25
	confused_start = 100
	pass_out = 175
	glass_icon_state = "absintheglass"
	glass_desc = "One sip of this and you just know you're gonna have a good time."

//Copy paste from LSD... shoot me
/datum/reagent/ethanol/absinthe/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	data++
	M.hallucination += 5

/datum/reagent/ethanol/bwine
	name = "Berry Wine"
	id = BWINE
	description = "Sweet berry wine!"
	color = "#C760A2" //rgb: 199, 96, 162
	dizzy_adj = 2
	slur_start = 65
	confused_start = 145
	glass_icon_state = "bwineglass"
	glass_desc = "A particular favorite of doctors."

/datum/reagent/ethanol/wwine
	name = "White Wine"
	id = WWINE
	description = "A premium alcoholic beverage made from fermented green grape juice."
	color = "#C6C693" //rgb: 198, 198, 147
	dizzy_adj = 2
	slur_start = 65
	confused_start = 145
	glass_icon_state = "wwineglass"
	glass_desc = "A drink enjoyed by intellectuals and middle-aged female alcoholics alike."

/datum/reagent/ethanol/plumphwine
	name = "Plump Helmet Wine"
	id = PLUMPHWINE
	description = "A very peculiar wine made from fermented plump helmet mushrooms. Popular among asteroid dwellers."
	color = "#800080" //rgb: 128, 0, 128
	dizzy_adj = 3 //dorf wine is a bit stronger than regular stuff
	slur_start = 60
	confused_start = 135

/datum/reagent/ethanol/pwine
	name = "Poison Wine"
	id = PWINE
	description = "Is this even wine? Toxic, hallucinogenic, foul-tasting... Why would you drink this?"
	color = "#000000" //rgb: 0, 0, 0
	dizzy_adj = 1
	slur_start = 1
	confused_start = 1
	glass_name = "glass of Vintage 2018 Special Reserve"
	glass_icon_state = "pwineglass"

/datum/reagent/ethanol/pwine/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.druggy = max(M.druggy, 50)
	switch(data)
		if(1 to 25)
			if(!M.stuttering)
				M.stuttering = 1
			M.Dizzy(1)
			M.hallucination = max(M.hallucination, 3)
			if(prob(1))
				M.emote(pick("twitch", "giggle"))
		if(25 to 75)
			if(!M.stuttering)
				M.stuttering = 1
			M.hallucination = max(M.hallucination, 10)
			M.Jitter(2)
			M.Dizzy(2)
			M.druggy = max(M.druggy, 45)
			if(prob(5))
				M.emote(pick("twitch", "giggle"))
		if(75 to 150)
			if(!M.stuttering)
				M.stuttering = 1
			M.hallucination = max(M.hallucination, 60)
			M.Jitter(4)
			M.Dizzy(4)
			M.druggy = max(M.druggy, 60)
			if(prob(10))
				M.emote(pick("twitch", "giggle"))
			if(prob(30))
				M.adjustToxLoss(2)
		if(150 to 300)
			if(!M.stuttering)
				M.stuttering = 1
			M.hallucination = max(M.hallucination, 60)
			M.Jitter(4)
			M.Dizzy(4)
			M.druggy = max(M.druggy, 60)
			if(prob(10))
				M.emote(pick("twitch", "giggle"))
			if(prob(30))
				M.adjustToxLoss(2)
			if(prob(5))
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					var/datum/organ/internal/heart/L = H.internal_organs_by_name["heart"]
					if(L && istype(L))
						L.take_damage(5, 0)
		if(300 to INFINITY)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/datum/organ/internal/heart/L = H.internal_organs_by_name["heart"]
				if(L && istype(L))
					L.take_damage(100, 0)
	data++

/datum/reagent/ethanol/karmotrine
	name = "Karmotrine"
	id = KARMOTRINE
	description = "A thick, light blue liquid extracted from strange plants."
	color = "#66ffff" //rgb(102, 255, 255)
	blur_start = 40 //Blur very early

/datum/reagent/ethanol/smokyroom
	name = "Smoky Room"
	id = SMOKYROOM
	description = "It was the kind of cool, black night that clung to you like something real... a black, tangible fabric of smoke, deceit, and murder. I had finished working my way through the fat cigars for the day - or at least told myself that to feel the sense of accomplishment for another night wasted on little more than chasing cheating dames and abusive husbands. It was enough to drive a man to drink... and it did. I sauntered into the cantina and wordlessly nodded to the barman. He knew my poison. I was a regular, after all. By the time the night was over, there would be another empty bottle and a case no closer to being cracked. Then I saw her, like a mirage across a desert, or a striken starlet on stage across a smoky room."
	color = "#664300"
	glass_icon_state = "smokyroom"
	glass_name = "\improper Smoky Room"


/datum/reagent/ethanol/smokyroom/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(prob(4)) //Small chance per tick to some noir stuff and gain NOIRBLOCK if we don't have it.
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!(M_NOIR in H.mutations))
				H.mutations += M_NOIR
				H.dna.SetSEState(NOIRBLOCK,1)
				genemutcheck(H, NOIRBLOCK, null, MUTCHK_FORCED)

		M.say(pick("The station corridors were heartless and cold, like the fickle 'love' of some hysterical dame.",
			"The lights, the smoke, the grime... the station itself seemed alive that day. Was it the pulse that made me think so? Or just all the blood?",
			"I caressed my .44 magnum. Ever since Jimmy bit it against the Two Bit Gang, the gun and its six rounds were the only partner I could trust. Never a single jam to trap me in another.",
			"The whole reason I took the case to begin with was trouble, in the shape of a pinup blonde with shanks that'd make you dizzy. Wouldn't give her name, said she was related to the captain. I doubt she was even on the manifest.",
			"According to the boys in the lab, the perp took a sander to the tooth profiles, but did a sloppy job. Lab report came in early this morning. Guess my vacation is on pause.",
			"The blacktop was baking that day, and the broads working 19th and Main were wearing even less than usual.",
			"The young dame was the pride and joy of the station. Little did she know that looks can breed envy... or worse.",
			"The new case reeked of the same bad blood as that now half-forgotten case of the turncoat chef. A recipe for murder.",
			"I dragged myself out of my drink-addled torpor and called to the shadowy figure at my door - come in - because if I didn't take a new case I'd be through my bottle by noon.",
			"Nursing my scotch, I turned my gaze upward and spotted trouble in the form of a bruiser with brass knuckles across the smoke-filled nightclub's cabaret.",
			"I didn't even know who she was. Just stumbled across a girl and four toughs. Took her home and the mayor named me a hero.",
			"She was a flapper and a swinger, but she was also in some hot water. Told me she'd make it worth my while if I could get her out of it. I told her that I wanted payment in cold hard simoleons.",
			"What he did just didn't compare. He killed an innocent person. What drives a man to kill in cold blood? I didn't want to hang around and find out.",
			"I breathed in the smoke of the underground speakeasy like a fish breathes water. The brass at the precinct couldn't understand: I was in my element.",
			"I put enough holes in the man to drop a goliath, but he kept coming. Some kind of blood-fueled hatred. The adrenaline of a dying man can snap bones in one last moment of spite. I can still see the anger in those dying eyes.",
			"Charlie's SPS sang its monotone dirge somewhere deep in the tunnels. I'd told him to watch his back, but the blood of rookies flows hot and fast. I took a long swig of scotch and lit a cigarette. Another good man lost.",
			"The scene was a mess. Three bodies, or what was left of them, the floor covered in blood and strange markings. I thought the shift couldn't possibly get any worse. A flash of blood red on pitch black in the corner of my eye proved me wrong.",
			"The martini was as dry as the barkeep's humor. How do I always find myself in this run-down hovel, I wondered as I lost myself in the drink.",
			"The coroner looked up from his papers and nodded at me. The mutilated body was none other than my damsel in distress. I cursed under my breath. Who would pay me now?"))

/datum/reagent/ethanol/rags_to_riches
	name = "Rags to Riches"
	id = RAGSTORICHES
	description = "The Spaceman Dream, incarnated as a cocktail."
	color = "#664300"
	dupeable = FALSE
	glass_icon_state = "ragstoriches"
	glass_name = "\improper Rags to Riches"

/datum/reagent/ethanol/rags_to_riches/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(!M.loc || prob(70))
		return
	playsound(M, pick('sound/items/polaroid1.ogg','sound/items/polaroid2.ogg'), 50, 1)
	dispense_cash(rand(5,15),get_turf(M))

/datum/reagent/ethanol/bad_touch
	name = "Bad Touch"
	id = BAD_TOUCH
	description = "On the scale of bad touches, somewhere between 'fondled by clown' and 'brushed by supermatter shard'."
	color = "#664300"
	glass_icon_state = "bad_touch"
	glass_name = "\improper Bad Touch"


/datum/reagent/ethanol/bad_touch/on_mob_life(var/mob/living/M) //Hallucinate and take hallucination damage.
	if(..())
		return 1
	M.hallucination = max(M.hallucination, 10)
	M.halloss += 5

/datum/reagent/ethanol/electric_sheep
	name = "Electric Sheep"
	id = ELECTRIC_SHEEP
	description = "Silicons dream of this."
	color = "#664300"
	custom_metabolism = 1
	glass_icon_state = "electric_sheep"
	glass_name = "\improper Electric Sheep"

/datum/reagent/ethanol/electric_sheep/on_mob_life(var/mob/living/M) //If it's human, shoot sparks every tick! If MoMMI, cause alcohol effects.
	if(..())
		return 1
	if(ishuman(M))
		spark(M, 5, FALSE)

/datum/reagent/ethanol/electric_sheep/reaction_mob(var/mob/living/M)
	if(isrobot(M))
		M.Jitter(20)
		M.Dizzy(20)
		M.druggy = max(M.druggy, 60)

/datum/reagent/ethanol/suicide
	name = "Suicide"
	id = SUICIDE
	description = "It's only tolerable because of the added alcohol."
	color = "#664300"
	custom_metabolism = 2
	glass_icon_state = "suicide"
	glass_name = "\improper Suicide"

/datum/reagent/ethanol/suicide/on_mob_life(var/mob/living/M)  //Instant vomit. Every tick.
	if(..())
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.vomit(0,1)

/datum/reagent/ethanol/metabuddy
	name = "Metabuddy"
	id = METABUDDY
	description = "Ban when?"
	color = "#664300"
	var/global/list/datum/mind/metaclub = list()
	glass_icon_state = "metabuddy"
	glass_name = "\improper Metabuddy"
	glass_desc = "The glass is etched with the name of a very deserving spaceman. There's a special note etched in the bottom..."

/datum/reagent/ethanol/metabuddy/on_mob_life(var/mob/living/L)
	if(..())
		return 1
	var/datum/mind/LM = L.mind
	if(!metaclub.Find(LM) && LM)
		metaclub += LM
		var/datum/mind/new_buddy = LM
		for(var/datum/mind/M in metaclub) //Update metaclub icons
			if(M.current.client && new_buddy.current && new_buddy.current.client)
				var/imageloc = new_buddy.current
				var/imagelocB = M.current
				if(istype(M.current.loc,/obj/mecha))
					imageloc = M.current.loc
					imagelocB = M.current.loc
				var/image/I = image('icons/mob/HUD.dmi', loc = imageloc, icon_state = "metaclub")
				I.plane = ANTAG_HUD_PLANE
				M.current.client.images += I
				var/image/J = image('icons/mob/HUD.dmi', loc = imagelocB, icon_state = "metaclub")
				J.plane = ANTAG_HUD_PLANE
				new_buddy.current.client.images += J

/datum/reagent/ethanol/waifu
	name = "Waifu"
	id = WAIFU
	description = "Don't drink more than one waifu if you value your laifu."
	color = "#D0206F"
	glass_icon_state = "waifu"
	glass_name = "\improper Waifu"

/datum/reagent/ethanol/waifu/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(M.gender == MALE)
		M.setGender(FEMALE)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!M.is_wearing_item(/obj/item/clothing/under/schoolgirl))
			var/turf/T = get_turf(H)
			T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/effects/rejuvinate.ogg',anim_plane = MOB_PLANE)
			H.visible_message("<span class='warning'>[H] dons her magical girl outfit in a burst of light!</span>")
			var/obj/item/clothing/under/schoolgirl/S = new /obj/item/clothing/under/schoolgirl(get_turf(H))
			if(H.w_uniform)
				H.u_equip(H.w_uniform, 1)
			H.equip_to_slot(S, slot_w_uniform)
			holder.remove_reagent(WAIFU,4) //Generating clothes costs extra reagent
	M.regenerate_icons()

/datum/reagent/ethanol/husbando
	name = "Husbando"
	id = HUSBANDO
	description = "You talkin' shit about my husbando?"
	color = "#2043D0"
	glass_icon_state = "husbando"
	glass_name = "\improper Husbando"

/datum/reagent/ethanol/husbando/on_mob_life(var/mob/living/M) //it's copypasted from waifu
	if(..())
		return 1
	if(M.gender == FEMALE)
		M.setGender(MALE)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!M.is_wearing_item(/obj/item/clothing/under/callum))
			var/turf/T = get_turf(H)
			T.turf_animation('icons/effects/96x96.dmi',"manexplode",-32,0,MOB_LAYER+1,'sound/items/poster_ripped.ogg',anim_plane = MOB_PLANE)
			H.visible_message("<span class='warning'>[H] reveals his true outfit in a vortex of ripped clothes!</span>")
			var/obj/item/clothing/under/callum/C = new /obj/item/clothing/under/callum(get_turf(H))
			if(H.w_uniform)
				H.u_equip(H.w_uniform, 1)
			H.equip_to_slot(C, slot_w_uniform)
			holder.remove_reagent(HUSBANDO,4)
	M.regenerate_icons()

/datum/reagent/ethanol/scientists_serendipity
	name = "Scientist's Serendipity"
	id = SCIENTISTS_SERENDIPITY
	description = "Go ahead and blow the research budget on drinking this." //Can deconstruct a glass with this for loadsoftech
	color = "#664300"
	custom_metabolism = 0.01
	dupeable = FALSE

/datum/reagent/ethanol/scientists_serendipity/handle_special_behavior(var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/D)
	if(volume < 10)
		glass_icon_state = "scientists_surprise"
		glass_name = "\improper Scientist's Surprise"
		glass_desc = "There is as yet insufficient data for a meaningful answer."
		D.origin_tech = ""

	else if(volume < 50)
		glass_icon_state = "scientists_serendipity"
		glass_name = "\improper Scientist's Serendipity"
		glass_desc = "Knock back a cold glass of R&D."
		D.origin_tech = "materials=7;engineering=3;plasmatech=2;powerstorage=4;bluespace=6;combat=3;magnets=6;programming=3"

	else
		glass_icon_state = "scientists_serendipity"
		glass_name = "\improper Scientist's Sapience"
		glass_desc = "Why research what has already been catalogued?"
		D.origin_tech = "materials=10;engineering=5;plasmatech=4;powerstorage=5;bluespace=10;biotech=5;combat=6;magnets=6;programming=5;illegal=1;nanotrasen=1;syndicate=2" //Maxes everything but Illegal and Anomaly

/datum/reagent/ethanol/beepskyclassic
	name = "Beepsky Classic"
	id = BEEPSKY_CLASSIC
	description = "Some believe that the more modern Beepsky Smash was introduced to make this drink more popular."
	color = "#664300" //rgb: 102, 67, 0
	custom_metabolism = 2 //Ten times the normal rate.
	glass_icon_state = "beepsky_classic"
	name = "\improper Beepsky Classic"


/datum/reagent/ethanol/beepskyclassic/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.job in list("Security Officer", "Head of Security", "Detective", "Warden"))
			playsound(H, 'sound/voice/halt.ogg', 100, 1, 0)
		else
			H.Knockdown(10)
			H.Stun(10)
			playsound(H, 'sound/weapons/Egloves.ogg', 100, 1, -1)

/datum/reagent/ethanol/spiders
	name = "Spiders"
	id = SPIDERS
	description = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA."
	color = "#666666" //rgb(102, 102, 102)
	custom_metabolism = 0.01 //Spiders really 'hang around'
	glass_icon_state = "spiders"
	name = "\improper This glass is full of spiders"
	glass_desc = "Seriously, dude, don't touch it."

/datum/reagent/ethanol/spiders/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.take_organ_damage(REM, 0) //Drinking a glass of live spiders is bad for you.
	if(holder.get_reagent_amount(SPIDERS)>=4) //The main reason we need to have a minimum cost rather than just high custom metabolism is so that someone can't give themselves an IV of spiders for "fun"
		new /mob/living/simple_animal/hostile/giant_spider/spiderling(get_turf(M))
		holder.remove_reagent(SPIDERS,4)
		M.emote("scream", , , 1)
		M.visible_message("<span class='warning'>[M] recoils as a spider emerges from \his mouth!</span>")

/datum/reagent/ethanol/weedeater
	name = "Weed Eater"
	id = WEED_EATER
	description = "The vegetarian equivalant of a snake eater."
	color = "#009933" //rgb(0, 153, 51)
	glass_icon_state = "weed_eater"
	glass_name = "\improper Weed Eater"

/datum/reagent/ethanol/weedeater/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	var/spell = /spell/targeted/genetic/eat_weed
	if(!(locate(spell) in M.spell_list))
		to_chat(M, "<span class='notice'>You feel hungry like the diona.</span>")
		M.add_spell(spell)

/datum/reagent/ethanol/magicadeluxe
	name = "Magica Deluxe"
	id = MAGICADELUXE
	description = "Makes you feel enchanted until the aftertaste hits you."
	color = "#009933" //rgb(0, 153, 51)
	glass_icon_state = "magicadeluxe"
	glass_name = "magica deluxe"

/datum/reagent/ethanol/magicadeluxe/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(M.spell_list.len)
		return //one per customer, magicians need not apply
	var/list/fake_spells = list()
	var/list/choices = getAllWizSpells()
	for(var/i=5; i > 0; i--)
		var/spell/passive/fakespell = new /spell/passive
		var/name_modifier = pick("Efficient ","Efficient ","Free ", "Instant ")
		fakespell.spell_flags = STATALLOWED
		var/spell/readyup = pick_n_take(choices)
		var/spell/fromwhichwetake = new readyup
		fakespell.name = fromwhichwetake.name
		fakespell.desc = fromwhichwetake.desc
		fakespell.hud_state = fromwhichwetake.hud_state
		fakespell.invocation = "MAH'JIK"
		fakespell.invocation_type = SpI_SHOUT
		fakespell.charge_type = Sp_CHARGES
		fakespell.charge_counter = 0
		fakespell.charge_max = 1
		if(prob(20))
			fakespell.name = name_modifier + fakespell.name
		fake_spells += fakespell
	if(!M.spell_list.len) //just to be sure
		to_chat(M, "<span class='notice'>You feel magical!</span>")
		playsound(M,'sound/effects/summon_guns.ogg', 50, 1)
		for (var/spell/majik in fake_spells)
			M.add_spell(majik)

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/spell/thisisdumb = new /spell/targeted/equip_item/robesummon
			H.add_spell(thisisdumb)
			thisisdumb.charge_type = Sp_CHARGES
			thisisdumb.charge_counter = 1
			thisisdumb.charge_max = 1
			H.cast_spell(thisisdumb,list(H))
		holder.remove_reagent(MAGICADELUXE,5)

/datum/reagent/ethanol/drink/gravsingulo
	name = "Gravitational Singulo"
	id = GRAVSINGULO
	description = "A true gravitational anomaly."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113
	custom_metabolism = 1 // A bit faster to prevent easy singuloosing
	dizzy_adj = 15
	slurr_adj = 15
	data = 1 //Used as a tally
	glass_icon_state = "gravsingulo"
	glass_name = "\improper Gravitational Singulo"
	glass_desc = "The destructive, murderous Lord Singuloth, patron saint of Bargineering, now in grape flavor!"

/datum/reagent/ethanol/drink/gravsingulo/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	switch(data)
		if(0 to 65)
			if(prob(5))
				to_chat(M,"<span class='notice'>You feel [pick("dense", "heavy", "attractive")].</span>")
		if(65 to 130)
			if(prob(5))
				to_chat(M,"<span class='notice'>You feel [pick("like the world revolves around you", "like your own centre of gravity", "others drawn to you")].</span>")
		if(130 to 250)
			if(prob(5))
				to_chat(M,"<span class='warning'>You feel [pick("like your insides are being pulled in", "torn apart", "sucked in")]!</span>")
			M.adjustBruteLoss(1)
		if(250 to INFINITY)
			M.visible_message("<span class='alert'>[M]'s entire mass collapses inwards, leaving a singularity behind!</span>","<span class='alert'>Your entire mass collapses inwards, leaving a singularity behind!</span>")
			var/turf/T = get_turf(M)
			//Can only make a singulo if active mind, otherwise a singulo toy
			if(M.mind)
				var/obj/machinery/singularity/S = new (T)
				S.consume(M)
			else
				new /obj/item/toy/spinningtoy(T)
				M.gib()
	//Will pull items in a range based on time in system
	for(var/atom/X in orange((data+30)/50, M))
		if(X.type == /atom/movable/light)//since there's one on every turf
			continue
		X.singularity_pull(M, data/50, data/50)
	data++

/datum/reagent/drink/tea/gravsingularitea
	name = "Gravitational Singularitea"
	id = GRAVSINGULARITEA
	description = "Spirally!"
	custom_metabolism = 1 // A bit faster to prevent easy singuloosing
	data = 1 //Used as a tally
	mug_icon_state = "gravsingularitea"
	mug_name = "\improper Gravitational Singularitea"
	mug_desc = "The destructive, murderous Lord Singuloth, patron saint of Bargineering, now in herbal flavour!"

/datum/reagent/drink/tea/gravsingularitea/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	switch(data)
		if(0 to 65)
			if(prob(5))
				to_chat(M,"<span class='notice'>You feel [pick("dense", "heavy", "attractive")].</span>")
		if(65 to 130)
			if(prob(5))
				to_chat(M,"<span class='notice'>You feel [pick("like the world revolves around you", "like your own centre of gravity", "others drawn to you")].</span>")
		if(130 to 250)
			if(prob(5))
				to_chat(M,"<span class='warning'>You feel [pick("like your insides are being pulled in", "torn apart", "sucked in")]!</span>")
			M.adjustBruteLoss(1)
		if(250 to INFINITY)
			M.visible_message("<span class='alert'>[M]'s entire mass collapses inwards, leaving a singularity behind!</span>","<span class='alert'>Your entire mass collapses inwards, leaving a singularity behind!</span>")
			var/turf/T = get_turf(M)
			//Can only make a singulo if active mind, otherwise a singulo toy
			if(M.mind)
				var/obj/machinery/singularity/S = new (T)
				S.consume(M)
			else
				new /obj/item/toy/spinningtoy(T)
				M.gib()
	//Will pull items in a range based on time in system
	for(var/atom/X in orange((data+30)/50, M))
		if(X.type == /atom/movable/light)//since there's one on every turf
			continue
		X.singularity_pull(M, data/50, data/50)
	data++

/datum/reagent/ethanol/drink
	id = EXPLICITLY_INVALID_REAGENT_ID
	pass_out = 250

/datum/reagent/ethanol/drink/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.dizziness += 5

/datum/reagent/ethanol/drink/rum
	name = "Rum"
	id = RUM
	description = "Popular with the sailors. Not very popular with anyone else."
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "rumglass"
	glass_desc = "Now you want to pray for a pirate suit, don't you?"

/datum/reagent/ethanol/drink/vodka
	name = "Vodka"
	id = VODKA
	description = "The drink and fuel of choice of Russians galaxywide."
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "ginvodkaglass"
	glass_desc = "The glass contain wodka. Xynta."

/datum/reagent/ethanol/drink/sake
	name = "Sake"
	id = SAKE
	description = "Anime's favorite drink."
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "sakeglass"
	glass_desc = "A glass of sake."

/datum/reagent/ethanol/drink/sake/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.mind.GetRole(NINJA))
			M.nutrition += nutriment_factor
			if(M.getOxyLoss() && prob(50))
				M.adjustOxyLoss(-2)
			if(M.getBruteLoss() && prob(60))
				M.heal_organ_damage(2, 0)
			if(M.getFireLoss() && prob(50))
				M.heal_organ_damage(0, 2)
			if(M.getToxLoss() && prob(50))
				M.adjustToxLoss(-2)
			if(M.dizziness != 0)
				M.dizziness = max(0, M.dizziness - 15)
			if(M.confused != 0)
				M.remove_confused(5)

/datum/reagent/ethanol/drink/glasgow
	name = "Glasgow Deadrum"
	id = GLASGOW
	description = "Makes you feel like you had one hell of a party."
	color = "#662D1D" //rgb: 101, 44, 29
	slur_start = 1
	confused_start = 1

/datum/reagent/ethanol/drink/tequila
	name = "Tequila"
	id = TEQUILA
	description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty, hombre?"
	color = "#A8B0B7" //rgb: 168, 176, 183
	glass_icon_state = "tequilaglass"
	glass_desc = "Now all that's missing is the weird colored shades!"

/datum/reagent/ethanol/drink/vermouth
	name = "Vermouth"
	id = VERMOUTH
	description = "You suddenly feel a craving for a martini..."
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "vermouthglass"
	glass_desc = "You wonder why you're even drinking this straight."

/datum/reagent/ethanol/drink/wine
	name = "Wine"
	id = WINE
	description = "A premium alcoholic beverage made from fermented grape juice."
	color = "#7E4043" //rgb: 126, 64, 67
	dizzy_adj = 2
	slur_start = 65
	confused_start = 145
	glass_icon_state = "wineglass"
	glass_desc = "A drink enjoyed by intellectuals and middle-aged female alcoholics alike."

/datum/reagent/ethanol/drink/cognac
	name = "Cognac"
	id = COGNAC
	description = "A sweet and strongly alcoholic drink, twice distilled and left to mature for several years. Classy as fornication."
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 4
	confused_start = 115
	glass_icon_state = "cognacglass"
	glass_desc = "You feel aristocratic just holding this."

/datum/reagent/ethanol/drink/hooch
	name = "Hooch"
	id = HOOCH
	description = "A suspiciously viscous off-brown liquid that reeks of fuel. Do you really want to drink that?"
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 6
	slurr_adj = 5
	slur_start = 35
	confused_start = 90
	pass_out = 250
	glass_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."

/datum/reagent/ethanol/drink/triplesec
	name = "Triple Sec"
	id = TRIPLESEC
	description = "Clear, dry, tastes like oranges. A necessity in any bartender's shelves."
	color = "#D1D1D1" //rgb: 209, 209, 209
	glass_icon_state = "triplesecglass"
	glass_desc = "Triple Sec, a clear orange liquor with a syrupy texture. Maybe mix it with something, you weirdo."

/datum/reagent/ethanol/drink/schnapps
	name = "Schnapps"
	id = SCHNAPPS
	description = "Tastes like all the fruits in the galaxy."
	color = "#FFAC38" //rgb: 255, 172, 56
	glass_icon_state = "schnappsglass"
	glass_desc = "A glass of indescernibly fruity schnapps."

/datum/reagent/ethanol/drink/bitters
	name = "Bitters"
	id = BITTERS
	description = "Dark, bitter alcohol. Who in their right mind drinks this straight?"
	color = "#361412" //rgb: 54, 20, 18
	glass_icon_state = "bittersglass"
	glass_desc = "A glass of dark and, well, bitter, bitters."

/datum/reagent/ethanol/drink/champagne
	name = "Champagne"
	id = CHAMPAGNE
	description = "Often found sprayed all over sports victors or at New Years parties."
	color = "#FAD6A5" //rgb: 250, 214, 165
	glass_icon_state = "champagneglass"
	glass_desc = "A fancy, bubbly glass of sparkling yellow champagne!"

/datum/reagent/ethanol/drink/bluecuracao
	name = "Blue Curacao"
	id = BLUECURACAO
	description = "Essentially a sweeter, bluer form of Triple Sec."
	color = "#3AD1F0" //rgb: 58, 209, 240
	glass_icon_state = "curacaoglass"
	glass_desc = "Why's it blue if it tastes like an orange?"

/datum/reagent/ethanol/drink/ale
	name = "Ale"
	id = ALE
	description = "A dark alcoholic beverage made from malted barley and yeast."
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "aleglass"
	glass_desc = "A cold pint of delicious ale."

/datum/reagent/ethanol/drink/thirteenloko
	name = "Thirteen Loko"
	id = THIRTEENLOKO
	description = "A potent mixture of caffeine and alcohol."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#102000" //rgb: 16, 32, 0
	glass_icon_state = "thirteen_loko_glass"
	glass_desc = "This is a glass of Thirteen Loko. It appears to be of the highest quality. The drink, not the glass."

/datum/reagent/ethanol/drink/thirteenloko/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor
	M.drowsyness = max(0, M.drowsyness - 7)
	M.Jitter(1)

/////////////////////////////////////////////////////////////////Cocktail Entities//////////////////////////////////////////////

/datum/reagent/ethanol/drink/bilk
	name = "Bilk"
	id = BILK
	description = "This appears to be beer mixed with milk. Disgusting."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#AA9988" //rgb: 170, 153, 136
	density = 0.89
	specheatcap = 2.46
	glass_desc = "A brew of milk and beer. For alcoholics who fear osteoporosis."

/datum/reagent/ethanol/drink/atomicbomb
	name = "Atomic Bomb"
	id = ATOMICBOMB
	description = "Nuclear proliferation never tasted so good."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#666300" //rgb: 102, 99, 0
	glass_icon_state = "atomicbombglass"
	glass_name = "\improper Atomic Bomb"
	glass_desc = "NanoTrasen does not take legal responsibility for your actions after imbibing."

/datum/reagent/ethanol/drink/threemileisland
	name = "Three Mile Island Iced Tea"
	id = THREEMILEISLAND
	description = "Made for a woman. Strong enough for a man."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#666340" //rgb: 102, 99, 64
	glass_icon_state = "threemileislandglass"
	glass_name = "\improper Three Mile Island Iced Tea"
	glass_desc = "A glass of this is sure to prevent a meltdown. Or cause one."

/datum/reagent/ethanol/drink/goldschlager
	name = "Goldschlager"
	id = GOLDSCHLAGER
	description = "100 proof cinnamon schnapps with small gold flakes mixed in."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	density = 2.72
	specheatcap = 0.32
	glass_icon_state = "goldschlagerglass"
	glass_desc = "A schnapps with tiny flakes of gold floating in it."

/datum/reagent/ethanol/drink/patron
	name = "Patron"
	id = PATRON
	description = "Tequila with small flakes of silver in it."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#585840" //rgb: 88, 88, 64
	density = 1.84
	specheatcap = 0.59
	glass_icon_state = "patronglass"
	glass_desc = "Drinking Patron in the bar, with all the subpar ladies."

/datum/reagent/ethanol/drink/gintonic
	name = "Gin and Tonic"
	id = GINTONIC
	description = "An all time classic, mild cocktail."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "gintonicglass"
	glass_desc = "A mild but still great cocktail. Drink up, like a true Englishman."

/datum/reagent/ethanol/drink/cuba_libre
	name = "Cuba Libre"
	id = CUBALIBRE
	description = "Rum, mixed with cola. Viva la revolution."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#3E1B00" //rgb: 62, 27, 0
	glass_icon_state = "cubalibreglass"
	glass_name = "\improper Cuba Libre"
	glass_desc = "A classic mix of rum and cola. Viva la revolution."

/datum/reagent/ethanol/drink/whiskey_cola
	name = "Whiskey Cola"
	id = WHISKEYCOLA
	description = "Whiskey, mixed with cola. Surprisingly refreshing."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#3E1B00" //rgb: 62, 27, 0
	glass_icon_state = "whiskeycolaglass"
	glass_desc = "An innocent-looking mixture of cola and whiskey. Delicious."

/datum/reagent/ethanol/drink/martini
	name = "Classic Martini"
	id = MARTINI
	description = "Vermouth with gin. Not quite how 007 enjoyed it, but still delicious."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "martiniglass"
	glass_desc = "Shaken, not stirred."

/datum/reagent/ethanol/drink/vodkamartini
	name = "Vodka Martini"
	id = VODKAMARTINI
	description = "Vodka with gin. Not quite how 007 enjoyed it, but still delicious."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "martiniglass"
	glass_desc = "A bastardisation of the classic martini. Still great."

/datum/reagent/ethanol/drink/sakemartini
	name = "Sake Martini"
	id = SAKEMARTINI
	description = "A martini mixed with sake instead of vermouth. Has a fruity, oriental flavor."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "martiniglass"
	glass_desc = "An oriental spin on the martini, mixed with sake instead of vermouth."

/datum/reagent/ethanol/drink/white_russian
	name = "White Russian"
	id = WHITERUSSIAN
	description = "That's just, like, your opinion, man..."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A68340" //rgb: 166, 131, 64
	glass_icon_state = "whiterussianglass"
	glass_name = "\improper White Russian"
	glass_desc = "A very nice looking drink. But that's just, like, your opinion, man."

/datum/reagent/ethanol/drink/screwdrivercocktail
	name = "Screwdriver"
	id = SCREWDRIVERCOCKTAIL
	description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A68310" //rgb: 166, 131, 16
	glass_icon_state = "screwdriverglass"
	glass_name = "\improper Screwdriver"
	glass_desc = "A simple, yet superb mixture of vodka and orange juice. Just the thing for the tired engineer."

/datum/reagent/ethanol/drink/booger
	name = "Booger"
	id = BOOGER
	description = "Ewww..."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A68310" //rgb: 166, 131, 16
	glass_icon_state = "booger"
	glass_name = "\improper Booger"
	glass_desc = "The color reminds you of something that came out of the clown's nose."

/datum/reagent/ethanol/drink/bloody_mary
	name = "Bloody Mary"
	id = BLOODYMARY
	description = "A strange yet pleasant mixture made of vodka, tomato and lime juice. Or at least you think the red stuff is tomato juice."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "bloodymaryglass"
	glass_name = "\improper Bloody Mary"
	glass_desc = "Tomato juice, mixed with vodka and a lil' bit of lime. Tastes like liquid murder."

/datum/reagent/ethanol/drink/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = GARGLEBLASTER
	description = "Whoah, this stuff looks volatile!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "gargleblasterglass"
	glass_name = "\improper Pan-Galactic Gargle Blaster"
	glass_desc = "Does... does this mean that Arthur and Ford are on the station? Oh joy."

/datum/reagent/ethanol/drink/brave_bull
	name = "Brave Bull"
	id = BRAVEBULL
	description = "A mixture of tequila and coffee liqueur."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "bravebullglass"
	glass_name = "\improper Brave Bull"
	glass_desc = "Tequila and coffee liqueur. Kicks like a bull."

/datum/reagent/ethanol/drink/tequila_sunrise
	name = "Tequila Sunrise"
	id = TEQUILASUNRISE
	description = "Tequila and orange juice. Much like a Screwdriver, only Mexican."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "tequilasunriseglass"
	glass_name = "\improper Tequila Sunrise"
	glass_desc = "Oh great, now you feel nostalgic about sunrises back on Terra..."

/datum/reagent/ethanol/drink/toxins_special
	name = "Toxins Special"
	id = TOXINSSPECIAL
	description = "This thing is FLAMING! CALL THE DAMN SHUTTLE!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "toxinsspecialglass"
	glass_name = "\improper Toxins Special"
	glass_desc = "Whoah, this thing is on FIRE!"

/datum/reagent/ethanol/drink/beepsky_smash
	name = "Beepsky Smash"
	id = BEEPSKYSMASH
	description = "This drink is the law."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "beepskysmashglass"
	glass_name = "\improper Beepsky Smash"
	glass_desc = "Heavy, hot and strong. Best enjoyed with your hands behind your back."

/datum/reagent/drink/doctor_delight
	name = "The Doctor's Delight"
	id = DOCTORSDELIGHT
	description = "A gulp a day keeps the MediBot away. That's what they say, at least."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = FOOD_METABOLISM
	color = "#BA7DBA" //rgb: 73, 49, 73
	glass_icon_state = "doctorsdelightglass"
	glass_name = "\improper Doctor's Delight"
	glass_desc = "A rejuvenating mixture of juices, guaranteed to keep you healthy until the next toolboxing takes place."

/datum/reagent/drink/doctor_delight/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor
	if(M.getOxyLoss())
		M.adjustOxyLoss(-2)
	if(M.getBruteLoss())
		M.heal_organ_damage(2, 0)
	if(M.getFireLoss())
		M.heal_organ_damage(0, 2)
	if(M.getToxLoss())
		M.adjustToxLoss(-2)
	if(M.dizziness != 0)
		M.dizziness = max(0, M.dizziness - 15)
	if(M.confused != 0)
		M.remove_confused(5)

/datum/reagent/ethanol/drink/changelingsting
	name = "Changeling Sting"
	id = CHANGELINGSTING
	description = "Milder than the name suggests. Not that you've ever been stung."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113

/datum/reagent/ethanol/drink/irish_cream
	name = "Irish Cream"
	id = IRISHCREAM
	description = "Whiskey-imbued cream. What else could you expect from the Irish."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "irishcreamglass"
	glass_desc = "It's cream, mixed with whiskey. What else would you expect from the Irish?"

/datum/reagent/ethanol/drink/manly_dorf
	name = "The Manly Dorf"
	id = MANLYDORF
	description = "A dwarfy concoction made from ale and beer. Intended for stout dwarves only."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "manlydorfglass"
	glass_name = "The Manly Dorf"
	glass_desc = "A dwarfy concoction made from ale and beer. Intended for stout dwarves only."

/datum/reagent/ethanol/drink/longislandicedtea
	name = "Long Island Iced Tea"
	id = LONGISLANDICEDTEA
	description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "longislandicedteaglass"
	glass_name = "\improper Long Island Iced Tea"

/datum/reagent/ethanol/drink/mudslide
	name = "Mudslide"
	id = MUDSLIDE
	description = "Like a milkshake, but for irresponsible adults."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#b6ac94" //rgb: 182, 172, 148
	glass_icon_state = "mudslide"
	glass_name = "\improper Mudslide"

/datum/reagent/ethanol/drink/sacrificial_mary
	name = "Sacrificial Mary"
	id = SACRIFICIAL_MARY
	description = "Fresh Altar-To-Table taste in every sip."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#bd1c1e" //rgb: 189, 28, 30
	glass_icon_state = "sacrificialmary"
	glass_name = "\improper Sacrificial Mary"

/datum/reagent/ethanol/drink/boysenberry_blizzard
	name = "Boysenberry Blizzard"
	id = BOYSENBERRY_BLIZZARD
	description = "Don't stick your tongue out for these snowflakes!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#aa4cbd" //rgb: 170, 76, 189
	glass_icon_state = "boysenberryblizzard"
	glass_name = "\improper Boysenberry Blizzard"

/datum/reagent/ethanol/drink/moonshine
	name = "Moonshine"
	id = MOONSHINE
	description = "You've really hit rock bottom now... your liver packed its bags and left last night."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/drink/midnightkiss
	name = "Midnight Kiss"
	id = MIDNIGHTKISS
	description = "Vodka mixed with Blue Curacao and topped with champagne. Bubbly!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#82f0ff" //rgb: 130, 240, 255
	glass_icon_state = "midnightkiss"
	glass_name = "\improper Midnight Kiss"

/datum/reagent/ethanol/drink/cosmopolitan
	name = "Cosmopolitan"
	id = COSMOPOLITAN
	description = "A Cosmopolitan, the poster child of fruity cocktails."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#d64054" //rgb: 214, 64, 84
	glass_icon_state = "cosmopolitan"
	glass_name = "cosmopolitan"

/datum/reagent/ethanol/drink/corpsereviver
	name = "Corpse Reviver No. 2"
	id = CORPSEREVIVER
	description = "Hair of the dog taken to one of its most logical extremes."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFFFFF" //rgb: 255, 255, 255
	glass_icon_state = "corpsereviver"
	glass_name = "\improper Corpse Reviver No. 2"

/datum/reagent/ethanol/drink/bluelagoon
	name = "Blue Lagoon"
	id = BLUELAGOON
	description = "Goes best with swim trunks, a sea breeze, and a nice big beach."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#82f0ff" //rgb: 130, 240, 255
	glass_icon_state = "bluelagoon"
	glass_name = "\improper Blue Lagoon"

/datum/reagent/ethanol/drink/sexonthebeach
	name = "Sex On The Beach"
	id = SEXONTHEBEACH
	description = "Did you hear a bear just now?"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#fca668" //rgb: 252, 166, 104
	glass_icon_state = "sexonthebeach"
	glass_desc = "\improper Sex On The Beach"

/datum/reagent/ethanol/drink/americano
	name = "Americano"
	id = AMERICANO
	description = "Expensive soda water - the best way to improve a poor drink."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#872d12" //rgb: 135, 45, 18
	glass_icon_state = "americano"
	glass_name = "americano"

/datum/reagent/ethanol/drink/betweenthesheets
	name = "Between The Sheets"
	id = BETWEENTHESHEETS
	description = "This is basically just a sidecar with rum in it."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#f0d695" //rgb: 240, 214, 149
	glass_icon_state = "betweenthesheets"
	glass_name = "\improper Between The Sheets"

/datum/reagent/ethanol/drink/sidecar
	name = "Sidecar"
	id = SIDECAR
	description = "For those who still want a fruity cocktail, without the effeminate connotations of a Cosmo."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#99593c" //rgb: 153, 89, 60
	glass_icon_state = "sidecar"
	glass_name = "sidecar"

/datum/reagent/ethanol/drink/champagnecocktail
	name = "Champagne Cocktail"
	id = CHAMPAGNECOCKTAIL
	description = "Champagne, bitters, and cognac, garnished with a cherry. Very classy."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#fcdf95" //rgb: 252, 223, 149
	glass_icon_state = "champagnecocktail"
	glass_name = "Champagne cocktail"

/datum/reagent/ethanol/drink/espressomartini
	name = "Espresso Martini"
	id = ESPRESSOMARTINI
	description = "Two of any self respecting substance abuser's fixes in one drink!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#120705" //rgb: 18, 7, 5
	glass_icon_state = "espressomartini"
	glass_name = "espresso martini"

/datum/reagent/ethanol/drink/kamikaze
	name = "Kamikaze"
	id = KAMIKAZE
	description = "Banzai!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFFFFF" //rgb: 255, 255, 255
	glass_icon_state = "kamikaze"
	glass_name = "kamikaze"

/datum/reagent/ethanol/drink/mojito
	name = "Mojito"
	id = MOJITO
	description = "A giant pain in the ass to make on the best of days."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#c3f08d" //rgb: 195, 240, 141
	glass_icon_state = "mojito"
	glass_name = "mojito"

/datum/reagent/ethanol/drink/whiskeytonic
	name = "Whiskey Tonic"
	id = WHISKEYTONIC
	description = "Quinine makes everything taste better."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#fff9cf" //rgb: 255, 249, 207
	glass_icon_state = "whiskeytonic"
	glass_name = "\improper Whiskey Tonic"

/datum/reagent/ethanol/drink/moscowmule
	name = "Moscow Mule"
	id = MOSCOWMULE
	description = "Wait a minute, this isn't ginger beer..."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6e573f" //rgb: 110, 87, 63
	glass_icon_state = "moscowmule"
	glass_name = "\improper Moscow Mule"

/datum/reagent/ethanol/drink/cinnamonwhisky
	name = "Cinnamon Whisky"
	id = CINNAMONWHISKY
	description = "Cinnamon whisky. Feel the burn."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#f29224" //rgb: 242, 146, 36
	glass_icon_state = "fireballglass"
	glass_desc = "Red-hot cinnamon whisky in a shot glass."

/datum/reagent/ethanol/drink/c4cocktail
	name = "C-4 Cocktail"
	id = C4COCKTAIL
	description = "Kahlua and Cinnamon Whisky, a burning explosion of flavor - tastes like pain. And cinnamon."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#1f0802" //31, 8, 2
	glass_icon_state = "c4cocktail"
	glass_name = "\improper C-4 Cocktail"
	glass_desc = "Kahlua and Cinnamon Whisky, a burning explosion of cinnamon flavor."

/datum/reagent/ethanol/drink/dragonsblood
	name = "Dragon's Blood"
	id = DRAGONSBLOOD
	description = "Burning hot and bright red, just like the mythical namesake."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#b01522" //176, 21, 34
	glass_icon_state = "dragonsblood"
	glass_name = "\improper Dragon's Blood"
	flammable = 1
	light_color = "#540303"

/datum/reagent/ethanol/drink/dragonspit
	name = "Dragon's Spit"
	id = DRAGONSSPIT
	description = "The simplest idea possible; take something hot, and make it hotter."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#f29224" // 242, 146, 36
	glass_icon_state = "dragonsspit"
	glass_name = "\improper Dragon's Spit"
	light_color = "#ff7003"
	flammable = 1

/datum/reagent/ethanol/drink/firecider
	name = "Fire Cider"
	id = FIREBALLCIDER
	description = "Apples, alcohol, and cinnamon, a match made in heaven."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#f29224" // 242, 146, 36
	glass_icon_state = "fireballcider"
	glass_name = "\improper Fireball Cider"
	glass_desc = "A toasty hot glass of apple cider and cinnamon whisky - makes you feel warm and fuzzy inside."

/datum/reagent/ethanol/drink/cinnamontoastcocktail
	name = "Cinnamon Toast"
	id = CINNAMONTOASTCOCKTAIL
	description = "Rum, cream, and cinnamon whisky. Tastes a little like the milk you get out of a sugary cereal."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#f29224" // 242, 146, 36
	glass_icon_state = "cinnamontoastcocktail"
	glass_name = "\improper Cinnamon Toast Cocktail"
	glass_desc = "Kind of like drinking left-over cereal milk, but for people with a drinking problem."

/datum/reagent/ethanol/drink/manhattanfireball
	name = "Manhattan Fireball"
	id = MANHATTANFIREBALL
	description = "A timeless classic made with a burning hot twist."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#f29224" // 242, 146, 36
	glass_icon_state = "manhattanfireball"
	glass_name = "\improper Manhattan Fireball"
	light_color = "#540303"
	flammable = 1

/datum/reagent/ethanol/drink/fireballcola
	name = "Fireball Cola"
	id = FIREBALLCOLA
	description = "Like a Whiskey Cola, but with added painful burning sensation."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#f20224" //242, 146, 36
	glass_icon_state = "fireballcola"
	glass_name = "\improper Fireball Cola"
	glass_desc = "Cinnamon whisky and cola - like a regular whiskey cola, but with more burning."

/datum/reagent/ethanol/drink/firerita
	name = "Fire-rita"
	id = FIRERITA
	description = "Triple sec, Cinnamon Whisky, and Tequila, eugh. Less a cocktail more than throwing whatever's on the shelf in a glass."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#f0133c" //rgb: 240, 19, 60
	glass_icon_state = "firerita"
	glass_name = "firerita"
	glass_desc = "Looks pretty, offends a sane person's taste buds. Then again, anyone who orders this probably lacks one of those two traits."

/datum/reagent/ethanol/drink/magica
	name = "Magica"
	id = MAGICA
	description = "A bitter mix with a burning aftertaste."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#774F1B"
	glass_icon_state = "magica"
	glass_name = "magica"
	glass_desc = "Bitter, with an annoying aftertaste of spice. Supposedly inspired by wearers of bath robes."

/datum/reagent/ethanol/drink/b52
	name = "B-52"
	id = B52
	description = "Coffee, irish cream, and cognac. You will get bombed."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "b52glass"
	glass_name = "\improper B-52"
	light_color = "#000080"
	flammable = 1

/datum/reagent/ethanol/drink/irishcoffee
	name = "Irish Coffee"
	id = IRISHCOFFEE
	description = "Coffee served with irish cream. Regular cream just isn't the same."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "irishcoffeeglass"

/datum/reagent/ethanol/drink/margarita
	name = "Margarita"
	id = MARGARITA
	description = "On the rocks with salt on the rim. Arriba!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "margaritaglass"

/datum/reagent/ethanol/drink/black_russian
	name = "Black Russian"
	id = BLACKRUSSIAN
	description = "For the lactose-intolerant. Still as classy as a White Russian."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#360000" //rgb: 54, 0, 0
	glass_icon_state = "blackrussianglass"
	glass_name = "\improper Black Russian"
	glass_desc = "For the lactose-intolerant. Still as classy as a White Russian."

/datum/reagent/ethanol/drink/manhattan
	name = "Manhattan"
	id = MANHATTAN
	description = "The Detective's undercover drink of choice. He never could stomach gin..."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "manhattanglass"
	glass_name = "\improper Manhattan"

/datum/reagent/ethanol/drink/manhattan_proj
	name = "Manhattan Project"
	id = MANHATTAN_PROJ
	description = "A scientist's drink of choice, for thinking about how to blow up the station."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "proj_manhattanglass"
	glass_name = "\improper Manhattan Project"

/datum/reagent/ethanol/drink/whiskeysoda
	name = "Whiskey Soda"
	id = WHISKEYSODA
	description = "Ultimate refreshment."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "whiskeysodaglass2"

/datum/reagent/ethanol/drink/antifreeze
	name = "Anti-freeze"
	id = ANTIFREEZE
	description = "The ultimate refreshment."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "antifreeze"
	glass_name = "\improper Anti-freeze"

/datum/reagent/ethanol/drink/barefoot
	name = "Barefoot"
	id = BAREFOOT
	description = "Barefoot and pregnant"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "b&p"
	glass_name = "\improper Barefoot"

/datum/reagent/ethanol/drink/snowwhite
	name = "Snow White"
	id = SNOWWHITE
	description = "Pale lager mixed with lemon-lime soda. Refreshing and sweet."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "snowwhite"
	glass_name = "\improper Snow White"

/datum/reagent/ethanol/drink/demonsblood
	name = "Demon's Blood"
	id = DEMONSBLOOD
	description = "AHHHH!!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 10
	slurr_adj = 10
	glass_icon_state = "demonsblood"
	glass_name = "\improper Demon's Blood"
	glass_desc = "Just looking at this thing makes the hair on the back of your neck stand up."

/datum/reagent/ethanol/drink/vodkatonic
	name = "Vodka and Tonic"
	id = VODKATONIC
	description = "For when a gin and tonic isn't Russian enough."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 4
	slurr_adj = 3
	glass_icon_state = "vodkatonicglass"
	glass_desc = "For when a gin and tonic isn't Russian enough."

/datum/reagent/ethanol/drink/ginfizz
	name = "Gin Fizz"
	id = GINFIZZ
	description = "Refreshingly lemony, deliciously dry."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 4
	slurr_adj = 3
	glass_icon_state = "ginfizzglass"
	glass_name = "\improper Gin Fizz"

/datum/reagent/ethanol/drink/bahama_mama
	name = "Bahama mama"
	id = BAHAMA_MAMA
	description = "Tropical cocktail."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "bahama_mama"
	glass_name = "\improper Bahama Mama"
	glass_desc = "A delicious tropical cocktail."

/datum/reagent/ethanol/drink/pinacolada
	name = "Pina Colada"
	id = PINACOLADA
	description = "Sans pineapple."
	reagent_state = REAGENT_STATE_LIQUID
	color = "F2F5BF" //rgb: 242, 245, 191
	glass_icon_state = "pinacolada"
	glass_name = "\improper Pina Colada"
	glass_desc = "If you like this and getting caught in the rain, come with me and escape."

/datum/reagent/ethanol/drink/singulo
	name = "Singulo"
	id = SINGULO
	description = "A gravitational anomaly."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113
	dizzy_adj = 15
	slurr_adj = 15
	glass_icon_state = "singulo"
	glass_name = "\improper Singulo"
	glass_desc = "IT'S LOOSE!"

/datum/reagent/ethanol/drink/sangria
	name = "Sangria"
	id = SANGRIA
	description = "So tasty you won't believe it's alcohol."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#53181A" //rgb: 83, 24, 26
	dizzy_adj = 2
	slur_start = 65
	confused_start = 145
	glass_icon_state = "sangria"
	glass_name = "\improper Sangria"

/datum/reagent/ethanol/drink/sbiten
	name = "Sbiten"
	id = SBITEN
	description = "A spicy vodka."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "sbitenglass"
	glass_desc = "A spicy mix of vodka and spice. Very hot."

/datum/reagent/ethanol/drink/sbiten/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.bodytemperature < 360)
		M.bodytemperature = min(360, M.bodytemperature + 50) //310 is the normal bodytemp. 310.055

/datum/reagent/ethanol/drink/devilskiss
	name = "Devil's Kiss"
	id = DEVILSKISS
	description = "Creepy time!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A68310" //rgb: 166, 131, 16
	glass_icon_state = "devilskiss"
	glass_name = "\improper Devil's Kiss"

/datum/reagent/ethanol/drink/red_mead
	name = "Red Mead"
	id = RED_MEAD
	description = "A crimson beverage consumed by space vikings. The coloration is from berries... you hope."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "red_meadglass"

/datum/reagent/ethanol/drink/mead
	name = "Mead"
	id = MEAD
	description = "A beverage consumed by space vikings on their long raids and rowdy festivities."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "meadglass"

/datum/reagent/ethanol/drink/iced_beer
	name = "Iced Beer"
	id = ICED_BEER
	description = "A beer so frosty the air around it freezes."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "iced_beerglass"

/datum/reagent/ethanol/drink/iced_beer/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.bodytemperature < T0C+33)
		M.bodytemperature = min(T0C+33, M.bodytemperature - 4) //310 is the normal bodytemp. 310.055

/datum/reagent/ethanol/drink/grog
	name = "Grog"
	id = GROG
	description = "Watered down rum. NanoTrasen approves!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "grogglass"
	glass_desc = "The favorite of pirates everywhere."

/datum/reagent/ethanol/drink/aloe
	name = "Aloe"
	id = ALOE
	description = "Watermelon juice and irish cream. Contains no actual aloe."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "aloe"
	glass_name = "\improper Aloe"

/datum/reagent/ethanol/drink/andalusia
	name = "Andalusia"
	id = ANDALUSIA
	description = "Rum, whiskey, and lemon juice."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "andalusia"
	glass_name = "\improper Andalusia"
	glass_desc = "A strong cocktail named after a historical Terran land."

/datum/reagent/ethanol/drink/alliescocktail
	name = "Allies Cocktail"
	id = ALLIESCOCKTAIL
	description = "English gin, French vermouth, and Russian vodka."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "alliescocktail"
	glass_name = "\improper Allies Cocktail"
	glass_desc = "A cocktail of spirits from three historical Terran nations, symbolizing their alliance in a great war."

/datum/reagent/ethanol/drink/acid_spit
	name = "Acid Spit"
	id = ACIDSPIT
	description = "Wine and sulphuric acid. You hope the wine has neutralized the acid."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#365000" //rgb: 54, 80, 0
	glass_icon_state = "acidspitglass"
	glass_name = "\improper Acid Spit"
	glass_desc = "Bites like a xeno queen."

/datum/reagent/ethanol/drink/amasec
	name = "Amasec"
	id = AMASEC
	description = "The official drink of the Imperium."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "amasecglass"
	glass_name = "\improper Amasec"
	glass_desc = "A grim and dark drink that knows only war."

/datum/reagent/ethanol/drink/amasec/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.AdjustStunned(4)

/datum/reagent/ethanol/drink/neurotoxin
	name = "Neurotoxin"
	id = NEUROTOXIN
	description = "A strong neurotoxin that puts the subject into a death-like state."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E2E61" //rgb: 46, 46, 97
	glass_icon_state = "neurotoxinglass"
	glass_name = "\improper Neurotoxin"
	glass_desc = "Guaranteed to knock you silly."

/datum/reagent/ethanol/drink/neurotoxin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.adjustOxyLoss(1)
	M.SetKnockdown(max(M.knockdown, 15))
	M.SetStunned(max(M.stunned, 15))
	M.silent = max(M.silent, 15)

/datum/reagent/drink/bananahonk
	name = "Banana Honk"
	id = BANANAHONK
	description = "A non-alcoholic drink of banana juice, milk cream and sugar."
	nutriment_factor = FOOD_METABOLISM
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "bananahonkglass"
	glass_name = "\improper Banana Honk"
	glass_desc = "A cocktail from the clown planet."

/datum/reagent/drink/silencer
	name = "Silencer"
	id = SILENCER
	description = "Some say this is the diluted blood of the mime."
	nutriment_factor = FOOD_METABOLISM
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "silencerglass"
	glass_name = "\improper Silencer"
	glass_desc = "The mime's favorite, though you won't hear him ask for it."

/datum/reagent/drink/silencer/on_mob_life(var/mob/living/M)

	if(..())
		return 1
	M.silent = max(M.silent, 15)

/datum/reagent/ethanol/drink/changelingsting
	name = "Changeling Sting"
	id = CHANGELINGSTING
	description = "Milder than the name suggests. Not that you've ever been stung."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113
	glass_icon_state = "changelingsting"
	glass_name = "\improper Changeling Sting"
	glass_desc = "Stings, but not deadly."

/datum/reagent/ethanol/drink/changelingsting/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.dizziness += 5

/datum/reagent/ethanol/drink/erikasurprise
	name = "Erika Surprise"
	id = ERIKASURPRISE
	description = "The surprise is, it's green!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113
	glass_icon_state = "erikasurprise"
	glass_name = "\improper Erika Surprise"

/datum/reagent/ethanol/drink/irishcarbomb
	name = "Irish Car Bomb"
	id = IRISHCARBOMB
	description = "A troubling mixture of irish cream and ale."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113
	glass_icon_state = "irishcarbomb"
	glass_name = "\improper Irish Car Bomb"
	glass_desc = "Something about this drink troubles you."

/datum/reagent/ethanol/drink/irishcarbomb/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.dizziness += 5

/datum/reagent/ethanol/drink/syndicatebomb
	name = "Syndicate Bomb"
	id = SYNDICATEBOMB
	description = "Whiskey cola and beer. Figuratively explosive."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113
	glass_icon_state = "syndicatebomb"
	glass_name = "\improper Syndicate Bomb"
	glass_desc = "Somebody set up us the bomb!"
	glass_isGlass = 0

/datum/reagent/ethanol/drink/driestmartini
	name = "Driest Martini"
	id = DRIESTMARTINI
	description = "Only for the experienced. You think you see sand floating in the glass."
	nutriment_factor = FOOD_METABOLISM
	color = "#2E6671" //rgb: 46, 102, 113
	data = 1 //Used as a tally
	glass_icon_state = "driestmartiniglass"
	glass_name = "\improper Driest Martini"

/datum/reagent/ethanol/drink/driestmartini/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.dizziness += 10
	if(data >= 55 && data < 115)
		M.stuttering += 10
	else if(data >= 115 && prob(33))
		M.confused = max(M.confused + 15, 15)
	data++

/datum/reagent/ethanol/drink/danswhiskey
	name = "Discount Dan's 'Malt' Whiskey"
	id = DANS_WHISKEY
	description = "It looks like whiskey... kinda."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 181, 199, 158
	glass_icon_state = "dans_whiskey"
	glass_name = "\improper Discount Dan's 'Malt' Whiskey"
	glass_desc = "The cheapest path to liver failure."

/datum/reagent/ethanol/drink/danswhiskey/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		switch(volume)
			if(1 to 15)
				if(prob(5))
					to_chat(H,"<span class='warning'>Your stomach grumbles and you feel a little nauseous.</span>")
					H.adjustToxLoss(0.5)
				H.adjustToxLoss(0.1)
			if(15 to 25)
				if(prob(10))
					to_chat(H,"<span class='warning'>Something in your abdomen definitely doesn't feel right.</span>")
					H.adjustToxLoss(1)
				if(prob(5))
					H.adjustToxLoss(2)
					H.vomit()
				H.adjustToxLoss(0.2)
			if(25 to INFINITY)
				if(prob(10))
					H.custom_pain("You feel a horrible throbbing pain in your stomach!",1)
					var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
					if(istype(L))
						L.take_damage(1, 1)
					H.adjustToxLoss(2)
				if(prob(5))
					H.vomit()
					H.adjustToxLoss(3)
				H.adjustToxLoss(0.3)

/datum/reagent/ethanol/drink/pintpointer
	name = "Pintpointer"
	id = PINTPOINTER
	description = "A little help finding the bartender."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/drink/pintpointer/handle_special_behavior(var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/D)
	var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/pintpointer/P = new (get_turf(D))
	var/datum/reagents/glassreagents = D.reagents

	if(glassreagents.last_ckey_transferred_to_this)
		for(var/client/C in clients)
			if(C.ckey == glassreagents.last_ckey_transferred_to_this)
				var/mob/M = C.mob
				P.creator = M
	glassreagents.trans_to(P, glassreagents.total_volume)
	spawn(1)
		qdel(D)

/datum/reagent/ethanol/drink/monstermash
	name = "Monster Mash"
	id = MONSTERMASH
	description = "It'll be gone in a flash!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#b97309"
	glass_icon_state = "monster_mash"
	glass_name = "\improper Monster Mash"
	glass_desc = "Will get you graveyard smashed."

/datum/reagent/ethanol/drink/monstermash/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(isskellington(H) || isskelevox(H) || islich(H) || H.is_wearing_item(/obj/item/clothing/under/skelesuit))
			doTheMash(H)
		if(H.is_wearing_item(/obj/item/clothing/head/franken_bolt) || istype(H, /mob/living/carbon/human/frankenstein))
			joltOfMyElectrodes(H)
		if(H.is_wearing_item(/obj/item/clothing/mask/vamp_fangs) || H.is_wearing_item(/obj/item/clothing/suit/storage/draculacoat) || isvampire(H))
			draculaAndHisSon(H)

/datum/reagent/ethanol/drink/monstermash/proc/doTheMash(mob/living/carbon/human/H)
	playsound(H, 'sound/effects/rattling_bones.ogg', 100, 1)
	if(prob(15))
		H.emote("spin")
		H.visible_message("<span class='good'>[H] does the mash!</span>")
		if(prob(25))
			spawn(1 SECONDS)
				H.emote("spin")
				H.visible_message("<span class='good'>[H] does the monster mash!</span>")

/datum/reagent/ethanol/drink/monstermash/proc/joltOfMyElectrodes(mob/living/carbon/human/H)
	for(var/turf/simulated/T in orange(1, H))
		if(prob(volume))
			spark(T, 1)

/datum/reagent/ethanol/drink/monstermash/proc/draculaAndHisSon(mob/living/carbon/human/H)
	if(prob(15))
		var/mob/living/simple_animal/dracson/dSon = new /mob/living/simple_animal/dracson(H.loc)
		try_move_adjacent(dSon)
		spawn(5 SECONDS)
			dSon.death()

/datum/reagent/ethanol/drink/eggnog
	name = "Eggnog"
	id = EGGNOG
	description = "Milk, cream and egg."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#F0DFD1" //rgb: 240, 223, 209
	glass_icon_state = "eggnog"
	glass_name = "\improper eggnog"
	glass_desc = "Celebrate the holidays with practically liquid custard. Something is missing though."

/datum/reagent/ethanol/drink/festive_eggnog
	name = "Festive Eggnog"
	id = FESTIVE_EGGNOG
	description = "Eggnog, complete with booze and a dusting of cinnamon."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#F0DFD1" //rgb: 240, 223, 209
	glass_icon_state = "festive_eggnog"
	glass_name = "\improper festive eggnog"
	glass_desc = "Eggnog, complete with booze and a dusting of cinnamon for that winter warmth."

//Eventually there will be a way of making vinegar.
/datum/reagent/vinegar
	name = "Vinegar"
	id = VINEGAR
	reagent_state = REAGENT_STATE_LIQUID
	color = "#3F1900" //rgb: 63, 25, 0
	density = 0.79
	specheatcap = 2.46

/datum/reagent/honkserum
	name = "Honk Serum"
	id = HONKSERUM
	description = "Concentrated honking."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#F2C900" //rgb: 242, 201, 0
	custom_metabolism = 0.05
	overdose_am = REAGENTS_OVERDOSE

/datum/reagent/honkserum/on_overdose(var/mob/living/H)

	if (H?.mind?.miming)
		H.mind.miming = 0
		for(var/spell/aoe_turf/conjure/forcewall/mime/spell in H.spell_list)
			H.remove_spell(spell)
		for(var/spell/targeted/oathbreak/spell in H.spell_list)
			H.remove_spell(spell)
		if (istype(H.wear_mask, /obj/item/clothing/mask/gas/mime/stickymagic))
			qdel(H.wear_mask)
			H.visible_message("<span class='warning'>\The [H]'s mask melts!</span>")
		H.visible_message("<span class='notice'>\The [H]'s face goes pale for a split second, and then regains some colour.</span>", "<span class='notice'><i>Where did Marcel go...?</i></span>'")


/datum/reagent/honkserum/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(5))
		M.say(pick("Honk", "HONK", "Hoooonk", "Honk?", "Henk", "Hunke?", "Honk!"))
		playsound(M, 'sound/items/bikehorn.ogg', 50, -1)

/datum/reagent/hamserum
	name = "Ham Serum"
	id = HAMSERUM
	description = "Concentrated legal discussions."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#00FF21" //rgb: 0, 255, 33

/datum/reagent/hamserum/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	if(..())
		return 1

	empulse(get_turf(M), 1, 2, 1)

	return

//Cafe drinks

/datum/reagent/drink/tea/greentea
	name = "Green Tea"
	id = GREENTEA
	description = "Delicious green tea."
	mug_icon_state = "greentea"
	mug_desc = "Green Tea served in a traditional Japanese tea cup, just like in your Chinese cartoons!"

/datum/reagent/drink/tea/redtea
	name = "Red Tea"
	id = REDTEA
	description = "Tasty red tea."
	mug_icon_state = "redtea"
	mug_desc = "Red Tea served in a traditional Chinese tea cup, just like in your Malaysian movies!"

/datum/reagent/drink/tea/singularitea
	name = "Singularitea"
	id = SINGULARITEA
	description = "Swirly!"
	mug_icon_state = "singularitea"
	mug_name = "\improper Singularitea"
	mug_desc = "Brewed under intense radiation to be extra flavorful!"

var/global/list/chifir_doesnt_remove = list("chifir", "blood")

/datum/reagent/drink/tea/chifir
	name = "Chifir"
	id = CHIFIR
	description = "Strong Russian tea. It'll help you remember what you had for lunch!"
	mug_icon_state = "chifir"
	mug_desc = "A Russian kind of tea. Not for those with weak stomachs."

/datum/reagent/drink/tea/chifir/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(ishuman(M) && prob(5))
		var/mob/living/carbon/human/H = M
		H.vomit()

	for(var/datum/reagent/reagent in holder.reagent_list)
		if(reagent.id in chifir_doesnt_remove)
			continue
		holder.remove_reagent(reagent.id, 3 * REM)

	M.adjustToxLoss(-2 * REM)

/datum/reagent/drink/tea/acidtea
	name = "Earl's Grey Tea"
	id = ACIDTEA
	description = "Get in touch with your Roswellian side!"
	mug_icon_state = "acidtea"
	mug_desc = "A sizzling mug of tea made just for Greys."

/datum/reagent/drink/tea/yinyang
	name = "Zen Tea"
	id = YINYANG
	description = "Find inner peace."
	mug_icon_state = "yinyang"
	mug_desc = "Enjoy inner peace and ignore the watered down taste"

/datum/reagent/drink/tea/gyro
	name = "Gyro"
	id = GYRO
	description = "Nyo ho ho~"
	mug_icon_state = "gyro"
	mug_name = "\improper Gyro"

/datum/reagent/drink/tea/gyro/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(30))
		M.emote("spin")
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/zone in list(LIMB_LEFT_LEG, LIMB_RIGHT_LEG, LIMB_LEFT_FOOT, LIMB_RIGHT_FOOT))
			H.HealDamage(zone, rand(1, 3), rand(1, 3)) //Thank you Gyro

/datum/reagent/drink/tea/dantea
	name = "Discount Dan's Green Flavor Tea"
	id = DANTEA
	description = "Not safe for children above or under the age of 12."
	mug_icon_state = "dantea"
	mug_name = "\improper Discount Dan's Green Flavor Tea"
	mug_desc = "Tea probably shouldn't be sizzling like that..."

/datum/reagent/drink/tea/mint
	name = "Groans Tea: Minty Delight Flavor"
	id = MINT
	description = "Very filling!"
	mug_icon_state = "mint"
	mug_name = "\improper Groans Tea: Minty Delight Flavor"
	mug_desc = "Groans knows mint might not be the kind of flavor our fans expect from us, but we've made sure to give it that patented Groans zing."

/datum/reagent/drink/tea/chamomile
	name = "Groans Tea: Chamomile Flavor"
	id = CHAMOMILE
	description = "Enjoy a good night's sleep."
	mug_icon_state = "chamomile"
	mug_name = "\improper Groans Tea: Chamomile Flavor"
	mug_desc = "Groans presents the perfect cure for insomnia: Chamomile!"

/datum/reagent/drink/tea/exchamomile
	name = "Tea"
	id = EXCHAMOMILE
	description = "Who needs to wake up anyway?"
	mug_icon_state = "exchamomile"
	mug_name = "\improper Groans Banned Tea: EXTREME Chamomile Flavor"
	mug_desc = "Banned literally everywhere."

/datum/reagent/drink/tea/fancydan
	name = "Groans Banned Tea: Fancy Dan Flavor"
	id = FANCYDAN
	description = "Full of that patented Dan taste you love!"
	mug_icon_state = "fancydan"
	mug_name = "\improper Groans Banned Tea: Fancy Dan Flavor"
	mug_desc = "Banned literally everywhere."

/datum/reagent/drink/tea/plasmatea
	name = "Plasma Pekoe"
	id = PLASMATEA
	description = "Probably not the safest beverage."
	mug_icon_state = "plasmatea"
	mug_desc = "You can practically taste the science. Or maybe that's just the horrible plasma burns."

/datum/reagent/drink/tea/greytea
	name = "Tide"
	id = GREYTEA
	description = "This probably shouldn't even be considered tea..."
	mug_icon_state = "greytea"
	mug_name = "\improper Tide"

/datum/reagent/drink/coffee/espresso
	name = "Espresso"
	id = ESPRESSO
	description = "A thick blend of coffee made by forcing near-boiling pressurized water through finely ground coffee beans."
	mug_icon_state = "espresso"

//Let's hope this one works
var/global/list/tonio_doesnt_remove=list("tonio", "blood")

/datum/reagent/drink/coffee/tonio
	name = "Tonio"
	id = TONIO
	nutriment_factor = FOOD_METABOLISM
	description = "This coffee seems uncannily good."
	mug_icon_state = "tonio"
	mug_name = "\improper Tonio"
	mug_desc = "Delicious, and may help you get out of a Jam."

/datum/reagent/drink/coffee/tonio/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(ishuman(M) && prob(5))
		var/mob/living/carbon/human/H = M
		H.vomit()

	for(var/datum/reagent/reagent in holder.reagent_list)
		if(reagent.id in tonio_doesnt_remove)
			continue
		holder.remove_reagent(reagent.id, 3 * REM)

	M.adjustToxLoss(-2 * REM)
	M.nutrition += nutriment_factor

	if(M.getBruteLoss() && prob(20))
		M.heal_organ_damage(1, 0)

/datum/reagent/drink/coffee/cappuccino
	name = "Cappuccino"
	id = CAPPUCCINO
	description = "Espresso with milk."
	mug_icon_state = "cappuccino"
	mug_desc = "The stronger big brother of the cafe latte, cappuccino contains more espresso in proportion to milk."

/datum/reagent/drink/coffee/cappuccino/on_mob_life(var/mob/living/M)
	..()
	if(M.getBruteLoss() && prob(20))
		M.heal_organ_damage(1, 0) //milk doing its work

/datum/reagent/drink/coffee/doppio
	name = "Doppio"
	id = DOPPIO
	description = "Double shot of espresso."
	mug_icon_state = "doppio"
	mug_name = "\improper Doppio"
	mug_desc = "Ring ring ring ring."

/datum/reagent/drink/coffee/passione
	name = "Passione"
	id = PASSIONE
	description = "Rejuvenating!"
	nutriment_factor = 3 * REAGENTS_METABOLISM //because honey
	mug_icon_state = "passione"
	mug_name = "\improper Passione"
	mug_desc = "Sometimes referred to as a 'Vento Aureo'."

/datum/reagent/drink/coffee/passione/on_mob_life(var/mob/living/M)
	..()

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!holder)
			return
		H.sleeping = 0
		H.nutrition += nutriment_factor //honey doing it's work
		if(H.getBruteLoss() && prob(60))
			H.heal_organ_damage(1, 0)
		if(H.getFireLoss() && prob(50))
			H.heal_organ_damage(0, 1)
		if(H.getToxLoss() && prob(50))
			H.adjustToxLoss(-1)

/datum/reagent/drink/coffee/seccoffee
	name = "Wake-Up Call"
	id = SECCOFFEE
	description = "All the essentials."
	mug_icon_state = "seccoffee"
	mug_name = "\improper Wake-Up Call"
	mug_desc = "The perfect start for any Sec officer's day."

/datum/reagent/drink/coffee/seccoffee/on_mob_life(var/mob/living/M)
	..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.job in list("Security Officer", "Head of Security", "Detective", "Warden"))
			H.heal_organ_damage(1, 1) //liquid sprinkles!

/datum/reagent/drink/coffee/medcoffee
	name = "Lifeline"
	id = MEDCOFFEE
	description = "Tastes like it's got iron in it or something."
	mug_icon_state = "medcoffee"
	mug_name = "\improper Lifeline"
	mug_desc = "Some days, the only thing that keeps you going is cryo and caffeine."

/datum/reagent/drink/coffee/medcoffee/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor
	if(M.getOxyLoss() && prob(25))
		M.adjustOxyLoss(-1)
	if(M.getBruteLoss() && prob(30))
		M.heal_organ_damage(1, 0)
	if(M.getFireLoss() && prob(25))
		M.heal_organ_damage(0, 1)
	if(M.getToxLoss() && prob(25))
		M.adjustToxLoss(-1)
	if(M.dizziness != 0)
		M.dizziness = max(0, M.dizziness - 15)
	if(M.confused != 0)
		M.remove_confused(5)
	M.reagents.add_reagent (IRON, 0.1)

/datum/reagent/drink/coffee/detcoffee
	name = "Joe"
	id = DETCOFFEE
	description = "Bitter, black, and tasteless. Just the way I liked my coffee. I was halfway down my third mug that day, and all the way down on my luck. The only case I'd had all month had just turned sour. I took the flask in my drawer and emptied its contents into my coffee. No alcohol today, I'd promised myself. Thing is, promises to yourself are easy to break. No one to hold you accountable."
	causes_jitteriness = 0
	var/activated = 0
	var/noir_set_by_us = 0
	mug_icon_state = "detcoffee"
	mug_name = "\improper Joe"
	mug_desc = "The lights, the smoke, the grime... the station itself felt alive that day when I stepped into my office, mug in hand. It had been one of those damn days. Some nurse got smoked in the tunnels, and it came down to me to catch the son of a bitch that did it. The dark, stale air of the tunnels sucks the soul out of a man -- sometimes literally -- and I was no closer to finding the killer than when the nurse was still alive. I hobbled over to my desk, reached for the flask in my pocket, and topped off my coffee with its contents. I had barely gotten settled in my chair when an officer burst through the door. Another body in the tunnels, an assistant this time. I grumbled and downed what was left of my joe. This stuff used to taste great when I was a rookie, but now it was like boiled dirt. I guess that's how the station changes you. I set the mug back down on my desk and lit my last cigar. My fingers instinctively sought out the comforting grip of the .44 snub in my coat as I stepped out into the bleak halls of the station. The case was not cold yet."

/datum/reagent/drink/coffee/detcoffee/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(!activated)
		if (M_NOIR in M.mutations)
			noir_set_by_us = 0
		else
			noir_set_by_us = 1
			M.dna.SetSEState(NOIRBLOCK, 1)
			genemutcheck(M, NOIRBLOCK)
			M.update_mutations()
		activated = 1

/datum/reagent/drink/coffee/detcoffee/reagent_deleted()
	if(..())
		return 1
	if(!holder)
		return
	var/mob/M =  holder.my_atom
	if (istype(M) && activated && noir_set_by_us)
		M.dna.SetSEState(NOIRBLOCK, 0)
		genemutcheck(M, NOIRBLOCK)
		M.update_mutations()

/datum/reagent/drink/coffee/etank
	name = "Recharger"
	id = ETANK
	description = "Regardless of how energized this coffee makes you feel, jumping against doors will still never be a viable way to open them."
	mug_icon_state = "etank"
	mug_name = "\improper Recharger"
	mug_desc = "Helps you get back on your feet after a long day of robot maintenance. Can also be used as a substitute for motor oil."

/datum/reagent/drink/cold/quantum
	name = "Nuka Cola Quantum"
	id = QUANTUM
	description = "Take the leap... enjoy a Quantum!"
	color = "#100800" //rgb: 16, 8, 0
	adj_sleepy = -2
	sport = SPORTINESS_SPORTS_DRINK

/datum/reagent/drink/cold/quantum/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.apply_radiation(2, RAD_INTERNAL)

/datum/reagent/drink/sportdrink
	name = "Sport Drink"
	id = SPORTDRINK
	description = "You like sports, and you don't care who knows."
	sport = SPORTINESS_SPORTS_DRINK
	color = "#CCFF66" //rgb: 204, 255, 51
	custom_metabolism =  0.01
	custom_plant_metabolism = HYDRO_SPEED_MULTIPLIER/5

/datum/reagent/citalopram
	name = "Citalopram"
	id = CITALOPRAM
	description = "Stabilizes the mind a little."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC"
	custom_metabolism = 0.01
	data = 0
	density = 1.01
	specheatcap = 3.88

/datum/reagent/citalopram/on_mob_life(var/mob/living/M as mob)
	if(..())
		return 1
	if(volume <= 0.1)
		if(data != -1)
			data = -1
			to_chat(M, "<span class='warning'>Your mind feels a little less stable...</span>")
	else
		if(world.time > data + 3000)
			data = world.time
			to_chat(M, "<span class='notice'>Your mind feels stable... a little stable.</span>")

/datum/reagent/paroxetine
	name = "Paroxetine"
	id = PAROXETINE
	description = "Stabilizes the mind greatly, but has a chance of adverse effects."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC"
	custom_metabolism = 0.01
	data = 0
	density = 1.19
	specheatcap = 3.99

/datum/reagent/paroxetine/on_mob_life(var/mob/living/M as mob)
	if(..())
		return 1
	if(volume <= 0.1)
		if(data != -1)
			data = -1
			to_chat(M, "<span class='warning'>Your mind feels much less stable.</span>")
	else
		if(world.time > data + 3000)
			data = world.time
			if(prob(90))
				to_chat(M, "<span class='notice'>Your mind feels much more stable.</span>")
			else
				to_chat(M, "<span class='warning'>Your mind breaks apart.</span>")
				M.hallucination += 200
	if(M.mind && M.mind.suiciding)
		M.mind.suiciding = FALSE
		to_chat(M, "<span class='numb'>Whoah... You feel like this life is worth living after all!</span>")

/datum/reagent/gravy
	name = "Gravy"
	id = GRAVY
	description = "Aww, come on Double D, I don't say 'gravy' all the time."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 10 * REAGENTS_METABOLISM
	color = "#E7A568"

/datum/reagent/gravy/on_mob_life(var/mob/living/M, var/alien)
	if(..())
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.name == "Vox")
			M.adjustToxLoss(-4 * REM) //chicken and gravy just go together

/datum/reagent/cheesygloop
	name = "Cheesy Gloop"
	id = CHEESYGLOOP
	description = "This fatty, viscous substance is found only within the cheesiest of cheeses. Has the potential to cause heart stoppage."
	reagent_state = REAGENT_STATE_SOLID
	color = "#FFFF00" //rgb: 255, 255, 0
	overdose_am = 5
	custom_metabolism = 0 //does not leave your body, clogs your arteries! puke or otherwise clear your system ASAP
	density = 0.14
	specheatcap = 0.7

/datum/reagent/cheesygloop/on_overdose(var/mob/living/M)
	M.adjustToxLoss(1)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/heart/damagedheart = H.get_heart()
		damagedheart.damage++

/datum/reagent/maplesyrup
	name = "Maple Syrup"
	id = MAPLESYRUP
	description = "Reddish brown Canadian maple syrup, perfectly sweet and thick. Nutritious and effective at healing."
	color = "#7C1C04"
	alpha = 200
	nutriment_factor = 20 * REAGENTS_METABOLISM

/datum/reagent/maplesyrup/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor
	M.adjustOxyLoss(-2 * REM)
	M.adjustToxLoss(-2 * REM)
	M.adjustBruteLoss(-3 * REM)
	M.adjustFireLoss(-3 * REM)

/datum/reagent/blockizine
	name = "Blockizine"
	id = BLOCKIZINE
	description = "Some type of material that preferentially binds to all possible chemical receptors in the body, but without any direct negative effects."
	reagent_state = REAGENT_STATE_LIQUID
	custom_metabolism = 0
	color = "#B0B0B0"

/datum/reagent/blockizine/on_mob_life(var/mob/living/carbon/human/H)
	if(..())
		return 1
	if(!data)
		data = world.time+3000
	if(world.time > data)
		holder.del_reagent(BLOCKIZINE,volume) //needs to be del_reagent, because metabolism is 0
		return

	if(istype(H) && volume >= 25)
		holder.isolate_reagent(BLOCKIZINE)
		volume = holder.maximum_volume
		holder.update_total()

/datum/reagent/fishbleach
	name = "Fish Bleach"
	id = FISHBLEACH
	description = "Just looking at this liquid makes you feel tranquil and peaceful. You aren't sure if you want to drink any however."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#12A7C9"

/datum/reagent/fishbleach/on_mob_life(var/mob/living/carbon/human/H)
	if(..())
		return 1
	H.color = "#12A7C9"
	return

/datum/reagent/roach_shell
	name = "Cockroach chitin"
	id = ROACHSHELL
	description = "Looks like somebody's been shelling peanuts."
	reagent_state = REAGENT_STATE_SOLID
	color = "#8B4513"

/datum/reagent/ethanol/drink/greyvodka
	name = "Greyshirt vodka"
	id = GREYVODKA
	description = "Made presumably from whatever scrapings you can get out of maintenance. Don't think, just drink."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#DEF7F5"
	alpha = 64
	glass_icon_state = "ginvodkaglass"
	glass_desc = "A questionable concoction of ingredients found within maintenance. Tastes just like you'd expect."

/datum/reagent/ethanol/drink/greyvodka/on_mob_life(var/mob/living/carbon/human/H)
	if(..())
		return 1
	H.radiation = max(H.radiation - 5 * REM, 0)
	H.rad_tick = max(H.rad_tick - 3 * REM, 0)

/datum/reagent/mediumcores
	name = "medium-salted cores"
	id = MEDCORES
	description = "A derivative of the chemical known as 'Hardcores', easier to mass produce, but at a cost of quality."
	reagent_state = REAGENT_STATE_SOLID
	color = "#FFA500"
	custom_metabolism = 0.1

/datum/reagent/softcores
	name = "softcores"
	id = SOFTCORES
	description = "Lesser known than its cheaper cousin in the popular snack 'mag-bites', softcores have all the benefits of chemical magnetism without the heart-stopping side effects."
	reagent_state = REAGENT_STATE_SOLID
	color = "#ff5100"
	custom_metabolism = 0.1

//Plant-specific reagents

/datum/reagent/kelotane/tannic_acid
	name = "Tannic acid"
	id = TANNIC_ACID
	description = "Tannic acid is a natural burn remedy."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#150A03" //rgb: 21, 10, 3

/datum/reagent/dermaline/kathalai
	name = "Kathalai"
	id = KATHALAI
	description = "Kathalai is an exceptional natural burn remedy, it performs twice as well as tannic acid."
	color = "#32BD08" //rgb: 50, 189, 8

/datum/reagent/bicaridine/opium
	name = "Opium"
	id = OPIUM
	description = "Opium is an exceptional natural analgesic."
	color = "#AE9260" //rgb: 174, 146, 96

/datum/reagent/space_drugs/mescaline
	name = "Mescaline"
	id = MESCALINE
	description = "Known to cause mild hallucinations, mescaline is often used recreationally."
	color = "#B8CD93" //rgb: 184, 205, 147

/datum/reagent/synaptizine/cytisine
	name = "Cytisine"
	id = CYTISINE
	description = "Cytisine is an alkaloid which mimics the effects of nicotine."
	color = "#A49B50" //rgb: 164, 155, 80

/datum/reagent/hyperzine/cocaine
	name = "Cocaine"
	id = COCAINE
	description = "Cocaine is a powerful nervous system stimulant."
	color = "#FFFFFF" //rgb: 255, 255, 255

/datum/reagent/imidazoline/zeaxanthin
	name = "Zeaxanthin"
	id = ZEAXANTHIN
	description = "Zeaxanthin is a natural pigment which purportedly supports eye health."
	color = "#CC4303" //rgb: 204, 67, 3

/datum/reagent/stoxin/valerenic_acid
	name = "Valerenic acid"
	id = VALERENIC_ACID
	description = "An herbal sedative used to treat insomnia."
	color = "#EAB160" //rgb: 234, 177, 96

/datum/reagent/sacid/formic_acid
	name = "Formic acid"
	id = FORMIC_ACID
	description = "A weak natural acid which causes a burning sensation upon contact."
	color = "#9B3D00" //rgb: 155, 61, 0

/datum/reagent/pacid/phenol
	name = "Phenol"
	id = PHENOL
	description = "Phenol is a corrosive acid which can cause chemical burns."
	color = "#C71839" //rgb: 199, 24, 57

/datum/reagent/ethanol/drink/neurotoxin/curare
	name = "Curare"
	id = CURARE
	description = "An alkaloid plant extract which causes weakness of the skeletal muscles."
	color = "#94DC76" //rgb: 148, 220, 118

/datum/reagent/toxin/solanine
	name = "Solanine"
	id = SOLANINE
	description = "A glycoalkaloid poison."
	color = "#6C8347" //rgb: 108, 131, 71

/datum/reagent/cryptobiolin/physostigmine
	name = "Physostigmine"
	id = PHYSOSTIGMINE
	description = "Physostigmine causes confusion and dizzyness."
	color = "#0098D7" //rgb: 0, 152, 215

/datum/reagent/impedrezene/hyoscyamine
	name = "Hyoscyamine"
	id = HYOSCYAMINE
	description = "Hyoscyamine is a tropane alkaloid which can disrupt the central nervous system."
	color = "#BBD0C9" //rgb: 187, 208, 201

/datum/reagent/lexorin/coriamyrtin
	name = "Coriamyrtin"
	id = CORIAMYRTIN
	description = "Coriamyrtin is a toxin which causes respiratory problems."
	color = "#FB6892" //rgb: 251, 104, 146

/datum/reagent/dexalin/thymol
	name = "Thymol"
	id = THYMOL
	description = "Thymol is used in the treatment of respiratory problems."
	color = "#790D27" //rgb: 121, 13, 39

/datum/reagent/synthocarisol/phytocarisol
	name = "Phytocarisol"
	id = PHYTOCARISOL
	description = "A plant based alternative to carisol, a medicine made from rhino horn dust."
	color = "#34D3B6" //rgb: 52, 211, 182

/datum/reagent/heartbreaker/defalexorin
	name = "Defalexorin"
	id = DEFALEXORIN
	description = "Defalexorin is used for getting a mild high in low amounts."
	color = "#000000" //rgb: 0, 0, 0

/datum/reagent/alkycosine/phytosine
	name = "Phytosine"
	id = PHYTOSINE
	description = "Neurological medication made from mutated herbs."
	color = "#9000ff" //rgb: 144, 0 255

//End of plant-specific reagents

//Petritricin = cockatrice juice
//Lore explanation for it affecting worn items (like hardsuits), but not items dropped on the ground that it was splashed over:
//Pure petritricin can stonify any matter, organic or unorganic. However, if it's outside of a living organism, it rapidly deterogates
//until it is only strong enough to affect organic matter.
//When introduced to organic matter, petritricin converts living cells to produce more of itself, and the freshly produced substance
//can affect items worn close enough to the body
/datum/reagent/petritricin
	name = "Petritricin"
	id = PETRITRICIN
	description = "Petritricin is a venom produced by cockatrices. The extraction process causes a major potency loss, but a right dose of this can still petrify somebody."
	color = "#002000" //rgb: 0, 32, 0
	dupeable = FALSE

	var/min_to_start = 1 //At least 1 unit is needed for petriication to start
	var/is_being_petrified = FALSE
	var/stage

/datum/reagent/petritricin/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(issilicon(M))
		return
	var/mob/living/carbon/C
	if(iscarbon(M))
		C = M
	if(volume >= min_to_start && !is_being_petrified)
		is_being_petrified = TRUE
	if(is_being_petrified)
		if(holder.has_any_reagents(PETRITRICINCURES))
			to_chat(M, "<span class='notice'>You feel a wave of relief as your muscles loosen up.</span>")
			C.pain_shock_stage = max(0, C.pain_shock_stage - 300)
			is_being_petrified = FALSE
			holder.del_reagent(PETRITRICIN)
			return
		switch(stage)
			if(1)
				//Second message is shown to hallucinating mobs
				M.simple_message("<span class='userdanger'>You are slowing down. Moving is extremely painful for you.</span>",\
				"<span class='notice'>You feel like Michelangelo di Lodovico Buonarroti Simoni trapped in a foreign body.</span>")
				if(istype(C))
					C.pain_shock_stage += 300
				M.audible_scream()
			if(2)
				M.simple_message("<span class='userdanger'>Your skin starts losing color and cracking. Your body becomes numb.</span>",\
				"<span class='notice'>You decide to channel your inner Italian sculptor to create a beautiful statue.</span>")
				M.Stun(3)
			if(3)
				if(M.turn_into_statue(1))
					M.simple_message("<span class='userdanger'>You have been turned to stone by ingesting petritricin.</span>",\
					"<span class='notice'>You've created a masterwork statue of David!</span>")
					is_being_petrified = FALSE
		stage = stage + 1





//A chemical for curing petrification. It only works after you've been fully petrified
//Items on corpses will survive the process, but the corpses itself will be damaged and uncloneable after unstoning
/datum/reagent/apetrine
	name = "Apetrine"
	id = APETRINE
	description = "Apetrine is a chemical used to partially reverse the post-mortem effects of petritricin."
	color = "#240080" //rgb: 36, 0, 128
	dupeable = FALSE
	density = 7.94
	specheatcap = 1.39

/datum/reagent/apetrine/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	if(istype(O, /obj/structure/closet/statue))
		var/obj/structure/closet/statue/statue = O
		statue.dissolve()
	if(istype(O, /obj/structure/mannequin))
		var/obj/structure/mannequin/statue = O
		statue.dissolve()


/datum/reagent/apetrine/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)
	if(..())
		return 1

	if(istype(M, /mob/living/simple_animal/hostile/mannequin))
		var/mob/living/simple_animal/hostile/mannequin/statue = M
		statue.dissolve()

/datum/reagent/hemoscyanine
	name = "Hemoscyanine"
	id = HEMOSCYANINE
	description = "Hemoscyanine is a toxin which can destroy blood cells."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#600000" //rgb: 96, 0, 0
	density = 11.53
	specheatcap = 0.22

/datum/reagent/hemoscyanine/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!(H.species.anatomy_flags & NO_BLOOD))
			H.vessel.remove_reagent(BLOOD, 2)

/datum/reagent/anthracene
	name = "Anthracene"
	id = ANTHRACENE
	description = "Anthracene is a fluorophore which emits a weak green glow."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#00ff00" //rgb: 0, 255, 0
	data = 0
	var/light_intensity = 4
	var/initial_color = null
	density = 3.46
	specheatcap = 512.3

/datum/reagent/anthracene/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(!data)
		initial_color = M.light_color
		M.light_color = LIGHT_COLOR_GREEN
		M.set_light(light_intensity)
		data++

/datum/reagent/anthracene/reagent_deleted()
	if(..())
		return 1

	if(!holder)
		return
	var/atom/A =  holder.my_atom
	A.light_color = initial_color
	A.kill_light()

/datum/reagent/anthracene/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)
	if(..())
		return 1

	if(method == TOUCH)
		var/init_color = M.light_color
		M.light_color = LIGHT_COLOR_GREEN
		M.set_light(light_intensity)
		spawn(volume * 10)
			M.light_color = init_color
			M.kill_light()

/datum/reagent/anthracene/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	var/init_color = T.light_color
	T.light_color = LIGHT_COLOR_GREEN
	T.set_light(light_intensity)
	spawn(volume * 10)
		T.light_color = init_color
		T.kill_light()

/datum/reagent/anthracene/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	var/init_color = O.light_color
	O.light_color = LIGHT_COLOR_GREEN
	O.set_light(light_intensity)
	spawn(volume * 10)
		O.light_color = init_color
		O.kill_light()

/datum/reagent/mucus
	name = "Mucus"
	id = MUCUS
	description = "A slippery aqueous secretion produced by, and covering, mucous membranes.  Problematic for Asthmatics."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#13BC5E"
	custom_metabolism = 0.01

/datum/reagent/mucus/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(M_ASTHMA in H.mutations)
			H.adjustOxyLoss(2)
			if(prob(30))
				H.emote("gasp", null, null, TRUE)

/datum/reagent/albuterol
	name = "Albuterol"
	id = ALBUTEROL
	description = "A bronchodilator that relaxes muscles in the airways and increases air flow to the lungs."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC"
	overdose_am = REAGENTS_OVERDOSE

/datum/reagent/albuterol/on_mob_life(var/mob/living/M)

	if(..())
		return 1
	if(holder.has_reagent(MUCUS))
		holder.remove_reagent(MUCUS, 10)

/datum/reagent/liquidbutter
	name ="Liquid Butter"
	id = LIQUIDBUTTER
	description = "A lipid heavy liquid, that's likely to make your fad lipozine diet fail."
	color = "#DFDFDF"
	nutriment_factor = 25 * REAGENTS_METABOLISM

/datum/reagent/liquidbutter/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(holder.has_reagent(LIPOZINE))
		holder.remove_reagent(LIPOZINE, 50)

	M.nutrition += nutriment_factor



/datum/reagent/saltwater
	name = "Salt Water"
	id = SALTWATER
	description = "It's water mixed with salt. It's probably not healthy to drink."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFFFFF" //rgb: 255, 255, 255
	density = 1.122
	specheatcap = 6.9036

/datum/reagent/saltwater/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(ishuman(M) && prob(20))
		var/mob/living/carbon/human/H = M
		H.vomit()
		M.adjustToxLoss(2 * REM)

/datum/reagent/saltwater/saline
	name = "Saline"
	id = SALINE
	description = "A solution composed of salt, water, and ammonia. Used in pickling and preservation"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#DEF7F5" //rgb: 192, 227, 233
	alpha = 64
	density = 0.622
	specheatcap = 99.27

/datum/reagent/calciumoxide
	name = "Calcium Oxide"
	id = CALCIUMOXIDE
	description = "Quicklime. Reacts strongly with water forming calcium hydrate and generating heat in the process"
	color = "#FFFFFF"
	density = 3.34
	specheatcap = 42.09

/datum/reagent/calciumoxide/on_mob_life(var/mob/living/M)

	if(..())
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if((H.species && H.species.flags & NO_BREATHE) || (M_NO_BREATH in H.mutations))
			return
		M.adjustFireLoss(0.5 * REM)
		if(prob(10))
			M.visible_message("<span class='warning'>[M] [pick("dry heaves!", "coughs!", "splutters!")]</span>")

/datum/reagent/calciumhydroxide
	name = "Calcium Hydroxide"
	id = CALCIUMHYDROXIDE
	description = "Hydrated lime, non-toxic."
	color = "#FFFFFF"
	density = 2.211
	specheatcap = 87.45

/datum/reagent/calciumcarbonate
	name = "Calcium Carbonate"
	id = CALCIUMCARBONATE
	description = "An odorless, fine, white micro-crystalline powder. Usually obtained by grinding limestone, or egg shells."
	color = "#FFFFFF"
	density = 2.73
	specheatcap = 83.43

/datum/reagent/sodium_silicate
	name = "Sodium Silicate"
	id = SODIUMSILICATE
	description = "A white powder, commonly used in cements."
	reagent_state = REAGENT_STATE_SOLID
	color = "#E5E5E5"
	density = 2.61
	specheatcap = 111.8

/datum/reagent/untable
	name = "Untable Mutagen"
	id = UNTABLE_MUTAGEN
	description = "Untable Mutagen is a substance that is inert to most materials and objects, but highly corrosive to tables."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#84121D" //rgb: 132, 18, 29
	overdose_am = REAGENTS_OVERDOSE

/datum/reagent/untable/reaction_obj(var/obj/O, var/volume)

	if(..())
		return 1

	if(!O.acidable())
		return

	if(istype(O,/obj/structure/table))
		var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
		I.desc = "Looks like this was \an [O] some time ago."
		O.visible_message("<span class='warning'>\The [O] melts.</span>")
		qdel(O)

/datum/reagent/colorful_reagent
	name = "Colorful Reagent"
	id = COLORFUL_REAGENT
	description = "Thoroughly sample the rainbow."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC"
	var/list/random_color_list = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")


/datum/reagent/colorful_reagent/on_mob_life(mob/living/M)
	if(M && isliving(M))
		M.color = pick(random_color_list)
	..()

/datum/reagent/colorful_reagent/reaction_mob(mob/living/M, reac_volume)
	if(M && isliving(M))
		M.color = pick(random_color_list)
	..()

/datum/reagent/colorful_reagent/reaction_obj(obj/O, reac_volume)
	if(O)
		O.color = pick(random_color_list)
	..()

/datum/reagent/colorful_reagent/reaction_turf(turf/T, reac_volume)
	if(T)
		T.color = pick(random_color_list)
	..()

/datum/reagent/degeneratecalcium
	name = "Degenerate calcium"
	id = DEGENERATECALCIUM
	description = "A highly radical chemical derived from calcium that aggressively attempts to regenerate osseus tissues it comes in contact with. In the presence of micro-fractures caused by extensive brute damage it rapidly heals the surrounding tissues, but in healthy limbs the new tissue quickly causes the osseal structure to lose shape and shatter rather graphically."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#ccffb3" //rgb: 204, 255, 179
	density = 3.9
	specheatcap = 128.12
	custom_metabolism = 0.1

/datum/reagent/degeneratecalcium/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.anatomy_flags & NO_BONES)
			return

		//if you have 30 or more brute damage: rapidly heals, makes your bones stronk
		//if you have less than 30 brute damage: rapidly heals, breaks all your bones one by one
		//(the rapid healing is likely to land you in that "less than 30" club real quick if you're not careful...)
		H.heal_organ_damage(3 * REM, 0)

		if(H.getBruteLoss(TRUE) >= 30)
			for(var/datum/organ/external/E in H.organs) //"organs" list only contains external organs aka limbs
				if((E.status & ORGAN_BROKEN) || !E.is_organic() || (E.min_broken_damage >= E.max_damage))
					continue
				E.min_broken_damage += rand(4,8) * REM
				if(E.min_broken_damage >= E.max_damage)
					E.min_broken_damage = E.max_damage
					to_chat(H, "Your [E.display_name] feels [pick("sturdy", "hardy")] as it can be!") //todo unfunny skeleton jokes (someone will probably comment them in the PR)
		else if(prob((100 - H.getBruteLoss() * 100 / 30)/3)) //33% at 0 damage, 16.6% at 15 damage, 1.1% at 29 damage etc
			var/datum/organ/external/E = pick(H.organs) //"organs" list only contains external organs aka limbs
			E.fracture()

/datum/reagent/aminomicin
	name = "Aminomicin"
	id = AMINOMICIN
	description = "An experimental and unstable chemical, said to be able to create life. Potential reaction detected if mixed with nutriment."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#634848" //rgb: 99, 72, 72
	density = 13.49 //our ingredients are pretty dense
	specheatcap = 208.4
	custom_metabolism = 0.01 //oh shit what are you doin

/datum/reagent/aminomician
	name = "Aminomician"
	id = AMINOMICIAN
	description = "An experimental and unstable chemical, said to be able to create companionship. Potential reaction detected if mixed with nutriment."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#634848" //rgb: 99, 72, 72
	density = 13.49 //our ingredients are pretty dense
	specheatcap = 208.4
	custom_metabolism = 0.01 //oh shit what are you doin

/datum/reagent/aminocyprinidol
	name = "Aminocyprinidol"
	id = AMINOCYPRINIDOL
	description = "An extremely dangerous, flesh-replicating material, mutated by exposure to God-knows-what. Do not mix with nutriment under any circumstances."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#cb42f4" //rgb: 203, 66, 244
	density = 111.75 //our ingredients are extremely dense, especially carppheromones
	specheatcap = ARBITRARILY_LARGE_NUMBER //Is partly made out of leporazine, so you're not heating this up.
	custom_metabolism = 0.01 //oh shit what are you doin

/datum/reagent/luminol
	name = "Luminol"
	id = LUMINOL
	description = "A chemical that exhibits chemiluminescence in the presence of blood due to the iron and copper in the hemoglobin."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFFFFF" //rgb: 255, 255, 255

/datum/reagent/luminol/reaction_mob(var/mob/living/M, var/method = TOUCH)
	if(ishuman(M) && (method == TOUCH))
		var/mob/living/carbon/human/H = M
		H.apply_luminol()

/datum/reagent/luminol/reaction_turf(var/turf/simulated/T)
	if(..())
		return TRUE
	T.apply_luminol()

/datum/reagent/luminol/reaction_obj(var/obj/O, var/volume)
	if(..())
		return TRUE
	O.apply_luminol()

/datum/reagent/ironrot
	name = "Ironrot"
	id = IRONROT
	description = "A mutated fungal compound that causes rapid rotting in iron infrastructures."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#005200" //moldy green

/datum/reagent/ironrot/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	if(volume >= 5 && T.can_thermite && istype(T, /turf/simulated/wall))
		var/turf/simulated/wall/W = T
		W.rot()

/datum/reagent/ironrot/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.adjustToxLoss(2 * REM)

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/chest/C = H.get_organ(LIMB_CHEST)
		for(var/datum/organ/internal/I in C.internal_organs)
			if(I.robotic == 2)
				I.take_damage(10, 0)//robo organs get damaged by ingested ironrot

/datum/reagent/ironrot/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)
	if(..())
		return 1

	if(method == TOUCH)
		if(issilicon(M))//borgs are hurt on touch by this chem
			M.adjustFireLoss(10)
			M.adjustBruteLoss(10)
//todo : mech and pod damage


/datum/reagent/diabeetusol
	name = "Diabeetusol"
	id = DIABEETUSOL
	description = "The mistaken byproduct of confectionery science. Targets the beta pancreatic cells, or equivalent, in carbon based life to not only cease insulin production but begin producing what medical science can only describe as 'the concept of obesity given tangible form'."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFFFFF" //rgb: 255, 255, 255
	nutriment_factor = 45 * REAGENTS_METABOLISM //This is maybe a little much
	sport = 0 //This will never come up but adding it made me smile
	density = 3 //He DENSE
	specheatcap = 0.55536
	overdose_am = 30
	custom_metabolism = 0.05

/datum/reagent/diabeetusol/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/heart/heart = H.internal_organs_by_name["heart"]
		var/static/list/chubbysound = list('sound/instruments/trombone/Eb3.mid', 'sound/instruments/trombone/Gb2.mid', 'sound/instruments/trombone/Bb3.mid')
		var/sugarUnits = H.reagents.get_reagent_amount(SUGAR)
		if(sugarUnits < volume)
			if(prob(volume*30))
				playsound(H, pick(chubbysound), 50, 1)
				H.confused += 2
				H.eye_blurry += 2
				H.dizziness += 2
			if(prob(volume*5))
				H.sleeping++
		else
			playsound(H, pick(chubbysound), 100, 1)
			H.overeatduration += 10 * volume
			H.nutrition += 10 * volume
		if(H.nutrition > 750)
			if(prob(volume) && heart && !heart.robotic)
				to_chat(H, "<span class='danger'>Your heart just can't take it anymore!</span>")
				qdel(H.remove_internal_organ(H,heart,H.get_organ(LIMB_CHEST)))
				H.adjustOxyLoss(60)
				H.adjustBruteLoss(30)


/datum/reagent/ectoplasm
	name = "Ectoplasm"
	id = ECTOPLASM
	description = "Pure, distilled spooky"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#21d389b4"
	density = 0.05

/datum/reagent/ectoplasm/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(isskellington(M) || isskelevox(M) || islich(M))	//Slightly better than DD for spooks
		playsound(M, 'sound/effects/rattling_bones.ogg', 100, 1)
		if(M.getOxyLoss())
			M.adjustOxyLoss(-3)
		if(M.getBruteLoss())
			M.heal_organ_damage(3, 0)
		if(M.getFireLoss())
			M.heal_organ_damage(0, 3)
		if(M.getToxLoss())
			M.adjustToxLoss(-3)
	else
		M.hallucination += 5	//50% mindbreaker

/datum/reagent/self_replicating
	id = EXPLICITLY_INVALID_REAGENT_ID
	var/whitelisted_ids = list()

/datum/reagent/self_replicating/post_transfer(var/datum/reagents/donor)
	..()
	holder.convert_all_to_id(id, whitelisted_ids)

/datum/reagent/self_replicating/on_introduced(var/data)
	..()
	holder.convert_all_to_id(id, whitelisted_ids)

/datum/reagent/self_replicating/midazoline
	name = "Midazoline"
	id = MIDAZOLINE
	description = "Chrysopoeia, the artificial production of gold, was one of the defining ambitions of ancient alchemy. Turns out, all it took was a little plasma. Converts all other reagents into Midazoline, except for Mercury, which will convert Midazoline into itself."
	reagent_state = REAGENT_STATE_SOLID
	color = "#F7C430" //rgb: 247, 196, 48
	density = 19.3
	specheatcap = 0.129
	whitelisted_ids = list(MERCURY)

/datum/reagent/temp_hearer/
	id = EXPLICITLY_INVALID_REAGENT_ID
	data = list("stored_phrase" = null)

/datum/reagent/temp_hearer/on_introduced(var/data)
	. = ..()
	var/obj/item/weapon/reagent_containers/RC = holder.my_atom
	if(!istype(RC))
		return
	if(!RC.virtualhearer)
		RC.addHear(/mob/virtualhearer/one_time)

/datum/reagent/temp_hearer/proc/parent_heard(var/datum/speech/speech, var/rendered_speech="")
	if(!data["stored_phrase"])
		set_phrase(sanitize(speech.message))
		var/atom/container = holder.my_atom
		if(container.is_open_container())
			container.visible_message("<span class='notice'>[bicon(container)] The solution fizzles for a moment.</span>", "You hear something fizzling for a moment.", "<span class='notice'>[bicon(container)] \The [container] replies something, but you can't hear them.</span>")
			if(!(container.flags & SILENTCONTAINER))
				playsound(container, 'sound/effects/bubbles.ogg', 20, -3)

/datum/reagent/temp_hearer/proc/set_phrase(var/phrase)
	data["stored_phrase"] = phrase

/datum/reagent/temp_hearer/locutogen
	name = "Locutogen"
	id = LOCUTOGEN
	description = "Sound-activated solution. Permanently stores the first soundwaves it 'hears' into a long polymer chain, which reacts into a crude form of speech into the ears of a live host. Tastes sweet."
	reagent_state = REAGENT_STATE_LIQUID
	custom_metabolism = 0.01
	color = "#8E18A9" //rgb: 142, 24, 169
	density = 1.58
	specheatcap = 1.44

/datum/reagent/temp_hearer/locutogen/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(!M.isUnconscious() && data["stored_phrase"])
		to_chat(M, "You hear a voice in your head saying: <span class='bold'>'[data["stored_phrase"]]'</span>.")
		M.reagents.del_reagent(LOCUTOGEN)

//////////////////////
//					//
//      INCENSE		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//					//
//////////////////////
/datum/reagent/incense
	id = EXPLICITLY_INVALID_REAGENT_ID
	reagent_state = REAGENT_STATE_GAS
	density = 3.214
	specheatcap = 1.34
	color = "#E0D3D3" //rgb: 224, 211, 211
	data = list("source" = null)

/datum/reagent/incense/on_introduced(var/data)
	..()
	if(!src.data["source"]) //src is necessary because of this terrible var name, but consistency!
		src.data["source"] = holder.my_atom

/datum/reagent/incense/proc/OnDisperse(var/turf/location)

/datum/reagent/incense/harebells//similar effects as holy water to cultists and vampires
	name = "Holy Incense"
	id = INCENSE_HAREBELLS
	description = "An incense used in holy rituals. Can be used to impede the occult."

/datum/reagent/incense/poppies//similar effects as chill wax and paracetamol
	name = "Opium Incense"
	id = INCENSE_POPPIES
	description = "A pleasing fragrance that soothes the nerves and removes pain."
	pain_resistance = 60
	custom_metabolism = 0.15

/datum/reagent/incense/poppies/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.pain_level < BASE_CARBON_PAIN_RESIST)
			C.pain_shock_stage--
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.druggy = max(H.druggy, 5)
			H.Dizzy(2)
			if(prob(5))
				H.emote(pick("stare", "giggle"), null, null, TRUE)
			if(prob(5))
				to_chat(H, "<span class='notice'>[pick("You feel at peace with the world.","Everyone is nice, everything is awesome.","You feel high and ecstatic.")]</span>")
			if(prob(2))
				to_chat(H, "<span class='notice'>You doze off for a second.</span>")
				H.sleeping += 1

/datum/reagent/incense/sunflowers//flavor text, does nothing
	name = "Incense"
	id = INCENSE_SUNFLOWERS
	description = "While it smells really nice, incense is known to increase the risk of lung cancer."

/datum/reagent/incense/mustardplant //same as sunflower, no connection to mustard gas
	name = "Mustardplant Incense"
	id = INCENSE_MUSTARDPLANT
	description = "A sweet scent with a tinge of clover." //i have no idea what these smell like, im going off of forum posts, if anyone does know please edit the desc

/datum/reagent/incense/moonflowers//Basically mindbreaker
	name = "Hallucinogenic Incense"
	id = INCENSE_MOONFLOWERS
	description = "This fragrance is so unsettling that it makes you question reality."
	custom_metabolism = 0.15

/datum/reagent/incense/moonflowers/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if (M.hallucination < 22)
		M.hallucination += 10

/datum/reagent/incense/novaflowers//Converts itself to hyperzine, but makes you hungry
	name = "Hyperactivity Incense"
	id = INCENSE_NOVAFLOWERS
	description = "This fragrance helps you focus and pull into your energy reserves to move quickly."
	custom_metabolism = 0.15

/datum/reagent/incense/novaflowers/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(holder.get_reagent_amount(HYPERZINE) < 2)
		holder.add_reagent(HYPERZINE, 0.5)
	M.nutrition--

/datum/reagent/incense/banana
	name = "Banana Incense"
	id = INCENSE_BANANA
	description = "This fragrance helps you be more clumsy, so you can laugh at yourself."

/datum/reagent/incense/banana/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(prob(5))
		to_chat(M,"<span class='warning'>[pick("You feel like giggling!", "You feel clumsy!", "You want to honk!")]</span>")

/datum/reagent/incense/cabbage
	name = "Leafy Incense"
	id = INCENSE_LEAFY
	description = "This fragrance smells of fresh greens, delicious to most animals."

/datum/reagent/incense/cabbage/reagent_deleted()
	if(..())
		return 1
	if(!holder)
		return
	var/mob/M =  holder.my_atom
	walk(M,0) //Cancel walk if it ran out

/datum/reagent/incense/cabbage/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(isanimal(M) || ismonkey(M))
		if(istype(M,/mob/living/simple_animal/hostile))
			var/mob/living/simple_animal/hostile/H = M
			switch(H.stance)
				if(HOSTILE_STANCE_ATTACK,HOSTILE_STANCE_ATTACKING)
					if(istype(M,/mob/living/simple_animal/hostile/retaliate/goat))
						var/mob/living/simple_animal/hostile/retaliate/goat/G = M
						G.Calm()
					else
						return
		M.start_walk_to(get_turf(data["source"]),1,6)

/datum/reagent/incense/booze
	name = "Alcoholic Incense"
	id = INCENSE_BOOZE
	description = "This fragrance is dense with the odor of ethanol."

/datum/reagent/incense/booze/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(M.slurring < 22)
		M.slurring += 10
	if(M.eye_blurry < 22)
		M.eye_blurry += 10

/datum/reagent/incense/vapor
	name = "Airy Incense"
	id = INCENSE_VAPOR
	description = "It burns your nostrils a little. The incense smells... clean."

/datum/reagent/incense/vapor/OnDisperse(var/turf/location)
	for(var/turf/simulated/T in view(2,location))
		if(T.is_wet())
			T.dry(TURF_WET_LUBE)
			T.turf_animation('icons/effects/water.dmi',"dry_floor",0,0,TURF_LAYER)

/datum/reagent/incense/dense
	name = "Dense Incense"
	id = INCENSE_DENSE
	description = "This isn't really a fragrance so much as tactical smoke."
	custom_metabolism = 0.25

/datum/reagent/incense/dense/OnDisperse(var/turf/location)
	var/datum/effect/system/smoke_spread/smoke = new /datum/effect/system/smoke_spread()
	smoke.set_up(2, 0, location) //Make 2 drifting clouds of smoke, direction
	smoke.start()

/datum/reagent/incense/dense/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(prob(5))
		M.visible_message("<span class='warning'>[M] [pick("dry heaves!", "coughs!", "splutters!")]</span>")

/datum/reagent/incense/vale
	name = "Sporty Incense"
	id = INCENSE_CRAVE
	description = "This has what you crave. Electrolytes."
	sport = SPORTINESS_SPORTS_DRINK
	custom_metabolism = 0.15

/datum/reagent/incense/cornoil
	name = "Corn Oil Incense"
	id = INCENSE_CORNOIL
	description = "This fragrance reminds you of a nice home-cooked meal, and sometimes even feels like it fills you up."

/datum/reagent/incense/cornoil/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(prob(5))
		to_chat(M,"<span class='warning'>[pick("You feel fuller.", "You no longer feel snackish.")]</span>")
		M.reagents.add_reagent(NUTRIMENT, 2)

/datum/reagent/dsyrup
	name = "Delightful Mix"
	id = DSYRUP
	description = "This syrupy stuff is everyone's favorite tricord additive."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#571212" //like a dark red
	density = 1.00 //basically water
	specheatcap = 4.184
