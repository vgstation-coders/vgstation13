
/obj/machinery/artifact_scanpad
	name = "anomaly scanner pad"
	desc = "Place things here for scanning."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "xenoarch_scanner"
	anchored = TRUE
	density = FALSE
	plane = ABOVE_OBJ_PLANE
	var/obj/machinery/artifact_analyser/analyser_console = null
	var/obj/machinery/artifact_harvester/harvester_console = null

/obj/machinery/artifact_scanpad/New()
	..()
	update_icon()

/obj/machinery/artifact_scanpad/update_icon()
	if (analyser_console)
		icon_state = "[initial(icon_state)][analyser_console ? analyser_console.scan_in_progress : 0]"
	else if (harvester_console)
		icon_state = "[initial(icon_state)][harvester_console ? harvester_console.harvesting : 0]"
