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
			slot_wear_suit_str = /obj/item/clothing/suit/space/vox/civ,
			slot_head_str = /obj/item/clothing/head/helmet/space/vox/civ,
			slot_wear_mask_str =  /obj/item/clothing/mask/breath,
		),
	)

	items_to_collect = list(
		/obj/item/weapon/storage/wallet/trader = "Survival Box",
	)

	pda_type = null
	associated_job = /datum/job/trader
	id_type = /obj/item/weapon/card/id/vox

/datum/outfit/trader/pre_equip(var/mob/living/carbon/human/H)
	switch(H.mind.role_alt_title) // Add to the survival box in case we don't have a backbag.
		if("Trader") //Traders get snacks and a coin
			items_to_collect[/obj/item/weapon/storage/box/donkpockets/random_amount] = "Survival Box"
			items_to_collect[/obj/item/weapon/reagent_containers/food/drinks/thermos/full] = "Survival Box"
			items_to_collect[/obj/item/weapon/coin/trader] = "Survival Box"

		if("Merchant") //Merchants get an implant
			implant_types += /obj/item/weapon/implant/loyalty

		if("Salvage Broker")
			items_to_collect[/obj/item/device/telepad_beacon] = "Survival Box"
			items_to_collect[/obj/item/weapon/rcs/salvage] = "Survival Box"
