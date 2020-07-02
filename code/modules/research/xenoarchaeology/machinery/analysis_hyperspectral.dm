/obj/machinery/anomaly/hyperspectral
	name = "hyperspectral imager"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "hyperspectral"
	light_power = 0.75
	light_color = LIGHT_COLOR_GREEN

/obj/machinery/anomaly/hyperspectral/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/anom/hyper,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module
	)

	RefreshParts()

/obj/machinery/anomaly/hyperspectral/update_icon()
	overlays.Cut()
	if (stat & (NOPOWER | BROKEN))
		return

	overlays += "hyperspectral_on"

	if (scan_process)
		overlays += "hyperspectral_active"

	if (panel_open)
		overlays += "hyperspectral_panel"

/obj/machinery/anomaly/hyperspectral/start(var/mob/user)
	..()
	set_light(2)

/obj/machinery/anomaly/hyperspectral/stop()
	..()
	set_light(0)

/obj/machinery/anomaly/hyperspectral/ScanResults()
	var/results = "The scan was inconclusive. Check sample integrity."

	var/datum/geosample/scanned_sample

	for(var/datum/reagent/A in held_container.reagents.reagent_list)
		var/datum/reagent/R = A
		if(istype(R, /datum/reagent/analysis_sample))
			scanned_sample = R.data
			break

	if(scanned_sample)
		if(scanned_sample.artifact_id)
			results = {"Detected energy signatures 95% consistent with standard background readings.<br>
			Anomalous exotic energy signature isolated: <font color='red'><b>[scanned_sample.artifact_id].</b></font>"}
		else
			results = "Detected energy signatures 100% consistent with standard background readings."

	return results
