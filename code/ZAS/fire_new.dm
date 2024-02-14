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
	var/specific_heat = 0
	var/fuel_ox_ratio
	var/autoignition_temperature = 0
	var/flammable = FALSE
	var/thermal_mass = 0 //VERY loose estimate of mass in kg
	var/burntime = 0 //time the object has been burning
	var/fire_protection //duration that something stays extinguished

	var/fire_dmi = 'icons/effects/fire.dmi'
	var/fire_sprite = "fire"
	var/fire_overlay = null

	var/atom/movable/firelightdummy/firelightdummy

/atom/movable/New()
	. = ..()
	if(flammable)
		switch(w_type)
			if(RECYK_WOOD)
				autoignition_temperature = AUTOIGNITION_WOOD
				specific_heat = SPECIFIC_HEAT_WOOD
				molecular_weight = MOLECULAR_WEIGHT_WOOD
				fuel_ox_ratio = FUEL_OX_RATIO_WOOD
			if(RECYK_PLASTIC, RECYK_ELECTRONIC)
				autoignition_temperature = AUTOIGNITION_PLASTIC
				specific_heat = SPECIFIC_HEAT_PLASTIC
				molecular_weight = MOLECULAR_WEIGHT_PLASTIC
				fuel_ox_ratio = FUEL_OX_RATIO_PLASTIC
			if(RECYK_FABRIC)
				autoignition_temperature = AUTOIGNITION_FABRIC
				specific_heat = SPECIFIC_HEAT_FABRIC
				molecular_weight = MOLECULAR_WEIGHT_FABRIC
				fuel_ox_ratio = FUEL_OX_RATIO_FABRIC
			if(RECYK_WAX)
				autoignition_temperature = AUTOIGNITION_WAX
				specific_heat = SPECIFIC_HEAT_WAX
				molecular_weight = MOLECULAR_WEIGHT_WAX
				fuel_ox_ratio = FUEL_OX_RATIO_WAX
			if(RECYK_BIOLOGICAL)
				autoignition_temperature = AUTOIGNITION_BIOLOGICAL
				specific_heat = SPECIFIC_HEAT_BIOLOGICAL
				molecular_weight = MOLECULAR_WEIGHT_BIOLOGICAL
				fuel_ox_ratio = FUEL_OX_RATIO_BIOLOGICAL
	else // just in case these were overwritten elsewhere accidentally
		autoignition_temperature = 0
		specific_combustion_heat = 0

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

/atom/proc/ashtype()
	return /obj/effect/decal/cleanable/ash

//this proc is called on every fire/process()
//energy is taken from burning atoms and delivered to the fire at its current location
//proc returns energy in MJ and oxygen consumed in mols
/atom/proc/burnSolidFuel()
	var/turf/T = get_turf(loc)

	var/datum/gas_mixture/air = T.return_air()
	var/oxy_ratio  = air.molar_density(GAS_OXYGEN)
	var/pressure = air.return_pressure()
	var/temperature = air.return_temperature()
	var/delta_t

	var/heat_out = 0 //MJ
	var/oxy_used = 0 //mols
	var/list/burn_products = list(heat_out,oxy_used)

	//if all energy has been extracted from the atom, ash it
	if(thermal_mass <= 0)
		ashify()
		return burn_products

	// ignite the tile if there isn't a fire present already
	var/in_fire = FALSE //is the atom in a tile with a fire
	for(var/obj/effect/fire/F in loc)
		in_fire = TRUE
		break

	//rate at which energy is consumed from the atom and delivered to the fire
	//burnrate = 1 at standard pressure with standard oxy concentration
	var/burnrate = oxy_ratio >= MINOXY2BURN ? (pressure/ONE_ATMOSPHERE) * (oxy_ratio/(MINOXY2BURN + rand(-.02,.02))) : 0

	if(burnrate < .1)
		extinguish()
		return burn_products

	//smoke density increases with burnrate and temperature
	var/smoke_density = clamp(4 * burnrate * (temperature/AUTOIGNITION_WOOD),1,5)
	if(prob(smoke_density)) //1-5% chance of smoke creation per tick
		smoke.set_up(smoke_density,0,T)
		smoke.time_to_live = 30 SECONDS
		smoke.start()

	//a tiny object will burn for 10 seconds under standard pressure and oxygen concentration
	//a large object will burn for 250 seconds under standard pressure and oxygen concentration
	var/delta_m = 0.1 * burnrate //mass change this tick
	thermal_mass -= delta_m

	//change in internal energy = energy produced by combustion (assuming perfect combustion)
	//delta_U = E = specific_heat * delta_m
	heat_out = specific_heat * delta_m

	//n_oxy = (m_fuel / (m_fuel/n_fuel)) / (n_fuel/n_oxy)
	oxy_used = (delta_m / molecular_weight) / fuel_ox_ratio //mols

	if(!in_fire && T)
		//change in internal energy (delta_U) = change in energy due to heat transfer (delta_Q) due to isochoric reaction
		//delta_t = delta_Q/(m*c) = heat_out/(delta_m * specific_heat)
		delta_t = heat_out/(delta_m * specific_heat)
		T.hotspot_expose(temperature + delta_t, CELL_VOLUME, surfaces=1)

	return burn_products

/atom/proc/burnLiquidFuel()
	var/heat_out = 0 //MJ
	var/oxy_used = 0 //mols
	var/list/burn_products = list(heat_out,oxy_used)

	if(!reagents)
		return burn_products
	for(reagent in src.reagents)
		//TODO: burn reagents

/atom/proc/ashify()
	if(!on_fire || burntime < 10) //all items will burn for at least 10 seconds
		return
	var/ashtype = ashtype()
	new ashtype(src.loc)
	extinguish()
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
	if(autoignition_temperature && !on_fire && exposed_temperature > autoignition_temperature)
		ignite()
		return 1
	return 0


///////////////////////////////////////////////
// TURF COMBUSTION
///////////////////////////////////////////////
/turf
	var/soot_type = /obj/effect/decal/cleanable/soot

/turf/proc/apply_fire_protection()

/turf/proc/hotspot_expose(var/exposed_temperature, var/exposed_volume, var/soh = 0, var/surfaces=0)

/turf/simulated/var/fire_protection = 0 //Protects newly extinguished tiles from being overrun again.

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

	if(surfaces && air_contents.molar_density(GAS_OXYGEN) >= MINOXY2BURN)
		for(var/obj/O in contents)
			if(prob(exposed_volume * 100 / CELL_VOLUME) && istype(O) && flammable && !O.on_fire && O.autoignition_temperature && exposed_temperature >= O.autoignition_temperature)
				O.ignite()
				igniting = 1
				break
	if(!igniting && exposed_temperature >= PLASMA_MINIMUM_BURN_TEMPERATURE && air_contents.check_combustability(src, surfaces))
		igniting = 1
	else if(igniting)
		new /obj/effect/fire(src)
	return igniting

/turf/simulated/apply_fire_protection()
	fire_protection = world.time

/turf/simulated/proc/burnLiquidFuel()
	return


///////////////////////////////////////////////
// FIRE OBJECT
///////////////////////////////////////////////

/obj/effect/fire/proc/burnFuel()
	///atom/proc/burnSolidFuel()
	///atom/proc/burnLiquidFuel()
	return
