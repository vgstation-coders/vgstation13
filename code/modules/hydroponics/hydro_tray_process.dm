/obj/machinery/portable_atmospherics/hydroponics/process()
	//Do this even if we're not ready for a plant cycle.
	process_reagents()

	// Update values every cycle rather than every process() tick.
	if(force_update)
		force_update = 0
	else if(world.time < (lastcycle + cycledelay))
		if(update_icon_after_process)
			update_icon()
		return
	lastcycle = world.time

	if (pollination <= 0)
		bees = 0
	else
		pollination--
		bees = 1

	// Weeds like water and nutrients, there's a chance the weed population will increase.
	// This process is up here because it still happens even when the tray is empty.
	if(get_waterlevel() > WATERLEVEL_MAX/5 && get_nutrientlevel() > NUTRIENTLEVEL_MAX/5)
		if(isnull(seed) && prob(5))
			add_weedlevel(HYDRO_SPEED_MULTIPLIER * weed_coefficient)
			update_icon_after_process = 1
		else if(prob(2))
			add_weedlevel(HYDRO_SPEED_MULTIPLIER * weed_coefficient)
			update_icon_after_process = 1
	// There's a chance for a weed explosion to happen if the weeds take over.
	// Plants that are themselves weeds (weed_tolerance > 80) are unaffected.
	if (get_weedlevel() >= WEEDLEVEL_MAX && prob(10))
		if(!seed || get_weedlevel() >= seed.weed_tolerance + 20)
			weed_invasion()

	// If there is no seed data (and hence nothing planted),
	// or the plant is dead, process nothing further.
	if(!seed || dead)
		if(update_icon_after_process)
			update_icon() //Harvesting would fail to set alert icons properly.
		return

	// On each tick, there's a chance the pest population will increase.
	// This process is under the !seed check because it only happens when a live plant is in the tray.
	if(prob(1))
		add_pestlevel(HYDRO_SPEED_MULTIPLIER * weed_coefficient / 2)

	//Bees will attempt to aid the plant's longevity and make it fruit faster.
	if(bees && age >= seed.maturation && prob(50))
		if(harvest)
			skip_aging++
		else
			lastproduce--

	// Advance plant age.
	if(!has_slime)
		if(skip_aging)
			skip_aging--
		else
			if(prob(80))
				age += 1 * HYDRO_SPEED_MULTIPLIER
				update_icon_after_process = 1

	//Highly mutable plants have a chance of mutating every tick.
	if(seed.immutable == -1)
		if(prob(5))
			mutate()

	//Consume, 25% of the time
	if(prob(25))
		if(seed.nutrient_consumption > 0)
			add_nutrientlevel(-seed.nutrient_consumption * HYDRO_SPEED_MULTIPLIER)
		if(seed.fluid_consumption > 0)
			if(seed.toxin_affinity < 5)
				add_waterlevel(-seed.fluid_consumption * HYDRO_SPEED_MULTIPLIER)
			else if(seed.toxin_affinity <= 7)
				add_waterlevel(-seed.fluid_consumption * HYDRO_SPEED_MULTIPLIER/2)
				add_toxinlevel(-seed.fluid_consumption * HYDRO_SPEED_MULTIPLIER/2)
			else
				add_toxinlevel(-seed.fluid_consumption * HYDRO_SPEED_MULTIPLIER)

	// If the plant's age is negative, let's revert it into a seed packet, for funsies
	if(age < 0)
		var/obj/item/seeds/seeds = seed.spawn_seed_packet(get_turf(src))
		if(arcanetampered)
			seeds.arcanetampered = arcanetampered
		remove_plant()
		force_update = 1
		process()

	if(harvest && seed.harvest_repeat == 2)
		autoharvest()

	// If enough time (in cycles, not ticks) has passed since the plant was harvested, we're ready to harvest again.
	if(!dead && seed.products && seed.products.len)
		if (age > seed.production)
			if ((age - lastproduce) > seed.production && !harvest)
				harvest = 1
				lastproduce = age
		else
			if(harvest) //It's a baby plant ready to harvest... must have aged backwards!
				harvest = 0
				lastproduce = age

	var/turf/T = get_turf(src)
	var/datum/gas_mixture/environment
	// If we're closed, take from our internal sources.
	if(closed_system && (connected_port || holding))
		environment = air_contents
	else if(!environment && istype(T))
		environment = T.return_air()
	else
		environment = space_gas

	process_health()
	check_light(T)
	check_gasses(environment)
	check_kpa(environment)
	check_temperature(environment)

	// If we're a spreading vine, let's go ahead and try to spread our love.
	if(try_spread())
		if(!(locate(/obj/effect/plantsegment) in T))
			new /obj/effect/plantsegment(T, seed)
			switch(seed.spread)
				if(1)
					msg_admin_attack("limited growth creeper vines ([seed.display_name]) have spread out of a tray. <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a>, last touched by [key_name_last_user]. Seed id: [seed.uid]. ([bad_stuff()])")
				if(2)
					msg_admin_attack("space vines ([seed.display_name]) have spread out of a tray. <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a>, last touched by [key_name_last_user]. Seed id: [seed.uid]. ([bad_stuff()])")

	if(update_icon_after_process)
		update_icon()

/obj/machinery/portable_atmospherics/hydroponics/proc/affect_growth(var/amount)
	if(!seed)
		return
	if(amount > 0)
		if(age < seed.maturation)
			age += amount
		else if(!harvest && seed.yield != -1)
			lastproduce -= amount
	else
		if(age < seed.maturation)
			skip_aging++
		else if(!harvest && seed.yield != -1)
			lastproduce += amount

/obj/machinery/portable_atmospherics/hydroponics/proc/update_name()
	if(seed)
		//name = "[initial(name)] ([seed.seed_name])"
		name = "[seed.display_name]"
	else
		name = initial(name)

	if(labeled)
		name += " ([labeled])"

/obj/machinery/portable_atmospherics/hydroponics/update_icon()
	update_icon_after_process = 0
	overlays.len = 0

	update_name() //fuck it i'll make it not happen constantly later

	// Updates the plant overlay.
	if(get_toxinlevel() > get_waterlevel() || get_toxinlevel() > TOXINLEVEL_MAX/2)
		overlays += image(icon = icon, icon_state = "hydrotray_toxin")
	if(!isnull(seed))
		if(draw_warnings && get_planthealth() <= (seed.endurance / 2))
			overlays += image('icons/obj/hydroponics/hydro_tools.dmi',"over_lowhealth3")
		if(dead)
			overlays += image(seed.plant_dmi,"dead")
		else if(harvest)
			overlays += image(seed.plant_dmi,"harvest")
		else if(age < seed.maturation)
			var/t_growthstate = max(1,round((age * seed.growth_stages) / seed.maturation))
			overlays += image(seed.plant_dmi,"stage-[t_growthstate]")
			lastproduce = age
		else
			overlays += image(seed.plant_dmi,"stage-[seed.growth_stages]")

	//Draw the cover.
	if(closed_system)
		overlays += image(icon = icon, icon_state = "hydrocover")

	//Updated the various alert icons.
	if(!draw_warnings)
		return
	if(get_nutrientlevel() <= NUTRIENTLEVEL_MAX / 5)
		overlays += image(icon = icon, icon_state = "over_lownutri3")
	if(get_weedlevel() >= WEEDLEVEL_MAX/2 || get_pestlevel() >= PESTLEVEL_MAX/2 || improper_heat || improper_light || improper_kpa || missing_gas)
		overlays += image(icon = icon, icon_state = "over_alert3")
	if(get_waterlevel() <= WATERLEVEL_MAX/5 && get_toxinlevel() <= TOXINLEVEL_MAX/5)
		overlays += image(icon = icon, icon_state = "over_lowwater3")

	if(!seed)
		return
	if(seed.toxin_affinity < 5)
		if(get_waterlevel() <= WATERLEVEL_MAX/5)
			overlays += image(icon = icon, icon_state = "over_lowwater3")
	else if(seed.toxin_affinity <= 7)
		if(get_waterlevel() < WATERLEVEL_MAX/5 || get_toxinlevel() < TOXINLEVEL_MAX/5)
			overlays += image(icon = icon, icon_state = "over_lowwater3")
	else if(get_toxinlevel() < TOXINLEVEL_MAX/5)
		overlays += image(icon = icon, icon_state = "over_lowwater3")
	if(harvest)
		overlays += image(icon = icon, icon_state = "over_harvest3")

/obj/machinery/portable_atmospherics/hydroponics/proc/check_light(var/turf/T)
	var/light_out = 0
	if(light_on)
		light_out += internal_light
	if(seed&&seed.biolum)
		light_out += (1 + Ceiling(seed.potency/10))
		if(seed.biolum_colour)
			light_color = seed.biolum_colour
		else
			light_color = null
	set_light(light_out)

	var/light_available = 5
	if(T?.dynamic_lighting)
		light_available = T.get_lumcount() * 10

	if(!seed.biolum && abs(light_available - seed.ideal_light) > seed.light_tolerance)
		improper_light = 1
	else
		improper_light = 0

/obj/machinery/portable_atmospherics/hydroponics/proc/check_gasses(var/datum/gas_mixture/environment)
	// Handle gas consumption.
	if(seed.consume_gasses && seed.consume_gasses.len && environment)
		missing_gas = 0
		for(var/gas in seed.consume_gasses)
			if(environment[gas] < seed.consume_gasses[gas])
				missing_gas++
				continue
			environment.adjust_gas(gas, -(seed.consume_gasses[gas]), FALSE)
		environment.update_values()

	// Handle gas production.
	// If we're attached to a pipenet, then we should let the pipenet know we might have modified some gasses
	//if (closed_system && connected_port)
	//'	update_connected_network()
	if(seed.exude_gasses && seed.exude_gasses.len)
		for(var/gas in seed.exude_gasses)
			environment.adjust_gas(gas, max(1,round((seed.exude_gasses[gas]*round(seed.potency))/seed.exude_gasses.len)))

/obj/machinery/portable_atmospherics/hydroponics/proc/check_kpa(var/datum/gas_mixture/environment)
	var/pressure = environment.return_pressure()
	if(pressure < seed.lowkpa_tolerance || pressure > seed.highkpa_tolerance)
		improper_kpa = 1
	else
		improper_kpa = 0

/obj/machinery/portable_atmospherics/hydroponics/proc/check_temperature(var/datum/gas_mixture/environment)
	if(abs(environment.temperature - seed.ideal_heat) > seed.heat_tolerance)
		improper_heat = 1
		if(seed.alter_temp)
			//This is totally arbitrary. It just serves to approximate the behavior from when this modified temperature rather than thermal energy.
			var/energy_cap = seed.potency * 60 * MOLES_CELLSTANDARD
			var/energy_change = clamp(environment.get_thermal_energy_change(seed.ideal_heat), -energy_cap, energy_cap)
			environment.add_thermal_energy(energy_change)
	else
		improper_heat = 0

/obj/machinery/portable_atmospherics/hydroponics/proc/process_health()
	var/sum_health = 0
	var/healthmod = rand(1,3) * HYDRO_SPEED_MULTIPLIER

	// Make sure the plant is not starving or thirsty. Adequate water and nutrients will
	// cause a plant to become healthier. Lack of sustenance will stunt the plant's growth.
	if(prob(35))
		if(get_nutrientlevel() > NUTRIENTLEVEL_MAX / 5)
			sum_health += healthmod
		else
			update_icon_after_process = 1
		if(seed.toxin_affinity < 5 && get_waterlevel() > WATERLEVEL_MAX / 5)
			sum_health += healthmod
		//lower minimum thresholds for moderate toxin affinity because it uptakes both toxin and water
		else if(seed.toxin_affinity >= 5 \
		&& seed.toxin_affinity <= 7 \
		&& get_waterlevel() > WATERLEVEL_MAX/10 \
		&& get_toxinlevel() > TOXINLEVEL_MAX/10)
			sum_health += healthmod
		else if(seed.toxin_affinity > 7 && get_toxinlevel() > TOXINLEVEL_MAX/5)
			sum_health += healthmod
		else
			update_icon_after_process = 1

	if(seed.toxin_affinity < 5 && get_toxinlevel() > TOXINLEVEL_MAX/5)
		sum_health -= healthmod*(5-seed.toxin_affinity)

	if(missing_gas)
		sum_health -= missing_gas * healthmod
		update_icon_after_process = 1
	if(improper_heat)
		sum_health -= healthmod
		update_icon_after_process = 1
	if(improper_light)
		sum_health -= healthmod
		if(prob(35))
			affect_growth(-1)
		update_icon_after_process = 1
	if(improper_kpa)
		sum_health -= healthmod
		update_icon_after_process = 1

	// Check for pests and weeds.
	// Some carnivorous plants happily eat pests.
	if(get_pestlevel() > 0)
		if(seed.voracious)
			sum_health += HYDRO_SPEED_MULTIPLIER
			add_pestlevel(-HYDRO_SPEED_MULTIPLIER * weed_coefficient)
		else if (get_pestlevel() > seed.pest_tolerance)
			sum_health -= HYDRO_SPEED_MULTIPLIER
			update_icon_after_process = 1

	// Some plants thrive and live off of weeds.
	if(get_weedlevel() > 0)
		if(seed.voracious)
			sum_health += HYDRO_SPEED_MULTIPLIER
			add_weedlevel(-HYDRO_SPEED_MULTIPLIER * weed_coefficient)
		else if (get_weedlevel() > seed.weed_tolerance)
			sum_health -= HYDRO_SPEED_MULTIPLIER
			update_icon_after_process = 1

	// Handle life and death.
	// If the plant is too old, it loses health fast.
	if(age > seed.lifespan)
		sum_health -= (rand(3,5) * HYDRO_SPEED_MULTIPLIER)
		update_icon_after_process = 1

	add_planthealth(sum_health)
