
//**************************************************************
//
// Map Objects
// ---------------
// Slap these on the map and they do their shit
//
//***************************************************************

/obj/abstract/map
	alpha = 255
	invisibility = 101
	mouse_opacity = 0

/obj/abstract/map/New()

	..()

	perform_spawn()
	qdel(src)

/obj/abstract/map/Destroy()
	return

//Spawn proc that can be modified, so New() can inherit properly
/obj/abstract/map/proc/perform_spawn()
	return
