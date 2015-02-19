/datum/reagent/water
	name = "Water"
	id = "water"
	description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
	reagent_state = LIQUID
	color = "#0064C8" // rgb: 0, 100, 200
	custom_metabolism = 0.01

/datum/reagent/water/on_mob_life(var/mob/living/M as mob,var/alien)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.name=="Grey")
			if(!M) M = holder.my_atom
			M.adjustToxLoss(1*REM)
			M.take_organ_damage(0, 1*REM)
	..()

/datum/reagent/water/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return
	M.color = initial(M.color)

	// Put out fire
	if(method == TOUCH)
		M.adjust_fire_stacks(-(volume / 10))
		if(M.fire_stacks <= 0)
			M.ExtinguishMob()

	// Water now directly damages slimes instead of being a turf check
	if(isslime(M))
		M.adjustToxLoss(rand(15,20))

	if(istype(M,/mob/living/simple_animal/hostile/slime))
		var/mob/living/simple_animal/hostile/slime/S = M
		S.calm()

	// Grays treat water like acid.
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.name=="Grey")
			if(method == TOUCH)
				if(H.wear_mask)
					H << "\red Your mask protects you from the water!"
					return

				if(H.head)
					H << "\red Your helmet protects you from the water!"
					return
				if(!M.unacidable)
					if(prob(15) && volume >= 30)
						var/datum/organ/external/affecting = H.get_organ("head")
						if(affecting)
							if(affecting.take_damage(25, 0))
								H.UpdateDamageIcon(1)
							H.status_flags |= DISFIGURED
							H.emote("scream",,, 1)
					else
						M.take_organ_damage(min(15, volume * 2)) // uses min() and volume to make sure they aren't being sprayed in trace amounts (1 unit != insta rape) -- Doohl
			else
				if(!M.unacidable)
					M.take_organ_damage(min(15, volume * 2))

		else if(H.dna.mutantrace == "slime")
			var/chance = 1
			var/block  = 0

			for(var/obj/item/clothing/C in H.get_equipped_items())
				if(C.permeability_coefficient < chance) chance = C.permeability_coefficient
				if(istype(C, /obj/item/clothing/suit/bio_suit))
					if(prob(75))
						block = 1
				if(istype(C, /obj/item/clothing/head/bio_hood))
					if(prob(50))
						block = 1

			chance = chance * 100

			if(prob(chance) && !block)
				H.adjustToxLoss(rand(1,3))

/datum/reagent/water/reaction_turf(var/turf/simulated/T, var/volume)
	if (!istype(T)) return
	T.color = initial(T.color)
	src = null
	if(volume >= 3)
		T.wet(800)


	var/hotspot = (locate(/obj/fire) in T)
	if(hotspot && !istype(T, /turf/space))
		var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
		lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)
	return

/datum/reagent/water/reaction_obj(var/obj/O, var/volume)
	O.color = initial(O.color)
	src = null
	var/turf/T = get_turf(O)
	var/hotspot = (locate(/obj/fire) in T)
	if(hotspot && !istype(T, /turf/space))
		var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
		lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)
	if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/monkeycube))
		var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/cube = O
		if(!cube.wrapped)
			cube.Expand()
	return

/datum/reagent/water/holy
	name = "Holy Water"
	id = "holywater"
	description = "An ashen-obsidian-water mix, this solution will alter certain sections of the brain's rationality."
	reagent_state = LIQUID
	color = "#0064C8" // rgb: 0, 100, 200

/datum/reagent/water/holy/reaction_obj(var/obj/O, var/volume)
	if(volume>=1)
		O.blessed=1

/datum/reagent/water/holy/on_mob_life(var/mob/living/M as mob,var/alien)
	..()
	if(!holder) return
	if(ishuman(M))
		if((M.mind in ticker.mode.cult) && prob(10))
			M << "<span class='notice'>A cooling sensation from inside you brings you an untold calmness.</span>"
			ticker.mode.remove_cultist(M.mind)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='notice'>[]'s eyes blink and become clearer.</span>", M), 1) // So observers know it worked.
		// Vamps react to this like acid
		if(((M.mind in ticker.mode.vampires) || M.mind.vampire) && prob(10))
			if(!(VAMP_FULL in M.mind.vampire.powers))
				if(!M) M = holder.my_atom
				M.adjustToxLoss(1*REM)
				M.take_organ_damage(0, 1*REM)
	holder.remove_reagent(src.id, 10 * REAGENTS_METABOLISM) //high metabolism to prevent extended uncult rolls.

/datum/reagent/water/holy/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//Splashing people with water can help put them out!
	..()
	// Vamps react to this like acid
	if(ishuman(M))
		if((M.mind in ticker.mode.vampires))
			if(!(VAMP_FULL in M.mind.vampire.powers))
				var/mob/living/carbon/human/H=M
				if(method == TOUCH)
					if(H.wear_mask)
						H << "<span class='warning'>Your mask protects you from the holy water!</span>"
						return

					if(H.head)
						H << "<span class='warning'>\red Your helmet protects you from the holy water!</span>"
						return
					if(!M.unacidable)
						if(prob(15) && volume >= 30)
							var/datum/organ/external/affecting = H.get_organ("head")
							if(affecting)
								if(affecting.take_damage(25, 0))
									H.UpdateDamageIcon(1)
								H.status_flags |= DISFIGURED
								H.emote("scream",,, 1)
						else
							M.take_organ_damage(min(15, volume * 2)) // uses min() and volume to make sure they aren't being sprayed in trace amounts (1 unit != insta rape) -- Doohl
			else
				if(!M.unacidable)
					M.take_organ_damage(min(15, volume * 2))
	return

/datum/reagent/water/holy/reaction_turf(var/turf/T, var/volume)
	..()
	src = null
	if(volume >= 5)
		T.holy = 1
	return
