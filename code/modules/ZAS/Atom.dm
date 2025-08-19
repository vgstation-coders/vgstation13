/atom/movable/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	return (!density || !height || air_group)

/turf/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)

	if(!target || istype(mover))
		return !density

	else // Now, doing more detailed checks for air movement and air group formation
		if(target.blocks_air||blocks_air)
			return FALSE

		for(var/obj/obstacle in src)
			if(!obstacle.Cross(mover, target, height, air_group))
				return FALSE
		if(target != src)
			for(var/obj/obstacle in target)
				if(!obstacle.Cross(mover, src, height, air_group))
					return FALSE

		return TRUE

//Basically another way of calling Cross(null, other, 0, 0) and Cross(null, other, 1.5, 1).
//Returns:
// 0 - Not blocked
// AIR_BLOCKED - Blocked
// ZONE_BLOCKED - Not blocked, but zone boundaries will not cross.
// BLOCKED - Blocked, zone boundaries will not cross even if opened.
/atom/proc/c_airblock(turf/other)

/atom/movable/c_airblock(turf/other)
	#ifdef ZASDBG
	ASSERT(isturf(other))
	#endif
	return !Cross(null, other, 0, 0) + 2*!Cross(null, other, 1.5, 1)

/turf/c_airblock(turf/other)
	#ifdef ZASDBG
	ASSERT(isturf(other))
	#endif
	if(blocks_air)
		return BLOCKED

	//Z-level handling code. Always block if there isn't an open space.
	#ifdef ZLEVELS
	if(other.z != src.z)
		if(other.z < src.z)
			if(!istype(src, /turf/simulated/open))
				return BLOCKED
		else
			if(!istype(other, /turf/simulated/open))
				return BLOCKED
	#endif

	var/result = 0
	for(var/atom/movable/M in contents)
		result |= M.c_airblock(other)
		if(result == BLOCKED)
			return BLOCKED
	return result

/atom/proc/update_nearby_tiles(var/turf/T)
	if(!SS_READY(SSair))
		return 0

	if(!T)
		T = get_turf(src)
	if(isturf(T))
		SSair.mark_for_update(T)
	return 1
