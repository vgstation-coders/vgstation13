/datum/event/micro_meteors
	announceWhen = 1
	endWhen = 5

/datum/event/micro_meteors/can_start()
	return 20

/datum/event/micro_meteors/announce()
	captain_announce("Sensors detect incoming micro-debris field. Brace for impact.")

/datum/event/micro_meteors/start()
	if(!map || !map.ship_shuttle)
		return
	var/datum/shuttle/odyssey/S = map.ship_shuttle
	if(!istype(S))
		return
	var/count = rand(4, 8)
	for(var/i = 1 to count)
		var/meteor_type = /obj/item/projectile/meteor/small/microdebris
		if(prob(25))
			meteor_type = /obj/item/projectile/meteor/small
		S.spawn_vz_meteor(meteor_type)
		sleep(rand(3, 5))

/datum/event/gib_storm
	announceWhen = 1
	endWhen = 5

/datum/event/gib_storm/can_start()
	return 40

/datum/event/gib_storm/announce()
	captain_announce("Warning: Unidentified organic matter on collision course.")

/datum/event/gib_storm/start()
	if(!map || !map.ship_shuttle)
		return
	var/datum/shuttle/odyssey/S = map.ship_shuttle
	if(!istype(S))
		return
	var/count = rand(8, 15)
	for(var/i = 1 to count)
		S.spawn_vz_meteor(/obj/item/projectile/meteor/gib)
		sleep(rand(2, 4))

/datum/event/solar_flare
	announceWhen = 1
	endWhen = 5

/datum/event/solar_flare/can_start()
	return 10

/datum/event/solar_flare/announce()
	captain_announce("Solar flare detected. Electrical systems may be affected.")

/datum/event/solar_flare/start()
	if(!map || !map.ship_shuttle)
		return
	var/datum/shuttle/odyssey/S = map.ship_shuttle
	if(!istype(S))
		return
	var/duration = rand(1 MINUTES, 2 MINUTES)
	var/list/affected_apcs = list()

	for(var/obj/machinery/power/apc/A in S.shuttle_contents())
		if(A.cell)
			A.cell.charge = 0
		A.chargemode = 0
		A.operating = 0
		A.update()
		A.update_icon()
		affected_apcs += A

	spawn(duration)
		for(var/obj/machinery/power/apc/A in affected_apcs)
			if(A && !A.gcDestroyed)
				A.chargemode = 1
				A.operating = 1
				A.update()
				A.update_icon()
		captain_announce("Electrical systems have stabilized. Power is being restored.")

/datum/event/odyssey_carp_swarm
	announceWhen = 1
	endWhen = 5

/datum/event/odyssey_carp_swarm/can_start()
	return 15

/datum/event/odyssey_carp_swarm/announce()
	captain_announce("Biosensors detect hostile fauna approaching the ship.")

/datum/event/odyssey_carp_swarm/start()
	if(!map || !map.ship_shuttle)
		return
	var/datum/shuttle/odyssey/S = map.ship_shuttle
	if(!istype(S) || !S.current_port)
		return
	var/datum/virtual_z/vz = S.current_port.get_virtual_z()
	if(!vz)
		return

	var/count = rand(4, 8)

	// Find space turfs near the shuttle
	var/list/shuttle_turfs = list()
	for(var/turf/T in S.shuttle_contents())
		shuttle_turfs += T
	if(!shuttle_turfs.len)
		return

	var/turf/center = shuttle_turfs[round(shuttle_turfs.len / 2) + 1]
	var/list/space_turfs = list()
	for(var/turf/space/SP in range(15, center))
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

/datum/event/radiation_storm/odyssey

/datum/event/disease_outbreak/odyssey

/datum/event/disease_outbreak/odyssey/can_start(var/list/active_with_role)
	if(!map.recently_on_planet())
		return 0
	return 20

/datum/event/disease_outbreak/odyssey/announce()
	captain_announce("Medical reports signs of an unidentified pathogen — likely picked up during the last dirtside excursion.")

/datum/event/viral_infection/odyssey

/datum/event/viral_infection/odyssey/can_start(var/list/active_with_role)
	if(!map.recently_on_planet())
		return 0
	if(active_with_role["Medical"] > 1)
		return 40
	return 0

/datum/event/viral_infection/odyssey/announce()
	biohazard_alert(level)
	captain_announce("Medical isolates a minor pathogen traced to the crew's last planetary excursion.")

/datum/event/viral_outbreak/odyssey

/datum/event/viral_outbreak/odyssey/can_start(var/list/active_with_role)
	if(!map.recently_on_planet())
		return 0
	if(active_with_role["Medical"] > 1)
		return 25
	return 0

/datum/event/viral_outbreak/odyssey/announce()
	biohazard_alert(level)
	captain_announce("Medical warns of a significant biological contaminant brought aboard during the last dirtside excursion.")

/datum/event/ancientpod/odyssey

/datum/event/ancientpod/odyssey/start()
	var/turf/spawn_turf = pick_odyssey_planet_floor()
	if(!spawn_turf)
		// Fall back to vanilla behavior if no valid planet turf
		..()
		return
	var/obj/machinery/cryopod/pod = new /obj/machinery/cryopod(spawn_turf)
	pod.ThrowAtStation()

/proc/pick_odyssey_planet_floor()
	// Pick a random non-hidden planet, then a random floor turf that isn't lava or water.
	var/list/candidate_planets = list()
	for(var/datum/planet_type/P in SSmapping.planets)
		if(P.hidden || !P.v)
			continue
		candidate_planets += P
	if(!candidate_planets.len)
		return null

	var/datum/planet_type/chosen = pick(candidate_planets)
	var/datum/virtual_z/vz = chosen.v
	var/z_level = vz.z()

	var/list/valid_turfs = list()
	for(var/x = vz.x_min to vz.x_max)
		for(var/y = vz.y_min to vz.y_max)
			var/turf/T = locate(x, y, z_level)
			if(!T)
				continue
			if(!istype(T, /turf/unsimulated/floor/planetary) && !istype(T, /turf/simulated/floor))
				continue
			if(istype(T, /turf/unsimulated/floor/planetary/lava))
				continue
			if(istype(T, /turf/unsimulated/floor/planetary/water))
				continue
			if(istype(T, /turf/simulated/floor/beach/water))
				continue
			valid_turfs += T

	if(!valid_turfs.len)
		return null
	return pick(valid_turfs)

/datum/event/grid_check/odyssey
	announceWhen = 1
	endWhen = 3

/datum/event/grid_check/odyssey/setup()
	endWhen = 3

/datum/event/grid_check/odyssey/announce()
	captain_announce("Solar microflare detected — brief power ripple expected.")

/datum/event/grid_check/odyssey/start()
	if(!map || !map.ship_shuttle)
		return
	var/datum/shuttle/odyssey/S = map.ship_shuttle
	if(!istype(S))
		return
	var/list/affected_apcs = list()
	for(var/obj/machinery/power/apc/A in S.shuttle_contents())
		if(A.cell)
			A.old_charge = A.cell.charge
			A.cell.charge = 0
		A.operating = 0
		A.update()
		A.update_icon()
		affected_apcs += A

	spawn(10 SECONDS)
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

/datum/event/immovable_rod/odyssey

/datum/event/immovable_rod/odyssey/can_start(var/list/active_with_role)
	if(active_with_role["Any"] > 3)
		return 15
	return 0

/datum/event/rogue_drone/odyssey

/datum/event/rogue_drone/odyssey/start()
	if(!map || !map.ship_shuttle)
		return
	var/datum/shuttle/odyssey/S = map.ship_shuttle
	if(!istype(S))
		return

	var/list/shuttle_turfs = list()
	for(var/turf/T in S.shuttle_contents())
		shuttle_turfs += T
	if(!shuttle_turfs.len)
		return
	var/turf/center = shuttle_turfs[round(shuttle_turfs.len / 2) + 1]
	var/list/space_turfs = list()
	for(var/turf/space/SP in range(15, center))
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

/datum/event/brand_intelligence/odyssey

/datum/event/brand_intelligence/odyssey/start()
	if(!map || !map.ship_shuttle)
		kill()
		return
	var/datum/shuttle/odyssey/S = map.ship_shuttle
	if(!istype(S))
		kill()
		return

	for(var/obj/machinery/vending/V in S.shuttle_contents())
		vendingMachines.Add(V)

	if(!vendingMachines.len)
		kill()
		return

	originMachine = pick(vendingMachines)
	vendingMachines.Remove(originMachine)
	originMachine.shut_up = 0
	originMachine.shoot_inventory = 1

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
	if(!map || !map.ship_shuttle)
		announceWhen = -1
		endWhen = 0
		return
	var/datum/shuttle/odyssey/S = map.ship_shuttle
	var/list/possibleVends = list()
	for(var/obj/machinery/vending/aVendor in S.shuttle_contents())
		if(!is_type_in_list(aVendor, canReplace))
			continue
		possibleVends.Add(aVendor)
	if(!possibleVends.len)
		message_admins("Old Vendotron event (odyssey) failed — no shuttle vendors to replace.")
		announceWhen = -1
		endWhen = 0
		return
	return pick(possibleVends)

/datum/event/hog/odyssey

/datum/event/hog/odyssey/start()
	if(!map || !map.ship_shuttle)
		message_admins("Aborted hog event (odyssey). No ship shuttle.")
		return
	var/datum/shuttle/odyssey/S = map.ship_shuttle
	if(!istype(S))
		message_admins("Aborted hog event (odyssey). Ship shuttle is not odyssey.")
		return

	var/list/turf/simulated/floor/turfs = list()
	for(var/turf/simulated/floor/F in S.shuttle_contents())
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
			startx = rand(vz.x_min + 2, vz.x_max - 2)
			starty = vz.y_max - 2
		if(SOUTH)
			startx = rand(vz.x_min + 2, vz.x_max - 2)
			starty = vz.y_min + 2
		if(EAST)
			startx = vz.x_max - 2
			starty = rand(vz.y_min + 2, vz.y_max - 2)
		if(WEST)
			startx = vz.x_min + 2
			starty = rand(vz.y_min + 2, vz.y_max - 2)

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

	spawn(rand(90 SECONDS, 120 SECONDS))
		captain_announce("Unidentified life signs detected aboard the NTEV Odyssey.")

	return new_xeno
