/* Multi-Z code was ported from Polaris, which operates under the AGPL v3 license.
Permission for its use was obtained on 11/12/2017 from Neerti in the Polaris Discord. */

#define isopenspace(A) istype(A, /turf/simulated/open)
#define OPENSPACE_PLANE_START -23
#define OPENSPACE_PLANE_END -8
#define OPENSPACE_PLANE -25
#define OVER_OPENSPACE_PLANE -7
//#define QDELETED(X) (!X || X.gc_destroyed)  Polaris has this

/obj/effect/landmark/map_data
	name = "Unknown"
	desc = "An unknown location."
	invisibility = 101

	var/height = 1     ///< The number of Z-Levels in the map.
	var/turf/edge_type ///< What the map edge should be formed with. (null = world.turf)

/turf/proc/is_space()
	return 0

/turf/space/is_space()
	return 1

/atom/proc/set_dir(new_dir) //We should probably use this for our whole codebase for shadows. If z-shadow isn't working I may have to implement it widely.
	. = new_dir != dir
	dir = new_dir

/* PORT NOTES
- Removed scaling with magboots / robots (pending discussion)
- We appear to already tell universe on turf change so I removed turf changed handling (see Polaris turf/ChangeTurf) which required their observer datum, instead
see turfs/turf.dm ChangeTurf()
- We handle building lattices and plating differently, see turfs.dm
- We don't have edge blending, but that's mostly for grass stuff anyway.
- We have scrapped connect type. We'll let you connect any two pipes on the same layer. Also note Polaris has no layered piping.
- Polaris uses some different hearing with hear_say, hear_quote, hear_radio. Hopefully our Hear() covers it!
- Our pipes don't seem to use pipe_color, see update_icon
- Converted OS Controller into a subsystem (see subsystem.dm)
- When Bay/Polaris ported our ventcrawling, they adapted the relaymove in pipes into a proc ventcrawl_to. Now we've adapted to use that proc.
- Rather than try to implement audible_message from Polaris (a whole rabbithole of helper procs), converted them to visible_message
- Ported post_change() for turfs
- At 384 and 386 in process.dm we manually add to world.log, Polaris has logging procs (log_to_dd) that I didn't port
- Commented a log_runtime call at 365 for similar reasons

What's NOT ported?
- MultiZAS: airflow between Z levels (ZAS/ConnectionManager.dm)
- Elevators (modules/turbolift/)
- Powernet across Z levels?
*/

/*/turf/simulated/proc/update_icon_edge()
	if(edge_blending_priority)
		for(var/checkdir in cardinal)
			var/turf/simulated/T = get_step(src, checkdir)
			if(istype(T) && T.edge_blending_priority && edge_blending_priority < T.edge_blending_priority && icon_state != T.icon_state)
				var/cache_key = "[T.get_edge_icon_state()]-[checkdir]"
				if(!turf_edge_cache[cache_key])
					var/image/I = image(icon = 'icons/turf/outdoors_edge.dmi', icon_state = "[T.get_edge_icon_state()]-edge", dir = checkdir)
					I.plane = 0
					turf_edge_cache[cache_key] = I
				overlays += turf_edge_cache[cache_key]

/turf/simulated/proc/get_edge_icon_state()
	return icon_state*/

// Called after turf replaces old one
/turf/proc/post_change()
	levelupdate()
	var/turf/simulated/open/T = GetAbove(src)
	if(istype(T))
		T.update_icon()


/proc/is_on_same_plane_or_station(var/z1, var/z2)
	if(z1 == z2)
		return 1
	if((z1 in map.zLevels) && (z2 in map.zLevels))
		return 1
	return 0

/**
 * Z-Distance functions
 *
 * Because vanilla get_dist() only gets the max value of either x or y and not z for some reason, thanks BYOND!
 *
 * Euclidean follows suit for the proper formula
 */
/proc/get_z_dist(atom/Loc1 as turf|mob|obj,atom/Loc2 as turf|mob|obj)
	var/dx = Loc1.x - Loc2.x
	var/dy = Loc1.y - Loc2.y
	var/dz = Loc1.z - Loc2.z

	return max(dx,dy,dz)

/proc/get_z_dist_euclidian(atom/Loc1 as turf|mob|obj,atom/Loc2 as turf|mob|obj)
	var/dx = Loc1.x - Loc2.x
	var/dy = Loc1.y - Loc2.y
	var/dz = Loc1.z - Loc2.z

	return sqrt(dx**2 + dy**2 + dz**2)

/**
 * Get Distance, Squared
 *
 * Because sqrt is slow, this returns the z distance squared, which skips the sqrt step.
 *
 * Use to compare distances. Used in component mobs.
 */
/proc/get_z_dist_squared(var/atom/a, var/atom/b)
	return ((b.x-a.x)**2) + ((b.y-a.y)**2) + ((b.z-a.z)**2)

/* Polaris methods for getting hearers. Necessary? Not sure

/proc/get_mobs_or_objects_in_view(var/R, var/atom/source, var/include_mobs = 1, var/include_objects = 1)

	var/turf/T = get_turf(source)
	var/list/hear = list()

	if(!T)
		return hear

	var/list/range = hear(R, T)

	for(var/I in range)
		if(ismob(I))
			hear |= recursive_content_check(I, hear, 3, 1, 0, include_mobs, include_objects)
			if(include_mobs)
				var/mob/M = I
				if(M.client)
					hear += M
		else if(istype(I,/obj/))
			hear |= recursive_content_check(I, hear, 3, 1, 0, include_mobs, include_objects)
			var/obj/O = I
			if(O.show_messages && include_objects)
				hear += I

	return hear

// Will recursively loop through an atom's contents and check for mobs, then it will loop through every atom in that atom's contents.
// It will keep doing this until it checks every content possible. This will fix any problems with mobs, that are inside objects,
// being unable to hear people due to being in a box within a bag.

/proc/recursive_content_check(var/atom/O,  var/list/L = list(), var/recursion_limit = 3, var/client_check = 1, var/sight_check = 1, var/include_mobs = 1, var/include_objects = 1, var/ignore_show_messages = 0)

	if(!recursion_limit)
		return L

	for(var/I in O.contents)

		if(ismob(I))
			if(!sight_check || isInSight(I, O))
				L |= recursive_content_check(I, L, recursion_limit - 1, client_check, sight_check, include_mobs, include_objects)
				if(include_mobs)
					if(client_check)
						var/mob/M = I
						if(M.client)
							L |= M
					else
						L |= I

		else if(istype(I,/obj/))
			var/obj/check_obj = I
			if(ignore_show_messages || check_obj.show_messages)
				if(!sight_check || isInSight(I, O))
					L |= recursive_content_check(I, L, recursion_limit - 1, client_check, sight_check, include_mobs, include_objects)
					if(include_objects)
						L |= I

	return L*/

// BEGIN /VG/ CODE
/proc/multi_z_spiral_block(var/turf/epicenter,var/max_range,var/inward=0,var/draw_red=0,var/cube=1)
	var/list/spiraled_turfs = list()
	var/turf/upturf = epicenter
	var/turf/downturf = epicenter
	if(inward)
		var/upcount = 1
		var/downcount = 1
		for(var/i = 1, i < max_range, i++)
			if(HasAbove(upturf.z))
				upturf = GetAbove(upturf)
				upcount++
			if(HasBelow(downturf.z))
				downturf = GetBelow(downturf)
				downcount++
		for(var/i = 1, i < max_range, i++)
			if(GetBelow(upturf) != epicenter)
				upturf = GetBelow(upturf)
				spiraled_turfs += spiral_block(upturf, cube ? max_range : i + (max_range - upcount), inward, draw_red)
				log_debug("Spiralling block of size [cube ? max_range : i + (max_range - upcount)] in [upturf.loc.name] ([upturf.x],[upturf.y],[upturf.z])")
			if(GetAbove(upturf) != epicenter)
				downturf = GetAbove(downturf)
				spiraled_turfs += spiral_block(downturf, cube ? max_range : i + (max_range - downcount), inward, draw_red)
				log_debug("Spiralling block of size [cube ? max_range : i + (max_range - downcount)] in [downturf.loc.name] ([downturf.x],[downturf.y],[downturf.z])")
		log_debug("Spiralling block of size [max_range] in [epicenter.loc.name] ([epicenter.x],[epicenter.y],[epicenter.z])")
		spiraled_turfs += spiral_block(epicenter,max_range,inward,draw_red)
	else
		log_debug("Spiralling block of size [max_range] in [epicenter.loc.name] ([epicenter.x],[epicenter.y],[epicenter.z])")
		spiraled_turfs += spiral_block(epicenter,max_range,inward,draw_red)
		for(var/i = 1, i < max_range, i++)
			if(HasAbove(upturf.z))
				upturf = GetAbove(upturf)
				log_debug("Spiralling block of size [cube ? max_range : i + (max_range - i)] in [upturf.loc.name] ([upturf.x],[upturf.y],[upturf.z])")
				spiraled_turfs += spiral_block(upturf, cube ? max_range : max_range - i, inward, draw_red)
			if(HasBelow(downturf.z))
				downturf = GetBelow(downturf)
				log_debug("Spiralling block of size [cube ? max_range : i + (max_range - i)] in [downturf.loc.name] ([downturf.x],[downturf.y],[downturf.z])")
				spiraled_turfs += spiral_block(downturf, cube ? max_range : max_range - i, inward, draw_red)

	return spiraled_turfs

/client/proc/check_multi_z_spiral()
	set name = "Check Multi-Z Spiral Block"
	set category = "Debug"

	var/turf/epicenter = get_turf(usr)
	var/max_range = input("Set the max range") as num
	var/inward_txt = alert("Which way?","Spiral Block", "Inward","Outward")
	var/inward = inward_txt == "Inward" ? 1 : 0
	var/shape_txt = alert("What shape?","Spiral Block", "Cube","Octahedron")
	var/shape = shape_txt == "Cube" ? 1 : 0
	multi_z_spiral_block(epicenter,max_range,inward,1,shape)

// Halves above and below, as per suggestion by deity on how to handle multi-z explosions
/proc/explosion_destroy_multi_z(turf/epicenter, turf/offcenter, const/devastation_range, const/heavy_impact_range, const/light_impact_range, const/flash_range, var/explosion_time)
	if(HasAbove(offcenter.z) && (devastation_range >= 1 || heavy_impact_range >= 1 || light_impact_range >= 1 || flash_range >= 1))
		var/turf/upcenter = GetAbove(offcenter)
		if(upcenter.z > epicenter.z)
			explosion_destroy(epicenter, upcenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, explosion_time)
	if(HasBelow(offcenter.z) && (devastation_range >= 1 || heavy_impact_range >= 1 || light_impact_range >= 1 || flash_range >= 1))
		var/turf/downcenter = GetBelow(offcenter)
		if(downcenter.z < epicenter.z)
			explosion_destroy(epicenter, downcenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, explosion_time)