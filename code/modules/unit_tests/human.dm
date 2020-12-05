
/datum/unit_test/human/start()

/datum/unit_test/human/wear_gloves_with_one_hand/start()
	var/mob/living/carbon/human/test_human = new()
	var/obj/item/clothing/gloves/yellow/test_gloves = new()

	var/datum/organ/external/organ = test_human.get_organ(LIMB_RIGHT_HAND)
	organ.droplimb(1)
	test_human.equip_to_slot_if_possible(test_gloves, slot_gloves)
	assert_eq(test_human.gloves, test_gloves)

	test_human.drop_from_inventory(test_human.gloves)
	assert_eq(test_human.gloves, null)

	organ = test_human.get_organ(LIMB_RIGHT_ARM)
	organ.droplimb(1)
	test_human.equip_to_slot_if_possible(test_gloves, slot_gloves)
	assert_eq(test_human.gloves, test_gloves)

// you CANNOT handcuff a person without both hands. This tests that
/datum/unit_test/human/handcuff_guy_with_one_hand/start()
	var/turf/centre = locate(100, 100, 1)
	var/mob/living/carbon/human/test_human = new(centre)
	var/mob/living/carbon/human/test_shitcurity = new(centre)
	var/obj/item/weapon/handcuffs/test_handcuffs = new(centre)

	var/datum/organ/external/organ = test_human.get_organ(LIMB_RIGHT_ARM)
	organ.droplimb(1)

	var/can_handcuff = test_handcuffs.attempt_apply_restraints(test_human, test_shitcurity)

	assert_eq(can_handcuff, FALSE)
