

/datum/mind_ui/malf
	uniqueID = "Malf"
	sub_uis_to_spawn = list(
		/datum/mind_ui/malf_top_panel,
		/datum/mind_ui/malf_left_panel,
		/datum/mind_ui/malf_right_panel,
		)

/datum/mind_ui/malf/Valid()
	var/mob/living/silicon/ai/A = mind.current
	if (!A)
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
   	

/datum/mind_ui/malf_top_panel/proc/SortPowers()
	var/space_size = 40		//32 px icon, 8 px spacer
	var/new_offset = (space_size * Floor(elements.len / 2, 1))*-1
	if(elements.len % 2 == 0)
		new_offset += 20
	for(var/obj/abstract/mind_ui_element/hoverable/malf_power/E in elements)
		E.offset_x = new_offset
		E.UpdateUIScreenLoc()
		new_offset += space_size

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


////////////////////////////////////////////////////////////////////
//																  //
//						   RIGHT PANEL							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/malf_right_panel
	uniqueID = "Malf Right Panel"
	x = "RIGHT"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/malf_tech_tab,
		)
	sub_uis_to_spawn = list(
		/datum/mind_ui/malf_tech_window,
		)
	display_with_parent = TRUE



//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/malf_tech_tab
	name = "Tech Tab"
	icon = 'icons/ui/malf/22x64.dmi'
	icon_state = "techtab"
	layer = MIND_UI_BACK
	offset_y = -88
	var/opened = FALSE


/obj/abstract/mind_ui_element/hoverable/malf_tech_tab/Click()
	var/datum/mind_ui/malf_tech_window/techtree = locate() in parent.subUIs
	if(techtree)
		if(opened)
			SlideUIElement(0, offset_y, 3, MIND_UI_BUTTON)
			techtree.Hide()
		else
			SlideUIElement(-256, offset_y, 3, MIND_UI_BUTTON)
			techtree.Display()		
		opened = !opened
		
	

////////////////////////////////////////////////////////////////////
//																  //
//					      TECH TREE TAB     					  //
//																  //
////////////////////////////////////////////////////////////////////


/datum/mind_ui/malf_tech_window
	uniqueID = "Malf Tech Window"
	x = "RIGHT"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/malf_tech_background,
		/obj/abstract/mind_ui_element/hoverable/malf_upgrade/coreshield,
		/obj/abstract/mind_ui_element/hoverable/malf_upgrade/explosivecore,
		/obj/abstract/mind_ui_element/hoverable/malf_upgrade/explosiveborgs,
		/obj/abstract/mind_ui_element/hoverable/malf_upgrade/holopadfaker,
		/obj/abstract/mind_ui_element/hoverable/malf_upgrade/overload
		)
	display_with_parent = FALSE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/malf_tech_background
	name = "Tech Window Background"
	icon = 'icons/ui/malf/256x256.dmi'
	icon_state = "background"
	offset_y = -112
	offset_x = 256
	layer = MIND_UI_BACK

/obj/abstract/mind_ui_element/malf_tech_background/Appear()
	invisibility = 0
	SlideUIElement(0, offset_y, 3, MIND_UI_BACK)
	
/obj/abstract/mind_ui_element/malf_tech_background/Hide()
	SlideUIElement(256, offset_y, 3, MIND_UI_BACK, TRUE)
	

//------------------------------------------------------------


/obj/abstract/mind_ui_element/hoverable/malf_upgrade
	name = "BROKEN UPGRADE"
	desc = "This is a broken description."
	icon = 'icons/ui/malf/32x32.dmi'
	icon_state = "bg"
	var/upgrade_icon = ""
	layer = MIND_UI_BUTTON
	var/module_type
	var/purchased = FALSE
	var/visible_offset_x = 0
	var/cost

/obj/abstract/mind_ui_element/hoverable/malf_upgrade/New()
	..()
	var/image/overlay = image(icon, src, upgrade_icon)
	overlays += overlay
	offset_x = visible_offset_x + 256

/obj/abstract/mind_ui_element/hoverable/malf_upgrade/Click()
	if(purchased)
		return
	var/mob/living/silicon/ai/A = GetUser()
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!istype(A) || !istype(M))
		return
	if (M.processing_power >= cost)
		M.add_power(-cost)
		purchased = TRUE
		UpdateIcon()
		new module_type(A)

/obj/abstract/mind_ui_element/hoverable/malf_upgrade/UpdateIcon()
	var/mob/living/silicon/ai/A = GetUser()
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(!istype(A) || !istype(M))
		return
	if (purchased)
		icon_state = "[base_icon_state]-purchased"
		color = null
		return
	else if(icon_state == "[base_icon_state]-hover")
		return
	else if (M.processing_power >= cost)
		color = null
	else
		color = grayscale

/obj/abstract/mind_ui_element/hoverable/malf_upgrade/MouseEntered(location,control,params)
	if (color == null && !purchased)
		icon_state = "[base_icon_state]-hover"
	if(!purchased)
		openToolTip(GetUser(),src,params,title = name,content = desc,theme = "radial-malf")
	
/obj/abstract/mind_ui_element/hoverable/malf_upgrade/StopHovering()
	if(color == null && !purchased)
		icon_state = base_icon_state
	closeToolTip(GetUser())

/obj/abstract/mind_ui_element/hoverable/malf_upgrade/Appear()
	invisibility = 0
	SlideUIElement(visible_offset_x, offset_y, 3, MIND_UI_BUTTON)
	UpdateIcon()

/obj/abstract/mind_ui_element/hoverable/malf_upgrade/Hide()
	SlideUIElement(visible_offset_x + 256, offset_y, 3, MIND_UI_BUTTON, TRUE)


//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/malf_upgrade/coreshield
	name = "Firewall (20)"
	desc = "Deploy a firewall to reduce damage to your core and make it immune to lasers."
	upgrade_icon = "coreshield"
	module_type = /datum/malf_module/active/coreshield
	cost = 10
	visible_offset_x = -216
	offset_y = 104

/obj/abstract/mind_ui_element/hoverable/malf_upgrade/explosivecore
	name = "Rigged AI Core"
	desc = "Overclock the central processing unit in your core, causing it to explode on system shutdown."
	upgrade_icon = "explosivecore"
	module_type = /datum/malf_module/explosivecore
	cost = 10
	offset_y = 104
	visible_offset_x = -176

/obj/abstract/mind_ui_element/hoverable/malf_upgrade/explosiveborgs
	name = "Rigged Cyborgs"
	desc = "Hijack the thermal regulators in your cyborgs, causing it to explode on system shutdown."
	upgrade_icon = "explosiveborgs"
	module_type = /datum/malf_module/explosiveborgs
	cost = 10
	offset_y = 104 
	visible_offset_x = -136


/obj/abstract/mind_ui_element/hoverable/malf_upgrade/holopadfaker
	name = "Lifelike Textures"
	desc = "Modifies the programming in hacked station holopads, allowing you to mimic the appearance and voice of a crewmember."
	upgrade_icon = "holopadfake"
	module_type = /datum/malf_module/holopadfaker
	cost = 10
	offset_y = 104 
	visible_offset_x = -96

/obj/abstract/mind_ui_element/hoverable/malf_upgrade/overload
	name = "Machine Overload"
	desc = "Allows you to hijack the thermal regulators within station machinery, causing them to explode violently."
	upgrade_icon = "overload"
	module_type = /datum/malf_module/overload
	cost = 10
	offset_y = 104 
	visible_offset_x = -56