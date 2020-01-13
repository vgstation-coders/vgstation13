var/list/datum_donotcopy = list("tag", "type", "parent_type", "vars", "gcDestroyed", "being_sent_to_past", "disposed")

// NOTE: datum2list and datum2json are pretty snowflakey and won't recurse properly in some cases
// specfically it checks for infinite recursion only one level down, so if you have:
// thing1
// 		thing2
//			thing3 referencing thing1
// you'll end up in an infinite loop
// don't use it for that that's bad
proc/datum2list(var/datum/D, var/list/do_not_copy=datum_donotcopy, parent_datum=null)
	var/list/L = list()
	for(var/I in D.vars)
		if(I in do_not_copy)
			continue
		L.Add(I)
		if(istype(D.vars[I], /list))
			var/list/item = D.vars[I]
			item = item.Copy() // so we get a copy of the list from vars instead

			var/iter = 0 // i'm running out of variables names
			// this next loop is gonna assume non-iterative
			for(var/X in item)
				iter++
				if(istype(X, /datum))
					if(X == parent_datum)
						item[iter] = "parentRecursionPrevention"
					else
						item[iter] = datum2list(X, do_not_copy, parent_datum)
			L[I] = item
		else
			L[I] = D.vars[I]
	return L

// converts a datum (including atoms!) to a JSON object
// do_not_copy is a list of vars to not include in the JSON output
proc/datum2json(var/datum/D, var/list/do_not_copy=datum_donotcopy)
	ASSERT(istype(D))

	var/list/L = datum2list(D, do_not_copy)
	for(var/I in L)
		if(istype(L[I], /datum))
			L[I] = datum2list(L[I], do_not_copy, D)
		else
			L[I] = L[I]
	return json_encode(L)
