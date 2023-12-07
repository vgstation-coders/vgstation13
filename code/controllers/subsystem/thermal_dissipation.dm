var/datum/subsystem/thermal_dissipation/SStd
var/list/datum/reagents/thermal_dissipation_reagents = list()

/datum/subsystem/thermal_dissipation
	name          = "Thermal Dissipation"
	wait          = SS_WAIT_THERM_DISS
	flags         = SS_KEEP_TIMING
	priority      = SS_PRIORITY_THERM_DISS
	display_order = SS_DISPLAY_THERM_DISS

	var/list/datum/reagents/currentrun
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
		var/list/turf_air_list = list()
		var/list/turf_temp_list = list()

		//Variables to reuse
		var/datum/reagents/R
		var/turf/T
		var/datum/gas_mixture/the_air
		var/emission_factor
		var/atom/this_potentially_insulative_layer
		var/i
		var/air_thermal_mass
		var/Tr
		var/Ta
		var/reagents_thermal_mass_reciprocal
		var/air_thermal_mass_reciprocal
		var/slices
		var/this_slice_energy

		while (c)

			R = currentrun[c]
			c--

			if(!R)
				goto tick_check

			//Exchange heat between reagents and the surrounding air.
			//Although the heat is exchanged directly between reagents and air, for now this is based on thermal radiation, not convection per se.

			if (!(T = get_turf(R.my_atom)))
				goto tick_check

			if (!(abs((Ta := (turf_temp_list[T] ||= T.air_temperature())) - R.chem_temp) >= MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER))  //Do it this way to catch NaNs.
				goto tick_check

			if (!R.total_volume || !R.total_thermal_mass || R.gcDestroyed || R.my_atom.gcDestroyed || R.my_atom.timestopped)
				goto tick_check

			//We treat the reagents like a spherical grey body with an emissivity of THERM_DISS_SCALING_FACTOR.

			emission_factor = THERM_DISS_SCALING_FACTOR * (SS_WAIT_THERM_DISS / (1 SECONDS)) * STEFAN_BOLTZMANN_CONSTANT * (36 * PI) ** (1/3) * (CC_PER_U / 1000) ** (2/3) * R.total_volume ** (2/3)

			//Here we reduce thermal transfer to account for insulation of the container.
			//We iterate though each loc until the loc is the turf T, to account for things like nested containers, each time multiplying emission_factor by a factor than can range between [0 and 1], representing heat insulation.

			this_potentially_insulative_layer = R.my_atom
			i = ARBITRARILY_LARGE_NUMBER
			while (emission_factor)
				emission_factor *= this_potentially_insulative_layer.get_heat_conductivity()
				if (this_potentially_insulative_layer == T)
					break
				else if (i && (this_potentially_insulative_layer := this_potentially_insulative_layer.loc))
					i--
				else
					log_admin("Something went wrong with [R.my_atom]'s handle_heat_dissipation() at iteration #[i] at [this_potentially_insulative_layer].")
					break //Avoid infinite loops and nullspace issues.

			if (emission_factor)

				Tr = R.chem_temp

				if (max(Tr, Ta) <= THERM_DISS_MAX_SAFE_TEMP)

					reagents_thermal_mass_reciprocal = (1 / R.total_thermal_mass)

					if (simulate_air && !istype(the_air := (turf_air_list[T] ||= T.return_air()), /datum/gas_mixture/unsimulated))
						if(!the_air)
							goto tick_check
						air_thermal_mass = the_air.heat_capacity()
						air_thermal_mass_reciprocal = (1 / air_thermal_mass)
						//If either temperature would change by more than a factor of THERM_DISS_MAX_PER_TICK_TEMP_CHANGE_RATIO, we do a more granular calculation.
						emission_factor /= (slices = ceil((1 / THERM_DISS_MAX_PER_TICK_TEMP_CHANGE_RATIO) * abs(emission_factor * (Tr ** 4 - Ta ** 4) * max(reagents_thermal_mass_reciprocal / Tr, air_thermal_mass_reciprocal / Ta))))
						if (Tr > Ta)
							for (slices = min(slices, THERM_DISS_MAX_PER_TICK_SLICES), slices, slices--)
								this_slice_energy = emission_factor * (Tr ** 4 - Ta ** 4)
								Tr -= this_slice_energy * reagents_thermal_mass_reciprocal
								Ta += this_slice_energy * air_thermal_mass_reciprocal
								//If the discrete nature of the calculation would cause the reagents temperature to go past the equalization temperature, we equalize the temperatures.
								if (!(Tr > Ta))
									goto temperature_equalization_simmed_air
						else
							for (slices = min(slices, THERM_DISS_MAX_PER_TICK_SLICES), slices, slices--)
								this_slice_energy = emission_factor * (Tr ** 4 - Ta ** 4)
								Tr -= this_slice_energy * reagents_thermal_mass_reciprocal
								Ta += this_slice_energy * air_thermal_mass_reciprocal
								if (!(Tr < Ta))
									goto temperature_equalization_simmed_air
						the_air.temperature = Ta
					else
						emission_factor /= (slices = ceil((1 / THERM_DISS_MAX_PER_TICK_TEMP_CHANGE_RATIO) * abs(emission_factor * (Tr ** 4 - Ta ** 4) * reagents_thermal_mass_reciprocal / Tr)))
						if (Tr > Ta)
							for (slices = min(slices, THERM_DISS_MAX_PER_TICK_SLICES), slices, slices--)
								Tr -= emission_factor * (Tr ** 4 - Ta ** 4) * reagents_thermal_mass_reciprocal
								if (!(Tr > Ta))
									goto temperature_equalization_unsimmed_air
						else
							for (slices = min(slices, THERM_DISS_MAX_PER_TICK_SLICES), slices, slices--)
								Tr -= emission_factor * (Tr ** 4 - Ta ** 4) * reagents_thermal_mass_reciprocal
								if (!(Tr < Ta))
									goto temperature_equalization_unsimmed_air

					R.chem_temp = Tr

				else //At extreme temperatures, we do a simpler calculation to avoid blowing out any values.
					if (simulate_air && !istype(the_air := (turf_air_list[T] ||= T.return_air()), /datum/gas_mixture/unsimulated)) //For simmed air, we equalize the temperatures.
						if (!the_air)
							goto tick_check
						air_thermal_mass = the_air.heat_capacity()
						goto temperature_equalization_simmed_air
					else //For unsimmed, air, the reagents temperature is set to the average of the two temperatures.
						R.chem_temp = (1/2) * Tr + (1/2) * Ta

				goto reactions_check

				temperature_equalization_unsimmed_air:
				//If the air is unsimulated we consider the air to have infinite thermal mass so the equalization temperature is the air temperature.
				R.chem_temp = Ta

				goto reactions_check

				temperature_equalization_simmed_air:
				//If the air is simulated we consider the thermal mass of the air.
				the_air.temperature = (R.chem_temp := (R.total_thermal_mass * R.chem_temp + air_thermal_mass * Ta) / (R.total_thermal_mass + air_thermal_mass))

				reactions_check:
				if(!(R.skip_flags & SKIP_RXN_CHECK_ON_HEATING))
					R.handle_reactions()

			tick_check:
			if (MC_TICK_CHECK)
				break

	currentrun_index = c

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
