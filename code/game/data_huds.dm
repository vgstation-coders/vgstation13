/* Using the HUD procs is simple. Call these procs in the life.dm of the intended mob.
Use the regular_hud_updates() proc before process_med_hud(mob) or process_sec_hud(mob) so
the HUD updates properly! */

//Deletes the current HUD images so they can be refreshed with new ones.
/mob/proc/regular_hud_updates() //Used in the life.dm of mobs that can use HUDs.
	if(client)
		for(var/image/hud in client.images)
			if(findtext(hud.icon_state, "hud", 1, 4))
				client.images -= hud
	if(src in med_hud_users)
		med_hud_users -= src
	if(src in sec_hud_users)
		sec_hud_users -= src
	diagnostic_hud_users -= src

/proc/check_HUD_visibility(var/atom/target, var/mob/user)
	if (user in confusion_victims)
		return FALSE
	if(user.see_invisible < target.invisibility)
		return FALSE
	if(target.alpha <= 1)
		return FALSE
	if(ismob(target))
		var/mob/M = target
		for(var/i in M.alphas)
			if(M.alphas[i] <= 1)
				return FALSE
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		for(var/i in C.body_alphas)
			if(C.body_alphas[i] <= 1)
				return FALSE
	return TRUE

//Medical HUD outputs. Called by the Life() proc of the mob using it, usually.
/proc/process_med_hud(var/mob/M, var/mob/eye)
	if(!M)
		return
	if(!M.client)
		return
	if(!(M in med_hud_users))
		med_hud_users += M
	var/client/C = M.client
	var/image/holder
	var/turf/T
	if(eye)
		T = get_turf(eye)
	else
		T = get_turf(M)
	for(var/mob/living/simple_animal/mouse/patient in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(patient, M))
			continue
		if(!C)
			continue
		holder = patient.hud_list[STATUS_HUD]
		if(holder)
			if(patient.isDead())
				holder.icon_state = "huddead"
			else if(patient.status_flags & XENO_HOST)
				holder.icon_state = "hudxeno"
			else if(has_recorded_disease(patient))
				holder.icon_state = "hudill_old"
			else
				var/dangerosity = has_recorded_virus2(patient)
				switch (dangerosity)
					if (1)
						holder.icon_state = "hudill"
					if (2)
						holder.icon_state = "hudill_safe"
					if (3)
						holder.icon_state = "hudill_danger"
					else
						holder.icon_state = "hudhealthy"
			C.images += holder

	for(var/mob/living/simple_animal/hostile/necro/zombie/patient in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(patient, M))
			continue
		if(!C)
			continue
		holder = patient.hud_list[STATUS_HUD]
		if (holder)
			if(patient.isDead())
				holder.icon_state = "huddead"
			else
				holder.icon_state = "hudundead"
			C.images += holder

	for(var/mob/living/carbon/patient in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if (ishuman(patient))
			var/mob/living/carbon/human/H = patient
			if(H.head && istype(H.head,/obj/item/clothing/head/tinfoil)) //Tinfoil hat? Move along.
				continue
		if(!check_HUD_visibility(patient, M))
			continue
		if(!C)
			continue

		holder = patient.hud_list[HEALTH_HUD]

		if(holder)
			if(patient.isDead())
				holder.icon_state = "hudhealth-100"
			else
				holder.icon_state = "hud[RoundHealth(patient.health)]"
			C.images += holder

		holder = patient.hud_list[STATUS_HUD]
		if(holder)
			if(patient.isDead())
				holder.icon_state = "huddead"
			else if(patient.status_flags & XENO_HOST)
				holder.icon_state = "hudxeno"
			else if(has_recorded_disease(patient))
				holder.icon_state = "hudill_old"
			else
				var/dangerosity = has_recorded_virus2(patient)
				switch (dangerosity)
					if (1)
						holder.icon_state = "hudill"
					if (2)
						holder.icon_state = "hudill_safe"
					if (3)
						holder.icon_state = "hudill_danger"
					else
						holder.icon_state = "hudhealthy"
			C.images += holder

		holder = patient.hud_list[RECORD_HUD]
		if(holder && ishuman(patient))
			var/mob/living/carbon/human/H = patient
			var/targetname = H.get_identification_name(H.get_face_name())
			var/medical = null
			var/datum/data/record/gen_record = data_core.find_general_record_by_name(targetname)
			if(gen_record)
				medical = gen_record.fields["p_stat"]
			switch(medical)
				if("*SSD*")
					holder.icon_state = "hudssd"
				if("*Deceased*")
					holder.icon_state = "huddeceased"
				if("Physically Unfit")
					holder.icon_state = "hudunfit"
				if("Active")
					holder.icon_state = "hudactive"
				if("Disabled")
					holder.icon_state = "huddisabled"
			C.images += holder


//Security HUDs. Pass a value for the second argument to enable implant viewing or other special features.
/proc/process_sec_hud(var/mob/M, var/advanced_mode,var/mob/eye)
	if(!M)
		return
	if(!M.client)
		return
	if(!(M in sec_hud_users))
		sec_hud_users += M
	var/client/C = M.client
	var/image/holder
	var/turf/T
	if(eye)
		T = get_turf(eye)
	else
		T = get_turf(M)

	for(var/mob/living/simple_animal/astral_projection/perp in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(perp, M))
			continue
		holder = perp.hud_list[ID_HUD]
		if(!holder)
			continue
		holder.icon_state = "hud[ckey(perp.cardjob)]"
		C.images += holder

	for(var/mob/living/carbon/human/perp in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(perp, M))
			continue
		holder = perp.hud_list[ID_HUD]
		if(!holder)
			continue
		holder.icon_state = "hudno_id"
		if(perp.head && istype(perp.head,/obj/item/clothing/head/tinfoil)) //Tinfoil hat? Move along.
			C.images += holder
			continue
		var/obj/item/weapon/card/id/card = perp.get_id_card()
		if(card)
			holder.icon_state = "hud[ckey(card.GetJobName())]"
		C.images += holder

		if(advanced_mode) //If set, the SecHUD will display the implants a person has.
			for(var/obj/item/weapon/implant/I in perp)
				if(I.imp_in)
					if(istype(I,/obj/item/weapon/implant/tracking))
						holder = perp.hud_list[IMPTRACK_HUD]
						holder.icon_state = "hud_imp_tracking"
					else if(istype(I,/obj/item/weapon/implant/loyalty))
						holder = perp.hud_list[IMPLOYAL_HUD]
						holder.icon_state = "hud_imp_loyal"
					else if(istype(I,/obj/item/weapon/implant/chem))
						holder = perp.hud_list[IMPCHEM_HUD]
						holder.icon_state = "hud_imp_chem"
					else if(istype(I,/obj/item/weapon/implant/holy))
						holder = perp.hud_list[IMPHOLY_HUD]
						holder.icon_state = "hud_imp_holy"
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
				C.images += holder

/proc/process_diagnostic_hud(var/mob/M, var/mob/eye)
	if(!M || !M.client)
		return
	diagnostic_hud_users |= M

	var/client/C = M.client
	var/image/holder
	var/turf/T = eye ? get_turf(eye) : get_turf(M)

	for(var/mob/living/silicon/robot/borg in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(borg, M))
			continue

		holder = borg.hud_list[DIAG_HEALTH_HUD]
		if(holder)
			C.images += holder
			if(borg.isDead())
				holder.icon_state = "huddiagdead"
			else
				holder.icon_state = cyborg_health_to_icon_state(borg.health / borg.maxHealth)

		holder = borg.hud_list[DIAG_CELL_HUD]
		if(holder)
			C.images += holder
			var/obj/item/weapon/cell/borg_cell = borg.get_cell()
			if(!borg_cell)
				holder.icon_state = "hudnobatt"
			else
				var/charge_ratio = borg_cell.charge / borg_cell.maxcharge
				holder.icon_state = power_cell_charge_to_icon_state(charge_ratio)

	for(var/obj/mecha/exosuit in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(exosuit, M))
			continue

		holder = exosuit.hud_list[DIAG_HEALTH_HUD]
		if(holder)
			C.images += holder
			var/integrity_ratio = exosuit.health / initial(exosuit.health)
			holder.icon_state = mech_integrity_to_icon_state(integrity_ratio)

		holder = exosuit.hud_list[DIAG_CELL_HUD]
		if(holder)
			C.images += holder
			var/obj/item/weapon/cell/exosuit_cell = exosuit.get_cell()
			if(!exosuit_cell)
				holder.icon_state = "hudnobatt"
			else
				var/charge_ratio = exosuit_cell.charge / exosuit_cell.maxcharge
				holder.icon_state = power_cell_charge_to_icon_state(charge_ratio)


//Unsure of where to put this, but since most of it is HUDs it seemed fitting to go here.
/mob/proc/handle_glasses_vision_updates(var/obj/item/clothing/glasses/G)
	if(istype(G))
		if(G.see_in_dark)
			see_in_dark = max(see_in_dark, G.see_in_dark)
		see_in_dark += G.darkness_view
		if(G.vision_flags) //MESONS
			change_sight(adding = G.vision_flags)
			if(!druggy)
				see_invisible = SEE_INVISIBLE_MINIMUM
		if(G.see_invisible)
			see_invisible = G.see_invisible

	seedarkness = G.seedarkness
	update_darkness()

	/* HUD shit goes here, as long as it doesn't modify sight flags
	 * The purpose of this is to stop xray and w/e from preventing you from using huds -- Love, Doohl
	 */

	if(istype(G, /obj/item/clothing/glasses/sunglasses/sechud))
		var/obj/item/clothing/glasses/sunglasses/sechud/O = G
		if(O.hud)
			O.hud.process_hud(src)
		if(!druggy)
			see_invisible = SEE_INVISIBLE_LIVING
	else if(istype(G, /obj/item/clothing/glasses/hud))
		var/obj/item/clothing/glasses/hud/O = G
		O.process_hud(src)
		if(!druggy)
			see_invisible = SEE_INVISIBLE_LIVING

//Artificer HUD
/proc/process_construct_hud(var/mob/M, var/mob/eye)
	if(!M)
		return
	if(!M.client)
		return
	var/client/C = M.client
	var/image/holder
	var/turf/T
	if(eye)
		T = get_turf(eye)
	else
		T = get_turf(M)
	for(var/mob/living/simple_animal/construct/construct in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(construct, M))
			continue

		holder = construct.hud_list[CONSTRUCT_HUD]
		if(holder)
			if(construct.isDead())
				holder.icon_state = "consthealth0"
			else
				holder.icon_state = "consthealth[10*round((construct.health/construct.maxHealth)*10)]"
			holder.plane = ABOVE_LIGHTING_PLANE
			C.images += holder
