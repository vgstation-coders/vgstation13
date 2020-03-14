/mob/living/carbon/human
	var/crawlcounter = 1
	var/max_crawls_before_fatigue = 6

/mob/living/carbon/human/movement_delay()
	if(isslimeperson(src))
		if (bodytemperature >= 330.23) // 135 F
			return min(..(), 1)
	return ..()

/mob/living/carbon/human/base_movement_tally()
	. = ..()

	if(flying)
		return // Calculate none of the following because we're technically on a vehicle
	if(reagents.has_any_reagents(HYPERZINES))
		return // Hyperzine ignores base slowdown
	if(istype(loc, /turf/space))
		return // Space ignores

	if (species && species.move_speed_mod)
		. += species.move_speed_mod

	var/hungry = (500 - nutrition)/5 // So overeat would be 100 and default level would be 80
	if (hungry >= 70)
		. += hungry/50

	if (isslimeperson(src))
		if (bodytemperature < 183.222)
			. += (283.222 - bodytemperature) / 10 * 175 // MAGIC NUMBERS!
	else if (undergoing_hypothermia())
		. += 2*undergoing_hypothermia()

	if(feels_pain() && !has_painkillers())
		if(pain_shock_stage >= 50)
			. += 3
		var/list/limbs_to_check
		var/multiplier = 1
		if(!lying)
			limbs_to_check = list(LIMB_LEFT_FOOT,LIMB_RIGHT_FOOT,LIMB_LEFT_LEG,LIMB_RIGHT_LEG)
		else
			limbs_to_check = grasp_organs
			multiplier = 2
		for(var/organ_name in limbs_to_check)
			var/datum/organ/external/E
			if(istype(organ_name, /datum/organ/external))
				E = organ_name
			else
				E = get_organ(organ_name)
			if(!E || (E.status & ORGAN_DESTROYED))
				. += 4*multiplier
			if(E.status & ORGAN_SPLINTED)
				if(!find_held_item_by_type(/obj/item/weapon/cane))
					. += 0.5*multiplier
			else if(E.status & ORGAN_BROKEN)
				if(!find_held_item_by_type(/obj/item/weapon/cane))
					. += 1*multiplier
				. += 0.5*multiplier


/mob/living/carbon/human/movement_tally_multiplier()
	. = ..()
	if(!reagents.has_any_reagents(HYPERZINES))
		if(!shoes)
			. *= NO_SHOES_SLOWDOWN
	if(M_FAT in mutations) // hyperzine can't save you, fatty!
		. *= 1.5
	if(M_RUN in mutations)
		. *= 0.8

	if(reagents.has_reagent(NUKA_COLA))
		. *= 0.8
	if(reagents.has_reagent(MEDCORES))
		. *= MAGBOOTS_SLOWDOWN_HIGH //Chemical magboots, imagine.

	if(isslimeperson(src))
		if(reagents.has_any_reagents(HYPERZINES))
			. *= 2
		if(reagents.has_reagent(FROSTOIL))
			. *= 5
	// Bomberman stuff
	var/skate_bonus = 0
	var/disease_slow = 0
	for(var/obj/item/weapon/bomberman/dispenser in src)
		disease_slow = max(disease_slow, dispenser.slow)
		skate_bonus = max(skate_bonus, dispenser.speed_bonus) // if the player is carrying multiple BBD for some reason, he'll benefit from the speed bonus of the most upgraded one

	if(skate_bonus > 1)
		. *= 1/skate_bonus
	if(disease_slow > 0)
		. *= disease_slow * 6


/mob/living/carbon/human/Process_Spacemove(var/check_drift = 0)
	//Can we act
	if(restrained())
		return 0

	//Do we have a working jetpack
	if(istype(back, /obj/item/weapon/tank/jetpack))
		var/obj/item/weapon/tank/jetpack/J = back
		if(((!check_drift) || (check_drift && J.stabilization_on)) && (!lying) && (J.allow_thrust(0.01, src)))
			inertia_dir = 0
			return 1
//		if(!check_drift && J.allow_thrust(0.01, src))
//			return 1

	//If no working jetpack then use the other checks
	return ..()


/mob/living/carbon/human/Process_Spaceslipping(var/prob_slip = 5)
	//If knocked out we might just hit it and stop.  This makes it possible to get dead bodies and such.
	if(stat)
		prob_slip = 0 // Changing this to zero to make it line up with the comment, and also, make more sense.

	//Do we have magboots or such on if so no slip
	if(CheckSlip() == SLIP_HAS_MAGBOOTS)
		prob_slip = 0

	//Check hands and mod slip
	for(var/i = 1 to held_items.len)
		var/obj/item/I = held_items[i]

		if(!I)
			prob_slip -= 2
		else if(I.w_class <= W_CLASS_SMALL)
			prob_slip -= 1

	prob_slip = round(prob_slip)
	return(prob_slip)

/mob/living/carbon/human/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	. = ..()

	/*if(status_flags & FAKEDEATH)
		return 0*/

	if(.)
		if(shoes && istype(shoes, /obj/item/clothing/shoes))
			var/obj/item/clothing/shoes/S = shoes
			S.step_action()

		if(wear_suit && istype(wear_suit, /obj/item/clothing/suit))
			var/obj/item/clothing/suit/SU = wear_suit
			SU.step_action()

		for(var/obj/item/weapon/bomberman/dispenser in src)
			if(dispenser.spam_bomb)
				dispenser.attack_self(src)

/mob/living/carbon/human/CheckSlip(slip_on_walking = FALSE, overlay_type = TURF_WET_WATER, slip_on_magbooties = FALSE)
	var/shoes_slip_factor
	switch (overlay_type)
		if (TURF_WET_WATER, TURF_WET_ICE)
			shoes_slip_factor = shoes && (shoes.clothing_flags & NOSLIP)
		if (TURF_WET_LUBE)
			shoes_slip_factor = shoes && (shoes.clothing_flags & IGNORE_LUBE)
		else
			shoes_slip_factor = TRUE // Shoes are of no interest for this.

	var/magboots_slip_factor = (!slip_on_magbooties && shoes_slip_factor && (shoes.clothing_flags & MAGPULSE))
	. = ..()

	// We have magboots, and magboots can protect us
	if (. && magboots_slip_factor)
		return SLIP_HAS_MAGBOOTS
	// We don't have magboots, or magboots can't protect us
	return (. && !shoes_slip_factor)
