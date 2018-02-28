var/list/ai_list = list()

//Not sure why this is necessary...
/proc/AutoUpdateAI(obj/subject)
	var/is_in_use = FALSE
	if(subject!=null)
		for(var/A in ai_list)
			var/mob/living/silicon/ai/M = A
			if((M.client && M.machine == subject))
				is_in_use = TRUE
				subject.attack_ai(M)
	return is_in_use


/mob/living/silicon/ai
	name = "AI"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai"
	anchored = TRUE // -- TLE
	density = TRUE
	status_flags = CANSTUN|CANPARALYSE|CANPUSH
	force_compose = TRUE
	size = SIZE_BIG

	var/list/network = list(CAMERANET_SS13)
	var/obj/machinery/camera/current = null
	var/list/connected_robots = list()
	var/aiRestorePowerRoutine = 0
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list())
	var/viewalerts = FALSE
	var/lawcheck[1]
	var/ioncheck[1]
	var/icon/holo_icon//Default is assigned when AI is created.
	var/obj/item/device/pda/ai/aiPDA = null
	var/obj/item/device/multitool/aiMulti = null
	var/obj/item/device/station_map/station_holomap = null
	var/obj/item/device/camera/silicon/aicamera = null
	var/busy = FALSE //Toggle Floor Bolt busy var.

//Hud stuff

	//MALFUNCTION
	var/ai_flags = 0

	var/control_disabled = FALSE // Set to TRUE to stop AI from interacting via Click() -- TLE
	var/malfhacking = FALSE // More or less a copy of the above var, so that malf AIs can hack and still get new cyborgs -- NeoFite

	var/obj/machinery/power/apc/malfhack = null
	var/explosive = FALSE //does the AI explode when it dies?

	var/mob/living/silicon/ai/parent = null
	var/camera_light_on = FALSE
	var/list/obj/machinery/camera/lit_cameras = list()

	var/datum/trackable/track = new()

	var/last_paper_seen = null
	var/can_shunt = TRUE
	var/last_announcement = ""

	// The AI's "eye". Described on the top of the page in eye.dm

	var/mob/camera/aiEye/eyeobj
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1

/mob/living/silicon/ai/New(loc, var/datum/ai_laws/L, var/obj/item/device/mmi/B, var/safety = FALSE)

	var/list/possibleNames = ai_names

	var/pickedName = null
	while(!pickedName)
		pickedName = pick(ai_names)
		for (var/mob/living/silicon/ai/A in mob_list)
			if(A.real_name == pickedName && possibleNames.len > 1) //fixing the theoretically possible infinite loop
				possibleNames -= pickedName
				pickedName = null
	add_language(LANGUAGE_GALACTIC_COMMON, TRUE)
	add_language(LANGUAGE_UNATHI, TRUE)
	add_language(LANGUAGE_CATBEAST, TRUE)
	add_language(LANGUAGE_SKRELLIAN, TRUE)
	add_language(LANGUAGE_ROOTSPEAK, TRUE)
	add_language(LANGUAGE_GUTTER, TRUE)
	add_language(LANGUAGE_CLATTER, TRUE)
	add_language(LANGUAGE_GREY, TRUE)
	add_language(LANGUAGE_MONKEY, TRUE)
	add_language(LANGUAGE_VOX, TRUE)
	add_language(LANGUAGE_GOLEM, TRUE)
	add_language(LANGUAGE_TRADEBAND, TRUE)
	add_language(LANGUAGE_MOUSE, TRUE)
	add_language(LANGUAGE_GOLEM, TRUE)
	add_language(LANGUAGE_SLIME, TRUE)
	add_language(LANGUAGE_HUMAN, TRUE)
	default_language = all_languages[LANGUAGE_GALACTIC_COMMON]
	real_name = pickedName
	name = real_name
	anchored = TRUE
	canmove = FALSE
	setDensity(TRUE)
	loc = loc

	radio = new /obj/item/device/radio/borg/ai(src)
	radio.recalculateChannels()

	holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo1"))

	proc_holder_list = new()

	//Determine the AI's lawset
	if(L && istype(L,/datum/ai_laws))
		src.laws = L
	else
		src.laws = getLawset(src)

	verbs += /mob/living/silicon/ai/proc/show_laws_verb

	aiPDA = new/obj/item/device/pda/ai(src)
	aiPDA.owner = name
	aiPDA.ownjob = "AI"
	aiPDA.name = name + " (" + aiPDA.ownjob + ")"

	station_holomap = new(src)

	aiMulti = new(src)
	aicamera = new /obj/item/device/camera/silicon/ai_camera(src)
	if(istype(loc, /turf))
		verbs.Add(/mob/living/silicon/ai/proc/ai_network_change, \
		/mob/living/silicon/ai/proc/ai_statuschange, \
		/mob/living/silicon/ai/proc/ai_hologram_change)

	if(!safety)//Only used by AIize() to successfully spawn an AI.
		if(!B)//If there is no player/brain inside.
			new/obj/structure/AIcore/deactivated(loc)//New empty terminal.
			qdel(src)//Delete AI.
			return
		else
			if(B.brainmob.mind)
				B.brainmob.mind.transfer_to(src)

			to_chat(src, "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>")
			to_chat(src, "<B>To look at other parts of the station, click on yourself to get a camera menu.</B>")
			to_chat(src, "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>")
			to_chat(src, "To use something, simply click on it.")
			to_chat(src, "Use say :b to speak to your cyborgs through binary.")
			if(!(ticker && ticker.mode && (mind in ticker.mode.malf_ai)))
				show_laws()
				to_chat(src, "<b>These laws may be changed by other players, or by you being the traitor.</b>")

			job = "AI"
	ai_list += src
	..()
	return

/mob/living/silicon/ai/verb/toggle_anchor()
	set category = "AI Commands"
	set name = "Toggle Floor Bolts"

	if(incapacitated() || aiRestorePowerRoutine || !isturf(loc) || busy)
		return
	busy = TRUE
	playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
	if(do_after(src, src, 30))
		anchored = !anchored
		to_chat(src, "You are now <b>[anchored ? "" : "un"]anchored</b>.")
	busy = FALSE

/mob/living/silicon/ai/verb/radio_interact()
	set category = "AI Commands"
	set name = "Radio Configuration"
	if(stat || aiRestorePowerRoutine)
		return
	radio.attack_self(usr)

/mob/living/silicon/ai/verb/rename_photo() //This is horrible but will do for now
	set category = "AI Commands"
	set name = "Modify Photo Files"
	if(stat || aiRestorePowerRoutine)
		return

	var/list/nametemp = list()
	var/find
	var/datum/picture/selection
	if(!aicamera.aipictures.len)
		to_chat(usr, "<font color=red><B>No images saved<B></font>")
		return
	for(var/datum/picture/t in aicamera.aipictures)
		nametemp += t.fields["name"]
	find = input("Select image to delete or rename.", "Photo Modification") in nametemp
	for(var/datum/picture/q in aicamera.aipictures)
		if(q.fields["name"] == find)
			selection = q
			break

	if(!selection)
		return
	var/choice = input(usr, "Would you like to rename or delete [selection.fields["name"]]?", "Photo Modification") in list("Rename","Delete","Cancel")
	switch(choice)
		if("Cancel")
			return
		if("Delete")
			aicamera.aipictures.Remove(selection)
			qdel(selection)
		if("Rename")
			var/new_name = sanitize(input(usr, "Write a new name for [selection.fields["name"]]:","Photo Modification"))
			if(length(new_name) > 0)
				selection.fields["name"] = new_name
			else
				to_chat(usr, "You must write a name.")

/mob/living/silicon/ai/verb/pick_icon()
	set category = "AI Commands"
	set name = "Set AI Core Display"
	if(stat || aiRestorePowerRoutine)
		return
	var/icontype = input("Select an icon!", "AI", null, null) as null|anything in list("Monochrome", "Blue", "Inverted", "Text", "Smiley", "Angry", "Dorf", "Matrix", "Bliss", "Firewall", "Green", "Red", "Broken Output", "Triumvirate", "Triumvirate Static", "Searif", "Ravensdale", "Serithi", "Static", "Wasp", "Robert House", "Red October", "Fabulous", "Girl", "Girl Malf", "Boy", "Boy Malf", "Four-Leaf", "Yes Man", "Hourglass", "Patriot", "Pirate", "Royal", "Heartline", "Hades", "Helios", "Syndicat", "Alien", "Too Deep", "Goon", "Database", "Glitchman", "Nanotrasen", "Angel", "Gentoo", "Murica", "President", "Fort", "Mothman", "Dancing Hotdog", "Diagnosis", "Drink It!", "Metaclub", "Jack Frost")
	switch(icontype)
		if("Clown")
			icon_state = "ai-clown2"
		if("Monochrome")
			icon_state = "ai-mono"
		if("Inverted")
			icon_state = "ai-u"
		if("Firewall")
			icon_state = "ai-magma"
		if("Green")
			icon_state = "ai-wierd"
		if("Red")
			icon_state = "ai-malf"
		if("Broken Output")
			icon_state = "ai-static"
		if("Text")
			icon_state = "ai-text"
		if("Smiley")
			icon_state = "ai-smiley"
		if("Matrix")
			icon_state = "ai-matrix"
		if("Angry")
			icon_state = "ai-angryface"
		if("Dorf")
			icon_state = "ai-dorf"
		if("Bliss")
			icon_state = "ai-bliss"
		if("Triumvirate")
			icon_state = "ai-triumvirate"
		if("Triumvirate Static")
			icon_state = "ai-triumvirate-malf"
		if("Searif")
			icon_state = "ai-searif"
		if("Ravensdale")
			icon_state = "ai-ravensdale"
		if("Serithi")
			icon_state = "ai-serithi"
		if("Static")
			icon_state = "ai-fuzz"
		if("Wasp")
			icon_state = "ai-wasp"
		if("Robert House")
			icon_state = "ai-president"
		if("Red October")
			icon_state = "ai-soviet"
		if("Girl")
			icon_state = "ai-girl"
		if("Girl Malf")
			icon_state = "ai-girl-malf"
		if("Boy")
			icon_state = "ai-boy"
		if("Boy Malf")
			icon_state = "ai-boy-malf"
		if("Fabulous")
			icon_state = "ai-fabulous"
		if("Four-Leaf")
			icon_state = "ai-4chan"
		if("Yes Man")
			icon_state = "yes-man"
		if("Hourglass")
			icon_state = "ai-hourglass"
		if("Patriot")
			icon_state = "ai-patriot"
		if("Pirate")
			icon_state = "ai-pirate"
		if("Royal")
			icon_state = "ai-royal"
		if("Heartline")
			icon_state = "ai-heartline"
		if("Hades")
			icon_state = "ai-hades"
		if("Helios")
			icon_state = "ai-helios"
		if("Syndicat")
			icon_state = "ai-syndicatmeow"
		if("Too Deep")
			icon_state = "ai-toodeep"
		if("Goon")
			icon_state = "ai-goon"
		if("Database")
			icon_state = "ai-database"
		if("Glitchman")
			icon_state = "ai-glitchman"
		if("Alien")
			icon_state = "ai-alien"
		if("Nanotrasen")
			icon_state = "ai-nanotrasen"
		if("Angel")
			icon_state = "ai-angel"
		if("Gentoo")
			icon_state = "ai-gentoo"
		if("Murica")
			icon_state = "ai-murica"
		if("President")
			icon_state = "ai-pres"
		if("Fort")
			icon_state = "ai-boxfort"
		if("Mothman")
			icon_state = "ai-mothman"
		if("Dancing Hotdog")
			icon_state = "ai-hotdog"
		if("Diagnosis")
			icon_state = "ai-atlantiscze"
		if("Drink It!")
			icon_state = "ai-silveryferret"
		if("Metaclub")
			icon_state = "ai-terminal"
		if("Jack Frost")
			icon_state = "ai-jack"
		else icon_state = "ai"

// displays the malf_ai information if the AI is the malf
/mob/living/silicon/ai/show_malf_ai()
	if(ticker.mode.name == "AI malfunction")
		var/datum/game_mode/malfunction/malf = ticker.mode
		for (var/datum/mind/malfai in malf.malf_ai)
			if(mind == malfai) // are we the evil one?
				if(malf.apcs >= 3)
					stat(null, "Time until station control secured: [max(malf.AI_win_timeleft/(malf.apcs/3), 0)] seconds")

/mob/proc/remove_malf_spells()
	for(var/spell/S in spell_list)
		if(S.panel == MALFUNCTION)
			remove_spell(S)

/mob/living/silicon/ai/proc/ai_alerts()


	var/dat = {"<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n
<A HREF='?src=\ref[src];mach_close=aialerts'>Close</A><BR><BR>"}
	for (var/cat in alarms)
		dat += text("<B>[]</B><BR>\n", cat)
		var/list/L = alarms[cat]
		if(L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/C = alm[2]
				var/list/sources = alm[3]
				dat += "<NOBR>"
				if(C && istype(C, /list))
					var/dat2 = ""
					for (var/obj/machinery/camera/I in C)
						dat2 += text("[]<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>", (dat2=="") ? "" : " | ", src, I, I.c_tag)
					dat += text("-- [] ([])", A.name, (dat2!="") ? dat2 : "No Camera")
				else if(C && istype(C, /obj/machinery/camera))
					var/obj/machinery/camera/Ctmp = C
					dat += text("-- [] (<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>)", A.name, src, C, Ctmp.c_tag)
				else
					dat += text("-- [] (No Camera)", A.name)
				if(sources.len > 1)
					dat += text("- [] sources", sources.len)
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	viewalerts = TRUE
	src << browse(dat, "window=aialerts&can_close=0")

// this verb lets the ai see the stations manifest
/mob/living/silicon/ai/proc/ai_roster()
	show_station_manifest()

/mob/living/silicon/ai/proc/ai_call_shuttle()
	if(isDead())
		to_chat(src, "You can't call the shuttle because you are dead!")
		return
	if(istype(usr,/mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = src
		if(AI.control_disabled)
			to_chat(usr, "Wireless control is disabled!")
			return

	var/justification = stripped_input(usr, "Please input a concise justification for the shuttle call. Note that failure to properly justify a shuttle call may lead to recall or termination.", "Nanotrasen Anti-Comdom Systems")
	if(!justification)
		return
	var/confirm = alert("Are you sure you want to call the shuttle?", "Confirm Shuttle Call", "Yes", "Cancel")
	if(confirm == "Yes")
		call_shuttle_proc(src, justification)

	// hack to display shuttle timer
	if(emergency_shuttle.online)
		var/obj/machinery/computer/communications/C = locate() in machines
		if(C)
			C.post_status("shuttle")

	return

/mob/living/silicon/ai/proc/ai_cancel_call()
	set category = "AI Commands"

	if(isDead())
		to_chat(src, "You can't send the shuttle back because you are dead!")
		return
	if(istype(usr,/mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = src
		if(AI.control_disabled)
			to_chat(src, "Wireless control is disabled!")
			return
	recall_shuttle(src)

/mob/living/silicon/ai/check_eye(var/mob/user as mob)
	if(!current)
		return null
	user.reset_view(current)
	return TRUE

/mob/living/silicon/ai/blob_act()
	if(flags & INVULNERABLE)
		return
	if(stat != DEAD)
		..()
		playsound(loc, 'sound/effects/blobattack.ogg',50,1)
		adjustBruteLoss(60)
		updatehealth()
		return TRUE
	return FALSE

/mob/living/silicon/ai/restrained()
	if(timestopped)
		return TRUE //under effects of time magick
	return FALSE

/mob/living/silicon/ai/emp_act(severity)
	if(flags & INVULNERABLE)
		return

	if(prob(30))
		switch(pick(1,2))
			if(1)
				view_core()
			if(2)
				ai_call_shuttle()
	..()

/mob/living/silicon/ai/ex_act(severity)
	if(flags & INVULNERABLE)
		return

	// if(!blinded) (this is now in flash_eyes)
	flash_eyes(visual = TRUE, affect_silicon = TRUE)

	switch(severity)
		if(1.0)
			if(!isDead())
				adjustBruteLoss(100)
				adjustFireLoss(100)
		if(2.0)
			if(!isDead())
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if(!isDead())
				adjustBruteLoss(30)

	updatehealth()

/mob/living/silicon/ai/put_in_hands(var/obj/item/W)
	return FALSE

/mob/living/silicon/ai/Topic(href, href_list)
	if(usr != src)
		return
	..()
	if(href_list["mach_close"])
		if(href_list["mach_close"] == "aialerts")
			viewalerts = FALSE
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_machine()
		src << browse(null, t1)
	if(href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"])) in cameranet.cameras
	if(href_list["showalerts"])
		ai_alerts()

	if(href_list["show_paper"])
		if(last_paper_seen)
			src << browse(last_paper_seen, "window=show_paper")
	//Carn: holopad requests
	if(href_list["jumptoholopad"])
		var/obj/machinery/hologram/holopad/H = locate(href_list["jumptoholopad"])
		if(stat == CONSCIOUS)
			if(H)
				H.attack_ai(src) //may as well recycle
			else
				to_chat(src, "<span class='notice'>Unable to locate the holopad.</span>")

	if(href_list["say_word"])
		play_vox_word(href_list["say_word"], null, src)
		return

	if(href_list["lawc"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawc"])
		switch(lawcheck[L+1])
			if("Yes")
				lawcheck[L+1] = "No"
			if("No")
				lawcheck[L+1] = "Yes"
		checklaws()

	if(href_list["lawi"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawi"])
		switch(ioncheck[L])
			if("Yes")
				ioncheck[L] = "No"
			if("No")
				ioncheck[L] = "Yes"
		checklaws()

	if(href_list["laws"]) // With how my law selection code works, I changed statelaws from a verb to a proc, and call it through my law selection panel. --NeoFite
		statelaws()

	if(href_list["track"])
		var/mob/target = locate(href_list["track"]) in mob_list
		var/mob/living/silicon/ai/A = locate(href_list["track2"]) in mob_list
		if(A && target)
			A.ai_actual_track(target)
		return

	else if(href_list["faketrack"])
		var/mob/target = locate(href_list["track"]) in mob_list
		var/mob/living/silicon/ai/A = locate(href_list["track2"]) in mob_list
		if(A && target)

			A.cameraFollow = target
			to_chat(A, text("Now tracking [] on camera.", target.name))
			if(usr.machine == null)
				usr.machine = usr

			while (src.cameraFollow == target)
				to_chat(usr, "Target is not on or near any active cameras on the station. We'll check again in 5 seconds (unless you use the cancel-camera verb).")
				sleep(40)
				continue

		return

	if(href_list["open"])
		var/mob/target = locate(href_list["open"])
		var/mob/living/silicon/ai/A = locate(href_list["open2"])
		if(A && target)
			A.open_nearest_door(target)
		return

	return

/mob/living/silicon/ai/bullet_act(var/obj/item/projectile/Proj)
	..(Proj)
	updatehealth()
	return 2

/mob/living/silicon/ai/attack_alien(mob/living/carbon/alien/humanoid/M)
	switch(M.a_intent)
		if(I_HELP)
			visible_message("<span class='notice'>[M] caresses [src]'s plating with its scythe like arm.</span>")

		else //harm
			if(M.unarmed_attack_mob(src))
				if(prob(8))
					flash_eyes(visual = TRUE, type = /obj/abstract/screen/fullscreen/flash/noise)

/mob/living/silicon/ai/attack_animal(mob/living/simple_animal/M as mob)
	M.unarmed_attack_mob(src)

/mob/living/silicon/ai/reset_view(atom/A)
	if(camera_light_on)
		light_cameras()
	if(istype(A,/obj/machinery/camera))
		current = A
	..()


/mob/living/silicon/ai/proc/switchCamera(var/obj/machinery/camera/C)


	src.cameraFollow = null

	if(!C || isDead()) //C.can_use())
		return FALSE

	if(!src.eyeobj)
		view_core()
		return
	// ok, we're alive, camera is good and in our network...
	eyeobj.forceMove(get_turf(C))
	//machine = src

	return TRUE

/mob/living/silicon/ai/triggerAlarm(var/class, area/A, var/O, var/alarmsource)
	if(isDead())
		return TRUE
	var/list/L = alarms[class]
	for (var/I in L)
		if(I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if(!(alarmsource in sources))
				sources += alarmsource
			return TRUE
	var/obj/machinery/camera/C = null
	var/list/CL = null
	if(O && istype(O, /list))
		CL = O
		if(CL.len == 1)
			C = CL[1]
	else if(O && istype(O, /obj/machinery/camera))
		C = O
	L[A.name] = list(A, (C) ? C : O, list(alarmsource))
	if(O)
		if(C && C.can_use())
			queueAlarm("--- [class] alarm detected in [A.name]! (<A HREF=?src=\ref[src];switchcamera=\ref[C]>[C.c_tag]</A>)", class)
		else if(CL && CL.len)
			var/foo = FALSE
			var/dat2 = ""
			for (var/obj/machinery/camera/I in CL)
				dat2 += text("[]<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>", (!foo) ? "" : " | ", src, I, I.c_tag)	//I'm not fixing this shit...
				foo = TRUE
			queueAlarm(text ("--- [] alarm detected in []! ([])", class, A.name, dat2), class)
		else
			queueAlarm(text("--- [] alarm detected in []! (No Camera)", class, A.name), class)
	else
		queueAlarm(text("--- [] alarm detected in []! (No Camera)", class, A.name), class)
	if(viewalerts)
		ai_alerts()
	return TRUE

/mob/living/silicon/ai/cancelAlarm(var/class, area/A as area, obj/origin)
	var/list/L = alarms[class]
	var/cleared = FALSE
	for (var/I in L)
		if(I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if(origin in srcs)
				srcs -= origin
			if(!srcs.len)
				cleared = TRUE
				L -= I
	if(cleared)
		queueAlarm(text("--- [] alarm in [] has been cleared.", class, A.name), class, 0)
		if(viewalerts)
			ai_alerts()
	return !cleared

/mob/living/silicon/ai/cancel_camera()
	src.view_core()


//Replaces /mob/living/silicon/ai/verb/change_network() in ai.dm & camera.dm
//Adds in /mob/living/silicon/ai/proc/ai_network_change() instead
//Addition by Mord_Sith to define AI's network change ability
/mob/living/silicon/ai/proc/ai_network_change()
	set category = "AI Commands"
	set name = "Jump To Network"
	unset_machine()
	src.cameraFollow = null
	var/cameralist[0]

	if(usr.isDead())
		to_chat(usr, "You can't change your camera network because you are dead!")
		return

	var/mob/living/silicon/ai/U = usr

	for (var/obj/machinery/camera/C in cameranet.cameras)
		if(!C.can_use())
			continue

		var/list/tempnetwork = difflist(C.network,RESTRICTED_CAMERA_NETWORKS,1)
		if(tempnetwork.len)
			for(var/i in tempnetwork)
				cameralist[i] = i
	var/old_network = network
	network = input(U, "Which network would you like to view?") as null|anything in cameralist

	if(!U.eyeobj)
		U.view_core()
		return

	if(isnull(network))
		network = old_network // If nothing is selected
	else
		for(var/obj/machinery/camera/C in cameranet.cameras)
			if(!C.can_use())
				continue
			if(network in C.network)
				U.eyeobj.forceMove(get_turf(C))
				break
		to_chat(src, "<span class='notice'>Switched to [network] camera network.</span>")
//End of code by Mord_Sith

/mob/living/silicon/ai/proc/ai_statuschange()
	set category = "AI Commands"
	set name = "AI Status"

	if(usr.isDead())
		to_chat(usr, "You cannot change your emotional status because you are dead!")
		return

	var/emote = input("Please, select a status!", "AI Status", null, null) in ai_emotions //ai_emotions can be found in code/game/machinery/status_display.dm @ 213 (above the AI status display)

	for (var/obj/machinery/M in status_displays) //change status
		if(istype(M, /obj/machinery/ai_status_display))
			var/obj/machinery/ai_status_display/AISD = M
			AISD.emotion = emote
		//if Friend Computer, change ALL displays
		else if(istype(M, /obj/machinery/status_display))

			var/obj/machinery/status_display/SD = M
			if(emote=="Friend Computer")
				SD.friendc = TRUE
			else
				SD.friendc = FALSE
	return

//I am the icon meister. Bow fefore me.	//>fefore
/mob/living/silicon/ai/proc/ai_hologram_change()
	set name = "Change Hologram"
	set desc = "Change the default hologram available to AI to something else."
	set category = "AI Commands"

	var/input
	if(alert("Would you like to select a hologram based on a crew member or switch to unique avatar?",,"Crew Member","Unique")=="Crew Member")

		var/personnel_list[] = list()

		for(var/datum/data/record/t in data_core.locked)//Look in data core locked.
			personnel_list["[t.fields["name"]]: [t.fields["rank"]]"] = t.fields["image"]//Pull names, rank, and image.

		if(personnel_list.len)
			input = input("Select a crew member:") as null|anything in personnel_list
			var/icon/character_icon = personnel_list[input]
			if(character_icon)
				qdel(holo_icon)//Clear old icon so we're not storing it in memory.
				holo_icon = getHologramIcon(icon(character_icon))
		else
			alert("No suitable records found. Aborting.")

	else
		var/icon_list[] = list(
		"Default",
		"Floating face",
		"Cortano",
		"Spoopy",
		"343",
		"Auto",
		"Four-Leaf",
		"Yotsuba",
		"Girl",
		"Boy",
		"SHODAN",
		"Corgi",
		"Mothman"
		)
		input = input("Please select a hologram:") as null|anything in icon_list
		if(input)
			qdel(holo_icon)
			holo_icon = null
			switch(input)
				if("Default")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo1"))
				if("Floating face")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo2"))
				if("Cortano")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo3"))
				if("Spoopy")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo4"))
				if("343")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo5"))
				if("Auto")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo6"))
				if("Four-Leaf")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo7"))
				if("Yotsuba")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo8"))
				if("Girl")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo9"))
				if("Boy")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo10"))
				if("SHODAN")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo11"))
				if("Corgi")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo12"))
				if("Mothman")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo13"))

	return

/spell/aoe_turf/corereturn
	name = "Return to Core"
	panel = MALFUNCTION
	charge_type = Sp_CHARGES
	charge_max = 1
	hud_state = "unshunt"
	override_base = "grey"

/spell/aoe_turf/corereturn/before_target(mob/user)
	if(istype(user.loc, /obj/machinery/power/apc))
		return FALSE
	else
		to_chat(user, "<span class='notice'>You are already in your Main Core.</span>")
		return TRUE

/spell/aoe_turf/corereturn/choose_targets(mob/user = usr)
	return list(user.loc)

/spell/aoe_turf/corereturn/cast(var/list/targets, mob/user)
	var/obj/machinery/power/apc/apc = targets[1]
	apc.malfvacate()

//Toggles the luminosity and applies it by re-entereing the camera.
/mob/living/silicon/ai/verb/toggle_camera_light()
	set name = "Toggle Camera Light"
	set desc = "Toggle internal infrared camera light"
	set category = "AI Commands"
	if(stat != CONSCIOUS)
		return

	camera_light_on = !camera_light_on

	if(!camera_light_on)
		to_chat(src, "Camera lights deactivated.")

		for (var/obj/machinery/camera/C in lit_cameras)
			C.set_light(FALSE)
			lit_cameras = list()

		return

	light_cameras()

	to_chat(src, "Camera lights activated.")
	return

/mob/living/silicon/ai/verb/toggle_station_map()
	set name = "Toggle Station Holomap"
	set desc = "Toggle station holomap on your screen"
	set category = "AI Commands"
	if(isUnconscious())
		return

	station_holomap.toggleHolomap(src,1)

//AI_CAMERA_LUMINOSITY

/mob/living/silicon/ai/proc/light_cameras()
	var/list/obj/machinery/camera/add = list()
	var/list/obj/machinery/camera/remove = list()
	var/list/obj/machinery/camera/visible = list()
	for (var/datum/camerachunk/CC in eyeobj.visibleCameraChunks)
		for (var/obj/machinery/camera/C in CC.cameras)
			if(!C.can_use() || C.light_disabled || get_dist(C, eyeobj) > 7)
				continue
			visible |= C

	add = visible - lit_cameras
	remove = lit_cameras - visible

	for (var/obj/machinery/camera/C in remove)
		C.set_light(FALSE)
		lit_cameras -= C
	for (var/obj/machinery/camera/C in add)
		C.set_light(AI_CAMERA_LUMINOSITY)
		lit_cameras |= C


/mob/living/silicon/ai/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iswrench(W))
		if(anchored)
			user.visible_message("<span class='notice'>\The [user] starts to unbolt \the [src] from the plating...</span>")
			if(!do_after(user, src,40))
				user.visible_message("<span class='notice'>\The [user] decides not to unbolt \the [src].</span>")
				return
			user.visible_message("<span class='notice'>\The [user] finishes unfastening \the [src]!</span>")
			anchored = FALSE
			return
		else
			user.visible_message("<span class='notice'>\The [user] starts to bolt \the [src] to the plating...</span>")
			if(!do_after(user, src,40))
				user.visible_message("<span class='notice'>\The [user] decides not to bolt \the [src].</span>")
				return
			user.visible_message("<span class='notice'>\The [user] finishes fastening down \the [src]!</span>")
			anchored = TRUE
			return
	else
		return ..()


/mob/living/silicon/ai/get_multitool(var/active_only=0)
	return aiMulti

// An AI doesn't become inoperable until -100% (or whatever config.health_threshold_dead is set to)
/mob/living/silicon/ai/system_integrity()
	return (health - config.health_threshold_dead) / 2

/mob/living/silicon/ai/html_mob_check()
	return TRUE

/mob/living/silicon/ai/isTeleViewing(var/client_eye)
	return TRUE
