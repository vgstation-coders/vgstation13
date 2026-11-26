
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
// donor's species datum is hard-deleted after its mob is gone, so a live
// reference would silently turn a preserved vox head into a human head.
/datum/unit_test/human/head_reattach_keeps_species/start()
	var/turf/centre = locate(100, 100, 1)
	var/mob/living/carbon/human/donor = new(centre, "Vox")
	var/mob/living/carbon/human/recipient = new(centre, "Human")

	var/datum/organ/external/head/donor_head = donor.get_organ(LIMB_HEAD)
	var/icon/expected_icon = donor_head.get_icon("m")

	var/obj/item/organ/external/head/head_item = donor_head.droplimb(TRUE, TRUE, TRUE, FALSE)
	assert_eq(istype(head_item), TRUE)

	// Hard-delete the donor's species datum now instead of waiting for the GC.
	var/datum/species/donor_species = donor.species
	donor.species = null
	donor_species.myhuman = null
	donor_species.Destroy()
	del(donor_species)

	var/datum/organ/external/head/recipient_head = recipient.get_organ(LIMB_HEAD)
	recipient_head.attach(head_item)

	// The attached head must still render with the donor's species icon.
	assert_eq(icon2base64(recipient_head.get_icon("m")), icon2base64(expected_icon))

	qdel(donor)
	qdel(recipient)

// A limb reattached to its own body must keep using the body's live species
// datum, so updatespeciescolor() still recolors it.
/datum/unit_test/human/limb_reattach_same_body_uses_live_species/start()
	var/turf/centre = locate(100, 100, 1)
	var/mob/living/carbon/human/vox = new(centre, "Vox")

	var/datum/organ/external/l_arm/arm = vox.get_organ(LIMB_LEFT_ARM)
	var/obj/item/organ/external/l_arm/arm_item = arm.droplimb(TRUE, TRUE, TRUE, FALSE)
	assert_eq(istype(arm_item), TRUE)

	arm.attach(arm_item)
	assert_eq(arm.species, null)

	vox.my_appearance.s_tone = VOXPLUCKED
	vox.update_mutantrace()
	var/icon/expected_arm_icon = icon('icons/mob/human_races/vox/r_voxplucked.dmi', "l_arm")
	assert_eq(icon2base64(arm.get_icon()), icon2base64(expected_arm_icon))

	qdel(vox)

// Copy() must preserve runtime species changes so cross-species grafts keep
// the donor's damage modifiers, flags and colors.
/datum/unit_test/species_copy_runtime_state/start()
	var/datum/species/test_species = new /datum/species/human
	test_species.flags |= RAD_GLOW
	test_species.anatomy_flags |= NO_BLOOD
	test_species.chem_flags = 123
	test_species.brute_mod = 0.5
	test_species.burn_mod = 2
	test_species.tox_mod = 3
	test_species.blood_color = "#112233"
	test_species.flesh_color = "#445566"
	test_species.punch_damage = 7
	test_species.max_hurt_damage = 9
	test_species.breath_type = GAS_NITROGEN
	test_species.damage_overlays = list("brute")
	test_species.attack_verb = "claws"
	test_species.fireloss_mult = 1.5
	test_species.default_language = LANGUAGE_VOX

	var/datum/species/test_copy = test_species.Copy()
	assert_eq((test_copy.flags & RAD_GLOW), RAD_GLOW)
	assert_eq((test_copy.anatomy_flags & NO_BLOOD), NO_BLOOD)
	assert_eq(test_copy.chem_flags, 123)
	assert_eq(test_copy.brute_mod, 0.5)
	assert_eq(test_copy.burn_mod, 2)
	assert_eq(test_copy.tox_mod, 3)
	assert_eq(test_copy.blood_color, "#112233")
	assert_eq(test_copy.flesh_color, "#445566")
	assert_eq(test_copy.punch_damage, 7)
	assert_eq(test_copy.max_hurt_damage, 9)
	assert_eq(test_copy.breath_type, GAS_NITROGEN)
	assert_eq(test_copy.damage_overlays.len, 1)
	assert_eq(test_copy.damage_overlays[1], "brute")
	assert_eq(test_copy.attack_verb, "claws")
	assert_eq(test_copy.fireloss_mult, 1.5)
	assert_eq(test_copy.default_language, LANGUAGE_VOX)

// A same-species graft must keep the donor's snapshot after being removed and
// reattached: the recipient's DNA is not proof that the limb came from it.
/datum/unit_test/human/limb_regraft_keeps_donor_species/start()
	var/turf/centre = locate(100, 100, 1)
	var/mob/living/carbon/human/donor = new(centre, "Vox")
	var/mob/living/carbon/human/recipient = new(centre, "Vox")

	donor.my_appearance.s_tone = VOXEMERALD
	donor.update_mutantrace()
	recipient.my_appearance.s_tone = VOXAZURE
	recipient.update_mutantrace()

	var/datum/organ/external/l_arm/donor_arm = donor.get_organ(LIMB_LEFT_ARM)
	var/obj/item/organ/external/l_arm/arm_item = donor_arm.droplimb(TRUE, TRUE, TRUE, FALSE)
	assert_eq(istype(arm_item), TRUE)

	var/datum/organ/external/l_arm/recipient_arm = recipient.get_organ(LIMB_LEFT_ARM)
	recipient_arm.attach(arm_item)

	// Remove it from the recipient and put it back. This regraft used to make
	// the limb adopt the recipient's colours.
	var/obj/item/organ/external/l_arm/regraft_item = recipient_arm.droplimb(TRUE, TRUE, TRUE, FALSE)
	assert_eq(istype(regraft_item), TRUE)
	recipient_arm.attach(regraft_item)

	var/icon/expected = icon('icons/mob/human_races/vox/r_voxemrl.dmi', "l_arm")
	assert_eq(icon2base64(recipient_arm.get_icon()), icon2base64(expected))

	qdel(donor)
	qdel(recipient)
