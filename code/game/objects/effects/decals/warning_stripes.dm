/obj/effect/decal/warning_stripes
	icon = 'icons/effects/warning_stripes.dmi'
	layer = 2.1

/obj/effect/decal/warning_stripes/New()
	. = ..()
	var/turf/T=get_turf(src)
	var/image/I=image(icon, icon_state = icon_state, dir = dir)
	I.color=color
	T.AddDecal(I)
	qdel(src)

/obj/effect/decal/warning_stripes/oldstyle
	icon = 'icons/effects/warning_stripes_old.dmi'

/obj/effect/decal/warning_stripes/pathmarkers
	name = "Path marker"
	desc = "Marks an important path."

	icon_state="pathmarker"

/obj/effect/decal/warning_stripes/pathmarkers/yellow
	color = "#ffff00"

// Pastels
/obj/effect/decal/warning_stripes/pathmarkers/red
	color = "#af6365"

/obj/effect/decal/warning_stripes/pathmarkers/blue
	color = "#719eb6"

//For people who lose themselves on defficiency
//Making it a decal makes it fuse with the plating and disappear under the pipes, I need a better solution but this will do for now
/obj/effect/nmpi
	name = "NMPI"
	desc = "If your sense of direction is under average, just follow the Nanotrasen-approved Maintenance Path Indicator to never get lost again. Nanotrasen declines all responsibility if you decide to stray off the path indicated by the Nanotrasen-approved Maintenance Path Indicator."

	icon = 'icons/effects/warning_stripes.dmi'
	icon_state = "maintguide"
	layer = 2.45

// MAPPING STATES.

/obj/effect/decal/warning_stripes/mapping/warning
	icon_state = "warning"

/obj/effect/decal/warning_stripes/mapping/all
	icon_state = "all"

/obj/effect/decal/warning_stripes/mapping/corner
	icon_state = "warning_corner"

/obj/effect/decal/warning_stripes/mapping/unloading
	icon_state = "unloading"

/obj/effect/decal/warning_stripes/mapping/bot
	icon_state = "bot"

/obj/effect/decal/warning_stripes/mapping/loading_area
	icon_state = "loading_area"

/obj/effect/decal/warning_stripes/mapping/no
	icon_state = "no"

/obj/effect/decal/warning_stripes/mapping/gas/oxygen
	icon_state = "oxygen"

/obj/effect/decal/warning_stripes/mapping/gas/nitrogen
	icon_state = "nitrogen"

/obj/effect/decal/warning_stripes/mapping/gas/carbon_dioxide
	icon_state = "carbon_dioxide"

/obj/effect/decal/warning_stripes/mapping/gas/nitrous_oxide
	icon_state = "nitrous_oxide"

/obj/effect/decal/warning_stripes/mapping/gas/air
	icon_state = "air"

/obj/effect/decal/warning_stripes/mapping/gas/plasma
	icon_state = "plasma"

/obj/effect/decal/warning_stripes/mapping/zoo
	icon_state = "zoo"

/obj/effect/decal/warning_stripes/mapping/numbers/n1
	icon_state = "1"

/obj/effect/decal/warning_stripes/mapping/numbers/n2
	icon_state = "2"

/obj/effect/decal/warning_stripes/mapping/numbers/n3
	icon_state = "3"

/obj/effect/decal/warning_stripes/mapping/numbers/n4
	icon_state = "4"

/obj/effect/decal/warning_stripes/mapping/numbers/n5
	icon_state = "5"

/obj/effect/decal/warning_stripes/mapping/numbers/n6
	icon_state = "6"

/obj/effect/decal/warning_stripes/mapping/numbers/n7
	icon_state = "7"

/obj/effect/decal/warning_stripes/mapping/numbers/n8
	icon_state = "8"

/obj/effect/decal/warning_stripes/mapping/numbers/n9
	icon_state = "9"
