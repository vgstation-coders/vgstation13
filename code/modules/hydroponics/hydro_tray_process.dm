/obj/machinery/portable_atmospherics/hydroponics/process()
	//Do this even if we're not ready for a plant cycle.
	process_reagents()

	if (!is_soil && !is_plastic)
		if (seed)
			use_power = MACHINE_POWER_USE_ACTIVE
		else
			use_power = MACHINE_POWER_USE_IDLE

	// Update values every cycle rather than every process() tick.
	if(force_update)
		force_update = 0
	else if(world.time < (lastcycle + cycledelay))
		if(update_icon_after_process > 0 && !delayed_update_icon)
			update_icon()
		else
			update_visible_gas()
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
		if(!seed || get_weedlevel() >= seed.weed_tolerance + 20 || dead)
			weed_invasion()

	// If we're connected to a pipe lets make sure that gas is flowing through
	if (connected_port)
		var/datum/pipe_network/P = connected_port.return_network(src)
		if (P)
			P.update = 1

	var/turf/T = get_turf(src)
	var/datum/gas_mixture/environment

	// If our lid is closed, we exchange gas only with ourselves and any potential connected pipenet.
	if(closed_system)
		environment = air_contents
	else
		if(istype(T))
			environment = T.return_air()
		else
			environment = space_gas
		// If our lid is open and we're holding some gas, let's release any gas in the tray to the air
		// Incidentally since the tray might still be connected to a pipenet, this allows it to behave like a passive vent that only lets air flow out of the pipes.
		if (air_contents?.total_moles > 0.01)
			environment.merge(air_contents.remove(air_contents.total_moles))

	// If there is no seed data (and hence nothing planted),
	// or the plant is dead, process nothing further.
	if(!seed || dead)
		if(update_icon_after_process && !delayed_update_icon)
			update_icon() //Harvesting would fail to set alert icons properly.
		else
			update_visible_gas()
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
	if(!(has_slimes & SLIME_GREEN))
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

	// If enough time (in cycles, not ticks) has passed since the plant was harvested, we're ready to harvest again.
	if(!dead && seed.products && seed.products.len)
		if (age > seed.production)
			if ((age - lastproduce) > seed.production)
				if (!harvest)
					harvest = 1
					lastproduce = age
					if(seed.harvest_repeat == 2)
						autoharvest()
				else if (harvest < seed.maturation_max)
					harvest++
					lastproduce = age
					//might have to implement auto-harvest support for plants that auto-harvest at later stages at some point
		else
			if(harvest > 0) //It's a baby plant ready to harvest... must have aged backwards!
				harvest--
				seed.update_product(harvest)
				lastproduce = age

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

	if(update_icon_after_process && !delayed_update_icon)
		update_icon()
	else
		update_visible_gas()

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

//This lets us update gas visually more frequently without having to call the whole update_icon() each time
/obj/machinery/portable_atmospherics/hydroponics/proc/update_visible_gas()
	overlays -= visible_gas
	var/cargo_cart_offset = 0
	if (istype(locked_to,/obj/machinery/cart/cargo))
		cargo_cart_offset = CARGO_CART_OFFSET
	if (closed_system)
		if (!visible_gas)
			visible_gas = image(icon, src, "blank")
		visible_gas.overlays.len = 0
		for(var/g in XGM.overlay_limit)
			if(air_contents.molar_density(g) > XGM.overlay_limit[g])
				var/obj/effect/overlay/gas_overlay/GO = XGM.tile_overlay[g]
				var/image/I = image(icon ,src , GO.icon_state)
				I.layer = HYDROPONIC_TRAY_ATMOS_LAYER + cargo_cart_offset
				visible_gas.overlays += I
		overlays += visible_gas

/obj/machinery/portable_atmospherics/hydroponics/update_icon(var/forced = FALSE)
	//optimizations so we don't call update_icon() more than we need to
	delayed_update_icon = 0
	if (!forced)
		if (lid_toggling)
			if (lid_toggling == 2)
				lid_toggling = 1
			else
				return
		if (last_update_icon == world.time)
			//we've already updated the icon on this tick
			return
	last_update_icon = world.time

	update_icon_after_process = 0
	overlays.len = 0
	stop_particles()
	kill_moody_light_all()

	var/powered_and_working = !(stat & (BROKEN|NOPOWER|FORCEDISABLE))
	var/light_actually_on = light_on && powered_and_working
	var/cargo_cart_offset = 0
	if (istype(locked_to,/obj/machinery/cart/cargo))
		cargo_cart_offset = CARGO_CART_OFFSET

	update_name() //fuck it i'll make it not happen constantly later

	if (!is_soil)
		if (!is_plastic)
			if (light_actually_on)
				overlays += image(icon = icon, icon_state = "lightson")
			else
				overlays += image(icon = icon, icon_state = "lightsoff")
			if (anchored)
				icon_state = "hydrotray"
				pixel_y = 0
				if (connected_port)
					overlays += image(icon = icon, icon_state = "connector")
			else
				icon_state = "blank"
				pixel_y = 3
				var/image/I = image(icon = icon, icon_state = "hydrotray_mobile_static")//if I don't do that, unanchored trays don't appear on photos. Photography remains as cursed as ever.
				I.pixel_y = -3
				overlays += I
				var/image/J = image(icon = icon, icon_state = "hydrotray_mobile")
				J.pixel_y = -3
				overlays += J

	//how toxic is the water
	var/image/toxins_overlay = image(icon, src, "[icon_state]_toxin")
	toxins_overlay.alpha = get_full_toxinlevel() * 2.55
	overlays += toxins_overlay

	//how much water is in there
	if (!is_soil)
		var/water_lvl = 0
		var/full_waterlevel = get_full_waterlevel()
		if (full_waterlevel > 0)
			water_lvl = clamp(1 + round(get_full_waterlevel()/(WATERLEVEL_MAX/4)),1,4)
		var/image/water_overlay = image(icon, src, "waterlevel_[water_lvl]")
		overlays += water_overlay

	// Updates the plant overlay.
	var/plant_appearance = ""
	if(!isnull(seed))
		if(draw_warnings && powered_and_working && get_full_planthealth() <= (seed.endurance / 2))
			overlays += image('icons/obj/hydroponics/hydro_tools.dmi',"over_lowhealth3")
			update_moody_light_index("health", icon, "over_lowhealth3-moody")

		if(dead)
			plant_appearance = "dead"
		else
			if(harvest)
				if (harvest > 1)
					plant_appearance = "harvest-[harvest]"
				else
					plant_appearance = "harvest"
			else if(age < seed.maturation)
				var/t_growthstate = clamp(1+round((age * seed.growth_stages) / seed.maturation),1,seed.growth_stages)
				if (t_growthstate > growth_level)
					//this should give us a chance to witness stages we wouldn't otherwise see due to the plant's maturation var being inferior or equal to its growth_stages var.
					growth_level++
					if (t_growthstate > growth_level+1)
						growth_level++
				plant_appearance = "stage-[growth_level]"
				lastproduce = age
			else
				if (seed.growth_stages > growth_level)
					growth_level++
				plant_appearance = "stage-[growth_level]"
			if (seed.moody_lights)
				update_moody_light_index("plant", seed.plant_dmi, "[plant_appearance][(seed.constrained && closed_system) ? "-constrained" : ""]-moody")
			else if (seed.biolum)
				var/image/luminosity_gradient = image(icon, src, "moody_plant_mask")
				luminosity_gradient.blend_mode = BLEND_INSET_OVERLAY
				var/image/mask = image(seed.plant_dmi, src, "[plant_appearance][(seed.constrained && closed_system) ? "-constrained" : ""]")
				mask.appearance_flags = KEEP_TOGETHER
				mask.overlays += luminosity_gradient
				update_moody_light_index("plant", image_override = mask)
		if (seed.constrained && closed_system)
			plant_appearance += "-constrained"

		if (!is_soil && seed.visible_roots_in_hydro_tray)
			var/image/roots_image = image(seed.plant_dmi,src,"roots-[plant_appearance]")
			roots_image.layer = HYDROPONIC_TRAY_PLANT_LAYER + cargo_cart_offset
			overlays += roots_image
		var/image/plant_image = image(seed.plant_dmi,src,plant_appearance)
		plant_image.layer = HYDROPONIC_TRAY_PLANT_LAYER + cargo_cart_offset
		overlays += plant_image

		seed.apply_particles(src)

	//Draw the cover.
	if(closed_system)
		var/image/back_lid = image(icon,src,"lid_back")
		back_lid.layer = HYDROPONIC_TRAY_BACK_LID_LAYER + cargo_cart_offset
		overlays += back_lid

		//and the visible gases in there
		update_visible_gas()

		var/image/front_lid = image(icon,src,"lid_front")
		front_lid.layer = HYDROPONIC_TRAY_FRONT_LID_LAYER + cargo_cart_offset
		overlays += front_lid

	if (light_actually_on)
		if(closed_system)
			update_moody_light_index("lights", icon, "hydrotray-closed-moody")
		else
			update_moody_light_index("lights", icon, "hydrotray-open-moody")
		if (seed)
			var/image/luminosity_gradient = image(icon, src, "moody_plant_mask")
			luminosity_gradient.blend_mode = BLEND_INSET_OVERLAY
			var/image/mask = image(seed.plant_dmi, src, plant_appearance)
			mask.appearance_flags = KEEP_TOGETHER
			mask.overlays += luminosity_gradient
			update_moody_light_index("plant_lights", image_override = mask)

	//Updated the various alert icons.
	if(!draw_warnings || !powered_and_working)
		return
	if(get_full_nutrientlevel() <= NUTRIENTLEVEL_MAX / 5)
		overlays += image(icon = icon, icon_state = "over_lownutri3")
		update_moody_light_index("nutri", icon, "over_lownutri3-moody")
	if(get_full_weedlevel() >= WEEDLEVEL_MAX/2 || get_full_pestlevel() >= PESTLEVEL_MAX/2 || improper_heat || improper_light || improper_kpa || missing_gas)
		overlays += image(icon = icon, icon_state = "over_alert3")
		update_moody_light_index("alert", icon, "over_alert3-moody")
	if(get_full_waterlevel() <= WATERLEVEL_MAX/5 && get_full_toxinlevel() <= TOXINLEVEL_MAX/5)
		overlays += image(icon = icon, icon_state = "over_lowwater3")
		update_moody_light_index("water", icon, "over_lowwater3-moody")

	if(!seed)
		return
	if(seed.toxin_affinity < 5)
		if(get_full_waterlevel() <= WATERLEVEL_MAX/5)
			overlays += image(icon = icon, icon_state = "over_lowwater3")
			update_moody_light_index("water", icon, "over_lowwater3-moody")
	else if(seed.toxin_affinity <= 7)
		if(get_full_waterlevel() < WATERLEVEL_MAX/5 || get_full_toxinlevel() < TOXINLEVEL_MAX/5)
			overlays += image(icon = icon, icon_state = "over_lowwater3")
			update_moody_light_index("water", icon, "over_lowwater3-moody")
	else if(get_full_toxinlevel() < TOXINLEVEL_MAX/5)
		overlays += image(icon = icon, icon_state = "over_lowwater3")
		update_moody_light_index("water", icon, "over_lowwater3-moody")
	if(harvest)
		overlays += image(icon = icon, icon_state = "over_harvest3")
		update_moody_light_index("harvest", icon, "over_harvest3-moody")

/obj/machinery/portable_atmospherics/hydroponics/proc/check_light(var/turf/T)
	var/light_out_range = 0
	var/light_actually_on = light_on
	if (stat & (BROKEN|NOPOWER|FORCEDISABLE))
		light_actually_on = 0
	if(light_actually_on)
		light_out_range += internal_light_range
	if(seed && !dead && seed.biolum)
		light_out_range += get_biolum()
		if(seed.biolum_colour)
			light_color = seed.biolum_colour
		else
			light_color = null
	set_light(light_out_range)

	if (seed)
		var/light_available = 5
		if(T?.dynamic_lighting)
			light_available = T.get_lumcount() * 10
		if(light_actually_on)
			light_available += 3//a little boost so dim lit hydroponic rooms relying on tray lights are viable

		if(!seed.biolum && abs(light_available - seed.ideal_light) > seed.light_tolerance)
			improper_light = 1
		else
			improper_light = 0

/obj/machinery/portable_atmospherics/hydroponics/proc/check_gasses(var/datum/gas_mixture/environment)
	// Handle gas consumption.
	// If it has the absorbing trait, takes no damage from lack of gas
	if(seed.consume_gasses && seed.consume_gasses.len && environment)
		missing_gas = 0
		for(var/gas in seed.consume_gasses)
			if(environment[gas] < seed.consume_gasses[gas])
				if(!seed.gas_absorb)
					missing_gas++
				continue
			if (seed.gas_absorb && seed.potency < 200)
				seed = seed.diverge(1)
				seed.potency += 0.2
			environment.adjust_gas(gas, -(seed.consume_gasses[gas]), FALSE)
		environment.update_values()

	// Handle gas production.
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
