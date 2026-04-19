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
	if(issolder(W) && bullet_marks)
		remove_holes(W,user)

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

/obj/structure/shuttle/diag_wall/diy
	anchored = FALSE
	verb_rotates = TRUE
	alt_click_rotates = TRUE
	var/panel_type = /obj/item/stack/shuttle_panel

/obj/structure/shuttle/diag_wall/diy/can_wrench_shuttle()
	return TRUE

/obj/structure/shuttle/diag_wall/diy/attackby(obj/item/I, mob/user)
	if(I.is_wrench(user))
		if(wrenchAnchor(user, I, 5 SECONDS))
			return TRUE
		return FALSE
	if(iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		if(!WT.isOn())
			to_chat(user, "<span class='warning'>\The [WT] needs to be on!</span>")
			return FALSE
		if(anchored)
			to_chat(user, "<span class='warning'>\The [src] must be unwrenched before you can disassemble it!</span>")
			return FALSE
		user.visible_message("<span class='warning'>[user] begins cutting apart \the [src].</span>", \
			"<span class='notice'>You begin cutting apart \the [src].</span>", \
			"<span class='warning'>You hear welding noises.</span>")
		playsound(src, 'sound/items/Welder.ogg', 100, 1)
		if(WT.do_weld(user, src, 50, 1))
			if(QDELETED(src))
				return TRUE
			user.visible_message("<span class='warning'>[user] cuts apart \the [src].</span>", \
				"<span class='notice'>You cut apart \the [src] and recover the shuttle panel.</span>", \
				"<span class='warning'>You hear welding noises.</span>")
			new panel_type(get_turf(src), 2)
			qdel(src)
		return TRUE
	return ..()

/obj/structure/shuttle/diag_wall/diy/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(50))
				qdel(src)
		if(3.0)
			if(prob(25))
				qdel(src)

/obj/structure/shuttle/diag_wall/diy/mech_drill_act(severity)
	new panel_type(get_turf(src), 2)
	qdel(src)
	return TRUE

/obj/structure/shuttle/diag_wall/diy/singularity_pull(S, current_size)
	if(current_size >= 4)
		if(prob(50))
			qdel(src)

/obj/structure/shuttle/diag_wall/diy/black
	icon_state = "diagonalWall3"
	panel_type = /obj/item/stack/shuttle_panel/black

/obj/structure/shuttle/diag_wall/diy/smooth
	icon_state = "diagonalWallS"

/obj/structure/shuttle/diag_wall/diy/smooth/black
	icon_state = "diagonalWall3S"
	panel_type = /obj/item/stack/shuttle_panel/black

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
	desc = "A prefabricated wall panel used in shuttle construction. Apply it to a secured metal girder to build a shuttle wall. The panel can be sliced off with a welder. Use in hand to see construction options."
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

/obj/item/stack/shuttle_panel/New(var/loc, var/amount=null)
	recipes = shuttle_panel_recipes
	return ..()

/obj/item/stack/shuttle_panel/black
	name = "black shuttle panel"
	desc = "A prefabricated wall panel used in shuttle construction, finished in matte black. Apply it to a secured metal girder to build a black shuttle wall. The panel can be sliced off with a welder. Use in hand to see construction options."
	singular_name = "black shuttle panel"
	icon_state = "panel_black"
	wall_type = /turf/simulated/wall/shuttle/panel/black

/obj/item/stack/shuttle_panel/black/New(var/loc, var/amount=null)
	recipes = shuttle_panel_black_recipes
	return ..()

/turf/simulated/wall/shuttle/panel
	name = "shuttle wall"
	desc = "A wall built from shuttle panels bolted to a girder."
	flags = 0
	hardness = 60
	explosion_block = 1
	dismantle_type = /turf/simulated/floor/plating
	var/panel_type = /obj/item/stack/shuttle_panel
	var/reinforcing = 0 // 0 = normal, 1 = rods applied (awaiting plasteel)

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
	// Reinforcement construction step 1: Apply 4 metal rods to add support struts
	if(istype(W, /obj/item/stack/rods) && !reinforcing)
		var/obj/item/stack/rods/R = W
		if(R.amount < 4)
			to_chat(user, "<span class='warning'>You need at least 4 rods to reinforce this wall.</span>")
			return
		user.visible_message("<span class='notice'>[user] begins inserting support rods into \the [src].</span>", \
			"<span class='notice'>You begin inserting support rods into \the [src].</span>")
		playsound(src, 'sound/items/Wirecutter.ogg', 50, 1)
		if(do_after(user, src, 50))
			if(!istype(src, /turf/simulated/wall/shuttle/panel) || reinforcing)
				return
			var/obj/item/stack/rods/O = W
			if(O.amount < 4)
				to_chat(user, "<span class='warning'>You need at least 4 rods to reinforce this wall.</span>")
				return
			O.use(4)
			user.visible_message("<span class='notice'>[user] inserts support rods into \the [src].</span>", \
				"<span class='notice'>You insert support rods into \the [src]. Now it needs plasteel plating.</span>")
			reinforcing = 1
			overlays += image(icon = 'icons/turf/shuttle.dmi', icon_state = "reinforcement")
			desc = "A shuttle wall with support rods installed. It needs plasteel plating to complete the reinforcement."
		return
	// Reinforcement construction step 2: Apply 2 plasteel sheets to complete
	if(istype(W, /obj/item/stack/sheet/plasteel) && reinforcing)
		var/obj/item/stack/sheet/plasteel/P = W
		if(P.amount < 2)
			to_chat(user, "<span class='warning'>You need at least 2 plasteel sheets to complete the reinforcement.</span>")
			return
		user.visible_message("<span class='notice'>[user] begins securing plasteel plating to \the [src].</span>", \
			"<span class='notice'>You begin securing plasteel plating to \the [src].</span>")
		playsound(src, 'sound/items/Welder.ogg', 50, 1)
		if(do_after(user, src, 60))
			if(!istype(src, /turf/simulated/wall/shuttle/panel) || !reinforcing)
				return
			var/obj/item/stack/sheet/plasteel/O = W
			if(O.amount < 2)
				to_chat(user, "<span class='warning'>You need at least 2 plasteel sheets to complete the reinforcement.</span>")
				return
			O.use(2)
			user.visible_message("<span class='notice'>[user] completes the reinforced plating on \the [src].</span>", \
				"<span class='notice'>You complete the reinforced plating. The wall is now fully reinforced.</span>")
			var/turf/simulated/wall/shuttle/reinforced/panel/new_wall = ChangeTurf(/turf/simulated/wall/shuttle/reinforced/panel)
			new_wall.add_fingerprint(user)
		return
	return ..()

/turf/simulated/wall/shuttle/panel/dismantle_wall(devastated = 0, explode = 0)
	if(!devastated)
		new panel_type(src, 1)
		if(reinforcing)
			new /obj/item/stack/rods(src, 4)
		if(girder_type)
			new girder_type(src)
	else
		new /obj/item/stack/sheet/metal(src)
		if(reinforcing)
			new /obj/item/stack/rods(src, 2)
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
			ChangeTurf(dismantle_type)
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

// =============================
// Reinforced Shuttle Walls
// =============================

// Map-placed reinforced shuttle wall (invulnerable, like base shuttle walls)
/turf/simulated/wall/shuttle/reinforced
	name = "reinforced shuttle wall"
	desc = "A heavily reinforced shuttle wall. It looks nearly impervious to damage."
	icon_state = "rbswall0"
	walltype = "rbswall"
	hardness = 100
	explosion_block = 3

/turf/simulated/wall/shuttle/reinforced/canSmoothWith()
	var/static/list/smoothables = list(
		/turf/simulated/wall/shuttle,
		/obj/machinery/door,
		/obj/structure/shuttle,
		/obj/structure/grille,
	)
	return smoothables

// Constructible reinforced shuttle wall (panel variant)
/turf/simulated/wall/shuttle/reinforced/panel
	name = "reinforced shuttle wall"
	desc = "A shuttle wall reinforced with rods and plasteel plating. Much tougher than a standard shuttle wall."
	flags = 0
	hardness = 90
	explosion_block = 2
	dismantle_type = /turf/simulated/floor/plating
	penetration_dampening = 20

/turf/simulated/wall/shuttle/reinforced/panel/isSmoothableNeighbor(atom/A)
	if(!A)
		return 0
	return is_type_in_list(A, canSmoothWith()) && !(cannotSmoothWith() && (is_type_in_list(A, cannotSmoothWith())))

/turf/simulated/wall/shuttle/reinforced/panel/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.delayNextAttack(8)
	if(!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	// Step 1: Weld to expose the reinforcement
	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.isOn() && WT.get_fuel() >= 1)
			user.visible_message("<span class='warning'>[user] begins cutting into \the [src]'s reinforced plating.</span>", \
				"<span class='notice'>You begin cutting into \the [src]'s reinforced plating.</span>", \
				"<span class='warning'>You hear welding noises.</span>")
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			if(WT.do_weld(user, src, 100, 1))
				if(!istype(src, /turf/simulated/wall/shuttle/reinforced/panel))
					return
				playsound(src, 'sound/items/Welder.ogg', 100, 1)
				user.visible_message("<span class='warning'>[user] cuts through \the [src]'s reinforced plating, exposing the support rods.</span>", \
					"<span class='notice'>You cut through \the [src]'s reinforced plating, exposing the support rods.</span>", \
					"<span class='warning'>You hear welding noises.</span>")
				// Drop the plasteel used in construction
				new /obj/item/stack/sheet/plasteel(src, 2)
				// Transition to intermediate state — needs wirecutters next
				var/turf/simulated/wall/shuttle/reinforced/panel/welded/W_turf = ChangeTurf(/turf/simulated/wall/shuttle/reinforced/panel/welded)
				W_turf.add_fingerprint(user)
		return
	// Bullet mark repair (inherited behavior)
	if(istype(W,/obj/item/tool/solder) && bullet_marks)
		var/obj/item/tool/solder/S = W
		if(!S.remove_fuel(bullet_marks*2,user))
			return
		S.playtoolsound(loc, 100)
		to_chat(user, "<span class='notice'>You remove the bullet marks with \the [W].</span>")
		bullet_marks = 0
		icon = initial(icon)
	return

// Intermediate state: reinforced shuttle wall that has been welded open (awaiting wirecutters)
/turf/simulated/wall/shuttle/reinforced/panel/welded
	name = "reinforced shuttle wall"
	desc = "A reinforced shuttle wall with its plating cut open. The support rods are exposed and can be cut with wirecutters."
	flags = 0

/turf/simulated/wall/shuttle/reinforced/panel/welded/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.delayNextAttack(8)
	if(!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	// Step 2: Wirecutters to remove the rods and revert to a black panel wall
	if(iswirecutter(W))
		user.visible_message("<span class='warning'>[user] begins cutting through \the [src]'s support rods.</span>", \
			"<span class='notice'>You begin cutting through \the [src]'s support rods.</span>", \
			"<span class='warning'>You hear snipping sounds.</span>")
		W.playtoolsound(src, 100)
		if(do_after(user, src, 50))
			if(!istype(src, /turf/simulated/wall/shuttle/reinforced/panel/welded))
				return
			W.playtoolsound(src, 100)
			user.visible_message("<span class='warning'>[user] cuts through \the [src]'s support rods.</span>", \
				"<span class='notice'>You cut through \the [src]'s support rods and remove the reinforcement.</span>", \
				"<span class='warning'>You hear snipping sounds.</span>")
			// Drop the rods used in construction
			new /obj/item/stack/rods(src, 4)
			// Revert to a black panel shuttle wall
			var/turf/simulated/wall/shuttle/panel/black/new_wall = ChangeTurf(/turf/simulated/wall/shuttle/panel/black)
			new_wall.add_fingerprint(user)
		return
	// Allow welding it back shut
	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.isOn() && WT.get_fuel() >= 1)
			user.visible_message("<span class='notice'>[user] begins welding \the [src]'s reinforced plating back shut.</span>", \
				"<span class='notice'>You begin welding \the [src]'s reinforced plating back shut.</span>", \
				"<span class='warning'>You hear welding noises.</span>")
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			if(WT.do_weld(user, src, 50, 1))
				if(!istype(src, /turf/simulated/wall/shuttle/reinforced/panel/welded))
					return
				playsound(src, 'sound/items/Welder.ogg', 100, 1)
				user.visible_message("<span class='notice'>[user] welds \the [src]'s reinforced plating shut.</span>", \
					"<span class='notice'>You weld \the [src]'s reinforced plating back shut.</span>", \
					"<span class='warning'>You hear welding noises.</span>")
				var/turf/simulated/wall/shuttle/reinforced/panel/new_wall = ChangeTurf(/turf/simulated/wall/shuttle/reinforced/panel)
				new_wall.add_fingerprint(user)
		return
	return

/turf/simulated/wall/shuttle/reinforced/panel/welded/update_icon()
	..()
	overlays += image(icon = 'icons/turf/shuttle.dmi', icon_state = "reinforcement")

// Reinforced panel wall: explosion behavior (mirrors r_wall)
/turf/simulated/wall/shuttle/reinforced/panel/ex_act(severity)
	switch(severity)
		if(1.0)
			if(prob(66))
				dismantle_wall(0, 1)
			else
				dismantle_wall(1, 1)
		if(2.0)
			if(prob(75))
				// Partially damage — drop some plasteel but don't destroy
				new /obj/item/stack/sheet/plasteel(get_turf(src))
			else
				dismantle_wall(0, 1)
		if(3.0)
			if(prob(15))
				dismantle_wall(0, 1)

/turf/simulated/wall/shuttle/reinforced/panel/dismantle_wall(devastated = 0, explode = 0)
	if(!devastated)
		new /obj/item/stack/sheet/plasteel(src, 2)
		new /obj/item/stack/rods(src, 4)
		new /obj/item/stack/shuttle_panel/black(src, 1)
		if(girder_type)
			new girder_type(src)
	else
		new /obj/item/stack/rods(src, 2)
		new /obj/item/stack/sheet/plasteel(src)
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

// Reinforced panel wall: animal attack behavior (mirrors r_wall)
/turf/simulated/wall/shuttle/reinforced/panel/attack_animal(var/mob/living/simple_animal/M)
	M.delayNextAttack(8)
	if(M.environment_smash_flags & SMASH_WALLS)
		if(M.environment_smash_flags & SMASH_RWALLS)
			playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
			dismantle_wall(1)
			M.visible_message("<span class='danger'>[M] smashes through \the [src].</span>", \
				"<span class='attack'>You smash through \the [src].</span>")
		else
			to_chat(M, "<span class='info'>\The [src] is far too strong for you to destroy.</span>")

// Reinforced panel wall: rotting behavior (mirrors r_wall — doesn't crumble)
/turf/simulated/wall/shuttle/reinforced/panel/attack_rotting(mob/user)
	to_chat(user, "<span class='notice'>This [src] feels rather unstable.</span>")

// Reinforced panel wall: acid immunity (mirrors r_wall)
/turf/simulated/wall/shuttle/reinforced/panel/dissolvable()
	return 0

// Reinforced panel wall: singularity resistance (mirrors r_wall)
/turf/simulated/wall/shuttle/reinforced/panel/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()
