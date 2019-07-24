var/datum/subsystem/power/SSpower

var/list/power_machines = list() //kept this cause alot of stuff relies on this apparently
var/list/datum/net/power/powernets = list() //Holds all powernet datums in use or pooled
var/list/datum/net_node/power/cable/cable_nodes = list() //all /datum/net_node/power/cable


/datum/subsystem/power
	name          = "Power"
	init_order    = SS_INIT_POWER
	display_order = SS_DISPLAY_POWER
	priority      = SS_PRIORITY_POWER
	wait          = 2 SECONDS

	var/list/currentrun_powerents


/datum/subsystem/power/New()
	NEW_SS_GLOBAL(SSpower)


/datum/subsystem/power/stat_entry()
	..("C:[cable_nodes.len]|PN:[powernets.len]")


/datum/subsystem/power/Initialize(timeofday)
	makepowernets()
	..()


/datum/subsystem/power/fire(resumed = FALSE)
	if (!resumed)
		currentrun_powerents      = global.powernets.Copy()

	while (currentrun_powerents.len)
		var/datum/net/power/net = currentrun_powerents[currentrun_powerents.len]
		currentrun_powerents.len--
		if (!net || net.disposed)
			continue

		net.powertick()
		if (MC_TICK_CHECK)
			return
