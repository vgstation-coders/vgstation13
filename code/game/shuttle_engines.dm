/obj/structure/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'

/obj/structure/shuttle/window
	name = "shuttle window"
	icon = 'icons/obj/podwindows.dmi'
	icon_state = "1"
	density = 1
	opacity = 0
	anchored = 1

/obj/structure/shuttle/window/shuttle_rotate(angle) //WOW
	src.transform = turn(src.transform, angle)

/obj/structure/shuttle/window/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(!height || air_group)
		return 0
	else
		return ..()

/obj/structure/shuttle/engine
	name = "engine"
	density = 1
	anchored = 1.0

/obj/structure/shuttle/engine/heater
	name = "heater"
	icon_state = "heater"

/obj/structure/shuttle/engine/heater/cultify()
	new /obj/structure/cult/pylon(loc)
	..()

/obj/structure/shuttle/engine/platform
	name = "platform"
	icon_state = "platform"

/obj/structure/shuttle/engine/propulsion
	name = "propulsion"
	icon_state = "propulsion"
	opacity = 1

/obj/structure/shuttle/engine/propulsion/proc/shoot_exhaust()

	var/turf/target = get_edge_target_turf(src,dir)
	var/turf/T = get_turf(src)
	var/obj/item/projectile/A = new /obj/item/projectile/fire_breath/shuttle_exhaust(T)

	for(var/i=0, i<2, i++)
		A.original = target
		A.starting = T
		A.shot_from = src
		A.current = T
		A.yo = target.y - T.y
		A.xo = target.x - T.x
		A.OnFired()
		spawn()
			A.process()

		target = get_edge_target_turf(src,reverse_direction(dir))
		sleep(6)
		A = new /obj/item/projectile/fire_breath/shuttle_exhaust(T)

/obj/structure/shuttle/engine/propulsion/left
	icon_state = "propulsion_l"

/obj/structure/shuttle/engine/propulsion/right
	icon_state = "propulsion_r"


/obj/structure/shuttle/engine/propulsion/cultify()
	var/turf/T = get_turf(src)
	if(T)
		T.ChangeTurf(/turf/simulated/wall/cult)
	..()

/obj/structure/shuttle/engine/propulsion/burst
	name = "burst"

/obj/structure/shuttle/engine/propulsion/burst/left
	icon_state = "burst_l"

/obj/structure/shuttle/engine/propulsion/burst/right
	icon_state = "burst_r"

/obj/structure/shuttle/engine/router
	name = "router"
	icon_state = "router"
