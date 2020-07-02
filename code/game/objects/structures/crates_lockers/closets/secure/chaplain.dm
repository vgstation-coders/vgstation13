/obj/structure/closet/secure_closet/chaplain
	name = "chapel wardrobe"
	desc = "A lockable storage unit for Nanotrasen-approved religious attire."
	req_access = list(access_chapel_office)
	icon_state = "chaplainsecure1"
	icon_closed = "chaplainsecure"
	icon_locked = "chaplainsecure1"
	icon_opened = "chaplainsecureopen"
	icon_broken = "chaplainsecurebroken"
	icon_off = "chaplainsecureoff"

/obj/structure/closet/secure_closet/chaplain/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/rank/chaplain,
		/obj/item/clothing/shoes/black,
		/obj/item/clothing/suit/nun,
		/obj/item/clothing/head/nun_hood,
		/obj/item/clothing/suit/chaplain_hoodie,
		/obj/item/clothing/head/chaplain_hood,
		/obj/item/clothing/suit/holidaypriest,
		/obj/item/clothing/under/wedding/bride_white,
		/obj/item/clothing/head/hasturhood,
		/obj/item/clothing/suit/hastur,
		/obj/item/clothing/suit/unathi/robe,
		/obj/item/clothing/head/wizard/amp, //This will need to be removed when/if psychic wizards are properly implemented
		/obj/item/clothing/suit/wizrobe/psypurple, //This will need to be removed when/if psychic wizards are properly implemented
		/obj/item/clothing/suit/imperium_monk,
		/obj/item/clothing/mask/chapmask,
		/obj/item/clothing/under/sl_suit,
		/obj/item/weapon/storage/backpack/cultpack,
		/obj/item/weapon/storage/fancy/candle_box = 2,
	)
