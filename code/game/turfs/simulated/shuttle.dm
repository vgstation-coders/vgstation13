/turf/simulated/wall/shuttle
	icon_state = "swall0"
	explosion_block = 2
	icon = 'icons/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0
	melt_temperature = 0 // Doesn't melt.
	flags = INVULNERABLE
	walltype = "swall"

/turf/simulated/wall/shuttle/canSmoothWith()
	var/static/list/smoothables = list(
		/turf/simulated/wall/shuttle,
		/obj/machinery/door,
		/obj/structure/shuttle,
		/obj/structure/grille,
	)
	return smoothables

/turf/simulated/wall/shuttle/isSmoothableNeighbor(atom/A)
	if (get_area(A) != get_area(src))
		return 0

	return ..()

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

/turf/simulated/wall/shuttle/mech_drill_act(severity)
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

/turf/simulated/shuttle/wall/unsmoothed/shuttle_rotate(angle)
	src.transform = turn(src.transform, angle)

/turf/simulated/wall/shuttle/unsmoothed/black
	icon_state = "wall3"
	walltype = "bswall"

/obj/structure/shuttle/diag_wall // This used to be a turf and was a pain to manage with layering two on the same tile
	name = "wall"
	desc = "A huge chunk of metal used to separate rooms."
	icon_state = "diagonalWall"
	density = 1
	plane = TURF_PLANE
	layer = TURF_LAYER
	anchored = 1
	opacity = 1

/obj/structure/shuttle/diag_wall/initialize()
	var/turf/T = get_turf(src)
	if(T)
		T.dynamic_lighting = 1

/obj/structure/shuttle/diag_wall/New()
	..()
	if(world.has_round_started())
		initialize()

/obj/structure/shuttle/diag_wall/Destroy()
	var/turf/T = get_turf(src)
	if(istype(T,/turf/space))
		T.dynamic_lighting = 0
	..()

/obj/structure/shuttle/diag_wall/forceMove(atom/destination, step_x = 0, step_y = 0, no_tp = FALSE, harderforce = FALSE, glide_size_override = 0)
	var/turf/T = get_turf(src)
	if(istype(T,/turf/space))
		T.dynamic_lighting = 0
	..()
	T = get_turf(destination)
	if(T)
		T.dynamic_lighting = 1

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
