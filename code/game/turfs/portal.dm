/* Instant teleporter with vis_contents */

/turf/portal
	icon = 'icons/turf/space.dmi'
	icon_state = ""
	plane = ABOVE_TURF_PLANE
	invisibility = 0
	var/turf/target_turf
	var/teleport_x = 0	// teleportation coordinates
	var/teleport_y = 0
	var/teleport_z = 0

/turf/portal/Entered(var/atom/movable/mover)
	..()
	if(!mover)
		return
	if(istype(mover, /obj/effect/beam))//those things aren't meant to get moved
		return
	mover.Move(target_turf)

/turf/portal/initialize()
	..()
	update_icon()

/turf/portal/map_element_rotate(angle)
	..()
	if(angle == 180 || angle == 270)
		teleport_x *= -1
	if(angle == 180 || angle == 90)
		teleport_y *= -1
	update_icon()

/turf/portal/proc/update_teleport(x,y,z)
	teleport_x = x
	teleport_y = y
	teleport_z = z
	update_icon()

/turf/portal/update_icon()
	overlays.Cut()
	vis_contents.Cut()
	var/turf/temp_turf = locate(src.x+teleport_x,src.y+teleport_y,src.z+teleport_z)
	if(istype(temp_turf,/turf/portal))
		warning("Area portal ([src.x],[src.y],[src.z]) target turf is another area portal, ([src.x+teleport_x],[src.y+teleport_y],[src.z+teleport_z]) aborting targeting")
		return
	target_turf = temp_turf
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
