/mob/camera/blob
	name = "Blob Overmind"
	real_name = "Blob Overmind"
	icon = 'icons/mob/blob.dmi'
	icon_state = "marker"

	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	invisibility = INVISIBILITY_OBSERVER

	pass_flags = PASSBLOB
	faction = "blob"

	var/obj/effect/blob/core/blob_core = null // The blob overmind's core
	var/blob_points = 0
	var/max_blob_points = 100
	var/maxjumprange = 20 //how far you can go in terms of non-blob tiles in a jump attempt

/mob/camera/blob/New()
	var/new_name = "[initial(name)] ([rand(1, 999)])"
	name = new_name
	real_name = new_name
	..()
	spawn(10)
		if(src.mind)
			src.mind.special_role = "Blob"

/mob/camera/blob/Login()
	..()
	//Mind updates
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

	to_chat(src, "<span class='blob'>You are the overmind!</span>")
	to_chat(src, "You are the overmind and can control the blob! You can expand, which will attack people, and place special blob types.")
	to_chat(src, "The location of your thoughts (eye), nodes, and core can power your buildings and expand the blob much further, use them well!")
	to_chat(src, "<b>Normal Blobs</b> will expand your reach and can be upgraded into other special blobs that perform certain functions.")
	to_chat(src, "<b>Shield Blob</b> is a strong and expensive blob which can take more damage. It is fireproof and can block air, use this to protect yourself from station fires. It can also begin to repair itself when powered.")
	to_chat(src, "<b>Resource Blob</b> is a blob which will collect more resources for you, try to build these earlier to get a strong income. It will benefit from being near your core or multiple nodes, by having an increased resource rate; put it alone and it won't create resources at all.")
	to_chat(src, "<b>Node Blob</b> is a blob which will grow, like the core. It will not provide income, but will power all the other special nodes and expand your blob by itself.")
	to_chat(src, "<b>Factory Blob</b> is a blob which will spawn blob spores which will attack nearby food. You must make sure it is powered to operate properly!")
	to_chat(src, "<b>Shortcuts:</b> CTRL Click = Expand Blob, Middle Mouse Click = Rally Spores, Alt Click = Create Shield, Double Click: Teleport to Blob")
	update_health()

/mob/camera/blob/proc/update_health()
	if(blob_core)
		hud_used.blobhealthdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='#e36600'>[blob_core.health]</font></div>"

/mob/camera/blob/proc/add_points(var/points)
	if(points != 0)
		blob_points = Clamp(blob_points + points, 0, max_blob_points)
	//sanity for manual spawned blob cameras
	if(hud_used)
		hud_used.blobpwrdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='#82ed00'>[src.blob_points]</font></div>"

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

	var/message_a = say_quote("\"[html_encode(message)]\"")
	var/rendered = "<font color=\"#EE4000\"><i><span class='game say'>Blob Telepathy, <span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i></font>"

	for (var/mob/camera/blob/S in mob_list)
		if(istype(S))
			S.show_message(rendered, 2)

	for (var/mob/M in dead_mob_list)
		if(!istype(M,/mob/new_player) && !istype(M,/mob/living/carbon/brain)) //No meta-evesdropping
			rendered = "<font color=\"#EE4000\"><i><span class='game say'>Blob Telepathy, <span class='name'>[name]</span> <a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>(Follow)</a> <span class='message'>[message_a]</span></span></i></font>"
			M.show_message(rendered, 2)

/mob/camera/blob/emote(var/act,var/m_type=1,var/message = null)
	return

/mob/camera/blob/blob_act()
	return

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

/mob/camera/blob/Move(var/NewLoc, var/Dir = 0)
	var/obj/effect/blob/B = locate() in range("3x3", NewLoc)
	if(B)
		loc = NewLoc
	else
		B = locate() in range("3x3", src.loc)
	if(!B) //PANIC, WE'RE NOWHERE NEAR ANYTHING
		var/newrange = 3 //slowly grows outwards, looking for the nearest blob tile. Should not take very long to find it.
		while (1)
			newrange++
			B = locate() in range("[newrange]x[newrange]", src.loc)
			if(B)
				loc = B.loc
				break
			if(newrange > maxjumprange) //to avoid going in an infinite loop
				break

		// Update on_moved listeners.
		INVOKE_EVENT(on_moved,list("loc"=NewLoc))
		return 0

	// Update on_moved listeners.
	INVOKE_EVENT(on_moved,list("loc"=NewLoc))