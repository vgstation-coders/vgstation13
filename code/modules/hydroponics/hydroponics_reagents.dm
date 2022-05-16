/obj/machinery/portable_atmospherics/hydroponics/proc/check_level_sanity()
	mutation_level = clamp(mutation_level, 0, 100)
	nutrilevel =     clamp(nutrilevel, 0, 10)
	waterlevel =     clamp(waterlevel, 0, 100)
	pestlevel =      clamp(pestlevel, 0, 10)
	weedlevel =      clamp(weedlevel, 0, 10)
	toxins =         clamp(toxins, 0, 100)
	yield_mod = 	 clamp(yield_mod, 0, 2)
	mutation_mod = 	 clamp(mutation_mod, 0, 3)

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

/obj/machinery/portable_atmospherics/hydroponics/proc/add_mutationlevel(var/amount)
	if(!seed)
		return
	if(dead)
		return
	if (amount > 0)
		mutationlevel = min(mutationlevel + amount, MUTATIONLEVEL_MAX)
		add_planthealth(-2)
	else
		mutationlevel = min(0, mutatiolevel + amount)

/obj/machinery/portable_atmospherics/hydroponics/proc/get_mutationlevel()
	return mutationlevel

/obj/machinery/portable_atmospherics/hydroponics/proc/add_nutrientlevel(var/amount, var/bloody = FALSE)
	if(hematophage && !bloody)
		return
	if (amount > 0)
		nutrientlevel = min(nutrientlevel + amount, NUTRIENTLEVEL_MAX)
		weedlevel = min(weedlevel + amount, WEEDLEVEL_MAX)
	else
		nutrientlevel = min(0, nutrientlevel + amount)
		weedlevel = min(0, weedlevel + amount)

/obj/machinery/portable_atmospherics/hydroponics/proc/get_nutrientlevel()
	return nutrientlevel

/obj/machinery/portable_atmospherics/hydroponics/proc/add_waterlevel(var/amount)
	if(amount > 0)
		waterlevel = min(waterlevel + amount,WATERLEVEL_MAX)
		toxinlevel = max(toxinlevel - amount/2, 0)
	else
		//Remove or uptake water
		waterlevel = max(0, waterlevel + amount)
		if(waterlevel == 0)
			add_planthealth(rand(1,3) * HYDRO_SPEED_MULTIPLIER)
			affect_growth(-1)

/obj/machinery/portable_atmospherics/hydroponics/proc/get_waterlevel()
	return waterlevel

/obj/machinery/portable_atmospherics/hydroponics/proc/add_pestlevel(var/amount, var/bloody = FALSE)
	if(hematophage && !bloody)
		return
	
/obj/machinery/portable_atmospherics/hydroponics/proc/get_pestlevel()
	return pestlevel

/obj/machinery/portable_atmospherics/hydroponics/proc/add_weedlevel(var/amount)
	if(amount > 0)
		weedlevel = min(weedlevel + amount,WEEDLEVEL_MAX)
	else
		weedlevel = max(0, weedlevel + amount)
	
/obj/machinery/portable_atmospherics/hydroponics/proc/get_weedlevel()
	return weedlevel

/obj/machinery/portable_atmospherics/hydroponics/proc/add_toxinlevel(var/amount)
	if(amount > 0)
		toxinlevel = min(toxinlevel + amount,TOXINLEVEL_MAX)
		waterlevel = max(waterlevel - amount/2, 0)
	else
		//Remove or uptake toxins
		toxinlevel = max(toxinlevel + amount,0)
		if(toxinlevel == 0 && !(toxin_affinity < 5))
			add_planthealth(rand(1,3) * HYDRO_SPEED_MULTIPLIER)
			affect_growth(-1)

/obj/machinery/portable_atmospherics/hydroponics/proc/get_toxinlevel()
	return toxinlevel

/obj/machinery/portable_atmospherics/hydroponics/proc/add_yieldmod(var/amount)
	if(!seed)
		return
	if(dead)
		return
	if(amount > 0)
		yield_mod = min(yield_mod + amount,YIELDMOD_MAX)
	else
		//Remove or uptake toxins
		yield_mod = max(yield_mod + amount,0)

/obj/machinery/portable_atmospherics/hydroponics/proc/get_yieldmod()
	return yield_mod

//plant_health is only modified here. This avoids the need for sanity checks every tick
/obj/machinery/portable_atmospherics/hydroponics/proc/add_planthealth(var/amount)
	if(!seed)
		return
	if(dead)
		return
	if(amount > 0)
		plant_health = min(plant_health + amount, seed.endurance)
	else
		plant_health = max(plant_health + amount, 0)
		if(get_planthealth() < 1)
			die()
/obj/machinery/portable_atmospherics/hydroponics/proc/get_planthealth()
	return plant_health