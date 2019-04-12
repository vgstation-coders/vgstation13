/obj/effect/portal
	name = "portal"
	desc = "Looks stable, but still, best to test it with the clown first."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal0"
	var/mask = "portal_mask"
	var/open_sound = 'sound/effects/portal_open.ogg'
	var/close_sound = 'sound/effects/portal_close.ogg'
	var/enter_sound = 'sound/effects/portal_enter.ogg'
	var/exit_sound = 'sound/effects/portal_exit.ogg'
	density = 0
	var/obj/target = null
	var/obj/item/weapon/creator = null
	var/mob/owner = null
	anchored = 1.0
	w_type=NOT_RECYCLABLE
	var/undergoing_deletion = 0
	var/atmos_connected = FALSE
	var/connection/atmos_connection

	var/list/exit_beams = list()

/obj/effect/portal/attack_hand(var/mob/user, params, proximity)
	if(proximity)
		spawn()
			src.teleport(user)

/obj/effect/portal/attackby(obj/item/weapon/O as obj, mob/user as mob)
	if(O == creator)
		to_chat(user, "<span class='warning'>You close the portal prematurely.</span>")
		qdel(src)
	else
		spawn()
			src.teleport(user)
/*
/obj/effect/portal/Bumped(mob/M as mob|obj)
	spawn()
		src.teleport(M)
*/
/obj/effect/portal/Crossed(AM as mob|obj,var/no_tp=0)
	if(no_tp)
		return
	if(istype(AM,/obj/item/projectile/beam))
		var/obj/item/projectile/beam/B = AM
		B.wait = 1
	spawn()
		teleport(AM)

/obj/effect/portal/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover,/obj/effect/beam))
		return 0
	else
		return ..()

/obj/effect/portal/New(turf/loc,var/lifespan=300)
	..()
	playsound(loc,open_sound,60,1)

	var/area/A = get_area(src)
	if(A.flags & NO_PORTALS)
		visible_message("<span class='notice'>\The [src] dissipates into thin air.</span>")
		target = null
		qdel(src)
		return

	spawn(5)
		connect_atmospheres()

	make_lifespan(lifespan)

/obj/effect/portal/proc/make_lifespan(var/lifespan)
	spawn(lifespan)
		qdel(src)

/obj/effect/portal/proc/connect_atmospheres()
	if(!atmos_connected)
		if(target)
			if(istype(target, /obj/effect/portal))
				var/obj/effect/portal/P = target
				if(get_turf(src) && get_turf(P))
					var/valid_connection = FALSE
					if(SSair.has_valid_zone(get_turf(src)))
						atmos_connection = new (get_turf(src), get_turf(P))
						valid_connection = TRUE
					if(SSair.has_valid_zone(get_turf(P)))
						P.atmos_connection = new (get_turf(P), get_turf(src))
						valid_connection = TRUE
					if(valid_connection)
						P.atmos_connected = TRUE
						atmos_connected = TRUE

/obj/effect/portal/proc/disconnect_atmospheres()
	atmos_connected = FALSE
	if(atmos_connection)
		atmos_connection.erase()
		atmos_connection = null

/obj/effect/portal/Destroy()
	if(undergoing_deletion)
		return
	undergoing_deletion = 1
	playsound(loc,close_sound,60,1)
	disconnect_atmospheres()

	purge_beams()
	owner = null
	if(target)
		if(istype(target,/obj/effect/portal) && !istype(creator,/obj/item/weapon/gun/portalgun))
			qdel(target)
		target = null
	if(creator)
		if(istype(creator,/obj/item/weapon/hand_tele))
			var/obj/item/weapon/hand_tele/H = creator
			H.portals -= src
			creator = null
		else if(istype(creator,/obj/item/weapon/gun/portalgun))
			var/obj/item/weapon/gun/portalgun/P = creator
			if(src == P.blue_portal)
				P.blue_portal = null
				P.sync_portals()
			else if(src == P.red_portal)
				P.red_portal = null
				P.sync_portals()
	spark(loc, 5)
	..()

/obj/effect/portal/cultify()
	return

/obj/effect/portal/singularity_act()
	return

/obj/effect/portal/singularity_pull()
	return

var/list/portal_cache = list()


/obj/effect/portal/proc/blend_icon(var/obj/effect/portal/P)
	var/turf/T = P.loc

	if(!("icon[initial(T.icon)]_iconstate[T.icon_state]_[type]" in portal_cache))//If the icon has not been added yet
		var/icon/I1 = icon(icon,mask)//Generate it.
		var/icon/I2 = icon(initial(T.icon),T.icon_state)
		I1.Blend(I2,ICON_MULTIPLY)
		portal_cache["icon[initial(T.icon)]_iconstate[T.icon_state]_[type]"] = I1 //And cache it!

	overlays += portal_cache["icon[initial(T.icon)]_iconstate[T.icon_state]_[type]"]

/obj/effect/portal/proc/teleport(atom/movable/M as mob|obj)
	if(istype(M, /obj/effect)) //sparks don't teleport
		return
	if (M.anchored && !istype(M, /obj/mecha) && !istype(M, /obj/item/projectile))
		return
	if (!target)
		visible_message("<span class='warning'>The portal fails to find a destination and dissipates into thin air.</span>")
		qdel(src)
		return
	if (istype(M, /atom/movable))
		var/area/A = get_area(target)
		if(A && A.anti_ethereal)
			visible_message("<span class='sinister'>A dark form vaguely ressembling a hand reaches through the portal and tears it apart before anything can go through.</span>")
			qdel(src)
		else
			do_teleport(M, target, 0, 1, 1, 1, enter_sound, exit_sound)
			if(ismob(M))
				var/mob/target = M
				if(target.mind && owner)
					log_attack("[target.name]([target.ckey]) entered a portal made by [owner.name]([owner.ckey]) at [loc]([x],[y],[z]), exiting at [target.loc]([target.x],[target.y],[target.z]).")

/obj/effect/portal/beam_connect(var/obj/effect/beam/B)
	if(istype(B))
		if(B.HasSource(src))
			return // Prevent infinite loops.
		..()
	handle_beams()

/obj/effect/portal/beam_disconnect(var/obj/effect/beam/B)
	if(istype(B))
		if(B.HasSource(src))
			return // Prevent infinite loops.
		..()
	handle_beams()

/obj/effect/portal/handle_beams()
	if(target && istype(target,/obj/effect/portal))
		var/obj/effect/portal/PE = target
		PE.purge_beams()

	add_beams()

/obj/effect/portal/proc/purge_beams()
	for(var/obj/effect/beam/BE in exit_beams)
		exit_beams -= BE
		qdel(BE)

/obj/effect/portal/proc/add_beams()
	if((!beams) || (!beams.len) || !target || !istype(target,/obj/effect/portal))
		return

	var/obj/effect/portal/PE = target

	for(var/obj/effect/beam/emitter/BE in beams)
		var/list/spawners = list(src)
		spawners |= BE.sources
		var/obj/effect/beam/emitter/beam = new(PE.loc)
		beam.dir = BE.dir
		beam.power = BE.power
		beam.steps = BE.steps+1
		beam.emit(spawn_by=spawners)
		PE.exit_beams += beam

/obj/effect/portal/tear
	name = "tear in space"
	desc = "This probably isn't supposed to be here."
	icon_state = "tear"
	mask = "tear_mask"
	open_sound = 'sound/weapons/bloodyslice.ogg'
	close_sound = 'sound/weapons/electriczap.ogg'
	enter_sound = 'sound/effects/fall2.ogg'
	exit_sound = 'sound/effects/fall2.ogg'


/obj/effect/portal/permanent
	name = "stabilized portal"
	desc = "The event horizon is held through magnetic forces, and potentially duct tape."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "tele1"

/obj/effect/portal/permanent/make_lifespan()
	return
