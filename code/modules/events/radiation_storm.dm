/datum/event/radiation_storm
	announceWhen	= 1
	var/safe_zones = list(
		/area/engineering/engineering_auxiliary,
		/area/maintenance,
		/area/crew_quarters/sleep,
		/area/security/prison,
		/area/security/perma,
		/area/security/gas_chamber,
		/area/security/brig,
		/area/shuttle,
		/area/vox_station,
		/area/syndicate_station,
		/area/medical/coldstorage,
		/area/mine,
		/area/prison,
		/area/medical/patients_rooms,
		/area/medical/patient_room1,
		/area/medical/patient_room2
	)


/datum/event/radiation_storm/announce()
	// Don't do anything, we want to pack the announcement with the actual event

/datum/event/radiation_storm/proc/is_safe_zone(var/area/A)
	for(var/szt in safe_zones)
		if(istype(A, szt))
			return 1
	return 0

/datum/event/radiation_storm/start()
	spawn()
		command_alert(/datum/command_alert/radiation_storm)

		for(var/area/A in areas)
			if(A.z != map.zMainStation || is_safe_zone(A))
				continue
			var/area/ma = get_area(A)
			ma.radiation_alert()

		make_maint_all_access()


		sleep(30 SECONDS)


		command_alert(/datum/command_alert/radiation_storm/start)

		for(var/i = 0, i < 15, i++)
			var/irradiationThisBurst = rand(15,25) //everybody gets the same rads this radiation burst
			var/randomMutation = prob(50)
			var/badMutation = prob(50)
			for(var/mob/living/carbon/human/H in living_mob_list)
				if(istype(H.loc, /obj/spacepod))
					continue
				var/turf/T = get_turf(H)
				if(!T)
					continue
				if(T.z != map.zMainStation || is_safe_zone(T.loc))
					continue

				var/applied_rads = (H.apply_radiation(irradiationThisBurst,RAD_EXTERNAL) > (irradiationThisBurst/4))
				if(randomMutation && applied_rads)
					if (badMutation)
						//H.apply_effect((rand(25,50)),IRRADIATE,0)
						randmutb(H) // Applies bad mutation
						domutcheck(H,null,MUTCHK_FORCED)
					else
						randmutg(H) // Applies good mutation
						domutcheck(H,null,MUTCHK_FORCED)

			sleep(25)


		command_alert(/datum/command_alert/radiation_storm/end)

		for(var/area/A in areas)
			if(A.z != map.zMainStation || is_safe_zone(A))
				continue
			var/area/ma = get_area(A)
			ma.reset_radiation_alert()


		sleep(600) // Want to give them time to get out of maintenance.


		revoke_maint_all_access()
