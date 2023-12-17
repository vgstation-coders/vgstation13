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

/atom/movable/light/moody/tube
	overlay_state = "_light_tube"

/atom/movable/light/moody/bulb
	overlay_state = "_light_bulb"

/atom/movable/light/moody/full_turf
	overlay_state = "_turf"

/atom/movable/light/moody/paint_mask
	overlay_state = "_paintmask_"
