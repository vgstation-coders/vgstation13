//Process reagents being input into the tray.
/obj/machinery/portable_atmospherics/hydroponics/proc/process_reagents()
	if(reagents.total_volume <= 0 || mutationlevel >= 25)
		if(mutationlevel) //probably a way to not check this twice but meh
			mutate(min(mutationlevel, 25)) //Lazy 25u cap to prevent cheesing the whole thing
			mutationlevel = 0
			return
	else
		for(var/datum/reagent/A in reagents.reagent_list)
			A.on_plant_life(src)
			reagents.update_total()
		check_level_sanity()
		update_icon_after_process = 1

/obj/machinery/portable_atmospherics/hydroponics/proc/add_mutationlevel(var/amount)
	if (amount > 0)
		mutationlevel = min(mutation+amount,MUTATIONLEVEL_MAX)

/obj/machinery/portable_atmospherics/hydroponics/proc/get_mutationlevel()
	return mutationlevel

/obj/machinery/portable_atmospherics/hydroponics/proc/add_nutrient(var/amount, var/bloody = 0)
	if(seed)
		if(seed.hematophage != bloody)
			return
	else
		if(bloody)
			return
	if (amount > 0)
		nutrientlevel = min(nutrientlevel + amount, NUTRIENTLEVEL_MAX)
		weedlevel = min(weedlevel + amount, WEEDLEVEL_MAX)

/obj/machinery/portable_atmospherics/hydroponics/proc/get_nutrient()
	return nutrientlevel

/obj/machinery/portable_atmospherics/hydroponics/proc/add_waterlevel(var/amount)
	if(amount > 0)
		waterlevel = min(waterlevel + amount,WATERLEVEL_MAX)
		//Water dilutes toxin level
		toxinlevel = max(toxinlevel - amount * 4, 0)
	else
		//Remove water
		waterlevel = max(0, waterlevel + amount)

	if(toxins_affinity <= 5)
		health = min(health + 8, maxHealth)
	else
		if(T.seed && !T.dead)
			T.health = max(T.health - 8, 0)

/obj/machinery/portable_atmospherics/hydroponics/proc/get_waterlevel()
	return waterlevel

obj/machinery/portable_atmospherics/hydroponics/proc/add_toxinlevel(var/amount)
	if(amount > 0)
		toxinlevel = min(toxinlevel+amount,TOXINLEVEL_MAX)
	else
		toxinlevel = max(toxinlevel+amount,0)
	//Toxins dilutes water level.
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

