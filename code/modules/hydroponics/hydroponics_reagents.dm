/*
 * Oh god
 * What the fuck am I doing
 * I am not good with compueter
 */


/obj/machinery/portable_atmospherics/hydroponics/proc/adjust_nutrient(var/amount, var/bloody = 0)
	if(seed)
		if(seed.hematophage != bloody)
			return
	else
		if(bloody)
			return
	nutrilevel += amount

/obj/machinery/portable_atmospherics/hydroponics/proc/adjust_water(var/amount)
	waterlevel += amount
	// Water dilutes toxin level.
	if(amount > 0)
		toxins -= amount*4

//Process reagents being input into the tray.
/obj/machinery/portable_atmospherics/hydroponics/proc/process_reagents()
	if(reagents.total_volume <= 0 || mutation_level >= 25)
		if(mutation_level) //probably a way to not check this twice but meh
			mutate(min(mutation_level, 25)) //Lazy 25u cap to prevent cheesing the whole thing
			mutation_level = 0
			return
	else
		for(var/datum/reagent/A in reagents.reagent_list)
			A.on_plant_life(src)
			reagents.update_total()

		check_level_sanity()
		update_icon_after_process = 1
