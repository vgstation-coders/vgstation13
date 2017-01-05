var/datum/subsystem/machinery/fast/SSfast_machinery

var/list/fast_machines = list()


/datum/subsystem/machinery/fast
	name = "Fast Machinery"
	wait = 0.7 SECONDS


/datum/subsystem/machinery/fast/New()
	NEW_SS_GLOBAL(SSfast_machinery)


/datum/subsystem/machinery/fast/get_currenrun()
	return fast_machines.Copy()
