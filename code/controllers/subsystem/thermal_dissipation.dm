var/datum/subsystem/thermal_dissipation/SStd
var/list/thermal_dissipation_atoms = list()

/datum/subsystem/thermal_dissipation
	name          = "Thermal Dissipation"
	wait          = SS_WAIT_THERM_DISS
	flags         = SS_KEEP_TIMING
	priority      = SS_PRIORITY_THERM_DISS
	display_order = SS_DISPLAY_THERM_DISS
	var/list/currentrun

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
		var/atom/A = currentrun[currentrun.len]
		currentrun.len--

		if (!A || A.gcDestroyed || A.timestopped)
			continue

		A.handle_thermal_dissipation()

		if (MC_TICK_CHECK)
			return