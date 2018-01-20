/*
	Adjacency proc for determining touch range

	This is mostly to determine if a user can enter a square for the purposes of touching something.
	Examples include reaching a square diagonally or reaching something on the other side of a glass window.

	This is calculated by looking for border items, or in the case of clicking diagonally from yourself, dense items.
	This proc will NOT notice if you are trying to attack a window on the other side of a dense object in its turf.  There is a window helper for that.

	Note that in all cases the neighbor is handled simply; this is usually the user's mob, in which case it is up to you
	to check that the mob is not inside of something
*/
/atom/proc/Adjacent(var/atom/neighbor) // basic inheritance, unused
	return 0

// Not a sane use of the function and (for now) indicative of an error elsewhere
/area/Adjacent(var/atom/neighbor)
	CRASH("Call to /area/Adjacent(), unimplemented proc")


/*
	Adjacency (to turf):
	* If you are in the same turf, always true
	* If you are vertically/horizontally adjacent, ensure there are no border objects
	* If you are diagonally adjacent, ensure you can pass through at least one of the mutually adjacent square.
		* Passing through in this case ignores anything with the throwpass flag, such as tables, racks, and morgue trays.
*/
/turf/Adjacent(var/atom/neighbor, var/atom/target = null)
	var/list/turf/T0list
	if(istype(neighbor, /atom/movable) && isturf(neighbor.loc))
		var/atom/movable/neighborholder = neighbor
		T0list = neighborholder.locs
	else
		T0list = list(get_turf(neighbor))
	for(var/turf/T0 in T0list)

		if(T0 == src) //same turf
			return 1

		if(get_dist(src, T0) > 1) //too far
			continue

		// Non diagonal case
		if(T0.x == x || T0.y == y)
			// Window snowflake code
			if(neighbor.flow_flags & ON_BORDER && neighbor.dir == get_dir(T0, src))
				return 1
			// Check for border blockages
			if(T0.ClickCross(get_dir(T0,src), border_only = 1) && src.ClickCross(get_dir(src,T0), border_only = 1, target_atom = target))
				return 1
			continue

		// Diagonal case
		var/in_dir = get_dir(T0,src) // eg. northwest (1+8) = 9 (00001001)
		var/d1 = in_dir&3		     // eg. north	  (1+8)&3 (0000 0011) = 1 (0000 0001)
		var/d2 = in_dir&12			 // eg. west	  (1+8)&12 (0000 1100) = 8 (0000 1000)

		for(var/d in list(d1,d2))
			if(!T0.ClickCross(d, border_only = 1) && !(neighbor.flow_flags & ON_BORDER && neighbor.dir == d))
				continue // could not leave T0 in that direction

			var/turf/T1 = get_step(T0,d)
			if(!T1 || T1.density || !T1.ClickCross(get_dir(T1,T0) | get_dir(T1,src), border_only = 0)) //let's check both directions at once
				continue // couldn't enter or couldn't leave T1
			if(!src.ClickCross(get_dir(src,T1), border_only = 1, target_atom = target))
				continue // could not enter src

			return 1 // we don't care about our own density
	return 0

/*
	Adjacency (to anything else):
	* Must be on a turf
	* In the case of a multiple-tile object, all valid locations are checked for adjacency.
*/
/atom/movable/Adjacent(var/atom/neighbor)
	if(neighbor == loc)
		return 1
	if(!isturf(loc))
		return 0
	if(locs.len > 1)
		for(var/turf/T in locs)
			if(T.Adjacent(neighbor, src))
				return 1
	else
		var/turf/T = loc
		if(T.Adjacent(neighbor, src))
			return 1
	return 0

// This is necessary for storage items not on your person.
/obj/item/Adjacent(var/atom/neighbor, var/recurse = 1)
	if(neighbor == loc)
		return 1
	if(istype(loc,/obj/item))
		if(recurse > 0)
			return loc.Adjacent(neighbor,recurse - 1)
		return 0
	return ..()
/*
	Special case: This allows you to reach a door when it is visally on top of,
	but technically behind, a fire door

	You could try to rewrite this to be faster, but I'm not sure anything would be.
	This can be safely removed if border firedoors are ever moved to be on top of doors
	so they can be interacted with without opening the door.
*/
/obj/machinery/door/Adjacent(var/atom/neighbor)
	var/list/disable_throwpass = list()

	for(var/obj/machinery/door/D in (loc.contents - src))
		if(D.flow_flags & ON_BORDER)
			D.throwpass = 1
			disable_throwpass += D
	.=..()
	for(var/obj/machinery/door/D in disable_throwpass)
		D.throwpass = 0
	return

/*
	This checks if you there is uninterrupted airspace between that turf and this one.
	This is defined as any dense ON_BORDER object, or any dense object without throwpass.
	The border_only flag allows you to not objects (for source and destination squares)
*/
/turf/proc/ClickCross(var/target_dir, var/border_only, var/atom/target_atom = null)
	for(var/obj/O in src)
		if(O.flow_flags&IMPASSABLE)
			return 0
		if( !O.density || O == target_atom || O.throwpass)
			continue // throwpass is used for anything you can click through

		if( O.flow_flags&ON_BORDER) // windows have throwpass but are on border, check them first
			if( O.dir & target_dir || O.dir&(O.dir-1) ) // full tile windows are just diagonals mechanically
				return 0

		else if( !border_only ) // dense, not on border, cannot pass over
			return 0
	return 1
/*
	Aside: throwpass does not do what I thought it did originally, and is only used for checking whether or not
	a thrown object should stop after already successfully entering a square.  Currently the throw code involved
	only seems to affect hitting mobs, because the checks performed against objects are already performed when
	entering or leaving the square.  Since throwpass isn't used on mobs, but only on objects, it is effectively
	useless.  Throwpass may later need to be removed and replaced with a passcheck (bitfield on movable atom passflags).

	Since I don't want to complicate the click code rework by messing with unrelated systems it won't be changed here.
*/

/**
	/vg/: Hack for full windows on top of panes.
**/
/obj/structure/window/full/Adjacent(var/atom/neighbor)
	for(var/obj/structure/window/W in loc)
		if(W)
			W.throwpass=1
	.=..()
	for(var/obj/structure/window/W in loc)
		if(W)
			W.throwpass=0
	return .