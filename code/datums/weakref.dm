/proc/WEAKREF(var/datum/input)
	if(istype(input) && !input.gcDestroyed)
		if(istype(input, /datum/weakref))
			return input

		if(!input.weak_reference)
			input.weak_reference = new /datum/weakref(input)
		return input.weak_reference

/datum/weakref
	var/reference

/datum/weakref/New(var/datum/thing)
	reference = "\ref[thing]"

/datum/weakref/proc/resolve()
	var/datum/D = locate(reference)
	if(!D || D.gcDestroyed || D.weak_reference != src)
		return null
	return D
