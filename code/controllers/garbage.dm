#define GC_COLLECTIONS_PER_TICK 300 // Was 100.
#define GC_COLLECTION_TIMEOUT (30 SECONDS)
#define GC_FORCE_DEL_PER_TICK 60
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
				queue -= refID
				continue
			if(remainingForceDelPerTick <= 0)
				break

			#ifdef GC_FINDREF
			to_chat(world, "picnic! searching [locate(D)]")
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
			for(var/A in _all_globals)
				found += LookForListRefs(readglobal(A), D, null, A)
			to_chat(world, "we found [found]")
			#endif


			#ifdef GC_DEBUG
			WARNING("gc process force delete [D.type]")
			#endif

			if(istype(D, /atom/movable))
				var/atom/movable/AM = D
				AM.hard_deleted = 1

			del D

			hard_dels++
			remainingForceDelPerTick--
			if(world.cpu > 80)
				#ifdef GG_DEBUG
				WARNING("GC process sleeping due to high CPU usage!")
				#endif
				sleep(calculateticks(2))

#ifdef GC_DEBUG
#undef GC_DEBUG
#endif

#undef GC_FORCE_DEL_PER_TICK
#undef GC_COLLECTION_TIMEOUT
#undef GC_COLLECTIONS_PER_TICK

/datum/garbage_collector/proc/dequeue(id)
	if (queue)
		queue -= id

	dels_count++

/*
 * NEVER USE THIS FOR /atom OTHER THAN /atom/movable
 * BASE ATOMS CANNOT BE QDEL'D BECAUSE THEIR LOC IS LOCKED.
 */
/proc/qdel(const/datum/D, ignore_pooling = 0, ignore_destroy = 0)
	if(isnull(D))
		return

	if(isnull(garbageCollector))
		del(D)
		return

	if(istype(D, /atom) && !istype(D, /atom/movable))
		WARNING("qdel() passed object of type [D.type]. qdel() cannot handle unmovable atoms.")
		del(D)
		garbageCollector.hard_dels++
		garbageCollector.dels_count++
		return

	//We are object pooling this.
	if(("[D.type]" in masterdatumPool) && !ignore_pooling)
		returnToPool(D)
		return

	if(isnull(D.gcDestroyed))
		// Let our friend know they're about to get fucked up.
		if(!ignore_destroy)
			D.Destroy()

		garbageCollector.addTrash(D)
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
	qdel(src, 1, 1)

/client/proc/qdel_toggle()
	set name = "Toggle qdel Behavior"
	set desc = "Toggle qdel usage between normal and force del()."
	set category = "Debug"

	garbageCollector.del_everything = !garbageCollector.del_everything
	to_chat(world, "<b>GC: qdel turned [garbageCollector.del_everything ? "off" : "on"].</b>")
	log_admin("[key_name(usr)] turned qdel [garbageCollector.del_everything ? "off" : "on"].")
	message_admins("<span class='notice'>[key_name(usr)] turned qdel [garbageCollector.del_everything ? "off" : "on"].</span>", 1)



#ifdef GC_FINDREF
/datum/garbage_collector/proc/LookForRefs(var/datum/D, var/datum/targ)
	. = 0
	for(var/V in D.vars)
		if(V == "contents")
			continue
		if(istype(D.vars[V], /datum))
			var/datum/A = D.vars[V]
			if(A == targ)
				testing("GC: [A] | [A.type] referenced by [D] | [D.type], var [V]")
				. += 1
		else if(islist(D.vars[V]))
			. += LookForListRefs(D.vars[V], targ, D, V)

/datum/garbage_collector/proc/LookForListRefs(var/list/L, var/datum/targ, var/datum/D, var/V)
	. = 0
	for(var/F in L)
		if(istype(F, /datum))
			var/datum/A = F
			if(A == targ)
				testing("GC: [A] | [A.type] referenced by [D? "[D] | [D.type]" : "global list"], list [V]")
				. += 1
		if(islist(F))
			. += LookForListRefs(F, targ, D, "[F] in list [V]")
#endif

#ifdef GC_FINDREF
#undef GC_FINDREF
#endif
