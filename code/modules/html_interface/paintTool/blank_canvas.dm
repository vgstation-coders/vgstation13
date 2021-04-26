
/obj/item/mounted/frame/painting/blank
	//paint = "blank"

	var/bitmap_height = 14
	var/bitmap_width = 14

	var/author = ""
	var/title = ""
	var/description = ""


	var/list/bitmap = list()
	var/datum/html_interface/interface

/obj/item/mounted/frame/painting/blank/New()
	..()

	// Blank the painting's contents
	for (var/i = 0, i < bitmap_height * bitmap_width, i++)
		bitmap += rgb(255, 255, 255)

	// Setup head
	var/head = {"
		<link rel=\"stylesheet\" type=\"text/css\" href=\"canvas.css\" />
		<link rel=\"stylesheet\" type=\"text/css\" href=\"shared.css\" />
		<link rel=\"stylesheet\" type=\"text/css\" href=\"html_interface_icons.css\" />
		<script src=\"paintTool.js\"></script>
		<script src=\"canvas.js\"></script>
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
	for (var/i = 2, i < bitmap.len, i++)
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
	delay += send_asset(user.client, "canvas.css")
	spawn(delay)
		interface.show(user)
		interface.callJavaScript("initCanvas", list(paint_init_inputs,canvas_init_inputs), user)
	world.log << "test"

//TODO ing
/obj/item/mounted/frame/painting/blank/Topic(href, href_list)
	world.log << "TESTING!"
	world.log << href_list["src"]
	world.log << href_list["bitmap"]
	world.log << href_list["title"]
	world.log << href_list["author"]
	world.log << href_list["description"]
	return ..()
