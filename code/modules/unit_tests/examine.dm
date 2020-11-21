// Tests masks/hardsuits not properly hiding gender

// To hide the gender the carbon has to be covering his body AND his face

/datum/unit_test/examine/start()

/datum/unit_test/examine/hidden_identity/start()
	var/mob/living/carbon/human/test_subject = new()
	var/name = "Barack Obama"
	test_subject.real_name = name
	test_subject.name = name
	test_subject.gender = MALE

	assert_eq(test_subject.name, "Barack Obama")
	test_subject.equip_to_appropriate_slot(new /obj/item/clothing/mask/balaclava, TRUE)
	assert_eq(test_subject.name, "Unknown")
	// naked body or simple jumpsuit is not enough to hide your gender
	assert_pronoun(test_subject.get_examine_text(test_subject), "He")

	test_subject.equip_to_appropriate_slot(new /obj/item/clothing/suit/space/rig/medical, TRUE)
	assert_eq(test_subject.name, "Unknown")
	assert_pronoun(test_subject.get_examine_text(test_subject), "They")
	
	test_subject.drop_from_inventory(test_subject.wear_mask)
	assert_eq(test_subject.name, "Barack Obama")
	assert_pronoun(test_subject.get_examine_text(test_subject), "He")

	test_subject.equip_to_slot(new /obj/item/clothing/mask/cigarette, slot_wear_mask)
	assert_eq(test_subject.name, "Barack Obama")
	assert_pronoun(test_subject.get_examine_text(test_subject), "He")

/datum/unit_test/examine/hidden_identity/proc/assert_pronoun(examine_text, expected_pronoun)
	var/list/lines = splittext(examine_text, "\n")

	for(var/i = 3; i < length(lines) - 2; i++)
		var/list/words = splittext(lines[i], " ")
		var/pronoun = words[1]
		assert_eq(pronoun, expected_pronoun)
