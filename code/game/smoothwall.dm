//YOU FAILED ME N3X15 THIS SHIT DOESN'T USE DIRECTIONAL ICON STATES
#define NSEW 15

/atom
	var/canSmoothWith // TYPE PATHS I CAN SMOOTH WITH~~~~~

/**
 * The base smooth_icon proc
 * Functions by finding the number of directions of connections, this establishes the base icon_state of the 5 directional image maps
 * The switch determines what dir to apply so the icon_state is properly oriented
 * 0 walls found, and 4 walls found both are dir-agnostic
 */

/atom/proc/smooth_icon(var/icon_base) //This will be the base behavior for smoothing to keep consistency through directional viewing of smoothing
	. = findSmoothingNeighbors() //Returns the number of objects found and a bitflag of the dirs
	var/list/smoothinfo = .
	switch(smoothinfo[2])
		if(1)
			dir = smoothinfo[1]
		if(2)
			if((smoothinfo[1] == (NORTH | SOUTH)) || (smoothinfo[1] == (EAST | WEST)))
				dir = smoothinfo[1] & (NORTH|EAST) //Convert it into NORTH and EAST only
			else
				dir = smoothinfo[1] //Bent walls are the diagonals
		if(3)
			dir = smoothinfo[1] ^ (NSEW) //This is the simplest way, sprites are oriented so their empty side is facing out
		else
	icon_state = icon_base + "-[smoothinfo[2]]"

/*
 * This proc is critical to the function of the above proc for basic icon smoothing
 * It sends over first the a directional bitmap of the found directions for each object
 * It also sends over the number of found walls in total because its easier than recalculating it in my opinion
 */

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

/*
 * Wrapper procs for determining when an icon is allowed to smooth with another
 * And a place for other wrapper procs where diagonal orientations and alternate icons are possible
 */

/atom/proc/isSmoothableNeighbor(atom/A)
	if(!A)
		return 0
	return isInTypes(A, canSmoothWith)

/turf/simulated/floor/isSmoothableNeighbor(var/turf/simulated/floor/T) //For now, you cant smooth floor tiles with anything but floor tiles
	if(!T || !istype(T))
		return 0
	if(!T.floor_tile || broken || burnt) //Why would you want to anyway, you'll need to replace this with some really carefully done shit
		return 0
	return isInTypes(T.floor_tile, floor_tile.canSmoothWith)

/turf/simulated/wall/isSmoothableNeighbor(atom/A)
	if(!A)
		return 0
	if(isInTypes(A, canSmoothWith))
		// COLON OPERATORS ARE TERRIBLE BUT I HAVE NO CHOICE //YOU HAVE FAILED ME BUT THAT DOESN'T MEAN I CAN FIX IT EITHER
		if(src.mineral == A:mineral)
			return 1
	return 0

/*
 * The base wrappers for icon_smoothing are below, they should call smooth_icon first
 * If they need to deal with replacing icons for special cases that will also be done here thanks to the default return value sent by icon_smooth
 * Currently these should handle:
 * Floor Diagonals
 * Shuttle Diagonal Overlays + Triangle/Rectangular Wall Conversion
 */

//Remember
//SOUTH = 1 = 0001
//NORTH = 2 = 0010
//EAST = 4 = 0100
//WEST = 8 = 1000

/atom/proc/icon_smoothing()
	return

/turf/simulated/wall/vault/icon_smoothing()
	return

/obj/structure/catwalk/icon_smoothing()
	smooth_icon("[base_icon]")

/obj/structure/lattice/icon_smoothing()
	smooth_icon("[base_icon]")

/obj/structure/window/full/icon_smoothing()
	smooth_icon("[base_icon]")

/turf/unsimulated/wall/icon_smoothing()
	smooth_icon("[walltype]")

/turf/simulated/wall/icon_smoothing()
	smooth_icon("[walltype]")

/turf/simulated/shuttle/wall/icon_smoothing() //Diagonal shuttle walls are going to be fun, just watch
	var/list/results = smooth_icon("[base_icon]")

	if(results[2] == 3) //Whelp here is code to add a kink under extremely specific circumstances, what a bitch to code
		. = add_kink(results)
	if(results[2] == 2 && !(dir in cardinal)) //Two connected walls, not a straight connection
		resolve_diagonal(dir)


/turf/simulated/shuttle/wall/proc/add_kink(results)
	var/list/check
	for(var/cardinaldir in cardinal)
		if(dir & cardinaldir) //Check only the other walls, not the empty space
			continue
		var/turf/simulated/shuttle/wall/buddy = get_step(src,cardinaldir)
		if(!istype(buddy))
			continue
		check = buddy.findSmoothingNeighbors()
		if(check[2] == results[2] && check[1] == results[1]) //Find the ones that have 3 also, we are looking for identical neighbors to get kinky with
			for(var/direction in diagonal)
				if(direction & dir)
					continue
				if(direction & cardinaldir)//Check the diagonal between us and our neighbor
					var/turf/simulated/shuttle/wall/T = get_step(src,direction)
					if(istype(T))
						var/list/check2 = T.findSmoothingNeighbors()
						if(check2[2] == 2)//Is it a 2 walled sonuvabitch
							return reorient_tri_corner(cardinaldir, buddy)
				if(direction & reverse_direction(cardinaldir))
					var/turf/simulated/shuttle/wall/T = get_step(buddy, direction)
					if(istype(T))
						var/list/check2 = T.findSmoothingNeighbors()
						if(check2[2] == 2)//Is it a 2 walled sonuvabitch
							return reorient_tri_corner(cardinaldir, buddy)


/turf/simulated/shuttle/wall/proc/reorient_tri_corner(cardinaldir,var/turf/simulated/shuttle/wall/buddy)
	buddy.icon_state = "[base_icon]-2"
	buddy.dir = (NSEW ^ dir) - reverse_direction(cardinaldir)
	buddy.resolve_diagonal(buddy.dir)
	src.icon_state = "[base_icon]-2"
	src.dir = (NSEW ^ dir) - cardinaldir
	src.resolve_diagonal(dir)
	. = cardinaldir

/turf/simulated/shuttle/wall/proc/resolve_diagonal(var/bitmap) //This is black magic, souls were sacrificed to obtain this
	underlays.len = 0
	var/turf/first
	var/turf/second
	for(var/cardinaldir in cardinal)
		if(bitmap & cardinaldir)
			continue
		var/turf/someturf = get_step(src,cardinaldir) //Lets take a look at the other turfs in the cardinal directions
		if(istype(someturf,/turf/space)) //This is an outer shuttle wall conjoining space, give it a space underlay
			underlays += icon('icons/turf/space.dmi',"[rand(1,25)]")
			return
		if(!first)
			first = someturf
		second = someturf
	if("[first.icon_state]" == "[second.icon_state]") //This is an outer shuttle wall conjoining turfs, we are going to smooth its icon with the conjoining turfs
		underlays += icon(first.icon, first.icon_state)
	else
		var/turf/outerdiagonal = get_step(src,bitmap ^ (NSEW)) //Since it didn't match both the two corners it is touching, simply take the diagonal sprite
		underlays += icon(outerdiagonal.icon, outerdiagonal.icon_state) //This has the potential to look really stupid, so I hope the above case caught it
/*	for(var/cardinaldir in cardinal) //One final check...
		if(!bitmap & cardinaldir)
			continue
		var/turf/simulated/shuttle/wall/connections = get_step(src,cardinaldir)
		var/list/results = connections.findSmoothingNeighbors()
		if(results[2] == 2 && !(connections.dir in cardinal)) //Hey if we're connected to other diagonals we're already done
			return
	icon_state += "right" //Really, not a single thing caught us up to this point? Looks like a right angle is more appropriate than diagonal
*/
/turf/simulated/floor/icon_smoothing() //Standardized for the addition of any new floor tile with smoothing
	if(!floor_tile || !floor_tile.smoothed)
		return
	var/base_icon = floor_tile.name
	var/list/results = smooth_icon(base_icon) //Bring us the bitflag from smooth_icon

	if(floor_tile.diagonal_overlays)
		var/list/diags = list()
		for(var/i=1, i < 5, i++)
			if((results[1] & diagonal[i]) == diagonal[i]) //Does the bitflag contain that diagonal
				var/turf/simulated/floor/T = get_step(src,diagonal[i])
				if(istype(T) && !isInTypes(T.floor_tile,floor_tile.canSmoothWith)) //Does that diagonal have an smoothable floor tile
					diags |= i //No? We need a diagonal overlay

		if(curdiag != diags)
			overlays.len = 0
			for(var/a in diags)
				overlays += floor_tile.diagonals["[base_icon]"][a] //Presuming 4 diagonal overlays properly ordered by smallest to largest dir
			curdiag = diags

/atom/proc/relativewall_neighbours(var/at=null)
	if(!at)
		at = get_turf(src)
	if(canSmoothWith)
		for(var/cdir in cardinal)
			var/turf/T = get_step(src,cdir)
			if(isSmoothableNeighbor(T))
				T.icon_smoothing()
			for(var/atom/A in T)
				if(isSmoothableNeighbor(A))
					A.icon_smoothing()

/atom/proc/relativewall_neighbours_ignore(var/ignore)
	if(canSmoothWith)
		for(var/cdir in cardinal)
			if(ignore & cdir)
				continue
			var/turf/T = get_step(src,cdir)
			if(isSmoothableNeighbor(T))
				T.icon_smoothing()
			for(var/atom/A in T)
				if(isSmoothableNeighbor(A))
					A.icon_smoothing()

/turf/simulated/wall/New()
	..()
	if(ticker)
		initialize()
		relativewall_neighbours()

/turf/simulated/wall/initialize()
	icon_smoothing()

/turf/simulated/wall/Destroy()

	var/temploc = src.loc

	if(!del_suppress_resmoothing)
		spawn(10)
			relativewall_neighbours(at=temploc)

	// JESUS WHY //But no really why is this here
	for(var/direction in cardinal)
		for(var/obj/effect/glowshroom/shroom in get_step(src,direction))
			if(!shroom.floor) //shrooms drop to the floor
				shroom.floor = 1
				shroom.icon_state = "glowshroomf"
				shroom.pixel_x = 0
				shroom.pixel_y = 0

	..()

/turf/simulated/shuttle/wall/New()
	..()
	if(ticker)
		. = initialize()
		relativewall_neighbours_ignore(.)

/turf/simulated/shuttle/wall/initialize()
	spawn()
		. = icon_smoothing()

var/list/smoothable_unsims = list(
	"riveted",
	)

/turf/unsimulated/wall/New()
	..()
	if(icon_state in smoothable_unsims && ticker)
		initialize()
		relativewall_neighbours()

/turf/unsimulated/wall/initialize()
	icon_smoothing()

#undef NSEW