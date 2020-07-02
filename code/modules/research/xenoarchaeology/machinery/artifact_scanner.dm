
/obj/machinery/artifact_scanpad
	name = "anomaly scanner pad"
	desc = "Place things here for scanning."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "xenoarch_scanner"
	anchored = TRUE
	density = FALSE
	plane = ABOVE_OBJ_PLANE
	var/obj/machinery/artifact_analyser/owner_console = null

/obj/machinery/artifact_scanpad/New()
	..()
	update_icon()

/obj/machinery/artifact_scanpad/update_icon()
	icon_state = "[initial(icon_state)][owner_console ? owner_console.scan_in_progress : 0]"
