//Process reagents being input into the tray.
/obj/machinery/portable_atmospherics/hydroponics/proc/process_reagents()
	if(reagents.total_volume <= 0 || get_mutationlevel() >= 25)
		if(get_mutationlevel()) //probably a way to not check this twice but meh
			mutate(min(get_mutationlevel(), 25)) //Lazy 25u cap to prevent cheesing the whole thing
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
		//every increase in mutation, lose some health
		mutationlevel = round(min(mutationlevel + amount, MUTATIONLEVEL_MAX))
		add_planthealth(-2)
	else
		mutationlevel = round(max(0, mutationlevel + amount))

/obj/machinery/portable_atmospherics/hydroponics/proc/get_mutationlevel()
	return mutationlevel

/obj/machinery/portable_atmospherics/hydroponics/proc/add_nutrientlevel(var/amount, var/bloody = FALSE)
	if(seed)
		if(seed.hematophage != bloody)
			return
		else if(bloody)
			return
	if (amount > 0)
		nutrientlevel = round(min(nutrientlevel + amount, NUTRIENTLEVEL_MAX))
	else
		nutrientlevel = round(max(0, nutrientlevel + amount))
		if(nutrientlevel < 1)
			add_planthealth(-rand(1,3) * HYDRO_SPEED_MULTIPLIER)
			affect_growth(-1)

/obj/machinery/portable_atmospherics/hydroponics/proc/get_nutrientlevel()
	return nutrientlevel

/obj/machinery/portable_atmospherics/hydroponics/proc/add_waterlevel(var/amount)
	if(amount > 0)
		waterlevel = round(min(waterlevel + amount,WATERLEVEL_MAX))
		toxinlevel = round(max(toxinlevel - amount/2, 0))
	else
		//Remove or uptake water
		waterlevel = round(max(0, waterlevel + amount))
		if(waterlevel < 1)
			add_planthealth(-rand(1,3) * HYDRO_SPEED_MULTIPLIER)
			affect_growth(-1)

/obj/machinery/portable_atmospherics/hydroponics/proc/get_waterlevel()
	return waterlevel

/obj/machinery/portable_atmospherics/hydroponics/proc/add_pestlevel(var/amount, var/bloody = FALSE)
	if(amount > 0)
		pestlevel = round(min(pestlevel + amount,PESTLEVEL_MAX))
	else
		pestlevel = round(max(0, pestlevel + amount))
	
/obj/machinery/portable_atmospherics/hydroponics/proc/get_pestlevel()
	return pestlevel

/obj/machinery/portable_atmospherics/hydroponics/proc/add_weedlevel(var/amount)
	if(amount > 0)
		weedlevel = round(min(weedlevel + amount,WEEDLEVEL_MAX))
	else
		weedlevel = round(max(0, weedlevel + amount))
	
/obj/machinery/portable_atmospherics/hydroponics/proc/get_weedlevel()
	return weedlevel

/obj/machinery/portable_atmospherics/hydroponics/proc/add_toxinlevel(var/amount)
	if(amount > 0)
		toxinlevel = round(min(toxinlevel + amount,TOXINLEVEL_MAX))
		waterlevel = round(max(waterlevel - amount/2, 0))
	else
		//Remove or uptake toxins
		toxinlevel = round(max(0, toxinlevel + amount))
		if(seed && !dead)
			if(toxinlevel < 1 && !(seed.toxin_affinity < 5))
				add_planthealth(-rand(1,3) * HYDRO_SPEED_MULTIPLIER)
				affect_growth(-1)
	//to update tray color
	update_icon_after_process = 1

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
		yield_mod = max(0, yield_mod + amount)

/obj/machinery/portable_atmospherics/hydroponics/proc/get_yieldmod()
	return yield_mod

/obj/machinery/portable_atmospherics/hydroponics/proc/add_mutationmod(var/amount)
	if(!seed)
		return
	if(dead)
		return
	if(amount > 0)
		yield_mod = min(yield_mod + amount, MUTATIONMOD_MAX)
	else
		yield_mod = max(0, yield_mod + amount)

/obj/machinery/portable_atmospherics/hydroponics/proc/get_mutationmod()
	return yield_mod

//plant_health is only modified here. This avoids the need for sanity checks every tick
/obj/machinery/portable_atmospherics/hydroponics/proc/add_planthealth(var/amount)
	if(!seed)
		return
	if(dead)
		return
	if(amount > 0)
		plant_health = round(min(plant_health + amount, seed.endurance))
	else
		plant_health = round(max(0, plant_health + amount))
		if(get_planthealth() < 1)
			die()
/obj/machinery/portable_atmospherics/hydroponics/proc/get_planthealth()
	return plant_health