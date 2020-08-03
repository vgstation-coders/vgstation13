//default maximum distance of a raycast, can be overridden
#define RAY_CAST_DEFAULT_MAX_DISTANCE 50

//step size of a raycast, used to calculate one step by multiplying with floored direction vector
#define RAY_CAST_STEP 0.01

//used to tell cast() to not have a hit limit (default value of max_hits)
#define RAY_CAST_UNLIMITED_HITS 0

//Return values for raycast_hit_check
#define RAY_CAST_NO_HIT_EXIT 		-1
#define RAY_CAST_NO_HIT_CONTINUE 	0
#define RAY_CAST_HIT_CONTINUE 		1
#define RAY_CAST_HIT_EXIT 			2

/ray
	var/z //the z-level we are casting our ray in
	var/vector/origin //the origin of the ray
	var/vector/origin_floored //the floored origin vector
	var/vector/direction //direction of the ray

//use atom2vector for the origin, atoms2vector for the direction
/ray/New(var/vector/p_origin, var/vector/p_direction, var/z)
	origin = p_origin
	origin_floored = origin.floored() //to save us from calculating it all over again
	direction = p_direction.chebyshev_normalized()
	src.z = z

//checks if another ray overlaps this one
/ray/proc/overlaps(var/ray/other_ray)
	if(!(direction.equals(other_ray.direction) || direction.equals(-1*other_ray.direction))) //direction is normalized, so we can check like this
		return FALSE

	return hitsPoint(other_ray.origin)

//returns true if point is on our ray (can be called with a max distance)
/ray/proc/hitsPoint(var/vector/point, var/max_distance = 0)
	if(origin.equals(point)) //the easy way out
		return TRUE

	var/c_x = (point.x - origin.x) / direction.x
	var/c_y = (point.y - origin.y) / direction.y
	return (c_x == c_y && (!max_distance || c_x <= max_distance ))

/ray/proc/hitsArea(var/vector/position, var/vector/dimensions)
	var/angle = direction.toAngle()
	if(angle < 90)
		return (hitsLine(position, position + new /vector(0, dimensions.y)) || hitsLine(position, position + new /vector(dimensions.x, 0)))
	else if(angle < 180)
		return (hitsLine(position, position + new /vector(0, dimensions.y)) || hitsLine(position + new /vector(0, dimensions.y), position + dimensions))
	else if(angle < 270)
		return (hitsLine(position + new /vector(0, dimensions.y), position + dimensions) || hitsLine(position + new /vector(dimensions.x, 0), position + dimensions))
	else if(angle < 360)
		return (hitsLine(position, position + new /vector(dimensions.x, 0)) || hitsLine(position + new /vector(dimensions.x, 0), position + dimensions))
	else
		return FALSE

/ray/proc/hitsLine(var/vector/start, var/vector/end)
	var/vector/line_direction = end - start
	line_direction = line_direction.chebyshev_normalized()
	if(direction.equals(line_direction) || direction.equals(-1*line_direction))
		if(hitsPoint(start))
			return TRUE
		else
			return FALSE

	//TODO CROSS CALC

//returns rebound angle of hit atom
//assumes atom is 1x1 hexagonal box
/ray/proc/getReboundOnAtom(var/rayCastHit/hit)
	//calc where we hit the atom
	var/vector/hit_point = hit.point
	var/vector/hit_atom_loc = atom2vector(hit.hit_atom)

	var/vector/hit_vector = hit_point - hit_atom_loc

	//we assume every atom is a hex, hence we use all_vectors
	var/smallest_angle = 360
	var/vector/entry_dir = null

	for(var/vector/dir in all_vectors)
		var/angle = dir.angleBetween(hit_vector)
		if(angle < smallest_angle)
			smallest_angle = angle
			entry_dir = dir

	return src.direction.mirrorWith(entry_dir)

//gets a point along the ray
/ray/proc/getPoint(var/distance)
	var/vector/path = direction * distance
	return (origin + path).floored()

//inherit and override this for costum logic
//=> for possible return values check defines at top of file
/ray/proc/raycast_hit_check(var/atom/movable/A)
	return RAY_CAST_HIT_CONTINUE

//returns list of raycasthits
/ray/proc/cast(var/max_distance = RAY_CAST_DEFAULT_MAX_DISTANCE, var/max_hits = RAY_CAST_UNLIMITED_HITS, var/ignore_origin = TRUE)
	//calculating a step and its distance to use in the loop
	var/vector/a_step = direction * RAY_CAST_STEP
	var/step_distance = a_step.chebyshev_norm()

	//setting up our pointer and distance to track where we are
	var/vector/pointer = new /vector(0,0)
	var/distance = 0

	//positions list to easier check if we already found this position (since we are moving in tiny steps, not full numbers)
	var/list/vector/positions = list()

	//our result
	var/list/atom/movable/hits = list()

	while(distance < max_distance)
		//moving one step further
		pointer += a_step
		distance += step_distance

		//calculating our current position in world space (its two lines cause byond)
		var/vector/new_position_unfloored = origin + pointer
		var/vector/new_position = new_position_unfloored.floored()

		//check if we already checked this (floored) vector
		var/exists = FALSE
		for(var/vector/V in positions)
			if(V.equals(new_position))
				exists = TRUE
		if(exists)
			continue

		//check if this is origin and if we should ignore it
		if(!ignore_origin || new_position.equals(origin_floored))
			continue

		//getting the turf at our current (floored) vector
		var/turf/T = locate(new_position.x, new_position.y, z)

		//trying hit at turf
		switch(raycast_hit_check(T))
			if(RAY_CAST_NO_HIT_EXIT)
				break; //exit loop
			if(RAY_CAST_HIT_CONTINUE)
				hits += new /rayCastHit(src, T, new_position, distance)
				if(max_hits && max_hits >= hits.len)
					break
			if(RAY_CAST_HIT_EXIT)
				. += new /rayCastHit(src, T, new_position, distance)
				if(max_hits && max_hits >= hits.len)
					break
				break //exit loop
			//if(RAY_CAST_NO_HIT_CONTINUE) <-- not included cause we dont do anything here

		//trying hit on every atom inside the turf
		for(var/atom/movable/A in T)
			switch(raycast_hit_check(A))
				if(RAY_CAST_NO_HIT_EXIT)
					break; //exit loop
				if(RAY_CAST_HIT_CONTINUE)
					. += new /rayCastHit(src, A, new_position, distance)
					if(max_hits && max_hits >= hits.len)
						break
				if(RAY_CAST_HIT_EXIT)
					. += new /rayCastHit(src, A, new_position, distance)
					if(max_hits && max_hits >= hits.len)
						break
					break //exit loop
				//if(RAY_CAST_NO_HIT_CONTINUE) <-- not included cause we dont do anything here

		//adding our position so we know we already checked this one
		positions += new_position

//helper proc to get first hit
/ray/proc/getFirstHit(var/max_distance = RAY_CAST_DEFAULT_MAX_DISTANCE, var/ignore_origin = TRUE)
	var/list/result = cast(max_distance, 1, ignore_origin)
	if(result.len)
		return result[1]
	else
		return null

