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
		/area/security/toilet,
		/area/shuttle,
		/area/vox_station,
		/area/medical/coldstorage,
		/area/mine,
		/area/prison,
		/area/medical/patients_rooms,
		/area/medical/patient_room1,
		/area/medical/patient_room2,
		/area/derelictparts,
		/area/vox_trading_post,
	)

/datum/event/radiation_storm/can_start(var/list/active_with_role)
	if(active_with_role["Any"] > 6)
		return 50
	return 0

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

		make_doors_all_access(list(access_maint_tunnels))


		sleep(30 SECONDS)


		command_alert(/datum/command_alert/radiation_storm/start)

		for(var/i = 0, i < 15, i++)
			var/irradiationThisBurst = rand(15,25) //everybody gets the same rads this radiation burst
			for(var/obj/machinery/power/rad_collector/R in rad_collectors)
				var/turf/T = get_turf(R)
				if(!T)
					continue
				if(T.z != map.zMainStation || is_safe_zone(T.loc))
					continue
				R.receive_pulse(irradiationThisBurst * 50)
			for(var/obj/item/weapon/am_containment/decelerator/D in decelerators)
				var/turf/T = get_turf(D)
				if(!T)
					continue
				if(T.z != map.zMainStation || is_safe_zone(T.loc))
					continue
				D.receive_pulse(irradiationThisBurst * 50)

			var/randomMutation
			var/badMutation
			for(var/mob/living/carbon/human/H in living_mob_list)
				if(istype(H.loc, /obj/spacepod))
					continue
				var/turf/T = get_turf(H)
				if(!T)
					continue
				if(T.z != map.zMainStation || is_safe_zone(T.loc))
					continue
				randomMutation = prob(50)
				var/applied_rads = (H.apply_radiation(irradiationThisBurst,RAD_EXTERNAL) > (irradiationThisBurst/4))
				if(randomMutation && applied_rads)
					//luck plays a role in the mutations acquired
					badMutation = H?.lucky_prob(50, -1/10)
					if(badMutation)
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


		revoke_doors_all_access(list(access_maint_tunnels))
