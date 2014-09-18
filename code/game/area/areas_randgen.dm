
//**************************************************************
//
// Random Generation Areas
// --------------------------
// These are mainly for marking off places on the map.
// Paths are strange because DM hates number-only paths.
//
//**************************************************************

/area/randgen
	icon = 'icons/obj/map/randgenareas.dmi'
	always_unpowered = 1
	lighting_use_dynamic = 0
	power_light = 0
	power_equip = 0
	power_environ = 0
	luminosity = 0
	layer = 10
	invisibility = 101

/area/randgen/New()
	src.related = list(src)
	src.master = src
	src.uid = ++global_uid
	return

// Subtypes ////////////////////////////////////////////////////	
	
/area/randgen/space/space1
	icon_state = "space_1"

/area/randgen/space/space2
	icon_state = "space_2"

/area/randgen/space/space3
	icon_state = "space_3"

/area/randgen/space/space4
	icon_state = "space_4"

/area/randgen/space/space5
	icon_state = "space_5"

/area/randgen/space/space6
	icon_state = "space_6"

/area/randgen/space/space7
	icon_state = "space_7"

/area/randgen/space/space8
	icon_state = "space_8"

/area/randgen/space/space9
	icon_state = "space_9"
