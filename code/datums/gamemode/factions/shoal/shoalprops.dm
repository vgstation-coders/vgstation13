/obj/prop/
	name = ""
	desc = ""
	anchored = TRUE
	density = TRUE
	icon = 'icons/obj/props.dmi'

/obj/prop/shoalwindow
	name = "window"
	desc = "There's a faint light coming through it."
	icon_state = "shoalwindow"

/obj/prop/shoalwindow/New()
	..()
	if(dir & EAST || dir & WEST)
		pixel_y = rand(-8, 8)
	else
		pixel_x = rand(-8, 8)
	update_moody_light(moody_icon = 'icons/lighting/moody_lights.dmi', moody_state = icon_state)


/obj/prop/hanginglight
	name = "hanging light"
	icon = 'icons/obj/props_96x96.dmi'
	icon_state = "hanginglight"
	plane = ABOVE_HUMAN_PLANE
	layer = LIGHT_FIXTURE_LAYER
	pixel_x = -WORLD_ICON_SIZE
	pixel_y = WORLD_ICON_SIZE/2
	density = FALSE

	var/set_range = 2
	var/set_power = 1
	var/set_color = "#e9ef8d"

/obj/prop/hanginglight/New()
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

/turf/simulated/floor/vox/shuttle
	icon_state = "vox_shuttle"

/turf/unsimulated/floor/vox/abyss
	name = "abyss"
	desc = "You can't see the bottom."
	icon_state = "blackpit"
	plane = PLATING_PLANE


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


/obj/effect/decal/papers
	name = "papers"
	icon = 'icons/obj/props.dmi'
	icon_state = "papers"
	mouse_opacity = 0

/obj/effect/decal/wallpapers
	name = "wall papers"
	icon = 'icons/obj/props.dmi'
	icon_state = "papers_wall"
	mouse_opacity = 0



/*
// Applies the open space overlay. //NOT FOR ACTUAL MULTI-Z
/obj/effect/fake_open_space
	icon = 'icons/turf/open_space_64x64.dmi'
	var/base_icon_state = "black_open"
	icon_state = "black_open_base"
	anchored = TRUE
	density = TRUE
	mouse_opacity = 0
	plane = ABOVE_LIGHTING_PLANE
	pixel_x = -16 * PIXEL_MULTIPLIER
	pixel_y = -16 * PIXEL_MULTIPLIER

// same as above, just darker
/obj/effect/fake_open_space/deep
	base_icon_state = "black_open_deep"
	icon_state = "black_open_deep_base"

// same as above, just ever darker
/obj/effect/fake_open_space/deeper
	base_icon_state = "black_open_deeper"
	icon_state = "black_open_deeper_base"

/obj/effect/fake_open_space/New()
	var/turf/T = get_turf(src)
	T.density = TRUE
	T.opacity = FALSE
	T.lighting_overlay.update_overlay()
	T.filters += filter(type="drop_shadow", x=0, y=-2, size=4, color="#04080FAA")
//	T.filters += filter(type="blur", size=1)

	spawn()
		for(var/obj/O in T)
			O.filters += filter(type="drop_shadow", x=0, y=-2, size=4, color="#04080FAA")
	//		O.filters += filter(type="blur", size=1)

		var/walled_dirs = 0
		for(var/cdir in cardinal)
			var/turf/terf = get_step(src,cdir)
			if(!iswall(terf) || is_type_in_list(type, terf.contents))
				continue
			walled_dirs |= cdir
			overlays += image(icon, src, base_icon_state, layer, cdir)

		// Probably not the best way to do this.
		if(walled_dirs & EAST && walled_dirs & NORTH)
			overlays += image(icon, src, base_icon_state, layer, NORTHEAST)
		if(walled_dirs & WEST && walled_dirs & NORTH)
			overlays += image(icon, src, base_icon_state, layer, NORTHWEST)
		if(walled_dirs & EAST && walled_dirs & SOUTH)
			overlays += image(icon, src, base_icon_state, layer, SOUTHEAST)
		if(walled_dirs & WEST && walled_dirs & SOUTH)
			overlays += image(icon, src, base_icon_state, layer, SOUTHWEST)


// Applies a drop shadow to shit on the tile and then deletes itself.
/obj/effect/landmark/drop_shadow
	layer = 100
	plane = 100
	//So that it's more visible in the map editor

/obj/effect/landmark/drop_shadow/New()
	var/turf/T = get_turf(src)
	T.filters += filter(type="drop_shadow", x=0, y=-2, size=4, color="#04080FAA")

	spawn()
		for(var/obj/O in T)
			O.filters += filter(type="drop_shadow", x=0, y=-2, size=4, color="#04080FAA")

	qdel(src)

*/
