//Implant HUD

/datum/visioneffect/implant
	name = "implant hud"

/datum/visioneffect/implant/process_hud(var/mob/M)
	..()
	if(!M.client)
		return
	var/client/C = M.client
	var/image/holder
	var/turf/T
	var/offset = 0
	if(M.hasHUD(HUD_MEDICAL))
		//hardcoded offset so that security huds will move aside for medical huds
		offset = 8
	offset = offset * PIXEL_MULTIPLIER
	T = get_turf(M)
	for(var/mob/living/carbon/human/perp in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(perp, M))
			continue

		for(var/obj/item/weapon/implant/I in perp)
			if(I.imp_in)
				if(istype(I,/obj/item/weapon/implant/tracking))
					holder = perp.hud_list[IMPTRACK_HUD]
					holder.icon_state = "hud_imp_tracking"
					holder.pixel_y = offset
				else if(istype(I,/obj/item/weapon/implant/loyalty))
					holder = perp.hud_list[IMPLOYAL_HUD]
					holder.icon_state = "hud_imp_loyal"
				else if(istype(I,/obj/item/weapon/implant/chem))
					holder = perp.hud_list[IMPCHEM_HUD]
					holder.icon_state = "hud_imp_chem"
					holder.pixel_y = offset
				else if(istype(I,/obj/item/weapon/implant/holy))
					holder = perp.hud_list[IMPHOLY_HUD]
					holder.icon_state = "hud_imp_holy"
					holder.pixel_y = offset
				else
					continue
				C.images += holder
