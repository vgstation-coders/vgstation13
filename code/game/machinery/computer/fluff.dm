//Unusable computers to be used as decorations for mapping

#define DENY_ACCESS_DENIED	0
#define DENY_TOO_OLD		1

/obj/machinery/computer/fluff

	var/window_data = "" //HTML to display to users
	var/window_width  = 300
	var/window_height = 300
	var/allow_silicons = TRUE


	var/deny_type = DENY_ACCESS_DENIED

/obj/machinery/computer/fluff/attack_ai(mob/user)
	if(isAdminGhost(user))

		//Some shitty-ass documentation here
		to_chat(user, "The following Topic() tags are handled: <b>notify_admin</b> (sends a notification to all admins), <b>notify_user</b> (displays a message to the user), <b>shutoff</b> (turns off the computer and erases all HTML). \ref\[src\] is added automatically to links. Keep HTML tags lowercase unless you don't want your links processed.")
		to_chat(user, "Link format: \<a href='notify_admin=Button pressed;shutoff=1'\>Button!\</a\>")

		var/new_window_data = input("Input new data to be displayed on this computer.", "Custom computer crafting", window_data) as null|message
		if(isnull(new_window_data))
			return
		var/new_window_width = input("Input new window width", "Custom computer crafting", window_width) as null|num
		var/new_window_height = input("Input new window height", "Custom computer crafting", window_height) as null|num

		//Fix all links so that they actually call Topic() on this computer
		//To prevent this replacetext from fucking up already fixed links, the 'a' tag is replaced with an uppercase 'A'. The case-sensitive replacetext will not touch it afterwards
		window_data = replacetextEx(new_window_data, "<a href='", "<A href='?src=\ref[src];")

		window_width = new_window_width
		window_height = new_window_height

		message_admins("[key_name(usr)] has modified the custom computer [src] ([formatJumpTo(src)])")
		log_admin("[key_name(usr)] has set the custom computer [src] ([formatJumpTo(src)]) to display: [window_data]")

	if(allow_silicons)
		return attack_hand(user)

/obj/machinery/computer/fluff/attack_hand(mob/user)
	if(window_data)
		var/datum/browser/popup = new(user, "customcomp", "[src]", window_width, window_height, src)
		popup.remove_stylesheets()
		popup.set_content(window_data)
		popup.open()
		return

	switch(deny_type)
		if(DENY_ACCESS_DENIED)
			to_chat(user, "<span class='warning'>Access denied.</span>")

		if(DENY_TOO_OLD)
			if(issilicon(user))
				to_chat(user, "<span class='warning'>Unable to establish connection: unknown interface type.</span>")
			else
				to_chat(user, "<span class='warning'>The buttons don't seem to do anything.</span>")

/obj/machinery/computer/fluff/Topic(href, href_list)
	if(..())
		return

	if(href_list["notify_admin"])
		message_admins("Incoming notification from the custom computer '[src]' [formatJumpTo(src)] (sent by [key_name(usr)]): [href_list["notify_admin"]]")

	if(href_list["notify_user"])
		to_chat(usr, "[bicon(src)][href_list["notify_user"]]")

	if(href_list["shutoff"])
		window_data = " "

	src.updateUsrDialog()

/obj/machinery/computer/fluff/emag(mob/user)
	if(user)
		to_chat(user, "<span class='notice'>You hold the cryptographic sequencer up to the ID scanner. Nothing happens.</span>")

////Shuttle fluffputers
/obj/machinery/computer/fluff/shuttle_control /*fluff shuttle console 1 */
	name = "shuttle console"
	desc = "This one appears to be password protected and heavily encrypted."
	icon_state = "shuttle"

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/fluff/shuttle_control/syndicate
	icon_state = "syndishuttle"

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/fluff/shuttle_engines
	name = "\improper Engine Control"
	desc = "A computer that controls this shuttle's engines and power systems."
	icon_state = "airtunnel01"

	light_color = LIGHT_COLOR_RED
	deny_type = DENY_TOO_OLD

/obj/machinery/computer/fluff/starmap
	name = "\improper Starmap"
	desc = "A console with a map of the local area. Just by looking at this thing you can tell it is years out of date and is too old to be used."
	icon_state = "comm_serv"

	light_color = LIGHT_COLOR_GREEN

/obj/machinery/computer/fluff/communications
	name = "communications console"
	icon_state = "comm_logs"

	light_color = LIGHT_COLOR_GREEN

/obj/machinery/computer/fluff/security
	name = "security records"
	icon_state = "security"

/obj/machinery/computer/fluff/medical
	name = "medical records"
	icon_state = "medcomp"

/obj/machinery/computer/fluff/factory
	name = "machinery control"
	icon_state = "engineeringcameras"

	light_color = LIGHT_COLOR_YELLOW

/obj/machinery/computer/fluff/terminal
	name = "computer"
	icon_state = "computer_generic"

/obj/machinery/computer/fluff/terminal/old
	icon_state = "old"
	deny_type = DENY_TOO_OLD

/obj/machinery/computer/fluff/terminal/compact
	icon_state = "pdaterm"

#undef DENY_ACCESS_DENIED
#undef DENY_TOO_OLD
