
/mob/living/Login()
	..()
	//Mind updates
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

	//login during ventcrawl
	if(is_ventcrawling && istype(loc, /obj/machinery/atmospherics)) //attach us back into the pipes
		remove_ventcrawl()
		add_ventcrawl(loc)

	//Round specific stuff like hud updates
	if(ticker && ticker.mode)
		switch(ticker.mode.name)
			if("sandbox")
				CanBuild()
		var/ref = "\ref[mind]"
		if(ref in ticker.mode.implanter)
			ticker.mode.update_traitor_icons_added(mind)
		if(mind in ticker.mode.implanted)
			ticker.mode.update_traitor_icons_added(mind)
		if((ref in ticker.mode.thralls) || (mind in ticker.mode.enthralled))
			ticker.mode.update_vampire_icons_added(mind)
		return
	return .