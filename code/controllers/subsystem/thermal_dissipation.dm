var/datum/subsystem/thermal_dissipation/SStd
var/list/datum/reagents/thermal_dissipation_reagents = list()

/datum/subsystem/thermal_dissipation
	name          = "Thermal Dissipation"
	wait          = SS_WAIT_THERM_DISS
	flags         = SS_KEEP_TIMING
	priority      = SS_PRIORITY_THERM_DISS
	display_order = SS_DISPLAY_THERM_DISS

	var/list/datum/reagents/currentrun
	var/list/turf_air_list
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
		var/turf_air_list = list()

		//Variables to reuse
		var/datum/reagents/R
		var/turf/T
		var/datum/gas_mixture/the_air
		var/emission_factor
		var/atom/this_potentially_insulative_layer
		var/i
		var/is_the_air_simulated
		var/air_thermal_mass
		var/Tr
		var/Ta
		var/reagents_thermal_mass_reciprocal
		var/air_thermal_mass_reciprocal
		var/which_is_hotter
		var/slices
		var/this_slice_energy
		var/this_slice

		while (c)

			R = currentrun[c]
			c--

			if(!R)
				continue

			//Exchange heat between reagents and the surrounding air.
			//Although the heat is exchanged directly between reagents and air, for now this is based on thermal radiation, not convection per se.

			if(gcDestroyed)
				continue

			if (!R.my_atom || R.my_atom.gcDestroyed || R.my_atom.timestopped)
				continue

			if (!R.total_volume || !R.total_thermal_mass)
				continue

			T = get_turf(R.my_atom)
			the_air = turf_air_list[T]
			if(!the_air)
				the_air = T?.return_air()
				turf_air_list[T] = the_air
			if (!the_air)
				continue

			if (!(abs(R.chem_temp - the_air.temperature) >= MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)) //Do it this way to catch NaNs.
				continue

			//We treat the reagents like a spherical grey body with an emissivity of THERM_DISS_SCALING_FACTOR.

			emission_factor = THERM_DISS_SCALING_FACTOR * (SS_WAIT_THERM_DISS / (1 SECONDS)) * STEFAN_BOLTZMANN_CONSTANT * (36 * PI) ** (1/3) * (CC_PER_U / 1000) ** (2/3) * R.total_volume ** (2/3)

			//Here we reduce thermal transfer to account for insulation of the container.
			//We iterate though each loc until the loc is the turf containing the_air, to account for things like nested containers, each time multiplying emission_factor by a factor than can range between [0 and 1], representing heat insulation.

			this_potentially_insulative_layer = R.my_atom
			i = 0
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
					log_admin("Something went wrong with [R.my_atom]'s handle_heat_dissipation() at iteration #[i] at [this_potentially_insulative_layer].")
					break //Avoid infinite loops.

			if (emission_factor)

				is_the_air_simulated = simulate_air && !istype(the_air, /datum/gas_mixture/unsimulated)
				air_thermal_mass = the_air.heat_capacity()

				Tr = R.chem_temp
				Ta = the_air.temperature

				if (max(Tr, Ta) <= THERM_DISS_MAX_SAFE_TEMP)

					reagents_thermal_mass_reciprocal = (1 / R.total_thermal_mass)
					air_thermal_mass_reciprocal = (1 / air_thermal_mass)

					#define REAGENTS_HOTTER 1
					#define AIR_HOTTER -1

					which_is_hotter = Tr > Ta ? REAGENTS_HOTTER : AIR_HOTTER

					if (is_the_air_simulated)
						//If either temperature would change by more than a factor of THERM_DISS_MAX_PER_TICK_TEMP_CHANGE_RATIO, we do a more granular calculation.
						slices = ceil((1 / THERM_DISS_MAX_PER_TICK_TEMP_CHANGE_RATIO) * abs(emission_factor * (Tr ** 4 - Ta ** 4) * max(reagents_thermal_mass_reciprocal / Tr, air_thermal_mass_reciprocal / Ta)))
						emission_factor /= slices
						switch (which_is_hotter)
							if (REAGENTS_HOTTER)
								for (this_slice in 1 to min(slices, THERM_DISS_MAX_PER_TICK_SLICES))
									this_slice_energy = emission_factor * (Tr ** 4 - Ta ** 4)
									Tr -= this_slice_energy * reagents_thermal_mass_reciprocal
									Ta += this_slice_energy * air_thermal_mass_reciprocal
									//If the discrete nature of the calculation would cause the reagents temperature to go past the equalization temperature, we equalize the temperatures.
									if (!(Tr > Ta))
										goto temperature_equalization_simmed_air
							if (AIR_HOTTER)
								for (this_slice in 1 to min(slices, THERM_DISS_MAX_PER_TICK_SLICES))
									this_slice_energy = emission_factor * (Tr ** 4 - Ta ** 4)
									Tr -= this_slice_energy * reagents_thermal_mass_reciprocal
									Ta += this_slice_energy * air_thermal_mass_reciprocal
									if (!(Tr < Ta))
										goto temperature_equalization_simmed_air
					else
						slices = ceil((1 / THERM_DISS_MAX_PER_TICK_TEMP_CHANGE_RATIO) * abs(emission_factor * (Tr ** 4 - Ta ** 4) * reagents_thermal_mass_reciprocal / Tr))
						emission_factor /= slices
						switch (which_is_hotter)
							if (REAGENTS_HOTTER)
								for (this_slice in 1 to min(slices, THERM_DISS_MAX_PER_TICK_SLICES))
									Tr -= emission_factor * (Tr ** 4 - Ta ** 4) * reagents_thermal_mass_reciprocal
									if (!(Tr > Ta))
										goto temperature_equalization_unsimmed_air
							if (AIR_HOTTER)
								for (this_slice in 1 to min(slices, THERM_DISS_MAX_PER_TICK_SLICES))
									Tr -= emission_factor * (Tr ** 4 - Ta ** 4) * reagents_thermal_mass_reciprocal
									if (!(Tr < Ta))
										goto temperature_equalization_unsimmed_air

					#undef REAGENTS_HOTTER
					#undef AIR_HOTTER

					the_air.temperature = Ta
					R.chem_temp = Tr

				else //At extreme temperatures, we do a simpler calculation to avoid blowing out any values.
					if (is_the_air_simulated) //For simmed air, we equalize the temperatures.
						goto temperature_equalization_simmed_air
					else //For unsimmed, air, the reagents temperature is set to the average of the two temperatures.
						R.chem_temp = (1/2) * Tr + (1/2) * Ta

				goto reactions_check

				temperature_equalization_unsimmed_air:
				//If the air is unsimulated we consider the air to have infinite thermal mass so the equalization temperature is the air temperature.
				R.chem_temp = the_air.temperature

				goto reactions_check

				temperature_equalization_simmed_air:
				//If the air is simulated we consider the thermal mass of the air.
				R.chem_temp = (R.total_thermal_mass * R.chem_temp + air_thermal_mass * the_air.temperature) / (R.total_thermal_mass + air_thermal_mass) //Use the original values in case something went wrong.
				the_air.temperature = R.chem_temp

				reactions_check:
				if(!(R.skip_flags & SKIP_RXN_CHECK_ON_HEATING))
					R.handle_reactions()

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
