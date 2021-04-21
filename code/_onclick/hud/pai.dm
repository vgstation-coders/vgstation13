#define SCANNER 1

/mob/living/silicon/pai/regular_hud_updates()
	if(client)
		for(var/image/hud in client.images)
			if(findtext(hud.icon_state, "hud", 1, 4))
				client.images -= hud

#undef SCANNER

/datum/hud/proc/pai_hud()

	mymob.zone_sel = new /obj/abstract/screen/zone_sel
	mymob.zone_sel.icon = 'icons/mob/screen1_robot.dmi'
	mymob.zone_sel.overlays.len = 0
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	mymob.client.reset_screen()

	mymob.client.screen += list(mymob.zone_sel)
