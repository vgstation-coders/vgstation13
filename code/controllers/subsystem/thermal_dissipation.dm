var/datum/subsystem/thermal_dissipation/SStd
var/list/thermal_dissipation_reagents = list()

/datum/subsystem/thermal_dissipation
	name          = "Thermal Dissipation"
	wait          = SS_WAIT_THERM_DISS
	flags         = SS_KEEP_TIMING
	priority      = SS_PRIORITY_THERM_DISS
	display_order = SS_DISPLAY_THERM_DISS

	var/list/currentrun
	var/currentrun_index

/datum/subsystem/thermal_dissipation/New()
	NEW_SS_GLOBAL(SStd)
	currentrun = list()

/datum/subsystem/thermal_dissipation/stat_entry(var/msg)
	if (msg)
		return ..()
	..("M:[thermal_dissipation_reagents.len]")

/datum/subsystem/thermal_dissipation/stat_entry()
	..("P:[thermal_dissipation_reagents.len]")

/datum/subsystem/thermal_dissipation/fire(var/resumed = FALSE)

	var/c
	if (resumed)
		c = currentrun_index
	else
		c = thermal_dissipation_reagents.len
		if (c)
			currentrun.len = c
			for(var/i in 1 to c)
				currentrun[i] = thermal_dissipation_reagents[i]

	if(config.thermal_dissipation)
		var/simulate_air = config.reagents_heat_air
		var/datum/reagents/R
		while (c)
			R = currentrun[c]
			c--

			R?.handle_thermal_dissipation(simulate_air)

			if (MC_TICK_CHECK)
				break

	currentrun_index = c

/datum/reagents/proc/handle_thermal_dissipation(simulate_air)
	//Exchange heat between reagents and the surrounding air.
	//Although the heat is exchanged directly between reagents and air, for now this is based on thermal radiation, not convection per se.

	if(gcDestroyed)
		return

	if (!my_atom || my_atom.gcDestroyed || my_atom.timestopped)
		return

	if (!total_volume || !total_thermal_mass)
		return

	var/datum/gas_mixture/the_air = (get_turf(my_atom))?.return_air()
	if (!the_air)
		return

	if (!(chem_temp >= TCMB)) //Do it this way to catch NaNs.
		chem_temp = TCMB

	if (abs(chem_temp - the_air.temperature) < MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		return

	//We treat the reagents like a spherical grey body with an emissivity of THERM_DISS_SCALING_FACTOR.

	var/emission_factor = THERM_DISS_SCALING_FACTOR * (SS_WAIT_THERM_DISS / (1 SECONDS)) * STEFAN_BOLTZMANN_CONSTANT * (36 * PI) ** (1/3) * (CC_PER_U / 1000) ** (2/3) * total_volume ** (2/3)

	//Here we reduce thermal transfer to account for insulation of the container.
	//We iterate though each loc until the loc is the turf containing the_air, to account for things like nested containers, each time multiplying emission_factor by a factor than can range between [0 and 1], representing heat insulation.

	var/atom/this_potentially_insulative_layer = my_atom
	var/i = 0
	while (emission_factor)
		emission_factor *= this_potentially_insulative_layer.get_heat_conductivity()
		if (isturf(this_potentially_insulative_layer) || isarea(this_potentially_insulative_layer))
			break
		else if (i <= ARBITRARILY_LARGE_NUMBER)
			if (isatom(this_potentially_insulative_layer.loc))
				this_potentially_insulative_layer = this_potentially_insulative_layer.loc
				i++
			else
				break
		else
			message_admins("Something went wrong with [my_atom]'s handle_heat_dissipation() at iteration #[i] at [this_potentially_insulative_layer].")
			break //Avoid infinite loops.

	if (emission_factor)

		var/is_the_air_simulated = simulate_air && !istype(the_air, /datum/gas_mixture/unsimulated)
		var/air_thermal_mass = the_air.heat_capacity()

		if (max(chem_temp, the_air.temperature) <= THERM_DISS_MAX_SAFE_TEMP)

			var/reagents_thermal_mass_reciprocal = (1 / total_thermal_mass)

			var/energy_to_radiate_from_reagents_to_air = emission_factor * (chem_temp ** 4 - the_air.temperature ** 4)

			//Temperature assuming complete equalization.
				//If the air is simulated we consider the thermal mass of the air.
				//If the air is unsimulated we consider the air to have infinite thermal mass so the equalization temperature is the air temperature.
			var/Te = is_the_air_simulated ? (total_thermal_mass * chem_temp + air_thermal_mass * the_air.temperature) / (total_thermal_mass + air_thermal_mass) : the_air.temperature

			//If the reagents temperature would change by more than a factor of THERM_DISS_MAX_PER_TICK_TEMP_CHANGE_RATIO, we do a more granular calculation.
			var/slices = ceil((1 / THERM_DISS_MAX_PER_TICK_TEMP_CHANGE_RATIO) * abs(energy_to_radiate_from_reagents_to_air * reagents_thermal_mass_reciprocal / chem_temp))
			emission_factor /= slices

			#define REAGENTS_HOTTER 1
			#define AIR_HOTTER -1

			var/which_is_hotter = chem_temp > Te ? REAGENTS_HOTTER : AIR_HOTTER

			var/this_slice_energy
			var/Tr
			if (is_the_air_simulated)

				for (var/this_slice in 1 to min(slices, THERM_DISS_MAX_PER_TICK_SLICES))
					this_slice_energy = emission_factor * (chem_temp ** 4 - the_air.temperature ** 4)
					Tr = chem_temp - this_slice_energy / total_thermal_mass
					//If the discrete nature of the calculation would cause the reagents temperature to go past the equalization temperature, we equalize the temperatures.
					switch (which_is_hotter)
						if (REAGENTS_HOTTER)
							if (Tr < Te)
								chem_temp = Te
								the_air.temperature = Te
								break
						if (AIR_HOTTER)
							if (Tr > Te)
								chem_temp = Te
								the_air.temperature = Te
								break
					chem_temp -= the_air.add_thermal_energy_hc_known(this_slice_energy, TCMB, air_thermal_mass) * reagents_thermal_mass_reciprocal

			else
				for (var/this_slice in 1 to min(slices, THERM_DISS_MAX_PER_TICK_SLICES))
					this_slice_energy = emission_factor * (chem_temp ** 4 - the_air.temperature ** 4)
					Tr = chem_temp - this_slice_energy / total_thermal_mass
					//If the discrete nature of the calculation would cause the reagents temperature to go past the equalization temperature, we equalize the temperatures.
					switch (which_is_hotter)
						if (REAGENTS_HOTTER)
							if (Tr < Te)
								chem_temp = Te
								the_air.temperature = Te
								break
						if (AIR_HOTTER)
							if (Tr > Te)
								chem_temp = Te
								the_air.temperature = Te
								break
					chem_temp -= this_slice_energy * reagents_thermal_mass_reciprocal

			#undef REAGENTS_HOTTER
			#undef AIR_HOTTER

		else //At extreme temperatures, we do a simpler calculation to avoid blowing out any values.
			if (is_the_air_simulated) //For simmed air, we equalize the temperatures.
				var/Te = (total_thermal_mass * chem_temp + air_thermal_mass * the_air.temperature) / (total_thermal_mass + air_thermal_mass)
				chem_temp = Te
				the_air.temperature = Te
			else //For unsimmed, air, the reagents temperature is set to the average of the two temperatures.
				chem_temp = (1/2) * (chem_temp + the_air.temperature)

		if(skip_flags & SKIP_RXN_CHECK_ON_HEATING)
			return
		handle_reactions()

/client/proc/configThermDiss()
	set name = "Thermal Config"
	set category = "Debug"

	. = alert("Thermal dissipation:", , "Full", "Reagents Only", "Off")
	switch (.)
		if ("Full")
			config.thermal_dissipation = TRUE
			config.reagents_heat_air = TRUE
		if ("Reagents Only")
			config.thermal_dissipation = TRUE
			config.reagents_heat_air = FALSE
		if ("Off")
			config.thermal_dissipation = FALSE
			config.reagents_heat_air = FALSE

	log_admin("[key_name(usr)] set thermal dissipation to [.].")
	message_admins("[key_name(usr)] set thermal dissipation to [.].")