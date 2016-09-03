/mob/Logout()
	if (isobj(loc))
		var/obj/location = loc
		location.on_logout(src)

	if((flags & HEAR) && !(flags & HEAR_ALWAYS))
		for(var/mob/virtualhearer/VH in virtualhearers)
			if(VH.attached == src)
				returnToPool(VH)
	world.log << "[src] logout"

	remove_spell_channeling() //remove spell channeling before we log out

	nanomanager.user_logout(src) // this is used to clean up (remove) this user's Nano UIs

	player_list -= src

	log_access("Logout: [key_name(src)] ([formatLocation(loc)])")

	remove_screen_objs() //Used to remove hud elements

	if(admin_datums[src.ckey])
		if (ticker && ticker.current_state == GAME_STATE_PLAYING) //Only report this stuff if we are currently playing.
			var/admins_number = admins.len
			var/admin_number_afk = 0
			for(var/client/X in admins)
				if(X.is_afk())
					admin_number_afk++

			var/available_admins = admins_number - admin_number_afk

			message_admins("Admin logout: [key_name(src)]")
			if(available_admins == 0) // Apparently the admin logging out is no longer an admin at this point, so we have to check this towards 0 and not towards 1. Awell.
				send2adminirc("[key_name(src)] logged out - no more admins online.")
				send2admindiscord("[key_name(src)] logged out. **No more non-AFK admins online.** - **[admin_number_afk]** AFK", TRUE)

	INVOKE_EVENT(on_logout, list())

	..()
