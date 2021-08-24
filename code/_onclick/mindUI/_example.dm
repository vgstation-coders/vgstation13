
/*
	calling DisplayUI("Hello World") on a mob with a client and a mind gives them a panel with a green button that sends "Hello World!" to their chat, and a red button that hides the UI.
*/


////////////////////////////////////////////////////////////////////
//																  //
//						   HELLO WORLD							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/test_hello_world_parent
	uniqueID = "Hello World"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/test_back,
		)
	sub_uis_to_spawn = list(
		/datum/mind_ui/test_hello_world,
		)
	x = "LEFT"
	y = "BOTTOM"
	display_with_parent = TRUE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/test_back
	icon = 'icons/ui/480x480.dmi'
	icon_state = "test_background"
	layer = FULLSCREEN_LAYER
	plane = FULLSCREEN_PLANE
	blend_mode = BLEND_ADD
	mouse_opacity = 0


////////////////////////////////////////////////////////////////////
//																  //
//						   HELLO WORLD CHILD					  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/test_hello_world
	uniqueID = "Hello World Panel"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/test_window,
		/obj/abstract/mind_ui_element/hoverable/test_close,
		/obj/abstract/mind_ui_element/hoverable/test_hello,
		/obj/abstract/mind_ui_element/hoverable/movable/test_move,
		)
	display_with_parent = TRUE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/test_window
	icon = 'icons/ui/192x192.dmi'
	icon_state = "test_192x128"
	layer = MIND_UI_BACK
	offset_x = -80
	offset_y = -80
	alpha = 180
	mouse_opacity = 1

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/test_close
	icon = 'icons/ui/32x32.dmi'
	icon_state = "close"
	layer = MIND_UI_BUTTON
	offset_x = 80
	offset_y = 16
	mouse_opacity = 1

/obj/abstract/mind_ui_element/hoverable/test_close/Appear()
	..()
	mouse_opacity = 1
	icon_state = "close"
	flick("close-spawn",src)

/obj/abstract/mind_ui_element/hoverable/test_close/Hide()
	mouse_opacity = 0
	icon_state = "blank"
	flick("close-click",src)
	spawn(10)
		..()

/obj/abstract/mind_ui_element/hoverable/test_close/Click()
	var/datum/mind_ui/ancestor = parent.GetAncestor()
	ancestor.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/test_hello
	icon = 'icons/ui/32x32.dmi'
	icon_state = "hello"
	layer = MIND_UI_BUTTON
	offset_y = -16
	mouse_opacity = 1

/obj/abstract/mind_ui_element/hoverable/test_hello/Click()
	flick("hello-click",src)
	to_chat(GetUser(), "[bicon(src)] Hello World!")

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/movable/test_move
	icon = 'icons/ui/32x32.dmi'
	icon_state = "move"
	layer = MIND_UI_BUTTON
	offset_x = -80
	offset_y = 16
	mouse_opacity = 1

	move_whole_ui = TRUE

//------------------------------------------------------------
