/mob/living/silicon/robot/mommi/handle_regular_hud_updates()
	. = ..()
	if(!can_see_static()) //what lets us avoid the overlay
		if(static_overlays && static_overlays.len)
			remove_static_overlays()

