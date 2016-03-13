/datum/universal_state/blowout
	name = "Nuclear Blowout"
	desc = "BLOWOUT NOW, FELLOW SPESSMAN"

	var/safe_zones = list(
		/area/maintenance,
		/area/crew_quarters/sleep,
		/area/security/prison,
		/area/security/perma,
		/area/security/gas_chamber,
		/area/security/brig,
		/area/shuttle,
		/area/vox_station,
		/area/syndicate_station
	)

/datum/universal_state/blowout/proc/is_safe_zone(var/area/A)
	for(var/szt in safe_zones)
		if(is_type_in_list(A, safe_zones))
			return 1
	return 0

/datum/universal_state/blowout/OnShuttleCall(var/mob/user)
	return 1

// Apply changes when entering state
/datum/universal_state/blowout/OnEnter()
	to_chat(world, "<span class='sinister' style='font-size:22pt'>You are blinded by a flash of color and light.</span>")

	if (emergency_shuttle)
		emergency_shuttle.incall()
		emergency_shuttle.can_recall = 0
		emergency_shuttle.settimeleft(600)

	to_chat(world, sound('sound/AI/radiation.ogg'))
	var/txt = {"A massive radiation spike has been detected at your station, and its levels are rapidly increasing.

We are sending an emergency shuttle to your station. Please wait in a shielded area if you can.

Be safe, crew of [station_name]."}
	command_alert(txt, "Anomaly Alert")

	for(var/area/A in areas)
		if(A.z != map.zMainStation || is_safe_zone(A))
			continue
		var/area/ma = get_area_master(A)
		ma.radiation_alert()

	make_maint_all_access()

	ticker.StartThematic("endgame")

	for(var/i = 0, i < 360, i++)
		var/irradiationThisBurst = rand(15,25) //everybody gets the same rads this radiation burst
		var/randomMutation = prob(50)
		var/badMutation = prob(50)
		for(var/mob/living/carbon/human/H in living_mob_list)
			if(istype(H.loc, /obj/spacepod))
				continue
			var/turf/T = get_turf(H)
			if(!T)
				continue
			if(T.z != 1 || is_safe_zone(T.loc))
				continue

			var/applied_rads = (H.apply_effect(irradiationThisBurst,IRRADIATE,0) > (irradiationThisBurst/4))
			if(randomMutation && applied_rads)
				if (badMutation)
					//H.apply_effect((rand(25,50)),IRRADIATE,0)
					randmutb(H) // Applies bad mutation
					domutcheck(H,null,MUTCHK_FORCED)
				else
					randmutg(H) // Applies good mutation
					domutcheck(H,null,MUTCHK_FORCED)

		sleep(25)