/mob/living/carbon/human/Login()
	..()
	update_hud()
	handle_regular_hud_updates()
	ticker.mode.update_all_synd_icons()	//This proc only sounds CPU-expensive on paper. It is O(n^2), but the outer for-loop only iterates through syndicates, which are only prsenet in nuke rounds and even when they exist, there's usually 6 of them.
	if(get_item_by_slot(slot_glasses) && istype(get_item_by_slot(slot_glasses), /obj/item/clothing/glasses/scanner) && get_item_by_slot(slot_glasses).on)
		sleep(51) // janky way of getting around the update_colour() called in mob/Login()
		get_item_by_slot(slot_glasses).apply_color(src)
