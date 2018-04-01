
/mob/living/proc/get_bodypart(zone)
	return

/mob/living/carbon/get_bodypart(zone)
	if(!zone)
		zone = BODY_ZONE_CHEST
	for(var/X in bodyparts)
		var/obj/item/bodypart/L = X
		if(L.body_zone == zone)
			return L

/mob/living/carbon/has_hand_for_held_index(i)
	if(i)
		var/obj/item/bodypart/L = hand_bodyparts[i]
		if(L)
			return L
	return FALSE




/mob/proc/has_left_hand()
	return TRUE

/mob/living/carbon/has_left_hand()
	for(var/obj/item/bodypart/L in hand_bodyparts)
		if(L.held_index % 2)
			return TRUE
	return FALSE

/mob/living/carbon/alien/larva/has_left_hand()
	return 1


/mob/proc/has_right_hand()
	return TRUE

/mob/living/carbon/has_right_hand()
	for(var/obj/item/bodypart/L in hand_bodyparts)
		if(!(L.held_index % 2))
			return TRUE
	return FALSE

/mob/living/carbon/alien/larva/has_right_hand()
	return 1



//Limb numbers
/mob/proc/get_num_arms()
	return 2

/mob/living/carbon/get_num_arms()
	. = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/affecting = X
		if(affecting.body_part == ARM_RIGHT)
			.++
		if(affecting.body_part == ARM_LEFT)
			.++


//sometimes we want to ignore that we don't have the required amount of arms.
/mob/proc/get_arm_ignore()
	return 0

/mob/living/carbon/alien/larva/get_arm_ignore()
	return 1 //so we can still handcuff larvas.


/mob/proc/get_num_legs()
	return 2

/mob/living/carbon/get_num_legs()
	. = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/affecting = X
		if(affecting.body_part == LEG_RIGHT)
			.++
		if(affecting.body_part == LEG_LEFT)
			.++

//sometimes we want to ignore that we don't have the required amount of legs.
/mob/proc/get_leg_ignore()
	return FALSE

/mob/living/carbon/alien/larva/get_leg_ignore()
	return TRUE

/mob/living/carbon/human/get_leg_ignore()
	if((movement_type & FLYING) || floating)
		return TRUE
	return FALSE

/mob/living/proc/get_missing_limbs()
	return list()

/mob/living/carbon/get_missing_limbs()
	var/list/full = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	for(var/zone in full)
		if(get_bodypart(zone))
			full -= zone
	return full

/mob/living/carbon/alien/larva/get_missing_limbs()
	var/list/full = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST)
	for(var/zone in full)
		if(get_bodypart(zone))
			full -= zone
	return full

//Remove all embedded objects from all limbs on the carbon mob
/mob/living/carbon/proc/remove_all_embedded_objects()
	var/turf/T = get_turf(src)

	for(var/X in bodyparts)
		var/obj/item/bodypart/L = X
		for(var/obj/item/I in L.embedded_objects)
			L.embedded_objects -= I
			I.forceMove(T)

	clear_alert("embeddedobject")
	SendSignal(COMSIG_CLEAR_MOOD_EVENT, "embedded")

/mob/living/carbon/proc/has_embedded_objects()
	. = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/L = X
		for(var/obj/item/I in L.embedded_objects)
			return 1


//Helper for quickly creating a new limb - used by augment code in species.dm spec_attacked_by
/mob/living/carbon/proc/newBodyPart(zone, robotic, fixed_icon)
	var/obj/item/bodypart/L
	switch(zone)
		if(BODY_ZONE_L_ARM)
			L = new /obj/item/bodypart/l_arm()
		if(BODY_ZONE_R_ARM)
			L = new /obj/item/bodypart/r_arm()
		if(BODY_ZONE_HEAD)
			L = new /obj/item/bodypart/head()
		if(BODY_ZONE_L_LEG)
			L = new /obj/item/bodypart/l_leg()
		if(BODY_ZONE_R_LEG)
			L = new /obj/item/bodypart/r_leg()
		if(BODY_ZONE_CHEST)
			L = new /obj/item/bodypart/chest()
	if(L)
		L.update_limb(fixed_icon, src)
		if(robotic)
			L.change_bodypart_status(BODYPART_ROBOTIC)
	. = L

/mob/living/carbon/monkey/newBodyPart(zone, robotic, fixed_icon)
	var/obj/item/bodypart/L
	switch(zone)
		if(BODY_ZONE_L_ARM)
			L = new /obj/item/bodypart/l_arm/monkey()
		if(BODY_ZONE_R_ARM)
			L = new /obj/item/bodypart/r_arm/monkey()
		if(BODY_ZONE_HEAD)
			L = new /obj/item/bodypart/head/monkey()
		if(BODY_ZONE_L_LEG)
			L = new /obj/item/bodypart/l_leg/monkey()
		if(BODY_ZONE_R_LEG)
			L = new /obj/item/bodypart/r_leg/monkey()
		if(BODY_ZONE_CHEST)
			L = new /obj/item/bodypart/chest/monkey()
	if(L)
		L.update_limb(fixed_icon, src)
		if(robotic)
			L.change_bodypart_status(BODYPART_ROBOTIC)
	. = L

/mob/living/carbon/alien/larva/newBodyPart(zone, robotic, fixed_icon)
	var/obj/item/bodypart/L
	switch(zone)
		if(BODY_ZONE_HEAD)
			L = new /obj/item/bodypart/head/larva()
		if(BODY_ZONE_CHEST)
			L = new /obj/item/bodypart/chest/larva()
	if(L)
		L.update_limb(fixed_icon, src)
		if(robotic)
			L.change_bodypart_status(BODYPART_ROBOTIC)
	. = L

/mob/living/carbon/alien/humanoid/newBodyPart(zone, robotic, fixed_icon)
	var/obj/item/bodypart/L
	switch(zone)
		if(BODY_ZONE_L_ARM)
			L = new /obj/item/bodypart/l_arm/alien()
		if(BODY_ZONE_R_ARM)
			L = new /obj/item/bodypart/r_arm/alien()
		if(BODY_ZONE_HEAD)
			L = new /obj/item/bodypart/head/alien()
		if(BODY_ZONE_L_LEG)
			L = new /obj/item/bodypart/l_leg/alien()
		if(BODY_ZONE_R_LEG)
			L = new /obj/item/bodypart/r_leg/alien()
		if(BODY_ZONE_CHEST)
			L = new /obj/item/bodypart/chest/alien()
	if(L)
		L.update_limb(fixed_icon, src)
		if(robotic)
			L.change_bodypart_status(BODYPART_ROBOTIC)
	. = L


/proc/skintone2hex(skin_tone)
	. = 0
	switch(skin_tone)
		if("caucasian1")
			. = "ffe0d1"
		if("caucasian2")
			. = "fcccb3"
		if("caucasian3")
			. = "e8b59b"
		if("latino")
			. = "d9ae96"
		if("mediterranean")
			. = "c79b8b"
		if("asian1")
			. = "ffdeb3"
		if("asian2")
			. = "e3ba84"
		if("arab")
			. = "c4915e"
		if("indian")
			. = "b87840"
		if("african1")
			. = "754523"
		if("african2")
			. = "471c18"
		if("albino")
			. = "fff4e6"
		if("orange")
			. = "ffc905"

/mob/living/carbon/proc/Digitigrade_Leg_Swap(swap_back)
	var/body_plan_changed = FALSE
	for(var/X in bodyparts)
		var/obj/item/bodypart/O = X
		var/obj/item/bodypart/N
		if((!O.use_digitigrade && swap_back == FALSE) || (O.use_digitigrade && swap_back == TRUE))
			if(O.body_part == LEG_LEFT)
				if(swap_back == TRUE)
					N = new /obj/item/bodypart/l_leg
				else
					N = new /obj/item/bodypart/l_leg/digitigrade
			else if(O.body_part == LEG_RIGHT)
				if(swap_back == TRUE)
					N = new /obj/item/bodypart/r_leg
				else
					N = new /obj/item/bodypart/r_leg/digitigrade
		if(!N)
			continue
		body_plan_changed = TRUE
		O.drop_limb(1)
		qdel(O)
		N.attach_limb(src)
	if(body_plan_changed && ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.w_uniform)
			var/obj/item/clothing/under/U = H.w_uniform
			if(U.mutantrace_variation)
				if(swap_back)
					U.adjusted = NORMAL_STYLE
				else
					U.adjusted = DIGITIGRADE_STYLE
				H.update_inv_w_uniform()
		if(H.shoes && !swap_back)
			H.dropItemToGround(H.shoes)
