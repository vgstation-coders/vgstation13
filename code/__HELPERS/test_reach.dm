//test_reach(), by Deity Link
//Basically sends a cheap projectile that moves from a turf A to a turf B in a "straight" line. Returns true if it reaches turf B without hitting anything on the way there (other than turf B itself)
//Useful for instance to check if an item thrown/projectile fired from a A to B would reach its target

/proc/test_reach(var/turf/origin,var/turf/destination,var/_pass_flags=0)
	if (!origin || !destination)
		return FALSE
	if (origin.z != destination.z)
		return FALSE
	if (origin == destination)
		return TRUE
	var/obj/test_reach/test = new(origin,destination,_pass_flags)
	var/result = test.main()
	qdel(test)
	return result

//////////////////////////////////////////////////////////////////////////////////////////////

/obj/test_reach
	invisibility = 101
	pass_flags = 0

	var/dist_x
	var/dist_y
	var/dx = 0
	var/dy = 0
	var/error = 0
	var/target_angle = 0
	var/bumped = 0
	var/max_range = 100
	var/turf/starting
	var/turf/target

	var/result = FALSE
	var/finished = FALSE

/obj/test_reach/New(var/turf/loc,var/turf/destination,var/_pass_flags)
	..()
	starting = loc
	target = destination
	pass_flags = _pass_flags

/obj/test_reach/proc/main()
	//let's do our first movement by carefully going around any adjacent wall if another cardinal direction toward our destination is possible
	//this fixes a quirk with bresenham paths where it may decide to run into adjacent walls on its first step even when it doesn't make "sense"
	var/orientation = get_dir(loc,target)
	if (orientation in diagonal)
		var/turf/gotta_move = null
		for (var/direction in splitdiagonals(orientation))
			var/turf/T = get_step(loc,direction)
			if (!T.density && T.Adjacent(src))
				if (!gotta_move)
					gotta_move = T
				else
					gotta_move = null
		if (gotta_move)
			loc = gotta_move
			starting = loc
	if (starting == target)
		return TRUE
	//init
	dist_x = abs(target.x - starting.x)
	dist_y = abs(target.y - starting.y)
	if (target.x > starting.x)
		dx = EAST
	else
		dx = WEST

	if (target.y > starting.y)
		dy = NORTH
	else
		dy = SOUTH

	if(dist_x > dist_y)
		error = dist_x/2 - dist_y
	else
		error = dist_y/2 - dist_x

	//main loop
	while(loc && !finished)
		loop()

	return result

/obj/test_reach/proc/loop()
	if(loc && !finished)
		if(dist_x > dist_y)
			bresenham_step(dist_x,dist_y,dx,dy)
		else
			bresenham_step(dist_y,dist_x,dy,dx)

		bumped = 0

/obj/test_reach/proc/bresenham_step(var/distA, var/distB, var/dA, var/dB)//based on the code I wrote forever ago in projectiles.dm
	if(max_range < 1)
		finished = TRUE
		return
	max_range--
	if(error < 0)
		var/atom/step = get_step(src, dB)
		if(!step)
			finished = TRUE
			return
		Move(step)
		error += distA
		if (loc == target)
			result = TRUE
			finished = TRUE
	else
		var/atom/step = get_step(src, dA)
		if(!step)
			finished = TRUE
			return
		Move(step)
		error -= distB
		dir = dA
		if(error < 0)
			dir = dA + dB
		if (loc == target)
			result = TRUE
			finished = TRUE

/obj/test_reach/to_bump(var/atom/A)
	if (A == target)
		result = TRUE
		finished = TRUE
	else
		finished = TRUE
