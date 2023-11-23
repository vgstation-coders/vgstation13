//Security HUD

/datum/hud/security
	name = "security hud"

/datum/hud/security/process_hud(var/mob/M)
	..()
	if(!(M in sec_hud_users))
		sec_hud_users += M
	var/client/C = M.client
	var/image/holder
	var/turf/T
	var/offset = 0
	if(M.hasHUD(HUD_MEDICAL))
		//hardcoded offset so that security huds will move aside for medical huds
		offset = 8
	offset = offset * PIXEL_MULTIPLIER
	T = get_turf(M)

	for(var/mob/living/simple_animal/astral_projection/perp in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(perp, M))
			continue
		holder = perp.hud_list[ID_HUD]
		if(!holder)
			continue
		holder.icon_state = "hud[ckey(perp.cardjob)]"
		holder.pixel_y = -offset
		C.images += holder

	for(var/mob/living/carbon/human/perp in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(perp, M))
			continue
		holder = perp.hud_list[ID_HUD]
		if(!holder)
			continue
		holder.icon_state = "hudno_id"
		if(perp.head && istype(perp.head,/obj/item/clothing/head/tinfoil)) //Tinfoil hat? Move along.
			holder.pixel_y = -offset
			C.images += holder
			continue
		var/obj/item/weapon/card/id/card = perp.get_id_card()
		if(card)
			holder.icon_state = "hud[ckey(card.GetJobName())]"
		holder.pixel_y = -offset
		C.images += holder

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

		var/perpname = perp.get_face_name()
		if(lowertext(perpname) == "unknown" || !perpname)
			perpname = perp.get_worn_id_name("Unknown")
		if(perpname)
			var/datum/data/record/R = find_record("name", perpname, data_core.security)
			if(R)
				holder = perp.hud_list[WANTED_HUD]
				switch(R.fields["criminal"])
					if("*High Threat*")
						holder.icon_state = "hudterminate"
					if("*Arrest*")
						holder.icon_state = "hudwanted"
					if("Incarcerated")
						holder.icon_state = "hudincarcerated"
					if("Parolled")
						holder.icon_state = "hudparolled"
					if("Released")
						holder.icon_state = "hudreleased"
					else
						continue
				holder.pixel_y = -offset
				C.images += holder
