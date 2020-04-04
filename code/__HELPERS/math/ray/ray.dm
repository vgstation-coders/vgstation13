//default maximum distance of a raycast, can be overridden
#define RAY_CAST_DEFAULT_MAX_DISTANCE 50

//step size of a raycast, used to calculate one step by multiplying with floored direction vector
#define RAY_CAST_STEP 0.01

//used to tell cast() to not have a hit limit (default value of max_hits)
#define RAY_CAST_UNLIMITED_HITS 0

//Return values for raycast_hit_check
#define RAY_CAST_NO_HIT_EXIT -1
#define RAY_CAST_NO_HIT_CONTINUE 0
#define RAY_CAST_HIT_CONTINUE 1
#define RAY_CAST_HIT_EXIT 2

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

//gets a point along the ray
/ray/proc/getPoint(var/distance)
	var/vector/path = direction * distance
	return (origin + path).floored()

//inherit and override this for costum logic
//=> for possible return values check defines at top of file
/ray/proc/raycast_hit_check(var/atom/movable/A)
	return RAY_CAST_HIT_CONTINUE

//returns list of raycasthits
//TODO (copy and modify getAllHits)
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
				hits += new /rayCastHit(src, T, distance)
				if(max_hits && max_hits >= hits.len)
					break
			if(RAY_CAST_HIT_EXIT)
				. += new /rayCastHit(src, T, distance)
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
					. += new /rayCastHit(src, A, distance)
					if(max_hits && max_hits >= hits.len)
						break
				if(RAY_CAST_HIT_EXIT)
					. += new /rayCastHit(src, A, distance)
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

