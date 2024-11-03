//Medical HUD

/datum/visioneffect/medical
	name = "medical hud"

/datum/visioneffect/medical/process_hud(var/mob/M)
	..()
	if(!(M in med_hud_users))
		med_hud_users += M
	if(!M.client)
		return
	var/client/C = M.client
	var/image/holder
	var/turf/T
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
				if(patient.check_can_revive() == CAN_REVIVE_IN_BODY)
					holder.icon_state = "huddead_revivable"
				else
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

		if(!ishuman(patient))
			continue

		var/mob/living/carbon/human/H = patient
		var/targetname = H.get_identification_name(H.get_face_name())
		var/physmedical = null
		var/mentmedical = null
		var/datum/data/record/gen_record = data_core.find_general_record_by_name(targetname)
		if(gen_record)
			physmedical = gen_record.fields["p_stat"]
			mentmedical = gen_record.fields["m_stat"]

		holder = patient.hud_list[PHYSRECORD_HUD]
		if(holder)
			switch(physmedical)
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

		holder = patient.hud_list[MENTRECORD_HUD]
		if(holder)
			switch(mentmedical)
				if("*Insane*")
					holder.icon_state = "hudinsane"
				if("*Unstable*")
					holder.icon_state = "hudunstable"
				if("*Watch*")
					holder.icon_state = "hudwatch"
				if("Stable")
					holder.icon_state = "hudblank"
			holder.pixel_y = 7 * PIXEL_MULTIPLIER
			C.images += holder
