// OKAY I DON'T KNOW WHO THE FUCK ORIGINALLY CODED THIS BUT THEY ARE OFFICIALLY FIRED FOR BEING DRUNK AND STUPID
// FUCK YOU MYSTERY CODERS
// FOR THIS SHIT I'M GOING TO MAKE ALL MY COMMENTS IN CAPS

/atom
	var/junction = 0 // THIS USED TO BE DEFINED TO THE TURF LEVEL BUT IT'S HERE NOW IN CASE ANYTHING ELSE (LIKE STRUCTURES) NEED IT, ALSO COMMENT IN CAPS IN THEME WITH THIS FILE
	var/bordersmooth_override = 0 // SOME ON_BORDER ITEMS PREFER FULL TILE SMOOTHING OKAY?

/atom/proc/canSmoothWith() // TYPE PATHS I CAN SMOOTH WITH~~~~~ (HAS TO BE THIS FUNCTION OR ELSE OBJECT INIT IS WAY WAY SLOWER)

/atom/proc/cannotSmoothWith() // TYPE PATHS I CANNOT SMOOTH WITH~~~~~ (HAS TO BE THIS FUNCTION OR ELSE OBJECT INIT IS WAY WAY SLOWER)

// MOVED INTO UTILITY FUNCTION FOR LESS DUPLICATED CODE.
/atom/proc/findSmoothingNeighbors()
	// THIS IS A BITMAP BECAUSE NORTH/SOUTH/ETC ARE ALL BITFLAGS BECAUSE BYOND IS DUMB AND
	// DOESN'T FUCKING MAKE SENSE, BUT IT WORKS TO OUR ADVANTAGE
	. = 0
	for(var/cdir in cardinal)
		if((flow_flags & ON_BORDER) && !bordersmooth_override && (dir == cdir || opposite_dirs[dir] == cdir))
			continue
		var/turf/T = get_step(src,cdir)
		if(isSmoothableNeighbor(T))
			. |= cdir
			continue // NO NEED FOR FURTHER SEARCHING IN THIS TILE
		for(var/atom/A in T)
			if(isSmoothableNeighbor(A))
				. |= cdir
				break // NO NEED FOR FURTHER SEARCHING IN THIS TILE

// OTHER FUNCTION SOME BORDER ITEMS MIGHT LIKE TO USE
/atom/proc/findSmoothingOnTurf()
	. = 0
	for(var/cdir in cardinal)
		if((flow_flags & ON_BORDER) && !bordersmooth_override && (dir == cdir || opposite_dirs[dir] == cdir))
			continue
		var/turf/T = get_turf(src)
		if(isSmoothableNeighbor(T,0) && T.dir == cdir)
			. |= cdir
		for(var/atom/A in T)
			if(isSmoothableNeighbor(A,0) && A.dir == cdir)
				. |= cdir

/atom/proc/isSmoothableNeighbor(atom/A, bordercheck = TRUE)
	if(!A)
		return 0
	if(bordercheck && (flow_flags & ON_BORDER) && (A.flow_flags & ON_BORDER) && !bordersmooth_override && A.dir != dir)
		return 0
	return is_type_in_list(A, canSmoothWith()) && !(is_type_in_list(A, cannotSmoothWith()))

/turf/simulated/wall/isSmoothableNeighbor(atom/A)
	if(!A)
		return 0
	if(is_type_in_list(A, canSmoothWith()) && !(is_type_in_list(A, cannotSmoothWith())))
		if(istype(A, /turf/simulated/wall))
			var/turf/simulated/wall/W = A
			if(src.mineral == W.mineral)
				return 1
		else
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
	if(canSmoothWith())
		junction = findSmoothingNeighbors()
	else
		junction = 0
	return junction // PREVIOUSLY DID NOTHING, NOW INHERITS THIS FOR COMMON BEHAVIOUR.

/atom/New()
	. = ..()
	if(ticker && ticker.current_state >= GAME_STATE_PLAYING && canSmoothWith())
		relativewall()
		relativewall_neighbours()

/*
 * SEE?  NOW WE ONLY HAVE TO PROGRAM THIS SHIT INTO WHAT WE WANT TO SMOOTH
 * INSTEAD OF BEING DUMB AND HAVING A BIG FUCKING IFTREE WITH TYPECHECKS
 * MY GOD, WE COULD EVEN MOVE THE CODE TO BE WITH THE REST OF THE WALL'S CODE!
 * HOW FUCKING INNOVATIVE.  ISN'T INHERITANCE NICE?
 *
 * WE COULD STANDARDIZE THIS BUT EVERYONE'S A FUCKING SNOWFLAKE
 */
/turf/simulated/wall/relativewall()
	icon_state = "[walltype][..()]" // WHY ISN'T THIS IN UPDATE_ICON OR SIMILAR

// AND NOW WE HAVE TO YELL AT THE NEIGHBORS FOR BEING LOUD AND NOT PAINTING WITH HOA-APPROVED COLORS
/atom/proc/relativewall_neighbours(var/at=null)
	if(!at)
		at = get_turf(src)
	// OPTIMIZE BY NOT CHECKING FOR NEIGHBORS IF WE DON'T FUCKING SMOOTH
	if(canSmoothWith())
		if((flow_flags & ON_BORDER) && !bordersmooth_override)
			var/turf/OT = get_turf(src)
			if(isSmoothableNeighbor(OT,0) && OT.canSmoothWith())
				OT.relativewall()
			for(var/atom/A in OT)
				if(isSmoothableNeighbor(A,0))
					A.relativewall()
		for(var/cdir in cardinal)
			var/turf/T = get_step(src,cdir)
			if(isSmoothableNeighbor(T) && T.canSmoothWith())
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

/turf/simulated/wall/Destroy()
	remove_rot()
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
	"alloy",
	"rock_rf",
	)

/turf/unsimulated/wall/initialize()
	if(icon_state in smoothable_unsims)
		relativewall()

/turf/unsimulated/wall/relativewall()
	if(icon_state in smoothable_unsims)
		icon_state = "[walltype][..()]"
