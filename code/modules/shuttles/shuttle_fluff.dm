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
	deny_type = 1

/obj/machinery/computer/fluff/starmap
	name = "\improper Starmap"
	desc = "A console with a map of the local area. Just by looking at this thing you can tell it is years out of date and is too old to be used."
	icon_state = "comm_serv"

	light_color = LIGHT_COLOR_GREEN