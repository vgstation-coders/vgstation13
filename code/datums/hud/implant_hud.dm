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
		offset = 4
	offset = offset * PIXEL_MULTIPLIER
	T = get_turf(M)
	for(var/mob/living/carbon/human/perp in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(perp, M))
			continue
		if(perp.head && istype(perp.head,/obj/item/clothing/head/tinfoil)) //Tinfoil hat? Move along.
			continue
		for(var/obj/item/weapon/implant/I in perp)
			if(I.imp_in)
				if(istype(I,/obj/item/weapon/implant/tracking))
					if(!offset)
						holder = perp.hud_list[IMPTRACK_HUD]
					else
						holder = perp.hud_list[IMPTRACK_HUD + "_shifted"]
						if(!istype(holder, /image/hud))
							perp.hud_list[IMPTRACK_HUD + "_shifted"] = new/image/hud('icons/mob/hud.dmi', perp, "hudblank")
							holder = perp.hud_list[IMPTRACK_HUD + "_shifted"]
							holder.pixel_y = offset
					holder.icon_state = "hud_imp_tracking"
				else if(istype(I,/obj/item/weapon/implant/chem))
					if(!offset)
						holder = perp.hud_list[IMPCHEM_HUD]
					else
						holder = perp.hud_list[IMPCHEM_HUD + "_shifted"]
						if(!istype(holder, /image/hud))
							perp.hud_list[IMPCHEM_HUD + "_shifted"] = new/image/hud('icons/mob/hud.dmi', perp, "hudblank")
							holder = perp.hud_list[IMPCHEM_HUD + "_shifted"]
							holder.pixel_y = offset
					holder.icon_state = "hud_imp_chem"
				else if(istype(I,/obj/item/weapon/implant/holy))
					if(!offset)
						holder = perp.hud_list[IMPHOLY_HUD]
					else
						holder = perp.hud_list[IMPHOLY_HUD + "_shifted"]
						if(!istype(holder, /image/hud))
							perp.hud_list[IMPHOLY_HUD + "_shifted"] = new/image/hud('icons/mob/hud.dmi', perp, "hudblank")
							holder = perp.hud_list[IMPHOLY_HUD + "_shifted"]
							holder.pixel_y = offset
					holder.icon_state = "hud_imp_holy"
				else if(istype(I,/obj/item/weapon/implant/loyalty))
					holder = perp.hud_list[IMPLOYAL_HUD]
					holder.icon_state = "hud_imp_loyal"
				else
					continue
				C.images += holder
