/turf/unsimulated/wasteland
	name = "wasteland"
	icon = 'icons/turf/planetary/battlefield.dmi'
	icon_state = "wasteland"
	plane = PLATING_PLANE

/turf/unsimulated/wasteland/New()
	..()
	icon_state = icon_state + "[rand(0,32)]"

/turf/unsimulated/toxic //gives mobs rads
	name = "no man's land"
	desc = "The toxic remnants of an irradiated battlefield."
	icon = 'icons/turf/planetary/wasteplanet.dmi'
	icon_state = "wasteplanet"
	plane = PLATING_PLANE

/turf/unsimulated/toxic/New()
	..()
	icon_state = icon_state + "[rand(0,12)]"
	set_light(2, 1, "#00ff00")
