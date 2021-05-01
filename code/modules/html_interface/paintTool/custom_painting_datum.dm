/datum/custom_painting

	var/parent

	var/bitmap_width = 14
	var/bitmap_height = 14

	var/offset_x = 0
	var/offset_y = 0

	var/base_color = "#ffffff"

	var/list/bitmap = list()

	var/datum/href_multipart_handler/mp_handler
	var/datum/html_interface/interface

	var/author = ""
	var/title = ""
	var/description = ""

/datum/custom_painting/New(var/parent, var/bitmap_width, var/bitmap_height, var/offset_x, var/offset_y, var/base_color=src.base_color)
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
	qdel(interface)
	interface = null

	qdel(mp_handler)
	mp_handler = null

	qdel(bitmap)
	bitmap = null

/datum/custom_painting/proc/blank_contents()
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

/datum/custom_painting/proc/interact(mob/user)

	// Prepare inputs
	//TODO: tool data(palette, opacity)
	var/paint_init_inputs = json_encode(list(
		"width" = bitmap_width,
		"height" = bitmap_height,
		"bitmap" = bitmap,
		"minPaintStrength" = 0,
		"maxPaintStrength" = 1
	))

	var/canvas_init_inputs = json_encode(list(
		"src" = "\ref[parent]",
		"palette" = list("#000000", "#ffffff", "#ff0000", "#ffff00", "#00ff00", "#00ffff", "#0000ff", "#ff00ff"),
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
		var/obj/item/held_item = usr.get_active_hand()
		if(!istype(held_item, /obj/item/weapon/pen))
			//TODO other tools (crayons, brushes)
			to_chat(usr, "<span class='warning'>You need to be holding a painting utensil in your active hand.</span>")
			return

		//Save and sanitize bitmap
		bitmap = splittext(url_decode(href_list["bitmap"]), ",")
		for (var/i; i <= bitmap.len; i++)
			bitmap[i] = sanitize_hexcolor(bitmap[i])

		//Save and sanitize author, title and description
		author = copytext(sanitize(url_decode(href_list["author"])), 1, MAX_NAME_LEN)
		title = copytext(sanitize(url_decode(href_list["title"])), 1, MAX_NAME_LEN)
		description = copytext(sanitize(url_decode(href_list["description"])), 1, MAX_MESSAGE_LEN)
		return TRUE
