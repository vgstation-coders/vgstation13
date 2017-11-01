/obj/abstract/mover
	icon = 'icons/obj/map/movers.dmi'
	alpha = 255
	invisibility = 101
	mouse_opacity = 0

/obj/abstract/mover/transporter
	icon_state = "transporter"
	dir = SOUTH
	var/atom/movable/host
	var/moving = FALSE
	var/step_delay = 1

/obj/abstract/mover/transporter/Destroy()
	stop_moving()
	host = null
	processing_objects.Remove(src)
	..()

/obj/abstract/mover/transporter/process()
	if(host && host.gcDestroyed)
		qdel(src)

/obj/abstract/mover/transporter/New()
	..()
	spawn(5)
		if(acquire_host())
			forceMove(host)
			processing_objects.Add(src)
			start_moving()
			return
		qdel(src)

/obj/abstract/mover/transporter/proc/acquire_host()
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in T.contents)
		if(!(isrealobject(AM) || isliving(AM)))
			continue
		if(istype(AM, /obj/abstract/mover))
			continue
		host = AM
		return TRUE
	return FALSE

/obj/abstract/mover/transporter/mob/acquire_host()
	var/turf/T = get_turf(src)
	for(var/mob/living/M in T.contents)
		host = M
		return TRUE
	return FALSE

/obj/abstract/mover/transporter/obj/acquire_host()
	var/turf/T = get_turf(src)
	for(var/obj/O in T.contents)
		if(!isrealobject(O))
			continue
		host = O
		return TRUE
	return FALSE

/obj/abstract/mover/transporter/proc/start_moving()
	moving = TRUE
	move_loop()

/obj/abstract/mover/transporter/proc/stop_moving()
	moving = FALSE

/obj/abstract/mover/transporter/proc/move_loop()
	if(!host)
		qdel(src)
		return
	while(moving)
		step(host, dir)
		sleep(step_delay)

/obj/abstract/mover/redirector
	icon_state = "redirector"

/obj/abstract/mover/redirector/Crossed(atom/movable/AM)
	for(var/obj/abstract/mover/transporter/T in AM.contents)
		T.dir = dir

/obj/abstract/mover/redirector/north
	dir = NORTH

/obj/abstract/mover/redirector/south
	dir = SOUTH

/obj/abstract/mover/redirector/east
	dir = EAST

/obj/abstract/mover/redirector/west
	dir = WEST

/obj/abstract/mover/redirector/northeast
	dir = NORTHEAST

/obj/abstract/mover/redirector/southeast
	dir = SOUTHEAST

/obj/abstract/mover/redirector/northwest
	dir = NORTHWEST

/obj/abstract/mover/redirector/southwest
	dir = SOUTHWEST

/obj/abstract/mover/speed_adjuster
	icon_state = "speed_adjuster"
	var/step_delay = 1

/obj/abstract/mover/speed_adjuster/Crossed(atom/movable/AM)
	for(var/obj/abstract/mover/transporter/T in AM.contents)
		T.step_delay = step_delay
