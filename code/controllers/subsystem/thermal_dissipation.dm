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

	//Keep all of these here to avoid having to redeclare them for every datum/reagents on every tick.
	var/datum/reagents/R
	var/datum/gas_mixture/the_air
	var/atom/A
	var/emission_factor
	var/atom/this_potentially_insulative_layer
	var/i
	var/is_the_air_simulated
	var/air_thermal_mass
	var/reagents_thermal_mass_reciprocal
	var/energy_to_radiate_from_reagents_to_air
	var/Te
	var/slices
	var/this_slice_energy
	var/Tr
	var/which_is_hotter
	var/this_slice
	var/c

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
		if (currentrun_index)
			currentrun.len = currentrun_index
			for(c in 1 to currentrun_index)
				currentrun[c] = thermal_dissipation_reagents[c]

	while (currentrun_index)
		R = currentrun[currentrun_index]
		currentrun_index--

		if (config.thermal_dissipation)
			A = R?.my_atom
			if (A && !A.gcDestroyed && !A.timestopped)
				the_air = (get_turf(A))?.return_air()
				if (the_air)
					handle_thermal_dissipation()

		if (MC_TICK_CHECK)
			return

/datum/subsystem/thermal_dissipation/proc/handle_thermal_dissipation()
	//Exchange heat between reagents and the surrounding air.
	//Although the heat is exchanged directly between reagents and air, for now this is based on thermal radiation, not convection per se.
	if (!R.total_volume || !R.total_thermal_mass)
		return

	if (R.chem_temp < TCMB)
		R.chem_temp = TCMB

	if (abs(R.chem_temp - the_air.temperature) < MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		return

	//We treat the reagents like a spherical grey body with an emissivity of THERM_DISS_SCALING_FACTOR.

	emission_factor = THERM_DISS_SCALING_FACTOR * (SS_WAIT_THERM_DISS / (1 SECONDS)) * STEFAN_BOLTZMANN_CONSTANT * (36 * PI) ** (1/3) * (CC_PER_U / 1000) ** (2/3) * R.total_volume ** (2/3)

	//Here we reduce thermal transfer to account for insulation of the container.
	//We iterate though each loc until the loc is the turf containing the_air, to account for things like nested containers, each time multiplying emission_factor by a factor than can range between [0 and 1], representing heat insulation.

	this_potentially_insulative_layer = A
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
			message_admins("Something went wrong with [A]'s handle_heat_dissipation() at iteration #[i] at [this_potentially_insulative_layer].")
			break //Avoid infinite loops.

	if (emission_factor)

		is_the_air_simulated = config.reagents_heat_air && !istype(the_air, /datum/gas_mixture/unsimulated)
		air_thermal_mass = the_air.heat_capacity()

		if (max(R.chem_temp, the_air.temperature) <= THERM_DISS_MAX_SAFE_TEMP)

			reagents_thermal_mass_reciprocal = (1 / R.total_thermal_mass)

			energy_to_radiate_from_reagents_to_air = emission_factor * (R.chem_temp ** 4 - the_air.temperature ** 4)

			//Temperature assuming complete equalization.
				//If the air is simulated we consider the thermal mass of the air.
				//If the air is unsimulated we consider the air to have infinite thermal mass so the equalization temperature is the air temperature.
			Te = is_the_air_simulated ? (R.total_thermal_mass * R.chem_temp + air_thermal_mass * the_air.temperature) / (R.total_thermal_mass + air_thermal_mass) : the_air.temperature

			//If the reagents temperature would change by more than a factor of THERM_DISS_MAX_PER_TICK_TEMP_CHANGE_RATIO, we do a more granular calculation.
			slices = ceil((1 / THERM_DISS_MAX_PER_TICK_TEMP_CHANGE_RATIO) * abs(energy_to_radiate_from_reagents_to_air * reagents_thermal_mass_reciprocal / R.chem_temp))
			emission_factor /= slices

			#define REAGENTS_HOTTER 1
			#define AIR_HOTTER -1

			which_is_hotter = R.chem_temp > Te ? REAGENTS_HOTTER : AIR_HOTTER

			if (is_the_air_simulated)

				for (this_slice in 1 to min(slices, THERM_DISS_MAX_PER_TICK_SLICES))
					this_slice_energy = emission_factor * (R.chem_temp ** 4 - the_air.temperature ** 4)
					Tr = R.chem_temp - this_slice_energy / R.total_thermal_mass
					//If the discrete nature of the calculation would cause the reagents temperature to go past the equalization temperature, we equalize the temperatures.
					switch (which_is_hotter)
						if (REAGENTS_HOTTER)
							if (Tr < Te)
								R.chem_temp = Te
								the_air.temperature = Te
								break
						if (AIR_HOTTER)
							if (Tr > Te)
								R.chem_temp = Te
								the_air.temperature = Te
								break
					R.chem_temp -= the_air.add_thermal_energy_hc_known(this_slice_energy, TCMB, air_thermal_mass) * reagents_thermal_mass_reciprocal

			else
				for (this_slice in 1 to min(slices, THERM_DISS_MAX_PER_TICK_SLICES))
					this_slice_energy = emission_factor * (R.chem_temp ** 4 - the_air.temperature ** 4)
					Tr = R.chem_temp - this_slice_energy / R.total_thermal_mass
					//If the discrete nature of the calculation would cause the reagents temperature to go past the equalization temperature, we equalize the temperatures.
					switch (which_is_hotter)
						if (REAGENTS_HOTTER)
							if (Tr < Te)
								R.chem_temp = Te
								the_air.temperature = Te
								break
						if (AIR_HOTTER)
							if (Tr > Te)
								R.chem_temp = Te
								the_air.temperature = Te
								break
					R.chem_temp -= this_slice_energy * reagents_thermal_mass_reciprocal

			#undef REAGENTS_HOTTER
			#undef AIR_HOTTER

		else //At extreme temperatures, we do a simpler calculation to avoid blowing out any values.
			if (is_the_air_simulated) //For simmed air, we equalize the temperatures.
				Te = (R.total_thermal_mass * R.chem_temp + air_thermal_mass * the_air.temperature) / (R.total_thermal_mass + air_thermal_mass)
				R.chem_temp = Te
				the_air.temperature = Te
			else //For unsimmed, air, the reagents temperature is set to the average of the two temperatures.
				R.chem_temp = (1/2) * (R.chem_temp + the_air.temperature)

		if(R.skip_flags & SKIP_RXN_CHECK_ON_HEATING)
			return
		R.handle_reactions()

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