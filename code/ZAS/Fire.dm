///////////////////////////////////////////////
// THERMAL MATERIAL DATUMS
///////////////////////////////////////////////
/datum/thermal_material
	var/autoignition_temperature
	var/heating_value
	var/molecular_weight
	var/fuel_ox_ratio
	var/flame_temp

/datum/thermal_material/wood
	autoignition_temperature = AUTOIGNITION_WOOD
	heating_value = HHV_WOOD
	molecular_weight = MOLECULAR_WEIGHT_WOOD
	fuel_ox_ratio = FUEL_OX_RATIO_WOOD
	flame_temp = FLAME_TEMPERATURE_WOOD
/datum/thermal_material/plastic
	autoignition_temperature = AUTOIGNITION_PLASTIC
	heating_value = HHV_PLASTIC
	molecular_weight = MOLECULAR_WEIGHT_PLASTIC
	fuel_ox_ratio = FUEL_OX_RATIO_PLASTIC
	flame_temp = FLAME_TEMPERATURE_PLASTIC
/datum/thermal_material/fabric
	autoignition_temperature = AUTOIGNITION_FABRIC
	heating_value = HHV_FABRIC
	molecular_weight = MOLECULAR_WEIGHT_FABRIC
	fuel_ox_ratio = FUEL_OX_RATIO_FABRIC
	flame_temp = FLAME_TEMPERATURE_FABRIC
/datum/thermal_material/wax
	autoignition_temperature = AUTOIGNITION_WAX
	heating_value = HHV_WAX
	molecular_weight = MOLECULAR_WEIGHT_WAX
	fuel_ox_ratio = FUEL_OX_RATIO_WAX
	flame_temp = FLAME_TEMPERATURE_WAX
/datum/thermal_material/biological
	autoignition_temperature = AUTOIGNITION_BIOLOGICAL
	heating_value = HHV_BIOLOGICAL
	molecular_weight = MOLECULAR_WEIGHT_BIOLOGICAL
	fuel_ox_ratio = FUEL_OX_RATIO_BIOLOGICAL
	flame_temp = FLAME_TEMPERATURE_BIOLOGICAL


///////////////////////////////////////////////
// ATOM COMBUSTION
///////////////////////////////////////////////
/*
1. Atom is heated beyond its autoignition temperature.
2. Burnable subsystem (burnable.dm) ignites (proc/ignite()) the atom and spawns a fire effect if one isn't already present.
3. fire/process() calls burnSolidFuel() for any atom on its tile that is also on_fire.
4. burnSolidFuel() adds energy into var/datum/gas_mixture/flow, which is then added to proc/zburn's reaction energy.
5. burnSolidFuel() will remove the burning atom's mass with each iteration.
6. Once the burning atom's mass is equal to or less than 0, it will turn to ash.
Note: this process will be halted if the oxygen concentration or pressure drops too low.
*/


/atom
	var/on_fire = 0
	var/flammable = FALSE
	var/autoignition_temperature //inherited from thermal_material unless defined otherwise
	var/thermal_mass = 0 //VERY loose estimate of mass in kg
	var/datum/thermal_material/thermal_material //contains the material properties of the item for burning, if applicable
	var/fire_protection //duration that something stays extinguished

	var/melt_temperature = 0 //unused, to be removed
	var/molten = 0 //unused, to be removed

	var/fire_dmi = 'icons/effects/fire.dmi'
	var/fire_sprite = "fire"
	var/fire_overlay = null

	var/atom/movable/firelightdummy/firelightdummy

/atom/movable/New()
	. = ..()
	if(flammable)
		switch(w_type)
			if(RECYK_WOOD)
				thermal_material = new/datum/thermal_material/wood()
			if(RECYK_PLASTIC, RECYK_ELECTRONIC, RECYK_MISC, NOT_RECYCLABLE)
				thermal_material = new/datum/thermal_material/plastic()
			if(RECYK_FABRIC)
				thermal_material = new/datum/thermal_material/fabric()
			if(RECYK_WAX)
				thermal_material = new/datum/thermal_material/wax()
			if(RECYK_BIOLOGICAL)
				thermal_material = new/datum/thermal_material/biological()
		if(!thermal_material)
			flammable = FALSE
			log_debug("[src] was defined as flammable but was missing a 'w_type' definition. [src] marked as inflammable for this round.")
			return
		if(!autoignition_temperature)
			autoignition_temperature = thermal_material.autoignition_temperature

/atom/movable/firelightdummy
	//this is a dummy that gets added to the vis_contents of a burning atom that can be a light source when its on fire so that it doesnt overwrite the light the atom might already be making
	//ideally instead of this you could directly add multiple light source datums to a single atom that would all be processed by the lighting system nicely
	//however, thats not how the lighting system currently works
	//are you up to the challenge?
	gender = PLURAL
	name = "fire"
	mouse_opacity = 0
	vis_flags = VIS_INHERIT_ID
	light_color = LIGHT_COLOR_FIRE

/atom/movable/firelightdummy/New()
	.=..()
	set_light(2,2)

/atom/proc/melt() //unused, to be removed
	return

/atom/proc/solidify() //unused, to be removed
	return

/atom/proc/ashtype()
	return /obj/effect/decal/cleanable/ash

//this proc is called on every fire/process()
//energy is taken from burning atoms and delivered to the fire at its current location
//proc returns energy in MJ and oxygen consumed in mols
/atom/proc/burnSolidFuel()
	var/turf/T = isturf(src) ? src : get_turf(loc)

	var/datum/thermal_material/material = src.thermal_material

	var/datum/gas_mixture/air = T.return_air()
	var/oxy_ratio  = air.partial_pressure(GAS_OXYGEN) / 100
	var/temperature = air.return_temperature()
	var/delta_t

	var/heat_out = 0 //MJ
	var/oxy_used = 0 //mols
	var/co2_prod = 0 //mols

	//if all energy has been extracted from the atom, ash it
	if(thermal_mass <= 0)
		ashify()
		return

	//don't burn the container until all reagents have been depleted
	if(reagents)
		return

	// ignite the tile if there isn't a fire present already
	var/in_fire = FALSE //is the atom in a tile with a fire
	for(var/obj/effect/fire/F in loc)
		in_fire = TRUE
		break

	//rate at which energy is consumed from the atom and delivered to the fire
	//burnrate = 1 at 20C with standard oxy concentration
	//provides the "heat" and "oxygen" portions of the fire triangle
	var/burnrate = (oxy_ratio/(MINOXY2BURN + rand(-0.02,0.02))) * (temperature/T20C)

	if(burnrate < 0.1)
		extinguish()
		return

	//smoke density increases with burnrate and decreases with temperature
	// var/smoke_density = clamp(4 * burnrate * (1-temperature/FLAME_TEMPERATURE_PLASTIC),1,5)
	// if(prob(smoke_density)) //1-5% chance of smoke creation per tick
	// 	var/datum/effect/system/smoke_spread/fire/smoke = new /datum/effect/system/smoke_spread()
	// 	smoke.set_up(smoke_density,0,T)
	// 	smoke.time_to_live = 30 SECONDS
	// 	smoke.start()

	//a tiny object will burn for 10 seconds under standard pressure and oxygen concentration
	//a large object will burn for 250 seconds under standard pressure and oxygen concentration
	var/delta_m = 0.1 * burnrate * zas_settings.Get(/datum/ZAS_Setting/fire_heat_generation) //mass change this tick
	thermal_mass -= delta_m

	//change in internal energy = energy produced by combustion (assuming perfect combustion)
	heat_out = material.heating_value * delta_m

	//n_oxy = (m_fuel / (m_fuel/n_fuel)) / (n_fuel/n_oxy)
	oxy_used = (delta_m / material.molecular_weight) / material.fuel_ox_ratio //mols
	co2_prod = oxy_used //simplification

	if(!in_fire && T)
		//change in internal energy (delta_U) = change in energy due to heat transfer (delta_Q) due to isochoric reaction
		//delta_t = delta_Q/(m*c) = heat_out/(delta_m * heating_value)
		delta_t = heat_out/(delta_m * material.heating_value)
		T.hotspot_expose(temperature + delta_t, CELL_VOLUME, surfaces=1)
	return list("heat_out"=heat_out,"oxy_used"=oxy_used,"co2_prod"=co2_prod,"max_temperature"=material.flame_temp)

//Outputs the heat produced (MJ), oxygen consumed (mol), co2 consumed (mol), and maximum flame temperature (K)
/atom/proc/burnLiquidFuel()
	var/heat_out = 0 //MJ
	var/oxy_used = 0 //mols
	var/co2_prod = 0 //mols (some reagents consume co2 when they burn)
	var/max_temperature = 0 //K
	var/thermal_energy_transfer = 0 //J
	var/consumption_rate = 1.0 //units per tick

	if(!reagents)
		return list(heat_out,oxy_used,co2_prod,max_temperature)
	for(var/datum/reagent/A in reagents.reagent_list)
		if(A.id in possible_fuels) //burn flammable
			var/list/fuel_stats = possible_fuels[A.id]
			max_temperature = fuel_stats["max_temperature"]
			thermal_energy_transfer = fuel_stats["thermal_energy_transfer"]
			consumption_rate = fuel_stats["consumption_rate"]
			oxy_used = fuel_stats["o2_cons"]
			co2_prod = fuel_stats["co2_cons"]

			reagents.remove_reagent(A.id, consumption_rate)
			heat_out = thermal_energy_transfer / 1000000 // J to MJ
		else //evaporate inflammable
			reagents.remove_reagent(A.id, consumption_rate)
		return list("heat_out"=heat_out,"oxy_used"=oxy_used,"co2_prod"=co2_prod,"max_temperature"=max_temperature)

/atom/proc/ashify()
	if(!on_fire)
		return
	var/ashtype = ashtype()
	new ashtype(src.loc)
	extinguish()
	message_admins("Extinguished because ashify() called")
	qdel(src)

/atom/proc/extinguish(var/duration = 30 SECONDS)
	if (on_fire)
		on_fire=0
		fire_protection = world.time + duration
		if(fire_overlay)
			overlays -= fire_overlay
		QDEL_NULL(firelightdummy)

//ignite() lights objects on fire; hotspot_expose() lights turfs and spawns fire effects
/atom/proc/ignite()
	var/in_fire = FALSE
	if(!flammable || fire_protection - world.time > 0)
		return FALSE
	on_fire=1
	if(fire_dmi && fire_sprite && !isturf(src))
		fire_overlay = image(fire_dmi,fire_sprite)
		overlays += fire_overlay

	var/atom/movable/AM = src
	if(istype(AM))
		firelightdummy = new (src)
		AM.vis_contents += firelightdummy

	for(var/obj/effect/fire/F in loc)
		in_fire = TRUE
		break
	if(!in_fire)
		new /obj/effect/fire(loc)
	return TRUE

/atom/proc/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(flammable && !on_fire)
		ignite()
		return 1
	return 0


/area/fire_act()
	return

/mob/fire_act()
	return

///////////////////////////////////////////////
// TURF COMBUSTION
///////////////////////////////////////////////
/turf
	var/soot_type = /obj/effect/decal/cleanable/soot

/turf/ashify()
	if(!on_fire)
		return
	var/ashtype = ashtype()
	new ashtype(src.loc)
	extinguish()
	message_admins("Extinguished because turf ashify() called")
	ChangeTurf(src.get_underlying_turf())

/turf/proc/hotspot_expose(var/exposed_temperature, var/exposed_volume, var/soh = 0, var/surfaces=0)

/turf/simulated/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	var/obj/effect/E = null
	if(soot_type)
		E = locate(soot_type) in src
	if(..())
		return 1
	if(on_fire)
		if(istype(E))
			qdel(E)
		return 0
	else
		if(flammable || (locate(/obj/effect/decal/cleanable/liquid_fuel) in src))
			on_fire = 1
	if(!E && soot_type && prob(25))
		new soot_type(src)
	return 0

/turf/simulated/hotspot_expose(exposed_temperature, exposed_volume, soh, surfaces)
	var/obj/effect/foam/fire/W = locate() in contents
	if(istype(W))
		return 0
	if(fire_protection > world.time-300)
		return 0

	var/datum/gas_mixture/air_contents = return_air()

	if(!air_contents)
		return 0

	var/igniting = 0

	if(surfaces && air_contents.partial_pressure(GAS_OXYGEN) / 100 >= MINOXY2BURN)
		for(var/obj/O in contents)
			if(prob(exposed_volume * 100 / CELL_VOLUME) && istype(O) && O.flammable && !O.on_fire && exposed_temperature >= O.autoignition_temperature)
				O.ignite()
				igniting = 1
				break
	if(!igniting && exposed_temperature >= PLASMA_MINIMUM_BURN_TEMPERATURE && air_contents.check_combustability(src, surfaces))
		igniting = 1
	else if(igniting)
		new /obj/effect/fire(src)
	return igniting

/turf/unsimulated/burnLiquidFuel()
	return

// Burning puddles of fuel. Can be improved if reagent puddles are ever a thing.
/turf/simulated/burnLiquidFuel()
	var/heat_out = 0 //MJ
	var/oxy_used = 0 //mols
	var/co2_prod = 0 //mols (some reagents consume co2 when they burn)
	var/max_temperature = 0 //K
	var/thermal_energy_transfer = 0 //J
	var/consumption_rate = 1.0 //units per tick

	if(!(locate(/obj/effect/decal/cleanable/liquid_fuel) in src))
		return

	var/obj/effect/decal/cleanable/liquid_fuel/puddle = locate(/obj/effect/decal/cleanable/liquid_fuel) in src
	var/list/fuel_stats = possible_fuels[puddle.reagent]
	max_temperature = fuel_stats["max_temperature"]
	thermal_energy_transfer = fuel_stats["thermal_energy_transfer"]
	consumption_rate = fuel_stats["consumption_rate"]
	oxy_used = fuel_stats["o2_cons"]
	co2_prod = fuel_stats["co2_cons"]

	puddle.amount -= consumption_rate
	heat_out = thermal_energy_transfer / 1000000 // J to MJ

	if(puddle.amount < 0.1)
		qdel(puddle)
	return list("heat_out"=heat_out,"oxy_used"=oxy_used,"co2_prod"=co2_prod,"max_temperature"=max_temperature)


///////////////////////////////////////////////
// FIRE OBJECT
///////////////////////////////////////////////
/obj/effect/fire
	//Icon for fire on turfs.

	anchored = 1
	mouse_opacity = 0

	blend_mode = BLEND_ADD

	icon = 'icons/effects/fire.dmi'
	icon_state = "key1"
	layer = TURF_FIRE_LAYER
	plane = ABOVE_TURF_PLANE

	light_color = LIGHT_COLOR_FIRE

/obj/effect/fire/proc/Extinguish()
	for(var/atom/A in loc)
		A.extinguish()
	qdel(src)

/obj/effect/fire/process()
	if(timestopped)
		return 0
	. = 1

	// Get location and check if it is in a proper ZAS zone.
	var/turf/simulated/S = get_turf(loc)

	if (!istype(S))
		Extinguish()
		message_admins("Extinguished because not a simmed turf")
		return

	if (isnull(S.zone))
		Extinguish()
		message_admins("Extinguished because null zone")
		return

	var/datum/gas_mixture/air_contents = S.return_air()

	//since the air is processed in fractions, we need to make sure not to have any minuscle residue or
	//the amount of moles might get to low for some functions to catch them and thus result in wonky behaviour
	if(air_contents.molar_density(GAS_OXYGEN) < 0.1 / CELL_VOLUME)
		air_contents[GAS_OXYGEN] = 0
	if(air_contents.molar_density(GAS_PLASMA) < 0.1 / CELL_VOLUME)
		air_contents[GAS_PLASMA] = 0
	if(air_contents.molar_density(GAS_VOLATILE) < 0.1 / CELL_VOLUME)
		air_contents[GAS_VOLATILE] = 0

	air_contents.update_values()

	// Check if there is something to combust.
	if (!air_contents.check_recombustability(S))
		Extinguish()
		return

	if(air_contents.partial_pressure(GAS_OXYGEN)/100 < MINOXY2BURN)
		Extinguish()
		return

	var/firelevel = air_contents.calculate_firelevel(S)
	setfirelight(firelevel, air_contents.temperature)

	//im not sure how to implement a version that works for every creature so for now monkeys are firesafe
	for(var/mob/living/carbon/human/M in loc)
		if(M.mutations.Find(M_UNBURNABLE))
			continue

		M.FireBurn(firelevel, air_contents.temperature, air_contents.return_pressure() ) //Burn the humans!

	for(var/atom/A in loc)
		A.fire_act(air_contents, air_contents.temperature, air_contents.return_volume())


	// Burn the turf, too.
	S.fire_act(air_contents, air_contents.temperature, air_contents.return_volume())

	//spread
	for(var/direction in cardinal)
		if(S.open_directions & direction) //Grab all valid bordering tiles

			var/turf/simulated/enemy_tile = get_step(S, direction)

			if(istype(enemy_tile))
				var/datum/gas_mixture/acs = enemy_tile.return_air()

				if(!acs)
					continue
				if(!acs.check_combustability(enemy_tile))
					continue
				//If extinguisher mist passed over the turf it's trying to spread to, don't spread and
				//reduce firelevel.
				var/obj/effect/foam/fire/W = locate() in enemy_tile
				if(istype(W))
					firelevel -= 3
					continue
				if(enemy_tile.fire_protection > world.time-30)
					firelevel -= 1.5
					continue

				//Spread the fire.
				if(!(locate(/obj/effect/fire) in enemy_tile))
					if( prob(10 + 50 * zas_settings.Get(/datum/ZAS_Setting/fire_spread_rate) * (firelevel/zas_settings.Get(/datum/ZAS_Setting/fire_firelevel_multiplier)) ) && S.Cross(null, enemy_tile, 0,0) && enemy_tile.Cross(null, S, 0,0))
						new/obj/effect/fire(enemy_tile)

	//seperate part of the present gas
	//this is done to prevent the fire burning all gases in a single pass
	var/datum/gas_mixture/flow = air_contents.remove_volume(zas_settings.Get(/datum/ZAS_Setting/fire_consumption_rate) * CELL_VOLUME)

///////////////////////////////// FLOW HAS BEEN CREATED /// DONT DELETE THE FIRE UNTIL IT IS MERGED BACK OR YOU WILL DELETE AIR ///////////////////////////////////////////////

	if(flow)
		flow.zburn(S, 1)

		//merge the air back
		S.assume_air(flow)

///////////////////////////////// FLOW HAS BEEN REMERGED /// feel free to delete the fire again from here on //////////////////////////////////////////////////////////////////

/obj/effect/fire/New()
	. = ..()
	dir = pick(cardinal)
	var/datum/gas_mixture/air_contents=return_air()
	if(air_contents)
		setfirelight(air_contents.calculate_firelevel(get_turf(src)), air_contents.temperature)
	SSair.add_hotspot(src)

/obj/effect/fire/Destroy()
	SSair.remove_hotspot(src)

	set_light(0)
	..()

/obj/effect/fire/proc/setfirelight(firelevel, firetemp)

	var/heatlight = max(1, firetemp / 2000)

	// Update fire color.
	color = heat2color(firetemp)

	if(firelevel > 6)
		icon_state = "key3"
		set_light(7, 3 * heatlight, color)
	else if(firelevel > 2.5)
		icon_state = "key2"
		set_light(5, 2 * heatlight, color)
	else
		icon_state = "key1"
		set_light(3, 1 * heatlight, color)

// where the magic happens
/datum/gas_mixture/proc/zburn(var/turf/T, force_burn)
	// NOTE: zburn is also called from canisters and in tanks/pipes (via react()).  Do NOT assume T is always a turf.
	//  In the aforementioned cases, it's null. - N3X.
	var/value = 0

	if((temperature > PLASMA_MINIMUM_BURN_TEMPERATURE || force_burn) && check_recombustability(T))
		var/firelevel = 0
		var/total_fuel = 0
		var/starting_energy = 0
		var/total_oxygen = 0
		var/used_fuel_ratio = 0
		var/total_reactants = 0
		var/used_reactants_ratio = 0

		total_fuel += src[GAS_PLASMA]
		total_fuel += src[GAS_VOLATILE]

		if(total_fuel)
			//Calculate the firelevel.
			firelevel = calculate_firelevel(T)

			//get the current inner energy of the gas mix
			//this must be taken here to prevent the addition or deletion of energy by a changing heat capacity
			starting_energy = temperature * heat_capacity()

			//determine the amount of oxygen used
			total_oxygen = min(src[GAS_OXYGEN], 2 * total_fuel)

			//determine the amount of fuel actually used
			used_fuel_ratio = min(src[GAS_OXYGEN] / 2 , total_fuel) / total_fuel
			total_fuel = total_fuel * used_fuel_ratio

			total_reactants = total_fuel + total_oxygen

			//determine the amount of reactants actually reacting
			used_reactants_ratio = clamp(firelevel / zas_settings.Get(/datum/ZAS_Setting/fire_firelevel_multiplier), clamp(0.2 / total_reactants, 0, 1), 1)

		//burn solids and liquids
		var/SL_energy = 0
		var/SL_oxy_used = 0
		var/SL_co2_prod = 0
		var/max_temperature = 0
		if(T && istype(T))
			if(T.flammable)
				var/solid_burn_products = T.burnSolidFuel()
				if(solid_burn_products)
					SL_energy += solid_burn_products["heat_out"]
					SL_oxy_used += solid_burn_products["oxy_used"]
					SL_co2_prod += solid_burn_products["co2_prod"]
					max_temperature = max(max_temperature, solid_burn_products["max_temperature"])

				var/liquid_burn_products = T.burnLiquidFuel()
				if(liquid_burn_products)
					SL_energy += liquid_burn_products["heat_out"]
					SL_oxy_used += liquid_burn_products["oxy_used"]
					SL_co2_prod += -liquid_burn_products["co2_prod"]
					max_temperature = max(max_temperature, liquid_burn_products["max_temperature"])
			for(var/atom/A in T)
				if(!A.flammable)
					continue
				var/solid_burn_products = A.burnSolidFuel()
				if(solid_burn_products)
					SL_energy += solid_burn_products["heat_out"]
					SL_oxy_used += solid_burn_products["oxy_used"]
					SL_co2_prod += solid_burn_products["co2_prod"]
					max_temperature = max(max_temperature, solid_burn_products["max_temperature"])

				var/liquid_burn_products = A.burnLiquidFuel()
				if(liquid_burn_products)
					SL_energy += liquid_burn_products["heat_out"]
					SL_oxy_used += liquid_burn_products["oxy_used"]
					SL_co2_prod += -liquid_burn_products["co2_prod"]
					max_temperature = max(max_temperature, liquid_burn_products["max_temperature"])

		//sanity check
		SL_oxy_used = clamp(SL_oxy_used, 0, src[GAS_OXYGEN])

		//remove and add gasses as calculated
		adjust_multi(
			GAS_OXYGEN, -min(src[GAS_OXYGEN], total_oxygen * used_reactants_ratio + SL_oxy_used * zas_settings.Get(/datum/ZAS_Setting/fire_oxygen_consumption)),
			GAS_PLASMA, -min(src[GAS_PLASMA], (src[GAS_PLASMA] * used_fuel_ratio * used_reactants_ratio) * 3),
			GAS_CARBON, max(2 * total_fuel * used_reactants_ratio + SL_co2_prod * zas_settings.Get(/datum/ZAS_Setting/fire_oxygen_consumption), 0),
			GAS_VOLATILE, -(src[GAS_VOLATILE] * used_fuel_ratio * used_reactants_ratio) * 5) //Fuel burns 5 times as quick

		//calculate the energy produced by the reaction and then set the new temperature of the mix
		if(total_fuel) //gas burning = limitless temperature
			temperature = (starting_energy + SL_energy * 100000 + zas_settings.Get(/datum/ZAS_Setting/fire_fuel_energy_release) * total_fuel * used_reactants_ratio) / heat_capacity()
		else
			temperature += max(((starting_energy + SL_energy * 100000 * zas_settings.Get(/datum/ZAS_Setting/fire_heat_generation)) / heat_capacity()) * (1 - temperature/max_temperature),0)
		update_values()
		value = total_reactants * used_reactants_ratio //0 if solids and liquids only
	return value

// checks if anything in a given turf can continue combusting.
/datum/gas_mixture/proc/check_recombustability(var/turf/T)
	if(gas[GAS_OXYGEN] && (gas[GAS_PLASMA] || gas[GAS_VOLATILE]))
		if(QUANTIZE(molar_density(GAS_PLASMA) * zas_settings.Get(/datum/ZAS_Setting/fire_consumption_rate)) >= MOLES_PLASMA_VISIBLE / CELL_VOLUME)
			return 1
		if(QUANTIZE(molar_density(GAS_VOLATILE) * zas_settings.Get(/datum/ZAS_Setting/fire_consumption_rate)) >= BASE_ZAS_FUEL_REQ / CELL_VOLUME)
			return 1

	// Check if we're actually in a turf or not before trying to check object fires.
	// Moved here to unbreak tankbombs - N3X
	if(!T)
		return 0

	if(!istype(T))
		warning("check_recombustability being asked to check a [T.type] instead of /turf.")
		return 0

	for(var/atom/A in T)
		if(A.flammable && A.fire_protection - world.time <= 0)
			if(A.thermal_mass > 0)
				return 1

	if(T.flammable && T.fire_protection - world.time <= 0)
		if(T.thermal_mass > 0)
			return 1

// checks if anything in a given turf can combust.
/datum/gas_mixture/proc/check_combustability(var/turf/T)
	for(var/atom/A in T)
		if(A.flammable)
			return 1
	if(T.flammable)
		return 1
	if(locate(/obj/effect/decal/cleanable/liquid_fuel) in T)
		return 1
	if(gas[GAS_OXYGEN] && (gas[GAS_PLASMA] || gas[GAS_VOLATILE]))
		if(QUANTIZE(molar_density(GAS_PLASMA) * zas_settings.Get(/datum/ZAS_Setting/fire_consumption_rate)) >= MOLES_PLASMA_VISIBLE / CELL_VOLUME)
			return 1
		if(QUANTIZE(molar_density(GAS_VOLATILE) * zas_settings.Get(/datum/ZAS_Setting/fire_consumption_rate)) >= BASE_ZAS_FUEL_REQ / CELL_VOLUME)
			return 1
	return 0

// firelevel represents the intensity of the fire according to GAS REACTANTS only. Solids and liquids burning use an internal burnrate calculation.
/datum/gas_mixture/proc/calculate_firelevel(var/turf/T)
	var/total_fuel = 0
	var/firelevel = 0

	if(check_recombustability(T))
		total_fuel += src[GAS_PLASMA]
		total_fuel += src[GAS_VOLATILE]

		var/total_combustables = (total_fuel + src[GAS_OXYGEN])

		if(total_fuel > 0 && src[GAS_OXYGEN] > 0)
			//slows down the burning when the concentration of the reactants is low
			var/dampening_multiplier = total_combustables / (total_combustables + src[GAS_NITROGEN] + src[GAS_CARBON])
			//calculates how close the mixture of the reactants is to the optimum
			var/mix_multiplier = 1 / (1 + (5 * ((src[GAS_OXYGEN] / total_combustables) ** 2))) // Thanks, Mloc
			//toss everything together
			firelevel = zas_settings.Get(/datum/ZAS_Setting/fire_firelevel_multiplier) * mix_multiplier * dampening_multiplier
	return max(0, firelevel)


///////////////////////////////////////////////
// MOB HEALTH
///////////////////////////////////////////////
/mob/living/proc/FireBurn(var/firelevel, var/last_temperature, var/pressure)
	var/mx = 5 * firelevel/zas_settings.Get(/datum/ZAS_Setting/fire_firelevel_multiplier) * min(pressure / ONE_ATMOSPHERE, 1)
	apply_damage(2.5*mx, BURN)

/mob/living/carbon/human/FireBurn(var/firelevel, var/last_temperature, var/pressure)
	//Burns mobs due to fire. Respects heat transfer coefficients on various body parts.
	//Due to TG reworking how fireprotection works, this is kinda less meaningful.

	var/head_exposure = 1
	var/chest_exposure = 1
	var/groin_exposure = 1
	var/legs_exposure = 1
	var/arms_exposure = 1

	//Get heat transfer coefficients for clothing.

	for(var/obj/item/clothing/C in src)
		if(is_holding_item(C))
			continue

		if( C.max_heat_protection_temperature >= last_temperature )
			if(!is_slot_hidden(C.body_parts_covered,FULL_HEAD))
				head_exposure = 0
			if(!is_slot_hidden(C.body_parts_covered,UPPER_TORSO))
				chest_exposure = 0
			if(!is_slot_hidden(C.body_parts_covered,LOWER_TORSO))
				groin_exposure = 0
			if(!is_slot_hidden(C.body_parts_covered,LEGS))
				legs_exposure = 0
			if(!is_slot_hidden(C.body_parts_covered,ARMS))
				arms_exposure = 0
	//minimize this for low-pressure enviroments
	var/mx = 5 * firelevel/zas_settings.Get(/datum/ZAS_Setting/fire_firelevel_multiplier) * min(pressure / ONE_ATMOSPHERE, 1)

	//Always check these damage procs first if fire damage isn't working. They're probably what's wrong.
	var/fire_tile_modifier = 4 //multiplicative modifier for damage received while on fire and standing on a fire tile
	apply_damage(fire_tile_modifier*HEAD_FIRE_DAMAGE_MULTIPLIER*mx*head_exposure, BURN, LIMB_HEAD, 0, 0, used_weapon = "Fire")
	apply_damage(fire_tile_modifier*CHEST_FIRE_DAMAGE_MULTIPLIER*mx*chest_exposure, BURN, LIMB_CHEST, 0, 0, used_weapon ="Fire")
	apply_damage(fire_tile_modifier*GROIN_FIRE_DAMAGE_MULTIPLIER*mx*groin_exposure, BURN, LIMB_GROIN, 0, 0, used_weapon ="Fire")
	apply_damage(fire_tile_modifier*LEGS_FIRE_DAMAGE_MULTIPLIER*mx*legs_exposure, BURN, LIMB_LEFT_LEG, 0, 0, used_weapon = "Fire")
	apply_damage(fire_tile_modifier*LEGS_FIRE_DAMAGE_MULTIPLIER*mx*legs_exposure, BURN, LIMB_RIGHT_LEG, 0, 0, used_weapon = "Fire")
	apply_damage(fire_tile_modifier*ARMS_FIRE_DAMAGE_MULTIPLIER*mx*arms_exposure, BURN, LIMB_LEFT_ARM, 0, 0, used_weapon = "Fire")
	apply_damage(fire_tile_modifier*ARMS_FIRE_DAMAGE_MULTIPLIER*mx*arms_exposure, BURN, LIMB_RIGHT_ARM, 0, 0, used_weapon = "Fire")

	if(head_exposure+chest_exposure+groin_exposure+legs_exposure+arms_exposure)
		src.dizziness = 5
		src.confused =  5
		src.audible_scream()
