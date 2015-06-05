// OKAY I DON'T KNOW WHO THE FUCK ORIGINALLY CODED THIS BUT THEY ARE OFFICIALLY FIRED FOR BEING DRUNK AND STUPID
// FUCK YOU MYSTERY CODERS
// FOR THIS SHIT I'M GOING TO MAKE ALL MY COMMENTS IN CAPS

/atom
	var/canSmoothWith // TYPE PATHS I CAN SMOOTH WITH~~~~~

// MOVED INTO UTILITY FUNCTION FOR LESS DUPLICATED CODE.
/atom/proc/findSmoothingNeighbors()
	var/junction = 0
	var/dirs = 0
	for(var/cdir in cardinal)
		var/turf/T = get_step(src,cdir)
		if(isSmoothableNeighbor(T))
			junction |= cdir
			dirs++
			continue // NO NEED FOR FURTHER SEARCHING IN THIS TILE
		for(var/atom/A in T)
			if(isSmoothableNeighbor(A))
				junction |= cdir
				dirs++
				break // NO NEED FOR FURTHER SEARCHING IN THIS TILE
	var/list/L = list(junction,dirs)
	return L

/atom/proc/isSmoothableNeighbor(atom/A)
	if(!A)
		WARNING("[__FILE__]L[__LINE__]: atom/isSmoothableNeighbor given bad atom")
		return 0
	return isInTypes(A, canSmoothWith)

/turf/simulated/floor/isSmoothableNeighbor(var/turf/simulated/floor/T) //For now, you cant smooth floor tiles with anything but floor tiles
	if(!T)
		WARNING("[__FILE__]L[__LINE__]: atom/isSmoothableNeighbor given bad atom")
		return 0
	if(!istype(T)) //Why would you want to anyway, you'll need to replace this with some really careful shit
		return 0
	return isInTypes(T.floor_tile, floor_tile.canSmoothWith)

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
 */
/atom/proc/smooth_icon(var/icon_base) //This will be the base behavior for smoothing to keep consistency through directional viewing of smoothing
	var/list/smoothinfo = findSmoothingNeighbors() //Returns the number of objects found and a bitflag of the dirs
	. = smoothinfo[1]
	switch(smoothinfo[2])
		if(0)
			dir = 1
		if(1)
			dir = .
		if(2)
			if((. == (NORTH | SOUTH)) || (. == (EAST | WEST)))
				dir = . & (NORTH|EAST) //Convert it into NORTH and EAST only
			else
				dir = . //Bent walls are the diagonals
		if(3)
			dir = . ^ (NORTH|SOUTH|EAST|WEST) //This is the simplest way, sprites are oriented so their empty side is facing out
		if(4)
			dir = 1
	icon_state = icon_base + "-[smoothinfo[2]]"

/*
 * SEE?  NOW WE ONLY HAVE TO PROGRAM THIS SHIT INTO WHAT WE WANT TO SMOOTH
 * INSTEAD OF BEING DUMB AND HAVING A BIG FUCKING IFTREE WITH TYPECHECKS
 * MY GOD, WE COULD EVEN MOVE THE CODE TO BE WITH THE REST OF THE WALL'S CODE!
 * HOW FUCKING INNOVATIVE.  ISN'T INHERITANCE NICE?
 *
 * WE COULD STANDARDIZE THIS BUT EVERYONE'S A FUCKING SNOWFLAKE
 */

/atom/proc/icon_smoothing()
	return

/turf/simulated/wall/icon_smoothing()
	smooth_icon("[walltype]")

turf/simulated/floor/icon_smoothing() //Standardized for the addition of any new floor tile with smoothing
	if(!floor_tile || !floor_tile.smoothed)
		return
	var/base_icon = floor_tile.name
	. = smooth_icon(base_icon) //Bring us the bitflag from smooth_icon

	if(floor_tile.diagonal_overlays)
		var/list/diags = list()
		for(var/i=1, i < 5, i++)
			if(. & diagonal[i]) //Does the bitflag contain that diagonal
				var/turf/simulated/floor/T = get_step(src,diagonal[i])
				if(istype(T) && !isInTypes(floor_tile.canSmoothWith,T.floor_tile) //Does that diagonal have an smoothable floor tile
					diags |= i //No? We need a diagonal overlay

		if(curdiag != diags)
			overlays.len = 0
			for(var/a in diags)
				overlays += floor_tile.diagonals["[base_icon]"][a] //Presuming 4 diagonal overlays properly ordered by smallest to largest dir
			curdiag = diags

// AND NOW WE HAVE TO YELL AT THE NEIGHBORS FOR BEING LOUD AND NOT PAINTING WITH HOA-APPROVED COLORS
/atom/proc/relativewall_neighbours(var/at=null)
	if(!at)
		at = get_turf(src)
	// OPTIMIZE BY NOT CHECKING FOR NEIGHBORS IF WE DON'T FUCKING SMOOTH
	if(canSmoothWith)
		for(var/cdir in cardinal)
			var/turf/T = get_step(src,cdir)
			if(isSmoothableNeighbor(T))
				T.icon_smoothing()
			for(var/atom/A in T)
				if(isSmoothableNeighbor(A))
					A.icon_smoothing()

/turf/simulated/wall/New()
	..()

	// SMOOTH US WITH OUR NEIGHBORS
	icon_smoothing()

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
/turf/simulated/wall/vault/icon_smoothing()
	return

var/list/smoothable_unsims = list(
	"riveted",
	)

/turf/unsimulated/wall/New()
	..()
	if(icon_state in smoothable_unsims)
		icon_smoothing()
		relativewall_neighbours()

/turf/unsimulated/wall/icon_smoothing()
	var/junction=findSmoothingNeighbors()
	icon_state = "[walltype][junction]"
