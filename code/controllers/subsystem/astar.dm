var/datum/subsystem/AStarbuild/SSAStarbuild
var/datum/subsystem/AStarprocess/SSAStarprocess

var/list/AStar_waitingbuild = list()
var/list/AStar_waitingprocess = list()


//Subsystem that builds the Astar paths
/datum/subsystem/AStarbuild
	name = "AStar builder"
	wait = 1 SECONDS
	var/list/currentrun

/datum/subsystem/AStarbuild/New()
	NEW_SS_GLOBAL(SSAStarbuild)

/datum/subsystem/AStarbuild/fire(resumed = FALSE)
	if (!resumed)
		currentrun = AStar_waitingbuild.Copy()

	while(currentrun.len)
		var/datum/astar/AS = currentrun[currentrun.len]
		currentrun.len--
		if(AS.gcDestroyed)
			continue
		AS.process_path_creation()

#define REGISTER_ASTAR(A, args) if(SSAStarbuild) SSAStarbuild.register_atom(A, args)

/proc/has_astar_path(var/atom/A)
	for(var/datum/astar/AW in AStar_waitingbuild)
		if(AW.waiting == A)
			return 1

/datum/subsystem/AStarbuild/proc/register_atom(var/atom/A, var/list/args)
	if(has_astar_path(A))
		return

	ASSERT(args["target"])

	new /datum/astar(A, args)

#define NOT_STARTED 0
#define STARTED 1
#define FAILED 2
#define PATH_MADE 3
#define PATH_COMPLETED 4

/datum/astar
	var/waiting
	var/start
	var/target
	var/adjacent
	var/distance
	var/maxnodes
	var/maxnodedepth = 30
	var/mintargetdist
	var/minnodedist
	var/ID
	var/turf/exclude
	var/list/path = list()
	var/status = NOT_STARTED

/datum/astar/New(var/atom/A, var/list/args)
	ASSERT(A)
	ASSERT(args)
	waiting = A
	start = A.loc
	for(var/i in args)
		switch(i)
			if("start")
				start = args[i]
			if("target")
				target = args[i]
			if("adjacent")
				adjacent = args[i]
			if("distance")
				distance = args[i]
			if("maxnodes")
				maxnodes = args[i]
			if("maxnodedepth")
				maxnodedepth = args[i]
			if("mintargetdist")
				mintargetdist = args[i]
			if("ID")
				ID = args[i]
			if("exclude")
				exclude = args[i]
	for(var/i in vars)
		to_chat(world, "[i] = [vars[i]]")
	AStar_waitingbuild |= src

/datum/astar/proc/receive_AStar()
	ASSERT(!islist(path) || !path.len)

	AStar_waitingprocess.Add(src)
	AStar_waitingbuild.Remove(src)

/datum/astar/proc/process_path_movement()
	if(!path || !path.len)
		qdel(src)
		return
	step_to(target, path[1])
	if(path.len == 1)
		path.Cut()
		qdel(src)
	else
		path.Remove(path[1])

/datum/astar/proc/process_path_creation()
	if(status == NOT_STARTED)
		status = STARTED


/datum/astar/Destroy()
	AStar_waitingbuild &= src
	waiting = null
	start = null
	target = null
	adjacent = null
	distance = null
	maxnodes = null
	maxnodedepth = null
	mintargetdist = null
	ID = null
	exclude = null
	path.Cut()
	AStar_waitingbuild &= src
	AStar_waitingprocess &= src
	..()

//subsystem that processes Astar paths
/datum/subsystem/AStarprocess
	name = "Astar path processor"
	wait = 1 SECONDS
	var/list/currentrun

/datum/subsystem/AStarprocess/New()
	NEW_SS_GLOBAL(SSAStarprocess)

/datum/subsystem/AStarprocess/fire(resumed = FALSE)
	if(!resumed)
		currentrun = AStar_waitingprocess = list()

	while(currentrun.len)
		var/datum/astar/AP = currentrun[currentrun.len]
		currentrun.len--
		if(AP.gcDestroyed)
			continue
		AP.process_path_movement()