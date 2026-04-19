#define ZMAP_UI_SIZE 260
#define ZMAP_UI_PADDING 5

// vLevel type colors for the map display
#define ZMAP_COLOR_TRANSIT   "#FFC800" // Yellow - shuttles in motion
#define ZMAP_COLOR_PARKING   "#6464FF" // Blue - parked shuttles
#define ZMAP_COLOR_PLANET    "#32C832" // Green - planetary surfaces
#define ZMAP_COLOR_PROTECTED "#C83232" // Red - protected areas (centcomm, dungeons, etc)
#define ZMAP_COLOR_SPACE     "#969696" // Gray - space areas (station, derelict, etc)
#define ZMAP_COLOR_CURRENT   "#FFFFFF" // White - current location highlight

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
		/obj/abstract/mind_ui_element/zmap_legend,
		/obj/abstract/mind_ui_element/zmap_legend_text,
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
	// Determine viewer's current vLevel for highlighting
	var/datum/virtual_z/viewer_vz = null
	var/mob/M = mind.current
	if(M)
		viewer_vz = vz_at_loc(M.x, M.y, M.z)
	for(var/datum/virtual_z/vz in z_to_show.virtual_z_levels)
		var/is_current = (vz == viewer_vz)
		var/obj/abstract/mind_ui_element/hoverable/virtual_z_display/vz_disp = new(null, src, vz, is_current)
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

/obj/abstract/mind_ui_element/zmap_legend
	layer = MIND_UI_FRONT
	offset_x = ZMAP_UI_SIZE/2
	offset_y = ZMAP_UI_SIZE/2 - 70

/obj/abstract/mind_ui_element/zmap_legend/New(turf/loc, var/datum/mind_ui/P)
	. = ..(loc, P)

	var/icon/legend = new /icon('icons/ui/zlevel_map/1x1.dmi', "pixel")
	legend.Scale(80, 60)
	legend.Blend(rgb(0, 0, 0, 180), ICON_MULTIPLY) // Semi-transparent black background

	var/list/legend_entries = list(
		list("Transit", ZMAP_COLOR_TRANSIT),
		list("Parking", ZMAP_COLOR_PARKING),
		list("Planet", ZMAP_COLOR_PLANET),
		list("Protected", ZMAP_COLOR_PROTECTED),
		list("Space", ZMAP_COLOR_SPACE)
	)

	var/y_pos = 50
	for(var/list/entry in legend_entries)
		var/icon/swatch = new /icon('icons/ui/zlevel_map/1x1.dmi', "pixel")
		swatch.Scale(8, 8)
		swatch.Blend(entry[2], ICON_MULTIPLY)
		legend.Blend(swatch, ICON_OVERLAY, 4, y_pos - 6)

		y_pos -= 10

	icon = legend

	UpdateUIScreenLoc()

/obj/abstract/mind_ui_element/zmap_legend_text
	layer = MIND_UI_FRONT
	offset_x = ZMAP_UI_SIZE/2 + 14
	offset_y = ZMAP_UI_SIZE/2 - 70

/obj/abstract/mind_ui_element/zmap_legend_text/New(turf/loc, var/datum/mind_ui/P)
	. = ..(loc, P)

	var/icon/text_bg = new /icon('icons/ui/zlevel_map/1x1.dmi', "pixel")
	text_bg.Scale(66, 60)
	text_bg.Blend(rgb(0, 0, 0, 0), ICON_MULTIPLY) // Transparent background
	icon = text_bg

	maptext_width = 66
	maptext_height = 60
	maptext = {"<div style=\"font-family: Fixedsys, monospace; font-size: 7pt; color: white; line-height: 10px; padding-top: 4px;\">Transit<br>Parking<br>Planet<br>Protected<br>Space</div>"}

	UpdateUIScreenLoc()

/obj/abstract/mind_ui_element/hoverable/virtual_z_display
	layer = MIND_UI_FRONT
	icon = 'icons/ui/zlevel_map/1x1.dmi'
	icon_state = "pixel"
	element_flags = MINDUI_FLAG_TOOLTIP
	var/datum/virtual_z/v

/obj/abstract/mind_ui_element/hoverable/virtual_z_display/New(turf/loc, var/datum/mind_ui/P, var/datum/virtual_z/vz, var/is_current = FALSE)
	v = vz
	. = ..(loc, P)

	var/usable_size = ZMAP_UI_SIZE - 2 * ZMAP_UI_PADDING
	var/scale_x = usable_size / world.maxx
	var/scale_y = usable_size / world.maxy
	offset_x = -ZMAP_UI_SIZE/2 + floor((v.x_min-1) * scale_x) + ZMAP_UI_PADDING
	offset_y = -ZMAP_UI_SIZE/2 + floor((v.y_min-1) * scale_y) + ZMAP_UI_PADDING
	var/new_width = max(round(v.size_x * scale_x), 1)
	var/new_height = max(round(v.size_y * scale_y), 1)

	var/type_desc
	var/type_color
	var/vz_type = v.level_type
	switch(vz_type)
		if(VZ_TRANSIT)
			type_desc = "Shuttle Transit Area"
			type_color = ZMAP_COLOR_TRANSIT
		if(VZ_PARKING)
			type_desc = "Shuttle Parking Area"
			type_color = ZMAP_COLOR_PARKING
		if(VZ_PLANET)
			type_desc = "Planet Surface"
			type_color = ZMAP_COLOR_PLANET
		if(VZ_PROTECTED)
			type_desc = "Protected Area"
			type_color = ZMAP_COLOR_PROTECTED
		else
			type_desc = "Space Area"
			type_color = ZMAP_COLOR_SPACE

	var/icon/ico = new /icon(icon, icon_state)
	ico.Scale(new_width, new_height)
	ico.Blend(type_color, ICON_MULTIPLY)

	if(is_current)
		var/icon/border = new /icon(icon, icon_state)
		border.Scale(new_width, new_height)
		border.Blend(ZMAP_COLOR_CURRENT, ICON_MULTIPLY)
		var/icon/interior = new /icon(icon, icon_state)
		var/interior_width = max(new_width - 2, 1)
		var/interior_height = max(new_height - 2, 1)
		interior.Scale(interior_width, interior_height)
		border.Blend(interior, ICON_SUBTRACT, 2, 2)
		ico.Blend(border, ICON_OVERLAY)

	icon = ico

	tooltip_title = "[v.name] ([v.id])[is_current ? " (You are here)" : ""]"
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
		var/datum/mind_ui/zlevel_map/zmap = parent
		zmap.Display(v.parent_z.z)

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
#undef ZMAP_COLOR_TRANSIT
#undef ZMAP_COLOR_PARKING
#undef ZMAP_COLOR_PLANET
#undef ZMAP_COLOR_PROTECTED
#undef ZMAP_COLOR_SPACE
#undef ZMAP_COLOR_CURRENT
