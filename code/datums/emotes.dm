#define EMOTE_VISIBLE 1
#define EMOTE_AUDIBLE 2

/* Emote datums, ported from TG station. */

/datum/emote
	var/key = "" //What calls the emote
	var/key_third_person = "" //This will also call the emote
	var/key_shorthand = "" //This will also call the emote
	var/message = "" //Message displayed when emote is used
	var/list/message_mobtype = list() //Message displayed depending on mobtype. Please put subtypes below supertypes so this works right.
	var/message_mime = "" //Message displayed if the user is a mime
	var/message_param = "" //Message to display if a param was given
	var/emote_type = EMOTE_VISIBLE //Whether the emote is visible or audible
	var/restraint_check = FALSE //Checks if the mob is restrained before performing the emote
	var/muzzle_ignore = FALSE //Will only work if the emote is EMOTE_AUDIBLE
	var/list/mob_type_allowed_typelist = list(/mob) //Types that are allowed to use that emote
	var/list/mob_type_blacklist_typelist //Types that are NOT allowed to use that emote
	var/list/mob_type_ignore_stat_typelist
	var/voxemote = TRUE //Flags if a vox CAN use an emote. Defaults to can.
	var/voxrestrictedemote = FALSE //Flags if Non-Vox CANNOT use an emote. Defaults to CAN.
	var/insectoidemote = TRUE
	var/insectoidrestrictedemote = FALSE
	var/stat_allowed = CONSCIOUS
	var/hands_needed = 0//how many hands do you need to perform the emote
	var/static/list/emote_list = list()
	var/replace_pronouns = TRUE

/datum/emote/New()
	if(key_third_person)
		emote_list[key_third_person] = src
	if(key_shorthand)
		emote_list[key_shorthand] = src

/datum/emote/proc/run_emote(mob/user, params, type_override, ignore_status = FALSE, var/arguments)
	. = TRUE
	if(!(type_override) && !(can_run_emote(user, !ignore_status))) // ignore_status == TRUE means that status_check should be FALSE and vise-versa
		return FALSE
	var/msg = select_message_type(user)
	if(params && message_param)
		msg = select_param(user, params)

	msg = replace_pronoun(user, msg)

	if(isliving(user))
		INVOKE_EVENT(user, /event/emote, "emote" = key, "source" = user)

	if(!msg)
		return

	var/msg_runechat = msg
	msg = "<b>[user]</b> " + msg

	var/obs_pass = TRUE
	// Don't hear simple mobs without a client.
	if (istype(user, /mob/living/simple_animal) && !user.client)
		obs_pass = FALSE

	if (obs_pass)
		for(var/mob/M in dead_mob_list)
			if(!M.client || isnewplayer(M))
				continue
			var/T = get_turf(user)
			if(isobserver(M) && M.client && (M.client.prefs.toggles & CHAT_GHOSTSIGHT) && !(M in viewers(T)))
				M.show_message("<a href='?src=\ref[M];follow=\ref[user]'>(Follow)</a> " + msg)
				if (user.client && M?.client?.prefs.mob_chat_on_map && get_dist(M, user) < M?.client.view)
					M.create_chat_message(user, null, msg_runechat, "", list("italics"))

	if (emote_type == EMOTE_VISIBLE)
		user.visible_message(msg)
		for(var/z0 in GetOpenConnectedZlevels(user))
			for (var/mob/O in viewers(world.view, locate(user.x,user.y,z0)))
				if (user.client && O?.client?.prefs.mob_chat_on_map && O.stat != UNCONSCIOUS && !(isinvisible(user)))
					O.create_chat_message(user, null, msg_runechat, "", list("italics"))
	else
		for(var/mob/O in get_hearers_in_view(world.view, user))
			O.show_message(msg)
			if (user.client && O?.client?.prefs.mob_chat_on_map && O.stat != UNCONSCIOUS && !O.is_deaf())
				O.create_chat_message(user, null, msg_runechat, "", list("italics"))

	var/turf/T = get_turf(user)
	var/location = T ? "[T.x],[T.y],[T.z]" : "nullspace"
	log_emote("[user.name]/[user.key] (@[location]): [message]")


// TODO : gender & all
/datum/emote/proc/replace_pronoun(mob/user, message)
	var/mob/living/carbon/human/H = user
	if (istype(H))
		var/skipface = FALSE
		var/list/obscured = H.check_obscured_slots()
		if(H.wear_mask)
			skipface |= H.check_hidden_head_flags(HIDEFACE)
		if((slot_w_uniform in obscured) && skipface)
			if(findtext(message, "%s"))
				message = replacetext(message, "%s", "")
			return message
		else if (replace_pronouns)
			switch(H.gender)
				if(MALE)
					if(findtext(message, "their"))
						message = replacetext(message, "their", "his")
					if(findtext(message, "them"))
						message = replacetext(message, "them", "him")
					if(findtext(message, "they"))
						message = replacetext(message, "they", "he")
					if(findtext(message, "%s"))
						message = replacetext(message, "%s", "s")
				if(FEMALE)
					if(findtext(message, "their"))
						message = replacetext(message, "their", "her")
					if(findtext(message, "them"))
						message = replacetext(message, "them", "her")
					if(findtext(message, "they"))
						message = replacetext(message, "they", "she")
					if(findtext(message, "%s"))
						message = replacetext(message, "%s", "s")
	return message

/datum/emote/proc/select_message_type(mob/user)
	. = message
	if(!muzzle_ignore && user.is_muzzled() && emote_type == EMOTE_AUDIBLE)
		return "makes a [pick("strong ", "weak ", "")]noise."
	if(user.mind && ishuman(user) && user.mind.miming && message_mime)
		. = message_mime
	if(message_mobtype.len)
		for(var/mobtype in message_mobtype)
			if(istype(user,mobtype))
				. = message_mobtype[mobtype]

/datum/emote/proc/select_param(mob/user, params)
	return replacetext(message_param, "%t", params)

/datum/emote/proc/can_run_emote(mob/user, var/status_check = TRUE)
	if(!(is_type_in_list(user, mob_type_allowed_typelist)))
		return FALSE
	if(is_type_in_list(user, mob_type_blacklist_typelist))
		return FALSE

	if((isinsectoid(user)) && insectoidrestrictedemote == TRUE)
		return TRUE
	if((!isinsectoid(user)) && insectoidrestrictedemote == TRUE)
		return FALSE
	if((isinsectoid(user)) && insectoidemote == FALSE)
		return FALSE
	if((isvox(user) || isskelevox(user)) && voxrestrictedemote == TRUE)
		return TRUE
	if((!isvox(user) || !isskelevox(user)) && voxrestrictedemote == TRUE)
		return FALSE
	if((isvox(user) || isskelevox(user)) && voxemote == FALSE)
		return FALSE
	if(!user.client && user.ckey == null) //Auto emote, like a monkey or corgi
		var/someone_in_earshot=0
		for(var/mob/M in get_hearers_in_view(world.view, user)) //See if anyone is in earshot
			if(M.client)
				someone_in_earshot=1
				break
		if(!someone_in_earshot)
			return FALSE
	if(status_check && !(is_type_in_list(user, mob_type_ignore_stat_typelist)))
		if(user.stat > stat_allowed)
			to_chat(user, "<span class='warning'>You cannot [key] while unconscious.</span>")
			return FALSE
		if(restraint_check)
			if(user.restrained() || (user.locked_to && !user.can_use_hands()))
				to_chat(user, "<span class='warning'>You cannot [key] while restrained.</span>")
				return FALSE

	if(isliving(user))
		var/mob/living/L = user
		if(L.silent)
			to_chat(user, "<span class='warning'>You cannot do that while silenced.</span>")
			return FALSE

	return TRUE

/datum/emote/sound
	var/sound //Sound to play when emote is called
	var/vary = FALSE	//used for the honk borg emote
	mob_type_allowed_typelist = list(/mob/living/carbon/brain, /mob/living/silicon)

/datum/emote/sound/run_emote(mob/user, params, ignore_status = FALSE)
	. = ..()
	if(.)
		playsound(user.loc, sound, 50, vary)

/mob/proc/audible_cough()
	emote("coughs", message = TRUE, ignore_status = TRUE)

/mob/proc/audible_scream(var/arguments)
	if(isvox(src) || isskelevox(src))
		emote("shrieks", message = TRUE, ignore_status = TRUE, arguments = arguments)
		return
	if(isinsectoid(src))
		emote("chitters", message = TRUE, ignore_status = TRUE, arguments = arguments)
		return
	else
		emote("screams", message = TRUE, ignore_status = TRUE, arguments = arguments) // So it's forced


