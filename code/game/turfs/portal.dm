/* Instant teleporter with vis_contents */

/turf/portal
	icon = 'icons/turf/space.dmi'
	icon_state = ""
	plane = ABOVE_TURF_PLANE
	invisibility = 0
	relative = TRUE
	affect_ghosts = TRUE
	var/turf/target_turf
	var/teleport_x = 0	// teleportation coordinates
	var/teleport_y = 0
	var/teleport_z = 0
	var/affect_ghosts = 0

/turf/portal/Entered(var/atom/movable/mover)
	..()
	if(!mover)
		return
	if(istype(mover, /mob/dead/observer) && !affect_ghosts)
		return
	if(istype(mover, /obj/effect/beam))//those things aren't meant to get moved
		return
	mover.forceMove(target_turf)

/turf/portal/initialize()
	..()
	update_icon()

/turf/portal/update_icon()
	overlays.Cut()
	vis_contents.Cut()
	if(relative)
		target_turf = locate(src.x+teleport_x,src.y+teleport_y,src.z+teleport_z)
	else
		if(teleport_x && teleport_y && teleport_z)
			target_turf = locate(teleport_x,teleport_y,teleport_z)
	vis_contents += target_turf

/turf/portal/ex_act(severity)
	if(target_turf)
		target_turf.ex_act(severity)
		for(var/atom/movable/A in target_turf)
			A.ex_act(severity)

/turf/portal/emp_act(severity)
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

	for(var/turf/portal/P in world)
		P.update_icon()
		for(var/atom/movable/A in P.loc)
			P.Crossed(A)

	message_admins("Admin [key_name_admin(usr)] forced area portals to update.")