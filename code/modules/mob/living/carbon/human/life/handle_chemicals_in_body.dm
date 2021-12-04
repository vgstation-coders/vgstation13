//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_chemicals_in_body()
	var/jittery_time = jitteriness

	if(reagents)

		var/alien = 0 //Not the best way to handle it, but neater than checking this for every single reagent proc.
		if(src.species)
			if(src.species.has_organ["liver"])
				var/datum/organ/internal/liver/L = src.internal_organs_by_name["liver"]
				if(!L)
					src.adjustToxLoss(1)
			switch(src.species.type)
				if(/datum/species/diona)
					alien = IS_DIONA
				if(/datum/species/vox)
					alien = IS_VOX
				if(/datum/species/plasmaman)
					alien = IS_PLASMA
				if(/datum/species/grey)
					alien = IS_GREY
		reagents.metabolize(src,alien)

	if(status_flags & GODMODE)
		return 0 //Godmode. This causes jittering and other variables to never go down but whatever.
	if(!(species.flags & PLASMA_IMMUNE))
		var/total_plasmaloss = 0
		for(var/obj/item/I in src)
			if(I.contaminated)
				total_plasmaloss += zas_settings.Get(/datum/ZAS_Setting/CONTAMINATION_LOSS)
			I.OnMobLife(src)
		adjustToxLoss(total_plasmaloss)

	if(species.flags & REQUIRE_LIGHT)
		var/light_amount = 0 //How much light there is in the place, affects receiving nutrition and healing
		if(isturf(loc)) //Else, there's considered to be no light
			var/turf/T = loc
			light_amount = (T.get_lumcount() * 10) - 5

		nutrition += light_amount
		pain_shock_stage -= light_amount

		if(species.flags & IS_PLANT)
			if(nutrition > 500)
				nutrition = 500
			if(light_amount >= 3 && !reagents.has_any_reagents(list(HYPERZINE,PLANTBGONE))) //If there's enough light, you do not have hyperzine in body, and you don't have plant-b-gone inside you, heal
				adjustBruteLoss(-(light_amount))
				adjustToxLoss(-(light_amount))
				adjustOxyLoss(-(light_amount))
				//TODO: heal wounds, heal broken limbs.

	if(isslimeperson(src) && reagents.total_volume > 10)
		blend_multicolor_skin(get_weighted_reagent_color(reagents), min(0.5, (reagents.total_volume / 1000)), 1)

	if(dna && dna.mutantrace == "shadow")
		var/light_amount = 0
		if(isturf(loc))
			var/turf/T = loc
			if(T.dynamic_lighting)
				light_amount = T.get_lumcount() * 10
			else
				light_amount = 10

		if(light_amount > 2) //If there's enough light, start dying
			take_overall_damage(1,1)
		else if(light_amount < 2) //Heal in the dark
			heal_overall_damage(1,1)

	//The fucking M_FAT mutation is the greatest shit ever. It makes everyone so hot and bothered.
	if(species.anatomy_flags & CAN_BE_FAT)
		if(M_FAT in mutations)
			if(overeatduration < 100)
				to_chat(src, "<span class='notice'>You feel fit again!</span>")
				mutations.Remove(M_FAT)
				update_mutantrace(0)
				update_mutations(0)
				update_inv_w_uniform(0)
				update_inv_wear_suit()
		else
			if(overeatduration > 500)
				to_chat(src, "<span class='warning'>You suddenly feel blubbery!</span>")
				mutations.Add(M_FAT)
				update_mutantrace(0)
				update_mutations(0)
				update_inv_w_uniform(0)
				update_inv_wear_suit()

	//Nutrition decrease
	if(stat != DEAD)
		var/reduce_nutrition_by_final = calorie_burn_rate
		if(sleeping)
			reduce_nutrition_by_final *= 0.75 //Reduce hunger factor by 25%
		burn_calories(reduce_nutrition_by_final,1)

	if(nutrition > OVEREAT_THRESHOLD)
		if(overeatduration < 600) //capped so people don't take forever to unfat
			overeatduration++
		if(isslimeperson(src))
			nutrition = OVEREAT_THRESHOLD
	else
		if(overeatduration > 1)
			if(M_FAT in mutations)
				overeatduration -= 1 //Those already fat take twice as long to unfat
			else
				overeatduration -= 2

	if(species.flags & REQUIRE_LIGHT)
		if(nutrition < 200)
			take_overall_damage(2,0)
			pain_shock_stage++

	if(drowsyness > 0)
		drowsyness = max(0, drowsyness - 1)
		eye_blurry = max(2, eye_blurry)
		if(prob(5))
			sleeping += 1
			Paralyse(5)

	remove_confused(1)
	//Decrement dizziness counter, clamped to 0
	if(resting)
		dizziness = max(0, dizziness - 15)
		jitteriness = max(0, jitteriness - 15)
	else
		dizziness = max(0, dizziness - 3)
		jitteriness = max(0, jitteriness - 3)
	if(jittery_time && !jitteriness)
		animate(src)

	handle_trace_chems()

	updatehealth()

//Color as text in hex, weight for the color we're adding should be < 1
/mob/living/carbon/human/proc/blend_multicolor_skin(var/color, var/weight = 0.5, var/updatehair = 0)
	var/list/colors = GetHexColors(color)
	multicolor_skin_r = round((1 - weight) * multicolor_skin_r + weight * colors[1])
	multicolor_skin_g = round((1 - weight) * multicolor_skin_g + weight * colors[2])
	multicolor_skin_b = round((1 - weight) * multicolor_skin_b + weight * colors[3])
	update_body()
	if(updatehair)
		my_appearance.r_hair = round(multicolor_skin_r * 0.8)
		my_appearance.g_hair = round(multicolor_skin_g * 0.8)
		my_appearance.b_hair = round(multicolor_skin_b * 0.8)
		update_hair()
