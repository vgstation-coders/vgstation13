//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
/mob/proc/update_Login_details()
	if(!client)
		WARNING("update_Login_details(): client for [src] is [client]!")
		message_admins("<span class='warning'><B>WARNING:</B> <A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has a null .client (BYOND issue, not malicious)!</span>", 1)

	else
		if(!client.address)
			WARNING("update_Login_details(): client.address for [src] is [client.address]!")
			message_admins("<span class='warning'><B>WARNING:</B> <A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has a null .client.address (BYOND issue, not malicious)!</span>", 1)
		if(!client.computer_id)
			WARNING("update_Login_details(): client.computer_id for [src] is [client.computer_id]!")
			message_admins("<span class='warning'><B>WARNING:</B> <A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has a null .client.computer_id (BYOND issue, not malicious)!</span>", 1)

	//Multikey checks and logging
	lastKnownIP	= client.address
	computer_id	= client.computer_id
	log_access("Login: [key_name(src)] from [lastKnownIP ? lastKnownIP : "localhost"]-[computer_id] || BYOND v[client.byond_version]")
	if(config.log_access)
		for(var/mob/M in player_list)
			if(M == src)
				continue
			if( M.key && (M.key != key) )
				var/matches
				var/matches_both = FALSE
				if( (M.lastKnownIP == client.address) )
					matches += "IP ([client.address])"
				if( (M.computer_id == client.computer_id) )
					if(matches)
						matches += " and "
						matches_both = TRUE
					matches += "ID ([client.computer_id])"
#if WARN_FOR_CLIENTS_SHARING_IP
					spawn() alert("You have logged in already with another key this round, please log out of this one NOW or risk being banned!")
#endif
				if(matches)
					message_admins("<font color='red'><B>Notice: </B><span class='notice'><A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has the same [matches] as <A href='?src=\ref[usr];priv_msg=\ref[M]'>[key_name_admin(M)]</A>[M.client ? "" : " (no longer logged in)"].</span>", 1)
					log_access("Notice: [key_name(src)] has the same [matches] as [key_name(M)][M.client ? "" : " (no longer logged in)"].")

				if(matches_both)
					var/admins_number = admins.len
					var/admin_number_afk = get_afk_admins()
					var/available_admins = admins_number - admin_number_afk
					//Dunno if it's okay to log IP or ID here
					send2adminirc("Notice: [key_name(src)] has the same IP and ID as [key_name(M)][M.client ? "" : " (no longer logged in)"].  [available_admins ? "" : "No non-AFK admins online"]")
					send2admindiscord("**Notice: [key_name(src)] has the same IP and ID as [key_name(M)][M.client ? "" : " (no longer logged in)"].  [available_admins ? "" : "No non-AFK admins online"]**", !available_admins)

// Do not call ..()
// If you do so and the mob is in nullspace BYOND will attempt to move the mob a gorillion times
// See http://www.byond.com/docs/ref/info.html#/mob/proc/Login and http://www.byond.com/forum/?post=2151126
/mob/Login()
	player_list |= src
	update_Login_details()
	world.update_status()

	if(hud_used)
		qdel(hud_used)		//remove the hud objects
	client.images = null				//remove the images such as AIs being unable to see runes

	if(spell_masters)
		for(var/obj/abstract/screen/movable/spell_master/spell_master in spell_masters)
			spell_master.toggle_open(1)
			client.screen -= spell_master

	client.reset_screen()				//remove hud items just in case
	hud_used = new /datum/hud(src)
	client.screen += catcher //Catcher of clicks
	client.screen += clickmaster // click catcher planesmaster on plane 0 with mouse opacity 0 - allows click catcher to work with SEE_BLACKNESS
	client.screen += clickmaster_dummy // honestly fuck you lummox
	client.initialize_ghost_planemaster() //We want to explicitly reset the planemaster's visibility on login() so if you toggle ghosts while dead you can still see cultghosts if revived etc.
	update_perception()
	create_lighting_planes()

	regular_hud_updates()

	update_antag_huds()

	update_action_buttons(TRUE)

	delayNextMove(0)

	change_sight(adding = (SEE_SELF|SEE_BLACKNESS))

	reset_view()

	if((flags & HEAR) && !(flags & HEAR_ALWAYS)) //Mobs with HEAR_ALWAYS will already have a virtualhearer
		virtualhearer = new /mob/virtualhearer(src)

	//Clear ability list and update from mob.
	client.verbs -= ability_verbs

	if(abilities)
		client.verbs |= abilities

	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		if(H.species && H.species.abilities)
			H.verbs |= H.species.abilities

	if(client)
		if(ckey in deadmins)
			client.verbs += /client/proc/readmin

		if(M_FARSIGHT in mutations)
			client.changeView(max(client.view, world.view+1))
	CallHook("Login", list("client" = src.client, "mob" = src))

	if(spell_masters)
		for(var/obj/abstract/screen/movable/spell_master/spell_master in spell_masters)
			client.screen += spell_master
			spell_master.toggle_open(1)

	if (isobj(loc))
		var/obj/location = loc
		location.on_login(src)

	if(client && client.haszoomed && !client.holder)
		client.changeView()
		client.haszoomed = 0

	update_colour()

	if(client)
		client.CAN_MOVE_DIAGONALLY = 0

	if(iscluwnebanned(src) && (timeofdeath > 0 || !iscluwne(src)))
		log_admin("Cluwnebanned player [key_name(src)] attempted to join and was kicked.")
		message_admins("<span class='notice'>Cluwnebanned player [key_name(src)] attempted to join and was kicked.</span>", 1)
		del(client)
