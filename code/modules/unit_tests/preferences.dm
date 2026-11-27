/datum/unit_test/preferences/start()

// copy_to() must keep the skin tone inside the range the species can render,
// even when a saved preference is out of range for the selected species.
/datum/unit_test/preferences/skin_tone_clamped_to_species/start()
	var/turf/centre = locate(100, 100, 1)
	var/datum/preferences/prefs = new()
	prefs.init_datums()

	var/datum/preference_setting/numerical/s_tone/tone = prefs.get_pref_datum(/datum/preference_setting/numerical/s_tone)
	var/datum/preference_setting/toggle/be_random_body/random_body = prefs.get_pref_datum(/datum/preference_setting/toggle/be_random_body)
	random_body.setting = FALSE

	// Skin tone is stored inverted (35 - tone), and ResetUIFrom() hardcodes 220
	// for HAS_SKIN_TONE species, so the range is always -185..34.
	var/mob/living/carbon/human/human = new(centre, "Human")
	tone.setting = -9999
	prefs.copy_to(human)
	assert_eq(human.my_appearance.s_tone, -185)
	tone.setting = 9999
	prefs.copy_to(human)
	assert_eq(human.my_appearance.s_tone, 34)
	qdel(human)

	// Species without HAS_SKIN_TONE keep the direct 1..max_skin_tone range.
	var/mob/living/carbon/human/grey = new(centre, "Grey")
	tone.setting = -9999
	prefs.copy_to(grey)
	assert_eq(grey.my_appearance.s_tone, 1)
	tone.setting = 9999
	prefs.copy_to(grey)
	assert_eq(grey.my_appearance.s_tone, max(grey.species.max_skin_tone, 1))
	qdel(grey)

	qdel(prefs)
