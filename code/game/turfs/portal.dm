/turf/portal
	name = "area portal"
	icon = 'icons/turf/space.dmi'
	icon_state = ""
	density = 0
	plane = OPENSPACE_PLANE
	dynamic_lighting = 0

    // Target coords to render
	var/px = 1
    var/py = 1
    var/pz = 1
    var/turf/target_turf

/turf/portal/post_change()
	..()
	update()

/turf/portal/initialize()
	..()
	update()

/turf/portal/Entered(var/atom/movable/mover)
	..()
    mover.forceMove(target_turf)

/turf/portal/proc/update()
    target_turf = locate(px,py,pz)
	levelupdate()
    for(var/atom/movable/A in src)
        A.forceMove(target_turf)
    update_icon()

// override to make sure nothing is hidden
/turf/portal/levelupdate()
	for(var/obj/O in src)
		O.hide(0)

/turf/portal/update_icon()
	overlays.Cut()
	vis_contents.Cut()
	vis_contents += target_turf

/turf/portal/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 1)
	overlays.Cut()
	vis_contents.Cut()
	..()

// Debug verbs.
/client/proc/update_all_area_portals()
	set category = "Debug"
	set name = "Update area portals"
	set desc = "Force all area portal turfs to update"

	if (!holder)
		return

	for(var/turf/portal/P in world)
        P.target_turf = locate(P.px,P.py,P.pz)
		P.update_icon()
		for(var/atom/movable/A in P)
			A.forceMove(P.target_turf)

	message_admins("Admin [key_name_admin(usr)] forced area portals to update.")