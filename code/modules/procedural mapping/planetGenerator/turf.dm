///Collection of turfs used only for procgen.
//Border
/turf/unsimulated/border
	name = "border"
	icon = 'icons/turf/space.dmi'
	icon_state = "black"
	plane = ABOVE_PARALLAX_PLANE
	mouse_opacity = 0
	density = 1
	opacity = 1
	blocks_air = 1
	explosion_block = 9999
	turf_flags = NOJAUNT

//Caves
/turf/unsimulated/floor/cave
	name = "cave floor"
	carbon_dioxide = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C
	icon_state = "cavefl_1"
	plane = PLATING_PLANE

/turf/unsimulated/floor/cave/New()
	..()
	icon_state = pick("cavefl_1","cavefl_2","cavefl_3","cavefl_4")

/turf/unsimulated/mineral/cave
	name = "cave wall"
	icon_state = "cave_wall"
	base_icon_state = "cave_wall"
	mined_type = /turf/unsimulated/floor/asteroid/underground

//Desert
/turf/unsimulated/floor/desert
	name = "desert"
	icon_state = "ironsand1"
	plane = TURF_PLANE

	carbon_dioxide = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C

/turf/unsimulated/floor/desert/New()
	..()
	if(prob(30))
		icon_state = "ironsand[rand(1,15)]"

/turf/unsimulated/floor/desert/dry_basin
	name = "dry sea basin"
	icon_state = "asteroid"
	carbon_dioxide = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C

/turf/unsimulated/floor/desert/dry_basin/New()
	..()
	if(prob(20) && icon_state == "asteroid")
		icon_state = "asteroid[rand(0,12)]"

/turf/unsimulated/floor/planetary/desert
	name = "desert"
	icon = 'icons/turf/planetary/desert.dmi'
	icon_state = "desert"
	plane = PLATING_PLANE

/turf/unsimulated/floor/planetary/desert/dry
	name = "dry desert"
	icon_state = "drydesert"

//Snow
/turf/unsimulated/floor/basalt
	name = "basalt"
	icon = 'icons/turf/new_snow.dmi'
	icon_state = "concrete"
	carbon_dioxide = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T0C

/turf/unsimulated/floor/snow/glacier
	name = "glacier"
	carbon_dioxide = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T0C

/turf/unsimulated/floor/snow/glacier/New()
	..()
	new	/obj/glacier(src, icon_update_later = 1)

/turf/unsimulated/floor/lava
	name = "lava"
	icon = 'icons/turf/floors.dmi'
	icon_state = "lava"
	carbon_dioxide = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = MELTPOINT_GLASS

/turf/unsimulated/floor/lava/Entered(atom/movable/A as mob|obj, atom/OldLoc)
	..()
	A.ignite()

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
