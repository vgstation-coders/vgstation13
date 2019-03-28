/mob/camera/eet
	name = "EET freemind"
	real_name = "EET freemind"
	icon = 'icons/mob/blob/blob.dmi'
	icon_state = "marker"

	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	invisibility = INVISIBILITY_OBSERVER

	pass_flags = PASSBLOB
	faction = "eet"

	plane = ABOVE_LIGHTING_PLANE

	var/datum/faction/eet_faction

/mob/camera/eet/New()
	eet_faction = find_active_faction_by_type(/datum/faction/eet)
	..()

/mob/camera/eet/Login()
	..()
	//Mind updates
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

	to_chat(src, "<span class='info'><B>Your mind has been returned to the Continuum.</B></span>")
	to_chat(src, "<span class='info'>You may look about freely and speak to other EETs, but are otherwise incapacitated.</span>")

/mob/camera/eet/say(var/message)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat)
		return

	eet_talk(message)

/mob/camera/eet/proc/eet_talk(message)
	var/turf/T = get_turf(src)
	log_say("[key_name(src)] (@[T.x],[T.y],[T.z]) EET Continuum: [message]")

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	var/message_a = say_quote("\"[message]\"")
	var/rendered = "<font color=\"#EE4000\"><i><span class='game say'>EET Telepathy, <span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i></font>"

	for(var/datum/role/R in eet_faction.members)
		if(R.antag.current && R.antag.current.stat)
			to_chat(R.antag.current,rendered)

	log_blobspeak("[key_name(usr)]: [rendered]")

	for (var/mob/M in dead_mob_list)
		rendered = "<font color=\"#EE4000\"><i><span class='game say'>EET Telepathy, <span class='name'>[name]</span> <a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>(Follow)</a> <span class='message'>[message_a]</span></span></i></font>"
		M.show_message(rendered, 2)

/mob/camera/eet/emote(var/act,var/m_type=1,var/message = null,var/auto)
	return

/mob/camera/eet/ex_act()
	return

/mob/camera/eet/singularity_act()
	return

/mob/camera/eet/cultify()
	return

/mob/camera/eet/singularity_pull()
	return

/mob/camera/eet/blob_act()
	return

/mob/camera/eet/Process_Spacemove(var/check_drift = 0)
	return 1

/mob/camera/eet/can_shuttle_move()
	return TRUE //other mob cameras can't ride shuttles
