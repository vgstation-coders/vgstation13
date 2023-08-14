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

	if (!resumed)
		currentrun_index = thermal_dissipation_reagents.len
		currentrun = thermal_dissipation_reagents.Copy()

	var/c = currentrun_index

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

	if (!(abs(chem_temp - the_air.temperature) >= MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)) //Do it this way to catch NaNs.
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

		var/Tr = chem_temp
		var/Ta = the_air.temperature

		if (max(Tr, Ta) <= THERM_DISS_MAX_SAFE_TEMP)

			var/reagents_thermal_mass_reciprocal = (1 / total_thermal_mass)
			var/air_thermal_mass_reciprocal = (1 / air_thermal_mass)

			//If either temperature would change by more than a factor of THERM_DISS_MAX_PER_TICK_TEMP_CHANGE_RATIO, we do a more granular calculation.
			var/slices = ceil((1 / THERM_DISS_MAX_PER_TICK_TEMP_CHANGE_RATIO) * abs(emission_factor * (Tr ** 4 - Ta ** 4) * max(reagents_thermal_mass_reciprocal / Tr, air_thermal_mass_reciprocal / Ta)))
			emission_factor /= slices

			#define REAGENTS_HOTTER 1
			#define AIR_HOTTER -1

			var/which_is_hotter = Tr > Ta ? REAGENTS_HOTTER : AIR_HOTTER
			var/this_slice_energy

			if (is_the_air_simulated)
				switch (which_is_hotter)
					if (REAGENTS_HOTTER)
						for (var/this_slice in 1 to min(slices, THERM_DISS_MAX_PER_TICK_SLICES))
							this_slice_energy = emission_factor * (Tr ** 4 - Ta ** 4)
							Tr -= this_slice_energy * reagents_thermal_mass_reciprocal
							Ta += this_slice_energy * air_thermal_mass_reciprocal
							//If the discrete nature of the calculation would cause the reagents temperature to go past the equalization temperature, we equalize the temperatures.
							if (!(Tr > Ta))
								goto temperature_equalization
					if (AIR_HOTTER)
						for (var/this_slice in 1 to min(slices, THERM_DISS_MAX_PER_TICK_SLICES))
							this_slice_energy = emission_factor * (Tr ** 4 - Ta ** 4)
							Tr -= this_slice_energy * reagents_thermal_mass_reciprocal
							Ta += this_slice_energy * air_thermal_mass_reciprocal
							if (!(Tr < Ta))
								goto temperature_equalization
			else
				switch (which_is_hotter)
					if (REAGENTS_HOTTER)
						for (var/this_slice in 1 to min(slices, THERM_DISS_MAX_PER_TICK_SLICES))
							this_slice_energy = emission_factor * (Tr ** 4 - Ta ** 4)
							Tr -= this_slice_energy * reagents_thermal_mass_reciprocal
							if (!(Tr > Ta))
								goto temperature_equalization
					if (AIR_HOTTER)
						for (var/this_slice in 1 to min(slices, THERM_DISS_MAX_PER_TICK_SLICES))
							this_slice_energy = emission_factor * (Tr ** 4 - Ta ** 4)
							Tr -= this_slice_energy * reagents_thermal_mass_reciprocal
							if (!(Tr < Ta))
								goto temperature_equalization

			#undef REAGENTS_HOTTER
			#undef AIR_HOTTER

			the_air.temperature = Ta
			chem_temp = Tr
			goto reactions_check

		else //At extreme temperatures, we do a simpler calculation to avoid blowing out any values.
			if (is_the_air_simulated) //For simmed air, we equalize the temperatures.
				goto temperature_equalization
			else //For unsimmed, air, the reagents temperature is set to the average of the two temperatures.
				chem_temp = (1/2) * Tr + (1/2) * Ta

		goto reactions_check

		temperature_equalization
		//Temperature assuming complete equalization.
			//If the air is simulated we consider the thermal mass of the air.
			//If the air is unsimulated we consider the air to have infinite thermal mass so the equalization temperature is the air temperature.
		var/Te = is_the_air_simulated ? (total_thermal_mass * chem_temp + air_thermal_mass * the_air.temperature) / (total_thermal_mass + air_thermal_mass) : the_air.temperature //Use the original values in case something went wrong.
		chem_temp = Te
		the_air.temperature = Te

		reactions_check
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