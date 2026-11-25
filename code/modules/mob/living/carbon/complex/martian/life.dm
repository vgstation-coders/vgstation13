
/mob/living/carbon/complex/martian/get_breath_from_internal(volume_needed)
	//As this is a race that can only wear helmets, we'll have a fishbowl helmet that can accept tanks in place of having gas mask setups
	if(head && istype(head, /obj/item/clothing/head/helmet/space/martian))
		var/obj/item/clothing/head/helmet/space/martian/fishbowl = head
		if(fishbowl.tank && istype(fishbowl.tank, /obj/item/weapon/tank))
			var/obj/item/weapon/tank/internals = fishbowl.tank
			return internals.remove_air_volume(volume_needed)
	return null

/mob/living/carbon/complex/martian/check_breath_block(var/flag_check = BLOCK_BREATHING)
	return (flag_check & BLOCK_GAS_SMOKE_EFFECT) ? istype(head, /obj/item/clothing/head/helmet/space/martian) : FALSE

/mob/living/carbon/complex/martian/is_spaceproof()
	if(head && istype(head, /obj/item/clothing/head/helmet/space/martian))
		return TRUE
	return ..()

/mob/living/carbon/complex/martian/get_thermal_protection_flags()
	var/thermal_protection_flags = 0
	if(head)
		thermal_protection_flags |= head.body_parts_covered
	return thermal_protection_flags

/mob/living/carbon/complex/martian/get_cold_protection()

	if(M_RESIST_COLD in mutations)
		return 1 //Fully protected from the cold.

	var/thermal_protection = 0.0

	if(head)
		thermal_protection += head.return_thermal_protection()

	var/max_protection = get_thermal_protection(get_thermal_protection_flags())
	return min(thermal_protection,max_protection)
