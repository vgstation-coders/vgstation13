/atom/movable/proc/vector_translate(var/vector/V, var/delay)
	var/turf/T = get_turf(src)
	var/turf/destination = locate(T.x + V.x, T.y + V.y, z)
	var/vector/V_norm = chebyshev_normalized(V)
	if (!is_integer(V_norm))
		return
	var/turf/destination_temp
	while (destination_temp != destination)
		destination_temp = locate(T.x + V_norm.x, T.y + V_norm.y, z)
		forceMove(destination_temp, glide_size_override = DELAY2GLIDESIZE(delay))
		T = get_turf(src)
		sleep(delay + world.tick_lag) // Shortest possible time to sleep

/atom/proc/get_translated_turf(var/vector/V)
	var/turf/T = get_turf(src)
	return locate(T.x + V.x, T.y + V.y, z)

//Vector representing world-pos of A
/proc/atom2vector(var/atom/A)
	return vector(A.x, A.y)

//Vector from A -> B
/proc/atoms2vector(var/atom/A, var/atom/B)
	return vector((B.x - A.x), (B.y - A.y))


/proc/dir2vector(var/dir)
	switch(dir)
		if(NORTH)
			return vector(0,1)
		if(NORTHEAST)
			return vector(1,1)
		if(EAST)
			return vector(1,0)
		if(SOUTHEAST)
			return vector(1,-1)
		if(SOUTH)
			return vector(0,-1)
		if(SOUTHWEST)
			return vector(-1,-1)
		if(WEST)
			return vector(-1,0)
		if(NORTHWEST)
			return vector(-1,1)

//defaults to north
/proc/vector2ClosestDir(var/vector/V)
	var/vector/V_norm = chebyshev_normalized(V)

	var/smallest_dist = 2 //since all vectors are normalized, the biggest possible distance is 2
	var/closestDir = NORTH
	for(var/d in alldirs)
		var/vector/dir = dir2vector(d)
		var/vector/delta = chebyshev_normalized(dir) - V_norm
		var/dist = chebyshev_norm(delta)
		if(dist < smallest_dist)
			smallest_dist = dist
			closestDir = d
	return closestDir

/proc/drawLaser(var/vector/A, var/vector/B, var/icon='icons/obj/projectiles.dmi', var/icon_state = "laser")
	var/vector/delta = (B - A)
	var/ray/laser_ray = new /ray(A, delta)
	var/distance = chebyshev_norm(delta)

	laser_ray.draw(distance, icon, icon_state)

/proc/vector2turf(var/vector/V, var/z)
	var/turf/T = locate(V.x, V.y, z)
	return T

