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
	var/exhaust_type = /obj/item/projectile/fire_breath/shuttle_exhaust

/obj/structure/shuttle/engine/heater/DIY
	name = "shuttle engine pre-igniter"
	var/obj/structure/shuttle/engine/propulsion/DIY/connected_engine
	anchored = FALSE
	
/obj/structure/shuttle/engine/heater/DIY/proc/try_connect()
	if(!anchored) 
		desc = initial(desc)
		return FALSE
	disconnect()
	
	for(var/obj/structure/shuttle/engine/propulsion/DIY/D in range(1,src))
		if(D.anchored && !D.heater && D.dir == dir && D.loc == get_step(src,dir))
			D.heater = src
			connected_engine = D
			desc += " It is connected to an engine." // have to do both, because only one of the parts' try_connect()s runs
			D.desc = initial(D.desc) + " It is connected to a preheater."
			return TRUE
	desc = initial(desc)
	return FALSE
	
/obj/structure/shuttle/engine/heater/DIY/proc/disconnect()
	if(connected_engine)
		connected_engine.heater = null // prevent infinite recursion and subsequent serb CPU fire
		connected_engine.disconnect()
	connected_engine = null
	src.desc = initial(src.desc)
			
/obj/structure/shuttle/engine/heater/DIY/attackby(obj/item/I, mob/user)
	if(I.is_wrench(user) && wrenchAnchor(user, I, 5 SECONDS))
		return TRUE			
	return ..()

/obj/structure/shuttle/engine/heater/DIY/canAffixHere(var/mob/user)
	if(src.anchored) // always allow unbolting, a la don't bug out if someone removes the engine
		return ..()
	for(var/obj/structure/shuttle/engine/propulsion/DIY/D in range(1,src))
		if(D.anchored && !D.heater && D.dir == dir && D.loc == get_step(src,dir))
			return ..()
	to_chat(user, "<span class = 'warning'>There is no engine within range of \the [src] it can connect to.</span>")
	return FALSE
	
/obj/structure/shuttle/engine/heater/DIY/wrenchAnchor(var/mob/user, var/obj/item/I, var/obj/item/I, var/time_to_wrench = 3 SECONDS)
	.=..()
	if(.)
		if(!anchored)
			disconnect()
		else if(!connected_engine)
			try_connect()



/obj/structure/shuttle/engine/propulsion/DIY
	name = "shuttle engine"
	var/obj/structure/shuttle/engine/heater/DIY/heater = null
	anchored = FALSE
	
/obj/structure/shuttle/engine/propulsion/DIY/proc/disconnect()
	if(heater)
		heater.disconnect()
	heater = null
	desc = initial(desc)
	
/obj/structure/shuttle/engine/propulsion/DIY/proc/try_connect()
	if(!anchored)
		desc = initial(desc)
		return FALSE
	disconnect()
	for(var/obj/structure/shuttle/engine/heater/DIY/D in range(1,src))
		if(D.anchored && !D.connected_engine && D.dir == dir && loc == get_step(D,D.dir))
			heater = D
			D.connected_engine = src
			desc += " It is connected to a preheater."
			D.desc = initial(D.desc) + " It is connected to an engine."
			return TRUE
	desc = initial(desc)
	return FALSE
	
// find and rectify black-swan type weirdness, i.e. varedit / singuloo unanchoring the engine parts or a push wizard teleporting them away
// the shuttle should NOT work if one of the heaters has been magicked halfway across the station, so check for it!
/obj/structure/shuttle/engine/propulsion/DIY/proc/retard_checks()
	if(!heater) // no point disconnecting if there is no heater
		return
	if(!heater.anchored || anchored) // we've somehow gotten unanchored
		disconnect()
		return
	if(loc != get_step(heater,heater.dir)) // we're not next to the heater anymore
		disconnect()
		return
		
/obj/structure/shuttle/engine/propulsion/DIY/attackby(obj/item/I, mob/user)
	if(I.is_wrench(user))
		return wrenchAnchor(user, I, 5 SECONDS)
	return ..()

/obj/structure/shuttle/engine/propulsion/DIY/wrenchAnchor(var/mob/user, var/obj/item/I, var/obj/item/I, var/time_to_wrench = 3 SECONDS)
	.=..()
	if(.)
		if(!anchored)
			disconnect()
		else if(!heater)
			try_connect()

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

/obj/structure/shuttle/engine/propulsion/proc/shoot_exhaust(forward=9, backward=9, var/turf/source_turf)
	if(!anchored)
		return
	var/turf/target = get_edge_target_turf(src,dir)
	var/turf/T = source_turf
	if (!T)
		T = get_turf(src)
	var/obj/item/projectile/fire_breath/A = new exhaust_type(T)
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
		A = new exhaust_type(T)
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

// -- NRV HORIZON --

var/ship_has_power = TRUE
var/list/large_engines = list()

/obj/structure/shuttle/engine/propulsion/horizon
	var/largeness = 0 // How much extra turfs we are on.

	plane = EFFECTS_PLANE
	layer = HORIZON_EXHAUST_LAYER
	exhaust_type = /obj/item/projectile/fire_breath/shuttle_exhaust/horizon

/obj/structure/shuttle/engine/propulsion/horizon/New()
	. = ..()
	large_engines += src

/obj/structure/shuttle/engine/propulsion/horizon/Destroy()
	large_engines -= src
	. = ..()

// Calls the parents on all the turfs we occupy.
/obj/structure/shuttle/engine/propulsion/horizon/shoot_exhaust(forward=9, backward=9, var/turf/source_turf)
	for (var/dx = 0 to largeness)
		spawn()
			var/turf/T = locate(src.x + dx, src.y, src.z)
			..(forward, backward, T)

/obj/structure/shuttle/engine/propulsion/horizon/large_engine
	bound_height = 64
	bound_width = 64
	icon = 'icons/2x2.dmi'
	icon_state = "large_engine"
	largeness = 1

/obj/structure/shuttle/engine/propulsion/horizon/huge_engine
	bound_height = 96
	bound_width = 96
	icon = 'icons/3x3.dmi'
	icon_state = "huge_engine"
	largeness = 2
