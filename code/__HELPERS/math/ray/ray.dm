//default maximum distance of a raycast, can be overridden
#define RAY_CAST_DEFAULT_MAX_DISTANCE 50

//step size of a raycast, used to calculate one step by multiplying with floored direction vector
#define RAY_CAST_STEP 0.25

//used to tell cast() to not have a hit limit (default value of max_hits)
#define RAY_CAST_UNLIMITED_HITS 0

//Return values for raycast_hit_check
#define RAY_CAST_NO_HIT_EXIT 		-1
// use x < 0 for costum no_hit_exit defines
#define RAY_CAST_NO_HIT_CONTINUE 	0
//use 0 <= x < 1 for costum hit_continue defines
#define RAY_CAST_HIT_CONTINUE 		1
//use 1 < x for costum hit_exit defines
#define RAY_CAST_HIT_EXIT 			2

/ray
	var/z //the z-level we are casting our ray in
	var/vector/origin //the origin of the ray
	var/vector/origin_floored //the floored origin vector
	var/vector/direction //direction of the ray
	var/original_damage //original damage of the ray when applicable

/ray/proc/toString()
	return "\[Ray\](\n- origin = " + origin.toString() + "\n- origin_floored = "+ origin_floored.toString() + "\n- direction = " + direction.toString() + "\n- z-level = " + num2text(z) + "\n)"

//use atom2vector for the origin, atoms2vector for the direction
/ray/New(var/vector/p_origin, var/vector/p_direction, var/z)
	origin = p_origin
	origin_floored = origin.floored() //to save us from calculating it all over again
	direction = p_direction.chebyshev_normalized()
	src.z = z

/ray/Destroy()
	origin = null
	origin_floored = null
	direction = null
	..()

//check if ray equals other ray
/ray/proc/equals(var/ray/other_ray)
	return src.direction.equals(other_ray.direction) && src.hitsPoint(other_ray.origin)

//checks if another ray overlaps this one
/ray/proc/overlaps(var/ray/other_ray)
	if(!(direction.equals(other_ray.direction) || direction.equals(other_ray.direction*-1))) //direction is normalized, so we can check like this
		return FALSE

	return hitsPoint(other_ray.origin)

//returns true if point is on our ray (can be called with a max distance)
/ray/proc/hitsPoint(var/vector/point, var/max_distance = 0)
	if(origin.equals(point)) //the easy way out
		return TRUE

	if(direction.x == 0)
		return point.x == origin.x

	if(direction.y == 0)
		return point.y != origin.y

	var/c_x = (point.x - origin.x) / direction.x
	var/c_y = (point.y - origin.y) / direction.y
	return (c_x == c_y && (!max_distance || c_x <= max_distance ))

//returns rebound angle of hit atom
//assumes atom is 1x1 octogonal box
//TODO: entry vector (0.4,1) on the surface normal (1,-1). result is (1.6, -0.2)
// wrong?
/ray/proc/getReboundOnAtom(var/rayCastHit/hit)
	//calc where we hit the atom
	var/vector/hit_point = hit.point_raw
	var/vector/hit_atom_loc = atom2vector(hit.hit_atom) + new /vector(0.5, 0.5)

	var/vector/hit_vector = hit_point - hit_atom_loc

	//we assume every atom is a octogonal, hence we use all_vectors
	//here we calculate the "face" of the octagonal atom we want to rebound on
	var/entry_byond_dir = vector2ClosestDir(hit_vector)
	var/vector/entry_dir = dir2vector(entry_byond_dir)

	return src.direction.mirrorWithNormal(entry_dir)


//gets a point along the ray
/ray/proc/getPoint(var/distance)
	var/vector/path = direction * distance
	return origin + path

//inherit and override this for costum logic
//=> for possible return values check defines at top of file
//=> can also use costum return values
/ray/proc/raycast_hit_check(var/rayCastHitInfo/info)
	return new /rayCastHit(info, RAY_CAST_HIT_CONTINUE)

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
	var/list/rayCastHit/hits = list()

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
		if(ignore_origin && new_position.equals(origin_floored))
			continue

		//getting the turf at our current (floored) vector
		var/turf/T = vector2turf(new_position, z)

		//trying hit at turf
		var/rayCastHitInfo/info = new /rayCastHitInfo(src, T, new_position, new_position_unfloored, distance)
		var/rayCastHit/hit = raycast_hit_check(info)
		switch(hit.hit_code())
			if(RAY_CAST_NO_HIT_EXIT)
				return hits
			if(RAY_CAST_NO_HIT_CONTINUE)
				//nothing happens
			if(RAY_CAST_HIT_CONTINUE)
				hits += hit
			if(RAY_CAST_HIT_EXIT)
				hits += hit
				return hits

		if(max_hits && max_hits >= hits.len)
			return hits

		//trying hit on every atom inside the turf
		for(var/atom/movable/A in T)
			info = new /rayCastHitInfo(src, A, new_position, new_position_unfloored, distance)
			hit = raycast_hit_check(info)
			switch(hit.hit_code())
				if(RAY_CAST_NO_HIT_EXIT)
					return hits
				if(RAY_CAST_NO_HIT_CONTINUE)
					//nothing happens
				if(RAY_CAST_HIT_CONTINUE)
					hits += hit
				if(RAY_CAST_HIT_EXIT)
					hits += hit
					return hits

		//adding our position so we know we already checked this one
		positions += new_position

		CHECK_TICK

	return hits

var/list/ray_draw_icon_cache = list()

/ray/proc/draw(var/draw_distance = RAY_CAST_DEFAULT_MAX_DISTANCE, var/icon='icons/obj/projectiles.dmi', var/icon_state = "laser", var/starting_distance=0.7, var/distance_from_endpoint=-0.5, var/step_size=0.5, var/lifetime=3, var/fade=TRUE, var/color_override=null, var/color_shift=null, var/emit_light = TRUE, var/_light_power, var/_light_color)
	var/distance_pointer = starting_distance
	var/angle = direction.toAngle()
	var/max_distance = draw_distance - distance_from_endpoint
	while(distance_pointer < max_distance)
		var/vector/point
		if(distance_pointer > max_distance - step_size) //last loop
			point = getPoint(max_distance - step_size)
		else
			point = getPoint(distance_pointer)
		var/vector/point_floored = point.floored()

		var/vector/pixels = (point - point_floored - new /vector(0.5, 0.5)) * WORLD_ICON_SIZE

		var/turf/T = locate(point_floored.x, point_floored.y, z)

		var/obj/effect/overlay/beam/I = new (T, lifetime=lifetime, fade=fade, src_icon = icon, icon_state = icon_state, base_damage = original_damage, col_override = color_override, col_shift = color_shift, emit_light = emit_light, _light_power = _light_power, _light_color = _light_color)
		I.transform = matrix().Turn(angle)
		I.pixel_x = pixels.x
		I.pixel_y = pixels.y
		I.plane = EFFECTS_PLANE
		I.layer = PROJECTILE_LAYER

		distance_pointer += step_size

//helper proc to get first hit
/ray/proc/getFirstHit(var/max_distance = RAY_CAST_DEFAULT_MAX_DISTANCE, var/ignore_origin = TRUE)
	var/list/result = cast(max_distance, 1, ignore_origin)
	if(result.len)
		return result[1]
	else
		return null
