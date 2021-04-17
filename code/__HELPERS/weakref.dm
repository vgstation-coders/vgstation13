// WEAK REFERENCES
//
// Weak references do not cause a hard reference to the referenced object.
// This of course means that every time you use them you are forced to check whether the reference is still valid,
// and sanely handle the scenario in which the object has been GC'd since.
//
// Basic usage is as follows:
// * Call makeweakref(datum) to get a /datum/weakref to the specified datum.
// * Call /datum/weakref/proc/get() to try to resolve the weakref. This returns null if the object has been GC'd.
// * To see if the object pointed to by a weakref is equal to another object, you can use the ~= operator.
// * For weakref <-> weakref comparisons (see if two weakrefs point to the same object), use plain !=.
//

/**
 * Gets a weak reference to an object.
 */
/proc/makeweakref(var/datum/D)
	if (D.weakref)
		return D.weakref

	var/datum/weakref/W = new
	W.ref = ref(D)
	D.weakref = W

	return W

/datum/weakref
	var/ref

/**
 * Attempts to retrieve the object referenced by the weakref, returning null if the object no longer exists.
 */
/datum/weakref/proc/get()
	var/datum/D = locate(ref)
	if (!D || !istype(D) || D.gcDestroyed || D.weakref != src)
		return null

	return D

/**
 * Compares a weakref with a regular object to see if the weakref points to the object.
 */
/datum/weakref/proc/operator~=(var/datum/other)
	return other?.weakref == src


/datum
	var/datum/weakref/weakref
