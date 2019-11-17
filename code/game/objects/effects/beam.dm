/**
 * Base code for CONSTANT beams.  No more constant addition and removal of shit from the pool.
 *
 * Weapon beams are projectiles.  This is for emitters and IR tripwires.
 *
 * Instead of triggering a bullet_act constantly, beams just send a
 *  beam_connect(var/obj/effect/beam/B) to the "client" and a similar
 *  beam_disconnect(var/obj/effect/beam/B) when disconnected.
 *
 * Note: All /atoms automatically maintain a beams list, so you should
 *  only need to fuck with that.
 */

// Uncomment to spam console with debug info.
//#define BEAM_DEBUG

#define BEAM_MAX_STEPS 50 // Or whatever

#define BEAM_DEL(x) del(x)

#ifdef BEAM_DEBUG
# warn SOME ASSHOLE FORGOT TO COMMENT BEAM_DEBUG BEFORE COMMITTING
# define beam_testing(x) to_chat(world, "(Line: [__LINE__]) [x]")
#else
# define beam_testing(x)
#endif

/obj/effect/beam
	name = "beam"
	anchored = 1
	density = 0

	var/def_zone=""
	var/damage=0
	var/damage_type=BURN

	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE

	// The first beam object
	var/obj/effect/beam/master = null

	// Children (for cleanup)
	var/list/children = list()

	// The next beam in the chain
	var/obj/effect/beam/next = null

	// Who we eventually hit
	var/atom/movable/target = null

	var/max_range = INFINITY

	var/bumped=0
	var/stepped=0
	var/steps=0 // How many steps we've made from the emitter.  Used in infinite loop avoidance.
	var/am_connector=0
	var/targetMoveKey=null // Key for the on_moved listener.
	var/targetDestroyKey=null // Key for the on_destroyed listener.
	var/targetDensityKey=null // Key for the on_density_change listener
	var/targetContactLoc=null // Where we hit the target (used for target_moved)
	var/locDensity=null
	var/list/sources = list() // Whoever served in emitting this beam. Used in prisms to prevent infinite loops.
	var/_re_emit = 1 // Re-Emit from master when deleted? Set to 0 to not re-emit.

/obj/effect/beam/resetVariables()
	..("sources", "children", args)
	children = list()
	sources = list()

// Listener for /atom/movable/on_moved
/obj/effect/beam/proc/target_moved(var/list/args)
	if(master)
		beam_testing("Child got target_moved!  Feeding to master.")
		master.target_moved(args)
		return

	var/event/E = args["event"]
	if(!targetMoveKey)
		beam_testing("Uh oh, got a target_moved when we weren't listening for one.")
		E.handlers.Remove("\ref[src]:target_moved")
		return

	var/turf/T = args["loc"]

	if(E.holder != target)
		beam_testing("Received erroneous event, killing")
		E.handlers.Remove("\ref[src]:target_moved")
		return
	beam_testing("Target now at [T.x],[T.y],[T.z]")
	if(T != targetContactLoc && T != loc)
		beam_testing("Disconnecting: Target moved.")
		// Disconnect and re-emit.
		disconnect()

/obj/effect/beam/proc/turf_density_change(var/list/args)
	var/turf/T = args["atom"]
	var/atom/A = T.has_dense_content()
	if(A && !(A in sources))
		Crossed(A)

// Listener for /atom/on_density_change
/obj/effect/beam/proc/target_density_change(var/list/args)
	if(master)
		beam_testing("Child got target_density_change!  Feeding to master.")
		master.target_density_change(args)
		return

	var/event/E = args["event"]

	if(!targetDensityKey)
		E.handlers.Remove("\ref[src]:target_density_change")
		beam_testing("Uh oh, got a target_density_change when we weren't listening for one.")
		return

	if(E.holder != target)
		E.handlers.Remove("\ref[src]:target_density_change")
		return
	beam_testing("\ref[src] Disconnecting: \ref[target] Target denisty has changed.")
	// Disconnect and re-emit.
	disconnect()

// Listener for /atom/on_destroyed
/obj/effect/beam/proc/target_destroyed(var/list/args)
	if(master)
		beam_testing("Child got target_destroyed!  Feeding to master.")
		master.target_destroyed(args)
		return

	var/event/E = args["event"]

	if(!targetDestroyKey)
		E.handlers.Remove("\ref[src]:target_destroyed")
		beam_testing("Uh oh, got a target_destroyed when we weren't listening for one.")
		return

	if(E.holder != target)
		E.handlers.Remove("\ref[src]:target_destroyed")
		return
	beam_testing("\ref[src] Disconnecting: \ref[target] Target destroyed.")
	// Disconnect and re-emit.
	disconnect()

/obj/effect/beam/Bumped(var/atom/movable/AM)
	if(!master || !AM)
		return
	if(istype(AM, /obj/effect/beam) || !AM.density || AM.Cross(src))
		return
	beam_testing("Bumped by [AM]")
	am_connector=1
	var/obj/effect/beam/OB = master
	if(!OB)
		OB = src
	src._re_emit = 0
	qdel(src)
	OB.connect_to(AM)
	//BEAM_DEL(src)


/obj/effect/beam/proc/get_master()

	#ifdef BEAM_DEBUG
	var/master_ref = "\ref[master]"
	#endif

	beam_testing("\ref[src] [master ? "get_master is returning [master_ref]" : "get_master is returning ourselves."]")
	if(master)
		return master
	return src

/obj/effect/beam/proc/get_damage()
	return damage

/obj/effect/beam/proc/get_machine_underlay(var/mdir)
	return image(icon=icon, icon_state="[icon_state] underlay", dir=mdir)

/obj/effect/beam/proc/connect_to(var/atom/movable/AM)
	if(!AM)
		return
	var/obj/effect/beam/BM=get_master()
	if(BM.target == AM)
		return
	if(BM.target)
		beam_testing("\ref[BM] - Disconnecting [BM.target]: target changed.")
		BM.disconnect(0)
	BM.target=AM
	if(istype(AM))
		BM.targetMoveKey    = AM.on_moved.Add(BM,    "target_moved")
	BM.targetDestroyKey = AM.on_destroyed.Add(BM,"target_destroyed")
	BM.targetDensityKey = AM.on_density_change.Add(BM,"target_density_change")
	BM.targetContactLoc = AM.loc
	beam_testing("\ref[BM] - Connected to [AM]")
	AM.beam_connect(BM)


/obj/effect/beam/blob_act()
	// Act like Crossed.
	// To do that, we need the blob.
	// Blob calls blob_act() twice:  Once (or so) on intent to expand, and finally on New().
	// We then use that second one to call Crossed().
	var/obj/effect/blob/B = locate() in loc
	if(B)
		Crossed(B)

/obj/effect/beam/proc/killKids()
	for(var/obj/effect/beam/child in children)
		if(child)
			//BEAM_DEL(child)
			children -= child
			child._re_emit = 0
			qdel(child)
	children.len = 0

/obj/effect/beam/proc/disconnect(var/re_emit=1)
	var/obj/effect/beam/_master=get_master()
	if(_master.target)
		if(ismovable(_master.target) && _master.target.on_moved)
			_master.target.on_moved.Remove(_master.targetMoveKey)
		_master.target.on_destroyed.Remove(_master.targetDestroyKey)
		_master.target.beam_disconnect(_master)
		_master.target=null
		_master.targetMoveKey=null
		_master.targetDestroyKey=null
		//if(_master.next)
		//	BEAM_DEL(_master.next)
		if(re_emit)
			_master.emit(sources)

/obj/effect/beam/Crossed(atom/movable/AM as mob|obj)
	beam_testing("Crossed by [AM]")
	if(!master || !AM)
		beam_testing(" returning (!AM || !master)")
		return

	if(istype(AM, /obj/effect/beam) || (!AM.density && !istype(AM, /obj/effect/blob)) || AM.Cross(src))
		beam_testing(" returning (is beam or not dense)")
		return

	if(master.target)
		disconnect(0)

	beam_testing(" Connecting!")
	am_connector=1
	var/obj/effect/beam/OB = master
	if(!OB)
		OB = src
	src._re_emit = 0
	qdel(src)
	OB.connect_to(AM)

/obj/effect/beam/proc/HasSource(var/atom/source)
	return source in sources

/**
 * Create and emit the beam in the desired direction.
 */
/obj/effect/beam/proc/emit(var/spawn_by, var/_range=-1)
	if(istype(spawn_by,/list))
		sources=spawn_by
	else
		sources |= (spawn_by)

	if(_range==-1)
#ifdef BEAM_DEBUG
		var/str_sources=jointext(sources,", ") // This will not work as an embedded statement.
		beam_testing("\ref[src] - emit(), sources=[str_sources]")
#endif
		_range=max_range

	if(next && next.loc)
		beam_testing("\ref[src] we have next \ref[next]")
		next.emit(sources,_range-1)
		return

	if(!loc)
		//BEAM_DEL(src)
		beam_testing("\ref[src] no loc")
		src._re_emit = 0
		qdel(src)
		return

	var/turf/T = get_turf(src)
	if(T && T.on_density_change)
		locDensity = T.on_density_change.Add(src, "turf_density_change")

	if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
		//BEAM_DEL(src)
		beam_testing("\ref[src] end of world")
		src._re_emit = 0
		qdel(src)
		return

	// If we're master, we're actually invisible, and we're on the same tile as the machine.
	// TODO: underlay firing machine.
	invisibility=0
	if(!master && !stepped)
		stepped=1
		invisibility=101

	if(!stepped)
		// Reset bumped
		setDensity(TRUE)
		bumped=0

		step(src, dir) // Move.

		setDensity(FALSE)
		if(bumped)
			beam_testing("\ref[src] Bumped")
			//BEAM_DEL(src)
			src._re_emit = 0
			qdel(src)
			return

		stepped=1

		if(_range-- < 1)
			beam_testing("\ref[src] ran out")
			//BEAM_DEL(src)
			src._re_emit = 0
			qdel(src)
			return

	update_icon()

	next = spawn_child()
	if(next)
		next.emit(sources,_range)

/obj/effect/beam/proc/spawn_child()
	if(steps >= BEAM_MAX_STEPS)
		return null // NOPE
	var/obj/effect/beam/B = new type(src.loc)
	B.steps = src.steps+1
	B.dir=dir
	B.master = get_master()
	if(B.master != B)
		B.master.children.Add(B)
	return B

/obj/effect/beam/to_bump(var/atom/A as mob|obj|turf|area)
	if(!master)
		return
	bumped = 1
	if(A)
		beam_testing("\ref[get_master()] - Bumped [A]!")
		connect_to(A)
		am_connector=1 // Prevents disconnecting after stepping into target.
	return 1

/obj/effect/beam/emitter/Destroy()
	..()
	if(sources && sources.len)
		for(var/obj/machinery/power/emitter/E in sources)
			if(E.beam == src)
				E.beam = null
		for(var/obj/machinery/prism/P in sources)
			if(P.beam == src)
				P.beam = null
		for(var/obj/machinery/mirror/M in sources)
			for(var/thing in M.emitted_beams)
				if(thing == src)
					M.emitted_beams -= thing

/obj/effect/beam/Destroy()
	var/turf/T = get_turf(src)
	if(T && T.on_density_change)
		T.on_density_change.Remove(locDensity)
	var/obj/effect/beam/ourselves = src
	var/obj/effect/beam/ourmaster = get_master()
	if(target)
		if(target.beams)
			target.beams -= ourselves
	for(var/obj/machinery/mirror/M in mirror_list)
		if(!M)
			continue
		if(ourselves in M.beams)
			M.beams -= ourselves

	for(var/obj/machinery/field_generator/F in field_gen_list)
		if(!F)
			continue
		if(ourselves in F.beams)
			F.beams -= ourselves

	for(var/obj/machinery/prism/P in prism_list)
		if(ourselves == P.beam)
			P.beam = null
		if(ourselves in P.beams)
			P.beams -= ourselves

	for(var/obj/machinery/power/photocollector/PC in photocollector_list)
		if(ourselves in PC.beams)
			PC.beams -= ourselves

	if(!am_connector && !master)
		beam_testing("\ref[get_master()] - Disconnecting (deleted)")
		disconnect(0)

	if(master)
		if(master.target && master.target.beams)
			master.target.beams -= ourselves

		for(var/obj/effect/beam/B in master.children)
			if(B.next == ourselves)
				B.next = null

		if(master.next == ourselves)
			master.next = null

		master.children.Remove(ourselves)
		master = null
	else if(children && children.len)

		killKids()
	if(next)
		//BEAM_DEL(next)
		next._re_emit = 0
		qdel(next)
		next=null
	..()

	if(ourselves._re_emit && ourmaster._re_emit)
		ourmaster.emit(ourmaster.sources)

/obj/effect/beam/singularity_pull()
	return

/obj/effect/beam/singularity_act()
	_re_emit = 0
	..()

/obj/effect/beam/ex_act(severity)
	return
