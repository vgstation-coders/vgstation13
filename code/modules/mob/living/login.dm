
/mob/living/Login()
	..()
	standard_damage_overlay_updates()

	//Mind updates
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

	ResendAllUIs() // Re-sends mind UIs
	INVOKE_EVENT(src, /event/living_login, "user" = src)

	//login during ventcrawl
	if(is_ventcrawling && istype(loc, /obj/machinery/atmospherics)) //attach us back into the pipes
		remove_ventcrawl()
		add_ventcrawl(loc)

	if(iscultist(src) && hud_used && !hud_used.cult_Act_display)
		hud_used.cult_hud()

	// Register as something able to receive sounds from sound_emitters
	if (sound_zone_manager)
		sound_zone_manager.register_listener(src)

	//Round specific stuff like hud updates
	if(ticker && ticker.mode)
		switch(ticker.mode.name)
			if("sandbox")
				CanBuild()

		if (hasFactionIcons(src))
			update_faction_icons()
	
	if(virus2.len)
		for(var/ID in virus2)
			var/datum/disease2/disease/V = virus2[ID]
			for(var/datum/disease2/effect/e in V.effects)
				if(e.count > 0 && e.type == /datum/disease2/effect/loneliness)
					e.side_effect(src)
					return
