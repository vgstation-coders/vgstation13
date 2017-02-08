
//UPDATE TRIGGERS, when the chunk (and the surrounding chunks) should update.

// TURFS

/turf
	var/image/obscured

/turf/proc/visibilityChanged()
	if(ticker)
		cameranet.updateVisibility(src)

/turf/simulated/Destroy()
	visibilityChanged()
	..()

/turf/simulated/New()
	..()
	visibilityChanged()



// STRUCTURES

/obj/structure/Destroy()
	if(ticker)
		cameranet.updateVisibility(src)
	..()

/obj/structure/New()
	..()
	if(ticker)
		cameranet.updateVisibility(src)

// EFFECTS

/obj/effect/Destroy()
	if(ticker)
		cameranet.updateVisibility(src)
	..()

/obj/effect/New()
	..()
	if(ticker)
		cameranet.updateVisibility(src)


// DOORS

// Simply updates the visibility of the area when it opens/closes/destroyed.
/obj/machinery/door/proc/update_freelok_sight()
	// Glass door glass = 1
	// don't check then?
	if(!glass && cameranet)
		cameranet.updateVisibility(src, 0)

// CAMERA

// An addition to deactivate which removes/adds the camera from the chunk list based on if it works or not.

/obj/machinery/camera/deactivate(user as mob, var/choice = 1)
	..(user, choice)
	if(src.can_use())
		cameranet.addCamera(src)
	else
		src.set_light(0)
		cameranet.removeCamera(src)

/obj/machinery/camera/New()
	..()
	cameranet.cameras += src
	cameranet.addCamera(src)

/obj/machinery/camera/Destroy()
	cameranet.cameras -= src
	cameranet.removeCamera(src)
	..()

#undef BORG_CAMERA_BUFFER