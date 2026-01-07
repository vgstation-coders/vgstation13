#define ZMAP_UI_SIZE 260
#define ZMAP_UI_PADDING 5

////////////////////////////////////////////////////////
//													  //
//					   Z-LEVEL MAP					  //
//													  //
////////////////////////////////////////////////////////
// Displays a simple map of all virtual z-levels on the current z-level
// Clicking any of the virtual z-levels will teleport the user to its center
// Admins can access this via the map button in the Level Manager UI

/datum/mind_ui/zlevel_map
	uniqueID = "zlevel_map"
	x = "CENTER"
	y = "CENTER"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/zmap_base,
		/obj/abstract/mind_ui_element/hoverable/close,
		/obj/abstract/mind_ui_element/hoverable/movable/move
		)

/datum/mind_ui/zlevel_map/Valid()
	var/mob/M = mind.current
	if (M?.client?.holder?.rights & R_ADMIN)
		return TRUE
	return FALSE

/datum/mind_ui/zlevel_map/Display(var/z_id)
	for(var/obj/abstract/mind_ui_element/hoverable/virtual_z_display/old_vz_disp in elements)
		if(istype(old_vz_disp))
			old_vz_disp.parent = null
			elements -= old_vz_disp
			qdel(old_vz_disp)
	. = ..()
	var/datum/zLevel/z_to_show = map.zLevels[z_id]
	if(!z_to_show)
		return
	for(var/datum/virtual_z/vz in z_to_show.virtual_z_levels)
		var/obj/abstract/mind_ui_element/hoverable/virtual_z_display/vz_disp = new(null, src, vz)
		elements += vz_disp
		vz_disp.Appear()
		if(mind.current?.client)
			mind.current.client.screen |= vz_disp

//------------------------------------------------------------

/obj/abstract/mind_ui_element/zmap_base
	icon = 'icons/ui/zlevel_map/260x260.dmi'
	icon_state = "base"
	layer = MIND_UI_BACK
	offset_x = -ZMAP_UI_SIZE/2
	offset_y = -ZMAP_UI_SIZE/2

/obj/abstract/mind_ui_element/hoverable/virtual_z_display
	layer = MIND_UI_FRONT
	icon = 'icons/ui/zlevel_map/1x1.dmi'
	icon_state = "pixel"
	element_flags = MINDUI_FLAG_TOOLTIP
	var/datum/virtual_z/v

/obj/abstract/mind_ui_element/hoverable/virtual_z_display/New(turf/loc, var/datum/mind_ui/P, var/datum/virtual_z/vz)
	v = vz
	. = ..(loc, P)

	// Size and position to match virtual z-level
	offset_x = -ZMAP_UI_SIZE/2 + floor((v.x_min-1)/2) + ZMAP_UI_PADDING
	offset_y = -ZMAP_UI_SIZE/2 + floor((v.y_min-1)/2) + ZMAP_UI_PADDING
	var/new_width = v.size_x / 2
	var/new_height = v.size_y / 2
	var/icon/ico = new /icon(icon, icon_state)
	ico.Scale(new_width, new_height)
	ico.Blend(rgb(rand(0, 255), rand(0, 255), rand(0, 255)), ICON_MULTIPLY)
	icon = ico

	// Tooltip info
	var/type_desc
	var/vz_type = v.level_type
	switch(vz_type)
		if(VZ_TRANSIT)
			type_desc = "Shuttle Transit Area"
		if(VZ_PARKING)
			type_desc = "Shuttle Parking Area"
		if(VZ_PLANET)
			type_desc = "Planet Surface"
		if(VZ_MAP_ELEMENT)
			type_desc = "Ruin/Dungeon/Away Mission"
		if(VZ_CUSTOM)
			type_desc = "Custom Level"
		else
			type_desc = "Default Level"
	tooltip_title = "[v.name] ([v.id])"
	tooltip_content = "[type_desc] of size [v.size_x]x[v.size_y] located at [v.x_min],[v.y_min] on [v.parent_z.z]."

	UpdateUIScreenLoc()

/obj/abstract/mind_ui_element/hoverable/virtual_z_display/Click()
	var/center_x = round((v.x_min + v.x_max) / 2)
	var/center_y = round((v.y_min + v.y_max) / 2)
	var/turf/T = locate(center_x, center_y, v.parent_z.z)
	var/mob/M = src.parent.mind.current
	if(T && M)
		M.forceMove(T)
		log_admin("[key_name(M)] jumped to vZ-[v.id] ([v.name]) at [center_x],[center_y],[v.parent_z.z].")
		message_admins("<span class='notice'>[key_name_admin(M)] jumped to vZ-[v.id] ([v.name]).</span>", 1)

/obj/abstract/mind_ui_element/hoverable/close
	icon = 'icons/ui/16x16.dmi'
	icon_state = "close"
	layer = MIND_UI_BUTTON
	offset_x = ZMAP_UI_SIZE/2 - 8
	offset_y = ZMAP_UI_SIZE/2 - 8
	mouse_opacity = 1

/obj/abstract/mind_ui_element/hoverable/close/Click()
	var/datum/mind_ui/ancestor = parent.GetAncestor()
	ancestor.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/movable/move
	icon = 'icons/ui/16x16.dmi'
	icon_state = "move"
	layer = MIND_UI_BUTTON
	offset_x = -ZMAP_UI_SIZE/2 - 8
	offset_y = ZMAP_UI_SIZE/2 - 8
	mouse_opacity = 1

	move_whole_ui = TRUE

#undef ZMAP_UI_SIZE
#undef ZMAP_UI_PADDING
