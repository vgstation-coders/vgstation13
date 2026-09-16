//////// Micro Meteors ////////
/datum/event/micro_meteors
	announceWhen = 0
	endWhen = 10

/datum/event/micro_meteors/can_start()
	return 20

/datum/event/micro_meteors/announce()
	captain_announce("Sensors detect incoming micro-debris field. Brace for impact.")

/datum/event/micro_meteors/start()
	spawn(5 SECONDS)
		var/count = rand(4, 8)
		for(var/i = 1 to count)
			var/meteor_type = /obj/item/projectile/meteor/small/microdebris
			if(prob(25))
				meteor_type = /obj/item/projectile/meteor/small
			odyssey_shuttle.spawn_vz_meteor(meteor_type)
			sleep(rand(3, 5))

//////// Gib Storm ////////
/datum/event/gib_storm
	announceWhen = 0
	endWhen = 10

/datum/event/gib_storm/can_start()
	return 40

/datum/event/gib_storm/announce()
	captain_announce("Warning: Unidentified organic matter on collision course. Brace for impact.")

/datum/event/gib_storm/start()
	spawn(5 SECONDS)
		var/count = rand(8, 15)
		for(var/i = 1 to count)
			odyssey_shuttle.spawn_vz_meteor(/obj/item/projectile/meteor/gib)
			sleep(rand(2, 4))

//////// Solar Flare ////////
/datum/event/solar_flare
	announceWhen = 1
	endWhen = 5

/datum/event/solar_flare/can_start()
	return 10

/datum/event/solar_flare/announce()
	captain_announce("Solar flare detected. Electrical systems may be affected.")

/datum/event/solar_flare/start()
	var/duration = rand(30 SECONDS, 2 MINUTES)
	var/list/affected_apcs = list()

	for(var/obj/machinery/power/apc/A in odyssey_shuttle.shuttle_contents())
		if(A.cell)
			A.old_charge = A.cell.charge
			A.cell.charge = 0
		A.chargemode = 0
		A.operating = 0
		A.update()
		A.update_icon()
		affected_apcs += A

	spawn(duration)
		for(var/obj/machinery/power/apc/A in affected_apcs)
			if(A && !A.gcDestroyed)
				if(A.cell && A.old_charge)
					A.cell.charge = A.old_charge / 2
				A.chargemode = 1
				A.operating = 1
				A.update()
				A.update_icon()
		captain_announce("Electrical systems have stabilized. Power is being restored.")

//////// Space Carp ////////
/datum/event/odyssey_carp_swarm
	announceWhen = 1
	endWhen = 5

/datum/event/odyssey_carp_swarm/can_start()
	return 15

/datum/event/odyssey_carp_swarm/announce()
	captain_announce("Biosensors detect hostile fauna approaching the ship.")

/datum/event/odyssey_carp_swarm/start()
	var/datum/virtual_z/vz = odyssey_shuttle.current_port.get_virtual_z()
	if(!vz)
		return

	var/count = rand(4, 8)

	// Find space turfs near the shuttle
	var/list/shuttle_turfs = list()
	for(var/turf/T in odyssey_shuttle.shuttle_contents())
		shuttle_turfs += T
	if(!shuttle_turfs.len)
		return

	var/turf/center = shuttle_turfs[round(shuttle_turfs.len / 2) + 1]
	var/list/space_turfs = list()
	for(var/turf/space/SP in range(50, center))
		if(!(SP in shuttle_turfs))
			space_turfs += SP

	if(!space_turfs.len)
		return

	for(var/i = 1 to count)
		var/turf/T = pick(space_turfs)
		new /mob/living/simple_animal/hostile/carp(T)

//////////////////////////////////////////////
//  Odyssey overrides of vanilla events     //
//////////////////////////////////////////////

//////// Radstorm ////////
/datum/event/radiation_storm/odyssey
	safe_zones = list(
		/area/shuttle/odyssey/maintenance,
		/area/shuttle/odyssey/hallway/aft,
		/area/shuttle/odyssey/engineering,
		/area/shuttle/odyssey/bridge,
		/area/shuttle/odyssey/bridge_lobby,
	)

/datum/command_alert/radiation_storm/odyssey
	name = "Radiation Storm - Warning"
	alert_title = "Anomaly Alert"
	alert = 'sound/AI/radiation.ogg'
	message = "High levels of radiation detected near the ship, ETA in 30 seconds. Please evacuate to the bridge, aft hallway, engineering, or maintenance."

/datum/event/radiation_storm/odyssey/start()
	spawn()
		command_alert(/datum/command_alert/radiation_storm/odyssey)

		for(var/area/A in odyssey_shuttle.linked_areas)
			if(is_safe_zone(A, null))
				continue
			A.radiation_alert()

		sleep(30 SECONDS)

		command_alert(/datum/command_alert/radiation_storm/start)

		for(var/i = 0, i < 15, i++)
			var/irradiationThisBurst = rand(15, 25)
			for(var/obj/machinery/power/rad_collector/R in rad_collectors)
				var/turf/T = get_turf(R)
				if(!T || !odyssey_shuttle.has_area(T.loc) || is_safe_zone(T.loc, T))
					continue
				R.receive_pulse(irradiationThisBurst * 50)
			for(var/obj/item/weapon/am_containment/decelerator/D in decelerators)
				var/turf/T = get_turf(D)
				if(!T || !odyssey_shuttle.has_area(T.loc) || is_safe_zone(T.loc, T))
					continue
				D.receive_pulse(irradiationThisBurst * 50)
			for(var/obj/machinery/portable_atmospherics/hydroponics/tray in hydro_trays)
				var/turf/T = get_turf(tray)
				if(!T || !odyssey_shuttle.has_area(T.loc) || is_safe_zone(T.loc, T))
					continue
				tray.receive_pulse(irradiationThisBurst * 50)

			for(var/mob/living/carbon/human/H in living_mob_list)
				if(istype(H.loc, /obj/spacepod))
					continue
				var/turf/T = get_turf(H)
				if(!T || !odyssey_shuttle.has_area(T.loc) || is_safe_zone(T.loc, T))
					continue
				var/randomMutation = prob(50)
				var/applied_rads = (H.apply_radiation(irradiationThisBurst, RAD_EXTERNAL) > (irradiationThisBurst / 4))
				if(randomMutation && applied_rads)
					var/badMutation = H?.lucky_prob(50, -1/10)
					if(badMutation)
						randmutb(H)
						domutcheck(H, null, MUTCHK_FORCED)
					else
						randmutg(H)
						domutcheck(H, null, MUTCHK_FORCED)

			sleep(25)

		command_alert(/datum/command_alert/radiation_storm/end)

		for(var/area/A in odyssey_shuttle.linked_areas)
			if(is_safe_zone(A, null))
				continue
			A.reset_radiation_alert()

//////// Viral Infection ////////
/datum/event/viral_infection/odyssey

/datum/event/viral_infection/odyssey/can_start(var/list/active_with_role)
	if(!map.recently_on_planet())
		return 0
	if(active_with_role["Medical"] > 0)
		return 40
	return 20

/datum/event/viral_infection/odyssey/announce()
	biohazard_alert(level)
	captain_announce("Air filtration systems have detected a minor pathogen onboard the ship.")

//////// Viral Outbreak ////////
/datum/event/viral_outbreak/odyssey

/datum/event/viral_outbreak/odyssey/can_start(var/list/active_with_role)
	if(!map.recently_on_planet())
		return 0
	if(active_with_role["Medical"] > 0)
		return 20
	return 10

/datum/event/viral_outbreak/odyssey/announce()
	biohazard_alert(level)
	captain_announce("Air filtration systems have detected a significant biological contaminant onboard the ship.")

//////// Grid Check ////////
/datum/event/grid_check/odyssey
	announceWhen = 1
	endWhen = 3

/datum/event/grid_check/odyssey/setup()
	endWhen = 3

/datum/event/grid_check/odyssey/announce()
	captain_announce("Solar microflare detected — brief power ripple expected.")

/datum/event/grid_check/odyssey/start()
	var/list/affected_apcs = list()
	for(var/obj/machinery/power/apc/A in odyssey_shuttle.shuttle_contents())
		if(A.cell)
			A.old_charge = A.cell.charge
			A.cell.charge = 0
		A.operating = 0
		A.update()
		A.update_icon()
		affected_apcs += A

	spawn(30 SECONDS)
		for(var/obj/machinery/power/apc/A in affected_apcs)
			if(A && !A.gcDestroyed)
				if(A.cell && A.old_charge)
					A.cell.charge = A.old_charge
				A.operating = 1
				A.chargemode = 1
				A.update()
				A.update_icon()

/datum/event/grid_check/odyssey/end()
	return

//////// Rogue Drone ////////
/datum/event/rogue_drone/odyssey

/datum/event/rogue_drone/odyssey/start()
	var/list/shuttle_turfs = list()
	for(var/turf/T in odyssey_shuttle.shuttle_contents())
		shuttle_turfs += T
	if(!shuttle_turfs.len)
		return
	var/turf/center = shuttle_turfs[round(shuttle_turfs.len / 2) + 1]
	var/list/space_turfs = list()
	for(var/turf/space/SP in range(50, center))
		if(!(SP in shuttle_turfs))
			space_turfs += SP
	if(!space_turfs.len)
		return

	var/num = prob(25) ? 0 : rand(2, 6)
	for(var/i = 0, i < num, i++)
		var/mob/living/simple_animal/hostile/retaliate/malf_drone/D = new(pick(space_turfs))
		D.from_event = src
		drones_list.Add(D)
		if(prob(25))
			D.disabled = rand(15, 60)

//////// Brand Intelligence ////////
/datum/event/brand_intelligence/odyssey

/datum/event/brand_intelligence/odyssey/start()
	for(var/obj/machinery/vending/V in odyssey_shuttle.shuttle_contents())
		vendingMachines.Add(V)

	if(!vendingMachines.len)
		kill()
		return

	originMachine = pick(vendingMachines)
	vendingMachines.Remove(originMachine)
	originMachine.shut_up = 0
	originMachine.shoot_inventory = 1

//////// Old Vendotron ////////
/datum/event/old_vendotron_teleport/odyssey

/datum/event/old_vendotron_teleport/odyssey/vendSpawnDecide()
	var/static/list/canReplace = list(
		/obj/machinery/vending/coffee,
		/obj/machinery/vending/snack,
		/obj/machinery/vending/cola,
		/obj/machinery/vending/cigarette,
		/obj/machinery/vending/discount,
		/obj/machinery/vending/groans,
		/obj/machinery/vending/nuka,
		/obj/machinery/vending/sovietsoda,
		/obj/machinery/vending/zamsnax,
	)
	var/list/possibleVends = list()
	for(var/obj/machinery/vending/aVendor in odyssey_shuttle.shuttle_contents())
		if(!is_type_in_list(aVendor, canReplace))
			continue
		possibleVends.Add(aVendor)
	if(!possibleVends.len)
		message_admins("Old Vendotron event has failed! Could not find any appropriate vending machines to replace.")
		announceWhen = -1
		endWhen = 0
		return
	return pick(possibleVends)

//////// ;HOG ////////
/datum/event/hog/odyssey

/datum/event/hog/odyssey/can_start(var/list/active_with_role)
	return 10

/datum/event/hog/odyssey/start()
	var/list/turf/simulated/floor/turfs = list()
	for(var/turf/simulated/floor/F in odyssey_shuttle.shuttle_contents())
		if(!is_blocked_turf(F))
			turfs += F
	if(turfs.len < 2)
		message_admins("Aborted hog event (odyssey). Not enough open shuttle turfs.")
		return

	command_alert(/datum/command_alert/hog)
	var/turf/spawn_turf = pick_n_take(turfs)
	var/mob/living/simple_animal/rampagingspacehog/ourhog = new(spawn_turf)
	message_admins("<span class='notice'>Event: hog spawned in at [ourhog.loc] <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[ourhog.x];Y=[ourhog.y];Z=[ourhog.z]'>(JMP)</a></span>")
	ourhog.homes += turfs

/// Spawn a meteor projectile from the edge of the shuttle's current virtual z-level aimed at the shuttle
/datum/shuttle/odyssey/proc/spawn_vz_meteor(meteor_type)
	var/datum/virtual_z/vz = current_port.get_virtual_z()
	if(!vz)
		return null
	var/z_level = vz.z()

	// Pick a random shuttle turf as the target
	var/list/shuttle_turfs = list()
	for(var/turf/T in shuttle_contents())
		shuttle_turfs += T
	if(!shuttle_turfs.len)
		return null
	var/turf/target = pick(shuttle_turfs)

	// Pick a random edge of the VZ as the origin
	var/dir = pick(cardinal)
	var/startx
	var/starty
	switch(dir)
		if(NORTH)
			startx = rand(vz.x_min + TRANSITIONEDGE, vz.x_max - TRANSITIONEDGE)
			starty = vz.y_max - TRANSITIONEDGE
		if(SOUTH)
			startx = rand(vz.x_min + TRANSITIONEDGE, vz.x_max - TRANSITIONEDGE)
			starty = vz.y_min + TRANSITIONEDGE
		if(EAST)
			startx = vz.x_max - TRANSITIONEDGE
			starty = rand(vz.y_min + TRANSITIONEDGE, vz.y_max - TRANSITIONEDGE)
		if(WEST)
			startx = vz.x_min + TRANSITIONEDGE
			starty = rand(vz.y_min + TRANSITIONEDGE, vz.y_max - TRANSITIONEDGE)
	var/turf/start = locate(startx, starty, z_level)
	if(start && target)
		return new meteor_type(start, target)
	return null

//////////////////////////////////////////////
//                                          //
//          ODYSSEY XENOMORPH               ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/odyssey_xeno
	name = "Alien Stowaway"
	role_category = /datum/role/xenomorph
	enemy_jobs = list()
	required_pop = list(0,0,0,0,0,0,0,0,0,0)
	required_enemies = list(0,0,0,0,0,0,0,0,0,0)
	required_candidates = 1
	max_candidates = 1
	weight = 12
	weight_category = "Alien"
	cost = 5
	requirements = list(20,15,10,10,10,10,10,10,10,10)
	high_population_requirement = 10
	logo = "xeno-logo"
	my_fac = /datum/faction/xenomorph

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/odyssey_xeno/proc/get_valid_spawns()
	var/list/valid_area_types = list(
		/area/shuttle/odyssey/engineering,
		/area/shuttle/odyssey/maintenance/port,
		/area/shuttle/odyssey/maintenance/starboard,
		/area/shuttle/odyssey/janitor,
		/area/shuttle/odyssey/restroom,
		/area/shuttle/odyssey/quarters/crew,
		/area/shuttle/odyssey/quarters/heads
	)
	var/list/valid_spawns = list()
	for(var/area/shuttle/odyssey/A in world)
		if(!(A.type in valid_area_types))
			continue
		for(var/turf/simulated/floor/T in A)
			if(T.density)
				continue
			valid_spawns += T
	return valid_spawns

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/odyssey_xeno/ready(var/forced = 0)
	var/list/spawns = get_valid_spawns()
	if(!spawns.len)
		log_admin("Odyssey xeno ruleset: No valid shuttle spawn turfs found.")
		message_admins("Odyssey xeno ruleset: No valid shuttle spawn turfs found.")
		return FALSE

	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/odyssey_xeno/generate_ruleset_body(var/mob/applicant)
	var/list/valid_spawns = get_valid_spawns()
	if(!valid_spawns.len)
		return
	var/turf/spawn_loc = pick(valid_spawns)
	var/mob/living/carbon/alien/larva/new_xeno = new(spawn_loc)
	new_xeno.stowaway = TRUE
	new_xeno.key = applicant.key
	new_xeno << sound('sound/voice/alienspawn.ogg')

	return new_xeno
