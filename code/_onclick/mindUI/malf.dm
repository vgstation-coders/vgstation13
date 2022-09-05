

/datum/mind_ui/malf
	uniqueID = "Malf"
	sub_uis_to_spawn = list(
	//	/datum/mind_ui/malf_top_panel,
		/datum/mind_ui/malf_left_panel,
		/datum/mind_ui/malf_win_panel
		)

/datum/mind_ui/malf/Valid()
	var/mob/living/silicon/A = mind.current
	if (!istype(A))
		return FALSE
	if(ismalf(A))
		return TRUE
	return FALSE

////////////////////////////////////////////////////////////////////
//																  //
//						   LEFT PANEL							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/malf_left_panel
	uniqueID = "Malf Left Panel"
	x = "LEFT"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/malf_power_gauge,
		/obj/abstract/mind_ui_element/malf_power_count,
		)
	display_with_parent = TRUE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/malf_power_gauge
	name = "Processing Power"
	icon = 'icons/ui/malf/21x246.dmi'
	icon_state = "malf_gauge_background"
	layer = MIND_UI_BACK
	offset_y = -117

/obj/abstract/mind_ui_element/malf_power_gauge/UpdateIcon()
	var/mob/living/silicon/ai/A = GetUser()
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!istype(A) || !istype(M))
		return

	// cover
	var/image/cover = image(icon, src, "malf_gauge_cover")
	cover.layer = MIND_UI_FRONT

	// gauge
	var/image/gauge = image('icons/ui/malf/18x200.dmi', src, "power")
	var/matrix/gauge_matrix = matrix()
	gauge_matrix.Scale(1,M.processing_power/M.max_processing_power)
	gauge.transform = gauge_matrix
	gauge.layer = MIND_UI_BUTTON
	gauge.pixel_y = round(-79 + 100 * (M.processing_power/M.max_processing_power))
	

	overlays = 0
	overlays += cover
	overlays += gauge


//------------------------------------------------------------

/obj/abstract/mind_ui_element/malf_power_count
	icon = 'icons/ui/malf/21x246.dmi'
	icon_state = ""
	layer = MIND_UI_FRONT+1
	mouse_opacity = 0

/obj/abstract/mind_ui_element/malf_power_count/UpdateIcon()
	var/mob/living/silicon/ai/A = GetUser()
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!istype(M) || !istype(A))
		return
	overlays.len = 0
	overlays += String2Image("[round(M.processing_power)]")
	if(M.processing_power >= 100)
		offset_x = 0
	else if(M.processing_power >= 10)
		offset_x = 3
	else
		offset_x = 6
	UpdateUIScreenLoc()




////////////////////////////////////////////////////////////////////
//																  //
//						   WIN PANEL							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/malf_win_panel
	uniqueID = "Malf Left Panel"
	x = "LEFT"
	element_types_to_spawn = list(
//		/obj/abstract/mind_ui_element/hoverable/malf_win/overload,
		/obj/abstract/mind_ui_element/hoverable/malf_win/nuke
		)
	display_with_parent = TRUE
	

/datum/mind_ui/malf_win_panel/Valid()
	var/mob/living/silicon/ai/A = GetUser()
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!istype(M) || !istype(A))
		return FALSE			
	if(!M.takeover)
		return FALSE			
	return TRUE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/malf_win
	icon = 'icons/ui/malf/48x32.dmi'
	icon_state = ""
	layer = MIND_UI_FRONT+1
	
/obj/abstract/mind_ui_element/hoverable/malf_win/UpdateIcon()
	var/mob/living/silicon/ai/A = GetUser()
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(M.destroyed_station)
		color = grayscale
	if(!istype(M) || !istype(A))
		Hide()
	if(!M.takeover)
		Hide()

/obj/abstract/mind_ui_element/hoverable/malf_win/StartHovering()
	if (color == null)
		..()


/obj/abstract/mind_ui_element/hoverable/malf_win/Click()
	var/mob/living/silicon/ai/A = GetUser()
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!istype(M) || !istype(A))
		return FALSE			// HAHA NOPE
	if(!M.takeover || M.destroyed_station == TRUE)
		return FALSE			// NO WAY
	return TRUE



// The idea was to overload just about every machine on station but explosions are super slow 
// I'm leaving this as a comment in case anyone wants to optimize this

/*

/obj/abstract/mind_ui_element/hoverable/malf_win/overload
	name = "Overload Everything"
	icon_state = "overload"
	offset_y = 100

/obj/abstract/mind_ui_element/hoverable/malf_win/overload/Click()
	set background = 1
	if(!..())
		return
	var/mob/living/silicon/ai/A = GetUser()
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	M.destroyed_station = TRUE
	A.DisplayUI("Malf")

	to_chat(world, "<span class='big danger'>BZZZZT!</span>")
	world << sound('sound/machines/Alarm.ogg')
	for(var/obj/machinery/machine in all_machines)
		if(machine.z != map.zMainStation)
			continue

		if(istype(machine, /obj/machinery/atmospherics))
			continue

		if(prob(50))
			continue

		spawn(rand(0, 300))
			machine.shake_animation(4, 4, 0.2 SECONDS, 20)
			spawn(4 SECONDS)
				if(machine)
					explosion(get_turf(machine), 1, 3, 5, 5) 
					qdel(machine)
		CHECK_TICK

*/

/obj/abstract/mind_ui_element/hoverable/malf_win/nuke
	name = "Activate the Nuclear Device"
	icon_state = "nuke"
	offset_y = 140

/obj/abstract/mind_ui_element/hoverable/malf_win/nuke/Click()
	if(!..())
		return
	var/mob/living/silicon/ai/A = GetUser()
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	
	for(var/obj/machinery/nuclearbomb/N in nuclear_bombs)
		if(N.z != map.zMainStation)
			continue
		M.destroyed_station = TRUE
		A.DisplayUI("Malf")
		to_chat(world, "<span class='big danger'>Self-destruction signal received. Self-destructing in 10...</span>")
		world << sound('sound/machines/Alarm.ogg')
		N.icon_state = "nuclearbomb3"
		for (var/i=9 to 1 step -1)
			sleep(10)
			to_chat(world, "<span class='danger'>[i]...</span>")
		N.safety = 0
		N.explode(FALSE)
		var/datum/faction/malf/MF = find_active_faction_by_member(M)
		MF.stage(FACTION_VICTORY)
		return
	to_chat(A, "<span class='warning'>There is no nuclear bomb aboard the station!</span>")
	A.DisplayUI("Malf")