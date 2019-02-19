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
	new /obj/structure/cult_legacy/pylon(loc)
	..()

/obj/structure/shuttle/engine/platform
	name = "platform"
	icon_state = "platform"

/obj/structure/shuttle/engine/propulsion
	name = "propulsion"
	icon_state = "propulsion"
	opacity = 1

/obj/structure/shuttle/engine/heater/DIY
	name = "shuttle engine pre-igniter"
	var/obj/structure/shuttle/engine/propulsion/DIY/connected_engine
	anchored = FALSE

/obj/structure/shuttle/engine/heater/DIY/attackby(obj/item/I, mob/user)
	if(iswrench(I) && wrenchAnchor(user, 5 SECONDS))
		if(!anchored)
			if(connected_engine)
				connected_engine.heater = null
				connected_engine = null
		else
			for(var/obj/structure/shuttle/engine/propulsion/DIY/D in range(1,src))
				if(!D.heater)
					D.heater = src
					connected_engine = D
					break
	return ..()

/obj/structure/shuttle/engine/heater/DIY/canAffixHere(var/mob/user)
	var/success = FALSE
	for(var/obj/structure/shuttle/engine/propulsion/DIY/D in range(1,src))
		if(!D.heater)
			success = TRUE
			break
	if(!success)
		to_chat(user, "<span class = 'warning'>There is no engine within range of \the [src] it can connect to.</span>")
		return FALSE
	return ..()

/obj/structure/shuttle/engine/propulsion/DIY
	name = "shuttle engine"
	var/obj/structure/shuttle/engine/heater/DIY/heater = null
	anchored = FALSE

/obj/structure/shuttle/engine/propulsion/DIY/attackby(obj/item/I, mob/user)
	if(iswrench(I))
		return wrenchAnchor(user, 5 SECONDS)
	return ..()

/obj/structure/shuttle/engine/propulsion/DIY/wrenchAnchor(var/mob/user, var/time_to_wrench = 3 SECONDS)
	.=..()
	if(.)
		if(!anchored && heater)
			heater.connected_engine = null
			heater = null

/obj/structure/shuttle/engine/propulsion/DIY/canAffixHere(var/mob/user)
	var/turf/T = get_step(src, dir)
	if(!istype(T, /turf/space))
		to_chat(user, "<span class = 'warning'>\The [src] must be facing and bordering space to be affixed.</span>")
		return FALSE
	for(var/obj/O in loc)
		if(O.flow_flags & ON_BORDER && dir == O.dir)
			to_chat(user, "<span class = 'warning''>\The [O] is blocking engine flow to space.</span>")
			return FALSE
	return ..()

/obj/structure/shuttle/engine/propulsion/DIY/verb/rotate_cw()
	set src in view(1)
	set name = "Rotate suspension gen (Clockwise)"
	set category = "Object"

	if(anchored)
		to_chat(usr, "<span class='warning'>You cannot rotate [src], it has been firmly fixed to the floor.</span>")
	else
		dir = turn(dir, -90)

/obj/structure/shuttle/engine/propulsion/DIY/verb/rotate_ccw()
	set src in view(1)
	set name = "Rotate suspension gen (Counter-Clockwise)"
	set category = "Object"

	if(anchored)
		to_chat(usr, "<span class='warning'>You cannot rotate [src], it has been firmly fixed to the floor.</span>")
	else
		dir = turn(dir, 90)

/obj/structure/shuttle/engine/propulsion/DIY/AltClick(mob/user)
	if(Adjacent(user))
		return rotate_cw()
	return ..()

/obj/structure/shuttle/engine/propulsion/DIY/ShiftClick(mob/user)
	if(Adjacent(user))
		return rotate_ccw()
	return ..()

/obj/structure/shuttle/engine/propulsion/proc/shoot_exhaust(forward=9, backward=9)
	if(!anchored)
		return
	var/turf/target = get_edge_target_turf(src,dir)
	var/turf/T = get_turf(src)
	var/obj/item/projectile/fire_breath/A = new /obj/item/projectile/fire_breath/shuttle_exhaust(T)
	A.max_range = forward

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
		A.max_range = backward

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
