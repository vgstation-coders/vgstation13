
/mob/living/carbon/complex/martian/get_breath_from_internal(volume_needed)
	//As this is a race that can only wear helmets, we'll have a fishbowl helmet that can accept tanks in place of having gas mask setups
	if(head && istype(head, /obj/item/clothing/head/helmet/space/martian))
		var/obj/item/clothing/head/helmet/space/martian/fishbowl = head
		if(fishbowl.tank && istype(fishbowl.tank, /obj/item/weapon/tank))
			var/obj/item/weapon/tank/internals = fishbowl.tank
			return internals.remove_air_volume(volume_needed)
	return null

/mob/living/carbon/complex/martian/breathe()
	.=..()
	var/block = 0
	if(head)
		if(istype(head, /obj/item/clothing/head/helmet/space/martian))
			block = 1

	if(!block)
		for(var/obj/effect/effect/smoke/chem/smoke in view(1, src))
			if(smoke.reagents.total_volume)
				smoke.reagents.reaction(src, INGEST)
				spawn(5)
					if(smoke)
						smoke.reagents.copy_to(src, 10) // I dunno, maybe the reagents enter the blood stream through the lungs?
				break // If they breathe in the nasty stuff once, no need to continue checking

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
