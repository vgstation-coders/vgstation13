

/datum/mind_ui/malf
	uniqueID = "Malf"
	sub_uis_to_spawn = list(
		/datum/mind_ui/malf_top_panel,
		/datum/mind_ui/malf_left_panel,
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
//							 TOP PANEL							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/malf_top_panel
	uniqueID = "Malf Top Panel"
	y = "TOP"
	display_with_parent = TRUE
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/malf_tech_tab
		)
	var/current_offset = -200
	
/datum/mind_ui/malf_top_panel/Valid()
	var/mob/living/silicon/ai/A = mind.current
	if (!istype(A))
		return FALSE
	if(ismalf(A))
		return TRUE
	return FALSE


/obj/abstract/mind_ui_element/hoverable/malf_tech_tab
	name = "Tech Tab"
	icon = 'icons/ui/malf/32x32.dmi'
	icon_state = "module"
	layer = MIND_UI_BACK
	offset_x = 178
	offset_y = -10


/obj/abstract/mind_ui_element/hoverable/malf_tech_tab/Click()
	var/mob/living/silicon/ai/A = GetUser()
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	M?.tgui_interact(GetUser())
		

/obj/abstract/mind_ui_element/hoverable/malf_power
	name = "BROKEN POWER"
	icon = 'icons/ui/malf/32x48.dmi'
	layer = MIND_UI_BUTTON
	var/datum/malf_module/active/module
	var/initial_name

/obj/abstract/mind_ui_element/hoverable/malf_power/New(turf/loc, var/datum/mind_ui/P, var/datum/malf_module/active/M)
	..()
	icon_state = M.icon_state
	base_icon_state = M.icon_state
	name = M.name
	module = M
	initial_name = name

/obj/abstract/mind_ui_element/hoverable/malf_power/Click()
	module.activate()

/obj/abstract/mind_ui_element/hoverable/malf_power/UpdateIcon()
	var/mob/living/silicon/ai/A = GetUser()
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!istype(A) || !istype(M))
		return
	if(icon_state == "[base_icon_state]-hover")
		return
	if (M.processing_power >= module.activate_cost)
		color = null
	else
		color = grayscale
	name = "[initial_name] ([module.activate_cost] Power)"

/obj/abstract/mind_ui_element/hoverable/malf_power/StartHovering()
	if (color == null)
		..()

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
	overlays.len = 0

	// gauge

	var/image/gauge = image('icons/ui/malf/18x200.dmi', src, "power")
	var/matrix/gauge_matrix = matrix()
	gauge_matrix.Scale(1,M.processing_power/M.max_processing_power)
	gauge.transform = gauge_matrix
	gauge.layer = MIND_UI_BUTTON
	gauge.pixel_y = round(-79 + 100 * (M.processing_power/M.max_processing_power))
	overlays += gauge

	// cover

	var/image/cover = image(icon, src, "malf_gauge_cover")
	cover.layer = MIND_UI_FRONT
	overlays += cover

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



//------------------------------------------------------------




