//////////////////////
//					//
//      MISC 		//
//					//
//////////////////////

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


/datum/reagent/ultraglue
	name = "Ultra Glue"
	id = GLUE
	description = "An extremely powerful bonding agent."
	color = "#FFFFCC" //rgb: 255, 255, 204


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


/datum/reagent/nitroglycerin
	name = "Nitroglycerin"
	id = NITROGLYCERIN
	description = "Nitroglycerin is a heavy, colorless, oily, explosive liquid obtained by nitrating glycerol."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#808080" //rgb: 128, 128, 128
	density = 4.33
	specheatcap = 2.64


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


/datum/reagent/potassiumcarbonate
	name = "Potassium Carbonate"
	id = POTASSIUMCARBONATE
	description = "A primary component of potash, usually acquired by reducing potassium-rich organics."
	reagent_state = REAGENT_STATE_SOLID
	color = "#A0A0A0"
	density = 2.43
	specheatcap = 0.96


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


/datum/reagent/mediumcores
	name = "medium-salted cores"
	id = MEDCORES
	description = "A derivative of the chemical known as 'Hardcores', easier to mass produce, but at a cost of quality."
	reagent_state = REAGENT_STATE_SOLID
	color = "#FFA500"
	custom_metabolism = 0.1





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

