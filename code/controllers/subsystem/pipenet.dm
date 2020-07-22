var/datum/subsystem/pipenet/SSpipenet

var/list/obj/machinery/atmospherics/atmos_machines = list()
var/list/datum/pipe_network/pipe_networks = list()
var/list/pipenet_processing_objects = list()

/datum/proc/pipenet_process()
	set waitfor = FALSE

/datum/subsystem/pipenet
	name          = "Pipenet"
	wait          = 2 SECONDS
	display_order = SS_DISPLAY_PIPENET
	priority      = SS_PRIORITY_PIPENET
	init_order    = SS_INIT_PIPENET

	var/list/currentrun_atmos_machines
	var/list/currentrun_pipenets


/datum/subsystem/pipenet/New()
	NEW_SS_GLOBAL(SSpipenet)


/datum/subsystem/pipenet/stat_entry()
	..("PN:[pipe_networks.len]|AM:[atmos_machines.len]")


/datum/subsystem/pipenet/Initialize()
	for (var/obj/machinery/atmospherics/machine in atmos_machines)
		machine.build_network()

		if (istype(machine, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = machine
			T.broadcast_status()

		else if (istype(machine, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = machine
			T.broadcast_status()

	..()

/datum/subsystem/pipenet/fire(resumed = FALSE)
	if (!resumed)
		currentrun_pipenets       = global.pipe_networks.Copy()
		currentrun_atmos_machines = global.atmos_machines.Copy()
		for(var/datum/thing in pipenet_processing_objects)
			thing.pipenet_process()

	while (currentrun_atmos_machines.len)
		var/obj/machinery/atmospherics/atmosmachinery = currentrun_atmos_machines[currentrun_atmos_machines.len]
		currentrun_atmos_machines.len--

		if (!atmosmachinery || atmosmachinery.gcDestroyed || atmosmachinery.timestopped)
			continue

		if (atmosmachinery.process() && MC_TICK_CHECK)
			return

		if (atmosmachinery.use_power)
			atmosmachinery.auto_use_power()

	while (currentrun_pipenets.len)
		var/datum/pipe_network/pipeNetwork = currentrun_pipenets[currentrun_pipenets.len]
		currentrun_pipenets.len--

		if (!pipeNetwork || pipeNetwork.gcDestroyed)
			continue

		pipeNetwork.process()

		if (MC_TICK_CHECK)
			return
