#define PENCIL_STRENGTH_MAX 0.15
#define PENCIL_STRENGTH_MIN 0
#define BRUSH_STRENGTH_MAX 1
#define BRUSH_STRENGTH_MIN 0

/datum/painting_utensil
	var/min_strength = 0
	var/max_strength = 1
	var/list/palette = list()

/datum/painting_utensil/New(mob/user, obj/item/held_item = user.get_active_hand())
	if (istype(held_item, /obj/item/weapon/pen))
		var/obj/item/weapon/pen/p = held_item
		max_strength = PENCIL_STRENGTH_MAX
		min_strength = PENCIL_STRENGTH_MIN
		palette += p.colour_rgb

	if (istype(held_item, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/c = held_item
		max_strength = PENCIL_STRENGTH_MAX
		min_strength = PENCIL_STRENGTH_MIN
		palette += c.colour
		palette += c.shadeColour

/datum/custom_painting
	var/parent

	// Array listing all colors, starting from the upper left corner
	var/list/bitmap = list()
	var/bitmap_width = 14
	var/bitmap_height = 14

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
	parent = null

	qdel(interface)
	interface = null

	qdel(mp_handler)
	mp_handler = null

/datum/custom_painting/proc/Copy()
	var/datum/custom_painting/copy = new(parent, bitmap_width, bitmap_height, offset_x, offset_y, base_color)
	copy.author = author
	copy.title = title
	copy.description = description
	copy.bitmap = bitmap.Copy()
	return copy

/datum/custom_painting/proc/set_parent(parent)
	src.parent = parent
	mp_handler.set_parent(parent)


/datum/custom_painting/proc/blank_contents()
	bitmap = list()
	for (var/i = 0, i < bitmap_height * bitmap_width, i++)
		bitmap += base_color

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
	interface.updateContent("content", file2text("code/modules/html_interface/paintTool/canvas.tmpl"))

/datum/custom_painting/proc/interact(mob/user, datum/painting_utensil/p)
	var/paint_init_inputs = json_encode(list(
		"width" = bitmap_width,
		"height" = bitmap_height,
		"bitmap" = bitmap,
		"minPaintStrength" = p.min_strength,
		"maxPaintStrength" = p.max_strength
	))

	var/canvas_init_inputs = json_encode(list(
		"src" = "\ref[parent]",
		"palette" = p.palette, //list("#000000", "#ffffff", "#ff0000", "#ffff00", "#00ff00", "#00ffff", "#0000ff", "#ff00ff"),
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
	spawn(delay)
		interface.show(user)
		interface.callJavaScript("initCanvas", list(paint_init_inputs,canvas_init_inputs), user)


/datum/custom_painting/Topic(href, href_list)
	// Handle multipart href
	if (href_list["multipart"])
		mp_handler.Topic(href, href_list)
		return

	// Save changes
	else
		// Make sure the player can actually paint
		if(!usr || usr.incapacitated())
			return

		if(!(new /datum/painting_utensil(usr)).palette.len)
			//TODO other tools (crayons, brushes)
			to_chat(usr, "<span class='warning'>You need to be holding a painting utensil in your active hand.</span>")
			return

		if (!do_after(usr, parent, 30))
			return

		//Save and sanitize bitmap
		bitmap = splittext(url_decode(href_list["bitmap"]), ",")
		for (var/i = 1; i <= bitmap.len; i++)
			bitmap[i] = sanitize_hexcolor(bitmap[i])

		//Save and sanitize author, title and description
		author = copytext(sanitize(url_decode(href_list["author"])), 1, MAX_NAME_LEN)
		title = copytext(sanitize(url_decode(href_list["title"])), 1, MAX_NAME_LEN)
		description = copytext(sanitize(url_decode(href_list["description"])), 1, MAX_MESSAGE_LEN)
		return TRUE

/datum/custom_painting/proc/render_on(icon/ico, offset_x = src.offset_x, offset_y = src.offset_y)
	var/x
	var/y
	for (var/pixel = 0; pixel < bitmap.len; pixel++)
		x = pixel % bitmap_width
		y = (pixel - x)/bitmap_width

		//for DrawBox, (x:1,y:1) is the lower left corner. On bitmap, (x:0,y:0) is the upper left
		x = 1 + offset_x + x
		y = 1 + offset_y + bitmap_height - y

		ico.DrawBox(bitmap[pixel + 1], x, y)

	return ico

#undef PENCIL_STRENGTH_MAX
#undef PENCIL_STRENGTH_MIN
#undef BRUSH_STRENGTH_MAX
#undef BRUSH_STRENGTH_MIN
