
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
		/datum/mind_ui/winner_beg_cards,
		/datum/mind_ui/loser_beg_cards,
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
/datum/mind_ui/winner_beg_cards
	uniqueID = "RPS Winner Beg Cards"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/mercy_winner,
		/obj/abstract/mind_ui_element/hoverable/more_winner,
		)
	display_with_parent = TRUE

//------------------------------------------------------------
/datum/mind_ui/loser_beg_cards
	uniqueID = "RPS Loser Beg Cards"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/mercy_loser,
		/obj/abstract/mind_ui_element/hoverable/more_loser,
		)
	display_with_parent = TRUE

//------------------------------------------------------------
/obj/abstract/mind_ui_element/hoverable/rock
	name = "Rock"
	desc = "lol"
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
	name = "Paper"
	desc = "lol..."
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
	name = "Scissors"
	desc = "lol!"
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

/obj/abstract/mind_ui_element/hoverable/mercy_winner
	name = "Mercy"
	desc = "lol!"
	icon = 'icons/ui/rockpaperscissors/228x192.dmi'
	icon_state = "mercy"
	layer = MIND_UI_BUTTON
	offset_x = -220
	offset_y = -220
	mouse_opacity = 1

/obj/abstract/mind_ui_element/hoverable/mercy_winner/StartHovering()
	icon_state = "mercy"

/obj/abstract/mind_ui_element/hoverable/mercy_winner/StopHovering()
	icon_state = "mercy"

/obj/abstract/mind_ui_element/hoverable/mercy_winner/Click()
	usr.rps_mercy_or_more = "mercy"
//------------------------------------------------------------
/obj/abstract/mind_ui_element/hoverable/mercy_loser
	name = "Mercy!"
	desc = "lol!"
	icon = 'icons/ui/rockpaperscissors/228x192.dmi'
	icon_state = "mercy-beg"
	layer = MIND_UI_BUTTON
	offset_x = -220
	offset_y = -220
	mouse_opacity = 1

/obj/abstract/mind_ui_element/hoverable/mercy_loser/StartHovering()
	icon_state = "mercy-beg"

/obj/abstract/mind_ui_element/hoverable/mercy_loser/StopHovering()
	icon_state = "mercy-beg"

/obj/abstract/mind_ui_element/hoverable/mercy_loser/Click()
	usr.rps_mercy_or_more = "mercy"
//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/more_winner
	name = "More!"
	desc = "lol!"
	icon = 'icons/ui/rockpaperscissors/228x192.dmi'
	icon_state = "more"
	layer = MIND_UI_BUTTON
	offset_x = 20
	offset_y = -220
	mouse_opacity = 1

/obj/abstract/mind_ui_element/hoverable/more_winner/StartHovering()
	icon_state = "more"

/obj/abstract/mind_ui_element/hoverable/more_winner/StopHovering()
	icon_state = "more"

/obj/abstract/mind_ui_element/hoverable/more_winner/Click()
	usr.rps_mercy_or_more = "more"
//------------------------------------------------------------
/obj/abstract/mind_ui_element/hoverable/more_loser
	name = "More"
	desc = "lol!"
	icon = 'icons/ui/rockpaperscissors/228x192.dmi'
	icon_state = "more-beg"
	layer = MIND_UI_BUTTON
	offset_x = 15
	offset_y = -220
	mouse_opacity = 1

/obj/abstract/mind_ui_element/hoverable/more_loser/StartHovering()
	icon_state = "more-beg"

/obj/abstract/mind_ui_element/hoverable/more_loser/StopHovering()
	icon_state = "more-beg"

/obj/abstract/mind_ui_element/hoverable/more_loser/Click()
	usr.rps_mercy_or_more = "more"
//------------------------------------------------------------
