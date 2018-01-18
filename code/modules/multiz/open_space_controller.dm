//
// Controller handling icon updates of open space turfs
//

//var/global/open_space_initialised = FALSE not necessary, we have initialized as a var
/var/global/datum/subsystem/open_space/OS_controller = null
/var/global/image/over_OS_darkness = image('icons/turf/open_space.dmi', "black_open")

/datum/subsystem/open_space
	name          = "openspace"
	init_order    = SS_INIT_OS //27. Must be before map (20)
	priority      = SS_PRIORITY_OS //Between power and objects, 99
	wait          = 1 SECONDS //originally world.tick_lag
	//No display order, we have no interesting info
	var/list/turfs_to_process = list()		// List of turfs queued for update.
	var/list/turfs_to_process_old = null	// List of turfs currently being updated.
	var/tmp/last_object //Polaris has this. Almost certainly used because their processing datums have automatic crash logging.

/*
/datum/controller/process/open_space/New()
	//. = ..()
	name = "openspace"
	schedule_interval = world.tick_lag // every second
	start_delay = 30 SECONDS
	OS_controller = src
	over_OS_darkness.plane = OVER_OPENSPACE_PLANE
	over_OS_darkness.layer = MOB_LAYER
	initialize_open_space()

	// Pre-process open space once once before the round starts. Wait 20 seconds so other stuff has time to finish.
	spawn(200)
		doWork(1)*/

/*/datum/controller/process/open_space/copyStateFrom(var/datum/controller/process/open_space/other)
	. = ..()
	OS_controller = src*/

/datum/subsystem/open_space/fire(resumed = FALSE)
	// We use a different list so any additions to the update lists during a delay from scheck()
	// don't cause things to be cut from the list without being updated.
	if(!resumed)
		turfs_to_process_old = turfs_to_process
	turfs_to_process = list()

	for(last_object in turfs_to_process_old)
		var/turf/T = last_object
		if(!T) //Polaris uses QDELETED for this, see comment in helpers
			update_turf(T)

		//if(TICK_USAGE >= next_sleep_usage) defer() This is part of a feature Polaris has where the process datum will pause itself if tick usage is over a threshold - our subsystems can do something similar. We won't worry about it though.

/datum/subsystem/open_space/proc/update_turf(var/turf/T)
	for(var/atom/movable/A in T)
		A.fall()
	T.update_icon()

/datum/subsystem/open_space/proc/add_turf(var/turf/T, var/recursive = 0)
	ASSERT(isturf(T))
	turfs_to_process += T
	if(recursive > 0)
		var/turf/above = GetAbove(T)
		if(above && isopenspace(above))
			add_turf(above, recursive)

// Do the initial updates of open space turfs when the game starts. This will lag!
//This was previously proc/initialize_open_space(), but it made more sense to convert it to Initialize()
/datum/subsystem/open_space/Initialize(timeofday)
	if(!map.multiz)
		to_chat(world, "<span class='danger'>Multi-Z was aborted due to lack of multiz on this map!</span>")
		return
	// Do initial setup from bottom to top.
	for(var/zlevel = 1 to world.maxz)
		for(var/turf/simulated/open/T in block(locate(1, 1, zlevel), locate(world.maxx, world.maxy, zlevel)))
			add_turf(T)
	..()

/turf/simulated/open/initialize()
	. = ..()
	if(OS_controller && OS_controller.initialized)
		// log_debug("[src] ([x],[y],[z]) queued for update for initialize()")
		OS_controller.add_turf(src)

/turf/Entered(atom/movable/AM)
	. = ..()
	if(OS_controller && OS_controller.initialized && !AM.invisibility && isobj(AM))
		var/turf/T = GetAbove(src)
		if(isopenspace(T))
			// log_debug("[T] ([T.x],[T.y],[T.z]) queued for update for [src].Entered([AM])")
			OS_controller.add_turf(T, 1)

/turf/Exited(atom/movable/AM)
	. = ..()
	if(OS_controller && OS_controller.initialized && !AM.invisibility && isobj(AM))
		var/turf/T = GetAbove(src)
		if(isopenspace(T))
			// log_debug("[T] ([T.x],[T.y],[T.z]) queued for update for [src].Exited([AM])")
			OS_controller.add_turf(T, 1)

/obj/update_icon()
	. = ..()
	if(OS_controller && OS_controller.initialized && !invisibility && isturf(loc))
		var/turf/T = GetAbove(src)
		if(isopenspace(T))
			// log_debug("[T] ([T.x],[T.y],[T.z]) queued for update for [src].update_icon()")
			OS_controller.add_turf(T, 1)

// Ouch... this is painful. But is there any other way?
/* - No for now
/obj/New()
	. = ..()
	if(open_space_initialised && !invisibility)
		var/turf/T = GetAbove(src)
		if(isopenspace(T))
			// log_debug("[T] ([T.x],[T.y],[T.z]) queued for update for [src]New()")
			OS_controller.add_turf(T, 1)
*/

// Just as New() we probably should hook Destroy() If we can think of something more efficient, lets hear it.
/obj/Destroy()
	if(OS_controller.initialized && !invisibility && isturf(loc))
		var/turf/T = GetAbove(src)
		if(isopenspace(T))
			OS_controller.add_turf(T, 1)
	. = ..() // Important that this be at the bottom, or we will have been moved to nullspace.