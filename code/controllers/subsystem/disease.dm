var/datum/subsystem/disease/SSdisease

var/list/active_diseases = list()


/datum/subsystem/disease
	name = "Disease"
	wait = 2 SECONDS
	flags = SS_NO_INIT

	var/list/currentrun

/datum/subsystem/disease/New()
	NEW_SS_GLOBAL(SSdisease)


/datum/subsystem/disease/fire(resumed = FALSE)
	if (!resumed)
		currentrun = active_diseases.Copy()

	while (currentrun.len)
		var/datum/disease/D = currentrun[currentrun.len]
		currentrun.len--

		if (!D || D.gcDestroyed || D.disposed)
			continue

		D.process()

		if (MC_TICK_CHECK)
			return
