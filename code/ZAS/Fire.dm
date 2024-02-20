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
	var/heating_value = 0
	var/fuel_ox_ratio
	var/autoignition_temperature = 0
	var/molecular_weight
	var/flammable = FALSE
	var/flame_temp = 0
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
				heating_value = HHV_WOOD
				molecular_weight = MOLECULAR_WEIGHT_WOOD
				fuel_ox_ratio = FUEL_OX_RATIO_WOOD
				flame_temp = FLAME_TEMPERATURE_WOOD
			if(RECYK_PLASTIC, RECYK_ELECTRONIC)
				autoignition_temperature = AUTOIGNITION_PLASTIC
				heating_value = HHV_PLASTIC
				molecular_weight = MOLECULAR_WEIGHT_PLASTIC
				fuel_ox_ratio = FUEL_OX_RATIO_PLASTIC
				flame_temp = FLAME_TEMPERATURE_PLASTIC
			if(RECYK_FABRIC)
				autoignition_temperature = AUTOIGNITION_FABRIC
				heating_value = HHV_FABRIC
				molecular_weight = MOLECULAR_WEIGHT_FABRIC
				fuel_ox_ratio = FUEL_OX_RATIO_FABRIC
				flame_temp = FLAME_TEMPERATURE_FABRIC
			if(RECYK_WAX)
				autoignition_temperature = AUTOIGNITION_WAX
				heating_value = HHV_WAX
				molecular_weight = MOLECULAR_WEIGHT_WAX
				fuel_ox_ratio = FUEL_OX_RATIO_WAX
				flame_temp = FLAME_TEMPERATURE_WAX
			if(RECYK_BIOLOGICAL)
				autoignition_temperature = AUTOIGNITION_BIOLOGICAL
				heating_value = HHV_BIOLOGICAL
				molecular_weight = MOLECULAR_WEIGHT_BIOLOGICAL
				fuel_ox_ratio = FUEL_OX_RATIO_BIOLOGICAL
				flame_temp = FLAME_TEMPERATURE_BIOLOGICAL
	else // just in case this was overwritten elsewhere accidentally
		autoignition_temperature = 0

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

	//if all energy has been extracted from the atom, ash it
	if(thermal_mass <= 0)
		ashify()
		return list(heat_out,oxy_used)

	//don't burn the container until all reagents have been depleted
	if(reagents)
		return list(heat_out,oxy_used)

	// ignite the tile if there isn't a fire present already
	var/in_fire = FALSE //is the atom in a tile with a fire
	for(var/obj/effect/fire/F in loc)
		in_fire = TRUE
		break

	//rate at which energy is consumed from the atom and delivered to the fire
	//burnrate = 1 at 20C with standard oxy concentration
	//provides the "heat" and "oxygen" portions of the fire triangle
	var/burnrate = oxy_ratio >= MINOXY2BURN ? (oxy_ratio/(MINOXY2BURN + rand(-0.02,0.02))) * (temperature/T20C) : 0

	if(burnrate < 0.1)
		extinguish()
		return list(heat_out,oxy_used)

	//smoke density increases with burnrate and decreases with temperature
	var/smoke_density = clamp(4 * burnrate * (1-temperature/FLAME_TEMPERATURE_PLASTIC),1,5)
	if(prob(smoke_density)) //1-5% chance of smoke creation per tick
		smoke.set_up(smoke_density,0,T)
		smoke.time_to_live = 30 SECONDS
		smoke.start()

	//a tiny object will burn for 10 seconds under standard pressure and oxygen concentration
	//a large object will burn for 250 seconds under standard pressure and oxygen concentration
	var/delta_m = 0.1 * burnrate //mass change this tick
	thermal_mass -= delta_m

	//change in internal energy = energy produced by combustion (assuming perfect combustion)
	heat_out = heating_value * delta_m

	//n_oxy = (m_fuel / (m_fuel/n_fuel)) / (n_fuel/n_oxy)
	oxy_used = (delta_m / molecular_weight) / fuel_ox_ratio //mols

	if(!in_fire && T)
		//change in internal energy (delta_U) = change in energy due to heat transfer (delta_Q) due to isochoric reaction
		//delta_t = delta_Q/(m*c) = heat_out/(delta_m * heating_value)
		delta_t = heat_out/(delta_m * heating_value)
		T.hotspot_expose(temperature + delta_t, CELL_VOLUME, surfaces=1)
	return list(heat_out,oxy_used)

/atom/proc/burnLiquidFuel()
	var/heat_out = 0 //MJ
	var/oxy_used = 0 //mols

	if(!reagents)
		return list(heat_out,oxy_used)
	for(var/datum/reagent/A in reagents.reagent_list)
		if(A.id in possible_fuels)
		else


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
	var/turf/simulated/S=loc

	if(istype(S))
		S.extinguish()

	for(var/atom/A in loc)
		A.extinguish()

	qdel(src)

/obj/effect/fire/proc/burnFuel()
	///atom/proc/burnSolidFuel()
	///atom/proc/burnLiquidFuel()
	return

/obj/effect/fire/process()
	if(timestopped)
		return 0
	. = 1

	// Get location and check if it is in a proper ZAS zone.
	var/turf/simulated/S = get_turf(loc)

	if (!istype(S))
		Extinguish()
		return

	if (isnull(S.zone))
		Extinguish()
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
		//testing("Not recombustible.")
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
				if(!acs.check_recombustability(enemy_tile))
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
					if( prob( 50 + 50 * (firelevel/zas_settings.Get(/datum/ZAS_Setting/fire_firelevel_multiplier)) ) && S.Cross(null, enemy_tile, 0,0) && enemy_tile.Cross(null, S, 0,0))
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



/turf/simulated/var/fire_protection = 0 //Protects newly extinguished tiles from being overrun again.
/turf/proc/apply_fire_protection()
/turf/simulated/apply_fire_protection()
	fire_protection = world.time


/datum/gas_mixture/proc/zburn(var/turf/T, force_burn)
	// NOTE: zburn is also called from canisters and in tanks/pipes (via react()).  Do NOT assume T is always a turf.
	//  In the aforementioned cases, it's null. - N3X.
	var/value = 0

	if((temperature > PLASMA_MINIMUM_BURN_TEMPERATURE || force_burn) && check_recombustability(T))
		var/total_fuel = 0

		total_fuel += src[GAS_PLASMA]
		total_fuel += src[GAS_VOLATILE]

		var/can_use_turf=(T && istype(T))
		if(can_use_turf)
			for(var/atom/A in T)
				if(!A)
					continue
				total_fuel += A.getFireFuel()

		if (0 == total_fuel) // Fix zburn /0 runtime
			//testing("zburn: No fuel left.")
			return 0

		//Calculate the firelevel.
		var/firelevel = calculate_firelevel(T)

		//get the current inner energy of the gas mix
		//this must be taken here to prevent the addition or deletion of energy by a changing heat capacity
		var/starting_energy = temperature * heat_capacity()

		//determine the amount of oxygen used
		var/total_oxygen = min(src[GAS_OXYGEN], 2 * total_fuel)

		//determine the amount of fuel actually used
		var/used_fuel_ratio = min(src[GAS_OXYGEN] / 2 , total_fuel) / total_fuel
		total_fuel = total_fuel * used_fuel_ratio

		var/total_reactants = total_fuel + total_oxygen

		//determine the amount of reactants actually reacting
		var/used_reactants_ratio = clamp(firelevel / zas_settings.Get(/datum/ZAS_Setting/fire_firelevel_multiplier), clamp(0.2 / total_reactants, 0, 1), 1)

		//remove and add gasses as calculated
		adjust_multi(
			GAS_OXYGEN, -min(src[GAS_OXYGEN], total_oxygen * used_reactants_ratio),
			GAS_PLASMA, -min(src[GAS_PLASMA], (src[GAS_PLASMA] * used_fuel_ratio * used_reactants_ratio) * 3),
			GAS_CARBON, max(2 * total_fuel * used_reactants_ratio, 0),
			GAS_VOLATILE, -(src[GAS_VOLATILE] * used_fuel_ratio * used_reactants_ratio) * 5) //Fuel burns 5 times as quick

		if(can_use_turf)
			if(T.getFireFuel()>0)
				T.burnFireFuel(used_fuel_ratio, used_reactants_ratio)
			for(var/atom/A in T)
				if(A.getFireFuel()>0)
					A.burnFireFuel(used_fuel_ratio, used_reactants_ratio)

		//calculate the energy produced by the reaction and then set the new temperature of the mix
		temperature = (starting_energy + zas_settings.Get(/datum/ZAS_Setting/fire_fuel_energy_release) * total_fuel * used_reactants_ratio) / heat_capacity()

		update_values()
		value = total_reactants * used_reactants_ratio
	return value

/datum/gas_mixture/proc/check_recombustability(var/turf/T)
	//this is a copy proc to continue a fire after its been started.

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

	// We have to check all objects in order to extinguish object fires.
	var/still_burning=0
	for(var/atom/A in T)
		if(!A)
			continue
		if(!gas[GAS_OXYGEN]/* || A.autoignition_temperature > temperature*/)
			A.extinguish()
			continue
//		if(!A.autoignition_temperature)
//			continue // Don't fuck with things that don't burn.
		if(QUANTIZE(A.getFireFuel() * zas_settings.Get(/datum/ZAS_Setting/fire_consumption_rate)) >= A.volatility)
			still_burning=1
		else if(A.on_fire)
			//A.extinguish()
			A.ashify()

	return still_burning

/datum/gas_mixture/proc/check_combustability(var/turf/T, var/objects)
	//this check comes up very often and is thus centralized here to ease adding stuff
	// zburn is used in tank fires, as well. This check, among others, broke tankbombs. - N3X
	/*
	if(!istype(T))
		warning("check_combustability being asked to check a [T.type] instead of /turf.")
		return 0
	*/

	if(gas[GAS_OXYGEN] && (gas[GAS_PLASMA] || gas[GAS_VOLATILE]))
		if(QUANTIZE(molar_density(GAS_PLASMA) * zas_settings.Get(/datum/ZAS_Setting/fire_consumption_rate)) >= MOLES_PLASMA_VISIBLE / CELL_VOLUME)
			return 1
		if(QUANTIZE(molar_density(GAS_VOLATILE) * zas_settings.Get(/datum/ZAS_Setting/fire_consumption_rate)) >= BASE_ZAS_FUEL_REQ / CELL_VOLUME)
			return 1

	if(objects && istype(T))
		for(var/atom/A in T)
			if(!A || !gas[GAS_OXYGEN] || A.autoignition_temperature > temperature)
				continue
			if(QUANTIZE(A.getFireFuel() * zas_settings.Get(/datum/ZAS_Setting/fire_consumption_rate)) >= A.volatility)
				return 1

	return 0

/datum/gas_mixture/proc/calculate_firelevel(var/turf/T)
	//Calculates the firelevel based on one equation instead of having to do this multiple times in different areas.

	var/total_fuel = 0
	var/firelevel = 0

	if(check_recombustability(T))

		total_fuel += src[GAS_PLASMA]

		if(T && istype(T))
			total_fuel += T.getFireFuel()

			for(var/atom/A in T)
				if(A)
					total_fuel += A.getFireFuel()

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
