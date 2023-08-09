var/datum/subsystem/thermal_dissipation/SStd
var/list/thermal_dissipation_atoms = list()

/datum/subsystem/thermal_dissipation
	name          = "Thermal Dissipation"
	wait          = SS_WAIT_THERM_DISS
	flags         = SS_KEEP_TIMING
	priority      = SS_PRIORITY_THERM_DISS
	display_order = SS_DISPLAY_THERM_DISS

	var/list/currentrun
	var/atom/A //The atom currently being processed by the subsystem.

/datum/subsystem/thermal_dissipation/New()
	NEW_SS_GLOBAL(SStd)

/datum/subsystem/thermal_dissipation/stat_entry(var/msg)
	if (msg)
		return ..()
	..("M:[thermal_dissipation_atoms.len]")

/datum/subsystem/thermal_dissipation/stat_entry()
	..("P:[thermal_dissipation_atoms.len]")

/datum/subsystem/thermal_dissipation/fire(var/resumed = FALSE)

	if (!resumed)

		currentrun = thermal_dissipation_atoms.Copy()

	while (currentrun.len)
		A = currentrun[currentrun.len]
		currentrun.len--

		if (config.thermal_dissipation && A && !A.gcDestroyed && !A.timestopped)
			A.handle_thermal_dissipation()

		if (MC_TICK_CHECK)
			return

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