/*
	mind_ui, started on 2021/07/22 by Deity.

	instead of being stored in the mob like /datum/hud, this one is stored in a mob's /datum/mind 's activeUIs list

	A mind can store several separate mind_uis, think of each one as its own menu/pop-up, that in turns contains a list of /obj/mind_ui_element,
	or other /datum/mind_ui that
*/


// During game setup we fill a list with the IDs and types of every /datum/mind_ui subtypes
var/mind_ui_init = FALSE
var/list/mind_ui_ID2type = list()

/proc/init_mind_ui()
	if (mind_ui_init)
		return
	mind_ui_init = TRUE
	for (var/mind_ui_type in subtypesof(/datum/mind_ui))
		var/datum/mind_ui/ui = mind_ui_type
		mind_ui_ID2type[initial(ui.uniqueID)] = mind_ui_type

//////////////////////MIND UI PROCS/////////////////////////////

/datum/mind/proc/ResendAllUIs() // Re-sends all mind uis to client.screen, called on mob/living/Login()
	for (var/mind_ui in activeUIs)
		var/datum/mind_ui/ui = activeUIs[mind_ui]
		ui.SendToClient()

/datum/mind/proc/RemoveAllUIs() // Removes all mind uis from client.screen, called on mob/Logout()
	for (var/mind_ui in activeUIs)
		var/datum/mind_ui/ui = activeUIs[mind_ui]
		ui.RemoveFromClient()

/datum/mind/proc/DisplayUI(var/ui_ID)
	var/datum/mind_ui/ui
	if (ui_ID in activeUIs)
		ui = activeUIs[ui_ID]
	else
		if (!(ui_ID in mind_ui_ID2type))
			return
		var/ui_type = mind_ui_ID2type[ui_ID]
		ui = new ui_type(src)
	ui.Display()

/datum/mind/proc/HideUI(var/ui_ID)
	if (ui_ID in activeUIs)
		var/datum/mind_ui/ui = activeUIs[ui_ID]
		ui.Hide()

//////////////////////MOB SHORTCUT PROCS////////////////////////

/mob/proc/ResendAllUIs()
	if (mind)
		mind.ResendAllUIs()

/mob/proc/RemoveAllUIs()
	if (mind)
		mind.RemoveAllUIs()

/mob/proc/DisplayUI(var/ui_ID)
	if (mind)
		mind.DisplayUI(ui_ID)

/mob/proc/HideUI(var/ui_ID)
	if (mind)
		mind.HideUI(ui_ID)

////////////////////////////////////////////////////////////////////
//																  //
//							  MIND UI							  //
//																  //
////////////////////////////////////////////////////////////////////

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

	var/visible = TRUE

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
	SendToClient()
	Initialize()


// Stuff the UI does when first created
/datum/mind_ui/proc/Initialize()

// Send every element to the client, called on Login() and when the UI is first added to a mind
/datum/mind_ui/proc/SendToClient()
	if (mind.current)
		var/mob/M = mind.current
		if (!M.client)
			return

		for (var/obj/abstract/mind_ui_element/element in elements)
			mind.current.client.screen |= element

// Removes every element from the client, called on Logout()
/datum/mind_ui/proc/RemoveFromClient()
	if (mind.current)
		var/mob/M = mind.current
		if (!M.client)
			return

		for (var/obj/abstract/mind_ui_element/element in elements)
			mind.current.client.screen -= element

// Makes every element visible
/datum/mind_ui/proc/Display()
	visible = TRUE
	for (var/obj/abstract/mind_ui_element/element in elements)
		element.Appear()

/datum/mind_ui/proc/Hide()
	visible = FALSE
	HideChildren()
	HideElements()

/datum/mind_ui/proc/HideChildren()
	for (var/datum/mind_ui/child in subUIs)
		child.Hide()

/datum/mind_ui/proc/HideElements()
	for (var/obj/abstract/mind_ui_element/element in elements)
		element.Hide()

/*
	Closes the root parent by default.
		* levels: can be specified to only close parents up to [levels] levels above.
*/
/datum/mind_ui/proc/HideParent(var/levels=0)
	if (levels <= 0)
		var/datum/mind_ui/ancestor = GetAncestor()
		ancestor.Hide()
		return
	else
		var/datum/mind_ui/to_hide = src
		while (levels > 0)
			if (to_hide.parent)
				levels--
				to_hide = to_hide.parent
			else
				break
		to_hide.Hide()

/*
	Returns the uppermost UI
*/
/datum/mind_ui/proc/GetAncestor()
	if (parent)
		return parent.GetAncestor()
	else
		return src

////////////////////////////////////////////////////////////////////
//																  //
//							 UI ELEMENT							  //
//																  //
////////////////////////////////////////////////////////////////////

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

/obj/abstract/mind_ui_element/hoverable
	mouse_opacity = 1

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
