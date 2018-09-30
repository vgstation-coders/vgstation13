//MoMMI Overlays Indexes//////////
#define MOMMI_HEAD_LAYER		1
#define MOMMI_TOTAL_LAYERS		2
/////////////////////////////////

// Add an overlays_hats variable to the MoMMI class
/mob/living/silicon/robot/mommi
	var/list/overlays_hats[MOMMI_TOTAL_LAYERS]

/mob/living/silicon/robot/mommi/regenerate_icons()
	..()
	update_inv_head(0)
	update_hud()
	return

// Update the MoMMI's visual icon
// This is called whenever a major change to the MoMMI's visual appearance is made
// i.e when they change their icon_state, open their cover, get emagged, toggle their parking break, or put on a hat
/mob/living/silicon/robot/mommi/updateicon(overlay_layer = ABOVE_LIGHTING_LAYER, overlay_plane = LIGHTING_PLANE)
	overlays.Cut()

	if(base_icon)
		if(emagged && has_icon(icon, "[base_icon]-emagged"))
			icon_state = "[base_icon]-emagged"
		else
			icon_state = "[base_icon]"

	if(!stat && cell != null)
		eyes = image(icon,"eyes-[base_icon][emagged?"-emagged":""]", ABOVE_LIGHTING_LAYER)
		if(plane == HIDING_MOB_PLANE) // Hiding MoMMIs
			overlay_plane = FLOAT_PLANE
			overlay_layer = FLOAT_LAYER
		if(!emagged)
			eyes.plane = overlay_plane
			eyes.layer = overlay_layer
		else
			eyes.plane = LIGHTING_PLANE //Emagged MoMMIs don't hide their eyes.
		overlays += eyes

		if(anchored) //anchored, really?
			var/image/parking_lights = image(icon,"[base_icon]-park",overlay_layer)
			parking_lights.plane = overlay_plane
			overlays += parking_lights

	if(opened)
		if(wiresexposed)
			overlays += image(icon = icon, icon_state = "[has_icon(icon, "[base_icon]-ov-openpanel +w")? "[icon_state]-ov-openpanel +w" : "ov-openpanel +w"]")
		else if(cell)
			overlays += image(icon = icon, icon_state = "[has_icon(icon, "[base_icon]-ov-openpanel +c")? "[icon_state]-ov-openpanel +c" : "ov-openpanel +c"]")
		else
			overlays += image(icon = icon, icon_state = "[has_icon(icon, "[base_icon]-ov-openpanel -c")? "[icon_state]-ov-openpanel -c" : "ov-openpanel -c"]")

	// Add any hats to the icon. Bloodspatter can also be in overlays_hats
	for(var/image/I in overlays_hats)
		// Adjust the position of the hat based on what subtype we are
		// These numbers can be tweaked to move where the hats appear on the MoMMIs' bodies
		switch(icon_state)
			// Sad note: only the hat's overall position can be modified, and we cannot change the hat's position per each direction separately
			// The hats are currently centered on the MoMMIs
			if("mommi")
				I.pixel_y = -8 * PIXEL_MULTIPLIER
			if("hovermommi")
				I.pixel_y = -5 * PIXEL_MULTIPLIER
			if("keeper")
				I.pixel_y = -7 * PIXEL_MULTIPLIER
			if("repairbot")
				I.pixel_y = -14 * PIXEL_MULTIPLIER
			if("ruskiebot")
				I.pixel_y = -14 * PIXEL_MULTIPLIER
			if("replicator")
				I.pixel_y = -10 * PIXEL_MULTIPLIER
			if("mommiprime")
				I.pixel_y = -7 * PIXEL_MULTIPLIER
			if("mommiprime-alt")
				I.pixel_y = -12 * PIXEL_MULTIPLIER
			if("scout")
				I.pixel_y = -15 * PIXEL_MULTIPLIER
		// Add the adjusted hat to our overlays
		overlays += I

// Update the MoMMI's hat inventory icons by adding all icons to overlays_hats
/mob/living/silicon/robot/mommi/update_inv_head(var/update_icons = TRUE)
	// If the MoMMI is wearing a hat
	if(head_state)
		var/obj/item/clothing/head = head_state
		var/image/overhats
		// Create the hat icon
		overhats = image("icon" = ((head.icon_override) ? head.icon_override : 'icons/mob/head.dmi'), "icon_state" = "[head.icon_state]")

		// If the hat has blood on it
		if(head.blood_DNA && head.blood_DNA.len)
			// Add a blood image to the hat
			var/image/bloodsies = image("icon" = 'icons/effects/blood.dmi', "icon_state" = "helmetblood")
			bloodsies.color = head.blood_color
			overhats.overlays	+= bloodsies
		// Add our hat images to overlays_hats
		overlays_hats[MOMMI_HEAD_LAYER]	= overhats
	// If the MoMMI is not wearing a hat
	else // Clear the hat array
		overlays_hats[MOMMI_HEAD_LAYER]	= null
	// Update the MoMMI's icons
	if(update_icons)
		updateicon()
