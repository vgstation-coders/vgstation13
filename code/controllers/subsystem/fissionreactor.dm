var/datum/subsystem/fissionreactors/SSfission

var/list/global/fissionreactorlist=list()

/datum/subsystem/fissionreactors
	name          = "Fission_reactors"
	display_order = SS_DISPLAY_FISSION
	priority      = SS_PRIORITY_FISSION
	wait          = 1 SECONDS

	//var/list/currentrun
	//var/list/bad_inits = list()

/datum/subsystem/fissionreactors/New()
	NEW_SS_GLOBAL(SSfission)

/datum/subsystem/fissionreactors/fire(resumed = FALSE)
	for(var/datum/fission_reactor_holder/reactor in fissionreactorlist)
		reactor.fissioncycle()
		reactor.coolantcycle()
		reactor.misccycle()