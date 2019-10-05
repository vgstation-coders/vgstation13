#define GC_COLLECTIONS_PER_TICK 300 // Was 100.
#define GC_COLLECTION_TIMEOUT (30 SECONDS)
#define GC_FORCE_DEL_PER_TICK 2 //Was 60, but even 5 is enough to notice the lag. Holy fuck these are slow.

//#define GC_DEBUG
//#define GC_FINDREF

/datum/var/gcDestroyed

var/datum/garbage_collector/garbageCollector
var/soft_dels = 0

/client/proc/gc_dump_hdl()
	set name = "(GC) Hard Del List"
	set desc = "List types that fail to soft del and are hard del()'d by the GC."
	set category = "Debug"

	var/list/L = list()
	L += "<b>Garbage Collector Forced Deletions in this round</b><br>"
	for(var/A in ghdel_profiling)
		L += "<br>[A] = [ghdel_profiling[A]]"
	if(L.len == 1)
		to_chat(usr, "No garbage collector deletions this round")
		return
	usr << browse(jointext(L,""),"window=harddellogs")

/datum/garbage_collector
	var/list/queue = new
	var/del_everything = 0

	// To let them know how hardworking am I :^).
	var/dels_count = 0
	var/hard_dels = 0

/datum/garbage_collector/proc/addTrash(const/datum/D)
	if(istype(D, /atom) && !istype(D, /atom/movable))
		return

	if(del_everything)
		del(D)
		hard_dels++
		dels_count++
		return

	dequeue("\ref[D]") //This makes sure the new entry is at the end in the event D is using a recycled ref already in the queue.
	queue["\ref[D]"] = world.timeofday

#ifdef GC_FINDREF
world/loop_checks = 0
#endif

/datum/garbage_collector/proc/process()
	var/remainingCollectionPerTick = GC_COLLECTIONS_PER_TICK
	var/remainingForceDelPerTick = GC_FORCE_DEL_PER_TICK
	var/collectionTimeScope = world.timeofday - GC_COLLECTION_TIMEOUT
	if(narsie_cometh)
		return //don't even fucking bother, its over.
	while(queue.len && --remainingCollectionPerTick >= 0)
		var/refID = queue[1]
		var/destroyedAtTime = queue[refID]

		if(destroyedAtTime > collectionTimeScope)
			break

		var/datum/D = locate(refID)
		if(D) // Something's still referring to the qdel'd object. del it.
			if(isnull(D.gcDestroyed))
				dequeue(refID)
				continue
			if(remainingForceDelPerTick <= 0)
				break

			#ifdef GC_FINDREF
			to_chat(world, "picnic! searching [D]")
			if(istype(D, /atom/movable))
				var/atom/movable/A = D
				testing("GC: Searching references for [A] | [A.type]")
				if(A.loc != null)
					testing("GC: [A] | [A.type] is located in [A.loc] instead of null")
				if(A.contents.len)
					testing("GC: [A] | [A.type] has contents:")
					for(var/atom/B in A.contents)
						testing("[B] | [B.type]")
			var/found = 0
			for(var/atom/R in world)
				found += LookForRefs(R, D)
			for(var/datum/R)
				found += LookForRefs(R, D)
			for(var/client/R)
				found += LookForRefs(R, D)
			found += LookForRefs(world, D)
			found += LookForListRefs(global.vars, D, null, "global.vars") //You can't pretend global is a datum like you can with clients and world. It'll compile, but throw completely nonsensical runtimes.
			to_chat(world, "we found [found]")
			#endif


			#ifdef GC_DEBUG
			WARNING("gc process force delete [D.type]")
			#endif

			if(istype(D, /atom/movable))
				var/atom/movable/AM = D
				AM.hard_deleted = 1
			else
				delete_profile("[D.type]", 1) //This is handled in Del() for movables.
				//There's not really a way to make the other kinds of delete profiling work for datums without defining /datum/Del(), but this is the most important one.

			del D
			dequeue(refID)

			hard_dels++
			remainingForceDelPerTick--
			if(world.cpu > 80)
				#ifdef GG_DEBUG
				WARNING("GC process sleeping due to high CPU usage!")
				#endif
				sleep(calculateticks(2))

		else
			dequeue(refID)

#ifdef GC_DEBUG
#undef GC_DEBUG
#endif

#undef GC_FORCE_DEL_PER_TICK
#undef GC_COLLECTION_TIMEOUT
#undef GC_COLLECTIONS_PER_TICK

/datum/garbage_collector/proc/dequeue(id)
	if(queue.Remove(id))
		dels_count++

/*
 * NEVER USE THIS FOR /atom OTHER THAN /atom/movable
 * BASE ATOMS CANNOT BE QDEL'D BECAUSE THEIR LOC IS LOCKED.
 */
/proc/qdel(const/datum/D, ignore_pooling = 0)
	if(isnull(D))
		return

	if(D.being_sent_to_past())
		return

	if(isnull(garbageCollector))
		del(D)
		return

	if(istype(D, /atom) && !istype(D, /atom/movable))
		warning("qdel() passed object of type [D.type]. qdel() cannot handle unmovable atoms.")
		del(D)
		garbageCollector.hard_dels++
		garbageCollector.dels_count++
		return

	//This is broken. The correct index to use is D.type, not "[D.type]"
	if(("[D.type]" in masterdatumPool) && !ignore_pooling)
		returnToPool(D)
		return

	if(isnull(D.gcDestroyed))
		// Let our friend know they're about to get fucked up.
		D.Destroy()

		garbageCollector.addTrash(D)

/datum/proc/being_sent_to_past()
	if(being_sent_to_past)
		return 1

/atom/movable/being_sent_to_past()
	if(..())
		invisibility = 101
		setDensity(FALSE)
		anchored = 1
		timestopped = 1
		flags |= INVULNERABLE | TIMELESS
		if(loc)
			if(ismob(loc))
				var/mob/M = loc
				M.drop_item(src, force_drop = 1)
		forceMove(null)
		return 1
/*
/datum/controller
	var/processing = 0
	var/iteration = 0
	var/processing_interval = 0

/datum/controller/proc/recover() // If we are replacing an existing controller (due to a crash) we attempt to preserve as much as we can.
*/
/*
 * Like Del(), but for qdel.
 * Called BEFORE qdel moves shit.
 */
/datum/proc/Destroy()
	gcDestroyed = "Bye, world!"
	tag = null

/proc/delete_profile(var/type, code = 0)
	if(!ticker || ticker.current_state < 3)
		return
	if(code == 0)
		if (!("[type]" in del_profiling))
			del_profiling["[type]"] = 0

		del_profiling["[type]"] += 1
	else if(code == 1)
		if (!("[type]" in ghdel_profiling))
			ghdel_profiling["[type]"] = 0

		ghdel_profiling["[type]"] += 1
	else
		if (!("[type]" in gdel_profiling))
			gdel_profiling["[type]"] = 0

		gdel_profiling["[type]"] += 1
		soft_dels += 1

#ifdef GC_FINDREF
/datum/garbage_collector/proc/LookForRefs(var/datum/D, var/datum/targ)
	. = 0
	for(var/V in D.vars)
		if(V == "contents" || V == "vars")
			continue
		if(istype(D.vars[V], /datum))
			var/datum/A = D.vars[V]
			if(A == targ)
				testing("GC: [A] | [A.type] referenced by [D] | [D.type], var [V]")
				. += 1
		else if(islist(D.vars[V]))
			. += LookForListRefs(D.vars[V], targ, D, V)

/datum/garbage_collector/proc/LookForListRefs(var/list/L, var/datum/targ, var/datum/D, var/V, var/list/foundcache = list())
	. = 0
	//foundcache makes sure each list in a given call to this is only checked once, to prevent infinite loops if two lists reference each other.
	//You might think it would be better to keep the cache across all searches for the same datum, but since the in operator takes longer on larger lists, it's much slower.
	//Thus we only keep it for one top-level call of LookForListRefs, as that's the minimum required to prevent infinite loops.
	if(L in foundcache)
		return
	foundcache += L

	for(var/F in L)
		var/G
		try
			G = L[F] //Some special built-in lists runtime if you try to use them as associative lists.
		catch
			G = null //It's probably already null if it gets here, but may as well be safe

		if(istype(F, /datum))
			var/datum/A = F
			if(A == targ)
				testing("GC: [A] | [A.type] referenced by [D? "[D] | [D.type]" : "global list"], list [V]")
				. += 1
		if(istype(G, /datum))
			var/datum/A = G
			if(A == targ)
				testing("GC: [A] | [A.type] referenced by [D? "[D] | [D.type]" : "global list"], list [V] at key [F]")
				. += 1
		if(islist(F))
			. += LookForListRefs(F, targ, D, "[F] in list [V]", foundcache)
		if(islist(G))
			. += LookForListRefs(G, targ, D, "[G] in list [V] at key [F]", foundcache)
#endif

#ifdef GC_FINDREF
#undef GC_FINDREF
#endif
