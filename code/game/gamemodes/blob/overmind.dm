/mob/camera/blob
	name = "Blob Overmind"
	real_name = "Blob Overmind"
	icon = 'icons/mob/blob/blob.dmi'
	icon_state = "marker"

	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	seedarkness = FALSE
	invisibility = INVISIBILITY_OBSERVER

	pass_flags = PASSBLOB
	faction = "blob"

	plane = ABOVE_LIGHTING_PLANE

	var/obj/effect/blob/core/blob_core = null // The blob overmind's core
	var/blob_points = 0
	var/max_blob_points = 100
	var/maxjumprange = 20 //how far you can go in terms of non-blob tiles in a jump attempt
	var/restrain_blob = TRUE

	var/blob_warning = 0

	var/list/special_blobs = list()

/mob/camera/blob/New()
	blob_overminds += src
	..()
	register_event(/event/living_login, src, /mob/camera/blob/proc/add_HUD)

/mob/camera/blob/Destroy()
	blob_overminds -= src
	unregister_event(/event/living_login, src, /mob/camera/blob/proc/add_HUD)
	..()

/mob/camera/blob/proc/add_HUD(var/mob/user)
	DisplayUI("Blob")

/mob/camera/blob/Login()
	..()
	//Mind updates
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

	client.CAN_MOVE_DIAGONALLY = 1
	ResendAllUIs()
	DisplayUI("Blob")

	to_chat(src, "<span class='blob'>You are the blob!</span>")
	to_chat(src, "The location of your thoughts (eye), nodes, and core power your spore factories, resources, and passive expansion.")
	to_chat(src, "<b>CTRL Click:</b> Active expand/attack. Expensive, use sparingly.")
	to_chat(src, "<b>ALT Click:</b> (On Blob) Upgrade to healthier, fire immune Strong Blob. (On Core) Toggle passive wall smashing - stealthier and leaves cover up!")
	to_chat(src, "<b>MIDDLE Click:</b> Rally (factory) spores. <b>DOUBLE Click:<B> Move eye (to blob).")
	to_chat(src, "<b><span class='bad'>Always place factories and resources within 2 tiles of a node or core!</span></b>")
	if(restrain_blob)
		to_chat(src, "<b><span class='bad'>You are stealthily restraining your blob from smashing walls! Don't forget to toggle it off when you are ready!</span></b>")
	update_health()

/mob/camera/blob/Topic(href, href_list)
	if(usr != src)
		return
	..()
	if (href_list["blobjump"])//We only let blobs jump to where there are blobs.
		var/turf/dest = locate(href_list["blobjump"])
		if(dest)
			var/turf/closest_turf = null
			for(var/turf/T in spiral_block(dest,7))
				var/obj/effect/blob/B = locate() in T
				if(B)
					closest_turf = T
					break
			if(closest_turf)
				if(closest_turf != dest)
					to_chat(src, "<span class='notice'>Jumping to closest blob from the target.</span>")
				loc = closest_turf
			else
				to_chat(src, "<span class='warning'>Unable to make the jump. Looks like all the blobs in a large radius around the target have been destroyed.</span>")

/mob/camera/blob/throw_at(var/atom/targ, var/range, var/speed, var/override = 1, var/fly_speed = 0)
	return

/mob/camera/blob/proc/update_health()
	DisplayUI("Blob")
	if(blob_core)
		var/severity = 0
		switch(round(blob_core.health))
			if(167 to 199)
				severity = 1
			if(134 to 166)
				severity = 2
			if(100 to 133)
				severity = 3
			if(67 to 99)
				severity = 4
			if(34 to 66)
				severity = 5
			if(-INFINITY to 33)
				severity = 6
		if(severity > 0)
			overlay_fullscreen("damage", /obj/abstract/screen/fullscreen/brute, severity)
		else
			clear_fullscreen("damage")

/mob/camera/blob/proc/add_points(var/points)
	if(points != 0)
		blob_points = clamp(blob_points + points, 0, max_blob_points)
	DisplayUI("Blob")

/mob/camera/blob/say(var/message)
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

	blob_talk(message)

/mob/camera/blob/proc/blob_talk(message)
	var/turf/T = get_turf(src)
	log_say("[key_name(src)] (@[T.x],[T.y],[T.z]) Blob Hivemind: [message]")

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	var/message_a = say_quote("\"[message]\"")
	var/rendered = "<font color=\"#EE4000\"><i><span class='game say'>Blob Telepathy, <span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i></font>"

	for (var/mob/camera/blob/S in mob_list)
		if(istype(S))
			S.show_message(rendered, 2)

	log_blobspeak("[key_name(usr)]: [rendered]")

	for (var/mob/M in dead_mob_list)
		if(!istype(M,/mob/new_player) && !istype(M,/mob/living/carbon/brain)) //No meta-evesdropping
			rendered = "<font color=\"#EE4000\"><i><span class='game say'>Blob Telepathy, <span class='name'>[name]</span> <a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>(Follow)</a> <span class='message'>[message_a]</span></span></i></font>"
			M.show_message(rendered, 2)

/mob/camera/blob/emote(act, m_type = null, message = null, ignore_status = FALSE, arguments)
	return

/mob/camera/blob/ex_act()
	return

/mob/camera/blob/singularity_act()
	return

/mob/camera/blob/cultify()
	return

/mob/camera/blob/singularity_pull()
	return

/mob/camera/blob/blob_act()
	return

/mob/camera/blob/Process_Spacemove(var/check_drift = 0)
	return 1

/mob/camera/blob/Stat()
	..()
	if (statpanel("Blob Status"))
		if(blob_core)
			stat(null, "Core Health: [blob_core.health]")
		stat(null, "Power Stored: [blob_points]/[max_blob_points]")
		stat(null, "Blob Total Size: [blobs.len]")
		stat(null, "Total Nodes: [blob_nodes.len]")
		stat(null, "Total Overminds: [blob_cores.len]")
	return

/mob/camera/blob/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	var/obj/effect/blob/B = locate() in range("3x3", NewLoc)
	if(B)
		forceEnter(B.loc)
	else
		B = locate() in range("3x3", src.loc)

	if(!B) //PANIC, WE'RE NOWHERE NEAR ANYTHING
		var/newrange = 3 //slowly grows outwards, looking for the nearest blob tile. Should not take very long to find it.
		while (1)
			newrange++
			B = locate() in range("[newrange]x[newrange]", src.loc)
			if(B)
				forceEnter(B.loc)
				break
			if(newrange > maxjumprange) //to avoid going in an infinite loop
				break

		INVOKE_EVENT(src, /event/moved, "mover" = src)
		return 0

	INVOKE_EVENT(src, /event/moved, "mover" = src)
