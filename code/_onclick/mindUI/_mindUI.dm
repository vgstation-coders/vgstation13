/*
	mind_ui, started on 2021/07/22 by Deity.

	instead of being stored in the mob like /datum/hud, this one is stored in a mob's /datum/mind 's activeUIs list

	A mind can store several separate mind_uis, think of each one as its own menu/pop-up, that in turns contains a list of /obj/mind_ui_element,
	or other /datum/mind_ui that

	* mind datums and their elements should avoid holding references to atoms in the real world.
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
	if(!ui.Valid())
		ui.Hide()
	else
		ui.Display()

/datum/mind/proc/HideUI(var/ui_ID)
	if (ui_ID in activeUIs)
		var/datum/mind_ui/ui = activeUIs[ui_ID]
		ui.Hide()

/datum/mind/proc/UpdateUIScreenLoc()
	for (var/mind_ui in activeUIs)
		var/datum/mind_ui/ui = activeUIs[mind_ui]
		ui.UpdateUIScreenLoc()

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

/mob/proc/UpdateUIScreenLoc()
	if (mind)
		mind.UpdateUIScreenLoc()

/mob/proc/UpdateUIElementIcon(var/element_type)
	if (client)
		var/obj/abstract/mind_ui_element/element = locate(element_type) in client.screen
		if (element)
			element.UpdateIcon()

/mob/proc/UpdateAllElementIcons()
	if (client)
		for (var/obj/abstract/mind_ui_element/element in client.screen)
			element.UpdateIcon()


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
	var/offset_x = 0 //KEEP THESE AT 0, they are set by /obj/abstract/mind_ui_element/hoverable/movable/
	var/offset_y = 0

	var/x = "CENTER"
	var/y = "CENTER"


	var/list/element_types_to_spawn = list()
	var/list/sub_uis_to_spawn = list()

	var/display_with_parent = FALSE

	var/active = TRUE

	var/obj/abstract/mind_ui_element/failsafe/failsafe	// All mind UI datums include one of those so we can detect if the elements somehow disappeared from client.screen

/datum/mind_ui/New(var/datum/mind/M)
	if (!istype(M))
		qdel(src)
		return
	mind = M
	mind.activeUIs[uniqueID] = src
	..()
	SpawnElements()
	for (var/ui_type in sub_uis_to_spawn)
		var/datum/mind_ui/child = new ui_type(mind)
		subUIs += child
		child.parent = src
	SendToClient()

/datum/mind_ui/proc/SpawnElements()
	failsafe = new (null, src)
	elements += failsafe
	for (var/element_type in element_types_to_spawn)
		elements += new element_type(null, src)

// Send every element to the client, called on Login() and when the UI is first added to a mind
/datum/mind_ui/proc/SendToClient()
	if (mind.current)
		var/mob/M = mind.current
		if (!M.client)
			return

		if (!Valid() || !display_with_parent) // Makes sure the UI isn't still active when we should have lost it (such as coming out of a mecha while disconnected)
			Hide(TRUE)

		for (var/obj/abstract/mind_ui_element/element in elements)
			mind.current.client.screen |= element

// Removes every element from the client, called on Logout()
/datum/mind_ui/proc/RemoveFromClient()
	if (mind.current)
		var/mob/M = mind.current
		if (!M.client)
			return
		
		mind.current.client.screen -= elements

// Makes every element visible
/datum/mind_ui/proc/Display()
	if (!Valid())
		Hide(TRUE)
		return
	active = TRUE

	var/mob/M = mind.current
	if (failsafe && M.client && !(failsafe in M.client.screen))
		SendToClient() // The elements disappeared from the client screen due to some fuckery, send them back!

	for (var/obj/abstract/mind_ui_element/element in elements)
		element.Appear()
	for (var/datum/mind_ui/child in subUIs)
		if (child.display_with_parent)
			if(child.Valid())
				child.Display()
			else
				child.Hide()

/datum/mind_ui/proc/Hide(var/override = FALSE)
	active = FALSE
	HideChildren(override)
	HideElements(override)

/datum/mind_ui/proc/HideChildren(var/override = FALSE)
	for (var/datum/mind_ui/child in subUIs)
		child.Hide(override)

/datum/mind_ui/proc/HideElements(var/override = FALSE)
	for (var/obj/abstract/mind_ui_element/element in elements)
		if (override)
			element.invisibility = 101
		else
			element.Hide()

/datum/mind_ui/proc/Valid()
	return TRUE

/datum/mind_ui/proc/UpdateUIScreenLoc()
	for (var/obj/abstract/mind_ui_element/element in elements)
		element.UpdateUIScreenLoc()

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

/datum/mind_ui/proc/GetAncestor()
	if (parent)
		return parent.GetAncestor()
	else
		return src

/datum/mind_ui/proc/GetUser()
	ASSERT(mind && mind.current)
	return mind.current

////////////////////////////////////////////////////////////////////
//																  //
//							 UI ELEMENT							  //
//																  //
////////////////////////////////////////////////////////////////////

/obj/abstract/mind_ui_element
	name = "Undefined UI Element"
	icon = 'icons/ui/32x32.dmi'
	icon_state = ""
	mouse_opacity = 1
	plane = HUD_PLANE

	var/base_icon_state

	var/datum/mind_ui/parent = null
	var/element_flags = 0	// PROCESSING

	var/offset_x = 0
	var/offset_y = 0

/obj/abstract/mind_ui_element/New(turf/loc, var/datum/mind_ui/P)
	if (!istype(P))
		qdel(src)
		return
	..()
	base_icon_state = icon_state
	parent = P
	UpdateUIScreenLoc()

/obj/abstract/mind_ui_element/proc/Appear()
	if (invisibility)
		invisibility = 0
		UpdateIcon(TRUE)
	else
		invisibility = 0
		UpdateIcon()

/obj/abstract/mind_ui_element/proc/Hide()
	if (!parent.active) // we check again for it due to potential spawn() use, and inconsistencies caused by quick UI toggling
		invisibility = 101

/obj/abstract/mind_ui_element/proc/GetUser()
	ASSERT(parent && parent.mind && parent.mind.current)
	return parent.mind.current

/obj/abstract/mind_ui_element/proc/UpdateUIScreenLoc()
	screen_loc = "[parent.x]:[offset_x + parent.offset_x],[parent.y]:[offset_y+parent.offset_y]"

/obj/abstract/mind_ui_element/proc/UpdateIcon(var/appear = FALSE)
	return

/obj/abstract/mind_ui_element/proc/String2Image(var/string) // only supports numbers right now
	if (!string)
		return image('icons/ui/16x16.dmi',"")

	var/image/result = image('icons/ui/16x16.dmi',"")
	for (var/i = 1 to length(string))
		var/image/I = image('icons/ui/16x16.dmi',copytext(string,i,i+1))
		I.pixel_x = (i - 1) * 6
		result.overlays += I
	return result

/obj/abstract/mind_ui_element/proc/SlideUIElement(var/new_x = 0, var/new_y = 0, var/duration, var/layer = MIND_UI_BACK, var/hide_after = FALSE)
	invisibility = 101
	var/image/ui_image = image(icon, src, icon_state, layer)
	ui_image.overlays = overlays
	var/mob/U = GetUser()
	U.client.images |= ui_image
	animate(ui_image, pixel_x = new_x - offset_x, pixel_y = new_y - offset_y,  time = duration)
	spawn(duration)
		offset_x = new_x
		offset_y = new_y
		UpdateUIScreenLoc()
		U.client.images -= ui_image
		if(!hide_after)
			invisibility = 0

/obj/abstract/mind_ui_element/failsafe
	icon_state = "blank"
	mouse_opacity = 0

////////////////// HOVERABLE ////////////////////////
// Make use of MouseEntered/MouseExited to allow for effects and behaviours related to simply hovering above the element

/obj/abstract/mind_ui_element/hoverable

/obj/abstract/mind_ui_element/hoverable/MouseEntered(location,control,params)
	StartHovering()

/obj/abstract/mind_ui_element/hoverable/MouseExited()
	StopHovering()

/obj/abstract/mind_ui_element/hoverable/proc/StartHovering()
	icon_state = "[base_icon_state]-hover"

/obj/abstract/mind_ui_element/hoverable/proc/StopHovering()
	icon_state = "[base_icon_state]"


////////////////// MOVABLE ////////////////////////
// Make use of MouseDown/MouseUp/MouseDrop to allow for relocating of the element
// By setting "move_whole_ui" to TRUE, the element will cause its entire parent UI to move with it.

/obj/abstract/mind_ui_element/hoverable/movable
	var/move_whole_ui = FALSE
	var/moving = FALSE
	var/icon/movement

/obj/abstract/mind_ui_element/hoverable/movable/AltClick(mob/user) // Alt+Click defaults to reset the offset
	ResetLoc()

/obj/abstract/mind_ui_element/hoverable/movable/MouseDown(location, control, params)
	if (!movement)
		var/icon/I = new(icon, icon_state)
		I.Blend('icons/mouse/mind_ui.dmi', ICON_OVERLAY, I.Width()/2-16, I.Height()/2-16)
		I.Scale(2* I.Width(),2* I.Height()) // doubling the size to account for players generally having more or less a 960x960 resolution
		var/rgba = "#FFFFFF" + copytext(rgb(0,0,0,191), 8)
		I.Blend(rgba, ICON_MULTIPLY)
		movement = I

	var/mob/M = GetUser()
	M.client.mouse_pointer_icon = movement
	moving = TRUE

/obj/abstract/mind_ui_element/hoverable/movable/MouseUp(location, control, params)
	var/mob/M = GetUser()
	M.client.mouse_pointer_icon = initial(M.client.mouse_pointer_icon)
	if (moving)
		MoveLoc(params)

/obj/abstract/mind_ui_element/hoverable/movable/MouseDrop(over_object, src_location, over_location, src_control, over_control, params)
	var/mob/M = GetUser()
	M.client.mouse_pointer_icon = initial(M.client.mouse_pointer_icon)
	MoveLoc(params)

/obj/abstract/mind_ui_element/hoverable/movable/proc/MoveLoc(var/params)
	moving = FALSE
	var/list/PM = params2list(params)
	if(!PM || !PM["screen-loc"])
		return

	//first we need the x and y coordinates in pixels of the element relative to the bottom left corner of the screen
	var/icon/I = new(icon,icon_state)
	var/list/start_loc_params = splittext(screen_loc, ",")
	var/list/start_loc_X = splittext(start_loc_params[1],":")
	var/list/start_loc_Y = splittext(start_loc_params[2],":")
	var/start_pix_X = text2num(start_loc_X[2])
	var/start_pix_Y = text2num(start_loc_Y[2])
	var/view = get_view_size()
	var/X = start_loc_X[1]
	var/Y = start_loc_Y[1]
	var/start_x_val
	var/start_y_val
	if(findtext(X,"RIGHT"))
		var/num = text2num(copytext(X,6))
		if(!num)
			num = 0
		start_x_val = view*2 + 1 - num
	else if(findtext(X,"LEFT"))
		var/num = text2num(copytext(X,6))
		if(!num)
			num = 0
		start_x_val = num+1
	else if(findtext(X,"CENTER"))
		start_x_val = view+1
	start_x_val *= 32
	start_x_val += start_pix_X
	if(findtext(Y,"TOP"))
		var/num = text2num(copytext(Y,7))
		if(!num)
			num = 0
		start_y_val = view*2 + 1 - num
	else if(findtext(Y,"BOTTOM"))
		var/num = text2num(copytext(Y,7))
		if(!num)
			num = 0
		start_y_val = num+1
	else if(findtext(Y,"CENTER"))
		start_y_val = view+1
	start_y_val *= 32
	start_y_val += start_pix_Y

	//now we get those of the place where we released the mouse button
	var/list/dest_loc_params = splittext(PM["screen-loc"], ",")
	var/list/dest_loc_X = splittext(dest_loc_params[1],":")
	var/list/dest_loc_Y = splittext(dest_loc_params[2],":")
	var/dest_pix_x = text2num(dest_loc_X[2]) - round(I.Width()/2)
	var/dest_pix_y = text2num(dest_loc_Y[2]) - round(I.Height()/2)
	var/dest_x_val = text2num(dest_loc_X[1])*32 + dest_pix_x
	var/dest_y_val = text2num(dest_loc_Y[1])*32 + dest_pix_y

	//and calculate the offset between the two, which we can then add to either the element or the whole UI
	if (move_whole_ui)
		parent.offset_x += dest_x_val - start_x_val
		parent.offset_y += dest_y_val - start_y_val
		parent.UpdateUIScreenLoc()
	else
		offset_x += dest_x_val - start_x_val
		offset_y += dest_y_val - start_y_val
		UpdateUIScreenLoc()

/obj/abstract/mind_ui_element/hoverable/movable/proc/ResetLoc()
	if (move_whole_ui)
		parent.offset_x = 0
		parent.offset_y = 0
		parent.UpdateUIScreenLoc()
	else
		offset_x = initial(offset_x)
		offset_y = initial(offset_y)
		UpdateUIScreenLoc()
