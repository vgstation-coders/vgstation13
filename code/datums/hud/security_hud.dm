//Security HUD
//Shows arrest status and gives access to security records

/datum/visioneffect/security
	name = "security hud"

/datum/visioneffect/security/arrest
	name = "arrest-setting security hud"

/datum/visioneffect/security/process_hud(var/mob/M)
	..()
	if(!M.client)
		return
	if(!(M in sec_hud_users))
		sec_hud_users += M
	var/client/C = M.client
	var/image/holder
	var/turf/T
	var/offset = 0
	if(M.hasHUD(HUD_MEDICAL))
		//hardcoded offset so that security huds will move aside for medical huds
		offset = -8
	offset = offset * PIXEL_MULTIPLIER
	T = get_turf(M)

	for(var/mob/living/carbon/human/perp in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(perp, M))
			continue
		if(perp.head && istype(perp.head,/obj/item/clothing/head/tinfoil)) //Tinfoil hat? Move along.
			continue
		var/perpname = perp.get_face_name()
		if(lowertext(perpname) == "unknown" || !perpname)
			perpname = perp.get_worn_id_name("Unknown")
		if(perpname)
			var/datum/data/record/R = find_record("name", perpname, data_core.security)
			if(R)
				if(!offset)
					holder = perp.hud_list[WANTED_HUD]
				else
					holder = perp.hud_list[WANTED_HUD + "_shifted"]
					if(!istype(holder, /image/hud))
						perp.hud_list[WANTED_HUD + "_shifted"] = new/image/hud('icons/mob/hud.dmi', perp, "hudblank")
						holder = perp.hud_list[WANTED_HUD + "_shifted"]
						holder.pixel_y = offset
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
				C.images += holder
