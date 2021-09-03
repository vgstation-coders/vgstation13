
////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - CULTIST							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_cultist
	uniqueID = "Cultist"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/draw_runes_manual,
		/obj/abstract/mind_ui_element/hoverable/draw_runes_guided,
		/obj/abstract/mind_ui_element/hoverable/erase_runes,
		/obj/abstract/mind_ui_element/hoverable/movable/cultist,
		)
	display_with_parent = TRUE
	y = "BOTTOM"

/datum/mind_ui/bloodcult_cultist/Valid()
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
		M.DisplayUI("Bloodcult Runes")

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

//------------------------------------------------------------
