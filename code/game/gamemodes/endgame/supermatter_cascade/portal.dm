/*** EXIT PORTAL ***/

/obj/machinery/singularity/narsie/large/exit
	name = "Bluespace Rift"
	desc = "NO TIME TO EXPLAIN, JUMP IN"
	icon = 'icons/obj/rift.dmi'
	icon_state = "rift"
	move_self = FALSE
	announce = FALSE
	narnar = FALSE
	layer = SUPER_PORTAL_LAYER
	consume_range = 12

/obj/machinery/singularity/narsie/large/exit/New()
	..()
	processing_objects.Add(src)

/obj/machinery/singularity/narsie/large/exit/update_icon()
	overlays.Cut()

/obj/machinery/singularity/narsie/large/exit/process()
	for(var/mob/M in player_list)
		if(M.client)
			M.see_rift(src)
	eat()

/obj/machinery/singularity/narsie/large/exit/acquire(var/mob/food)
	return

/obj/machinery/singularity/narsie/large/exit/consume(const/atom/A)

	if (istype(A, /mob/living/))
		var/mob/living/L = A
		if(L.locked_to && istype(L.locked_to,/obj/structure/bed/))
			var/turf/O = L.locked_to
			do_teleport(O, pick(endgame_safespawns), aijamming=TRUE)
			L.forceMove(O.loc)
		else
			do_teleport(L, pick(endgame_safespawns), aijamming=TRUE) //dead-on precision

	else if (istype(A, /obj/mecha/))
		do_teleport(A, pick(endgame_safespawns), aijamming=TRUE) //dead-on precision

	else if (isturf(A))
		var/turf/T = A
		var/dist = get_dist(T, src)
		if (dist <= consume_range && T.density)
			T.setDensity(FALSE)

		for (var/atom/movable/AM in T.contents)
			if (AM == src) // This is the snowflake.
				continue

			if (dist <= consume_range)
				consume(AM)
				continue

			if (dist > consume_range && canPull(AM))

				if (101 == AM.invisibility)
					continue

				spawn (0)
					step_towards(AM, src)
