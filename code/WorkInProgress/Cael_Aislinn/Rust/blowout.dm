/datum/universal_state/blowout
	name = "Nuclear Blowout"
	desc = "BLOWOUT NOW, FELLOW SPESSMAN"

	decay_rate = 5 // 5% chance of a turf decaying on lighting update/airflow (there's no actual tick for turfs)

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
		if(istype(A, szt))
			return 1
	return 0

/datum/universal_state/blowout/OnShuttleCall(var/mob/user)
	return 1
	/*
	if(user)
		to_chat(user, "<span class='sinister'>All you hear on the frequency is static and panicked screaming. There will be no shuttle call today.</span>")
	return 0
	*/

/datum/universal_state/blowout/OnTurfChange(var/turf/T)
	if(T.name == "space")
		T.overlays += "hell01"
		T.underlays -= "hell01"
	else
		T.overlays -= "hell01"

// Apply changes when entering state
/datum/universal_state/blowout/OnEnter()

	to_chat(world, sound('sound/AI/radiation.ogg'))
	command_alert("High levels of radiation detected near the station, ETA in 30 seconds. Please evacuate into one of the shielded maintenance tunnels.", "Anomaly Alert")

	for(var/area/A in areas)
		if(A.z != 1 || is_safe_zone(A))
			continue
		var/area/ma = get_area_master(A)
		ma.radiation_alert()

	make_maint_all_access()

	ticker.StartThematic("endgame")

/datum/universal_state/blowout/OnTurfTick()
	var/irradiationThisBurst = rand(1,2) //everybody gets the same rads this radiation burst
	var/randomMutation = prob(5)
	var/badMutation = prob(5)
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