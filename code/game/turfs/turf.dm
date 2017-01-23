/turf
	icon = 'icons/turf/floors.dmi'
	plane = TURF_PLANE
	layer = TURF_LAYER
	luminosity = 0

	//for floors, use is_plating(), is_plasteel_floor() and is_light_floor()
	var/intact = 1

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

	//associated PathNode in the A* algorithm
	var/PathNode/PNode = null

	// Bot shit
	var/targetted_by=null

	var/list/turfdecals

	// Flick animation shit
	var/atom/movable/overlay/c_animation = null

	// Powernet /datum/power_connections.  *Uninitialized until used to conserve memory*
	var/list/power_connections = null

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

	var/explosion_block = 0

	//For shuttles - if 1, the turf's underlay will never be changed when moved
	//See code/datums/shuttle.dm @ 544
	var/preserve_underlay = 0


	// This is the placed to store data for the holomap.
	var/list/image/holomap_data

	// Map element which spawned this turf
	var/datum/map_element/map_element

/turf/examine(mob/user)
	..()
	if(bullet_marks)
		to_chat(user, "It has bullet markings on it.")

/turf/proc/process()
	set waitfor = FALSE
	universe.OnTurfTick(src)

/turf/New()
	..()
	if(loc)
		var/area/A = loc
		A.area_turfs += src
	for(var/atom/movable/AM as mob|obj in src)
		spawn( 0 )
			src.Entered(AM)
			return

/turf/proc/initialize()
	return

/turf/DblClick()
	if(istype(usr, /mob/living/silicon/ai))
		return move_camera_by_click()
	if(usr.stat || usr.restrained() || usr.lying)
		return ..()
	return ..()

/turf/ex_act(severity)
	return 0


/turf/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.destroy)
		src.ex_act(2)
	..()
	return 0

/turf/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/bullet/gyro))
		explosion(src, -1, 0, 2)
	..()
	return 0

/turf/Enter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)
	if(!mover)
		return 1
	. = ..()
	if(.)
		return !density //Nothing found to block so return success!

/turf/Entered(atom/movable/A as mob|obj)
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
	var/objects = 0
	if(A && A.flags & PROXMOVE)
		for(var/atom/Obj as mob|obj|turf|area in range(1))
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
		if (A.x <= TRANSITIONEDGE || A.x >= (world.maxx - TRANSITIONEDGE - 1) || A.y <= TRANSITIONEDGE || A.y >= (world.maxy - TRANSITIONEDGE - 1))

			var/list/contents_brought = list()
			contents_brought += recursive_type_check(A)

			if(istype(A, /obj/structure/bed/chair/vehicle))
				var/obj/structure/bed/chair/vehicle/B = A
				if(B.is_locking(B.lock_type))
					contents_brought += recursive_type_check(B)

			var/locked_to_current_z = 0//To prevent the moveable atom from leaving this Z, examples are DAT DISK and derelict MoMMIs.

			for(var/obj/item/weapon/disk/nuclear/nuclear in contents_brought)
				locked_to_current_z = map.zMainStation
				break

			//Check if it's a mob pulling an object
			var/obj/was_pulling = null
			var/mob/living/MOB = null
			if(isliving(A))
				MOB = A
				if(MOB.pulling)
					was_pulling = MOB.pulling //Store the object to transition later


			var/move_to_z = src.z

			// Prevent MoMMIs from leaving the derelict.
			for(var/mob/living/silicon/robot/mommi in contents_brought)
				if(mommi.locked_to_z != 0)
					if(src.z == mommi.locked_to_z)
						locked_to_current_z = map.zMainStation
					else
						to_chat(mommi, "<span class='warning'>You find your way back.</span>")
						move_to_z = mommi.locked_to_z

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
					A.loc.Entered(A)

/turf/proc/is_plating()
	return 0
/turf/proc/is_asteroid_floor()
	return 0
/turf/proc/is_plasteel_floor()
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
	update_holomap_planes()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(src.intact)

// override for space turfs, since they should never hide anything
/turf/space/levelupdate()
	update_holomap_planes()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(0)

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L)
		qdel (L)
		L = null

//Creates a new turf
/turf/proc/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 1)
	if(loc)
		var/area/A = loc
		A.area_turfs -= src
	if (!N || !allow)
		return

#ifdef ENABLE_TRI_LEVEL
// Fuck this, for now - N3X
///// Z-Level Stuff ///// This makes sure that turfs are not changed to space when one side is part of a zone
	if(N == /turf/space)
		var/turf/controller = locate(1, 1, src.z)
		for(var/obj/effect/landmark/zcontroller/c in controller)
			if(c.down)
				var/turf/below = locate(src.x, src.y, c.down_target)
				if((air_master.has_valid_zone(below) || air_master.has_valid_zone(src)) && !istype(below, /turf/space)) // dont make open space into space, its pointless and makes people drop out of the station
					var/turf/W = src.ChangeTurf(/turf/simulated/floor/open)
					var/list/temp = list()
					temp += W
					c.add(temp,3,1) // report the new open space to the zcontroller

					if(opacity != initialOpacity)
						UpdateAffectingLights()

					return W
///// Z-Level Stuff
#endif

	var/datum/gas_mixture/env

	var/old_opacity = opacity
	var/old_dynamic_lighting = dynamic_lighting
	var/old_affecting_lights = affecting_lights
	var/old_lighting_overlay = lighting_overlay
	var/old_corners = corners

	var/old_holomap = holomap_data
//	to_chat(world, "Replacing [src.type] with [N]")

	if(connections)
		connections.erase_all()

	if(istype(src,/turf/simulated))
		//Yeah, we're just going to rebuild the whole thing.
		//Despite this being called a bunch during explosions,
		//the zone will only really do heavy lifting once.
		var/turf/simulated/S = src
		env = S.air //Get the air before the change
		if(S.zone)
			S.zone.rebuild()
	if(istype(src,/turf/simulated/floor))
		var/turf/simulated/floor/F = src
		if(F.floor_tile)
			returnToPool(F.floor_tile)
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
		if(env)
			W.air = env //Copy the old environment data over if both turfs were simulated

		if (istype(W,/turf/simulated/floor) && !W.can_exist_under_lattice)
			W.RemoveLattice()

		if(tell_universe)
			universe.OnTurfChange(W)

		if(air_master)
			air_master.mark_for_update(src)

		W.levelupdate()

		. = W

	else
		//if(zone)
		//	zone.RemoveTurf(src)
		//	if(!zone.CheckStatus())
		//		zone.SetStatus(ZONE_ACTIVE)

		var/turf/W = new N(src)

		if(tell_universe)
			universe.OnTurfChange(W)

		if(air_master)
			air_master.mark_for_update(src)

		W.levelupdate()

		. = W

	recalc_atom_opacity()
	if (SSlighting && SSlighting.initialized)
		lighting_overlay = old_lighting_overlay
		affecting_lights = old_affecting_lights
		corners = old_corners
		if((old_opacity != opacity) || (dynamic_lighting != old_dynamic_lighting) || force_lighting_update)
			reconsider_lights()
		if(dynamic_lighting != old_dynamic_lighting)
			if(dynamic_lighting)
				lighting_build_overlay()
			else
				lighting_clear_overlay()

	holomap_data = old_holomap // Holomap persists through everything...
	update_holomap_planes() // But we might need to recalculate it.

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


//Commented out by SkyMarshal 5/10/13 - If you are patching up space, it should be vacuum.
//  If you are replacing a wall, you have increased the volume of the room without increasing the amount of gas in it.
//  As such, this will no longer be used.

//////Assimilate Air//////
/*
/turf/simulated/proc/Assimilate_Air()
	var/aoxy = 0//Holders to assimilate air from nearby turfs
	var/anitro = 0
	var/aco = 0
	var/atox = 0
	var/atemp = 0
	var/turf_count = 0

	for(var/direction in cardinal)//Only use cardinals to cut down on lag
		var/turf/T = get_step(src,direction)
		if(istype(T,/turf/space))//Counted as no air
			turf_count++//Considered a valid turf for air calcs
			continue
		else if(istype(T,/turf/simulated/floor))
			var/turf/simulated/S = T
			if(S.air)//Add the air's contents to the holders
				aoxy += S.air.oxygen
				anitro += S.air.nitrogen
				aco += S.air.carbon_dioxide
				atox += S.air.toxins
				atemp += S.air.temperature
			turf_count ++
	air.oxygen = (aoxy/max(turf_count,1))//Averages contents of the turfs, ignoring walls and the like
	air.nitrogen = (anitro/max(turf_count,1))
	air.carbon_dioxide = (aco/max(turf_count,1))
	air.toxins = (atox/max(turf_count,1))
	air.temperature = (atemp/max(turf_count,1))//Trace gases can get bant
	air.update_values()

	//cael - duplicate the averaged values across adjacent turfs to enforce a seamless atmos change
	for(var/direction in cardinal)//Only use cardinals to cut down on lag
		var/turf/T = get_step(src,direction)
		if(istype(T,/turf/space))//Counted as no air
			continue
		else if(istype(T,/turf/simulated/floor))
			var/turf/simulated/S = T
			if(S.air)//Add the air's contents to the holders
				S.air.oxygen = air.oxygen
				S.air.nitrogen = air.nitrogen
				S.air.carbon_dioxide = air.carbon_dioxide
				S.air.toxins = air.toxins
				S.air.temperature = air.temperature
				S.air.update_values()
*/

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

/turf/proc/Bless()
	flags |= NOJAUNT

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
#define PLANE_FOR (intact ? ABOVE_TURF_PLANE : ABOVE_PLATING_PLANE)
/turf/proc/add_holomap(var/atom/movable/AM)
	var/image/I = new
	I.appearance = AM.appearance
	I.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	I.loc = src
	I.dir = AM.dir
	I.alpha = 128
	// Since holomaps are overlays of the turf
	// This'll make them always be just above the turf and not block interaction.
	I.plane = PLANE_FOR
	// When I said above turfs I mean it.
	I.layer = HOLOMAP_LAYER

	if (!holomap_data)
		holomap_data = list()
	holomap_data += I

// Calls the above, but only if the game has not yet started.
/turf/proc/soft_add_holomap(var/atom/movable/AM)
	if (!ticker || ticker.current_state != GAME_STATE_PLAYING)
		add_holomap(AM)

// Goddamnit BYOND.
// So for some reason, I incurred a rendering issue with the usage of FLOAT_PLANE for the holomap plane.
//   (For some reason the existance of underlays prevented the main icon and overlays to render)
//   (Yes, removing every underlay with VV instantly fixed the overlays and main icon)
//   (Yes, I tried to reproduce it outside SS13, but got nothing)
// So now I need to render the overlays at the plane above the turf (ABOVE_TURF_PLANE and ABOVE_PLATING_PLANE)
// And as you probably already guessed, the plane required changes based on the turf type.
// So this helper does that.
/turf/proc/update_holomap_planes()
	var/the_plane = PLANE_FOR
	for (var/image/I in holomap_data)
		I.plane = the_plane

#undef PLANE_FOR

// Return -1 to make movement instant for the mob
// Return high values to make movement slower
/turf/proc/adjust_slowdown(mob/living/L, base_slowdown)
	return base_slowdown

/turf/proc/has_gravity(mob/M)
	if(istype(M) && M.CheckSlip() == -1) //Wearing magboots - good enough
		return 1

	var/area/A = loc
	if(istype(A))
		return A.has_gravity

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

	A.contents.Add(src)

	if(old_area)
		change_area(old_area, A)
		for(var/atom/AM in contents)
			AM.change_area(old_area, A)

/turf/spawned_by_map_element(datum/map_element/ME, list/objects)
	.=..()

	src.map_element = ME
