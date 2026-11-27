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

// Universal speak/understand cover every language, including the ones that were
// never added to the mob's languages list, so the pickers and help pages must
// use the language helpers instead of reading the list directly.
/datum/unit_test/languages/universal_languages_cover_all_languages/start()
	var/mob/living/test_mob = new()

	var/datum/language/outside = null
	var/datum/language/restricted = null
	var/datum/language/common = all_languages[LANGUAGE_GALACTIC_COMMON]
	for (var/language_name in all_languages)
		var/datum/language/candidate = all_languages[language_name]
		if (candidate in test_mob.languages)
			continue
		if ((candidate.flags & RESTRICTED) && !istype(candidate, /datum/language/common))
			if (!restricted)
				restricted = candidate
			continue
		if (!outside)
			outside = candidate

	if (!outside)
		fail("every non-restricted language is already in the test mob's languages list")
		qdel(test_mob)
		return

	assert_eq(test_mob.can_speak_lang(outside), FALSE)
	assert_eq((outside in test_mob.get_spoken_languages()), FALSE)
	assert_eq((outside in test_mob.get_known_languages()), FALSE)

	test_mob.universal_speak = TRUE
	assert_eq(test_mob.can_speak_lang(outside), TRUE)
	assert_eq((outside in test_mob.get_spoken_languages()), TRUE)
	assert_eq((outside in test_mob.get_known_languages()), TRUE)

	// Setting the default language must accept a language that only universal
	// speak grants.
	test_mob.set_default_language(outside)
	assert_eq(test_mob.default_language, outside)

	// Universal understand alone makes it known, but not spoken.
	test_mob.universal_speak = FALSE
	test_mob.universal_understand = TRUE
	assert_eq((outside in test_mob.get_spoken_languages()), FALSE)
	assert_eq((outside in test_mob.get_known_languages()), TRUE)

	// Restricted languages only join the picker when they are in languages.
	test_mob.universal_speak = TRUE
	if (restricted)
		assert_eq(test_mob.can_speak_lang(restricted), TRUE)
		assert_eq((restricted in test_mob.get_spoken_languages()), FALSE)
		var/datum/language/previous = test_mob.default_language
		test_mob.set_default_language(restricted)
		assert_eq(test_mob.default_language, previous)

	// Galactic Common is restricted but should still be selectable by a mob that
	// can speak it through the universal flags.
	if (common && !(common in test_mob.languages))
		assert_eq((common in test_mob.get_spoken_languages()), TRUE)
		test_mob.set_default_language(common)
		assert_eq(test_mob.default_language, common)

	qdel(test_mob)

// A default language the mob can no longer speak must fall back to init_language
// (or the first known language) instead of staying selected.
/datum/unit_test/languages/default_language_falls_back_when_unspeakable/start()
	var/mob/living/test_mob = new()

	var/datum/language/known = null
	var/datum/language/outside = null
	for (var/language_name in all_languages)
		var/datum/language/candidate = all_languages[language_name]
		if (candidate.flags & RESTRICTED)
			continue
		if (!known)
			known = candidate
		else if (!outside)
			outside = candidate

	if (!known || !outside)
		fail("not enough non-restricted languages to run this test")
		qdel(test_mob)
		return

	test_mob.languages.Add(known)
	test_mob.init_language = known

	// Simulate a pAI that set a default through universal speak and then lost it.
	test_mob.universal_speak = TRUE
	test_mob.set_default_language(outside)
	assert_eq(test_mob.default_language, outside)

	test_mob.universal_speak = FALSE
	assert_eq(test_mob.get_default_language(), known)

	qdel(test_mob)

// Carbons override get_default_language(), so they need the same fallback. A
// human that picked a default through universal speak (phazon can grant and
// later remove it) must go back to a language it can speak once it loses it.
/datum/unit_test/languages/human_default_language_falls_back_when_unspeakable/start()
	var/mob/living/carbon/human/test_human = new()

	var/datum/language/outside = null
	for (var/language_name in all_languages)
		var/datum/language/candidate = all_languages[language_name]
		if ((candidate.flags & RESTRICTED) || (candidate in test_human.languages))
			continue
		outside = candidate
		break

	if (!outside)
		fail("every non-restricted language is already in the test human's languages list")
		qdel(test_human)
		return

	var/datum/language/original = test_human.get_default_language()

	test_human.universal_speak = TRUE
	test_human.set_default_language(outside)
	assert_eq(test_human.default_language, outside)

	test_human.universal_speak = FALSE
	var/datum/language/fallback = test_human.get_default_language()
	assert_eq(test_human.can_speak_lang(fallback), TRUE)
	assert_eq(fallback, original)

	qdel(test_human)
