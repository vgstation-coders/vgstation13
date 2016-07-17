//This was put here because I don't want to overcomplicate my PR
/obj/effect/decal
	//var/global/list/decals = list()
	plane = PLANE_TURF

/obj/effect/decal/New()
	..()
	decals += src

/obj/effect/decal/Destroy()
	decals -= src
	..()

/obj/effect/decal/point
	name = "arrow"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "arrow"
	layer = 16
	mouse_opacity = 0
	w_type = NOT_RECYCLABLE

//Used for spray that you spray at walls, tables, hydrovats etc
/obj/effect/decal/spraystill
	density = 0
	layer = 50

/obj/effect/decal/snow
	name = "snow"
	density = 0
	layer = 2
	icon = 'icons/turf/snow.dmi'
	w_type = NOT_RECYCLABLE


/obj/effect/decal/snow/clean/edge
	icon_state = "snow_corner"

/obj/effect/decal/snow/sand/edge
	icon_state = "gravsnow_corner"

/obj/effect/decal/snow/clean/surround
	icon_state = "snow_surround"

/obj/effect/decal/snow/sand/surround
	icon_state = "gravsnow_surround"
