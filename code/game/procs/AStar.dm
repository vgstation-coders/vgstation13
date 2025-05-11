/*
A Star pathfinding algorithm
Returns a list of tiles forming a path from A to B, taking dense objects as well as walls, and the orientation of
windows along the route into account.
Use:
your_list = AStar(src, start location, end location, adjacent turf proc, distance proc)
For the adjacent turf proc i wrote:
/turf/proc/AdjacentTurfs
And for the distance one i wrote:
/turf/proc/Distance
So an example use might be:

src.path_list = AStar(src, src.loc, target.loc, /turf/proc/AdjacentTurfs, /turf/proc/Distance)

Then to start on the path, all you need to do it:
Step_to(src, src.path_list[1])
src.path_list -= src.path_list[1] or equivilent to remove that node from the list.

Optional extras to add on (in order):
MaxNodes: The maximum number of nodes the returned path can be (0 = infinite)
Maxnodedepth: The maximum number of nodes to search (default: 30, 0 = infinite)
Mintargetdist: Minimum distance to the target before path returns, could be used to get
near a target, but not right to it - for an AI mob with a gun, for example.
Minnodedist: Minimum number of nodes to return in the path, could be used to give a path a minimum
length to avoid portals or something i guess?? Not that they're counted right now but w/e.
*/

// Modified to provide ID argument - supplied to 'adjacent' proc, defaults to null
// Used for checking if route exists through a door which can be opened

// Also added 'exclude' turf to avoid travelling over; defaults to null

//Currently, there's four main ways to call AStar
//
// 1) adjacent = "/turf/proc/AdjacentTurfsWithAccess" and distance = "/turf/proc/Distance"
//	Seeks a path moving in all directions (including diagonal) and checking for the correct id to get through doors
//
// 2) adjacent = "/turf/proc/CardinalTurfsWithAccess" and distance = "/turf/proc/Distance_cardinal"
//  Seeks a path moving only in cardinal directions and checking if for the correct id to get through doors
//  Used by most bots, including Beepsky
//
// 3) adjacent = "/turf/proc/AdjacentTurfs" and distance = "/turf/proc/Distance"
//  Same as 1), but don't check for ID. Can get only get through open doors
//
// 4) adjacent = "/turf/proc/AdjacentTurfsSpace" and distance = "/turf/proc/Distance"
//  Same as 1), but check all turf, including unsimulated

//////////////////////
//PathNode object
//////////////////////

//A* nodes variables
/PathNode
	var/turf/source //turf associated with the PathNode
	var/PathNode/prevNode //link to the parent PathNode
	var/total_node_cost		//A* Node weight (total_node_cost = distance_from_start + distance_from_end)
	var/distance_from_end		//A* movement cost variable, how far it is from the end
	var/distance_from_start		//A* heuristic variable, how far it is from the start
	var/nodecount		//count the number of Nodes traversed
	var/id

/PathNode/New(s,p,ndistance_from_start,ndistance_from_end,pnt,id)
	source = s
	prevNode = p
	distance_from_start = ndistance_from_start
	distance_from_end = ndistance_from_end
	calc_f()
	nodecount = pnt
	source.AddPathNode(src, id)
	src.id = id

/PathNode/proc/calc_f()
	total_node_cost = distance_from_start + distance_from_end

/PathNode/Destroy()
	if(source.PathNodes)
		source.PathNodes -= id
	source = null
	prevNode = null
	..()

//////////////////////
//A* procs
//////////////////////

//the weighting function, used in the A* algorithm
/proc/PathWeightCompare(PathNode/a, PathNode/b)
	return a.total_node_cost - b.total_node_cost

//search if there's a PathNode that points to turf T in the Priority Queue
/proc/SeekTurf(var/PriorityQueue/Queue, var/turf/T)
	var/i = 1
	var/PathNode/PN
	while(i < Queue.L.len + 1)
		PN = Queue.L[i]
		if(PN.source == T)
			return i
		i++
	return 0

#define ASTAR_REGISTERED 1
#define ASTAR_PROCESSING 2
#define ASTAR_FAIL 3

/*
 * ASTAR
 * source: the atom which calls this Astar call.TRUE
 * callback: the callback to invoke when the path is ready
 * start: starting atom
 * end: end of targetted path
 * Adjacent: the proc which rules what is adjacent for us
 * dist: the proc which rules what is the distance for us

 * Returns an hint (are we processing the path, did we make the path already, or are we unable to make the path?)
 * Creates a pathmaker datum to process the path if we aren't processing the path.
 * Returns nothing if this path is already being processed.
 */
/proc/AStar(source, callback, start,end,adjacent,dist,maxnodes,maxnodedepth = 30,mintargetdist,minnodedist,id=null, var/turf/exclude=null, var/debug = ASTAR_DEBUG)
	ASSERT(!istype(end,/area)) //Because yeah some things might be doing this and we want to know what
	if(start:z != end:z) //if you're feeling ambitious and make something that can ASTAR through z levels, feel free to remove this check
		return ASTAR_FAIL
	for(var/datum/path_maker/P in pathmakers)
		if(P.owner == source && start == P.start && end == P.end)
			return ASTAR_PROCESSING
	var/atom/target
	if(!isturf(end))
		target = end

	astar_debug("ASTAR called [source] [callback] [start:x],[start:y],[start:z] [end:x],[end:y],[end:z] [adjacent] [dist] [maxnodes] [maxnodedepth] [mintargetdist] [minnodedist] [id] [exclude] [debug]")
	new /datum/path_maker(source,callback, get_turf(start), get_turf(end), target, adjacent, dist, maxnodes, maxnodedepth, mintargetdist, id, exclude, debug)
	return ASTAR_REGISTERED

// Only use if you just need to check if a path exists, and is a reasonable length
// The main difference is that it'll be caculated immediately and transmitted to the bot rather than waiting for the path to be made.
// Currently, security bots are using this method to chase suspsects.
// You MUST have the start and end be turfs.
/proc/quick_AStar(start,end,adjacent,dist,maxnodes,maxnodedepth = 30,mintargetdist,minnodedist,id=null, var/turf/exclude=null, var/reference)
	ASSERT(!istype(end,/area)) //Because yeah some things might be doing this and we want to know what
	. = list() // In case of failure/runtimes, we want to return a list.
	var/PriorityQueue/open = new /PriorityQueue/reverse(/proc/PathWeightCompare) //the open list, ordered using the PathWeightCompare proc, from lower f to higher
	var/list/closed = new() //the closed list
	var/list/path = list() //the returned path, if any
	var/PathNode/cur //current processed turf
	start = get_turf(start)

	if(!start)
		astar_debug("aborted - no start.")
		return list()

	//initialization
	open.Enqueue(new /PathNode(start,null,0,call(start,dist)(end),0,"unique_[reference]"))

	//then run the main loop
	while(!open.IsEmpty() && !path.len)
	{
		cur = open.Dequeue() //get the lowest node cost turf in the open list
		closed.Add(cur.source) //and tell we've processed it

		//if we only want to get near the target, check if we're close enough
		var/closeenough
		if(mintargetdist)
			closeenough = call(cur.source,dist)(end) <= mintargetdist

		//if too many steps, abandon that path
		if(maxnodedepth && (cur.nodecount > maxnodedepth))
			//cleanup
			for(var/PathNode/PN in open.L)
				qdel(PN)
			for(var/turf/T in closed)
				var/PathNode/PN = T.FindPathNode("unique_[reference]")
				qdel(PN)
			return list()

		//found the target turf (or close enough), let's create the path to it
		if(cur.source == end || closeenough)
			path = new()
			path.Add(cur.source)
			while(cur.prevNode)
				cur = cur.prevNode
				path.Add(cur.source)
			break


		//get adjacents turfs using the adjacent proc, checking for access with id
		var/list/L = call(cur.source,adjacent)(id,closed)

		for(var/turf/T in L)
			if(ASTAR_DEBUG && T.color != "#00ff00")
				T.color = "#FFA500" //orange
			if(T == exclude)
				if(ASTAR_DEBUG && T.color != "#00ff00")
					T.color = "#FF0000" //red
				continue

			var/newenddist = call(T,dist)(end)
			var/PathNode/PNode = T.FindPathNode("unique_[reference]")
			if(!PNode) //is not already in open list, so add it
				open.Enqueue(new /PathNode(T,cur,call(cur.source,dist)(T),newenddist,cur.nodecount+1,"unique_[reference]"))
			else //is already in open list, check if it's a better way from the current turf
				if(newenddist < PNode.distance_from_end)
					PNode.prevNode = cur
					PNode.distance_from_start = newenddist
					PNode.calc_f()
					open.ReSort(PNode)//reorder the changed element in the list
	}

	//cleanup
	for(var/PathNode/PN in open.L)
		qdel(PN)
	for(var/turf/T in closed)
		var/PathNode/PN = T.FindPathNode("unique_[reference]")
		qdel(PN)
	for(var/turf/T in path)
		var/PathNode/PN = T.FindPathNode("unique_[reference]")
		qdel(PN)

	open.L = null
	closed = null

	//if the path is longer than maxnodes, then don't return it
	if(path && maxnodes && path.len > (maxnodes + 1))
		return list()

	//reverse the path to get it from start to finish
	if(path)
		for(var/i = 1; i <= path.len/2; i++)
			path.Swap(i,path.len-i+1)

	return path

///////////////////
//A* helpers procs
///////////////////


// Returns true if a link between A and B is blocked
// Movement through doors allowed if ID has access
/proc/LinkBlockedWithAccess(turf/A, turf/B, obj/item/weapon/card/id/ID)


	if(A == null || B == null)
		return 1
	var/adir = get_dir(A,B)
	var/rdir = get_dir(B,A)
	if(adir & (adir-1))	//	diagonal
		var/turf/iStep = get_step(A,adir&(NORTH|SOUTH))
		if(!iStep.density && !LinkBlockedWithAccess(A,iStep, ID) && !LinkBlockedWithAccess(iStep,B,ID))
			return 0

		var/turf/pStep = get_step(A,adir&(EAST|WEST))
		if(!pStep.density && !LinkBlockedWithAccess(A,pStep,ID) && !LinkBlockedWithAccess(pStep,B,ID))
			return 0

		return 1

	if(DirBlockedWithAccess(A,adir, ID))
		return 1

	if(DirBlockedWithAccess(B,rdir, ID))
		return 1

	for(var/obj/O in B)
		if(O.density && !istype(O, /obj/machinery/door) && !(O.flow_flags & ON_BORDER))
			return 1

	return 0

// Returns true if direction is blocked from loc
// Checks doors against access with given ID
/proc/DirBlockedWithAccess(turf/loc,var/dir,var/obj/item/weapon/card/id/ID)
	for(var/obj/structure/window/D in loc)
		if(!D.density)
			continue
		if(D.dir == SOUTHWEST)
			return 1 //full-tile window
		if(D.dir == dir)
			return 1 //matching border window

	for(var/obj/machinery/door/D in loc)
		if(!D.CanAStarPass(ID,dir))
			return 1
	return 0

// Returns true if a link between A and B is blocked
// Movement through doors allowed if door is open
/proc/LinkBlocked(turf/A, turf/B)
	if(A == null || B == null)
		return 1
	var/adir = get_dir(A,B)
	var/rdir = get_dir(B,A)
	if(adir & (adir-1)) //diagonal
		var/turf/iStep = get_step(A,adir & (NORTH|SOUTH)) //check the north/south component
		if(!iStep.density && !LinkBlocked(A,iStep) && !LinkBlocked(iStep,B))
			return 0

		var/turf/pStep = get_step(A,adir & (EAST|WEST)) //check the east/west component
		if(!pStep.density && !LinkBlocked(A,pStep) && !LinkBlocked(pStep,B))
			return 0

		return 1

	if(DirBlocked(A,adir))
		return 1
	if(DirBlocked(B,rdir))
		return 1

	for(var/obj/O in B)
		if(O.density && !istype(O, /obj/machinery/door) && !(O.flow_flags & ON_BORDER))
			return 1

	return 0

// Returns true if direction is blocked from loc
// Checks if doors are open
/proc/DirBlocked(turf/loc,var/dir)
	for(var/obj/structure/window/D in loc)
		if(!D.density)
			continue
		if(D.dir == SOUTHWEST)
			return 1 //full-tile window
		if(D.dir == dir)
			return 1 //matching border window

	for(var/obj/machinery/door/D in loc)
		if(D.density)// if closed, it's a real, air blocking door
			return 1

	return 0

/////////////////////////////////////////////////////////////////////////

/atom/proc/make_astar_path(var/atom/target, var/callback = new /callback(src, nameof(src::get_astar_path())))
	AStar(src, callback, get_turf(src), target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 30, 30)

//override when needed to receive your path
/atom/proc/get_astar_path(var/list/L)
	if(L && L.len)
		pathers.Add(src)
		return L
	return FALSE

/atom/proc/process_astar_path()
	return FALSE

/atom/proc/drop_astar_path()
	pathers.Remove(src)
