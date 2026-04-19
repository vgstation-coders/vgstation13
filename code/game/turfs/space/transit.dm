/turf/space/transit
	var/pushdirection // push things that get caught in the transit tile this direction
	plane = TURF_PLANE

/turf/space/transit/Entered(atom/movable/A, atom/OldLoc)
	if(isliving(A) && !isobserver(A))
		var/datum/virtual_z/transit_v = src.v
		if(transit_v && transit_v.level_type == VZ_TRANSIT)
			var/list/datum/virtual_z/destinations = list()
			for(var/datum/virtual_z/vz in map.vLevels)
				if(vz.level_type == VZ_PARKING || vz.level_type == VZ_SPACE)
					destinations += vz
			if(destinations.len)
				var/datum/virtual_z/dest = pick(destinations)
				for(var/i = 1 to 50)
					var/tx = rand(dest.x_min + TRANSITIONEDGE, dest.x_max - TRANSITIONEDGE)
					var/ty = rand(dest.y_min + TRANSITIONEDGE, dest.y_max - TRANSITIONEDGE)
					var/turf/T = locate(tx, ty, dest.z())
					if(istype(T, /turf/space) && !istype(T, /turf/space/transit) && !istype(T, /turf/unsimulated/border))
						to_chat(A, "<span class='warning'>You are violently thrown out of hyperspace!</span>")
						var/mob/living/L = A
						transit_v.mob_exited(L)
						A.forceMove(T)
						dest.mob_entered(L)
						return
	..()

/turf/space/transit/New()
	if(loc)
		var/area/A = loc
		A.area_turfs += src

	update_icon()

/turf/space/transit/initialize()
	return

/turf/space/transit/update_icon()
	icon_state = ""

	var/dira=""
	var/i=0
	switch(pushdirection)
		if(SOUTH) // North to south
			dira="ns"
			i=1+(abs((x^2)-y)%15) // Vary widely across X, but just decrement across Y

		if(NORTH) // South to north  I HAVE NO IDEA HOW THIS WORKS I'M SORRY.  -Probe
			dira="ns"
			i=1+(abs((x^2)-y)%15) // Vary widely across X, but just decrement across Y

		if(WEST) // East to west
			dira="ew"
			i=1+(((y^2)+x)%15) // Vary widely across Y, but just increment across X

		if(EAST) // West to east
			dira="ew"
			i=1+((((y^2)-x)%15)+15)%15 // Vary widely across Y, but just increment across X (true modulo for negative values)


		/*
		if(NORTH) // South to north (SPRITES DO NOT EXIST!)
			dira="sn"
			i=1+(((x^2)+y)%15) // Vary widely across X, but just increment across Y

		if(EAST) // West to east (SPRITES DO NOT EXIST!)
			dira="we"
			i=1+(abs((y^2)-x)%15) // Vary widely across X, but just increment across Y
		*/

		else
			icon_state="black"
	if(icon_state != "black")
		icon_state = "speedspace_[dira]_[i]"

/turf/space/transit/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 0, var/defer_edges = FALSE)
	return ..(N, tell_universe, 1, allow, defer_edges)

//Overwrite because we dont want people building rods in space.
/turf/space/transit/attackby(obj/O as obj, mob/user as mob)
	return

/turf/space/transit/canBuildCatwalk()
	return BUILD_FAILURE

/turf/space/transit/canBuildLattice()
	return BUILD_FAILURE

/turf/space/transit/canBuildPlating()
	return BUILD_SILENT_FAILURE

/turf/space/transit/north // moving to the north

	pushdirection = SOUTH  // south because the space tile is scrolling south
	icon_state="debug-north"

/turf/space/transit/south // moving to the south

	pushdirection = NORTH
	icon_state="debug-south"

/turf/space/transit/east // moving to the east

	pushdirection = WEST
	icon_state="debug-east"

/turf/space/transit/west // moving to the west

	pushdirection = EAST
	icon_state="debug-west"

/turf/space/transit/horizon //special transit turf for Horizon

	pushdirection = SOUTH //the ship is moving forward
	plane = ABOVE_PARALLAX_PLANE
	icon_state="debug-north"

/turf/space/transit/horizon/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 1, var/defer_edges = FALSE)
    return ..(N, tell_universe, 1, allow, defer_edges)

/turf/space/transit/horizon/canBuildCatwalk()
	if(locate(/obj/structure/catwalk) in contents)
		return BUILD_FAILURE
	return locate(/obj/structure/lattice) in contents

/turf/space/transit/horizon/canBuildLattice(var/material)
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(locate(/obj/structure/catwalk) in contents)
		return BUILD_FAILURE
	else if(!(locate(/obj/structure/lattice) in contents) && !(istype(material,/obj/item/stack/sheet/wood)))
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/space/transit/horizon/canBuildPlating(var/material)
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if((locate(/obj/structure/lattice) in contents) && !(istype(material,/obj/item/stack/tile/wood)))
		return 1
	return BUILD_FAILURE

//code that throws you around like a little bitch. Commented out until I can figure out how to make it work.
///turf/space/transit/horizon/Crossed(atom/movable/O)
//    if(!istype(O) || isobserver(O) || istype(O, /obj/effect/beam))
//        return

//    step(O, pushdirection)

/turf/space/transit/faketransit //special transit turf for Horizon that doesn't throw you around like a little bitch

	pushdirection = SOUTH //the ship is moving forward
	plane = ABOVE_PARALLAX_PLANE
	icon_state="debug-north"

/turf/space/transit/faketransit/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 1, var/defer_edges = FALSE)
    return ..(N, tell_universe, 1, allow, defer_edges)

/turf/space/transit/faketransit/canBuildCatwalk()
	if(locate(/obj/structure/catwalk) in contents)
		return BUILD_FAILURE
	return locate(/obj/structure/lattice) in contents

/turf/space/transit/faketransit/canBuildLattice(var/material)
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(locate(/obj/structure/catwalk) in contents)
		return BUILD_FAILURE
	else if(!(locate(/obj/structure/lattice) in contents) && !(istype(material,/obj/item/stack/sheet/wood)))
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/space/transit/faketransit/canBuildPlating(var/material)
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if((locate(/obj/structure/lattice) in contents) && !(istype(material,/obj/item/stack/tile/wood)))
		return 1
	return BUILD_FAILURE
