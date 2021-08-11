/turf/proc/CanZPass(atom/A, direction)
	if(z == A.z) //moving FROM this turf
		return direction == UP //can't go below
	else
		if(direction == UP) //on a turf below, trying to enter
			return 0
		if(direction == DOWN) //on a turf above, trying to enter
			return !density

/turf/simulated/open/CanZPass(atom, direction)
	return 1

/turf/space/CanZPass(atom, direction)
	return 1

//
// Open Space - "empty" turf that lets stuff fall thru it to the layer below
//

/turf/simulated/open
	name = "open space"
	icon = 'icons/turf/space.dmi'
	icon_state = ""
	desc = "\..."
	density = 0
	plane = OPENSPACE_PLANE_START
	//pathweight = 100000 //For lack of pathweights, mobdropping meta inc
	dynamic_lighting = 0 // Someday lets do proper lighting z-transfer.  Until then we are leaving this off so it looks nicer.

	var/turf/below

/turf/simulated/open/post_change()
	..()
	update()

/turf/simulated/open/initialize()
	..()
	ASSERT(HasBelow(z))
	update()

/turf/simulated/open/Entered(var/atom/movable/mover)
	..()
	mover.fall()

// Called when thrown object lands on this turf.
/turf/simulated/open/hitby(var/atom/movable/AM, var/speed)
	. = ..()
	AM.fall()

/turf/simulated/open/proc/update()
	plane = OPENSPACE_PLANE + src.z
	below = GetBelow(src)
	//turf_changed_event.register(below, src, /turf/simulated/open/update_icon)
	universe.OnTurfChange(below) //I think this is equivalent??
	levelupdate()
	for(var/atom/movable/A in src)
		A.fall()
	update_icon()

// override to make sure nothing is hidden
/turf/simulated/open/levelupdate()
	for(var/obj/O in src)
		O.hide(0)

/turf/simulated/open/examine(mob/user, distance, infix, suffix)
	if(..(user, 2))
		var/depth = 1
		for(var/T = GetBelow(src); isopenspace(T); T = GetBelow(T))
			depth += 1
		to_chat(user, "It is about [depth] levels deep.")

/**
* Update icon and overlays of open space to be that of the turf below, plus any visible objects on that turf.
*/
/turf/simulated/open/update_icon()
	vis_contents.Cut()
	var/turf/bottom
	for(bottom = GetBelow(src); isopenspace(bottom); bottom = GetBelow(bottom))

	if(!bottom || bottom == src)
		return
	vis_contents += bottom

//This segment of code copied directly from space.dm

/turf/simulated/open/canBuildCatwalk()
	if(locate(/obj/structure/catwalk) in contents)
		return BUILD_FAILURE
	return locate(/obj/structure/lattice) in contents


/turf/simulated/open/canBuildLattice(var/material)
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(locate(/obj/structure/catwalk) in contents)
		return BUILD_FAILURE
	else if(!(locate(/obj/structure/lattice) in contents) && !(istype(material,/obj/item/stack/sheet/wood)))
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/simulated/open/canBuildPlating(var/material)
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if((locate(/obj/structure/lattice) in contents) && !(istype(material,/obj/item/stack/tile/wood)))
		return 1
	return BUILD_FAILURE

// This previously contained handling lattices, catwalks, and platings, but we do that differently here
/turf/simulated/open/attackby(obj/item/C as obj, mob/user as mob)
	//To lay cable
	if(istype(C, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = C
		coil.turf_place(src, user)
	return

//Most things use is_plating to test if there is a cover tile on top (like regular floors)
/turf/simulated/open/is_plating()
	return TRUE

/turf/simulated/open/is_space()
	var/turf/below = GetBelow(src)
	return !below || below.is_space()
