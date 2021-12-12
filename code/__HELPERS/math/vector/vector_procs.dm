/atom/movable/proc/vector_translate(var/vector/V, var/delay)
	var/turf/T = get_turf(src)
	var/turf/destination = locate(T.x + V.x, T.y + V.y, z)
	var/vector/V_norm = V.chebyshev_normalized()
	if (!V_norm.is_integer())
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
	return new /vector(A.x, A.y)

//Vector from A -> B
/proc/atoms2vector(var/atom/A, var/atom/B)
	return new /vector((B.x - A.x), (B.y - A.y))


/proc/dir2vector(var/dir)
	switch(dir)
		if(NORTH)
			return new /vector(0,1)
		if(NORTHEAST)
			return new /vector(1,1)
		if(EAST)
			return new /vector(1,0)
		if(SOUTHEAST)
			return new /vector(1,-1)
		if(SOUTH)
			return new /vector(0,-1)
		if(SOUTHWEST)
			return new /vector(-1,-1)
		if(WEST)
			return new /vector(-1,0)
		if(NORTHWEST)
			return new /vector(-1,1)

//defaults to north
/proc/vector2ClosestDir(var/vector/V)
	var/vector/V_norm = V.chebyshev_normalized()

	var/smallest_dist = 2 //since all vectors are normalized, the biggest possible distance is 2
	var/closestDir = NORTH
	for(var/d in alldirs)
		var/vector/dir = dir2vector(d)
		var/vector/delta = dir.chebyshev_normalized() - V_norm
		var/dist = delta.chebyshev_norm()
		if(dist < smallest_dist)
			smallest_dist = dist
			closestDir = d
	return closestDir

/proc/drawLaser(var/vector/A, var/vector/B, var/icon='icons/obj/projectiles.dmi', var/icon_state = "laser")
	var/vector/delta = (B - A)
	var/ray/laser_ray = new /ray(A, delta)
	var/distance = delta.chebyshev_norm()

	laser_ray.draw(distance, icon, icon_state)

/proc/vector2turf(var/vector/V, var/z)
	var/turf/T = locate(V.x, V.y, z)
	return T

// Return a list of unity vectors
/proc/vector_to_steps(var/vector/V)
	var/steps_number = max(abs(V.x), abs(V.y))
	var/list/vector/steps = list()
	for (var/i = 1 to steps_number)
		var/delta = abs(V.x) - abs(V.y)
		switch (delta)
			if (-12 to -1)
				steps += new /vector(sign(V.x), 0)
				V.x -= sign(V.x)
			if (0)
				steps += new /vector(sign(V.x), sign(V.y))
				V.x -= sign(V.x)
				V.y -= sign(V.y)
			if (1 to 12)
				steps += new /vector(0, sign(V.y))
				V.y -= sign(V.y)
