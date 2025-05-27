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
	if(istype(A, /mob))
		var/mob/M = A
		M.dust(FALSE)
