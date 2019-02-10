var/datum/subsystem/persistence_map/SSpersistence_map

/datum/subsystem/persistence_map
	name       = "Persistence - Map"
	init_order = SS_INIT_PERSISTENCE_MAP
	flags      = SS_NO_FIRE

	var/list/subdatums = list()
	var/finished = FALSE


/datum/subsystem/persistence_map/New()
	NEW_SS_GLOBAL(SSpersistence_map)

///datum/subsystem/persistence_map/Recover() //What would this even be?

/datum/subsystem/persistence_map/proc/track(var/atom/A, var/typename)
	var/datum/map_persistence_type/T = subdatums[typename]
	if(T)
		T.track(A)

/datum/subsystem/persistence_map/proc/forget(var/atom/A, var/typename)
	var/datum/map_persistence_type/T = subdatums[typename]
	if(T)
		T.forget(A)

/datum/subsystem/persistence_map/Initialize(timeofday)
	..()
	for(var/i in subtypesof(/datum/map_persistence_type))
		var/datum/map_persistence_type/T = new i
		subdatums[T.name] = T
		T.readSavefile()

/datum/subsystem/persistence_map/Shutdown()
	if(!finished)
		finish()
	..()

/datum/subsystem/persistence_map/proc/onRoundEnd()
	if(!finished)
		finish()
	..()

/datum/subsystem/persistence_map/proc/finish()
	if(finished)
		return
	var/watch = start_watch()
	for(var/name in subdatums)
		var/datum/map_persistence_type/T = subdatums[name]
		T.writeSavefile()
	log_debug("[time_stamp()] - Map persistence saved in [stop_watch(watch)]s.")
	finished = TRUE
