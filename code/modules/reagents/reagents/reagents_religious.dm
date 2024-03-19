//Religious-based chemicals

/datum/reagent/holywater
	name = "Holy Water"
	id = HOLYWATER
	description = "An ashen-obsidian-water mix, this solution will alter certain sections of the brain's rationality."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#8497A9" //rgb: 52, 59, 63
	custom_metabolism = 2
	specheatcap = 4.183
	alpha = 128

/datum/reagent/holywater/on_mob_life(mob/living/M)
	if(..())
		return 1
	M.immune_system.ApplyAntipathogenics(100, list(ANTIGEN_CULT), 2)

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

/datum/reagent/holywater/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_waterlevel(1)

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
	T.add_waterlevel(-5)
	T.add_nutrientlevel(5)
	T.add_toxinlevel(8)
	T.add_weedlevel(-20)
	T.add_pestlevel(-10)
	if(T.seed && !T.dead)
		T.add_planthealth(-2)

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
	nutriment_factor = -5 * REAGENTS_METABOLISM
	custom_metabolism = 0.15

/datum/reagent/incense/novaflowers/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(holder.get_reagent_amount(HYPERZINE) < 2)
		holder.add_reagent(HYPERZINE, 0.5)

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
