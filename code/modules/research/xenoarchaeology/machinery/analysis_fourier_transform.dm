
// This machine tells the distance to a nearby artifact, if there is one

/obj/machinery/anomaly/fourier_transform
	name = "\improper Fourier transform spectroscope"
	desc = "A specialised, complex analysis machine. Can measure an approximate distance from the closest source of anomalous exotic energies."
	var/distance = 0

/obj/machinery/anomaly/fourier_transform/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/anom,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module
	)

	RefreshParts()

/obj/machinery/anomaly/fourier_transform/ScanResults()
	var/results = "The scan was inconclusive. Check sample integrity."

	for(var/datum/reagent/A in held_container.reagents.reagent_list)
		var/datum/reagent/R = A
		if(istype(R, /datum/reagent/analysis_sample))
			scanned_sample = R.data
			break

	if(scanned_sample)
		distance = scanned_sample.artifact_distance
		if(distance > 0)
			distance += (2 * rand() - 1) * distance * 0.05
			results = "Fourier transform analysis on anomalous energy absorption indicates source located inside emission radius (95% accuracy): <b>[distance]</b>."
		else
			results = "Energy dispersion detected throughout sample consistent with background readings.<br>"

	return results

/obj/machinery/anomaly/fourier_transform/draw_on_map(x,y)
	if(map_icon && scanned_sample)
		if(round(abs(x_offset-x)**2 + abs(y_offset-y)**2,distance*3) != round(distance**2,distance*3))
			map_icon.DrawBox("#000", x, y)
		else
			map_icon.DrawBox("#f00", x, y)
