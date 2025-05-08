/atom/movable/proc/vector_translate(var/_vector/V, var/delay)
	var/turf/T = get_turf(src)
	var/turf/destination = locate(T.x + V.x, T.y + V.y, z)
	var/_vector/V_norm = V.chebyshev_normalized()
	if (!V_norm.is_integer())
		return
	var/turf/destination_temp
	while (destination_temp != destination)
		destination_temp = locate(T.x + V_norm.x, T.y + V_norm.y, z)
		forceMove(destination_temp, glide_size_override = DELAY2GLIDESIZE(delay))
		T = get_turf(src)
		sleep(delay + world.tick_lag) // Shortest possible time to sleep

/atom/proc/get_translated_turf(var/_vector/V)
	var/turf/T = get_turf(src)
	return locate(T.x + V.x, T.y + V.y, z)

//Vector representing world-pos of A
/proc/atom2vector(var/atom/A)
	return new /_vector(A.x, A.y)

//Vector from A -> B
/proc/atoms2vector(var/atom/A, var/atom/B)
	return new /_vector((B.x - A.x), (B.y - A.y))


/proc/dir2vector(var/dir)
	switch(dir)
		if(NORTH)
			return new /_vector(0,1)
		if(NORTHEAST)
			return new /_vector(1,1)
		if(EAST)
			return new /_vector(1,0)
		if(SOUTHEAST)
			return new /_vector(1,-1)
		if(SOUTH)
			return new /_vector(0,-1)
		if(SOUTHWEST)
			return new /_vector(-1,-1)
		if(WEST)
			return new /_vector(-1,0)
		if(NORTHWEST)
			return new /_vector(-1,1)

//defaults to north
/proc/vector2ClosestDir(var/_vector/V)
	var/_vector/V_norm = V.chebyshev_normalized()

	var/smallest_dist = 2 //since all vectors are normalized, the biggest possible distance is 2
	var/closestDir = NORTH
	for(var/d in alldirs)
		var/_vector/dir = dir2vector(d)
		var/_vector/delta = dir.chebyshev_normalized() - V_norm
		var/dist = delta.chebyshev_norm()
		if(dist < smallest_dist)
			smallest_dist = dist
			closestDir = d
	return closestDir

/proc/drawLaser(var/_vector/A, var/_vector/B, var/icon='icons/obj/projectiles.dmi', var/icon_state = "laser")
	var/_vector/delta = (B - A)
	var/ray/laser_ray = new /ray(A, delta)
	var/distance = delta.chebyshev_norm()

	laser_ray.draw(distance, icon, icon_state)

/proc/vector2turf(var/_vector/V, var/z)
	var/turf/T = locate(V.x, V.y, z)
	return T

