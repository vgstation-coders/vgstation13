var/datum/subsystem/pathing/SSpath
var/global/list/pathers = list()
var/global/path_count = 0

// -- The pathing subsystem has a list of path_makers datums which are currently calculating paths for mobs or bots.
// It iterates through them and checks if the pathmaking is still relevant.

/datum/subsystem/pathing
	name = "Pathing"
	wait = 1
	priority = SS_PRIORITY_PATHING
	flags = SS_NO_INIT
	var/list/currentrun

/datum/subsystem/pathing/New()
	NEW_SS_GLOBAL(SSpath)

/datum/subsystem/pathing/stat_entry()
	..("Pathfinders:[pathers.len]")

/datum/subsystem/pathing/fire(var/resumed = FALSE)
	if(!resumed)
		currentrun = pathers.Copy()

	while(currentrun.len)
		var/atom/A = currentrun[currentrun.len]
		currentrun.len--

		if(!A.process_astar_path())
			A.drop_astar_path()

		if (MC_TICK_CHECK)
			return

var/datum/subsystem/pathing/SSPathmake
var/global/list/pathmakers = list()

/datum/subsystem/pathmaking
	name = "Pathmaking"
	wait = 1
	priority = SS_PRIORITY_PATHING
	flags = SS_NO_INIT
	var/list/currentrun

/datum/subsystem/pathing/New()
	NEW_SS_GLOBAL(SSPathmake)

/datum/subsystem/pathmaking/stat_entry()
	..("Paths to make:[pathmakers.len]")

/datum/subsystem/pathmaking/fire(var/resumed = FALSE)
	if(!resumed)
		currentrun = pathmakers.Copy()

	while(currentrun.len)
		var/datum/path_maker/P = currentrun[currentrun.len]
		currentrun.len--

		if(!P || P.gcDestroyed)
			currentrun.Remove(P)
			continue

		if(P.can_process())
			P.process()

		if (MC_TICK_CHECK)
			return

// -- The datum which stores the path currently being calculated for the owner.
// -- It will tell its owner the path to follow by calling back a proc it was given.

/datum/path_maker
	var/atom/owner
	var/turf/start
	var/turf/end
	var/atom/target
	var/PriorityQueue/open = new /PriorityQueue/reverse(/proc/PathWeightCompare) //the open list, ordered using the PathWeightCompare proc, from lower f to higher
	var/list/closed = new() //the closed list
	var/list/path = null //the returned path, if any
	var/PathNode/cur //current processed turf
	var/callback/callback //how we can tell the owner the finished path

	var/adjacent //How we check which turfs that are adjacent to our checked turf are valid
	var/dist //How we check the distance between points
	var/maxnodes //How complex the path can be
	var/maxnodedepth //How far we're willing to look away from the start point to find a path
	var/mintargetdist //If not null, how close we're willing to be to call it a completed path
	var/id //What ID we will be using, needed for adjacent checks
	var/turf/exclude //A turf to specifically avoid, used by mulebots
	var/debug = FALSE //Whether we paint our turfs as we calculate
	var/PM_id //How we will identify PathNodes associated with this, to prevent PathNode conflict

/datum/path_maker/New(var/nowner, var/ncallback, var/turf/nstart, var/turf/nend, var/atom/ntarget, var/nadjacent, var/ndist, var/nmaxnodes, var/nmaxnodedepth, var/nmintargetdist, var/nid=null, var/turf/nexclude, var/ndebug)
	ASSERT(nowner)
	ASSERT(nstart)
	ASSERT(nend)
	ASSERT(ncallback)

	owner = nowner
	start = nstart
	end = nend
	callback = ncallback
	target = ntarget
	adjacent = nadjacent
	dist = ndist
	maxnodes = nmaxnodes
	maxnodedepth = nmaxnodedepth
	mintargetdist = nmintargetdist
	id = nid
	exclude = nexclude
	debug = ndebug
	path_count++
	PM_id = "PM_[path_count]_\ref[owner]"
	open.Enqueue(new /PathNode(start,null,0,call(start,dist)(end),0,PM_id))
	pathmakers.Add(src)

/datum/path_maker/proc/can_process()
	if(!owner || owner.gcDestroyed) //crit fail
		astar_debug("owner no longer exists [owner?"owner is destroyed":"no owner"]")
		qdel(src)
		return FALSE
	if(gcDestroyed)
		astar_debug("We are being deleted")
		return FALSE
	if(get_turf(owner) != start)
		astar_debug("owner not in start position")
		fail()
		return FALSE
	if(target && get_turf(target) != end)
		astar_debug("target moved from end")
		fail()
		return FALSE
	if(end == exclude)
		astar_debug("our target is being avoided.")
		fail()
		return FALSE
	return TRUE

/datum/path_maker/Destroy()
	pathmakers.Remove(src)
	//cleaning after us
	for(var/PathNode/PN in open.L)
		open.L -= PN
		qdel(PN)
	for(var/turf/T in closed)
		var/PathNode/PN = T.FindPathNode(PM_id)
		closed -= T
		qdel(PN)
	owner = null
	start = null
	end = null
	target = null
	cur = null
	id = null
	closed = null
	path = null
	..()

/datum/path_maker/proc/process()
	if(path)
		return finish()
	if(open.List().len == 0)
		astar_debug("ran out of open turfs")
		return fail()
	cur = open.Dequeue() //get the lowest node cost turf in the open list
	closed.Add(cur.source) //and tell we've processed it

	//if we only want to get near the target, check if we're close enough
	var/closeenough
	if(mintargetdist)
		closeenough = call(cur.source,dist)(end) <= mintargetdist

	//if too many steps, abandon that path
	if(maxnodedepth && (cur.nodecount > maxnodedepth))
		astar_debug("max node depth reached")
		return fail()

	//found the target turf (or close enough), let's create the path to it
	if(cur.source == end || closeenough)
		path = new()
		path.Add(cur.source)
		while(cur.prevNode)
			cur = cur.prevNode
			path.Add(cur.source)
		return finish()


	//get adjacents turfs using the adjacent proc, checking for access with id
	var/list/L = call(cur.source,adjacent)(id,closed)
	astar_debug("adjacent turfs [L.len]")
	for(var/turf/T in L)
		if(debug && T.color != "#00ff00")
			T.color = "#FFA500" //orange
		if(T == exclude)
			if(debug && T.color != "#00ff00")
				T.color = "#FF0000" //red
			continue

		var/newenddist = call(T,dist)(end)
		var/PathNode/PNode = T.FindPathNode(PM_id)
		if(!PNode) //is not already in open list, so add it
			open.Enqueue(new /PathNode(T,cur,call(cur.source,dist)(T),newenddist,cur.nodecount+1, PM_id))
			if(debug && T.color != "#00ff00")
				T.color = "#0000ff" //blue
		else //is already in open list, check if it's a better way from the current turf
			if(newenddist < PNode.distance_from_end)
				if(debug)
					T.color = "#00ff00" //green
				PNode.prevNode = cur
				PNode.distance_from_start = call(cur.source,dist)(T)
				PNode.distance_from_end = newenddist
				PNode.calc_f()
				if(!open.ReSort(PNode))//reorder the changed element in the list
					astar_debug("failed to reorder, requeuing")
					open.Enqueue(PNode)
	astar_debug("open:[open.List().len]")

/datum/path_maker/proc/fail()
	callback.invoke_async()
	qdel(src)

/datum/path_maker/proc/finish()
	//if the path is longer than maxnodes, then don't return it
	if(path && maxnodes && path.len > (maxnodes + 1))
		astar_debug("max node count reached")
		return qdel(src)

	//reverse the path to get it from start to finish
	if(path)
		for(var/i = 1; i <= path.len/2; i++)
			path.Swap(i,path.len-i+1)

	callback.invoke_async(path.Copy(), target)
	qdel(src)
