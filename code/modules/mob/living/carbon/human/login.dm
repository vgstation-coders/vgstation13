/mob/living/carbon/human/Login()
	..()
	update_hud()
	handle_regular_hud_updates()
	//ticker.mode.update_all_synd_icons()	//This proc only sounds CPU-expensive on paper. It is O(n^2), but the outer for-loop only iterates through syndicates, which are only present in nuke rounds and even when they exist, there's usually 6 of them.
	return
