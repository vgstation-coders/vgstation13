/*
 * Experimental procs by ESwordTheCat!
 */

/**
 * Object pooling.
 *
 * If this file is named experimental,
 * well treat this implementation as experimental experimental (redundancy intended).
 *
 * WARNING, only supports /atom/movable (/mob and /obj)
 */

// Uncomment to show debug messages.
//#define DEBUG_OBJECT_POOL

#define MAINTAINING_OBJECT_POOL_COUNT 500

var/global/list/masterPool = new

// Read-only or compile-time vars and special exceptions.
var/list/exclude = list("inhand_states", "loc", "locs", "parent_type", "vars", "verbs", "type", "x", "y", "z","group", "animate_movement")

/*
 * @args
 * A, object type
 * B, location to spawn
 *
 * Example call: getFromPool(/obj/item/weapon/shard, loc)
 */
/proc/getFromPool()
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/getFromPool() called tick#: [world.time]")
	var/A = args[1]
	var/list/B = list()
	B += (args - A)
	if(length(masterPool["[A]"]) <= 0)
		#ifdef DEBUG_OBJECT_POOL
		if(ticker)
			world << text("DEBUG_OBJECT_POOL: new proc has been called ([] | []).", A, list2params(B))
		#endif
		//so the GC knows we're pooling this type.
		if(isnull(masterPool["[A]"]))
			masterPool["[A]"] = list(new A)
		if(B && B.len)
			return new A(arglist(B))
		else
			return new A()

	var/atom/movable/O = masterPool["[A]"][1]
	masterPool["[A]"] -= O

	#ifdef DEBUG_OBJECT_POOL
	world << text("DEBUG_OBJECT_POOL: getFromPool([]) [] left arglist([]).", A, length(masterPool[A]), list2params(B))
	#endif
	if(!O || !istype(O))
		O = new A(arglist(B))
	else
		if(length(B))
			O.loc = B[1]
		O.New(arglist(B))
	return O

/*
 * @args
 * A, object instance
 *
 * @return
 * -1, if A is not a movable atom
 *
 * Example call: returnToPool(src)
 */
/proc/returnToPool(const/atom/movable/AM)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/returnToPool() called tick#: [world.time]")
	ASSERT(AM)
	if(istype(AM.loc,/mob/living))
		var/mob/living/L = AM.loc
		L.u_equip(AM,1)
	if(length(masterPool["[AM.type]"]) > MAINTAINING_OBJECT_POOL_COUNT)
		#ifdef DEBUG_OBJECT_POOL
		world << text("DEBUG_OBJECT_POOL: returnToPool([]) exceeds [] discarding...", AM.type, MAINTAINING_OBJECT_POOL_COUNT)
		#endif

		qdel(AM, 1)
		return

	if(isnull(masterPool["[AM.type]"]))
		masterPool["[AM.type]"] = list()
	AM.Destroy()
	AM.resetVariables()
	masterPool["[AM.type]"] |= AM

	#ifdef DEBUG_OBJECT_POOL
	world << text("DEBUG_OBJECT_POOL: returnToPool([]) [] left.", AM.type, length(masterPool["[AM.type]"]))
	#endif

#undef MAINTAINING_OBJECT_POOL_COUNT

#ifdef DEBUG_OBJECT_POOL
#undef DEBUG_OBJECT_POOL
#endif

/*
 * if you have a variable that needed to be preserve, override this and call ..
 *
 * example
 *
 * /obj/item/resetVariables()
 * 	..("var1", "var2", "var3")
 *
 * however, if the object has a child type an it has overridden resetVariables()
 * this should be
 *
 * /obj/item/resetVariables()
 * 	..("var1", "var2", "var3", args)
 *
 * /obj/item/weapon/resetVariables()
 * 	..("var4")
 */

//RETURNS NULL WHEN INITIALIZED AS A LIST() AND POSSIBLY OTHER DISCRIMINATORS
//IF YOU ARE USING SPECIAL VARIABLES SUCH A LIST() INITIALIZE THEM USING RESET VARIABLES
//SEE http://www.byond.com/forum/?post=76850 AS A REFERENCE ON THIS

/atom/movable/resetVariables()
	loc = null
	..("loc",args)