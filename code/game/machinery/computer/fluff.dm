//Unusable computers to be used as decorations for mapping

#define DENY_ACCESS_DENIED	0
#define DENY_TOO_OLD		1

/obj/machinery/computer/fluff
	var/deny_type = DENY_ACCESS_DENIED

/obj/machinery/computer/fluff/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/fluff/attack_hand(mob/user)
	switch(deny_type)
		if(DENY_ACCESS_DENIED)
			to_chat(user, "<span class='warning'>Access denied.</span>")

		if(DENY_TOO_OLD)
			if(issilicon(user))
				to_chat(user, "<span class='warning'>Unable to establish connection: unknown interface type.</span>")
			else
				to_chat(user, "<span class='warning'>The buttons don't seem to do anything.</span>")

/obj/machinery/computer/fluff/emag(mob/user)
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
