// -- Medical outfits
// -- CMO

/datum/outfit/cmo

	outfit_name = "Chief Medical Officer"
	associated_job = /datum/job/cmo

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/medic,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_med,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/med,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/heads/cmo,
			slot_w_uniform_str = /obj/item/clothing/under/rank/chief_medical_officer,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/storage/labcoat/cmo,
			slot_s_store_str = /obj/item/device/flashlight/pen,
		),
		/datum/species/plasmaman = list(
			slot_ears_str = /obj/item/device/radio/headset/heads/cmo,
			slot_w_uniform_str = /obj/item/clothing/under/rank/chief_medical_officer,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/medical/cmo,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/medical/cmo,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/heads/cmo,
			slot_w_uniform_str = /obj/item/clothing/under/rank/chief_medical_officer,
			slot_shoes_str = /obj/item/clothing/shoes/brown,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/medical/cmo,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/medical/cmo,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
		),
	)

	race_items_to_collect = list(
		/datum/species/vox/ = list(
			/obj/item/clothing/suit/storage/labcoat/cmo,
		),
		/datum/species/plasmaman/ = list(
			/obj/item/clothing/suit/storage/labcoat/cmo,
		)
	)

	implant_types = list(
		/obj/item/weapon/implant/loyalty/,
	)

	pda_type = /obj/item/device/pda/heads/cmo
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/cmo

/datum/outfit/cmo/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/storage/firstaid/regular(get_turf(H)))

/datum/outfit/cmo/pre_equip_priority(var/mob/living/carbon/human/H, var/species)
	items_to_collect[/obj/item/weapon/storage/belt/medical] = GRASP_LEFT_HAND
	return ..()

// -- Doctor

/datum/outfit/doctor

	outfit_name = "Medical Doctor"
	associated_job = /datum/job/doctor

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/medic,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_med,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/med,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_med,
			slot_w_uniform_str = list(
				"Emergency Physician" = /obj/item/clothing/under/rank/medical,
				"Surgeon" =  /obj/item/clothing/under/rank/medical/blue,
				"Medical Doctor" = /obj/item/clothing/under/rank/medical,
			),
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = list(
				"Emergency Physician" = /obj/item/clothing/suit/storage/fr_jacket,
				"Surgeon" =  /obj/item/clothing/suit/storage/labcoat,
				"Medical Doctor" =  /obj/item/clothing/suit/storage/labcoat,
			),
			slot_head_str = list(
				"Surgeron" = /obj/item/clothing/head/surgery/blue,
			),
			slot_s_store_str = /obj/item/device/flashlight/pen,
		),
		/datum/species/plasmaman = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_med,
			slot_w_uniform_str = list(
				"Emergency Physician" = /obj/item/clothing/under/rank/medical,
				"Surgeon" =  /obj/item/clothing/under/rank/medical/blue,
				"Medical Doctor" = /obj/item/clothing/under/rank/medical,
			),
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/medical,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/medical,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_med,
			slot_w_uniform_str = list(
				"Emergency Physician" = /obj/item/clothing/under/rank/medical,
				"Surgeon" =  /obj/item/clothing/under/rank/medical/blue,
				"Medical Doctor" = /obj/item/clothing/under/rank/medical,
			),
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/medical,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/medical,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
		),
	)

	race_items_to_collect = list(
		/datum/species/vox/ = list(
			"Emergency Physician" = list(/obj/item/clothing/under/rank/medical),
			"Surgeon" =  list(/obj/item/clothing/under/rank/medical/blue),
			"Medical Doctor" = list(/obj/item/clothing/under/rank/medical),
		),
		/datum/species/plasmaman/ = list(
			"Emergency Physician" = list(/obj/item/clothing/under/rank/medical),
			"Surgeon" =  list(/obj/item/clothing/under/rank/medical/blue),
			"Medical Doctor" = list(/obj/item/clothing/under/rank/medical),
		)
	)

	pda_type = /obj/item/device/pda/medical
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/medical

	special_snowflakes = list(
		"Default" = list(
			"Nurse" = list(slot_w_uniform_str, slot_head_str),
		),
		/datum/species/vox = list(
			"Nurse" = list(slot_w_uniform_str),
		),
		/datum/species/plasmaman = list(
			"Nurse" = list(slot_w_uniform_str),
		),
	)

// This right here is the proof that the female gender should be removed from the codebase. Fucking snowflakes

/datum/outfit/doctor/special_equip(var/title, var/slot, var/mob/living/carbon/human/H)
	switch (title)
		if ("Nurse")
			switch (slot)
				if (slot_w_uniform_str)
					if(H.gender == FEMALE)
						if(prob(50))
							H.equip_or_collect(new /obj/item/clothing/under/rank/nursesuit(H), slot_w_uniform)
						else
							H.equip_or_collect(new /obj/item/clothing/under/rank/nurse(H), slot_w_uniform)
					else
						H.equip_or_collect(new /obj/item/clothing/under/rank/medical/purple(H), slot_w_uniform)
				if (slot_head_str)
					if (H.gender == FEMALE)
						H.equip_or_collect(new /obj/item/clothing/head/nursehat(H), slot_head)

/datum/outfit/doctor/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/storage/firstaid/regular(get_turf(H)))

/datum/outfit/doctor/pre_equip_priority(var/mob/living/carbon/human/H, var/species)
	items_to_collect[/obj/item/weapon/storage/belt/medical] = GRASP_LEFT_HAND
	return ..()

// -- Chemist

/datum/outfit/chemist

	outfit_name = "Chemist"
	associated_job = /datum/job/chemist

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/medic,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_chem,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/chem,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_med,
			slot_w_uniform_str = list(
				"Chemist" =	/obj/item/clothing/under/rank/chemist,
				"Pharmacist" = /obj/item/clothing/under/rank/pharma,
			),
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/science,
			slot_wear_suit_str = /obj/item/clothing/suit/storage/labcoat/chemist,
		),
		/datum/species/plasmaman = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_med,
			slot_w_uniform_str = list(
				"Chemist" =	/obj/item/clothing/under/rank/chemist,
				"Pharmacist" = /obj/item/clothing/under/rank/pharma,
			),
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/science,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/medical/chemist,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/medical/chemist,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_med,
			slot_w_uniform_str = list(
				"Chemist" =	/obj/item/clothing/under/rank/chemist,
				"Pharmacist" = /obj/item/clothing/under/rank/pharma,
			),
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/science,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/medical/chemist,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/medical/chemist,
			slot_wear_mask_str = /obj/item/clothing/mask/breath/vox,
		),
	)

	race_items_to_collect = list(
		/datum/species/vox/ = list(
			/obj/item/clothing/suit/storage/labcoat/chemist,
		),
		/datum/species/plasmaman/ = list(
			/obj/item/clothing/suit/storage/labcoat/chemist,
		)
	)

	pda_type = /obj/item/device/pda/chemist
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/medical

/datum/outfit/chemist/pre_equip_priority(var/mob/living/carbon/human/H, var/species)
	items_to_collect[/obj/item/weapon/storage/bag/chem] = GRASP_LEFT_HAND
	return ..()

// -- Paramedic

/datum/outfit/paramedic

	outfit_name = "Paramedic"
	associated_job = /datum/job/paramedic

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/medic,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_med,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/med,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_med,
			slot_w_uniform_str = /obj/item/clothing/under/rank/medical/paramedic,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/storage/paramedic,
			slot_s_store_str = /obj/item/device/flashlight/pen,
			slot_head_str = /obj/item/clothing/head/soft/paramedic,
			slot_wear_mask_str = /obj/item/clothing/mask/cigarette,
			slot_l_store_str = /obj/item/weapon/reagent_containers/hypospray/autoinjector/biofoam_injector,
		),
		/datum/species/plasmaman = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_med,
			slot_w_uniform_str = /obj/item/clothing/under/rank/medical/paramedic,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/medical/paramedic,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/medical/paramedic,
			slot_l_store_str = /obj/item/weapon/reagent_containers/hypospray/autoinjector/biofoam_injector,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_med,
			slot_w_uniform_str = /obj/item/clothing/under/rank/medical/paramedic,
			slot_shoes_str = /obj/item/clothing/shoes/black,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/medical/paramedic,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/medical/paramedic,
			slot_l_store_str = /obj/item/weapon/reagent_containers/hypospray/autoinjector/biofoam_injector,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
		),
	)

	equip_survival_gear = list(
		/datum/species/human = /obj/item/weapon/storage/box/survival/engineer,
		/datum/species/plasmaman = /obj/item/weapon/storage/box/survival/engineer/plasmaman,
		/datum/species/diona = /obj/item/weapon/storage/box/survival/engineer,
		/datum/species/insectoid = /obj/item/weapon/storage/box/survival/engineer,
	)

	items_to_collect = list(
		/obj/item/device/healthanalyzer = SURVIVAL_BOX,
	)

	race_items_to_collect = list(
		/datum/species/vox/ = list(
			/obj/item/clothing/suit/storage/paramedic,
			/obj/item/clothing/head/soft/paramedic,
		),
		/datum/species/plasmaman/ = list(
			/obj/item/clothing/suit/storage/paramedic,
			/obj/item/clothing/head/soft/paramedic,
		)
	)

	pda_type = /obj/item/device/pda/medical
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/medical

/datum/outfit/paramedic/pre_equip_priority(var/mob/living/carbon/human/H, var/species)
	items_to_collect[/obj/item/weapon/storage/belt/medical] = GRASP_LEFT_HAND
	return ..()

// -- Geneticist

/datum/outfit/geneticist

	outfit_name = "Geneticist"
	associated_job = /datum/job/geneticist

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/medic,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_gen,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/med,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_medsci,
			slot_w_uniform_str = /obj/item/clothing/under/rank/geneticist,
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/storage/labcoat/genetics,
			slot_s_store_str = /obj/item/device/flashlight/pen,
		),
		/datum/species/plasmaman = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_medsci,
			slot_w_uniform_str = /obj/item/clothing/under/rank/geneticist,
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/medical,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/medical,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_medsci,
			slot_w_uniform_str = /obj/item/clothing/under/rank/geneticist,
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/medical/geneticist,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/medical/geneticist,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
		),
	)

	race_items_to_collect = list(
		/datum/species/vox/ = list(
			/obj/item/clothing/suit/storage/labcoat/genetics,
		),
		/datum/species/plasmaman/ = list(
			/obj/item/clothing/suit/storage/labcoat/genetics,
		)
	)

	pda_type = /obj/item/device/pda/geneticist
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/medical

/datum/outfit/geneticist/pre_equip_priority(var/mob/living/carbon/human/H, var/species)
	items_to_collect[/obj/item/weapon/storage/belt/medical] = GRASP_LEFT_HAND
	return ..()

// -- Virologist

/datum/outfit/virologist

	outfit_name = "Virologist"
	associated_job = /datum/job/virologist

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack/medic,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_vir,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger/viro,
	)

	items_to_spawn = list(
		"Default" = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_med,
			slot_w_uniform_str = /obj/item/clothing/under/rank/virologist,
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/storage/labcoat/virologist,
			slot_s_store_str = /obj/item/device/flashlight/pen,
			slot_wear_mask_str =  /obj/item/clothing/mask/surgical,
		),
		/datum/species/plasmaman = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_med,
			slot_w_uniform_str = /obj/item/clothing/under/rank/virologist,
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/space/plasmaman/medical,
			slot_head_str = /obj/item/clothing/head/helmet/space/plasmaman/medical,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/,
		),
		/datum/species/vox = list(
			slot_ears_str = /obj/item/device/radio/headset/headset_med,
			slot_w_uniform_str = /obj/item/clothing/under/rank/virologist,
			slot_shoes_str = /obj/item/clothing/shoes/white,
			slot_glasses_str = /obj/item/clothing/glasses/hud/health,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/medical/virologist,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/medical/virologist,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
		),
	)

	race_items_to_collect = list(
		/datum/species/vox/ = list(
			/obj/item/clothing/suit/storage/labcoat/virologist,
		),
		/datum/species/plasmaman/ = list(
			/obj/item/clothing/suit/storage/labcoat/virologist,
		)
	)

	pda_type = /obj/item/device/pda/viro
	pda_slot = slot_belt
	id_type = /obj/item/weapon/card/id/medical

/datum/outfit/virologist/post_equip(var/mob/living/carbon/human/H)
	..()
	H.put_in_hands(new /obj/item/weapon/book/manual/virology_guide(H))

/datum/outfit/virologist/pre_equip_priority(var/mob/living/carbon/human/H, var/species)
	items_to_collect[/obj/item/weapon/virusdish/random] = GRASP_LEFT_HAND
	return ..()
