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

/mob/living/silicon/ai/proc/switchCamera(var/obj/machinery/camera/C)
	cameraFollow = null

	if(!C || isDead()) //C.can_use())
		return FALSE

	if(!src.eyeobj)
		view_core()
		return
	// ok, we're alive, camera is good and in our network...
	eyeobj.forceMove(get_turf(C))
	return TRUE

/mob/living/silicon/ai/cancel_camera()
	view_core()

/mob/living/silicon/ai/reset_view(atom/A)
	if(camera_light_on)
		light_cameras()
	if(istype(A,/obj/machinery/camera))
		current = A
	..()

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

/mob/living/silicon/ai/proc/ai_roster()
	show_station_manifest()

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

// displays the malf_ai information if the AI is the malf
/mob/living/silicon/ai/show_malf_ai()
	var/datum/faction/malf/malf = find_active_faction_by_member(src.mind.GetRole(MALF))
	if(malf && malf.apcs >= 3)
		stat(null, "Amount of APCS hacked: [malf.apcs]")
		stat(null, "Time until station control secured: [max(malf.AI_win_timeleft/(malf.apcs/3), 0)] seconds")

/mob/living/silicon/ai/Greet()
	to_chat(src, "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>")
	to_chat(src, "<B>To look at other parts of the station, click on yourself to get a camera menu.</B>")
	to_chat(src, "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>")
	to_chat(src, "To use something, simply click on it.")
	to_chat(src, "Use say :b to speak to other silicons through binary.")
	show_laws()
	if(!ismalf(src))
		to_chat(src, "<b>These laws may be changed by others.</b>")


/mob/living/silicon/ai/proc/PickAIName()
	var/list/possibleNames = ai_names
	var/pickedName = null

	while(!pickedName)
		pickedName = pick(ai_names)
		for(var/mob/living/silicon/ai/A in ai_list)
			if(A.real_name == pickedName && possibleNames.len > 1) //fixing the theoretically possible infinite loop
				possibleNames -= pickedName
				pickedName = null

	real_name = pickedName
	name = real_name

/mob/living/silicon/ai/proc/SetAILanguages()
	//AIs speak all languages that aren't restricted(XENO, CULT).
	for(var/language_name in all_languages)
		var/datum/language/lang = all_languages[language_name]
		if(!(lang.flags & RESTRICTED) && !(lang in languages))
			add_language(lang.name)

	//But gal common is restricted so let's add it manually.
	add_language(LANGUAGE_GALACTIC_COMMON)
	src.default_language = all_languages[LANGUAGE_GALACTIC_COMMON]

/mob/living/silicon/ai/proc/SetAIRadio()
	if(!radio)
		radio = new /obj/item/device/radio/borg/ai(src)
		radio.recalculateChannels()

/mob/living/silicon/ai/proc/SetAIPDA()
	aiPDA = new(src)
	aiPDA.set_name_and_job(name,job)

/mob/living/silicon/ai/proc/SetAICamera()
	if(!aicamera)
		aicamera = new /obj/item/device/camera/silicon/ai_camera(src)
		verbs.Add(
			/mob/living/silicon/ai/proc/ai_network_change,
			/mob/living/silicon/ai/proc/ai_statuschange,
			/mob/living/silicon/ai/proc/ai_hologram_change
			)

/mob/living/silicon/ai/proc/SetAILaws(var/datum/ai_laws/L)
    //Determine the AI's lawset
	if(L && istype(L,/datum/ai_laws))
		laws = L
	else
		laws = getLawset(src)

	verbs += /mob/living/silicon/ai/proc/show_laws_verb

/mob/living/silicon/ai/proc/SetAIComponents()
	SetAIRadio()
	SetAIPDA()
	SetAICamera()
	station_holomap = new(src)
	aiMulti = new(src)