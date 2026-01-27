
// Props are mapping objects that don't have any interaction besides decoration.
/obj/prop/
	name = ""
	desc = ""
	anchored = TRUE
	density = FALSE
	icon = 'icons/obj/props.dmi'

// Dense prop subtype.
/obj/prop/dense
	density = TRUE

//'Big' props are props which have... big sprites. They become transparent when you are behind them.

/obj/prop/big/New()
	..()
	add_component(/datum/component/see_behind, 2)

/obj/prop/shoalwindow
	name = "window"
	desc = "There's a faint light coming through it."
	icon_state = "shoalwindow"

/obj/prop/coolerfan
	name = "cooling fan"
	icon_state = "cooler"

/obj/prop/monitor
	name = "monitor"
	icon_state = "monitor"


/obj/prop/panel
	name = "panel"
	icon_state = "panel"


/obj/prop/panelwires
	name = "panel"
	icon_state = "panel-broken-wires"


/obj/prop/panelbroken
	name = "panel"
	icon_state = "panel-broken"


/obj/prop/carpet
	name = "carpet"
	icon_state = "carpetsmall"


/obj/prop/carpetbig
	name = "big carpet"
	icon = 'icons/obj/props_64x64.dmi'
	icon_state = "carpetbig"


/obj/prop/loadingdecal
	name = "loading"
	icon = 'icons/obj/props_64x64.dmi'
	icon_state = "loading"

/obj/prop/carpetlong
	name = "long carpet"
	icon = 'icons/obj/props_64x64.dmi'
	icon_state = "carpetlong"

/obj/prop/papers
	name = "papers"
	icon = 'icons/obj/props.dmi'
	icon_state = "papers"
	mouse_opacity = 0

/obj/prop/floorpanel
	name = "floorpanel"
	icon = 'icons/obj/props_64x64.dmi'
	icon_state = "floorpanel"


/obj/prop/metalwear1
	name = "wear"
	icon = 'icons/obj/props_64x64.dmi'
	icon_state = "metalwear1"


/obj/prop/metalwear2
	name = "wear"
	icon = 'icons/obj/props_64x64.dmi'
	icon_state = "metalwear2"

/obj/prop/metalwear3
	name = "wear"
	icon = 'icons/obj/props_64x64.dmi'
	icon_state = "metalwear3"

/obj/prop/metalwear4
	name = "wear"
	icon = 'icons/obj/props_64x64.dmi'
	icon_state = "metalwear4"

/obj/prop/metalwear5
	name = "wear"
	icon = 'icons/obj/props_64x64.dmi'
	icon_state = "metalwear5"





/obj/prop/shoalwindow/New()
	..()
	if(dir & EAST || dir & WEST)
		pixel_y = rand(-8, 8)
	else
		pixel_x = rand(-8, 8)
	update_moody_light(moody_icon = 'icons/lighting/moody_lights.dmi', moody_state = icon_state)


/obj/prop/big/hanginglight
	name = "hanging light"
	icon = 'icons/obj/props_96x96.dmi'
	icon_state = "hanginglight"
	plane = ABOVE_HUMAN_PLANE
	layer = LIGHT_FIXTURE_LAYER
	pixel_x = -WORLD_ICON_SIZE
	pixel_y = WORLD_ICON_SIZE*2
	density = FALSE

	var/set_range = 2
	var/set_power = 1
	var/set_color = "#e9ef8d"

/obj/prop/big/hanginglight/New()
	..()
	set_light(set_range, set_power, set_color)
	update_moody_light(moody_icon = 'icons/lighting/moody_lights_96x96.dmi', moody_state = "hanginglight_32", offY = -47, moody_color = "#e8ebca")


/obj/prop/fan
	name = "fan array"
	icon_state = "fan"

/obj/prop/fan/New()
	..()
	if(prob(90))
		add_particles(PS_STEAM)
		var/obj/abstract/particles_holder/steam_holder = particle_systems[PS_STEAM]
		steam_holder.particles.spawning = rand(5,15)/100
		adjust_particles(PVAR_PIXEL_Y, 10, PS_STEAM)
	else
		icon_state = "fan_off"

/obj/prop/ladder/
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"

/obj/prop/ladder/up
	icon_state = "ladder10"

/obj/prop/ladder/down
	icon_state ="ladder01"

/obj/prop/latticemess
	icon_state = "pcat_base"
	icon = 'icons/turf/catwalks.dmi'
	fake_z_exclude = TRUE
	plane = ABOVE_PLATING_PLANE
	layer = CATWALK_LAYER
	density = FALSE

/turf/simulated/wall/shuttle/skipjack
	name = "neogypsum wall"
	desc = "Ah, neogypsum. Just as flakey as the Earth stuff. How does it stay intact?"
	icon = 'icons/turf/voxprobe.dmi'
	icon_state = "sjwall0"
	walltype = "sjwall"

/turf/simulated/wall/shuttle/skipjack/canSmoothWith()
	return list(/turf/simulated/wall/shuttle)

/obj/structure/window/full/reinforced/plasma/vox/skipjack
	icon_state = "sjwindow"

/obj/structure/shuttle/diag_wall/smooth/skipjack
	icon = 'icons/turf/voxprobe.dmi'
	icon_state = "sjcorner"

//////

/turf/unsimulated/floor/vox
	name = "vox floor"
	oxygen=0
	nitrogen = MOLES_O2STANDARD+MOLES_N2STANDARD

/turf/unsimulated/floor/vox/plating
	plane = PLATING_PLANE

/turf/unsimulated/floor/vox/plating/alt
	name = "plating"
	icon_state = "voxplating"

/turf/unsimulated/floor/vox/carpet
	icon_state = "carpet"

/turf/unsimulated/floor/vox/carpet/is_carpet_floor()
	return TRUE

/turf/unsimulated/floor/vox/carpet/New()
	..()
	spawn(4)
		if(src)
			update_icon()
			for(var/direction in alldirs)
				var/turf/unsimulated/floor/FF = get_step(src,direction)
				if(istype(FF))
					FF.update_icon()

// Copypaste from /turf/simulated/floor/update_icon()
/turf/unsimulated/floor/vox/carpet/update_icon()
	var/connectdir = 0
	for(var/direction in cardinal)
		if(istype(get_step(src,direction),/turf/simulated/floor))
			var/turf/simulated/floor/FF = get_step(src,direction)
			if(FF.is_carpet_floor())
				connectdir |= direction

	//Check the diagonal connections for corners, where you have, for example, connections both north and east. In this case it checks for a north-east connection to determine whether to add a corner marker or not.
	var/diagonalconnect = 0 //1 = NE; 2 = SE; 4 = NW; 8 = SW

	//Northeast
	if(connectdir & NORTH && connectdir & EAST)
		if(istype(get_step(src,NORTHEAST),/turf/simulated/floor))
			var/turf/simulated/floor/FF = get_step(src,NORTHEAST)
			if(FF.is_carpet_floor())
				diagonalconnect |= 1

	//Southeast
	if(connectdir & SOUTH && connectdir & EAST)
		if(istype(get_step(src,SOUTHEAST),/turf/simulated/floor))
			var/turf/simulated/floor/FF = get_step(src,SOUTHEAST)
			if(FF.is_carpet_floor())
				diagonalconnect |= 2

	//Northwest
	if(connectdir & NORTH && connectdir & WEST)
		if(istype(get_step(src,NORTHWEST),/turf/simulated/floor))
			var/turf/simulated/floor/FF = get_step(src,NORTHWEST)
			if(FF.is_carpet_floor())
				diagonalconnect |= 4

	//Southwest
	if(connectdir & SOUTH && connectdir & WEST)
		if(istype(get_step(src,SOUTHWEST),/turf/simulated/floor))
			var/turf/simulated/floor/FF = get_step(src,SOUTHWEST)
			if(FF.is_carpet_floor())
				diagonalconnect |= 8

	icon_state = "carpet[connectdir]-[diagonalconnect]"


/turf/simulated/floor/vox/shuttle
	icon_state = "vox_shuttle"

/obj/machinery/door/poddoor/shutters/rusty
	name = "rusty shutters"
	icon_state = "rustshutter1"
	base_icon_state = "rustshutter"
	animation_delay = 8.1

/obj/machinery/door/poddoor/shutters/rusty/preopen
	icon_state = "rustshutter0"
	density = 0
	opacity = 0
	layer = BELOW_TABLE_LAYER

/obj/machinery/door/poddoor/shutters/rusty/attackby(var/obj/item/I, var/mob/user)
	return

