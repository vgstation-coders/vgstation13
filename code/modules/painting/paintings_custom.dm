/* ==== Custom painting structure (Hanging on wall) ====
 * Whole lot of copy-paste here, sadly. Check out /obj/item/mounted/frame/painting/custom and make sure changes made
 *  here are applied there too.
*/
/obj/structure/painting/custom
	name = "small canvas"
	desc = "What to draw?"
	icon_state = "blank"
	var/base_name = "small canvas"
	var/base_desc = "What to draw?"

	var/blank = TRUE
	var/protected_by_glass = FALSE
	var/framed = FALSE
	var/datum/custom_painting/painting_data

	// Where to render the custom painting. Make sure it matches the icon state!
	var/painting_height = 14
	var/painting_width = 14
	var/painting_offset_x = 9
	var/painting_offset_y = 10
	var/base_color = "#ffffff"

	// Icon to render our painting data on
	layer = CANVAS_LAYER
	var/base_icon = 'icons/obj/paintings.dmi'
	var/base_icon_state = "blank"
	var/frame_icon = 'icons/obj/painting_items.dmi'
	var/frame_icon_state = "frame"
	var/show_on_scoreboard = TRUE

	starting_materials = list(MAT_WOOD = 2 * CC_PER_SHEET_WOOD)

/obj/structure/painting/custom/New()
	src.painting_data = new(src, painting_width, painting_height, painting_offset_x, painting_offset_y, base_color)
	var/list/gallery = score.global_paintings
	if(!gallery.Find(src))
		gallery += src
	..()

/obj/structure/painting/custom/Destroy()
	var/list/gallery = score.global_paintings
	if(gallery.len && gallery.Find(src))
		gallery -= src
	QDEL_NULL(painting_data)
	..()

/obj/structure/painting/custom/attackby(obj/item/W, mob/user)
	// Painting
	var/datum/painting_utensil/p = new(user, W)
	if (p.palette.len)
		if (protected_by_glass)
			to_chat(usr, "<span class='warning'>\the [name]'s glass cover stops you from painting on it.</span>")
		else
			painting_data.interact(user, p)

	// Pouring
	if (istype(W, /obj/item/weapon/reagent_containers))
		if (protected_by_glass)
			return FALSE //Let the reagent container's afterattack handle things

		var/obj/item/weapon/reagent_containers/container = W
		if (container.is_open_container() && container.reagents && !container.reagents.is_empty())
			to_chat(usr, "<span class='warning'>You start splashing \the [container]'s contents over \the [name].</span>")
			if (do_after(user, src, 10))
				// Reagent mix is strong enough to clean the canvas, do so
				var/cleaner_percent = get_reagent_paint_cleaning_percent(container)
				if (cleaner_percent >= PAINT_CLEANER_THRESHOLD)
					painting_data.blank_contents()
					to_chat(usr, "<span class='warning'>You wash the paint off \the [name]!</span>")

				// Reagent mix is opaque enough to paint the canvas, do so
				else
					painting_data.bucket_fill(mix_color_from_reagents(container.reagents.reagent_list))
				container.reagents.remove_any(5)
				update_painting(TRUE)

			return TRUE

	// Cleaning
	if (istype(W, /obj/item/weapon/soap) && !protected_by_glass)
		if (protected_by_glass)
			to_chat(usr, "<span class='warning'>\the [name]'s glass cover stops you from cleaning it off.</span>")
		else
			to_chat(usr, "<span class='warning'>You start cleaning \the [name].</span>")
			if (do_after(user, src, 20))
				painting_data.blank_contents()
				update_painting(TRUE)

	// Framing
	if (istype(W, /obj/item/stack/sheet/wood) && !framed)
		framed = TRUE
		to_chat(usr, "<span class='notice'>You frame \the [name].</span>")
		update_painting()
		var/obj/item/stack/sheet/wood/WS = W
		WS.use(1)
		materials.addAmount(WS.mat_type, WS.perunit)

	if (iscrowbar(W) && framed)
		to_chat(usr, "<span class='warning'>You struggle to pop \the [name] out of it's frame.</span>")
		if (do_after(user, src, 6))
			if (protected_by_glass)
				protected_by_glass = FALSE
				to_chat(usr, "<span class='warning'>\the [name]'s glass cover pops out and breaks!.</span>")
				playsound(src, "shatter", 50, TRUE)
				var/obj/item/stack/sheet/glass/glass/GS = new(user.loc, 1)
				materials.removeAmount(GS.mat_type, GS.perunit)
				qdel(GS)
				var/obj/item/weapon/shard/shard = new()
				shard.forceMove(user.loc)
			framed = FALSE
			to_chat(usr, "<span class='notice'>You pop \the [name] out of it's frame.</span>")
			update_painting()
			var/obj/item/stack/sheet/wood/WS = new(user.loc, 1)
			materials.removeAmount(WS.mat_type, WS.perunit)
			WS.forceMove(user.loc)

	// Protecting with glass
	if (istype(W, /obj/item/stack/sheet/glass/glass) && !protected_by_glass)
		if (!framed)
			to_chat(usr, "<span class='warning'>\the [name] needs a frame to hold the glass sheet.</span>")
		else
			var/obj/item/stack/sheet/glass/glass/GS = W
			GS.use(1)
			materials.addAmount(GS.mat_type, GS.perunit)
			protected_by_glass = TRUE
			update_painting()
			to_chat(usr, "<span class='notice'>You cover \the [name] with a glass sheet.</span>")

	if (W.is_screwdriver(user) && protected_by_glass)
		var/obj/item/stack/sheet/glass/glass/GS = new(user.loc, 1)
		GS.forceMove(user.loc)
		materials.removeAmount(GS.mat_type, GS.perunit)
		protected_by_glass = FALSE
		update_painting()
		to_chat(usr, "<span class='notice'>You screw off \the [name]'s glass cover.</span>")

	return ..()

/obj/structure/painting/custom/Topic(href, href_list)
	// Sanity checks
	if(..())
		return
	if(usr.incapacitated())
		return
	if (!usr.dexterity_check())
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if (!in_range(src, usr))
		return

	add_fingerprint(usr)
	add_hiddenprint(usr)

	// Let /datum/custom_painting handle Topic(). If succesful, update appearance
	if (painting_data.Topic(href, href_list))
		update_painting(TRUE)

/obj/structure/painting/custom/update_painting(render)
	blank = painting_data.is_blank()
	if (!blank)
		name = (painting_data.title ? ("\proper[painting_data.title]") : "untitled artwork") + (painting_data.author ? ", by [painting_data.author]" : "")
		desc = painting_data.description ? "A small plaque reads: \"<span class='info'>[painting_data.description]\"</span>" : "A painting... But what could it mean?"
		if (painting_data.copy)
			desc += "A tag on this artwork indicates that it's a replica reproduced from Nanotrasen's databanks."
		if (render)
			icon = painting_data.render_on(icon(base_icon, base_icon_state))
	else
		name = base_name
		desc = base_desc
		icon = icon(base_icon, base_icon_state)

	overlays.Cut()
	if (framed)
		overlays += icon(frame_icon, frame_icon_state)

	desc += protected_by_glass ? "\n A glass sheet protects it from would-be-vandals." : ""

/obj/structure/painting/custom/proc/set_painting_data(datum/custom_painting/painting_data)
	src.painting_data = painting_data
	src.painting_data.set_parent(src)

/obj/structure/painting/custom/to_item(mob/user)
	var/obj/item/mounted/frame/painting/custom/P = new(user.loc)
	unlock_from()

	// Painting info
	P.set_painting_data(painting_data.Copy())
	P.rendered_icon = icon
	P.base_name = base_name
	P.base_desc = base_desc
	P.base_icon = base_icon
	P.base_icon_state = base_icon_state
	P.frame_icon = frame_icon
	P.frame_icon_state = frame_icon_state
	P.blank = blank

	// Glass panel info
	P.framed = framed
	P.protected_by_glass = protected_by_glass
	P.materials = new /datum/materials(P)
	P.materials.addFrom(materials)

	P.update_painting()
	return P

/* ==== Custom painting (Item) ====
 * Whole lot of copy-paste here, sadly. Check out /obj/structure/painting/custom and make sure changes made here are
 *  applied there too.
 * Main difference is update_painting() renders on a separate icon (structure_icon), on conversion to structure (hanging)
 *  this separate icon is applied as the structure's icon
*/
/obj/item/mounted/frame/painting/custom
	name = "small canvas"
	desc = "What to draw?"
	var/base_name = "small canvas"
	var/base_desc = "What to draw?"
	var/blank = TRUE
	var/datum/custom_painting/painting_data

	var/framed = FALSE
	var/protected_by_glass = FALSE

	// Icon to render our painting data on
	var/base_icon = 'icons/obj/paintings.dmi'
	var/base_icon_state = "blank"
	var/frame_icon = 'icons/obj/painting_items.dmi'
	var/frame_icon_state = "frame"
	var/rendered_icon

	// Where to render the custom painting. Make sure it matches the structure icon state!
	var/painting_height = 14
	var/painting_width = 14
	var/painting_offset_x = 9
	var/painting_offset_y = 10
	var/base_color = "#ffffff"

	starting_materials = list(MAT_WOOD = 2 * CC_PER_SHEET_WOOD)

/obj/item/mounted/frame/painting/custom/New()
	src.painting_data = new(src, painting_width, painting_height, painting_offset_x, painting_offset_y, base_color)
	..()

/obj/item/mounted/frame/painting/custom/Destroy()
	QDEL_NULL(painting_data)
	..()

/obj/item/mounted/frame/painting/custom/attackby(obj/item/W, mob/user)
	// Painting
	var/datum/painting_utensil/p = new(user, W)
	if (p.palette.len)
		if (protected_by_glass)
			to_chat(usr, "<span class='warning'>\the [name]'s glass cover stops you from painting on it.</span>")
		else
			painting_data.interact(user, p)

	// Pouring
	if (istype(W, /obj/item/weapon/reagent_containers))
		if (protected_by_glass)
			return FALSE //Let the reagent container's afterattack handle things

		var/obj/item/weapon/reagent_containers/container = W
		if (container.is_open_container() && container.reagents && !container.reagents.is_empty())
			to_chat(usr, "<span class='warning'>You start pouring \the [container]'s contents over \the [name].</span>")
			if (do_after(user, src, 10))
				// Reagent mix is strong enough to clean the canvas, do so
				var/cleaner_percent = get_reagent_paint_cleaning_percent(container)
				if (cleaner_percent >= PAINT_CLEANER_THRESHOLD)
					painting_data.blank_contents()
					to_chat(usr, "<span class='warning'>You wash the paint off \the [name]!</span>")

				// Reagent mix is opaque enough to paint the canvas, do so
				else
					painting_data.bucket_fill(mix_color_from_reagents(container.reagents.reagent_list))
					container.reagents.remove_any(5)
				update_painting(TRUE)
			return TRUE

	// Cleaning
	if (istype(W, /obj/item/weapon/soap) && !protected_by_glass)
		if (protected_by_glass)
			to_chat(usr, "<span class='warning'>\the [name]'s glass cover stops you from cleaning it off.</span>")
		else
			to_chat(usr, "<span class='warning'>You start cleaning \the [name].</span>")
			if (do_after(user, src, 20))
				painting_data.blank_contents()
				update_painting(TRUE)

	// Framing
	if (istype(W, /obj/item/stack/sheet/wood) && !framed)
		framed = TRUE
		to_chat(usr, "<span class='notice'>You frame \the [name].</span>")
		update_painting()
		var/obj/item/stack/sheet/wood/WS = W
		WS.use(1)
		materials.addAmount(WS.mat_type, WS.perunit)

	if (iscrowbar(W) && framed)
		to_chat(usr, "<span class='warning'>You struggle to pop \the [name] out of it's frame.</span>")
		if (do_after(user, src, 6))
			if (protected_by_glass)
				protected_by_glass = FALSE
				to_chat(usr, "<span class='notice'>\the [name]'s glass cover pops out!</span>")
				var/obj/item/stack/sheet/glass/glass/GS = new(user.loc, 1)
				materials.removeAmount(GS.mat_type, GS.perunit)
				GS.forceMove(user.loc)
			framed = FALSE
			to_chat(usr, "<span class='notice'>You pop \the [name] out of it's frame.</span>")
			update_painting()
			var/obj/item/stack/sheet/wood/WS = new(user.loc, 1)
			materials.removeAmount(WS.mat_type, WS.perunit)
			WS.forceMove(user.loc)

	// Protecting with glass
	if (istype(W, /obj/item/stack/sheet/glass/glass) && !protected_by_glass)
		if (!framed)
			to_chat(usr, "<span class='warning'>\the [name] needs a frame to hold the glass sheet.</span>")
		else
			var/obj/item/stack/sheet/glass/glass/GS = W
			GS.use(1)
			materials.addAmount(GS.mat_type, GS.perunit)
			protected_by_glass = TRUE
			update_painting()
			to_chat(usr, "<span class='notice'>You cover \the [name] with a glass sheet.</span>")

	if (W.is_screwdriver(user) && protected_by_glass)
		var/obj/item/stack/sheet/glass/glass/GS = new(user.loc, 1)
		GS.forceMove(user.loc)
		materials.removeAmount(GS.mat_type, GS.perunit)
		protected_by_glass = FALSE
		update_painting()
		to_chat(usr, "<span class='notice'>You screw off \the [name]'s glass cover.</span>")

	return ..()

/obj/item/mounted/frame/painting/custom/Topic(href, href_list)
	if(..())
		return

	// Let /datum/custom_painting handle Topic(). If succesful, update appearance
	if (painting_data.Topic(href, href_list))
		update_painting(TRUE)

/obj/item/mounted/frame/painting/custom/update_painting(render)
	blank = painting_data.is_blank()
	if (!blank)
		name = (painting_data.title ? ("\proper[painting_data.title]") : "untitled artwork") + (painting_data.author ? ", by [painting_data.author]" : "")
		desc = painting_data.description ? "A small plaque reads: \"<span class='info'>[painting_data.description]\"</span>" : "A painting... But what could it mean?"
		if (render)
			rendered_icon = painting_data.render_on(icon(base_icon, base_icon_state))
	else
		name = base_name
		desc = base_desc
	desc += protected_by_glass ? "\n A glass sheet protects it from would-be-vandals" : ""

/obj/item/mounted/frame/painting/custom/proc/set_painting_data(datum/custom_painting/painting_data)
	src.painting_data = painting_data
	src.painting_data.set_parent(src)

/obj/item/mounted/frame/painting/custom/to_structure(turf/on_wall, mob/user)
	var/obj/structure/painting/custom/P = new(user.loc)

	// Painting info
	P.set_painting_data(painting_data.Copy())
	P.icon = rendered_icon ? rendered_icon : icon(base_icon, base_icon_state)
	P.icon_state = base_icon_state
	P.base_name = base_name
	P.base_desc = base_desc
	P.base_icon = base_icon
	P.base_icon_state = base_icon_state
	P.frame_icon = frame_icon
	P.frame_icon_state = frame_icon_state
	P.blank = blank

	// Glass panel info
	P.framed = framed
	P.protected_by_glass = protected_by_glass
	P.materials = new /datum/materials(P)
	P.materials.addFrom(materials)

	P.update_painting()
	return P

/*
 * ==== Variants ====
 * Each variant should have both an /item/mounted and /structure version so they can be either
 *  mapped in or created through recipes without issue
*/

// Blank landscape canvas
/obj/item/mounted/frame/painting/custom/landscape
	name = "landscape canvas"
	base_name = "landscape canvas"
	base_icon_state = "blank_landscape"
	frame_icon_state = "frame_landscape"
	painting_height = 14
	painting_width = 24
	painting_offset_x = 4
	painting_offset_y = 10
	// Material data
	starting_materials = list(MAT_WOOD = CC_PER_SHEET_WOOD * 3)

/obj/structure/painting/custom/landscape
	name = "landscape canvas"
	base_name = "landscape canvas"
	icon_state = "blank_landscape"
	base_icon_state = "blank_landscape"
	frame_icon_state = "frame_landscape"

	painting_height = 14
	painting_width = 24
	painting_offset_x = 4
	painting_offset_y = 10
	// Material data
	starting_materials = list(MAT_WOOD = CC_PER_SHEET_WOOD * 3)

// Blank portrait canvas
/obj/item/mounted/frame/painting/custom/portrait
	name = "portrait canvas"
	base_name = "portrait canvas"
	base_icon_state = "blank_portrait"
	frame_icon_state = "frame_portrait"
	painting_height = 24
	painting_width = 14
	painting_offset_x = 9
	painting_offset_y = 4
	// Material data
	starting_materials = list(MAT_WOOD = CC_PER_SHEET_WOOD * 3)

/obj/structure/painting/custom/portrait
	name = "portrait canvas"
	base_name = "portrait canvas"
	icon_state = "blank_portrait"
	base_icon_state = "blank_portrait"
	frame_icon_state = "frame_portrait"
	painting_height = 24
	painting_width = 14
	painting_offset_x = 9
	painting_offset_y = 4
	// Material data
	starting_materials = list(MAT_WOOD = CC_PER_SHEET_WOOD * 3)

// Large blank canvas
/obj/item/mounted/frame/painting/custom/large
	name = "large canvas"
	base_name = "large canvas"
	desc = "The larger the canvas, the more overwhelming it is to put pen to paper and get started."
	base_desc = "The larger the canvas, the more overwhelming it is to put pen to paper and get started."
	base_icon_state = "blank_large"
	frame_icon_state = "frame_large"
	painting_height = 24
	painting_width = 24
	painting_offset_x = 4
	painting_offset_y = 4
	// Material data
	starting_materials = list(MAT_WOOD = CC_PER_SHEET_WOOD * 5)

/obj/structure/painting/custom/large
	name = "large canvas"
	base_name = "large canvas"
	desc = "The larger the canvas, the more overwhelming it is to put pen to paper and get started."
	base_desc = "The larger the canvas, the more overwhelming it is to put pen to paper and get started."
	icon_state = "blank_large"
	base_icon_state = "blank_large"
	frame_icon_state = "frame_large"
	painting_height = 24
	painting_width = 24
	painting_offset_x = 4
	painting_offset_y = 4
	// Material data
	starting_materials = list(MAT_WOOD = CC_PER_SHEET_WOOD * 5)
