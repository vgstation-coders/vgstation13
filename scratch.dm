/datum
	var/gcDestroyed = ""
	var/disposed = FALSE

/datum/proc/Destroy()
	disposed = TRUE
	tag = null

#define DEBUG_OBJECT_POOL
#define MAINTAIN_OBJECT_POOL_COUNT 100

/proc/get_from_pool()
	var/type_path = args[1]

	#ifdef DEBUG_OBJECT_POOL
	ASSERT(ispath(type_path))
	#endif

	if (isnull(type_path))
		return

	var/list/object_args = args - type_path
	var/list/objects_list = masterPool["[type_path]"]

	if (isnull(objects_list))
		objects_list = new/list()

	var/datum/O

	if (objects_list.len)
		O = objects_list[1]

	if (isnull(O))
		if (object_args && object_args.len)
			O = new type_path(arglist(object_args))
		else
			O = new type_path()
	else
		objects_list -= O

		#ifdef DEBUG_OBJECT_POOL
		world << "DEBUG_OBJECT_POOL: get_from_pool([type_path]) - [length(masterPool["[type_path]"])] left, args([list2params(object_args)])"
		#endif

		if (object_args && object_args.len)
			O.New(arglist(object_args))
		else
			O.New()

	return O

/proc/return_to_pool(datum/O)
	#ifdef DEBUG_OBJECT_POOL
	ASSERT(istype(O))
	#endif

	if (isnull(O) || O.disposed)
		return

	if (length(masterPool["[O.type]"]) > MAINTAIN_OBJECT_POOL_COUNT)
		qdel(O, TRUE)
		return
	else
		if (isnull(masterPool["[O.type]"]))
			masterPool["[O.type]"] = new/list()

	O.Destroy()
	O.resetVariables()

	masterPool["[O.type]"] += O

	#ifdef DEBUG_OBJECT_POOL
	world << "DEBUG_OBJECT_POOL: return_to_pool([O.type]) - [length(masterPool["[O.type]"])] left"
	#endif

#ifdef DEBUG_OBJECT_POOL
#undef DEBUG_OBJECT_POOL
#endif

#undef MAINTAIN_OBJECT_POOL_COUNT
