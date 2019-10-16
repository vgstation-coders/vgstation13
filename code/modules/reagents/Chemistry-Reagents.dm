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
	var/list/data = null
	var/volume = 0
	var/nutriment_factor = 0
	var/pain_resistance = 0
	var/sport = 1 //High sport helps you show off on a treadmill. Multiplicative
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

/datum/reagent/proc/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)
	set waitfor = 0

	if(!holder)
		return 1
	if(!istype(M))
		return 1

	var/datum/reagent/self = src //Note : You need to declare self again (before the parent call) to use it in your chemical, see blood
	src = null

	//If the chemicals are in a smoke cloud, do not let the chemicals "penetrate" into the mob's system (balance station 13) -- Doohl
	if(self.holder && !istype(self.holder.my_atom, /obj/effect/effect/smoke/chem))
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

			if(prob(chance) && !block)
				if(M.reagents)
					M.reagents.add_reagent(self.id, self.volume/2) //Hardcoded, transfer half of volume

	if (M.mind)
		for (var/role in M.mind.antag_roles)
			var/datum/role/R = M.mind.antag_roles[role]
			R.handle_splashed_reagent(self.id)

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

/datum/reagent/proc/on_move(var/mob/M)
	return

//Called after add_reagents creates a new reagent
/datum/reagent/proc/on_introduced(var/data)
	return

//Called when two reagents are mixing
/datum/reagent/proc/on_merge(var/data)
	return

/datum/reagent/proc/on_update(var/atom/A)
	return

/datum/reagent/proc/on_removal(var/data)
	return 1

/datum/reagent/proc/on_overdose(var/mob/living/M)
	M.adjustToxLoss(1)

/datum/reagent/proc/OnTransfer()
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

	spawn(duration + 1)
		var/datum/reagents/R = holder
		R.reagent_list.Add(src)

/datum/reagent/Destroy()
	if(istype(holder))
		holder.reagent_list -= src
		holder = null
	..()

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

	data = list(
		"donor"= null,
		"viruses" = null,
		"blood_DNA" = null,
		"blood_type" = null,
		"blood_colour" = DEFAULT_BLOOD,
		"resistances" = null,
		"trace_chem" = null,
		"virus2" = null,
		"immunity" = null,
		)

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
			H.bloody_body(self.data["donor"])
			if(self.data["donor"])
				H.bloody_hands(self.data["donor"])
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

/datum/reagent/blood/on_merge(var/data)
	if(data["blood_colour"])
		color = data["blood_colour"]
	return ..()

/datum/reagent/blood/on_update(var/atom/A)
	if(data["blood_colour"])
		color = data["blood_colour"]
	return ..()

/datum/reagent/blood/reaction_turf(var/turf/simulated/T, var/volume) //Splash the blood all over the place

	var/datum/reagent/self = src
	if(..())
		return TRUE

	if(volume < 3) //Hardcoded
		return
//	WHY WAS THIS MAKING 2 SPLATTERS? Awfully hardcoded, no need to exist, and this is completely broken colorwise
//
	//var/datum/disease/D = self.data["virus"]
//	if(!self.data["donor"] || ishuman(self.data["donor"]))
//		var/obj/effect/decal/cleanable/blood/blood_prop = locate() in T //Find some blood here
//		if(!blood_prop) //First blood
//			blood_prop = getFromPool(/obj/effect/decal/cleanable/blood, T)
//			blood_prop.New(T)
//			blood_prop.blood_DNA[self.data["blood_DNA"]] = self.data["blood_type"]
//
//		for(var/datum/disease/D in self.data["viruses"])
//			var/datum/disease/newVirus = D.Copy(1)
//			blood_prop.viruses += newVirus
//

	if(!self.data["donor"] || ishuman(self.data["donor"]))
		blood_splatter(T, self, 1)
	else if(ismonkey(self.data["donor"]))
		var/obj/effect/decal/cleanable/blood/B = blood_splatter(T, self, 1)
		if(B)
			B.blood_DNA["Non-Human DNA"] = "A+"
	else if(isalien(self.data["donor"]))
		var/obj/effect/decal/cleanable/blood/B = blood_splatter(T, self, 1)
		if(B)
			B.blood_DNA["UNKNOWN DNA STRUCTURE"] = "X*"
	T.had_blood = TRUE
	if(volume >= 5 && !istype(T.loc, /area/chapel)) //Blood desanctifies non-chapel tiles
		T.holy = 0
	return

/datum/reagent/blood/on_removal(var/data)
	if(holder && holder.my_atom)
		var/mob/living/carbon/human/H = holder.my_atom
		if(istype(H))
			if(H.species && H.species.anatomy_flags & NO_BLOOD)
				return 0
	return 1

/datum/reagent/blood/reaction_obj(var/obj/O, var/volume)

	if(..())
		return 1

	if(istype(O, /obj/item/clothing/mask/stone))
		var/obj/item/clothing/mask/stone/S = O
		S.spikes()

/datum/reagent/water
	name = "Water"
	id = WATER
	description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#DEF7F5" //rgb: 192, 227, 233
	alpha = 128
	specheatcap = 4.184
	density = 1

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
	name = "Anti-Toxin (Dylovene)"
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
	if(holder.has_any_reagents(list(TOXIN, PLANTBGONE, SOLANINE)))
		holder.remove_reagents(list(TOXIN, PLANTBGONE, SOLANINE), 2 * REM)
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
			human.set_species("Evolved Slime")

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
	color = "#0064C8" //rgb: 0, 100, 200
	custom_metabolism = 2 //High metabolism to prevent extended uncult rolls. Approx 5 units per roll
	specheatcap = 4.183

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
		if(istype(M,/mob/living/simple_animal/construct))
			var/mob/living/simple_animal/construct/C = M
			C.purge = 3
			C.adjustBruteLoss(5)
			C.visible_message("<span class='danger'>The holy water erodes \the [src].</span>")

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
		if((H.species && H.species.flags & NO_BREATHE) || M_NO_BREATH in H.mutations)
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
	sport = 1.2
	density = 1.59
	specheatcap = 1.244

/datum/reagent/sugar/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += REM

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
		var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(get_turf(O))
		I.desc = "Looks like this was \an [O] some time ago."
		O.visible_message("<span class='warning'>\The [O] melts.</span>")
		qdel(O)
	else if(istype(O,/obj/effect/plantsegment))
		var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(get_turf(O))
		I.desc = "Looks like these were some [O.name] some time ago."
		var/obj/effect/plantsegment/K = O
		K.die_off()
	else if(istype(O,/obj/effect/dummy/chameleon))
		var/obj/effect/dummy/chameleon/projection = O
		projection.disrupt()

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

/datum/reagent/radium
	name = "Radium"
	id = RADIUM
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = REAGENT_STATE_SOLID
	color = "#669966" //rgb: 102, 153, 102
	density = 5
	specheatcap = 94

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
		var/obj/effect/effect/smoke/S = new /obj/effect/effect/smoke(T)
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
		getFromPool(/obj/effect/decal/cleanable/liquid_fuel, T, volume)

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
			getFromPool(/obj/effect/decal/cleanable/vomit, T)

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
	if(istype(O, /obj/effect/decal/cleanable))
		qdel(O)
	else if(O.color && istype(O, /obj/item/weapon/paper))
		O.color = null

/datum/reagent/space_cleaner/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	if(volume >= 1)
		T.clean_blood()
		for(var/obj/effect/decal/cleanable/C in src)
			qdel(C)

		for(var/mob/living/carbon/slime/M in T)
			M.adjustToxLoss(rand(5, 10))

		for(var/mob/living/carbon/human/H in T)
			if(isslimeperson(H))
				H.adjustToxLoss(rand(5, 10)/10)

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

/datum/reagent/fertilizer/left4zed
	name = "Left-4-Zed"
	id = LEFT4ZED
	description = "A cocktail of mutagenic compounds, which cause plant life to become highly unstable."
	color = "#5B406C" // rgb: 91, 64, 108
	density = 1.32
	specheatcap = 0.60

/datum/reagent/fertilizer/robustharvest
	name = "Robust Harvest"
	id = ROBUSTHARVEST
	description = "Plant-enhancing hormones, good for increasing potency."
	color = "#3E901C" // rgb: 62, 144, 28
	density = 1.32
	specheatcap = 0.60

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
	if(isplasmaman(H))
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

/datum/reagent/clonexadone
	name = "Clonexadone"
	id = CLONEXADONE
	description = "A liquid compound similar to that used in the cloning process. Can be used to 'finish' the cloning process when used in conjunction with a cryo tube."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = 1.22
	specheatcap = 4.27

/datum/reagent/clonexadone/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.bodytemperature < 170)
		M.adjustCloneLoss(-3)
		M.adjustOxyLoss(-3)
		M.heal_organ_damage(3,3)
		M.adjustToxLoss(-3)

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
	if(holder.has_any_reagents(list(TOXIN, PLANTBGONE, SOLANINE)))
		holder.remove_reagents(list(TOXIN, PLANTBGONE, SOLANINE), 2 * REM)
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
				temp.clamp()

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
	var/diseasetype = /datum/disease/robotic_transformation
/datum/reagent/nanites/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)

	if(..())
		return 1

	if((prob(10) && method == TOUCH) || method == INGEST)
		M.contract_disease(new diseasetype, 1)

/datum/reagent/nanites/autist
	name = "Autist nanites"
	id = AUTISTNANITES
	diseasetype = /datum/disease/robotic_transformation/mommi

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
		M.contract_disease(new /datum/disease/xeno_transformation(0), 1)

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
		M.confused = max(0, M.confused - 5)
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

	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.confused = 0

//Otherwise known as a "Mickey Finn"
/datum/reagent/chloralhydrate
	name = "Chloral Hydrate"
	id = CHLORALHYDRATE
	description = "A powerful sedative."
	reagent_state = REAGENT_STATE_SOLID
	color = "#000067" //rgb: 0, 0, 103
	data = 1 //Used as a tally
	flags = CHEMFLAG_DISHONORABLE // NO CHEATING
	density = 11.43
	specheatcap = 13.79

/datum/reagent/chloralhydrate/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	switch(data)
		if(1)
			M.confused += 2
			M.drowsyness += 2
		if(2 to 80)
			M.sleeping++
		if(81 to INFINITY)
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

/datum/reagent/capsaicin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

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
				H << "<span class='danger'>You are sprayed directly in the eyes with pepperspray!</span>"
				H.eye_blurry = max(M.eye_blurry, 25)
				H.eye_blind = max(M.eye_blind, 10)
				H.Paralyse(1)
				H.drop_item()

/datum/reagent/condensedcapsaicin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(5))
		M.visible_message("<span class='warning'>[M] [pick("dry heaves!", "coughs!", "splutters!")]</span>")

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
	color = "#B31008" //rgb: 139, 166, 233
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

/datum/reagent/sodiumchloride/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	var/list/borers = M.get_brain_worms()
	if(borers)
		for(var/mob/living/simple_animal/borer/B in borers)
			B.health -= 1
			to_chat(B, "<span class='warning'>Something in your host's bloodstream burns you!</span>")

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
	name = "carp pheromones"
	id = CARPPHEROMONES
	description = "A disgusting liquid with a horrible smell, which is used by space carps to mark their territory and food."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6AAA96" //rgb: 106, 170, 150
	custom_metabolism = 0.1
	data = 1 //Used as a tally
	density = 109.06
	specheatcap = ARBITRARILY_LARGE_NUMBER //Contains leporazine, better this than 6 digits

/datum/reagent/carp_pheromones/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	data++

	var/stench_radius = Clamp(data * 0.1, 1, 6) //Stench starts out with 1 tile radius and grows after every 10 life ticks

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
	//rgb: 0, 0, 0

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

/datum/reagent/hot_coco
	name = "Hot Chocolate"
	id = HOT_COCO
	description = "Made with love! And coco beans."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#403010" //rgb: 64, 48, 16

/datum/reagent/hot_coco/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.bodytemperature < 310) //310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))

	M.nutrition += nutriment_factor

/datum/reagent/hot_coco/subhuman
	id = HOT_COCO_SUBHUMAN
	description = "Made with hate! And coco beans."
	data = 0

/datum/reagent/hot_coco_subhuman/on_mob_life(var/mob/living/M)
	..()
	if(prob(1))
		to_chat(M, "<span class='notice'>You are suddenly reminded that you are subhuman.</span>")

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

/datum/reagent/cornoil/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor

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

/datum/reagent/tomato_soup
	name = "Tomato Soup"
	id = TOMATO_SOUP
	description = "Water, tomato extract, and maybe some other stuff."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#731008" //rgb: 115, 16, 8
	density = 0.63
	specheatcap = 4.21

/datum/reagent/tomato_soup/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor
	if(M.bodytemperature < 310) //310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))

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

/datum/reagent/irradiatedbeans
	name = "Irradiated Beans"
	id = IRRADIATEDBEANS
	description = "You can almost taste the lead sheet behind it!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/toxicwaste
	name = "Toxic Waste"
	id = TOXICWASTE
	description = "A type of sludge."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do
	density = 5.59
	specheatcap = 2.71

/datum/reagent/refriedbeans
	name = "Re-Fried Beans"
	id = REFRIEDBEANS
	description = "Mmm.."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/mutatedbeans
	name = "Mutated Beans"
	id = MUTATEDBEANS
	description = "Mutated flavor."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/beff
	name = "Beff"
	id = BEFF
	description = "What's beff? Find out!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/horsemeat
	name = "Horse Meat"
	id = HORSEMEAT
	description = "Tastes excellent in lasagna."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/moonrocks
	name = "Moon Rocks"
	id = MOONROCKS
	description = "We don't know much about it, but we damn well know that it hates the human skeleton."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/offcolorcheese
	name = "Off-Color Cheese"
	id = OFFCOLORCHEESE
	description = "American Cheese."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/bonemarrow
	name = "Bone Marrow"
	id = BONEMARROW
	description = "Looks like a skeleton got stuck in the production line."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/greenramen
	name = "Greenish Ramen Noodles"
	id = GREENRAMEN
	description = "That green isn't organic."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/glowingramen
	name = "Glowing Ramen Noodles"
	id = GLOWINGRAMEN
	description = "That glow 'aint healthy."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

/datum/reagent/deepfriedramen
	name = "Deep Fried Ramen Noodles"
	id = DEEPFRIEDRAMEN
	description = "Ramen, deep fried."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 255,255,255 //to-do

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

/datum/reagent/drink/orangejuice/on_mob_life(var/mob/living/M)

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

/datum/reagent/drink/tomatojuice/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.getFireLoss() && prob(20))
		M.heal_organ_damage(0, 1)

/datum/reagent/drink/limejuice
	name = "Lime Juice"
	id = LIMEJUICE
	description = "The sweet-sour juice of limes."
	color = "#BBB943" //rgb: 187, 185, 67
	alpha = 170
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/limejuice/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1)

/datum/reagent/drink/carrotjuice
	name = "Carrot juice"
	id = CARROTJUICE
	description = "It's like a carrot, but less crunchy."
	color = "#973800" //rgb: 151, 56, 0
	nutriment_factor = 5 * REAGENTS_METABOLISM
	data = 1 //Used as a tally

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
	color = "#863333" //rgb: 134, 51, 51
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/poisonberryjuice
	name = "Poison Berry Juice"
	id = POISONBERRYJUICE
	description = "A surprisingly tasty juice blended from various kinds of very deadly and toxic berries."
	color = "#863353" //rgb: 134, 51, 83

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
	color = "#C6BB6E" //rgb: 198, 187, 110
	alpha = 170
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/banana
	name = "Banana Juice"
	id = BANANA
	description = "The raw essence of a banana."
	color = "#FFEBC1" //rgb: 255, 235, 193
	alpha = 255
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/nothing
	name = "Nothing"
	id = NOTHING
	description = "Absolutely nothing."
	nutriment_factor = 0

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

/datum/reagent/drink/milk
	name = "Milk"
	id = MILK
	description = "An opaque white liquid produced by the mammary glands of mammals."
	color = "#DFDFDF" //rgb: 223, 223, 223
	alpha = 240
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/milk/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.getBruteLoss() && prob(20))
		M.heal_organ_damage(1, 0)
	if(holder.has_reagent("capsaicin"))
		holder.remove_reagent("capsaicin", 10 * REAGENTS_METABOLISM)
	if(prob(50))
		M.heal_organ_damage(1, 0)

/datum/reagent/drink/milk/soymilk
	name = "Soy Milk"
	id = SOYMILK
	description = "An opaque white liquid made from soybeans."
	color = "#DFDFC7" //rgb: 223, 223, 199
	nutriment_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/drink/milk/cream
	name = "Cream"
	id = CREAM
	description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
	color = "#DFD7AF" //rgb: 223, 215, 175
	nutriment_factor = 5 * REAGENTS_METABOLISM
	density = 2.37
	specheatcap = 1.38

/datum/reagent/drink/hot_coco
	name = "Hot Chocolate"
	id = HOT_COCO
	description = "Made with love! And cocoa beans."
	nutriment_factor = 2 * FOOD_METABOLISM
	color = "#403010" //rgb: 64, 48, 16
	adj_temp = 5
	density = 1.2
	specheatcap = 4.18

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

/datum/reagent/drink/coffee/soy_latte
	name = "Soy Latte"
	id = SOY_LATTE
	description = "The hipster version of the classic cafe latte."
	color = "#664300" //rgb: 102, 67, 0
	adj_sleepy = 0
	adj_temp = 5

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

/datum/reagent/drink/tea/arnoldpalmer
	name = "Arnold Palmer"
	id = ARNOLDPALMER
	description = "Known as half and half to some. A mix of ice tea and lemonade."
	color = "#104038" //rgb: 16, 64, 56
	adj_temp = -5
	adj_sleepy = -3
	adj_dizzy = -1
	adj_drowsy = -3

/datum/reagent/drink/kahlua
	name = "Kahlua"
	id = KAHLUA
	description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
	color = "#664300" //rgb: 102, 67, 0
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2

/datum/reagent/drink/kahlua/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.Jitter(5)

/datum/reagent/drink/cold
	name = "Cold drink"
	adj_temp = -5

/datum/reagent/drink/cold/tonic
	name = "Tonic Water"
	id = TONIC
	description = "It tastes strange but at least the quinine keeps the space malaria at bay."
	color = "#664300" //rgb: 102, 67, 0
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2

/datum/reagent/drink/cold/sodawater
	name = "Soda Water"
	id = SODAWATER
	description = "Effervescent water used in many cocktails and drinks."
	color = "#619494" //rgb: 97, 148, 148
	adj_dizzy = -5
	adj_drowsy = -3

/datum/reagent/drink/cold/ice
	name = "Ice"
	id = ICE
	description = "Frozen water. Your dentist wouldn't like you chewing this."
	reagent_state = REAGENT_STATE_SOLID
	color = "#619494" //rgb: 97, 148, 148
	density = 0.91
	specheatcap = 4.18

/datum/reagent/drink/cold/space_cola
	name = "Cola"
	id = COLA
	description = "A refreshing beverage."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#100800" //rgb: 16, 8, 0
	adj_drowsy 	= 	-3

/datum/reagent/drink/cold/nuka_cola
	name = "Nuka Cola"
	id = NUKA_COLA
	description = "Cola. Cola never changes."
	color = "#100800" //rgb: 16, 8, 0
	adj_sleepy = -2
	density = 4.17
	specheatcap = 124

/datum/reagent/drink/cold/nuka_cola/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.Jitter(20)
	M.druggy = max(M.druggy, 30)
	M.dizziness += 5
	M.drowsyness = 0

/datum/reagent/drink/cold/spacemountainwind
	name = "Space Mountain Wind"
	id = SPACEMOUNTAINWIND
	description = "Blows right through you like a space wind."
	color = "#102000" //rgb: 16, 32, 0
	adj_drowsy = -7
	adj_sleepy = -1

/datum/reagent/drink/cold/dr_gibb
	name = "Dr. Gibb"
	id = DR_GIBB
	description = "A delicious blend of 42 different flavors."
	color = "#102000" //rgb: 16, 32, 0
	adj_drowsy = -6

/datum/reagent/drink/cold/space_up
	name = "Space-Up"
	id = SPACE_UP
	description = "Tastes like a hull breach in your mouth."
	color = "#202800" //rgb: 32, 40, 0
	adj_temp = -8

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

/datum/reagent/drink/cold/kiraspecial
	name = "Kira Special"
	description = "Long live the guy who everyone had mistaken for a girl. Baka!"
	id = KIRASPECIAL
	color = "#CCCC99" //rgb: 204, 204, 153

/datum/reagent/drink/cold/brownstar
	name = "Brown Star"
	description = "Its not what it sounds like..."
	id = BROWNSTAR
	color = "#9F3400" //rgb: 159, 052, 000
	adj_temp = -2

/datum/reagent/drink/cold/milkshake
	name = "Milkshake"
	description = "Glorious brainfreezing mixture."
	id = MILKSHAKE
	color = "#AEE5E4" //rgb" 174, 229, 228
	adj_temp = -9
	custom_metabolism = FOOD_METABOLISM
	data = 1 //Used as a tally

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

/datum/reagent/ethanol/beer/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.jitteriness = max(M.jitteriness - 3, 0)

/datum/reagent/ethanol/whiskey
	name = "Whiskey"
	id = WHISKEY
	description = "A superb and well-aged single-malt whiskey. Damn."
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 4
	pass_out = 225

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

/datum/reagent/ethanol/absinthe
	name = "Absinthe"
	id = ABSINTHE
	description = "Watch out that the Green Fairy doesn't get you!"
	color = "#33EE00" //rgb: lots, ??, ??
	dizzy_adj = 5
	slur_start = 25
	confused_start = 100
	pass_out = 175

//Copy paste from LSD... shoot me
/datum/reagent/ethanol/absinthe/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	data++
	M.hallucination += 5

/datum/reagent/ethanol/rum
	name = "Rum"
	id = RUM
	description = "Yohoho and all that."
	color = "#664300" //rgb: 102, 67, 0
	pass_out = 250

/datum/reagent/ethanol/tequila
	name = "Tequila"
	id = TEQUILA
	description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty, hombre?"
	color = "#FFFF91" //rgb: 255, 255, 145

/datum/reagent/ethanol/vermouth
	name = "Vermouth"
	id = VERMOUTH
	description = "You suddenly feel a craving for a martini..."
	color = "#91FF91" //rgb: 145, 255, 145

/datum/reagent/ethanol/wine
	name = "Wine"
	id = WINE
	description = "A premium alcoholic beverage made from fermented grape juice."
	color = "#7E4043" //rgb: 126, 64, 67
	dizzy_adj = 2
	slur_start = 65
	confused_start = 145

/datum/reagent/ethanol/bwine
	name = "Berry Wine"
	id = BWINE
	description = "Sweet berry wine!"
	color = "#C760A2" //rgb: 199, 96, 162
	dizzy_adj = 2
	slur_start = 65
	confused_start = 145

/datum/reagent/ethanol/wwine
	name = "White Wine"
	id = WWINE
	description = "A premium alcoholic beverage made from fermented green grape juice."
	color = "#C6C693" //rgb: 198, 198, 147
	dizzy_adj = 2
	slur_start = 65
	confused_start = 145

/datum/reagent/ethanol/plumphwine
	name = "Plump Helmet Wine"
	id = PLUMPHWINE
	description = "A very peculiar wine made from fermented plump helmet mushrooms. Popular among asteroid dwellers."
	color = "#800080" //rgb: 128, 0, 128
	dizzy_adj = 3 //dorf wine is a bit stronger than regular stuff
	slur_start = 60
	confused_start = 135

/datum/reagent/ethanol/cognac
	name = "Cognac"
	id = COGNAC
	description = "A sweet and strongly alcoholic drink, twice distilled and left to mature for several years. Classy as fornication."
	color = "#AB3C05" //rgb: 171, 60, 5
	dizzy_adj = 4
	confused_start = 115

/datum/reagent/ethanol/hooch
	name = "Hooch"
	id = HOOCH
	description = "A suspiciously viscous off-brown liquid that reeks of fuel. Do you really want to drink that?"
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 6
	slurr_adj = 5
	slur_start = 35
	confused_start = 90

/datum/reagent/ethanol/ale
	name = "Ale"
	id = ALE
	description = "A dark alcoholic beverage made from malted barley and yeast."
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/pwine
	name = "Poison Wine"
	id = PWINE
	description = "Is this even wine? Toxic, hallucinogenic, foul-tasting... Why would you drink this?"
	color = "#000000" //rgb: 0, 0, 0
	dizzy_adj = 1
	slur_start = 1
	confused_start = 1

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

/datum/reagent/ethanol/rags_to_riches/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(!M.loc || prob(70))
		return
	playsound(get_turf(M), pick('sound/items/polaroid1.ogg','sound/items/polaroid2.ogg'), 50, 1)
	dispense_cash(rand(5,15),get_turf(M))

/datum/reagent/ethanol/bad_touch
	name = "Bad Touch"
	id = BAD_TOUCH
	description = "On the scale of bad touches, somewhere between 'fondled by clown' and 'brushed by supermatter shard'."
	color = "#664300"

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
				I.plane = METABUDDY_HUD_PLANE
				M.current.client.images += I
				var/image/J = image('icons/mob/HUD.dmi', loc = imagelocB, icon_state = "metaclub")
				J.plane = METABUDDY_HUD_PLANE
				new_buddy.current.client.images += J

/datum/reagent/ethanol/waifu
	name = "Waifu"
	id = WAIFU
	description = "Don't drink more than one waifu if you value your laifu."
	color = "#664300"

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

/datum/reagent/ethanol/scientists_serendipity
	name = "Scientist's Serendipity"
	id = SCIENTISTS_SERENDIPITY
	description = "Go ahead and blow the research budget on drinking this." //Can deconstruct a glass with this for loadsoftech
	color = "#664300"
	custom_metabolism = 0.01
	dupeable = FALSE

/datum/reagent/ethanol/beepskyclassic
	name = "Beepsky Classic"
	id = BEEPSKY_CLASSIC
	description = "Some believe that the more modern Beepsky Smash was introduced to make this drink more popular."
	color = "#664300" //rgb: 102, 67, 0
	custom_metabolism = 2 //Ten times the normal rate.

/datum/reagent/ethanol/beepskyclassic/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.job in list("Security Officer", "Head of Security", "Detective", "Warden"))
			playsound(get_turf(H), 'sound/voice/halt.ogg', 100, 1, 0)
		else
			H.Knockdown(10)
			H.Stun(10)
			playsound(get_turf(H), 'sound/weapons/Egloves.ogg', 100, 1, -1)

/datum/reagent/ethanol/spiders
	name = "Spiders"
	id = SPIDERS
	description = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA."
	color = "#666666" //rgb(102, 102, 102)
	custom_metabolism = 0.01 //Spiders really 'hang around'

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

/datum/reagent/ethanol/weedeater/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	var/spell = /spell/targeted/genetic/eat_weed
	if(!(locate(spell) in M.spell_list))
		to_chat(M, "<span class='notice'>You feel hungry like the diona.</span>")
		M.add_spell(spell)

/datum/reagent/ethanol/deadrum
	name = "Deadrum"
	id = RUM
	description = "Popular with the sailors. Not very popular with anyone else."
	color = "#664300" //rgb: 102, 67, 0
	pass_out = 325

/datum/reagent/ethanol/deadrum/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.dizziness += 5

/datum/reagent/ethanol/deadrum/vodka
	name = "Vodka"
	id = VODKA
	description = "The drink and fuel of choice of Russians galaxywide."
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/sake
	name = "Sake"
	id = SAKE
	description = "Anime's favorite drink."
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/sake/on_mob_life(var/mob/living/M)
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
				M.confused = max(0, M.confused - 5)

/datum/reagent/ethanol/deadrum/glasgow
	name = "Glasgow Deadrum"
	id = GLASGOW
	description = "Makes you feel like you had one hell of a party."
	color = "#662D1D" //rgb: 101, 44, 29
	slur_start = 1
	confused_start = 1

/datum/reagent/ethanol/deadrum/tequila
	name = "Tequila"
	id = TEQUILA
	description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty, hombre?"
	color = "#A8B0B7" //rgb: 168, 176, 183

/datum/reagent/ethanol/deadrum/vermouth
	name = "Vermouth"
	id = VERMOUTH
	description = "You suddenly feel a craving for a martini..."
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/wine
	name = "Wine"
	id = WINE
	description = "A premium alcoholic beverage made from fermented grape juice."
	color = "#7E4043" //rgb: 126, 64, 67
	dizzy_adj = 2
	slur_start = 65
	confused_start = 145

/datum/reagent/ethanol/deadrum/cognac
	name = "Cognac"
	id = COGNAC
	description = "A sweet and strongly alcoholic drink, twice distilled and left to mature for several years. Classy as fornication."
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 4
	confused_start = 115

/datum/reagent/ethanol/deadrum/hooch
	name = "Hooch"
	id = HOOCH
	description = "A suspiciously viscous off-brown liquid that reeks of fuel. Do you really want to drink that?"
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 6
	slurr_adj = 5
	slur_start = 35
	confused_start = 90
	pass_out = 250

/datum/reagent/ethanol/deadrum/ale
	name = "Ale"
	id = ALE
	description = "A dark alcoholic beverage made from malted barley and yeast."
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/thirteenloko
	name = "Thirteen Loko"
	id = THIRTEENLOKO
	description = "A potent mixture of caffeine and alcohol."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#102000" //rgb: 16, 32, 0

/datum/reagent/ethanol/deadrum/thirteenloko/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.nutrition += nutriment_factor
	M.drowsyness = max(0, M.drowsyness - 7)
	M.Jitter(1)

/////////////////////////////////////////////////////////////////Cocktail Entities//////////////////////////////////////////////

/datum/reagent/ethanol/deadrum/bilk
	name = "Bilk"
	id = BILK
	description = "This appears to be beer mixed with milk. Disgusting."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#895C4C" //rgb: 137, 92, 76
	density = 0.89
	specheatcap = 2.46

/datum/reagent/ethanol/deadrum/atomicbomb
	name = "Atomic Bomb"
	id = ATOMICBOMB
	description = "Nuclear proliferation never tasted so good."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#666300" //rgb: 102, 99, 0

/datum/reagent/ethanol/deadrumm/threemileisland
	name = "Three Mile Island Iced Tea"
	id = THREEMILEISLAND
	description = "Made for a woman. Strong enough for a man."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#666340" //rgb: 102, 99, 64

/datum/reagent/ethanol/deadrum/goldschlager
	name = "Goldschlager"
	id = GOLDSCHLAGER
	description = "100 proof cinnamon schnapps with small gold flakes mixed in."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	density = 2.72
	specheatcap = 0.32

/datum/reagent/ethanol/deadrum/patron
	name = "Patron"
	id = PATRON
	description = "Tequila with small flakes of silver in it."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#585840" //rgb: 88, 88, 64
	density = 1.84
	specheatcap = 0.59

/datum/reagent/ethanol/deadrum/gintonic
	name = "Gin and Tonic"
	id = GINTONIC
	description = "An all time classic, mild cocktail."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/cuba_libre
	name = "Cuba Libre"
	id = CUBALIBRE
	description = "Rum, mixed with cola. Viva la revolution."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#3E1B00" //rgb: 62, 27, 0

/datum/reagent/ethanol/deadrum/whiskey_cola
	name = "Whiskey Cola"
	id = WHISKEYCOLA
	description = "Whiskey, mixed with cola. Surprisingly refreshing."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#3E1B00" //rgb: 62, 27, 0

/datum/reagent/ethanol/deadrum/martini
	name = "Classic Martini"
	id = MARTINI
	description = "Vermouth with gin. Not quite how 007 enjoyed it, but still delicious."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/vodkamartini
	name = "Vodka Martini"
	id = VODKAMARTINI
	description = "Vodka with gin. Not quite how 007 enjoyed it, but still delicious."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/sakemartini
	name = "Sake Martini"
	id = SAKEMARTINI
	description = "A martini mixed with sake instead of vermouth. Has a fruity, oriental flavor."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/white_russian
	name = "White Russian"
	id = WHITERUSSIAN
	description = "That's just, like, your opinion, man..."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A68340" //rgb: 166, 131, 64

/datum/reagent/ethanol/deadrum/screwdrivercocktail
	name = "Screwdriver"
	id = SCREWDRIVERCOCKTAIL
	description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A68310" //rgb: 166, 131, 16

/datum/reagent/ethanol/deadrum/booger
	name = "Booger"
	id = BOOGER
	description = "Ewww..."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A68310" //rgb: 166, 131, 16

/datum/reagent/ethanol/deadrum/bloody_mary
	name = "Bloody Mary"
	id = BLOODYMARY
	description = "A strange yet pleasant mixture made of vodka, tomato and lime juice. Or at least you think the red stuff is tomato juice."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = GARGLEBLASTER
	description = "Whoah, this stuff looks volatile!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/brave_bull
	name = "Brave Bull"
	id = BRAVEBULL
	description = "A mixture of tequila and coffee liqueur."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/tequila_sunrise
	name = "Tequila Sunrise"
	id = TEQUILASUNRISE
	description = "Tequila and orange juice. Much like a Screwdriver, only Mexican."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/toxins_special
	name = "Toxins Special"
	id = TOXINSSPECIAL
	description = "This thing is FLAMING! CALL THE DAMN SHUTTLE!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/beepsky_smash
	name = "Beepsky Smash"
	id = BEEPSKYSMASH
	description = "This drink is the law."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/drink/doctor_delight
	name = "The Doctor's Delight"
	id = DOCTORSDELIGHT
	description = "A gulp a day keeps the MediBot away. That's what they say, at least."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = FOOD_METABOLISM
	color = "#BA7DBA" //rgb: 73, 49, 73

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
		M.confused = max(0, M.confused - 5)

/datum/reagent/ethanol/deadrum/changelingsting
	name = "Changeling Sting"
	id = CHANGELINGSTING
	description = "Milder than the name suggests. Not that you've ever been stung."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113

/datum/reagent/ethanol/deadrum/irish_cream
	name = "Irish Cream"
	id = IRISHCREAM
	description = "Whiskey-imbued cream. What else could you expect from the Irish."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/manly_dorf
	name = "The Manly Dorf"
	id = MANLYDORF
	description = "A dwarfy concoction made from ale and beer. Intended for stout dwarves only."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/longislandicedtea
	name = "Long Island Iced Tea"
	id = LONGISLANDICEDTEA
	description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/moonshine
	name = "Moonshine"
	id = MOONSHINE
	description = "You've really hit rock bottom now... your liver packed its bags and left last night."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/b52
	name = "B-52"
	id = B52
	description = "Coffee, irish cream, and cognac. You will get bombed."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/irishcoffee
	name = "Irish Coffee"
	id = IRISHCOFFEE
	description = "Coffee served with irish cream. Regular cream just isn't the same."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/margarita
	name = "Margarita"
	id = MARGARITA
	description = "On the rocks with salt on the rim. Arriba!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/black_russian
	name = "Black Russian"
	id = BLACKRUSSIAN
	description = "For the lactose-intolerant. Still as classy as a White Russian."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#360000" //rgb: 54, 0, 0

/datum/reagent/ethanol/deadrum/manhattan
	name = "Manhattan"
	id = MANHATTAN
	description = "The Detective's undercover drink of choice. He never could stomach gin..."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/manhattan_proj
	name = "Manhattan Project"
	id = MANHATTAN_PROJ
	description = "A scientist's drink of choice, for thinking about how to blow up the station."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/whiskeysoda
	name = "Whiskey Soda"
	id = WHISKEYSODA
	description = "Ultimate refreshment."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/antifreeze
	name = "Anti-freeze"
	id = ANTIFREEZE
	description = "Ultimate refreshment."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/barefoot
	name = "Barefoot"
	id = BAREFOOT
	description = "Barefoot and pregnant"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/snowwhite
	name = "Snow White"
	id = SNOWWHITE
	description = "Pale lager mixed with lemon-lime soda. Refreshing and sweet."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/demonsblood
	name = "Demon's Blood"
	id = DEMONSBLOOD
	description = "AHHHH!!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 10
	slurr_adj = 10

/datum/reagent/ethanol/deadrum/vodkatonic
	name = "Vodka and Tonic"
	id = VODKATONIC
	description = "For when a gin and tonic isn't Russian enough."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 4
	slurr_adj = 3

/datum/reagent/ethanol/deadrum/ginfizz
	name = "Gin Fizz"
	id = GINFIZZ
	description = "Refreshingly lemony, deliciously dry."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	dizzy_adj = 4
	slurr_adj = 3

/datum/reagent/ethanol/deadrum/bahama_mama
	name = "Bahama mama"
	id = BAHAMA_MAMA
	description = "Tropical cocktail."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/pinacolada
	name = "Pina Colada"
	id = PINACOLADA
	description = "Sans pineapple."
	reagent_state = REAGENT_STATE_LIQUID
	color = "F2F5BF" //rgb: 242, 245, 191

/datum/reagent/ethanol/deadrum/singulo
	name = "Singulo"
	id = SINGULO
	description = "A gravitational anomaly."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113
	dizzy_adj = 15
	slurr_adj = 15

/datum/reagent/ethanol/deadrum/sangria
	name = "Sangria"
	id = SANGRIA
	description = "So tasty you won't believe it's alcohol."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#53181A" //rgb: 83, 24, 26
	dizzy_adj = 2
	slur_start = 65
	confused_start = 145

/datum/reagent/ethanol/deadrum/sbiten
	name = "Sbiten"
	id = SBITEN
	description = "A spicy vodka."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/sbiten/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.bodytemperature < 360)
		M.bodytemperature = min(360, M.bodytemperature + 50) //310 is the normal bodytemp. 310.055

/datum/reagent/ethanol/deadrum/devilskiss
	name = "Devil's Kiss"
	id = DEVILSKISS
	description = "Creepy time!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#A68310" //rgb: 166, 131, 16

/datum/reagent/ethanol/deadrum/red_mead
	name = "Red Mead"
	id = RED_MEAD
	description = "A crimson beverage consumed by space vikings. The coloration is from berries... you hope."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/mead
	name = "Mead"
	id = MEAD
	description = "A beverage consumed by space vikings on their long raids and rowdy festivities."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/iced_beer
	name = "Iced Beer"
	id = ICED_BEER
	description = "A beer so frosty the air around it freezes."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/iced_beer/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.bodytemperature < T0C+33)
		M.bodytemperature = min(T0C+33, M.bodytemperature - 4) //310 is the normal bodytemp. 310.055

/datum/reagent/ethanol/deadrum/grog
	name = "Grog"
	id = GROG
	description = "Watered down rum. NanoTrasen approves!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/aloe
	name = "Aloe"
	id = ALOE
	description = "Contains no actual aloe."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/andalusia
	name = "Andalusia"
	id = ANDALUSIA
	description = "Rum, whiskey, and lemon juice."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/alliescocktail
	name = "Allies Cocktail"
	id = ALLIESCOCKTAIL
	description = "English gin, French vermouth, and Russian vodka."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/acid_spit
	name = "Acid Spit"
	id = ACIDSPIT
	description = "Wine and sulphuric acid. You hope the wine has neutralized the acid."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#365000" //rgb: 54, 80, 0

/datum/reagent/ethanol/deadrum/amasec
	name = "Amasec"
	id = AMASEC
	description = "The official drink of the Imperium."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/ethanol/deadrum/amasec/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.stunned = 4

/datum/reagent/ethanol/deadrum/neurotoxin
	name = "Neurotoxin"
	id = NEUROTOXIN
	description = "A strong neurotoxin that puts the subject into a death-like state."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E2E61" //rgb: 46, 46, 97

/datum/reagent/ethanol/deadrum/neurotoxin/on_mob_life(var/mob/living/M)

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

/datum/reagent/drink/silencer
	name = "Silencer"
	id = SILENCER
	description = "Some say this is the diluted blood of the mime."
	nutriment_factor = FOOD_METABOLISM
	color = "#664300" //rgb: 102, 67, 0

/datum/reagent/drink/silencer/on_mob_life(var/mob/living/M)

	if(..())
		return 1
	M.silent = max(M.silent, 15)

/datum/reagent/ethanol/deadrum/changelingsting
	name = "Changeling Sting"
	id = CHANGELINGSTING
	description = "Milder than the name suggests. Not that you've ever been stung."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113

/datum/reagent/ethanol/deadrum/changelingsting/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.dizziness += 5

/datum/reagent/ethanol/deadrum/erikasurprise
	name = "Erika Surprise"
	id = ERIKASURPRISE
	description = "The surprise is, it's green!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113

/datum/reagent/ethanol/deadrum/irishcarbomb
	name = "Irish Car Bomb"
	id = IRISHCARBOMB
	description = "A troubling mixture of irish cream and ale."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113

/datum/reagent/ethanol/deadrum/irishcarbomb/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.dizziness += 5

/datum/reagent/ethanol/deadrum/syndicatebomb
	name = "Syndicate Bomb"
	id = SYNDICATEBOMB
	description = "Whiskey cola and beer. Figuratively explosive."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#2E6671" //rgb: 46, 102, 113

/datum/reagent/ethanol/deadrum/driestmartini
	name = "Driest Martini"
	id = DRIESTMARTINI
	description = "Only for the experienced. You think you see sand floating in the glass."
	nutriment_factor = FOOD_METABOLISM
	color = "#2E6671" //rgb: 46, 102, 113
	data = 1 //Used as a tally

/datum/reagent/ethanol/deadrum/driestmartini/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.dizziness += 10
	if(data >= 55 && data < 115)
		M.stuttering += 10
	else if(data >= 115 && prob(33))
		M.confused = max(M.confused + 15, 15)
	data++

/datum/reagent/ethanol/deadrum/danswhiskey
	name = "Discount Dan's 'Malt' Whiskey"
	id = DANS_WHISKEY
	description = "It looks like whiskey... kinda."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#6F884F" //rgb: 181, 199, 158

/datum/reagent/ethanol/deadrum/danswhiskey/on_mob_life(var/mob/living/M)
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

/datum/reagent/ethanol/deadrumm/pintpointer
	name = "Pintpointer"
	id = PINTPOINTER
	description = "A little help finding the bartender."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0


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

/datum/reagent/honkserum/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(5))
		M.say(pick("Honk", "HONK", "Hoooonk", "Honk?", "Henk", "Hunke?", "Honk!"))
		playsound(get_turf(M), 'sound/items/bikehorn.ogg', 50, -1)

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

/datum/reagent/drink/tea/redtea
	name = "Red Tea"
	id = REDTEA
	description = "Tasty red tea."

/datum/reagent/drink/tea/singularitea
	name = "Singularitea"
	id = SINGULARITEA
	description = "Swirly!"

var/global/list/chifir_doesnt_remove = list("chifir", "blood")

/datum/reagent/drink/tea/chifir
	name = "Chifir"
	id = CHIFIR
	description = "Strong Russian tea. It'll help you remember what you had for lunch!"

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

/datum/reagent/drink/tea/yinyang
	name = "Zen Tea"
	id = YINYANG
	description = "Find inner peace."

/datum/reagent/drink/tea/gyro
	name = "Gyro"
	id = GYRO
	description = "Nyo ho ho~"

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

/datum/reagent/drink/tea/mint
	name = "Groans Tea: Minty Delight Flavor"
	id = MINT
	description = "Very filling!"

/datum/reagent/drink/tea/chamomile
	name = "Groans Tea: Chamomile Flavor"
	id = CHAMOMILE
	description = "Enjoy a good night's sleep."

/datum/reagent/drink/tea/exchamomile
	name = "Tea"
	id = EXCHAMOMILE
	description = "Who needs to wake up anyway?"

/datum/reagent/drink/tea/fancydan
	name = "Groans Banned Tea: Fancy Dan Flavor"
	id = FANCYDAN
	description = "Full of that patented Dan taste you love!"

/datum/reagent/drink/tea/plasmatea
	name = "Plasma Pekoe"
	id = PLASMATEA
	description = "Probably not the safest beverage."

/datum/reagent/drink/tea/greytea
	name = "Tide"
	id = GREYTEA
	description = "This probably shouldn't even be considered tea..."

/datum/reagent/drink/coffee/espresso
	name = "Espresso"
	id = ESPRESSO
	description = "A thick blend of coffee made by forcing near-boiling pressurized water through finely ground coffee beans."

//Let's hope this one works
var/global/list/tonio_doesnt_remove=list("tonio", "blood")

/datum/reagent/drink/coffee/tonio
	name = "Tonio"
	id = TONIO
	nutriment_factor = FOOD_METABOLISM
	description = "This coffee seems uncannily good."

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

/datum/reagent/drink/coffee/doppio
	name = "Doppio"
	id = DOPPIO
	description = "Double shot of espresso."

/datum/reagent/drink/coffee/passione
	name = "Passione"
	id = PASSIONE
	description = "Rejuvenating!"

/datum/reagent/drink/coffee/seccoffee
	name = "Wake-Up Call"
	id = SECCOFFEE
	description = "All the essentials."

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
		M.confused = max(0, M.confused - 5)
	M.reagents.add_reagent (IRON, 0.1)

/datum/reagent/drink/coffee/detcoffee
	name = "Joe"
	id = DETCOFFEE
	description = "Bitter, black, and tasteless. Just the way I liked my coffee. I was halfway down my third mug that day, and all the way down on my luck. The only case I'd had all month had just turned sour. I took the flask in my drawer and emptied its contents into my coffee. No alcohol today, I'd promised myself. Thing is, promises to yourself are easy to break. No one to hold you accountable."
	causes_jitteriness = 0
	var/activated = 0
	var/noir_set_by_us = 0

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

/datum/reagent/drink/cold/quantum
	name = "Nuka Cola Quantum"
	id = QUANTUM
	description = "Take the leap... enjoy a Quantum!"
	color = "#100800" //rgb: 16, 8, 0
	adj_sleepy = -2
	sport = 5

/datum/reagent/drink/cold/quantum/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	M.apply_radiation(2, RAD_INTERNAL)

/datum/reagent/drink/sportdrink
	name = "Sport Drink"
	id = SPORTDRINK
	description = "You like sports, and you don't care who knows."
	sport = 5
	color = "#CCFF66" //rgb: 204, 255, 51
	custom_metabolism =  0.01
	custom_plant_metabolism = HYDRO_SPEED_MULTIPLIER/5

/datum/reagent/antidepressant/citalopram
	name = "Citalopram"
	id = CITALOPRAM
	description = "Stabilizes the mind a little."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC"
	custom_metabolism = 0.01
	data = 0
	density = 1.01
	specheatcap = 3.88

/datum/reagent/antidepressant/citalopram/on_mob_life(var/mob/living/M as mob)
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

/datum/reagent/antidepressant/paroxetine
	name = "Paroxetine"
	id = PAROXETINE
	description = "Stabilizes the mind greatly, but has a chance of adverse effects."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC"
	custom_metabolism = 0.01
	data = 0
	density = 1.19
	specheatcap = 3.99

/datum/reagent/antidepressant/paroxetine/on_mob_life(var/mob/living/M as mob)
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

/datum/reagent/gravy
	name = "Gravy"
	id = GRAVY
	description = "Aww, come on Double D, I don't say 'gravy' all the time."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 10 * REAGENTS_METABOLISM
	color = "#EDEDE1"

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

/datum/reagent/ethanol/deadrum/greyvodka
	name = "Greyshirt vodka"
	id = GREYVODKA
	description = "Made presumably from whatever scrapings you can get out of maintenance. Don't think, just drink."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#DEF7F5"
	alpha = 64

/datum/reagent/ethanol/deadrum/greyvodka/on_mob_life(var/mob/living/carbon/human/H)
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

/datum/reagent/ethanol/deadrum/neurotoxin/curare
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

	var/minimal_dosage = 1 //At least 1 unit is needed for petriication

/datum/reagent/petritricin/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(volume >= minimal_dosage && prob(30))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(locate(/datum/disease/petrification) in H.viruses)
				return

			var/datum/disease/D = new /datum/disease/petrification
			D.holder = H
			D.affected_mob = H
			H.viruses += D
		else if(!issilicon(M))
			if(M.turn_into_statue(1)) //Statue forever
				to_chat(M, "<span class='userdanger'>You have been turned to stone by ingesting petritricin.</span>")

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
	A.set_light(0)

/datum/reagent/anthracene/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)
	if(..())
		return 1

	if(method == TOUCH)
		var/init_color = M.light_color
		M.light_color = LIGHT_COLOR_GREEN
		M.set_light(light_intensity)
		spawn(volume * 10)
			M.light_color = init_color
			M.set_light(0)

/datum/reagent/anthracene/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	var/init_color = T.light_color
	T.light_color = LIGHT_COLOR_GREEN
	T.set_light(light_intensity)
	spawn(volume * 10)
		T.light_color = init_color
		T.set_light(0)

/datum/reagent/anthracene/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	var/init_color = O.light_color
	O.light_color = LIGHT_COLOR_GREEN
	O.set_light(light_intensity)
	spawn(volume * 10)
		O.light_color = init_color
		O.set_light(0)

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
		if((H.species && H.species.flags & NO_BREATHE) || M_NO_BREATH in H.mutations)
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

	if(volume >= 5 && T.can_thermite)
		T:rot()

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
			M.adjustFireLoss(5*REM)
			M.adjustBruteLoss(5*REM)

//////////////////////
//					//
//      INCENSE		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//					//
//////////////////////
/datum/reagent/incense
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
	var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
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
	sport = 5
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