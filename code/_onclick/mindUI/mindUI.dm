/*
	mind_ui, started on 2021/07/22 by Deity.

	instead of being stored in the mob like /datum/hud, this one is stored in a mob's /datum/mind 's activeUIs list

	A mind can store several separate mind_uis, think of each one as its own menu/pop-up, that in turns contains a list of /obj/mind_ui_element,
	or other /datum/mind_ui that
*/

/datum/mind_ui
	var/uniqueID = "Default"
	var/datum/mind/mind
	var/list/elements = list()	// the objects displayed by the UI. Those can be both non-interactable objects (background/fluff images, foreground shaders) and clickable interace buttons.
	var/list/subUIs	= list()	// children UI. Closing the parent UI closes all the children.
	var/datum/mind_ui/parent = null

	var/x = "CENTER"
	var/y = "CENTER"

	var/list/element_types_to_spawn = list()
	var/list/sub_uis_to_spawn = list()

/datum/mind_ui/New(var/datum/mind/M)
	if (!istype(M))
		qdel(src)
		return
	mind = M
	..()
	for (var/element_type in element_types_to_spawn)
		elements += new element_type(null, src)
	for (var/ui_type in sub_uis_to_spawn)
		var/datum/mind_ui/child = new ui_type(mind)
		subUIs += child
		mind.activeUIs[child.uniqueID] = child
		child.parent = src
	Initialize()

/*
	Stuff the UI does when first created
*/
/datum/mind_ui/proc/Initialize()


/*
	Send every element to the client if they're not there yet
*/
/datum/mind_ui/proc/DisplayToPlayer()
	if (mind.current)
		var/mob/M = mind.current
		if (!M.client)
			return

		for (var/obj/abstract/mind_ui_element/element in elements)
			mind.current.client.screen |= element
			element.Appear()


/*
	Closes the UI. Every child UI in subUIs will be closed as well.
*/
/datum/mind_ui/proc/Close()
	CloseChildren()
	CloseElements()
/*
	Closes every child UI
*/
/datum/mind_ui/proc/CloseChildren()
	for (var/datum/mind_ui/child in subUIs)
		child.Close()
/*
	Closes every element
*/
/datum/mind_ui/proc/CloseElements()
	for (var/obj/abstract/mind_ui_element/element in elements)
		element.Hide()

/*
	Closes the root parent by default.
		* levels: can be specified to only close parents up to [levels] levels above.
*/
/datum/mind_ui/proc/CloseParent(var/levels=0)
	if (levels <= 0)
		var/datum/mind_ui/ancestor = GetAncestor()
		ancestor.Close()
		return
	else
		var/datum/mind_ui/to_close = src
		while (levels > 0)
			if (to_close.parent)
				levels--
				to_close = to_close.parent
			else
				break
		to_close.Close()

/*
	Returns the uppermost UI
*/
/datum/mind_ui/proc/GetAncestor()
	if (parent)
		return parent.GetAncestor()
	else
		return src


/////////////////////////////UI ELEMENT/////////////////////////////

/obj/abstract/mind_ui_element
	mouse_opacity = 0
	plane = HUD_PLANE

	var/datum/mind_ui/parent = null
	var/element_flags = 0	// PROCESSING

	var/offset_x = 0
	var/offset_y = 0

/obj/abstract/mind_ui_element/New(loc/turf, var/datum/mind_ui/P)
	if (!istype(P))
		qdel(src)
		return
	..()
	parent = P
	screen_loc = GetScreenLoc()

/obj/abstract/mind_ui_element/hoverable/MouseEntered(location,control,params)
	StartHovering()

/obj/abstract/mind_ui_element/hoverable/MouseExited()
	StopHovering()

/obj/abstract/mind_ui_element/hoverable/proc/StartHovering()

/obj/abstract/mind_ui_element/hoverable/proc/StopHovering()

/obj/abstract/mind_ui_element/proc/GetScreenLoc()
	return "[parent.x][offset_x ? ":[offset_x]" : ""],[parent.y][offset_y ? ":[offset_y]" : ""]"

/obj/abstract/mind_ui_element/proc/Appear()
	invisibility = 0

/obj/abstract/mind_ui_element/proc/Hide()
	invisibility = 101

/obj/abstract/mind_ui_element/close
	mouse_opacity = 1

/obj/abstract/mind_ui_element/close/Click()

/////////////////////////////TESTING/////////////////////////////

/mob/proc/testUI()
	if (mind)
		mind.activeUIs["Hello World Parent"] = new /datum/mind_ui/test_hello_world_parent(mind)

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
	DisplayToPlayer()

/datum/mind_ui/test_hello_world
	uniqueID = "Hello World"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/test_window,
		/obj/abstract/mind_ui_element/hoverable/test_close,
		/obj/abstract/mind_ui_element/hoverable/test_hello,
		)

/datum/mind_ui/test_hello_world/Initialize()
	DisplayToPlayer()

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
	alpha = 0

/obj/abstract/mind_ui_element/hoverable/test_close
	icon = 'icons/ui/32x32.dmi'
	icon_state = "close"
	layer = 11
	offset_x = 80
	offset_y = 16

/obj/abstract/mind_ui_element/hoverable/test_close/Appear()
	..()
	flick("close-spawn",src)

/obj/abstract/mind_ui_element/hoverable/test_close/Hide()
	flick("close-click",src)
	spawn(10)
		..()

/obj/abstract/mind_ui_element/hoverable/test_close/StartHovering()
	icon_state = "close-hover"

/obj/abstract/mind_ui_element/hoverable/test_close/StopHovering()
	icon_state = "close"

/obj/abstract/mind_ui_element/hoverable/test_close/Click()
	var/datum/mind_ui/ancestor = parent.GetAncestor()
	ancestor.Close()

/obj/abstract/mind_ui_element/hoverable/test_hello
	icon = 'icons/ui/32x32.dmi'
	icon_state = "hello"
	layer = 11
	offset_y = -16

/obj/abstract/mind_ui_element/hoverable/test_hello/StartHovering()
	icon_state = "hello-hover"

/obj/abstract/mind_ui_element/hoverable/test_hello/StopHovering()
	icon_state = "hello"

/obj/abstract/mind_ui_element/hoverable/test_hello/Click()
	flick("hello-click",src)
	to_chat(usr, "[bicon(src)] Hello World!")

/////////////////////////////TESTING/////////////////////////////