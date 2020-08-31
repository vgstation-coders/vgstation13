
/obj/machinery/artifact_scanpad
	name = "anomaly scanner pad"
	desc = "Build next to an anomaly analyser or exotic particle harvester."
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

/obj/machinery/artifact_scanpad/Destroy()
	analyser_console = null
	harvester_console = null
	..()

/obj/machinery/artifact_scanpad/power_change()
	..()
	update_icon()

/obj/machinery/artifact_scanpad/update_icon()
	if(stat & (NOPOWER|BROKEN))
		icon_state = "xenoarch_scanner"
		return

	if (analyser_console)
		icon_state = "[initial(icon_state)][analyser_console ? analyser_console.scan_in_progress : 0]"
	else if (harvester_console)
		icon_state = "[initial(icon_state)][harvester_console ? ((harvester_console.harvesting > 0)*2) : 0]"
