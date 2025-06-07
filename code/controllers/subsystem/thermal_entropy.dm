var/datum/subsystem/thermal_entropy/SSte
var/list/obj/item/weapon/reagent_containers/thermal_entropy_containers = list()

/datum/subsystem/thermal_entropy
	name          = "Thermal Entropy"
	wait          = SS_WAIT_THERM_ENTROPY
	flags         = SS_KEEP_TIMING
	priority      = SS_PRIORITY_THERM_ENTROPY
	display_order = SS_DISPLAY_THERM_ENTROPY

	var/list/obj/item/weapon/reagent_containers/currentrun = list()

/datum/subsystem/thermal_entropy/New()
	NEW_SS_GLOBAL(SSte)

/datum/subsystem/thermal_entropy/stat_entry()
	..("P:[thermal_entropy_containers.len]")

/datum/subsystem/thermal_entropy/fire(resumed = FALSE)
	if (!resumed)
		currentrun = thermal_entropy_containers.Copy()

	while (currentrun.len)
		var/obj/item/weapon/reagent_containers/RC = currentrun[currentrun.len]
		currentrun.len--

		if (!RC || RC.gcDestroyed || RC.timestopped)
			continue

		RC.thermal_entropy()

		if (MC_TICK_CHECK)
			return

////////////////////////////////////////////////////////////////////////////////////
var/datum/subsystem/thermal_entropy_rechecker/SSter
var/list/obj/item/weapon/reagent_containers/all_reagent_containers = list()

/datum/subsystem/thermal_entropy_rechecker
	name          = "Thermal Entropy Rechecker"
	wait          = SS_WAIT_THERM_ENTROPY_RECHECK
	flags         = SS_KEEP_TIMING
	priority      = SS_PRIORITY_THERM_ENTROPY_RECHECK
	display_order = SS_DISPLAY_THERM_ENTROPY_RECHECK

	var/list/obj/item/weapon/reagent_containers/currentrun = list()

/datum/subsystem/thermal_entropy_rechecker/New()
	NEW_SS_GLOBAL(SSter)

/datum/subsystem/thermal_entropy_rechecker/stat_entry()
	..("P:[all_reagent_containers.len]")

/datum/subsystem/thermal_entropy_rechecker/fire(resumed = FALSE)
	if (!resumed)
		currentrun = all_reagent_containers.Copy()

	while (currentrun.len)
		var/obj/item/weapon/reagent_containers/RC = currentrun[currentrun.len]
		currentrun.len--

		if (!RC || RC.gcDestroyed || RC.timestopped)
			continue

		RC.process_temperature()

		if (MC_TICK_CHECK)
			return
