/turf/simulated/wall/shuttle
	icon_state = "swall0"
	explosion_block = 2
	icon = 'icons/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0
	melt_temperature = 0 // Doesn't melt.
	flags = INVULNERABLE
	walltype = "swall"
	hardness = 100 // nohulkz

/turf/simulated/wall/shuttle/canSmoothWith()
	var/static/list/smoothables = list(
		/turf/simulated/wall/shuttle,
		/obj/machinery/door,
		/obj/structure/shuttle,
		/obj/structure/grille,
	)
	return smoothables

/turf/simulated/wall/shuttle/cannotSmoothWith()
	return

/turf/simulated/wall/shuttle/isSmoothableNeighbor(atom/A)
	if (get_area(A) != get_area(src))
		return 0
	return is_type_in_list(A, canSmoothWith()) && !(cannotSmoothWith() && (is_type_in_list(A, cannotSmoothWith())))

/turf/simulated/wall/shuttle/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.delayNextAttack(8)
	if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(istype(W,/obj/item/tool/solder) && bullet_marks)
		var/obj/item/tool/solder/S = W
		if(!S.remove_fuel(bullet_marks*2,user))
			return
		S.playtoolsound(loc, 100)
		to_chat(user, "<span class='notice'>You remove the bullet marks with \the [W].</span>")
		bullet_marks = 0
		icon = initial(icon)

/turf/simulated/wall/shuttle/ex_act(severity)
	return

/turf/simulated/wall/shuttle/dismantle_wall(devastated, explode)
	return 1

/turf/simulated/wall/shuttle/attack_rotting(mob/user)
	return

/turf/simulated/wall/shuttle/attack_animal(var/mob/living/simple_animal/M)
	return

/turf/simulated/wall/shuttle/singularity_pull(S, current_size)
	return

/turf/simulated/wall/shuttle/black
	icon_state = "bswall0"
	walltype = "bswall"

/turf/simulated/wall/shuttle/unsmoothed
	icon_state = "wall1"

/turf/simulated/wall/shuttle/unsmoothed/relativewall()
	return

/turf/simulated/shuttle/wall/unsmoothed/map_element_rotate(angle)
	src.transform = turn(src.transform, angle)

/turf/simulated/wall/shuttle/unsmoothed/black
	icon_state = "wall3"
	walltype = "bswall"

/obj/structure/shuttle/diag_wall // This used to be a turf and was a pain to manage with layering two on the same tile
	name = "wall"
	desc = "A huge chunk of metal used to separate rooms."
	icon_state = "diagonalWall"
	density = 1
	anchored = 1
	opacity = 1
	is_on_mesons = TRUE

/obj/structure/shuttle/diag_wall/initialize()
	var/turf/T = get_turf(src)
	if(T)
		if(!T.dynamic_lighting)
			update_moody_light('icons/lighting/moody_lights.dmi', "diag_wall")
		T.dynamic_lighting = 1
		if(SSlighting && SSlighting.initialized && !T.lighting_overlay)
			new /atom/movable/lighting_overlay(T, TRUE)
		update_weather_overlays(T)

/obj/structure/shuttle/diag_wall/New()
	..()
	if(world.has_round_started())
		initialize()

/obj/structure/shuttle/diag_wall/Destroy()
	var/turf/T = get_turf(src)
	if(istype(T,/turf/space))
		T.dynamic_lighting = 0
		T.lighting_clear_overlay()
	..()

/obj/structure/shuttle/diag_wall/forceMove(atom/destination, step_x = 0, step_y = 0, no_tp = FALSE, harderforce = FALSE, glide_size_override = 0)
	var/turf/T = get_turf(src)
	if(istype(T,/turf/space))
		T.dynamic_lighting = 0
		T.lighting_clear_overlay()
	var/datum/climate/Cold = SSweather.get_climate(T.v)
	if(Cold)
		Cold.unregister_weather_turf(T, TRUE)
		plane = initial(plane)
		layer = initial(layer)
	..()
	T = get_turf(destination)
	if(T)
		kill_moody_light()
		if(!T.dynamic_lighting)
			update_moody_light('icons/lighting/moody_lights.dmi', "diag_wall")
		T.dynamic_lighting = 1
		if(!T.lighting_overlay)
			new /atom/movable/lighting_overlay(T, TRUE)
		update_weather_overlays(T)

/obj/structure/shuttle/diag_wall/proc/update_weather_overlays(var/turf/T)
	var/climate_added = FALSE
	for(var/turf/adjT in range(1, T))
		if(adjT == T)
			continue
		if(istype(adjT, T.type))
			for(var/obj/effect/weather_holder/WH in adjT.vis_contents)
				T.vis_contents |= WH
				climate_added = TRUE
				break
		if(climate_added)
			break
	var/datum/climate/Cnew = SSweather.get_climate(T.v)
	if(climate_added && Cnew)
		Cnew.register_weather_turf(T, TRUE)
		plane = EFFECTS_PLANE
		layer = SNOW_OVERLAY_LAYER + 1

/obj/structure/shuttle/diag_wall/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group)
		return 0
	return !density

/obj/structure/shuttle/diag_wall/ex_act(severity)
	return

/obj/structure/shuttle/diag_wall/mech_drill_act(severity)
	return

/obj/structure/shuttle/diag_wall/attack_animal(var/mob/living/simple_animal/M)
	return

/obj/structure/shuttle/diag_wall/singularity_pull(S, current_size)
	return

/obj/structure/shuttle/diag_wall/black
	icon_state = "diagonalWall3"

/obj/structure/shuttle/diag_wall/smooth
	icon_state = "diagonalWallS"

/obj/structure/shuttle/diag_wall/smooth/black
	icon_state = "diagonalWall3S"

/turf/simulated/floor/shuttle
	icon = 'icons/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0
	soot_type = null
	melt_temperature = 0 // Doesn't melt.
	flags = INVULNERABLE

/turf/simulated/floor/shuttle/attackby(obj/item/weapon/W as obj, mob/user as mob)
	return

/turf/simulated/floor/shuttle/airless
	oxygen   = 0.01
	nitrogen = 0.01

/turf/simulated/floor/shuttle/ex_act(severity)
	switch(severity)
		if(1.0)
			if(!(locate(/obj/effect/decal/cleanable/soot) in src))
				new /obj/effect/decal/cleanable/soot(src)
		if(2.0)
			if(prob(65))
				if(!(locate(/obj/effect/decal/cleanable/soot) in src))
					new /obj/effect/decal/cleanable/soot(src)
		if(3.0)
			if(prob(20))
				if(!(locate(/obj/effect/decal/cleanable/soot) in src))
					new /obj/effect/decal/cleanable/soot(src)

/turf/simulated/floor/shuttle/cultify()
	if((icon_state != "cult")&&(icon_state != "cult-narsie"))
		name = "engraved floor"
		icon_state = "cult"
		turf_animation('icons/effects/effects.dmi',"cultfloor",0,0,MOB_LAYER-1, anim_plane = OBJ_PLANE)
	return

/turf/simulated/floor/shuttle/singularity_pull(S, current_size)
	return

/turf/simulated/floor/shuttle/plating
	name = "plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"

/turf/simulated/floor/shuttle/plating/airless
	oxygen   = 0.01
	nitrogen = 0.01

/turf/simulated/floor/shuttle/brig // Added this floor tile so that I have a seperate turf to check in the shuttle -- Polymorph
	name = "Brig floor"        // Also added it into the 2x3 brig area of the shuttle.
	icon_state = "floor4"


/obj/machinery/podcomputer
	name = "pod computer"
	desc = "A computer for piloting escape pods. The software hasn't been updated since the autopilot system was installed and is mostly non-functional."
	use_power = 0
	icon = 'icons/obj/computer.dmi'
	anchored = TRUE
	icon_state = "podcomputer"
	icon_state_open = "podcomputer_maint"

	var/datum/shuttle/escape/pod/linked_pod
	machine_flags = SCREWTOGGLE | EMAGGABLE

	hack_abilities = list(
		/datum/malfhack_ability/oneuse/emag,
		/datum/malfhack_ability/oneuse/overload_quiet
	)


/obj/machinery/podcomputer/Destroy()
	linked_pod?.podcomputer = null
	linked_pod?.crashing_this_pod = FALSE
	..()

/obj/machinery/podcomputer/process()
	..()
	update_icon()

/obj/machinery/podcomputer/emag_act(mob/user)
	if(emagged)
		return
	if(emergency_shuttle.online)
		to_chat(user, "<span class='warning'>The emergency shuttle is already on its way. \The [src]'s systems are locked.")
		return
	to_chat(user, "<span class='warning'>You insert the cryptographic sequencer into the [src] short out the desination controller!</span>")
	emagged = TRUE
	linked_pod?.crashing_this_pod = "with no survivors"
	spark(src)
	update_icon()

/obj/machinery/podcomputer/examine(mob/user)
	..()
	if(panel_open && emagged)
		to_chat(user, "<span class='danger'>Some of the wires have been shorted out!</span>")

/obj/machinery/podcomputer/attackby(obj/item/O, mob/user)
	..()
	if(issolder(O) && emagged && panel_open)
		var/obj/item/tool/solder/S = O
		if(S.remove_fuel(2,user))
			fix_circuitry(user)

/obj/machinery/podcomputer/proc/fix_circuitry(mob/user)
	emagged = FALSE
	to_chat(user, "<span class='notice'>You repair the melted wire in the destination controller.</span>")
	linked_pod?.crashing_this_pod = FALSE

/obj/machinery/podcomputer/update_icon()
	update_moody_light('icons/lighting/moody_lights.dmi', "overlay_podcomputer")
	if(panel_open)
		icon_state = "podcomputer_maint"
	else if(emergency_shuttle.online)
		icon_state = "podcomputer_shuttle"
	else if(emagged)
		icon_state = "podcomputer_error"
	else
		icon_state = "podcomputer"


/obj/item/stack/shuttle_panel
	name = "shuttle panel"
	desc = "A prefabricated wall panel used in shuttle construction. Apply it to a secured metal girder to build a shuttle wall. The panel can be sliced off with a welder."
	singular_name = "shuttle panel"
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "panel"
	w_class = W_CLASS_LARGE
	max_amount = 60
	flags = FPRINT
	starting_materials = list(MAT_IRON = CC_PER_SHEET_METAL)
	perunit = CC_PER_SHEET_METAL
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	origin_tech = Tc_MATERIALS + "=1"
	var/wall_type = /turf/simulated/wall/shuttle/panel

/obj/item/stack/shuttle_panel/black
	name = "black shuttle panel"
	desc = "A prefabricated wall panel used in shuttle construction, finished in matte black. Apply it to a secured metal girder to build a black shuttle wall. The panel can be sliced off with a welder."
	singular_name = "black shuttle panel"
	icon_state = "panel_black"
	wall_type = /turf/simulated/wall/shuttle/panel/black

/turf/simulated/wall/shuttle/panel
	name = "shuttle wall"
	desc = "A wall built from shuttle panels bolted to a girder."
	flags = 0
	hardness = 60
	explosion_block = 1
	var/panel_type = /obj/item/stack/shuttle_panel

/turf/simulated/wall/shuttle/panel/black
	name = "black shuttle wall"
	desc = "A wall built from black shuttle panels bolted to a girder."
	icon_state = "bswall0"
	walltype = "bswall"
	panel_type = /obj/item/stack/shuttle_panel/black

/turf/simulated/wall/shuttle/panel/isSmoothableNeighbor(atom/A)
	if(!A)
		return 0
	return is_type_in_list(A, canSmoothWith()) && !(cannotSmoothWith() && (is_type_in_list(A, cannotSmoothWith())))

/turf/simulated/wall/shuttle/panel/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.delayNextAttack(8)
	if(!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.isOn() && WT.get_fuel() >= 1)
			user.visible_message("<span class='warning'>[user] begins slicing through \the [src]'s outer panel.</span>", \
				"<span class='notice'>You begin slicing through \the [src]'s outer panel.</span>", \
				"<span class='warning'>You hear welding noises.</span>")
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			if(WT.do_weld(user, src, 100, 1))
				if(!istype(src))
					return
				playsound(src, 'sound/items/Welder.ogg', 100, 1)
				user.visible_message("<span class='warning'>[user] slices off \the [src]'s outer panel.</span>", \
					"<span class='notice'>You slice off \the [src]'s outer panel.</span>", \
					"<span class='warning'>You hear welding noises.</span>")
				var/pdiff = performWallPressureCheck(src)
				if(pdiff)
					investigation_log(I_ATMOS, "with a pdiff of [pdiff] dismantled by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]!")
					message_admins("\The [src] with a pdiff of [pdiff] has been dismantled by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]!")
				dismantle_wall()
		return
	return ..()

/turf/simulated/wall/shuttle/panel/dismantle_wall(devastated = 0, explode = 0)
	if(!devastated)
		new panel_type(src, 1)
		if(girder_type)
			new girder_type(src)
	else
		new /obj/item/stack/sheet/metal(src)
	for(var/obj/O in src.contents)
		if(istype(O, /obj/effect/cult_shortcut))
			qdel(O)
		if(istype(O, /obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)
	if(peepers)
		reset_view()
	ChangeTurf(dismantle_type)
	update_near_walls()

/turf/simulated/wall/shuttle/panel/ex_act(severity)
	switch(severity)
		if(1.0)
			ChangeTurf(get_underlying_turf())
			return
		if(2.0)
			if(prob(50))
				dismantle_wall(0, 1)
			else
				dismantle_wall(1, 1)
			return
		if(3.0)
			if(prob(40))
				dismantle_wall(0, 1)
			return

/turf/simulated/wall/shuttle/panel/attack_animal(var/mob/living/simple_animal/M)
	M.delayNextAttack(8)
	if(M.environment_smash_flags & SMASH_WALLS)
		playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
		dismantle_wall(1)
		M.visible_message("<span class='danger'>[M] smashes through \the [src].</span>", \
			"<span class='attack'>You smash through \the [src].</span>")

/turf/simulated/wall/shuttle/panel/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(75))
			dismantle_wall()
		return
	if(current_size == STAGE_FOUR)
		if(prob(30))
			dismantle_wall()
