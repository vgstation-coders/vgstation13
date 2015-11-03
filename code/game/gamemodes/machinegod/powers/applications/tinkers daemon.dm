/datum/clockcult_power/tinkers_daemon
	name				= "Tinker's Daemon"
	desc				= "Summons a daemon shell on a tile that produces tinkerer bits much faster than handheld slabs. When 25 sheets worth of metal is supplied, the daemon merges with it and works to automatically create a component every 30 seconds(45 if asked to make specific components). Constructed components will be transferred to the oldest cache with space, otherwise they will be left on the ground. Can dispense a free slab every 30 seconds. Daemons will refuse to work altogether if cultists do not outnumber them 5:1."
	category			= CLOCK_APPLICATIONS

	invocation			= "TODO"
	cast_time			= 4 SECONDS
	req_components		= list(CLOCK_REPLICANT = 3, CLOCK_HIEROPHANT = 1, CLOCK_GEIS = 1)
