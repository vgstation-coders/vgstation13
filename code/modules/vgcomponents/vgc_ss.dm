var/datum/subsystem/circuits/SScircuit

var/list/datum/vgassemblies/vg_assemblies = list()

/datum/subsystem/circuits
	name          	= "Circuits"
	flags    		= SS_NO_INIT
	display_order 	= SS_DISPLAY_CIRCUIT
	priority      	= SS_PRIORITY_CIRCUIT
	wait          	= 0.5 SECONDS

	var/list/currentrun


/datum/subsystem/circuits/New()
	NEW_SS_GLOBAL(SScircuit)

/datum/subsystem/circuits/stat_entry()
	..("P:[vg_assemblies.len]")


/datum/subsystem/circuits/fire(resumed = FALSE)
	if (!resumed)
		currentrun = global.vg_assemblies.Copy()

	while (currentrun.len)
		var/datum/vgassembly/A = currentrun[currentrun.len]
		currentrun.len--

		if (!A || A.gcDestroyed || A.disposed || A.timestopped)
			continue

		A.fireOutputs()

		if (MC_TICK_CHECK)
			return