/* ==== Custom painting structure (Hanging on wall) ====
 * Whole lot of copy-paste here, sadly. Check out /obj/item/mounted/frame/painting/custom and make sure changes made
 *  here are applied there too.
*/
/obj/structure/painting/custom
	var/blank = TRUE
	var/datum/custom_painting/painting_data

	// Where to render the custom painting. Make sure it matches the icon state!
	var/painting_height = 14
	var/painting_width = 14
	var/painting_offset_x = 9
	var/painting_offset_y = 9
	var/base_color = "#ffffff"

	// Icon to render our painting data on
	var/base_icon = 'icons/obj/paintings.dmi'
	var/base_icon_state = "blank"


/obj/structure/painting/custom/New()
	..()
	src.painting_data = new(src, painting_width, painting_height, painting_offset_x, painting_offset_y, base_color)

/obj/structure/painting/custom/Destroy()
	qdel(painting_data)
	painting_data = null
	..()

/obj/structure/painting/custom/attackby(obj/item/W, mob/user)
	var/datum/painting_utensil/p = new(user, W)
	if (p.palette.len)
		painting_data.interact(user, p)

	if (istype(W, /obj/item/weapon/soap) && do_after(user, src, 20))
		painting_data.blank_contents()
		icon = icon(base_icon, base_icon_state)
		update_painting()

	return ..()

/obj/structure/painting/custom/Topic(href, href_list)
	// Let /datum/custom_painting handle Topic(). If succesful, update appearance
	if (painting_data.Topic(href, href_list))
		blank = FALSE
		update_painting(TRUE)
	return ..()

/obj/structure/painting/custom/update_painting(render)
	if (!blank)
		name = (painting_data.title ? ("\proper[painting_data.title]") : "untitled artwork") + (painting_data.author ? ", by [painting_data.author]" : "")
		desc = painting_data.description ? "A small plaque reads: \"<span class='info'>[painting_data.description]\"</span>" : "A painting. But what does it mean?"
		if (render)
			icon = painting_data.render_on(icon(base_icon, base_icon_state))
	else
		name = initial(name)
		desc = initial(desc)

/obj/structure/painting/custom/proc/set_painting_data(datum/custom_painting/painting_data)
	src.painting_data = painting_data
	src.painting_data.set_parent(src)

/obj/structure/painting/custom/to_item(mob/user)
	var/obj/item/mounted/frame/painting/custom/P = new(user.loc)
	P.set_painting_data(painting_data.Copy())
	P.rendered_icon = icon
	P.base_icon = base_icon
	P.base_icon_state = base_icon_state
	P.blank = blank
	P.update_painting()
	return P

/* ==== Custom painting (Item) ====
 * Whole lot of copy-paste here, sadly. Check out /obj/structure/painting/custom and make sure changes made here are
 *  applied there too.
 * Main difference is update_painting() renders on a separate icon (structure_icon), on conversion to structure (hanging)
 *  this separate icon is applied as the structure's icon
*/
/obj/item/mounted/frame/painting/custom
	var/blank = TRUE
	var/datum/custom_painting/painting_data

	// Icon to render our painting data on
	var/base_icon = 'icons/obj/paintings.dmi'
	var/base_icon_state = "blank"
	var/rendered_icon

	// Where to render the custom painting. Make sure it matches the structure icon state!
	var/painting_height = 14
	var/painting_width = 14
	var/painting_offset_x = 9
	var/painting_offset_y = 9
	var/base_color = "#ffffff"

/obj/item/mounted/frame/painting/custom/New()
	..()
	src.painting_data = new(src, painting_width, painting_height, painting_offset_x, painting_offset_y, base_color)

/obj/item/mounted/frame/painting/custom/Destroy()
	qdel(painting_data)
	painting_data = null
	..()

/obj/item/mounted/frame/painting/custom/attackby(obj/item/W, mob/user)
	var/datum/painting_utensil/p = new(user, W)
	if (p.palette.len)
		painting_data.interact(user, p)

	if (istype(W, /obj/item/weapon/soap))
		to_chat(usr, "<span class='warning'>You start cleaning \the [name].</span>")
		if (do_after(user, src, 20))
			painting_data.blank_contents()
			rendered_icon = icon(base_icon, base_icon_state)
			update_painting()

	return ..()

/obj/item/mounted/frame/painting/custom/Topic(href, href_list)
	// Let /datum/custom_painting handle Topic(). If succesful, update appearance
	if (painting_data.Topic(href, href_list))
		blank = FALSE
		update_painting(TRUE)
	return ..()

/obj/item/mounted/frame/painting/custom/update_painting(render)
	if (!blank)
		name = (painting_data.title ? ("\proper[painting_data.title]") : "untitled artwork") + (painting_data.author ? ", by [painting_data.author]" : "")
		desc = painting_data.description ? "The author left the following note: \"<span class='info'>[painting_data.description]\"</span>" : "A painting. But what does it mean?"
		if (render)
			rendered_icon = painting_data.render_on(icon(base_icon, base_icon_state))
	else
		name = initial(name)
		desc = initial(desc)


/obj/item/mounted/frame/painting/custom/proc/set_painting_data(datum/custom_painting/painting_data)
	src.painting_data = painting_data
	src.painting_data.set_parent(src)

/obj/item/mounted/frame/painting/custom/to_structure(turf/on_wall, mob/user)
	var/obj/structure/painting/custom/P = new(user.loc)
	P.set_painting_data(painting_data.Copy())
	P.icon = rendered_icon ? rendered_icon : icon(base_icon, base_icon_state)
	P.icon_state = base_icon_state
	P.base_icon = base_icon
	P.base_icon_state = base_icon_state
	P.blank = blank
	P.update_painting()
	return P

/*
 * ==== Variants ====
 * Each variant should have both an /item/mounted and /structure version so they can be either
 *  mapped in or created through recipes without issue
*/

// Blank landscape canvas
/obj/item/mounted/frame/painting/custom/landscape
	base_icon_state = "blank_landscape"
	painting_height = 14
	painting_width = 24
	painting_offset_x = 4
	painting_offset_y = 9

/obj/structure/painting/custom/landscape
	icon_state = "blank_landscape"
	base_icon_state = "blank_landscape"
	painting_height = 14
	painting_width = 24
	painting_offset_x = 4
	painting_offset_y = 9

// Blank portrait canvas
/obj/item/mounted/frame/painting/custom/portrait
	base_icon_state = "blank_portrait"
	painting_height = 24
	painting_width = 14
	painting_offset_x = 9
	painting_offset_y = 3

/obj/structure/painting/custom/portrait
	icon_state = "blank_portrait"
	base_icon_state = "blank_portrait"
	painting_height = 24
	painting_width = 14
	painting_offset_x = 9
	painting_offset_y = 3

// Large blank canvas
/obj/item/mounted/frame/painting/custom/large
	base_icon_state = "blank_large"
	painting_height = 24
	painting_width = 24
	painting_offset_x = 4
	painting_offset_y = 3

/obj/structure/painting/custom/large
	icon_state = "blank_large"
	base_icon_state = "blank_large"
	painting_height = 24
	painting_width = 24
	painting_offset_x = 4
	painting_offset_y = 3
