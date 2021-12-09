
////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - CULTIST							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_cultist
	uniqueID = "Cultist"
	sub_uis_to_spawn = list(
		/datum/mind_ui/bloodcult_cultist_panel,
		/datum/mind_ui/bloodcult_left_panel,
		)
	display_with_parent = TRUE
	y = "BOTTOM"

/datum/mind_ui/bloodcult_cultist/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(iscultist(M))
		return TRUE
	return FALSE


////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - RUNEDRAW						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_cultist_panel
	uniqueID = "Cultist Panel"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/draw_runes_manual,
		/obj/abstract/mind_ui_element/hoverable/draw_runes_guided,
		/obj/abstract/mind_ui_element/hoverable/erase_runes,
		/obj/abstract/mind_ui_element/hoverable/movable/cultist,
		)
	sub_uis_to_spawn = list(
		/datum/mind_ui/bloodcult_runes,
		)
	display_with_parent = TRUE
	y = "BOTTOM"

/datum/mind_ui/bloodcult_cultist_panel/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(iscultist(M) && iscarbon(M))
		return TRUE
	return FALSE


//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/draw_runes_manual
	name = "Trace Runes Manually"
	desc = "(1 BLOOD) Use available blood to write down words. Three words form a rune."
	icon = 'icons/ui/bloodcult/32x32.dmi'
	icon_state = "rune_manual"
	layer = MIND_UI_BUTTON
	offset_x = 111
	offset_y = 39
	mouse_opacity = 1

/obj/abstract/mind_ui_element/hoverable/draw_runes_manual/Click()
	flick("rune_manual-click",src)
	var/mob/M = GetUser()
	if (M)
		var/datum/role/cultist/C = iscultist(M)
		if (C)
			C.verbose = TRUE
		M.DisplayUI("Bloodcult Runes")

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/draw_runes_guided
	name = "Trace Rune with a Guide"
	desc = "(1 BLOOD) Use available blood to write down words. Three words form a rune."
	icon = 'icons/ui/bloodcult/32x32.dmi'
	icon_state = "rune_guide"
	layer = MIND_UI_BUTTON
	offset_x = 111
	offset_y = 39
	mouse_opacity = 1

/obj/abstract/mind_ui_element/hoverable/draw_runes_guided/Click()
	flick("rune_guide-click",src)
	var/mob/M = GetUser()
	if (M)

		var/list/available_runes = list()
		var/i = 1
		for(var/blood_spell in subtypesof(/datum/rune_spell))
			var/datum/rune_spell/instance = blood_spell
			if (initial(instance.secret))
				continue
			available_runes.Add("[initial(instance.name)] - \Roman[i]")
			available_runes["[initial(instance.name)] - \Roman[i]"] = instance
			i++
		var/spell_name = input(M,"Remember how to trace a given rune.", "Trace Rune with a Guide", null) as null|anything in available_runes

		if (spell_name)
			for(var/datum/mind_ui/bloodcult_runes/BR in parent.subUIs)
				BR.queued_rune = available_runes[spell_name]

				var/datum/role/cultist/C = iscultist(M)
				if (C)
					C.verbose = TRUE
				M.DisplayUI("Bloodcult Runes")
				break

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/erase_runes
	name = "Erase Rune"
	desc = "Remove the last word written of the rune you're standing above."
	icon = 'icons/ui/bloodcult/16x32.dmi'
	icon_state = "rune_erase"
	layer = MIND_UI_BUTTON
	offset_x = 95
	offset_y = 39
	mouse_opacity = 1

/obj/abstract/mind_ui_element/hoverable/erase_runes/Click()
	flick("rune_erase-click",src)
	var/mob/M = GetUser()
	if (M)
		var/datum/role/cultist/C = iscultist(M)
		if (C)
			C.erase_rune()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/movable/cultist
	name = "Move Interface (Click and Drag)"
	icon = 'icons/ui/bloodcult/16x32.dmi'
	icon_state = "rune_move"
	layer = MIND_UI_BUTTON
	offset_x = 143
	offset_y = 39
	mouse_opacity = 1

	move_whole_ui = TRUE

////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - LEFT PANEL						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_left_panel
	uniqueID = "Cultist Left Panel"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/bloodcult_role,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_help,
		)
	sub_uis_to_spawn = list(
		/datum/mind_ui/bloodcult_role,
		/datum/mind_ui/bloodcult_help,
		)
	display_with_parent = TRUE
	x = "LEFT"

/datum/mind_ui/bloodcult_left_panel/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(iscultist(M))
		return TRUE
	return FALSE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role
	name = "Choose a Role"
	icon = 'icons/ui/bloodcult/32x32.dmi'
	icon_state = "role"
	offset_x = 6
	offset_y = -92

	var/image/click_me

/obj/abstract/mind_ui_element/hoverable/bloodcult_role/New()
	..()
	click_me = image(icon, src, "click")
	animate(click_me, pixel_y = 16 , time = 7, loop = -1, easing = SINE_EASING)
	animate(pixel_y = 8, time = 7, loop = -1, easing = SINE_EASING)

/obj/abstract/mind_ui_element/hoverable/bloodcult_role/Click()
	flick("role-click",src)

	var/mob/M = GetUser()
	if (M)
		if (M.client)
			M.client.images -= click_me
		var/datum/role/cultist/C = iscultist(M)
		if (C)
			if (C.cultist_role != CULTIST_ROLE_NONE)
				if (C.mentor)
					to_chat(M,"<span class='notice'>You are currently in a mentorship under [C.mentor.antag.name].</span>")
				if (C.acolytes.len > 0)
					var/dat = ""
					for (var/datum/role/cultist/U in C.acolytes)
						dat += "[U.antag.name], "
					to_chat(M,"<span class='notice'>You are currently mentoring [dat].</span>")
				if ((world.time - C.time_role_changed_last) < 5 MINUTES)
					if ((world.time - C.time_role_changed_last) > 4 MINUTES)
						to_chat(M,"<span class='warning'>You must wait [round((5 MINUTES - (world.time - C.time_role_changed_last))/10) + 1] seconds before you can switch role.</span>")
					else
						to_chat(M,"<span class='warning'>You must wait around [round((5 MINUTES - (world.time - C.time_role_changed_last))/600) + 1] minutes before you can switch role.</span>")
					return
				else
					if (C.mentor)
						if(alert(M, "Switching roles will put an end to your mentorship by [C.mentor.antag.name]. Do you wish to proceed?", "Confirmation", "Yes", "No") == "No")
							return
					if (C.acolytes.len > 0)
						if(alert(M, "Switching roles will put an end to your mentorship. Do you wish to proceed?", "Confirmation", "Yes", "No") == "No")
							return

	var/datum/mind_ui/bloodcult_role/role_popup = locate() in parent.subUIs
	if(role_popup)
		role_popup.Display()


/obj/abstract/mind_ui_element/hoverable/bloodcult_role/UpdateIcon()
	var/mob/M = GetUser()
	if (M)
		if (M.client)
			M.client.images -= click_me
		var/datum/role/cultist/C = iscultist(M)
		if (C)
			overlays.len = 0
			switch(C.cultist_role)
				if (CULTIST_ROLE_NONE)
					if (M.client)
						M.client.images += click_me
				if (CULTIST_ROLE_ACOLYTE)
					overlays += "role_acolyte"
				if (CULTIST_ROLE_HERALD)
					overlays += "role_herald"
				if (CULTIST_ROLE_MENTOR)
					overlays += "role_mentor"

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_help
	name = "How do I Cult?"
	icon = 'icons/ui/bloodcult/32x32.dmi'
	icon_state = "help"
	offset_x = 6
	offset_y = -119
	var/clicked = FALSE

	var/image/click_me

/obj/abstract/mind_ui_element/hoverable/bloodcult_help/New()
	..()
	click_me = image(icon, src, "click")
	animate(click_me, pixel_y = 16 , time = 7, loop = -1, easing = SINE_EASING)
	animate(pixel_y = 8, time = 7, loop = -1, easing = SINE_EASING)

/obj/abstract/mind_ui_element/hoverable/bloodcult_help/Appear()
	var/mob/M = GetUser()
	if (M)
		var/datum/role/cultist/C = iscultist(M)
		if (M.client)
			M.client.images -= click_me
		if (C)
			if (C.cultist_role != CULTIST_ROLE_ACOLYTE)
				invisibility = 101	// We only appear to Acolytes
			else
				..()
				if (!C.mentor && !clicked && M.client)
					M.client.images += click_me

/obj/abstract/mind_ui_element/hoverable/bloodcult_help/Click()
	flick("help-click",src)
	if (!clicked)
		clicked = TRUE
		var/mob/M = GetUser()
		if (M)
			if (M.client)
				M.client.images -= click_me
	var/datum/mind_ui/bloodcult_help/tooltip = locate() in parent.subUIs
	if(tooltip)
		tooltip.Display()


////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - ROLE							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_role
	uniqueID = "Cultist Role"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/bloodcult_role_background,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_role_close,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/acolyte,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/herald,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/mentor,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_role_confirm,
		/obj/abstract/mind_ui_element/hoverable/movable/bloodcult_role_move,
		)
	display_with_parent = FALSE

	var/selected_role = CULTIST_ROLE_NONE

/datum/mind_ui/bloodcult_role/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(iscultist(M))
		return TRUE
	return FALSE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_role_background
	name = "Choose a Role"
	icon = 'icons/ui/bloodcult/362x229.dmi'
	icon_state = "background"
	offset_x = -165
	offset_y = -83
	alpha = 200
	layer = MIND_UI_BACK

/obj/abstract/mind_ui_element/bloodcult_role_background/UpdateIcon()
	overlays.len = 0
	var/datum/mind_ui/bloodcult_role/P = parent
	switch(P.selected_role)
		if (CULTIST_ROLE_ACOLYTE)
			overlays += "acolyte"
		if (CULTIST_ROLE_HERALD)
			overlays += "herald"
		if (CULTIST_ROLE_MENTOR)
			overlays += "mentor"
		else
			overlays += "none"

/obj/abstract/mind_ui_element/bloodcult_role_background/Click()
	parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_close
	name = "Close"
	icon = 'icons/ui/bloodcult/16x16.dmi'
	icon_state = "close"
	offset_x = 181
	offset_y = 130
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_close/Click()
	parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select
	icon = 'icons/ui/bloodcult/40x40.dmi'
	icon_state = "button"
	layer = MIND_UI_BUTTON
	var/role_small = ""
	var/role = null

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/New()
	..()
	overlays += "overlay_[role_small]"

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/UpdateIcon()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == role)
		icon_state = "button-down"
	else
		icon_state = "button"

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/StartHovering()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == role)
		return
	else
		..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/StopHovering()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == role)
		return
	else
		..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/Click()
	var/datum/mind_ui/bloodcult_role/P = parent
	P.selected_role = role
	P.Display()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/acolyte
	name = "Acolyte"
	offset_x = -99
	offset_y = 90
	role_small = "acolyte"
	role = CULTIST_ROLE_ACOLYTE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/herald
	name = "Herald"
	offset_x = -3
	offset_y = 90
	role_small = "herald"
	role = CULTIST_ROLE_HERALD

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/mentor
	name = "Mentor"
	offset_x = 93
	offset_y = 90
	role_small = "mentor"
	role = CULTIST_ROLE_MENTOR

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_confirm
	name = "Close"
	icon = 'icons/ui/bloodcult/104x40.dmi'
	icon_state = "confirm"
	offset_x = -36
	offset_y = -68
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_confirm/UpdateIcon()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == CULTIST_ROLE_NONE)
		icon_state = "confirm-grey"
	else
		icon_state = "confirm"
	base_icon_state = icon_state

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_confirm/StartHovering()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == CULTIST_ROLE_NONE)
		return
	icon_state = "[base_icon_state]-hover"

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_confirm/StopHovering()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == CULTIST_ROLE_NONE)
		return
	icon_state = "[base_icon_state]"

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_confirm/Click()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == CULTIST_ROLE_NONE)
		return
	var/mob/M = GetUser()
	if (M)
		var/datum/role/cultist/C = iscultist(M)
		if (C)
			C.ChangeCultistRole(P.selected_role)
			parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/movable/bloodcult_role_move
	name = "Move Interface (Click and Drag)"
	icon = 'icons/ui/bloodcult/16x16.dmi'
	icon_state = "move"
	layer = MIND_UI_BUTTON
	offset_x = -165
	offset_y = 130
	mouse_opacity = 1

	move_whole_ui = TRUE

////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - HELP							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_help
	uniqueID = "Cultist Help"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/bloodcult_help_background,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_help_close,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_help_previous,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_help_next,
		/obj/abstract/mind_ui_element/hoverable/movable/bloodcult_help_move,
		)
	display_with_parent = FALSE

/datum/mind_ui/bloodcult_help/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(iscultist(M))
		return TRUE
	return FALSE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_help_background
	name = "How do I Cult?"
	icon = 'icons/ui/bloodcult/192x192.dmi'
	icon_state = "cult_help"
	offset_x = -80
	offset_y = -150
	layer = MIND_UI_BACK
	var/current_page = 1
	var/max_page = 13

/obj/abstract/mind_ui_element/bloodcult_help_background/UpdateIcon()
	overlays.len = 0
	overlays += "cult_help[current_page]"

/obj/abstract/mind_ui_element/bloodcult_help_background/Click()
	parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_close
	name = "Close"
	icon = 'icons/ui/bloodcult/16x16.dmi'
	icon_state = "close"
	offset_x = 96
	offset_y = -38
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_close/Click()
	parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_previous
	name = "Previous Page"
	icon = 'icons/ui/bloodcult/24x24.dmi'
	icon_state = "button_prev"
	offset_x = -80
	offset_y = -150
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_previous/Appear()
	var/obj/abstract/mind_ui_element/bloodcult_help_background/help = locate() in parent.elements
	if(help)
		if (help.current_page <= 1)
			invisibility = 101
		else
			..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_previous/Click()
	flick("button_prev-click",src)
	var/obj/abstract/mind_ui_element/bloodcult_help_background/help = locate() in parent.elements
	if(help)
		help.current_page = max(help.current_page-1, 1)
		parent.Display()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_next
	name = "Next Page"
	icon = 'icons/ui/bloodcult/24x24.dmi'
	icon_state = "button_next"
	offset_x = 88
	offset_y = -150
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_next/Appear()
	var/obj/abstract/mind_ui_element/bloodcult_help_background/help = locate() in parent.elements
	if(help)
		if (help.current_page >= help.max_page)
			invisibility = 101
		else
			..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_next/Click()
	flick("button_next-click",src)
	var/obj/abstract/mind_ui_element/bloodcult_help_background/help = locate() in parent.elements
	if(help)
		help.current_page = min(help.current_page+1, help.max_page)
		parent.Display()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/movable/bloodcult_help_move
	name = "Move Interface (Click and Drag)"
	icon = 'icons/ui/bloodcult/16x16.dmi'
	icon_state = "move"
	layer = MIND_UI_BUTTON
	offset_x = -80
	offset_y = -38
	mouse_opacity = 1

	move_whole_ui = TRUE

//------------------------------------------------------------

