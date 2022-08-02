
/*
	calling DisplayUI("Hello World") on a mob with a client and a mind gives them a panel with a green button that sends "Hello World!" to their chat, and a red button that hides the UI.
*/


////////////////////////////////////////////////////////////////////
//																  //
//						   HELLO WORLD							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/rock_paper_scissors_ui
	uniqueID = "Rock Paper Scissors"
	sub_uis_to_spawn = list(
		/datum/mind_ui/rock_paper_scissors_intent_cards,
		)
	x = "LEFT"
	y = "BOTTOM"
	display_with_parent = TRUE

//------------------------------------------------------------

////////////////////////////////////////////////////////////////////
//																  //
//						   HELLO WORLD CHILD					  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/rock_paper_scissors_intent_cards
	uniqueID = "Rock Paper Scissors Cards"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/rock,
		/obj/abstract/mind_ui_element/hoverable/paper,
		/obj/abstract/mind_ui_element/hoverable/scissors,
		)
	display_with_parent = TRUE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/rock
	name = "Trace Runes Manually"
	desc = "(1 BLOOD) Use available blood to write down words. Three words form a rune."
	icon = 'icons/ui/rockpaperscissors/152x192.dmi'
	icon_state = "rock"
	layer = MIND_UI_BUTTON
	offset_x = -220
	offset_y = -220
	mouse_opacity = 1

/obj/abstract/mind_ui_element/hoverable/rock/StartHovering()
	icon_state = "rock"

/obj/abstract/mind_ui_element/hoverable/rock/StopHovering()
	icon_state = "rock"

/* /obj/abstract/mind_ui_element/hoverable/rock/Appear()
	..()
	mouse_opacity = 1
	icon_state = "close"

/obj/abstract/mind_ui_element/hoverable/rock/Hide()
	mouse_opacity = 0
	icon_state = "blank"
	flick("close-click",src)
	spawn(10)
		..()   */

/obj/abstract/mind_ui_element/hoverable/rock/Click()
	usr.rps_intent = "rock"

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/paper
	name = "Trace Runes Manually"
	desc = "(1 BLOOD) Use available blood to write down words. Three words form a rune."
	icon = 'icons/ui/rockpaperscissors/152x192.dmi'
	icon_state = "paper"
	layer = MIND_UI_BUTTON
	offset_x = -60
	offset_y = -220
	mouse_opacity = 1


/obj/abstract/mind_ui_element/hoverable/paper/StartHovering()
	icon_state = "paper"

/obj/abstract/mind_ui_element/hoverable/paper/StopHovering()
	icon_state = "paper"


/obj/abstract/mind_ui_element/hoverable/paper/Click()
	usr.rps_intent = "paper"

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/scissors
	name = "Trace Runes Manually"
	desc = "(1 BLOOD) Use available blood to write down words. Three words form a rune."
	icon = 'icons/ui/rockpaperscissors/152x192.dmi'
	icon_state = "scissors"
	layer = MIND_UI_BUTTON
	offset_x = 100
	offset_y = -220
	mouse_opacity = 1

/obj/abstract/mind_ui_element/hoverable/scissors/StartHovering()
	icon_state = "scissors"

/obj/abstract/mind_ui_element/hoverable/scissors/StopHovering()
	icon_state = "scissors"

/obj/abstract/mind_ui_element/hoverable/scissors/Click()
	usr.rps_intent = "scissors"
//------------------------------------------------------------
