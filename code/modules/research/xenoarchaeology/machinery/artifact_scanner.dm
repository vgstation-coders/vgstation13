
/obj/machinery/artifact_scanpad
	name = "anomaly scanner pad"
	desc = "Place things here for scanning."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "xenoarch_scanner"
	anchored = TRUE
	density = FALSE
	var/obj/machinery/artifact_analyser/owner_console = null

/obj/machinery/artifact_scanpad/New()
	..()
	update_icon()

/obj/machinery/artifact_scanpad/update_icon()
	if(owner_console)
		icon_state = initial(icon_state)+owner_console.scan_in_progress
		return
	icon_state = "[initial(icon_state)]0"