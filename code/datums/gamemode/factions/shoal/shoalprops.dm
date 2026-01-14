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

/obj/prop/coolerfan
	name = "cooling fan"
	icon_state = "cooler"
	density = 0

/obj/prop/monitor
	name = "monitor"
	icon_state = "monitor"
	density = 0

/obj/prop/panel
	name = "panel"
	icon_state = "panel"
	density = 0

/obj/prop/panelwires
	name = "panel"
	icon_state = "panel-broken-wires"
	density = 0

/obj/prop/panelbroken
	name = "panel"
	icon_state = "panel-broken"
	density = 0

/obj/prop/carpet
	name = "carpet"
	icon_state = "carpetsmall"
	density = 0

/obj/prop/carpetbig
	name = "big carpet"
	icon = 'icons/obj/props_64x64.dmi'
	icon_state = "carpetbig"
	density = 0

/obj/prop/loadingdecal
	name = "loading"
	icon = 'icons/obj/props_64x64.dmi'
	icon_state = "loading"
	density = 0

/obj/prop/carpetlong
	name = "long carpet"
	icon = 'icons/obj/props_64x64.dmi'
	icon_state = "carpetlong"
	density = 0

/obj/prop/floorpanel
	name = "floorpanel"
	icon = 'icons/obj/props_64x64.dmi'
	icon_state = "floorpanel"
	density = 0

/obj/prop/metalwear1
	name = "wear"
	icon = 'icons/obj/props_64x64.dmi'
	icon_state = "metalwear1"
	density = 0

/obj/prop/metalwear2
	name = "wear"
	icon = 'icons/obj/props_64x64.dmi'
	icon_state = "metalwear2"
	density = 0

/obj/prop/metalwear3
	name = "wear"
	icon = 'icons/obj/props_64x64.dmi'
	icon_state = "metalwear3"
	density = 0

/obj/prop/metalwear4
	name = "wear"
	icon = 'icons/obj/props_64x64.dmi'
	icon_state = "metalwear4"
	density = 0

/obj/prop/metalwear5
	name = "wear"
	icon = 'icons/obj/props_64x64.dmi'
	icon_state = "metalwear5"
	density = 0


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
				var/turf/unsimulated/floor = get_step(src,direction)
				if(istype(FF))
					FF.update_icon()


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

/turf/unsimulated/floor/vox/abyss
	name = "abyss"
	desc = "You can't see the bottom."
	icon_state = "blackpit"
	plane = BELOW_PLATING_PLANE

/atom/movable
	// Adding a variable for this probably isn't the best approach, but it's the easiest.
	// That way, if someone throws something across the abyss and it crosses multiple /effect/abyss's, it'll only start the falling sequence once.
	var/abyssfall = FALSE

/obj/effect/abyss
	name = "landmark"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1
	w_type=NOT_RECYCLABLE
	invisibility = 101
	var/abyss_link_tag = ""
	var/initialized = FALSE
	var/exclude_types = list(
		/obj/structure/bed/chair/vehicle/adminbus/, 	// NOPE!
//		/obj/structure/bed/chair/vehicle/firebird/,		// See can_fall() comment.
	)

/obj/effect/abyss/initialize()
	. = ..()
	initialized = TRUE

/obj/effect/abyss/proc/can_abyssfall(var/atom/movable/AM)
	if(!isobj(AM) && !isliving(AM))						// Objects and living mobs only!
		return FALSE
	if(is_type_in_list(AM, exclude_types))
		return FALSE
	if(is_type_in_list(AM.locked_to, exclude_types))
		return FALSE

	// 		I thought about allowing players to flying things like powered jetpacks and firebirds to traverse the abyss.
	// 		but this just invites a headache because of the out-of-bounds "fake-z" areas, which are not meant to be accessible.
	// 		What should happen if someone's jetpack runs out of fuel or someone exits their firebird above one of those areas?
	//		The extra complexity isn't worth it for such a niche interaction.
	//		The adminbus remains excluded because the adminbus don't care

	/*
	var/mob/living/carbon/human/H
	if(ishuman(H))
		if(istype(H.back, /obj/item/weapon/tank/jetpack))
			var/obj/item/weapon/tank/jetpack/J = H.back
			if((J.allow_thrust(0.01, src)))
				return FALSE
	*/

	return TRUE

/obj/effect/abyss/Crossed(var/atom/movable/AM)
	if(AM.abyssfall || !initialized || !can_abyssfall(AM))
		..()
	else
		abyssfall(AM)


/obj/effect/abyss/proc/abyssfall(var/atom/movable/AM)
	AM.abyssfall = TRUE
	AM.visible_message("<span class='warning'>[AM] falls down into the abyss, disappearing from view!</span>")
	var/color_cache = AM.color

	// There's some weird quirk with animate where non-mobs take longer to have their color adjusted.
	// Don't know why that happens, but here's a workaround..
	if(isobj(AM))
		animate(AM, color = "#000000", time = 3)
	else
		animate(AM, color = "#000000", time = 1 SECONDS)
	// Play a falling sound here

	var/list/mob_list = recursive_type_check(AM, /mob/living)
	var/list/human_list = recursive_type_check(AM, /mob/living/carbon/human)
	mob_list = mob_list - human_list

	for(var/mob/living/M in mob_list)
		M.Knockdown(10)
		M.Stun(10)
		M.captured = TRUE	// The captured var exists for other things like mannequins and the adminbus, but it works perfectly fine here.
		M.update_canmove()

	for(var/mob/living/carbon/human/M in human_list)
		if(M.client)
			if(pulledby) 		// If we have a client, we add attack logs
				add_logs(pulledby, M, "pulled into an abyss", TRUE, src, get_coordinates_string(src))
			else if(M.last_bumped_by_timestamp - 0.1 SECONDS <= world.time <= M.last_bumped_by_timestamp + 0.1 SECONDS) // If got bumped into a supermatter
				var/mob/hostile = M.last_bumped_by.get()
				add_logs(hostile, M, "bumped into an abyss", TRUE, src, get_coordinates_string(src))
			else if(M.last_thrown_by_timestamp - 0.1 SECONDS <= world.time <= M.last_thrown_by_timestamp + 2 SECONDS) // If got thrown into a supermatter
				var/mob/hostile = M.last_thrown_by.get()
				add_logs(hostile, M, "thrown into an abyss", TRUE, src, get_coordinates_string(src))
			else
				M.attack_log += "\[[time_stamp()]\]: walked into supermatter (no bumper/no pusher)"

		if(M.pulledby)
			pulledby.stop_pulling()
		to_chat(M, "<span class='danger'>Everything turns dark as you tumble down the pit...</span>")
		M.overlay_fullscreen("blindblack", /obj/abstract/screen/fullscreen/black)
		M.update_fullscreen_alpha("blindblack", 255, 10)
		M.audible_scream()
		M.captured = TRUE
		M.Knockdown(10)
		M.Stun(10)
		M.update_canmove()



	spawn(1 SECONDS + 1)
		if(human_list.len != 0)					// If AM is a human or contains a human, it gets collected by any corpse chutes.
			var/list/valid_chutes = list()
			for(var/obj/structure/disposaloutlet/no_deconstruct/abysschute/D in abyss_chutes)	// First, we try to pick a chute with a matching tag.
				if(D.abyss_link_tag == abyss_link_tag)											// If the tags match, add the chute to the list of possible picks.
					valid_chutes += D
			var/obj/structure/disposaloutlet/D = pick(valid_chutes)			// Then we pick one of the valid chutes.
			var/obj/structure/disposalholder/H
			if(D)
				H = new(D)
				AM.forceMove(H)
			else
				AM.loc = null
				qdel(AM)
				CRASH("no abyss corpse chutes exist in the world OR no chutes exist with a matching abyss_link_tag var!")

			for(var/mob/living/carbon/human/M in human_list)
				M.captured = FALSE

				var/total_damage = 100 		// Always enough to knock the person into crit.
				var/datum/organ/external/lleg = M.pick_usable_organ(LIMB_LEFT_LEG)
				var/datum/organ/external/rleg = M.pick_usable_organ(LIMB_RIGHT_LEG)
				var/datum/organ/external/chest = M.pick_usable_organ(LIMB_CHEST)

				if(lleg)
					var/dam = rand(40, 60)
					lleg.take_damage(dam, 0)
					total_damage -= dam
				if(rleg)
					var/dam = rand(40,min(60, total_damage))
					rleg.take_damage(dam,0)
					total_damage -= dam
				if(chest)
					chest.take_damage(total_damage,0)	// Any remaining damage gets splashed to the chest.
				else
					M.adjustBruteLoss(total_damage)		// There should always be a chest organ, but just in case.

				to_chat(M, "<span class='big danger'>Ouch...</span>")
				M.playsound_local(src, 'sound/effects/falldamage.ogg', 75, 0)
				M.clear_fullscreen("blindblack", 30)

				M.UpdateDamageIcon()
				M.updatehealth()
				M.Life()		// Update just about everything else.

			for(var/mob/living/M in mob_list)
				M.captured = TRUE
				M.death()							// Kill any non-humans instantly.

			AM.color = color_cache
			AM.abyssfall = FALSE

			spawn(20)
				D.expel(H)
		else										// If AM isn't a human or contains a human, it's lost forever.
			for(var/mob/living/M in mob_list)
				qdel(M)			// We want to delete any mobs first so their ghosts (if they're player-controlled) end up in the spot where they fell.
			AM.loc = null
			qdel(AM)



var/global/list/abyss_chutes = list()
/obj/structure/disposaloutlet/no_deconstruct/abysschute
	name = "corpse chute"
	var/abyss_link_tag = ""

/obj/structure/disposaloutlet/no_deconstruct/abysschute/New()
	..()
	abyss_chutes += src

/obj/structure/disposaloutlet/no_deconstruct/abysschute/Destroy()
	abyss_chutes -= src
	..()


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
