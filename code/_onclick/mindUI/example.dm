
/////////////////////////////TESTING/////////////////////////////

/mob/proc/testUI(var/ui_ID)
	if (ui_ID)
		DisplayUI(ui_ID)

/datum/mind_ui/test_hello_world_parent
	uniqueID = "Hello World Parent"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/test_back,
		)
	sub_uis_to_spawn = list(
		/datum/mind_ui/test_hello_world,
		)
	x = "LEFT"
	y = "BOTTOM"

/datum/mind_ui/test_hello_world_parent/Initialize()
	Display()

/datum/mind_ui/test_hello_world
	uniqueID = "Hello World"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/test_window,
		/obj/abstract/mind_ui_element/hoverable/test_close,
		/obj/abstract/mind_ui_element/hoverable/test_hello,
		)

/datum/mind_ui/test_hello_world/Initialize()
	Display()

/obj/abstract/mind_ui_element/test_back
	icon = 'icons/ui/480x480.dmi'
	icon_state = "test_background"
	layer = FULLSCREEN_LAYER
	plane = FULLSCREEN_PLANE
	blend_mode = BLEND_ADD

/obj/abstract/mind_ui_element/test_window
	icon = 'icons/ui/192x192.dmi'
	icon_state = "test_192x128"
	layer = 10
	offset_x = -80
	offset_y = -80
	alpha = 180
	mouse_opacity = 1

/obj/abstract/mind_ui_element/hoverable/test_close
	icon = 'icons/ui/32x32.dmi'
	icon_state = "close"
	layer = 11
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

/obj/abstract/mind_ui_element/hoverable/test_close/StartHovering()
	icon_state = "close-hover"

/obj/abstract/mind_ui_element/hoverable/test_close/StopHovering()
	icon_state = "close"

/obj/abstract/mind_ui_element/hoverable/test_close/Click()
	var/datum/mind_ui/ancestor = parent.GetAncestor()
	ancestor.Hide()

/obj/abstract/mind_ui_element/hoverable/test_hello
	icon = 'icons/ui/32x32.dmi'
	icon_state = "hello"
	layer = 11
	offset_y = -16
	mouse_opacity = 1

/obj/abstract/mind_ui_element/hoverable/test_hello/StartHovering()
	icon_state = "hello-hover"

/obj/abstract/mind_ui_element/hoverable/test_hello/StopHovering()
	icon_state = "hello"

/obj/abstract/mind_ui_element/hoverable/test_hello/Click()
	flick("hello-click",src)
	to_chat(usr, "[bicon(src)] Hello World!")

/////////////////////////////TESTING/////////////////////////////