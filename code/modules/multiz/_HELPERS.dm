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