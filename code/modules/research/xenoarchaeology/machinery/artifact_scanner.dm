
/obj/machinery/artifact_scanpad
	name = "anomaly scanner pad"
	desc = "Build next to an anomaly analyzer or exotic particle harvester."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "xenoarch_scanner0"
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
	icon_state = "xenoarch_scanner0"
	if(stat & (NOPOWER|BROKEN))
		return

	if (analyser_console?.scan_in_progress)
		icon_state = "xenoarch_scanner1"
	if (harvester_console?.harvesting > 0)
		icon_state = "xenoarch_scanner2"
