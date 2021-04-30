
/obj/item/mounted/frame/painting/blank
	//paint = "blank"

	var/bitmap_height = 14
	var/bitmap_width = 14

	var/blank = 1

	var/author = ""
	var/title = ""
	var/description = ""

	var/datum/href_multipart_handler/mp_handler


	var/list/bitmap = list()
	var/datum/html_interface/interface

/obj/item/mounted/frame/painting/blank/New()
	..()

	mp_handler = new /datum/href_multipart_handler(src)

	// Blank the painting's contents
	for (var/i = 0, i < bitmap_height * bitmap_width, i++)
		bitmap += "#ffffff"

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

/obj/item/mounted/frame/painting/blank/Destroy()
	..()
	qdel(interface)
	interface = null

/obj/item/mounted/frame/painting/blank/attackby(var/obj/item/W, var/mob/user)
	if (istype(W, /obj/item/weapon/pen))//TODO other tools (crayons, brushes)
		interact(user)
	return ..()

/obj/item/mounted/frame/painting/blank/interact(mob/user)

	// Set canvas data (contents, size...)
	var/bitmap_array = "\[\"[bitmap[1]]\""
	for (var/i = 2, i <= bitmap.len, i++)
		bitmap_array += ",\"[bitmap[i]]\""
	bitmap_array += "]"

	var/paint_init_inputs = {"
		{
			\"width\":[bitmap_height],
			\"height\":[bitmap_width],
			\"bitmap\":[bitmap_array],
			\"minPaintStrength\":0,
			\"maxPaintStrength\":1
		}
	"}
	var/color_array = "\[\"#000000\", \"#ffffff\", \"#ff0000\", \"#ffff00\", \"#00ff00\", \"#00ffff\", \"#0000ff\", \"#ff00ff\"]"
	var/canvas_init_inputs = {"
		{
			\"src\":\"\ref[src]\",
			\"palette\": [color_array],
			\"title\": \"[title]\",
			\"author\": \"[author]\",
			\"description\": \"[description]\"
		}
	"}

	// Set tool data (palette, strength...) //TODO
	//interface.updateContent("<a href='?src=\ref[src];action=startgame'>Submit</a>");

	// Send assets, and wait for them to load before showing UI and initializing scripts
	var/delay = 0
	delay += send_asset(user.client, "paintTool.js")
	delay += send_asset(user.client, "canvas.js")
	delay += send_asset(user.client, "href_multipart_handler.js")
	delay += send_asset(user.client, "canvas.css")
	spawn(delay)
		interface.show(user)
		interface.callJavaScript("initCanvas", list(paint_init_inputs,canvas_init_inputs), user)

/obj/item/mounted/frame/painting/blank/Topic(href, href_list)
	world.log << href
	if (href_list["multipart"])
		mp_handler.Topic(href, href_list)
	else
		//Save and sanitize bitmap
		bitmap = splittext(url_decode(href_list["bitmap"]), ",")
		for (var/i; i <= bitmap.len; i++)
			bitmap[i] = sanitize_hexcolor(bitmap[i])

		//Save and sanitize author, title and description
		author = copytext(sanitize(url_decode(href_list["author"])), 1, MAX_NAME_LEN)
		title = copytext(sanitize(url_decode(href_list["title"])), 1, MAX_NAME_LEN)
		description = copytext(sanitize(url_decode(href_list["description"])), 1, MAX_MESSAGE_LEN)

		//Update name and description
		blank = 0
		name = (title ? title : "\improper untitled artwork") + (author ? ", by [author]" : "")
		desc = "The author left the following note: \"<span class='info'>[description]\"</span>"

	return ..()

/obj/item/mounted/frame/painting/blank/proc/render()
	icon = 'icons/obj/paintings.dmi'
	icon_state = "item"
	item_state = "painting"
	//TODOing
