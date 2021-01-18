/turf/unsimulated/beach
	name = "Beach"
	icon = 'icons/misc/beach.dmi'

/turf/unsimulated/beach/sand
	name = "Sand"
	icon_state = "sand"

/turf/unsimulated/beach/coastline
	name = "Coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"

/turf/unsimulated/beach/water
	name = "Water"
	icon_state = "water"

/turf/unsimulated/beach/water/New()
	..()
	var/image/water = image("icon"='icons/misc/beach.dmi',"icon_state"="water2","layer"=MOB_LAYER+0.1)
	water.plane = MOB_PLANE
	overlays += water

/turf/unsimulated/beach/water/deep
	name = "deep water"
	density = 1

/turf/unsimulated/beach/shallows
	name = "Water"
	icon_state = "water"
	var/image/water

/turf/unsimulated/beach/shallows/New()
	..()
	water = image("icon"='icons/misc/beach.dmi',"icon_state"="shallow-water","layer"=MOB_LAYER+0.1)
	water.plane = MOB_PLANE

//enter is "trying to enter", we use this instead of Entered() because we don't want to count the entering object
/turf/unsimulated/beach/shallows/Enter(atom/A, atom/OL)
	if(!..())
		return 0
	//the atom was permitted entry, but we also have no previous contents
	if(isliving(A) || ismecha(A) || isbot(A))
		spawn(!istype(OL,/turf/unsimulated/beach/shallows)) //very small delay to reduce clipping on entry; 0 if already in shallows
			A.overlays += water //This thing is likely to move, so it gets to carry an overlay with it for smoother transitions
		return 1
	if(!count_objs())
		//objects however are less likely to move and have a tendency to pile up
		//therefore, they all share one for the turf
		overlays += water
	return 1

//Exited is after it exits, we prefer this because we don't want to count it.
/turf/unsimulated/beach/shallows/Exited(atom/A, atom/newloc)
	. = ..()
	if(isliving(A) || ismecha(A) || isbot(A))
		A.overlays -= water
		return .
	if(!count_objs()) //nothing left, get rid of it
		overlays -= water
	return .

/turf/unsimulated/beach/cultify()
	return

/turf/proc/count_objs()
	var/count = 0
	for(var/atom/A in contents)
		if(isrealobject(A))
			count++
	return count