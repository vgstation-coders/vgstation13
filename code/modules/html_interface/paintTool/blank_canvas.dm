
/obj/item/mounted/frame/painting/blank
	//paint = "blank"

	var/bitmap_height = 12
	var/bitmap_width = 12

	var/list/bitmap = list()
	var/datum/html_interface/interface

/obj/item/mounted/frame/painting/blank/New()
	..()

	// Blank the painting's contents
	for (var/i = 0, i < bitmap_height * bitmap_width, i++)
		bitmap += rgb(255, 255, 255)

	// Setup head
	var/head = "<script src=\"paintTool.js\"></script>"

	// Use NT-style UI
	src.interface = new/datum/html_interface/nanotrasen(src, "Canvas", 600, 600, head)

	// Setup contents
	//TODO: move filepath somewhere accesible by other .dm files
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
	var/bitmap_string = "[bitmap[1]]"
	for (var/i = 2, i < bitmap.len, i++)
		bitmap_string += ",[bitmap[i]]"
	var/canvas_data_inputs = {"
	<input type="text" id="width" value="[bitmap_width]"/>
	<input type="text" id="height" value="[bitmap_height]"/>
	<input type="textarea" id="bitmap" value="[bitmap_string]"/>
	"}
	interface.updateContent("canvas_data_inputs", canvas_data_inputs, TRUE)

	// Set tool data (palette, strength...) //TODO
	var/tool_data_inputs = "<input type=\"text\" id=\"paint_strength\" value=\"0.2\"/>"
	var/palette_buttons = ""
	for (var/color in list(rgb(0,0,0), rgb(255, 0, 0), rgb(0, 255, 0), rgb(0, 0, 255), rgb(255, 255, 255)))
		palette_buttons += "<input type=\"button\" onclick=\"setColor('[color]');\" style=\"background: [color]\"/>"
	interface.updateContent("tool_data_inputs", tool_data_inputs, TRUE)
	interface.updateContent("palette_buttons", palette_buttons, TRUE)

	// Send script assets, and wait for them to load before showing UI and initializing said script
	var/delay = 0
	delay += send_asset(user.client, "paintTool.js")
	spawn(delay)
		interface.show(user)
		interface.executeJavaScript("init()", user)


//TODO
//obj/item/mounted/frame/painting/blank/Topic(href, href_list)
