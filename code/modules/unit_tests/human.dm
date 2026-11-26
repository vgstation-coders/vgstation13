
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

// Heads (and other limbs) must keep a snapshot of their donor species. The
// donor's species datum is deleted along with the donor mob, so a live
// reference would silently turn a preserved vox head into a human head.
/datum/unit_test/human/head_reattach_keeps_species/start()
	var/turf/centre = locate(100, 100, 1)
	var/mob/living/carbon/human/donor = new(centre, "Vox")
	var/mob/living/carbon/human/recipient = new(centre, "Human")
	var/datum/species/donor_species = donor.species

	var/datum/organ/external/head/donor_head = donor.get_organ(LIMB_HEAD)
	var/obj/item/organ/external/head/head_item = donor_head.droplimb(TRUE, TRUE, TRUE, FALSE)
	assert_eq(istype(head_item), TRUE)

	var/expected_icobase = head_item.species?.icobase
	assert_eq(expected_icobase, donor_species.icobase)
	assert_eq(head_item.species == donor_species, FALSE)

	var/datum/species/head_species = head_item.species

	// This is what /mob/living/carbon/human/Destroy() does to its own species.
	QDEL_NULL(donor.species)
	assert_eq(head_item.species, head_species)

	var/datum/organ/external/head/recipient_head = recipient.get_organ(LIMB_HEAD)
	recipient_head.attach(head_item)

	assert_eq(recipient_head.species, head_species)
	assert_eq(recipient_head.species?.icobase, expected_icobase)

	qdel(donor)
	qdel(recipient)
