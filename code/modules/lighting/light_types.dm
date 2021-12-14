/atom/movable/light/moody
	icon = 'icons/lighting/special.dmi'
	glide_size = 8 // Don't ask me why. It breaks gliding otherwise.
	appearance_flags = KEEP_TOGETHER|TILE_BOUND
	var/overlay_state

/atom/movable/light/moody/apc
	overlay_state = "_apc"

/atom/movable/light/moody/beam
	overlay_state = "_beam"

/atom/movable/light/moody/light_switch
	overlay_state = "_lightswitch"

/atom/movable/light/moody/statusdisplay
	overlay_state = "_statusdisplay"

/atom/movable/light/moody/morgue
	overlay_state = "_morgue"

/atom/movable/light/moody/holomap
	overlay_state = "_holomap"
