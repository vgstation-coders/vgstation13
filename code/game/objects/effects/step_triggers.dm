/* Simple object type, calls a proc when "stepped" on by something */

/obj/effect/step_trigger
	var/affect_ghosts = 0
	var/stopper = 1 // stops throwers
	invisibility = 101 // nope cant see this shit
	anchored = 1
	w_type=NOT_RECYCLABLE

/obj/effect/step_trigger/proc/Trigger(var/atom/movable/A)
	return 0

/obj/effect/step_trigger/Crossed(H as mob|obj)
	..()
	if(!H)
		return
	if(istype(H, /mob/dead/observer) && !affect_ghosts)
		return
	if(istype(H, /obj/effect/beam))//those things aren't meant to get moved
		return
	Trigger(H)



/* Tosses things in a certain direction */

/obj/effect/step_trigger/thrower
	icon = 'icons/effects/effects.dmi'
	icon_state = "arrows"
	var/direction = SOUTH // the direction of throw
	var/tiles = 3	// if 0: forever until atom hits a stopper
	var/immobilize = 1 // if nonzero: prevents mobs from moving while they're being flung
	var/speed = 1	// delay of movement
	var/facedir = 0 // if 1: atom faces the direction of movement
	var/nostop = 0 // if 1: will only be stopped by teleporters
	var/list/affecting = list()

	Trigger(var/atom/A)
		if(!A || !istype(A, /atom/movable) || isobserver(A))
			return
		var/atom/movable/AM = A
		var/curtiles = 0
		var/stopthrow = 0
		for(var/obj/effect/step_trigger/thrower/T in orange(2, src))
			if(AM in T.affecting)
				return

		if(ismob(AM))
			var/mob/M = AM
			if(immobilize)
				M.canmove = 0

		affecting.Add(AM)
		while(AM && !stopthrow)
			if(tiles)
				if(curtiles >= tiles)
					break
			if(AM.z != src.z)
				break

			curtiles++

			sleep(speed)

			// Calculate if we should stop the process
			if(!nostop)
				for(var/obj/effect/step_trigger/T in get_step(AM, direction))
					if(T.stopper && T != src)
						stopthrow = 1
			else
				for(var/obj/effect/step_trigger/teleporter/T in get_step(AM, direction))
					if(T.stopper)
						stopthrow = 1

			if(AM)
				var/predir = AM.dir
				step(AM, direction)
				if(!facedir)
					AM.dir = predir



		affecting.Remove(AM)

		if(ismob(AM))
			var/mob/M = AM
			if(immobilize)
				M.canmove = 1

/obj/effect/step_trigger/thrower/north
	dir = NORTH

/obj/effect/step_trigger/thrower/east
	dir = EAST

/obj/effect/step_trigger/thrower/west
	dir = WEST

/obj/effect/step_trigger/thrower/New()
	..()
	direction = dir

/* Stops things thrown by a thrower, doesn't do anything */

/obj/effect/step_trigger/stopper

/* Instant teleporter */

/obj/effect/step_trigger/teleporter
	var/teleport_x = 0	// teleportation coordinates (if one is null, then no teleport!)
	var/teleport_y = 0
	var/teleport_z = 0

	var/relative = FALSE // move relative to this position? (disabling moves to normal absolute coords)

/obj/effect/step_trigger/teleporter/Trigger(var/atom/movable/A)
	if(relative)
		A.x += teleport_x
		A.y += teleport_y
		A.z += teleport_z
	else
		if(teleport_x && teleport_y && teleport_z)
			A.x = teleport_x
			A.y = teleport_y
			A.z = teleport_z

/* Random teleporter, teleports atoms to locations ranging from teleport_x - teleport_x_offset, etc */

/obj/effect/step_trigger/teleporter/random
	var/teleport_x_offset = 0
	var/teleport_y_offset = 0
	var/teleport_z_offset = 0

/obj/effect/step_trigger/teleporter/random/Trigger(var/atom/movable/A)
	if(!istype(A))
		return
	if(istype(A,/obj/item/projectile/fire_breath/shuttle_exhaust))
		qdel(A)
		return
	if(relative)
		A.x += rand(teleport_x, teleport_x_offset)
		A.y += rand(teleport_y, teleport_y_offset)
		A.z += rand(teleport_z, teleport_z_offset)
	else
		if(teleport_x && teleport_y && teleport_z)
			if(teleport_x_offset && teleport_y_offset && teleport_z_offset)
				A.x = rand(teleport_x, teleport_x_offset)
				A.y = rand(teleport_y, teleport_y_offset)
				A.z = rand(teleport_z, teleport_z_offset)

/obj/effect/step_trigger/teleporter/random/shuttle_transit
	teleport_x = 25
	teleport_y = 25
	teleport_z = 6

	//x and y offsets depend on the map size

	teleport_z_offset = 6

/obj/effect/step_trigger/teleporter/random/shuttle_transit/New()
	..()
	teleport_x_offset = world.maxx - 25
	teleport_y_offset = world.maxy - 25

/* Instant teleporter with vis_contents */

/obj/effect/step_trigger/teleporter/portal
	icon = 'icons/turf/space.dmi'
	icon_state = ""
	plane = ABOVE_TURF_PLANE
	invisibility = 0
	relative = TRUE
	affect_ghosts = TRUE
	var/turf/target_turf

// Block gases for now
/obj/effect/step_trigger/teleporter/portal/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover))
		return ..()
	return FALSE

/obj/effect/step_trigger/teleporter/portal/initialize()
	..()
	update_icon()

/obj/effect/step_trigger/teleporter/portal/update_icon()
	overlays.Cut()
	vis_contents.Cut()
	if(relative)
		target_turf = locate(src.x+teleport_x,src.y+teleport_y,src.z+teleport_z)
	else
		if(teleport_x && teleport_y && teleport_z)
			target_turf = locate(teleport_x,teleport_y,teleport_z)
	vis_contents += target_turf

/obj/effect/step_trigger/teleporter/portal/ex_act(severity)
	if(target_turf)
		target_turf.ex_act(severity)
		for(var/atom/movable/A in target_turf)
			A.ex_act(severity)

/obj/effect/step_trigger/teleporter/portal/emp_act(severity)
	if(target_turf)
		target_turf.emp_act(severity)
		for(var/atom/movable/A in target_turf)
			A.emp_act(severity)

// Debug verbs.
/client/proc/update_all_area_portals()
	set category = "Debug"
	set name = "Update area portals"
	set desc = "Force all area portal turfs to update"

	if (!holder)
		return

	for(var/obj/effect/step_trigger/teleporter/portal/P in world)
		P.update_icon()
		for(var/atom/movable/A in P.loc)
			P.Trigger(A)

	message_admins("Admin [key_name_admin(usr)] forced area portals to update.")