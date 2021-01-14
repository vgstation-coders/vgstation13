/proc/makeweakref(var/datum/D)
	if (D.weakref)
		return D.weakref

	var/datum/weakref/W = new
	W.ref = ref(D)
	D.weakref = W

	return W

/datum/weakref
	var/ref

/datum/weakref/proc/get()
	var/datum/D = locate(ref)
	if (!D || !istype(D) || D.weakref != src)
		return null

	return D

/datum
	var/datum/weakref/weakref
