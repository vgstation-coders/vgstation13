var/datum/subsystem/persistence_map/SSpersistence_map

/datum/subsystem/persistence_map
	name       = "Persistence - Map"
	init_order = SS_INIT_PERSISTENCE_MAP
	flags      = SS_NO_FIRE

	var/list/subdatums = list()
	var/finished = FALSE

	var/savingFilth = TRUE
	var/filthCreatedCount = 0


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

/datum/subsystem/persistence_map/proc/finish()
	if(finished)
		return
	var/watch = start_watch()
	for(var/name in subdatums)
		var/datum/map_persistence_type/T = subdatums[name]
		if(savingFilth)
			T.writeSavefile()
		else
			T.deleteSavefile()
	log_debug("[time_stamp()] - Map persistence finished in [stop_watch(watch)]s.")
	finished = TRUE

/datum/subsystem/persistence_map/proc/qdelAllFilth(var/whodunnit)
	for(var/name in subdatums)
		var/datum/map_persistence_type/T = subdatums[name]
		if(T.filth)
			T.qdelAllTrackedItems() //whodunnit var intentionally left blank
	if(whodunnit)
		log_admin("[key_name(whodunnit)] deleted all filth on the station!")
		message_admins("[key_name_admin(whodunnit)] deleted all filth on the station!")

/datum/subsystem/persistence_map/proc/setSavingFilth(var/_saving, var/whodunnit)
	savingFilth = _saving
	if(whodunnit)
		log_admin("PERSISTENCE: [key_name(usr)] [savingFilth == TRUE ? "enabled" : "disabled"] filth persistence for this round.")
		message_admins("PERSISTENCE: [key_name_admin(usr)] [savingFilth == TRUE ? "enabled" : "disabled"] filth persistence for this round.")
	else
		log_admin("PERSISTENCE: Filth persistence was automatically [savingFilth == TRUE ? "enabled" : "disabled"] for this round.")
		message_admins("PERSISTENCE: Filth persistence was automatically [savingFilth == TRUE ? "enabled" : "disabled"] for this round.")

/datum/subsystem/persistence_map/proc/bumpFilthCreatedCount()
	filthCreatedCount++
	if(filthCreatedCount % 100 == 0)
		for(var/obj/effect/landmark/xtra_cleanergrenades/xtra in landmarks_list)
			new /obj/item/weapon/grenade/chem_grenade/cleaner(get_turf(xtra))