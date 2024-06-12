/obj/machinery/anomaly/triangul
	name = "placeholder machine name"
	desc = "Placeholder description."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "triangul"

/obj/machinery/anomaly/triangul/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/anom/triangul,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module
	)

	RefreshParts()
	
/obj/machinery/anomaly/triangul/update_icon()

/obj/machinery/anomaly/triangul/ScanResults()
	var/results = "The scan was inconclusive. Check sample integrity."

	var/datum/geosample/scanned_sample

	for(var/datum/reagent/A in held_container.reagents.reagent_list)
		var/datum/reagent/R = A
		if(istype(R, /datum/reagent/analysis_sample))
			scanned_sample = R.data
			break

	if(scanned_sample)
		if(scanned_sample.artifact_x > 0)
			var/artifact_x = scanned_sample.artifact_x
			var/artifact_y = scanned_sample.artifact_y
			artifact_x += (4 * rand() - 2)
			artifact_y += (4 * rand() - 2)
			results = "Analysis on anomalous energy absorption indicates source located inside a radius of 2 meters centered around <b>X: [artifact_x], Y: [artifact_y]</b>."
		else
			results = "Energy dispersion detected throughout sample consistent with background readings.<br>"

	return results
