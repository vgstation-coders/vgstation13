// OKAY I DON'T KNOW WHO THE FUCK ORIGINALLY CODED THIS BUT THEY ARE OFFICIALLY FIRED FOR BEING DRUNK AND STUPID
// FUCK YOU MYSTERY CODERS
// FOR THIS SHIT I'M GOING TO MAKE ALL MY COMMENTS IN CAPS

/atom
	var/canSmoothWith // TYPE PATHS I CAN SMOOTH WITH~~~~~

// MOVED INTO UTILITY FUNCTION FOR LESS DUPLICATED CODE.
/atom/proc/findSmoothingNeighbors()
	// THIS IS A BITMAP BECAUSE NORTH/SOUTH/ETC ARE ALL BITFLAGS BECAUSE BYOND IS DUMB AND
	// DOESN'T FUCKING MAKE SENSE, BUT IT WORKS TO OUR ADVANTAGE
	var/junction = 0
	for(var/cdir in cardinal)
		var/turf/T = get_step(src,cdir)
		if(isSmoothableNeighbor(T))
			junction |= cdir
			continue // NO NEED FOR FURTHER SEARCHING IN THIS TILE
		for(var/atom/A in T)
			if(isSmoothableNeighbor(A))
				junction |= cdir
				break // NO NEED FOR FURTHER SEARCHING IN THIS TILE

	return junction

/atom/proc/isSmoothableNeighbor(atom/A)
	if(!A)
		WARNING("[__FILE__]L[__LINE__]: atom/isSmoothableNeighbor given bad atom")
		return 0
	return isInTypes(A, canSmoothWith)

/turf/simulated/wall/isSmoothableNeighbor(atom/A)
	if(!A)
		WARNING("[__FILE__]L[__LINE__]: turf/isSmoothableNeighbor given bad atom")
		return 0
	if(isInTypes(A, canSmoothWith))
		// COLON OPERATORS ARE TERRIBLE BUT I HAVE NO CHOICE
		if(src.mineral == A:mineral)
			return 1

	return 0

/**
 * WALL SMOOTHING SHIT
 *
 * IN /ATOM BECAUSE /TURFS ARE /ATOMS AND SO ARE /OBJ/STRUCTURE/FALSEWALLS
 * THIS IS STUPID BUT IS FAIRLY ELEGANT FOR BYOND
 *
 * HOWEVER, INSTEAD OF MAKING ONE BIG GODDAMN MONOLITHIC PROC LIKE A FUCKING
 * SHITTY FUNCTIONAL PROGRAMMER, WE WILL BE COOL AND MODERN AND USE INHERITANCE.
 */
/atom/proc/relativewall()
	return // DOES JACK SHIT BY DEFAULT. OLD BEHAVIOR WAS TO SPAM LOOPS ANYWAY.

/*
 * SEE?  NOW WE ONLY HAVE TO PROGRAM THIS SHIT INTO WHAT WE WANT TO SMOOTH
 * INSTEAD OF BEING DUMB AND HAVING A BIG FUCKING IFTREE WITH TYPECHECKS
 * MY GOD, WE COULD EVEN MOVE THE CODE TO BE WITH THE REST OF THE WALL'S CODE!
 * HOW FUCKING INNOVATIVE.  ISN'T INHERITANCE NICE?
 *
 * WE COULD STANDARDIZE THIS BUT EVERYONE'S A FUCKING SNOWFLAKE
 */
/turf/simulated/wall/relativewall()
	var/junction=findSmoothingNeighbors()
	icon_state = "[walltype][junction]" // WHY ISN'T THIS IN UPDATE_ICON OR SIMILAR

// AND NOW WE HAVE TO YELL AT THE NEIGHBORS FOR BEING LOUD AND NOT PAINTING WITH HOA-APPROVED COLORS
/atom/proc/relativewall_neighbours(var/at=null)
	if(!at)
		at = get_turf(src)
	// OPTIMIZE BY NOT CHECKING FOR NEIGHBORS IF WE DON'T FUCKING SMOOTH
	if(canSmoothWith)
		for(var/cdir in cardinal)
			var/turf/T = get_step(src,cdir)
			if(isSmoothableNeighbor(T) && T.canSmoothWith)
				T.relativewall()
			for(var/atom/A in T)
				if(isSmoothableNeighbor(A))
					A.relativewall()

/atom/proc/update_near_walls(var/at)
	if(!at)
		at = get_turf(src)

	for(var/cdir in cardinal)
		var/turf/T = get_step(src,cdir)
		if(istype(T, /turf))
			T.relativewall()
			for(var/atom/A in T)
				A.relativewall()

/turf/simulated/wall/New()
	..()

	// SMOOTH US WITH OUR NEIGHBORS
	relativewall()

	// WE NEED TO TELL ALL OUR FRIENDS ABOUT THIS SCANDAL
	relativewall_neighbours()

/turf/simulated/wall/Destroy()
	var/temploc = src.loc

	if(!del_suppress_resmoothing)
		spawn(10)
			relativewall_neighbours(at=temploc)

	// JESUS WHY
	for(var/direction in cardinal)
		for(var/obj/effect/glowshroom/shroom in get_step(src,direction))
			if(!shroom.floor) //shrooms drop to the floor
				shroom.floor = 1
				shroom.icon_state = "glowshroomf"
				shroom.pixel_x = 0
				shroom.pixel_y = 0

	..()

// DE-HACK
/turf/simulated/wall/vault/relativewall()
	return

var/list/smoothable_unsims = list(
	"riveted",
	)

/turf/unsimulated/wall/New()
	..()
	if(icon_state in smoothable_unsims)
		relativewall()
		relativewall_neighbours()

/turf/unsimulated/wall/relativewall()
	var/junction=findSmoothingNeighbors()
	icon_state = "[walltype][junction]"
