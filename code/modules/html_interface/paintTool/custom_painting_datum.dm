#define PENCIL_STRENGTH_MAX 0.15
#define PENCIL_STRENGTH_MIN 0
#define BRUSH_STRENGTH_MAX 1
#define BRUSH_STRENGTH_MIN 0

/*
 * PAINTING UTENSIL DATUM
 *
 * Add any items that can be used to it's New() so it is properly converted into the right data
 *
*/
/datum/painting_utensil
	var/min_strength = 0
	var/max_strength = 1
	var/list/palette = list() // List of colors that will be made available while painting
	var/list/nano_palette = list()
	var/base_color
	var/nano_paint = FALSE
	var/polarized = FALSE
	var/list/components = list()

/datum/painting_utensil/New(mob/user, obj/item/held_item)
	if (!user) // Special case
		return
	if (!held_item)
		held_item = user.get_active_hand()

	// Painting with a pen
	if (istype(held_item, /obj/item/weapon/pen))
		var/obj/item/weapon/pen/p = held_item
		max_strength = PENCIL_STRENGTH_MAX
		min_strength = PENCIL_STRENGTH_MIN
		palette += p.colour_rgb
		nano_palette += "#161616"
		base_color = p.colour_rgb
		components = list("pen ink")

	// Painting with a crayon
	if (istype(held_item, /obj/item/toy/crayon))
		components = list("crayon")
		for (var/obj/item/weapon/storage/fancy/crayons/box in user.held_items)
			for (var/crayon in box)
				var/obj/item/toy/crayon/c = crayon
				max_strength = PENCIL_STRENGTH_MAX
				min_strength = PENCIL_STRENGTH_MIN
				palette += c.mainColour
				palette += c.shadeColour
				base_color = c.mainColour

		var/obj/item/toy/crayon/c = held_item
		max_strength = PENCIL_STRENGTH_MAX
		min_strength = PENCIL_STRENGTH_MIN
		palette += c.mainColour
		nano_palette += "#161616"
		palette += c.shadeColour
		nano_palette += "#161616"
		base_color = c.mainColour

	// Painting with hair dye sprays
	if (istype(held_item, /obj/item/weapon/hair_dye))
		components = list("hair dye")
		var/obj/item/weapon/hair_dye/h = held_item
		max_strength = PENCIL_STRENGTH_MAX
		min_strength = PENCIL_STRENGTH_MIN
		palette += rgb(h.color_r, h.color_g, h.color_b)
		nano_palette += "#161616"
		base_color = rgb(h.color_r, h.color_g, h.color_b)

	// Painting with a brush
	if (istype(held_item, /obj/item/painting_brush))
		// If holding a palette (item) add it's colors to the brush's list

		var/obj/item/painting_brush/b = held_item
		components = b.component.Copy()

		for (var/obj/item/palette/pal in user.held_items)
			for (var/c in pal.stored_colours)
				palette += pal.stored_colours[c]
				switch(pal.nanopaint_indexes[c])
					if (PAINTLIGHT_NONE)
						nano_palette += "#161616"
					if (PAINTLIGHT_LIMITED)
						nano_palette += "#999999"
					if (PAINTLIGHT_FULL)
						nano_palette += "#FFFFFF"

		if (b.paint_color)
			max_strength = BRUSH_STRENGTH_MAX
			min_strength = BRUSH_STRENGTH_MIN
			// Players are likely to have one of the palette's colors on their brush from mixing colors earlier,
			//  so make sure we're not adding it again to the list
			if (!(b.paint_color in palette))
				palette += b.paint_color
				switch(b.nano_paint)
					if (PAINTLIGHT_NONE)
						nano_palette += "#161616"
					if (PAINTLIGHT_LIMITED)
						nano_palette += "#999999"
					if (PAINTLIGHT_FULL)
						nano_palette += "#FFFFFF"
			base_color = b.paint_color
			nano_paint = b.nano_paint

	// Wearing polarized glasses
	polarized = FALSE
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		if (istype(H.glasses, /obj/item/clothing/glasses/sunglasses/polarized))
			polarized = TRUE
	else if (ismonkey(user))
		var/mob/living/carbon/monkey/M = user
		if (istype(M.glasses, /obj/item/clothing/glasses/sunglasses/polarized))
			polarized = TRUE

	// Normalize palette colors
	for (var/i = 1; i < palette.len; i++)
		palette[i] = lowertext(palette[i])
		if (length(palette[i]) < 9) //If missing alpha channel assume opaque
			palette[i] += "ff"
	// Normalize base color
	if (base_color)
		base_color = lowertext(base_color)
		if (length(base_color) < 9) //If missing alpha channel assume opaque
			base_color += "ff"


/datum/painting_utensil/proc/duplicate()
	var/datum/painting_utensil/dupe = new(null, null)
	dupe.max_strength = src.max_strength
	dupe.min_strength = src.min_strength
	dupe.palette = src.palette
	dupe.nano_palette = src.nano_palette
	dupe.base_color = src.base_color
	dupe.nano_paint = src.nano_paint
	dupe.components = src.components.Copy()
	dupe.tag = "\ref[dupe]"
	return dupe

/*
* CUSTOM PAINTING DATUM
*
* Add this to any object you should be able to paint on, setting said object as this datum's parent, either through New()
* or set_parent() if moving this datum to a different object
*
* Call interact() when the user starts painting
*/

/datum/custom_painting
	var/parent

	// Array listing all colors, starting from the upper left corner
	var/list/bitmap = list()
	var/bitmap_width = 14
	var/bitmap_height = 14

	// Secondary luminous bitmap for when working with nano-paint
	var/list/nanomap = list()
	var/has_nano_paint = FALSE

	// Color that shows up on creation or after cleaning
	var/base_color = "#ffffff"

	// Position of the lower left corner of the image when rendering the bitmap onto an icon
	var/offset_x = 0
	var/offset_y = 0

	// UI and JS stuff
	var/datum/html_interface/interface
	var/datum/href_multipart_handler/mp_handler

	var/author = ""
	var/title = ""
	var/description = ""
	var/contributing_artists = list()
	var/show_on_scoreboard = TRUE

	var/copy = 0

	var/list/components = list()

/datum/custom_painting/New(parent, bitmap_width, bitmap_height, offset_x=0, offset_y=0, base_color=src.base_color)
	src.parent = parent
	src.bitmap_width = bitmap_width
	src.bitmap_height = bitmap_height
	src.offset_x = offset_x
	src.offset_y = offset_y
	src.base_color = base_color
	mp_handler = new /datum/href_multipart_handler(parent)
	blank_contents()
	setup_UI()

/datum/custom_painting/Destroy()
	..()

	if (istype(parent, /turf/simulated))
		var/turf/simulated/S = parent
		S.advanced_graffiti = null

	parent = null

	QDEL_NULL(interface)

	QDEL_NULL(mp_handler)

/datum/custom_painting/proc/Copy()
	var/datum/custom_painting/copy = new(parent, bitmap_width, bitmap_height, offset_x, offset_y, base_color)
	copy.author = author
	copy.title = title
	copy.description = description
	copy.bitmap = bitmap.Copy()
	copy.nanomap = nanomap.Copy()
	copy.components = components.Copy()
	copy.has_nano_paint = has_nano_paint
	return copy

/datum/custom_painting/proc/set_parent(parent)
	src.parent = parent
	mp_handler.set_parent(parent)

/datum/custom_painting/proc/smear(var/amount=50, var/strength=1)
	var/list/list_of_numbers = list()
	var/list/pixels_to_shift = list()

	for (var/i = 1 to bitmap.len)
		list_of_numbers += "[i]"
	for (var/i = 1 to amount)
		var/num = pick(list_of_numbers)
		var/actual_num = text2num(num)
		list_of_numbers -= num
		pixels_to_shift[num] = list(bitmap[actual_num], nanomap[actual_num])//saving pixel data and location before smearing

	for (var/index in pixels_to_shift)
		var/list/colors_to_move = pixels_to_shift[index]
		var/actual_index = text2num(index)
		var/new_index = actual_index
		for (var/i = 1 to strength)
			new_index = actual_index + bitmap_width
			if (new_index > bitmap.len)
				new_index -= bitmap.len
				colors_to_move = list(base_color, "#000000")
			bitmap[new_index] = colors_to_move[1]
			nanomap[new_index] = colors_to_move[2]

/datum/custom_painting/proc/bucket_fill(var/color,var/nanopaint=PAINTLIGHT_NONE)
	bitmap = list()
	nanomap = list()
	if (nanopaint != PAINTLIGHT_NONE)
		for (var/i = 0, i < bitmap_height * bitmap_width, i++)
			bitmap += color
			if (uppertext(color) == "#FFFFFF")
				color = "#FEFEFE"//workaround because white nano paint doesn't glow up for some reason
			nanomap += color
	else
		for (var/i = 0, i < bitmap_height * bitmap_width, i++)
			bitmap += color
			nanomap += "#000000"


/datum/custom_painting/proc/blank_contents()
	components = list()
	bucket_fill(base_color)

/datum/custom_painting/proc/is_blank()
	if (author || title || description)
		return FALSE

	for (var/b in bitmap)
		if (b != base_color)
			return FALSE
	for (var/b in nanomap)
		if (b != "#000000")
			return FALSE

	return TRUE

/datum/custom_painting/proc/setup_UI()
	// Setup head
	var/head = {"
		<link rel=\"stylesheet\" type=\"text/css\" href=\"canvas.css\" />
		<link rel=\"stylesheet\" type=\"text/css\" href=\"shared.css\" />
		<link rel=\"stylesheet\" type=\"text/css\" href=\"html_interface_icons.css\" />
		<script src=\"paintTool.js\"></script>
		<script src=\"canvas.js\"></script>
		<script src=\"href_multipart_handler.js\"></script>
	"}

	// Use NT-style UI
	src.interface = new/datum/html_interface/nanotrasen(src, "Canvas", 600, 600, head)

	// Setup contents
	if (bitmap_height < 32)
		interface.updateContent("content", file2text("code/modules/html_interface/paintTool/canvas.tmpl"))
	else
		interface.updateContent("content", file2text("code/modules/html_interface/paintTool/canvas_tile.tmpl"))

/datum/custom_painting/proc/interact(mob/user, datum/painting_utensil/p)
	if(jobban_isbanned(user, "artist"))
		to_chat(user, "<span class='warning'>Try as you might, you cannot possibly work out the intricacies of fine art!</span>")
		return

	var/paint_init_inputs = json_encode(list(
		"width" = bitmap_width,
		"height" = bitmap_height,
		"bitmap" = bitmap,
		"nanomap" = nanomap,
		"nanopaint" = p.nano_paint,
		"polarized" = p.polarized,
		"minPaintStrength" = p.min_strength,
		"maxPaintStrength" = p.max_strength,
	))

	var/canvas_init_inputs = json_encode(list(
		"src" = "\ref[parent]",
		"palette" = p.palette, //list("#000000", "#ffffff", "#ff0000", "#ffff00", "#00ff00", "#00ffff", "#0000ff", "#ff00ff"),
		"nano_palette" = p.nano_palette,
		"title" = title,
		"author" = author,
		"description" = description
	))

	// Send assets, wait for them to load before showing UI and initializing scripts
	var/delay = 0
	delay += send_asset(user.client, "paintTool.js")
	delay += send_asset(user.client, "canvas.js")
	delay += send_asset(user.client, "href_multipart_handler.js")
	delay += send_asset(user.client, "canvas.css")
	delay += send_asset(user.client, "checkerboard.png")
	spawn(delay)
		if (bitmap_height > 26 || bitmap_width > 26)
			interface.height = 800
			interface.width = 960
		interface.show(user)
		interface.callJavaScript("initCanvas", list(paint_init_inputs,canvas_init_inputs), user)


/datum/custom_painting/Topic(href, href_list)
	// Handle multipart href
	if (href_list["multipart"])
		mp_handler.Topic(href, href_list)
		return

	// Change painting brush color
	else if (href_list["newcolor"])
		var/mob/user = usr
		var/obj/item/held_item = user.get_active_hand()
		if (istype(held_item,/obj/item/painting_brush))
			var/obj/item/painting_brush/PB = held_item
			PB.paint_color = href_list["newcolor"]
			PB.nano_paint = text2num(href_list["nanopaint"])
			for (var/obj/item/palette/pal in user.held_items)
				for (var/c in pal.stored_colours)
					var/found = FALSE
					if (pal.stored_colours[c] == PB.paint_color)
						var/list/pal_comp = pal.components[c]
						PB.component = pal_comp.Copy()
						found = TRUE
						break
					if (!found)
						PB.component = PB.component_alt.Copy()//using the original brush color that isn't on the palette
			PB.update_icon()

	// Save changes
	else
		// Make sure the player can actually paint
		if(!usr || usr.incapacitated())
			return

		var/datum/painting_utensil/pu = new /datum/painting_utensil(usr)
		if(!pu.palette.len)
			to_chat(usr, "<span class='warning'>You need to be holding a painting utensil in your active hand.</span>")
			return

		if (!do_after(usr, parent, 30))
			return

		components |= pu.components//This won't get us all the components if the player changed c

		//Save and sanitize bitmap
		bitmap = splittext(url_decode(href_list["bitmap"]), ",")
		for (var/i = 1; i <= bitmap.len; i++)
			bitmap[i] = sanitize_hexcolor(bitmap[i])
		nanomap = splittext(url_decode(href_list["nanomap"]), ",")
		for (var/i = 1; i <= nanomap.len; i++)
			nanomap[i] = sanitize_hexcolor(nanomap[i])

		//Save and sanitize author, title and description
		author = copytext(sanitize(url_decode(href_list["author"])), 1, MAX_NAME_LEN)
		title = copytext(sanitize(url_decode(href_list["title"])), 1, MAX_NAME_LEN)
		description = copytext(sanitize(url_decode(href_list["description"])), 1, MAX_MESSAGE_LEN)
		contributing_artists += usr.ckey

		// Should I be using COMSIG or events for this ? :thinking:
		if (istype(parent, /turf/simulated/floor))
			var/turf/simulated/floor/F = parent
			F.render_advanced_graffiti(src, usr)

		playsound(usr.loc, get_sfx("mop"), 10, 1)

		return TRUE

/datum/custom_painting/proc/render_on(icon/ico, offset_x = src.offset_x, offset_y = src.offset_y)
	var/x
	var/y
	for (var/pixel = 0; pixel < bitmap.len; pixel++)
		x = pixel % bitmap_width
		y = (pixel - x)/bitmap_width

		//for DrawBox, (x:1,y:1) is the lower left corner. On bitmap, (x:0,y:0) is the upper left
		x = 1 + offset_x + x
		y = offset_y + bitmap_height - y

		ico.DrawBox(bitmap[pixel + 1], x, y)

	return ico

/datum/custom_painting/proc/render_nanomap(icon/ico, offset_x = src.offset_x, offset_y = src.offset_y)
	var/x
	var/y
	has_nano_paint = FALSE
	for (var/pixel = 0; pixel < nanomap.len; pixel++)
		x = pixel % bitmap_width
		y = (pixel - x)/bitmap_width

		//for DrawBox, (x:1,y:1) is the lower left corner. On bitmap, (x:0,y:0) is the upper left
		x = 1 + offset_x + x
		y = offset_y + bitmap_height - y

		ico.DrawBox(nanomap[pixel + 1], x, y)

		if (nanomap[pixel + 1] != "#000000")
			has_nano_paint = TRUE

	return image(ico)

/datum/custom_painting/proc/get_components()
	var/mats = ""

	var/is_drawing = TRUE
	var/list/drawing_implements = list(
		"crayon",
		"pen ink",
		)
	if (components.len > 0)
		var/mat = components[1]
		mats = "\a [mat]"
		if (!(mat in drawing_implements))
			is_drawing = FALSE

		for (var/i = 2 to components.len)
			if (i == components.len)
				mats += " and "
			else
				mats += ", "

			mat = components[i]
			if (!(mat in drawing_implements))
				is_drawing = FALSE
			mats += mat

		if (is_drawing)
			mats += " drawing"
		else
			mats += " painting"

	return mats

// -- export/import stuff
// -- don't we have a serializer for this? :thinking:

/proc/painting2json(var/datum/custom_painting/painting)
	var/list/L = list(
		painting.bitmap_width,
		painting.bitmap_height,
		painting.offset_x,
		painting.offset_y,
		painting.base_color,
		painting.bitmap,
		painting.nanomap,
		painting.components,
	)
	return json_encode(L)

/proc/json2painting(var/json_data, var/title, var/author, var/description)
	var/list/L = json_decode(json_data)
	var/datum/custom_painting/painting = new(null, L[1], L[2], L[3], L[4], L[5]) // no parents
	var/list/bitmap_to_copy = L[6]
	painting.bitmap = bitmap_to_copy.Copy()
	if (L.len > 6)//post Paint & Linen update
		var/list/nanomap_to_copy = L[7]
		painting.nanomap = nanomap_to_copy.Copy()
		var/list/components_to_copy = L[8]
		painting.components = components_to_copy.Copy()
	painting.title = title
	painting.author = author
	painting.description = description
	painting.copy = 1
	painting.show_on_scoreboard = FALSE //sorry, OC only
	return painting

#undef PENCIL_STRENGTH_MAX
#undef PENCIL_STRENGTH_MIN
#undef BRUSH_STRENGTH_MAX
#undef BRUSH_STRENGTH_MIN
