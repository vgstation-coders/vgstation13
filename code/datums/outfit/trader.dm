// -- Vox trader

/datum/outfit/trader

	outfit_name = "Trader"
	associated_job = /datum/job/trader

	backpack_types = list(
		BACKPACK_STRING = /obj/item/weapon/storage/backpack,
		SATCHEL_NORM_STRING = /obj/item/weapon/storage/backpack/satchel_norm,
		SATCHEL_ALT_STRING = /obj/item/weapon/storage/backpack/satchel,
		MESSENGER_BAG_STRING = /obj/item/weapon/storage/backpack/messenger,
	)

	items_to_spawn = list(
		"Default" = list(),
		/datum/species/vox = list(
			slot_w_uniform_str =/obj/item/clothing/under/vox/vox_robes,
			slot_shoes_str = /obj/item/clothing/shoes/magboots/vox,
			slot_belt_str = /obj/item/device/radio,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/trader,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/trader,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
		),
		/datum/species/mushroom = list(
			slot_w_uniform_str = /obj/item/clothing/under/stilsuit,
			slot_shoes_str = /obj/item/clothing/shoes/magboots,
			slot_belt_str = /obj/item/device/radio,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/trader/flex,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/trader/flex,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath,
		),
		/datum/species/skellington/skelevox = list(
			slot_w_uniform_str =/obj/item/clothing/under/vox/vox_robes,
			slot_shoes_str = /obj/item/clothing/shoes/magboots/vox,
			slot_belt_str = /obj/item/device/radio,
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ/trader,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ/trader,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath/vox,
		)

	)

	equip_survival_gear = list(
		/datum/species/vox = /obj/item/weapon/storage/box/survival/engineer/vox,
	)


	items_to_collect = list(
		/obj/item/weapon/storage/wallet/trader = SURVIVAL_BOX,
	)

	pda_type = null
	associated_job = /datum/job/trader
	id_type = /obj/item/weapon/card/id/vox

/datum/outfit/trader/pre_equip(var/mob/living/carbon/human/H)
	if (!H.mind)
		return
	switch(H.mind.role_alt_title) // Add to the survival box in case we don't have a backbag.
		if("Trader") //Traders get snacks and a coin
			items_to_collect[/obj/item/weapon/storage/box/donkpockets/random_amount] = SURVIVAL_BOX
			items_to_collect[/obj/item/weapon/reagent_containers/food/drinks/thermos/full] = SURVIVAL_BOX
			items_to_collect[/obj/item/weapon/coin/trader] = SURVIVAL_BOX

		if("Merchant") //Merchants get an implant
			implant_types += /obj/item/weapon/implant/loyalty

		if("Salvage Broker")
			items_to_collect[/obj/item/device/telepad_beacon] = SURVIVAL_BOX
			items_to_collect[/obj/item/weapon/rcs/salvage] = SURVIVAL_BOX
	return ..()
