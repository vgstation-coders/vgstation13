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
			return AW
	for(var/datum/astar/AW in AStar_waitingprocess)
		if(AW.waiting == A)
			return AW

/proc/drop_astar_path(var/atom/A)
	var/datum/astar/AW = has_astar_path(A)
	if(AW)
		qdel(AW)

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
	var/PriorityQueue/open
	var/list/closed = list()
	var/PathNode/current_node //current processed turf

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
		open = new /PriorityQueue(/proc/PathWeightCompare) //the open list, ordered using the PathWeightCompare proc, from lower f to higher
		//initialization
		open.Enqueue(new /PathNode(start,null,0,call(start,distance)(target),0))
		//sanitation
		if(!isturf(start))
			start = get_turf(start)
		if(!start)
			status = FAILED
			return

	if(!open.IsEmpty() && !path)
		//get the lower f node on the open list
		current_node = open.Dequeue() //get the lower f turf in the open list
		closed.Add(current_node.source) //and tell we've processed it

		//if we only want to get near the target, check if we're close enough
		var/closeenough
		if(mintargetdist)
			closeenough = call(current_node.source,distance)(target) <= mintargetdist

		//if too many steps, abandon that path
		if(maxnodedepth && (current_node.nt > maxnodedepth))
			goto end

		//found the target turf (or close enough), let's create the path to it
		if(current_node.source == target || closeenough)
			path = new()
			path.Add(current_node.source)
			while(current_node.prevNode)
				current_node = current_node.prevNode
				path.Add(current_node.source)
			goto end

		//IMPLEMENTATION TO FINISH
		//do we really need this minnodedist ???
		/*if(minnodedist && maxnodedepth)
			if(call(current_node.source,minnodedist)(end) + current_node.nt >= maxnodedepth)
				continue
		*/
		end:
		//get adjacents turfs using the adjacent proc, checking for access with id
		var/list/L = call(current_node.source,adjacent)(ID,closed)

		for(var/turf/T in L)
			if(exclude && istype(T, exclude))
				continue

			var/newg = current_node.g + call(current_node.source,distance)(T)
			if(!T.PNode) //is not already in open list, so add it
				open.Enqueue(new /PathNode(T,current_node,newg,call(T,distance)(target),current_node.nt+1))
			else //is already in open list, check if it's a better way from the current_noderent turf
				if(newg < T.PNode.g)
					T.PNode.prevNode = current_node
					T.PNode.g = newg
					T.PNode.calc_f()
					open.ReSort(T.PNode)//reorder the changed element in the list

	else
		//cleaning after us
		for(var/PathNode/PN in open.L)
			PN.source.PNode = null
		for(var/turf/T in closed)
			T.PNode = null

		//if the path is longer than maxnodes, then don't return it
		if(path && maxnodes && path.len > (maxnodes + 1))
			return 0

		//reverse the path to get it from start to finish
		if(path)
			for(var/i = 1; i <= path.len/2; i++)
				path.Swap(i,path.len-i+1)

		return path

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