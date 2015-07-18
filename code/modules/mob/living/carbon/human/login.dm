/mob/living/carbon/human/Login()
	..()
	update_hud()
	ticker.mode.update_all_antag_icons(ticker.mode.syndicates, "synd")	//This proc only sounds CPU-expensive on paper. It is O(n^2), but the outer for-loop only iterates through syndicates, which are only prsenet in nuke rounds and even when they exist, there's usually 6 of them.
	return
