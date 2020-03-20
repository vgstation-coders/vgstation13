#define RAY_CAST_DEFAULT_MAX_DISTANCE 50
#define RAY_CAST_STEP 0.01

/ray
	var/z
	var/vector/origin //the origin of the ray
	var/vector/origin_floored //the floored origin vector
	var/vector/direction //direction of the ray

//use atom2vector for the origin, atoms2vector for the direction
/ray/New(var/vector/p_origin, var/vector/p_direction, var/z)
	origin = p_origin
	origin_floored = origin.floored()
	direction = p_direction.chebyshev_normalized()
	src.z = z

/ray/proc/getPoint(var/distance)
	var/vector/path = direction * distance
	return (origin + path).floored()

/ray/proc/getFirstHit(var/max_distance = RAY_CAST_DEFAULT_MAX_DISTANCE)
	var/vector/a_step = direction * RAY_CAST_STEP
	var/step_distance = a_step.chebyshev_norm()
	var/vector/pointer = new /vector(0,0)
	var/distance = 0
	while(distance < max_distance)
		pointer += a_step
		distance += step_distance
		var/vector/new_position_unfloored = origin + pointer
		var/vector/new_position = new_position_unfloored.floored()
		if(!new_position.equals(origin_floored))
			var/turf/T = locate(new_position.x, new_position.y, z)
			return new /rayCastHit(src, T, distance)

/ray/proc/getAllHits(var/max_distance = RAY_CAST_DEFAULT_MAX_DISTANCE)
	var/vector/a_step = direction * RAY_CAST_STEP
	var/step_distance = a_step.chebyshev_norm()
	var/vector/pointer = new /vector(0,0)
	var/distance = 0
	var/list/vector/positions = list()
	while(distance < max_distance)
		pointer += a_step
		distance += step_distance
		var/vector/new_position_unfloored = origin + pointer
		var/vector/new_position = new_position_unfloored.floored()
		var/exists = FALSE
		for(var/vector/V in positions)
			if(V.equals(new_position))
				exists = TRUE
		if(!exists && !new_position.equals(origin_floored))
			positions += new_position

	. = list()
	for(var/vector/P in positions)
		var/turf/T = locate(P.x, P.y, z)
		. += new /rayCastHit(src, T, (P - origin).euclidian_norm())
