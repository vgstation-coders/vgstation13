#define BAD_INIT_QDEL_BEFORE 1
#define BAD_INIT_DIDNT_INIT 2
#define BAD_INIT_SLEPT 4
#define BAD_INIT_NO_HINT 8

var/datum/subsystem/atoms/SSatoms

/datum/subsystem/atoms
	name          = "Atoms"
	display_order = SS_DISPLAY_ATOMS
	init_order    = SS_INIT_ATOMS
	flags         = SS_NO_FIRE

	var/old_initialized

	var/list/late_loaders
	var/list/created_atoms

	var/list/BadInitializeCalls = list()

/datum/subsystem/atoms/New()
	NEW_SS_GLOBAL(SSatoms)

/datum/subsystem/atoms/Initialize()
	initialized = INITIALIZATION_INNEW_MAPLOAD
	InitializeAtoms()
	..()

/datum/subsystem/atoms/stat_entry()
	..("Bad initialize calls: [BadInitializeCalls.len]")

/datum/subsystem/atoms/proc/InitializeAtoms(var/list/atoms)
	if(initialized == INITIALIZATION_INSSATOMS)
		return

	initialized = INITIALIZATION_INNEW_MAPLOAD

	if(!late_loaders)
		late_loaders = list()

	var/count
	var/list/mapload_arg = list(TRUE)
	if(atoms)
		created_atoms = list()
		count = atoms.len
		for(var/I in atoms)
			var/atom/A = I
			if(!(A.flags & INITIALIZED))
				if(InitAtom(I, mapload_arg))
					atoms -= I
				CHECK_TICK
	else
		count = 0
		for(var/atom/A in world)
			if(!(A.flags & INITIALIZED))
				InitAtom(A, mapload_arg)
				++count
				CHECK_TICK

	log_startup_progress("Initialized [count] atoms")

	initialized = INITIALIZATION_INNEW_REGULAR

	if(late_loaders.len)
		for(var/I in late_loaders)
			var/atom/A = I
			A.late_initialize()
		log_startup_progress("Late initialized [late_loaders.len] atoms")
		late_loaders.Cut()

	if(atoms)
		. = created_atoms + atoms
		created_atoms = null

/datum/subsystem/atoms/proc/InitAtom(var/atom/A, var/list/arguments)
	var/the_type = A.type
	if(A.gcDestroyed)
		BadInitializeCalls[the_type] |= BAD_INIT_QDEL_BEFORE
		return TRUE

	var/start_tick = world.time

	var/result = A.initialize(arglist(arguments))

	if(start_tick != world.time)
		BadInitializeCalls[the_type] |= BAD_INIT_SLEPT

	var/qdeleted = FALSE

	if(result != INITIALIZE_HINT_NORMAL)
		switch(result)
			if(INITIALIZE_HINT_LATELOAD)
				if(arguments[1])	//mapload
					late_loaders += A
				else
					A.late_initialize()
			if(INITIALIZE_HINT_QDEL)
				qdel(A)
				qdeleted = TRUE
			else
				BadInitializeCalls[the_type] |= BAD_INIT_NO_HINT

	if(!A)	//possible harddel
		qdeleted = TRUE
	else if(!(A.flags & INITIALIZED))
		BadInitializeCalls[the_type] |= BAD_INIT_DIDNT_INIT

	return qdeleted || A.gcDestroyed

/datum/subsystem/atoms/proc/map_loader_begin()
	old_initialized = initialized
	initialized = INITIALIZATION_INSSATOMS

/datum/subsystem/atoms/proc/map_loader_stop()
	initialized = old_initialized

/datum/subsystem/atoms/Recover()
	initialized = SSatoms.initialized
	if(initialized == INITIALIZATION_INNEW_MAPLOAD)
		InitializeAtoms()
	old_initialized = SSatoms.old_initialized
	BadInitializeCalls = SSatoms.BadInitializeCalls

/datum/subsystem/atoms/proc/WriteInitLog()
	. = ""
	for(var/path in BadInitializeCalls)
		. += "Path : [path] \n"
		var/fails = BadInitializeCalls[path]
		if(fails & BAD_INIT_DIDNT_INIT)
			. += "- Didn't call atom/Initialize()\n"
		if(fails & BAD_INIT_NO_HINT)
			. += "- Didn't return an Initialize hint\n"
		if(fails & BAD_INIT_QDEL_BEFORE)
			. += "- Qdel'd in New()\n"
		if(fails & BAD_INIT_SLEPT)
			. += "- Slept during Initialize()\n"
	if(.)
		world.log << .

/datum/subsystem/atoms/Shutdown()
	WriteInitLog()

#undef BAD_INIT_QDEL_BEFORE
#undef BAD_INIT_DIDNT_INIT
#undef BAD_INIT_SLEPT
#undef BAD_INIT_NO_HINT
