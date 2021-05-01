/obj/item/mounted/frame/painting/custom
/*
	name = "painting"
	desc = "A blank painting."
	icon = 'icons/obj/paintings.dmi'
	icon_state = "item"
	item_state = "painting"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	flags = FPRINT
	w_type = RECYK_WOOD
	frame_material = /obj/item/stack/sheet/wood
	sheets_refunded = 2
	autoignition_temperature = AUTOIGNITION_WOOD
	var/paint = ""
*/
	var/datum/custom_painting/painting

/obj/item/mounted/frame/painting/custom/New()
	painting = new /datum/custom_painting(src, 14, 14, 0, 0)

/obj/item/mounted/frame/painting/custom/Destroy()
	qdel(painting)
	painting = null
	..()

/obj/item/mounted/frame/painting/custom/attackby(var/obj/item/W, var/mob/user)
	if (istype(W, /obj/item/weapon/pen))//TODO other tools (crayons, brushes)
		painting.interact(user)
	return ..()

/obj/item/mounted/frame/painting/custom/Topic(href, href_list)
	// Let /datum/custom_painting handle Topic(). If succesful, update appearance
	if (painting.Topic(href, href_list))
		update_painting()
	return ..()

/obj/item/mounted/frame/painting/custom/update_painting()
	name = (painting.title ? ("\proper[painting.title]") : "untitled artwork") + (painting.author ? ", by [painting.author]" : "")
	desc = painting.description ? "The author left the following note: \"<span class='info'>[painting.description]\"</span>" : "A painting. But what does it mean?"


/obj/structure/painting/custom
/*
	name = "painting"
	desc = "A blank painting."
	icon = 'icons/obj/paintings.dmi'
	icon_state = "blank"
	autoignition_temperature = AUTOIGNITION_WOOD
	anchored = 1
*/

	var/datum/custom_painting/painting


/obj/structure/painting/custom/New()
	painting = new /datum/custom_painting(src, 14, 14, 0, 0)

/obj/structure/painting/custom/Destroy()
	qdel(painting)
	painting = null
	..()


/obj/structure/painting/custom/attackby(var/obj/item/W, var/mob/user)
	if (istype(W, /obj/item/weapon/pen))//TODO other tools (crayons, brushes)
		painting.interact(user)
	return ..()

/obj/structure/painting/custom/Topic(href, href_list)
	// Let /datum/custom_painting handle Topic(). If succesful, update appearance
	if (painting.Topic(href, href_list))
		update_painting()
	return ..()

/obj/structure/painting/custom/update_painting()
	name = (painting.title ? ("\proper[painting.title]") : "untitled artwork") + (painting.author ? ", by [painting.author]" : "")
	desc = painting.description ? "The author left the following note: \"<span class='info'>[painting.description]\"</span>" : "A painting. But what does it mean?"
