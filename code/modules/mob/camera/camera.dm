// Camera mob, used by AI camera and blob.

/mob/camera
	name = "camera mob"
	density = 0
	status_flags = GODMODE  // You can't damage it.
	mouse_opacity = 0
	see_in_dark = 7
	invisibility = 101 // No one can see us
	flags = HEAR | PROXMOVE | TIMELESS

/mob/camera/can_shuttle_move()
	return 0

/mob/camera/cultify()
	return

