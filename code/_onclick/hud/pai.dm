#define SCANNER 1

/mob/living/silicon/pai/regular_hud_updates()
	if(client)
		for(var/image/hud in client.images)
			if(findtext(hud.icon_state, "hud", 1, 4))
				client.images -= hud

/mob/living/silicon/pai/proc/RoundHealth(health)
	switch(health)
		if(100 to INFINITY)
			return "health100"
		if(70 to 100)
			return "health80"
		if(50 to 70)
			return "health60"
		if(30 to 50)
			return "health40"
		if(20 to 30)
			return "health25"
		if(5 to 15)
			return "health10"
		if(1 to 5)
			return "health1"
		if(-99 to 0)
			return "health0"
		else
			return "health-100"
	return "0"

#undef SCANNER

/datum/hud/proc/pai_hud()

	mymob.zone_sel = getFromPool(/obj/abstract/screen/zone_sel)
	mymob.zone_sel.icon = 'icons/mob/screen1_robot.dmi'
	mymob.zone_sel.overlays.len = 0
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	mymob.client.reset_screen()

	mymob.client.screen += list(mymob.zone_sel)
