//The code execution of the emote datum is located at code/datums/emotes.dm
/mob/proc/emote(act, m_type = null, message = null, ignore_status = FALSE)
	act = lowertext(act)
	var/param = message
	var/custom_param = findtext(act, " ") // Someone was given as a parameter
	if(custom_param)
		param = copytext(act, custom_param + 1, length(act) + 1)
		act = copytext(act, 1, custom_param)

	var/datum/emote/E
	E = E.emote_list[act]
	if(!E)
		to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")
		return
	E.run_emote(src, param, m_type, ignore_status)

/datum/emote/flip
	key = "flip"
	key_third_person = "flips"
	restraint_check = TRUE
	mob_type_allowed_typelist = list(/mob/living, /mob/dead/observer)
	mob_type_blacklist_typelist = list(/mob/living/silicon/ai, /mob/living/silicon/pai, /mob/living/carbon/brain)
	mob_type_ignore_stat_typelist = list(/mob/dead/observer)

/datum/emote/flip/run_emote(mob/user, params)
	. = ..()
	if(.)
		var/prev_dir = user.dir
		for(var/i in list(1, 4, 2, 8, 1, 4, 2, 8, 1, 4, 2, 8, 1, 4, 2, 8))
			user.dir = i
			sleep(1)
		user.dir = prev_dir

/datum/emote/spin
	key = "spin"
	key_third_person = "spins"
	restraint_check = TRUE
	mob_type_allowed_typelist = list(/mob/living, /mob/dead/observer)
	mob_type_blacklist_typelist = list(/mob/living/silicon/ai, /mob/living/silicon/pai, /mob/living/carbon/brain)
	mob_type_ignore_stat_typelist = list(/mob/dead/observer)

/datum/emote/spin/run_emote(mob/user)
	. = ..()
	if(.)
		var/prev_dir = user.dir
		for(var/i in list(1, 4, 2, 8, 1, 4, 2, 8, 1, 4, 2, 8, 1, 4, 2, 8))
			user.dir = i
			sleep(1)
		user.dir = prev_dir

/datum/emote/me
	key = "me"
	restraint_check = FALSE

/datum/emote/me/run_emote(mob/user, params, m_type)

	if (user.stat)
		return

	var/message = params

	if(copytext(message,1,5) == "says")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
		return
	else if(copytext(message,1,9) == "exclaims")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
		return
	else if(copytext(message,1,6) == "yells")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
		return
	else if(copytext(message,1,5) == "asks")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
		return

	var/msg = "<b>[user]</b> " + message

	var/turf/T = get_turf(user) // for pAIs

	for(var/mob/M in dead_mob_list)
		if (!M.client)
			continue //skip leavers
		if(isobserver(M) && M.client.prefs && (M.client.prefs.toggles & CHAT_GHOSTSIGHT) && !(M in viewers(user)))
			M.show_message("<a href='?src=\ref[M];follow=\ref[user]'>(Follow)</a> " + msg)

	if (emote_type == EMOTE_VISIBLE)
		user.visible_message(msg)
	else
		for(var/mob/O in get_hearers_in_view(world.view, user))
			O.show_message(msg)

	var/location = T ? "[T.x],[T.y],[T.z]" : "nullspace"
	log_emote("[user.name]/[user.key] (@[location]): [message]")

/mob/proc/emote_dead(var/message)
	if(client.prefs.muted & MUTE_DEADCHAT)
		to_chat(src, "<span class='warning'>You cannot send deadchat emotes (muted).</span>")
		return

	if(!(client.prefs.toggles & CHAT_DEAD))
		to_chat(src, "<span class='warning'>You have deadchat muted.</span>")
		return

	var/input
	if(!message)
		input = copytext(sanitize(input(src, "Choose an emote to display.") as text|null), 1, MAX_MESSAGE_LEN)
	else
		input = message

	if(input)
		message = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <b>[src]</b> [message]</span>"
	else
		return


	if(message)
		for(var/mob/M in player_list)
			if(istype(M, /mob/new_player))
				continue

			if(M.client && M.client.holder && (M.client.holder.rights & R_ADMIN|R_MOD) && (M.client.prefs.toggles & CHAT_DEAD)) // Show the emote to admins/mods
				to_chat(M, message)

			else if(M.stat == DEAD && (M.client.prefs.toggles & CHAT_DEAD)) // Show the emote to regular ghosts with deadchat toggled on
				M.show_message(message, 2)
