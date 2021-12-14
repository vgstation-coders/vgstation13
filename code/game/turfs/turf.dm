/turf
	icon = 'icons/turf/floors.dmi'
	plane = TURF_PLANE
	layer = TURF_LAYER
	luminosity = 0

	//for floors, use is_plating(), is_metal_floor() and is_light_floor()
	var/intact = 1
	var/turf_flags = 0

	//properties for open tiles (/floor)
	var/oxygen = 0
	var/carbon_dioxide = 0
	var/nitrogen = 0
	var/toxins = 0

	//properties for airtight tiles (/wall)
	var/thermal_conductivity = 0.05
	var/heat_capacity = 1

	//properties for both
	var/temperature = T20C

	var/blocks_air = 0

	var/list/PathNodes = null

	// Bot shit
	var/targetted_by=null

	var/list/turfdecals

	// Flick animation shit
	var/atom/movable/overlay/c_animation = null

	// Powernet /datum/power_connections.  *Uninitialized until used to conserve memory*
	var/list/power_connections = null

	var/protect_infrastructure = FALSE //protect cables/pipes from explosive damage

	// holy water
	var/holy = 0

	// left by bullets that went all the way through
	var/bullet_marks = 0
	penetration_dampening = 10
	// if STANDING     ON THE EDGE        OF THE z-level will transition you to another
	var/can_border_transition = 0
/*
 * Technically obsoleted by base_turf
	//For building on the asteroid.
 	var/under_turf = /turf/space
 */

	var/turf_speed_multiplier = 1

	var/explosion_block = 0

	// This is the placed to store data for the holomap.
	var/list/image/holomap_data

	// Map element which spawned this turf
	var/datum/map_element/map_element

	var/image/viewblock

	var/junction = 0

	var/volume_mult = 1 //how loud are things on this turf?

	var/holomap_draw_override = HOLOMAP_DRAW_NORMAL

	var/last_beam_damage = 0

/turf/examine(mob/user)
	..()
	if(bullet_marks)
		to_chat(user, "It has [bullet_marks > 1 ? "some holes" : "a hole"] in it.")

/turf/proc/process()
	set waitfor = FALSE
	universe.OnTurfTick(src)

/turf/initialize()
	..()
	if(loc)
		var/area/A = loc
		A.area_turfs += src
	for(var/atom/movable/AM in src)
		src.Entered(AM)

/turf/ex_act(severity)
	return 0

/turf/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/bullet/gyro))
		explosion(src, -1, 0, 2)
	if(Proj.destroy)
		src.ex_act(2)
	..()
	return 0

/turf/Exit(atom/movable/mover, atom/target)
	return TRUE

/turf/Exited(atom/movable/mover, atom/newloc)
	..()
	INVOKE_EVENT(src, /event/exited, "mover" = mover, "location" = src, "newloc" = newloc)

/turf/Enter(atom/movable/mover, atom/oldloc, check_contents = FALSE)
	. = ..()
	if(check_contents && .)
		for(var/atom/movable/AM in src)
			if(!AM.Cross(mover))
				return FALSE

/turf/Entered(atom/movable/A as mob|obj, atom/OldLoc)
	if(movement_disabled)
		to_chat(usr, "<span class='warning'>Movement is admin-disabled.</span>")//This is to identify lag problems
		return

	//THIS IS OLD TURF ENTERED CODE
	var/loopsanity = 100

	if(!src.has_gravity())
		inertial_drift(A)
	else
		A.inertia_dir = 0

	..()
	INVOKE_EVENT(src, /event/entered, "mover" = A, "location" = src, "oldloc" = OldLoc)
	var/objects = 0
	if(A && A.flags & PROXMOVE)
		for(var/atom/Obj in range(1, src))
			if(objects > loopsanity)
				break
			objects++
			if(Obj.flags & PROXMOVE)
				spawn( 0 )
					Obj.HasProximity(A, 1)
	// THIS IS NOW TRANSIT STUFF
	if ((!(A) || src != A.loc))
		return
	if (!(src.can_border_transition))
		return
	if(ticker && ticker.mode)

		// Okay, so let's make it so that people can travel z levels but not nuke disks!
		// if(ticker.mode.name == "nuclear emergency")	return
		if(A.z > 6)
			return
		if (A.x <= TRANSITIONEDGE || A.x >= (world.maxx - TRANSITIONEDGE + 1) || A.y <= TRANSITIONEDGE || A.y >= (world.maxy - TRANSITIONEDGE + 1))

			var/list/contents_brought = list()
			contents_brought += recursive_type_check(A)

			if(istype(A, /obj/structure/bed/chair/vehicle))
				var/obj/structure/bed/chair/vehicle/B = A
				if(B.is_locking(B.mob_lock_type))
					contents_brought += recursive_type_check(B)

			var/locked_to_current_z = 0//To prevent the moveable atom from leaving this Z, examples are DAT DISK and derelict MoMMIs.

			var/datum/zLevel/ZL = map.zLevels[z]
			if(ZL.transitionLoops)
				locked_to_current_z = z

			var/obj/item/weapon/disk/nuclear/nuclear = locate() in contents_brought
			if(nuclear)
				qdel(nuclear)

			//Check if it's a mob pulling an object
			var/obj/was_pulling = null
			var/mob/living/MOB = null
			if(isliving(A))
				MOB = A
				if(MOB.pulling)
					was_pulling = MOB.pulling //Store the object to transition later


			var/move_to_z = src.z

			// Prevent MoMMIs from leaving the derelict and to ensure Exile Implants work properly.
			for(var/mob/living/L in contents_brought)
				if(L.locked_to_z != 0)
					if(src.z == L.locked_to_z)
						locked_to_current_z = map.zMainStation
					else
						to_chat(L, "<span class='warning'>You find your way back.</span>")
						move_to_z = L.locked_to_z

			var/safety = 1

			if(!locked_to_current_z)
				while(move_to_z == src.z)
					var/move_to_z_str = pickweight(accessable_z_levels)
					move_to_z = text2num(move_to_z_str)
					safety++
					if(safety > 10)
						break

			if(!move_to_z)
				return

			INVOKE_EVENT(A, /event/z_transition, "user" = A, "from_z" = A.z, "to_z" = move_to_z)
			for(var/atom/movable/AA in contents_brought)
				INVOKE_EVENT(AA, /event/z_transition, "user" = AA, "from_z" = AA.z, "to_z" = move_to_z)
			A.z = move_to_z

			if(src.x <= TRANSITIONEDGE)
				A.x = world.maxx - TRANSITIONEDGE - 2
				A.y = rand(TRANSITIONEDGE + 2, world.maxy - TRANSITIONEDGE - 2)

			else if (A.x >= (world.maxx - TRANSITIONEDGE - 1))
				A.x = TRANSITIONEDGE + 1
				A.y = rand(TRANSITIONEDGE + 2, world.maxy - TRANSITIONEDGE - 2)

			else if (src.y <= TRANSITIONEDGE)
				A.y = world.maxy - TRANSITIONEDGE -2
				A.x = rand(TRANSITIONEDGE + 2, world.maxx - TRANSITIONEDGE - 2)

			else if (A.y >= (world.maxy - TRANSITIONEDGE - 1))
				A.y = TRANSITIONEDGE + 1
				A.x = rand(TRANSITIONEDGE + 2, world.maxx - TRANSITIONEDGE - 2)

			spawn (0)
				if(was_pulling && MOB) //Carry the object they were pulling over when they transition
					was_pulling.forceMove(MOB.loc)
					MOB.pulling = was_pulling
					was_pulling.pulledby = MOB
				if ((A && A.loc))
					A.loc.Entered(A, OldLoc)
				if (istype(A,/obj/item/projectile))
					var/obj/item/projectile/P = A
					P.reset()//fixing linear projectile movement

			INVOKE_EVENT(A, /event/post_z_transition, "user" = A, "from_z" = A.z, "to_z" = move_to_z)
			for(var/atom/movable/AA in contents_brought)
				INVOKE_EVENT(AA, /event/post_z_transition, "user" = AA, "from_z" = AA.z, "to_z" = move_to_z)

/turf/proc/is_plating()
	return 0
/turf/proc/can_place_cables()
	return is_plating()
/turf/proc/is_asteroid_floor()
	return 0
/turf/proc/is_metal_floor()
	return 0
/turf/proc/is_light_floor()
	return 0
/turf/proc/is_grass_floor()
	return 0
/turf/proc/is_wood_floor()
	return 0
/turf/proc/is_carpet_floor()
	return 0
/turf/proc/is_arcade_floor()
	return 0
/turf/proc/is_slime_floor()
	return 0
/turf/proc/is_mineral_floor()
	return 0
/turf/proc/return_siding_icon_state()		//used for grass floors, which have siding.
	return 0

/turf/proc/inertial_drift(atom/movable/A as mob|obj)
	if(!(A.last_move))
		return

	if(src.x > 2 && src.x < (world.maxx - 1) && src.y > 2 && src.y < (world.maxy - 1))
		A.process_inertia(src)

	return

/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(src.intact)

// override for space turfs, since they should never hide anything
/turf/space/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(0)

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L)
		qdel (L)
		L = null

/turf/proc/add_dust()
	return

//Creates a new turf
/turf/proc/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 1)
	if(loc)
		var/area/A = loc
		A.area_turfs -= src
	if (!N || !allow)
		return

	var/datum/gas_mixture/env

	var/old_opacity = opacity
	var/old_density = density
	var/old_holomap_draw_override = holomap_draw_override
	var/old_registered_events = registered_events

	var/old_holomap = holomap_data
//	to_chat(world, "Replacing [src.type] with [N]")

	//The following two lines are an optimization. Without them, each connection would search connections when erased to remove itself.
	var/list/connection/connections = src.connections
	src.connections = null

	for(var/turf/T in connections)
		connections[T].erase()

	connections = null

	if(N == /turf/space)
		for(var/obj/effect/decal/cleanable/C in src)
			qdel(C)//enough with footprints floating in space

	//Rebuild turf
	var/turf/T = src
	env = T.air //Get the air before the change
	if(istype(src,/turf/simulated))
		var/turf/simulated/S = src
		if(S.zone)
			S.zone.rebuild()

	if(istype(src,/turf/simulated/floor))
		var/turf/simulated/floor/F = src
		//No longer phazon, not a teleport destination
		if(F.material=="phazon")
			phazontiles -= src
		if(F.floor_tile)
			qdel(F.floor_tile)
			F.floor_tile = null
		F = null

	if(ispath(N, /turf/simulated/floor))
		//if the old turf had a zone, connect the new turf to it as well - Cael
		//Adjusted by SkyMarshal 5/10/13 - The air master will handle the addition of the new turf.
		//if(zone)
		//	zone.RemoveTurf(src)
		//	if(!zone.CheckStatus())
		//		zone.SetStatus(ZONE_ACTIVE)

		var/turf/simulated/W = new N(src)
		if(world.has_round_started())
			initialize()
		if(env)
			W.air = env //Copy the old environment data over if both turfs were simulated

		if (istype(W,/turf/simulated/floor) && !W.can_exist_under_lattice)
			W.RemoveLattice()

		if(tell_universe)
			universe.OnTurfChange(W)

		if(SS_READY(SSair))
			SSair.mark_for_update(src)

		if(istype(W, /turf/space) && W.loc.dynamic_lighting == 0)
			var/image/I = image(icon = 'icons/mob/screen1.dmi', icon_state = "white")
			I.plane = LIGHTING_PLANE
			I.blend_mode = BLEND_ADD
			W.overlays += I

		W.levelupdate()
		W.post_change() //What to do after changing the turf. Handles stuff like zshadow updates.
		. = W
		if (SS_READY(SSlighting))
			if(old_opacity != opacity)
				for(var/atom/movable/light/L in range(5, src)) //view(world.view, dview_mob))
					lighting_update_lights |= L

	else
		//if(zone)
		//	zone.RemoveTurf(src)
		//	if(!zone.CheckStatus())
		//		zone.SetStatus(ZONE_ACTIVE)

		var/turf/W = new N(src)
		if(world.has_round_started())
			W.initialize()

		if(istype(W, /turf/space) && W.loc.dynamic_lighting == 0)
			var/image/I = image(icon = 'icons/mob/screen1.dmi', icon_state = "white")
			I.plane = LIGHTING_PLANE
			I.blend_mode = BLEND_ADD
			W.overlays += I

		if(tell_universe)
			universe.OnTurfChange(W)

		if(SS_READY(SSair))
			SSair.mark_for_update(src)

		W.levelupdate()

		. = W

	if (!ticker)
		holomap_draw_override = old_holomap_draw_override//we don't want roid/snowmap cave tunnels appearing on holomaps
	holomap_data = old_holomap // Holomap persists through everything
	registered_events = old_registered_events
	if(density != old_density)
		densityChanged()

/turf/proc/AddDecal(const/image/decal)
	if(!turfdecals)
		turfdecals = new

	turfdecals += decal
	overlays += decal

/turf/proc/ClearDecals()
	if(!turfdecals)
		return

	for(var/image/decal in turfdecals)
		overlays -= decal

	turfdecals.len = 0

/turf/apply_luminol()
	if(!..())
		return FALSE
	if(!(locate(/obj/effect/decal/cleanable/blueglow) in src))
		new /obj/effect/decal/cleanable/blueglow(src)

/turf/proc/get_underlying_turf()
	var/area/A = loc
	if(A.base_turf_type)
		return A.base_turf_type

	return get_base_turf(z)

/turf/proc/ReplaceWithLattice()
	src.ChangeTurf(get_underlying_turf())
	if(istype(src, /turf/space))
		new /obj/structure/lattice(src)

/turf/proc/kill_creatures(mob/U = null)//Will kill people/creatures and damage mechs./N
//Useful to batch-add creatures to the list.
	for(var/mob/living/M in src)
		if(M==U)
			continue//Will not harm U. Since null != M, can be excluded to kill everyone.
		spawn(0)
			M.gib()
	for(var/obj/mecha/M in src)//Mecha are not gibbed but are damaged.
		spawn(0)
			M.take_damage(100, "brute")

/turf/bless()
	if (holy)
		return
	holy = 1
	..()
	new /obj/effect/overlay/holywaterpuddle(src)

/////////////////////////////////////////////////////////////////////////
// Navigation procs
// Used for A-star pathfinding
////////////////////////////////////////////////////////////////////////

///////////////////////////
//Cardinal only movements
///////////////////////////

// Returns the surrounding cardinal turfs with open links
// Including through doors openable with the ID
/turf/proc/CardinalTurfsWithAccess(var/obj/item/weapon/card/id/ID)
	var/list/L = new()
	var/turf/simulated/T

	for(var/dir in cardinal)
		T = get_step(src, dir)
		if(istype(T) && !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				L.Add(T)
	return L

// Returns the surrounding cardinal turfs with open links
// Don't check for ID, doors passable only if open
/turf/proc/CardinalTurfs()
	var/list/L = new()
	var/turf/simulated/T

	for(var/dir in cardinal)
		T = get_step(src, dir)
		if(istype(T) && !T.density)
			if(!LinkBlocked(src, T))
				L.Add(T)
	return L

///////////////////////////
//All directions movements
///////////////////////////

// Returns the surrounding simulated turfs with open links
// Including through doors openable with the ID
/turf/proc/AdjacentTurfsWithAccess(var/obj/item/weapon/card/id/ID = null,var/list/closed)//check access if one is passed
	var/list/L = new()
	var/turf/simulated/T
	for(var/dir in list(NORTHWEST,NORTHEAST,SOUTHEAST,SOUTHWEST,NORTH,EAST,SOUTH,WEST)) //arbitrarily ordered list to favor non-diagonal moves in case of ties
		T = get_step(src,dir)
		if(T in closed) //turf already proceeded in A*
			continue
		if(istype(T) && !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				L.Add(T)
	return L

//Idem, but don't check for ID and goes through open doors
/turf/proc/AdjacentTurfs(var/list/closed)
	var/list/L = new()
	var/turf/simulated/T
	for(var/dir in list(NORTHWEST,NORTHEAST,SOUTHEAST,SOUTHWEST,NORTH,EAST,SOUTH,WEST)) //arbitrarily ordered list to favor non-diagonal moves in case of ties
		T = get_step(src,dir)
		if(T in closed) //turf already proceeded by A*
			continue
		if(istype(T) && !T.density)
			if(!LinkBlocked(src, T))
				L.Add(T)
	return L

// check for all turfs, including unsimulated ones
/turf/proc/AdjacentTurfsSpace(var/obj/item/weapon/card/id/ID = null, var/list/closed)//check access if one is passed
	var/list/L = new()
	var/turf/T
	for(var/dir in list(NORTHWEST,NORTHEAST,SOUTHEAST,SOUTHWEST,NORTH,EAST,SOUTH,WEST)) //arbitrarily ordered list to favor non-diagonal moves in case of ties
		T = get_step(src,dir)
		if(T in closed) //turf already proceeded by A*
			continue
		if(istype(T) && !T.density)
			if(!ID)
				if(!LinkBlocked(src, T))
					L.Add(T)
			else
				if(!LinkBlockedWithAccess(src, T, ID))
					L.Add(T)
	return L

//////////////////////////////
//Distance procs
//////////////////////////////

//Distance associates with all directions movement
/turf/proc/Distance(var/turf/T)
	return get_dist(src,T)

//  This Distance proc assumes that only cardinal movement is
//  possible. It results in more efficient (CPU-wise) pathing
//  for bots and anything else that only moves in cardinal dirs.
/turf/proc/Distance_cardinal(turf/T)
	if(!src || !T)
		return 0
	return abs(src.x - T.x) + abs(src.y - T.y)

////////////////////////////////////////////////////


/turf/proc/cultify()
	if(istype(src, get_underlying_turf())) //Don't cultify the base turf, ever
		return
	ChangeTurf(get_base_turf(src.z))

/turf/proc/clockworkify()
	return

/turf/projectile_check()
	return PROJREACT_WALLS

/turf/singularity_act()
	if(istype(src, get_underlying_turf())) //Don't singulo the base turf, ever
		return
	if(intact)
		for(var/obj/O in contents)
			if(O.level != 1)
				continue
			if(O.invisibility == 101)
				O.singularity_act()
	ChangeTurf(get_underlying_turf())
	score["turfssingulod"]++
	return(2)

//Return a lattice to allow catwalk building
/turf/proc/canBuildCatwalk()
	return BUILD_FAILURE

//Return true to allow lattice building
/turf/proc/canBuildLattice()
	return BUILD_FAILURE

//Return a lattice to allow plating building, return 0 for error message, return -1 for silent fail.
/turf/proc/canBuildPlating()
	return BUILD_SILENT_FAILURE

/turf/proc/dismantle_wall()
	return

/////////////////////////////////////////////////////

/turf/proc/spawn_powerup()
	spawn(5)
		var/powerup = pick(
			50;/obj/structure/powerup/bombup,
			50;/obj/structure/powerup/fire,
			50;/obj/structure/powerup/skate,
			10;/obj/structure/powerup/kick,
			10;/obj/structure/powerup/line,
			10;/obj/structure/powerup/power,
			10;/obj/structure/powerup/skull,
			5;/obj/structure/powerup/full,
			)
		new powerup(src)

// Holomap stuff!
/turf/proc/add_holomap(var/atom/movable/AM)
	var/image/I = new
	I.appearance = AM.appearance
	I.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	I.loc = src
	I.dir = AM.dir
	I.alpha = 128
	// Since holomaps are overlays of the turf
	// This'll make them always be just above the turf and not block interaction.
	I.plane = FLOAT_PLANE + 1 //Yes, there's a define equal to this value, but what we specifically want here is one plane above the parent, which is what this means.
	// When I said above turfs I mean it.
	I.layer = HOLOMAP_LAYER

	if (!holomap_data)
		holomap_data = list()
	holomap_data += I

// This is a MULTIPLIER OVER THE MOB'S USUAL MOVEMENT DELAY.
// Return a high number to make the mob move slower.
// Return a low number to make the mob move superfast.
/turf/proc/adjust_slowdown(mob/living/L, base_slowdown)
	for(var/atom/A in src)
		if(A.slowdown_modifier)
			base_slowdown *= A.slowdown_modifier
	base_slowdown *= turf_speed_multiplier
	return base_slowdown

/turf/proc/has_gravity(mob/M)
	if(istype(M) && M.CheckSlip() == SLIP_HAS_MAGBOOTS) //Wearing magboots - good enough
		return 1

	var/area/A = loc
	if(istype(A))
		return A.gravity

	return 1

/turf/proc/set_area(area/A)
	if(ispath(A))
		var/path = A
		A = locate(path)

		if(!A)
			A = new path
	else if(!isarea(A))
		return FALSE

	var/area/old_area = loc
	old_area.contents.Remove(src)
	old_area.area_turfs.Remove(src)
	A.contents.Add(src)
	A.area_turfs.Add(src)
	if(old_area)
		change_area(old_area, A)
		for(var/atom/AM in contents)
			AM.change_area(old_area, A)

/turf/spawned_by_map_element(datum/map_element/ME, list/objects)
	.=..()

	src.map_element = ME

/turf/send_to_past(var/duration)
	var/current_type = type
	being_sent_to_past = TRUE
	spawn(duration)
		being_sent_to_past = FALSE
		ChangeTurf(current_type)

/turf/attack_hand(mob/user as mob)
	user.Move_Pulled(src)

/turf/proc/remove_rot()
	return

//Pathnode stuff

/turf/proc/FindPathNode(var/id)
	return PathNodes ? PathNodes["[id]"] : null

/turf/proc/AddPathNode(var/PathNode/PN, var/id)
	ASSERT(!PathNodes || !PathNodes["[id]"])
	if (!PathNodes)
		PathNodes = list()
	PathNodes["[id]"] = PN
