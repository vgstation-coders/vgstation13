
//it's called toomycross because i was very cross with the previous pathing checks t. toomy
/proc/Toomycross(turf/A,turf/B,atom/movable/thing, var/obj/item/weapon/card/id/ID=null)
	if(!B||!A||!thing)
		return FALSE

	if(B.blocks_air)
		return FALSE
	var/door_in_tile_A
	for(var/atom/obstacle in A)
		if(obstacle == thing)
			continue
		if(istype(obstacle,/obj))
			var/obj/obsobj = obstacle
			if(istype(obsobj,/obj/machinery/door))
				if(istype(obsobj,/obj/machinery/door/window))
					if(!(get_dir(A,B) == obsobj.dir))
						continue
				var/obj/machinery/door/obsdoor = obsobj
				if(!obsdoor.density || obsdoor.check_access(ID))
					astar_debug("door check passsed")
					continue
				else
					astar_debug("door check failed")
					return FALSE
			else
				astar_debug("[obsobj] is not a door")
			if(obsobj.flow_flags & ON_BORDER)
				if(get_dir(A,B) == obsobj.dir)
					return FALSE
				else
					continue
	for(var/atom/obstacle in B)
		if(obstacle == thing)
			continue
		if(istype(obstacle,/obj))
			var/obj/obsobj = obstacle
			if(istype(obsobj,/obj/machinery/door))
				if(istype(obsobj,/obj/machinery/door/window))
					if(!(get_dir(B,A) == obsobj.dir))
						continue
				var/obj/machinery/door/obsdoor = obsobj
				if(!obsdoor.density || obsdoor.check_access(ID))
					astar_debug("door check passsed")
					continue
				else
					astar_debug("door check failed")
					return FALSE
			else
				astar_debug("[obsobj] is not a door")
			if(obsobj.flow_flags & ON_BORDER)
				if(get_dir(B,A) == obsobj.dir)
					return FALSE
				else
					continue
			//if(obstacle.density)
			//	astar_debug("density fail")
			//return FALSE
			if(!obsobj.Cross(thing,B,1.5,0))
				astar_debug("cross failed")
				return FALSE
			//	astar_debug("ASTAR called toomycross  --- [thing] cannot cross [obstacle]!")
			//	return FALSE
	astar_debug("success")
	return TRUE
	//astar_debug("ASTAR called toomycross, nothing happened went through!")
	//return TRUE



#define ASTAR_REGISTERED 1
#define ASTAR_PROCESSING 2
#define ASTAR_FAIL 3
/datum/path_maker/toomy

/datum/path_maker/toomy/process()
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
	var/list/L = call(cur.source,adjacent)(owner,id,closed)
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


/proc/ToomyAStar(atom/movable/thing, callback, start,end,maxnodes,maxnodedepth = 30,mintargetdist = 0,minnodedist,id=null, var/turf/exclude=null, var/debug = ASTAR_DEBUG)
	ASSERT(!istype(end,/area)) //Because yeah some things might be doing this and we want to know what
	if(start:z != end:z) //if you're feeling ambitious and make something that can ASTAR through z levels, feel free to remove this check
		return ASTAR_FAIL
	for(var/datum/path_maker/P in pathmakers)
		if(P.owner == thing && start == P.start && end == P.end)
			return ASTAR_PROCESSING
	var/atom/target
	if(!isturf(end))
		target = end

	astar_debug("ASTAR called [thing] [callback] [start:x],[start:y],[start:z] [end:x],[end:y],[end:z] [maxnodes] [maxnodedepth] [mintargetdist] [minnodedist] [id] [exclude] [debug]")
	new /datum/path_maker/toomy(thing,callback, get_turf(start), get_turf(end), target, /turf/proc/ToomysCardinalTurfsWithAccess, /turf/proc/Distance_cardinal, maxnodes, maxnodedepth, mintargetdist, id, exclude, debug)
	return ASTAR_REGISTERED


/turf/proc/ToomysCardinalTurfsWithAccess(var/atom/movable/thing, var/obj/item/weapon/card/id/ID)
	var/list/L = new()
	var/turf/simulated/T

	for(var/dir in cardinal)
		T = get_step(src, dir)
		//if(istype(T) && !T.density)
		if(Toomycross(src, T, thing, ID))
			L.Add(T)
	return L


