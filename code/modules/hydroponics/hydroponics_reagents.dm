/obj/machinery/portable_atmospherics/hydroponics/proc/add_mutationlevel(var/amount)
	mutation_level = min(mutation+amount,MUTATIONLEVEL_MAX)

/obj/machinery/portable_atmospherics/hydroponics/proc/get_mutationlevel()
	return mutation_level

/obj/machinery/portable_atmospherics/hydroponics/proc/add_nutrient(var/amount, var/bloody = 0)
	if(seed)
		if(seed.hematophage != bloody)
			return
	else
		if(bloody)
			return
	nutrilevel += amount
	weedlevel += amount

/obj/machinery/portable_atmospherics/hydroponics/proc/get_nutrient()
	return nutrilevel

/obj/machinery/portable_atmospherics/hydroponics/proc/add_waterlevel(var/amount)
	water += amount
	// Water dilutes toxin level.
	toxinlevel = max(toxinlevel-amount*4,0)
	if(toxins_affinity <= 5)
		health = min(health + 8, maxHealth)
	else
		if(T.seed && !T.dead)
			T.health = max(T.health - 8, 0)

/obj/machinery/portable_atmospherics/hydroponics/proc/get_waterlevel()
	return waterlevel

obj/machinery/portable_atmospherics/hydroponics/proc/add_toxins(var/amount)
	toxinlevel = max(toxinlevel+amount,0)
	// Toxins dilutes water level.
	waterlevel = max(waterlevel-amount*4,0)
	weedlevel -= round(amount/4,1)

	if(toxins_affinity > 5)
		health = min(health + 8, maxHealth)
	else
		if(T.seed && !T.dead)
			T.health = max(T.health - 8, 0)



/obj/machinery/portable_atmospherics/hydroponics/proc/add_nutrient(var/amount, var/bloody = 0)
	if(seed)
		if(seed.hematophage != bloody)
			return
	else
		if(bloody)
			return
	nutrilevel += amount
	weedlevel += amount

/obj/machinery/portable_atmospherics/hydroponics/proc/get_nutrient()
	return nutrilevel

//Process reagents being input into the tray.
/obj/machinery/portable_atmospherics/hydroponics/proc/process_reagents()
	handle_toxins()
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

