/datum/unit_test/languages/start()
	var/list/keys_used = list()
	for (var/language in subtypesof(/datum/language))
		var/datum/language/L = new language

		// 1. Check the list
		var/list/dupes = list()
		for (var/name in keys_used)
			if (keys_used[name] == L.key)
				dupes += name
		if (dupes.len)
			fail("[L.name] ([L.key]) uses a duplicate key. Dupes: [english_list(dupes)]")

		// 2. Add it
		keys_used[L.name] = L.key

