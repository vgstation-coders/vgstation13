
//legacy crystal
/obj/machinery/crystal
	name = "Crystal"
	icon = 'icons/obj/mining.dmi'
	icon_state = "crystal"

/obj/machinery/crystal/New()
	if(prob(50))
		icon_state = "crystal2"

//large finds
				/*
				/obj/machinery/syndicate_beacon
				/obj/machinery/wish_granter
			if(18)
				item_type = "jagged green crystal"
				additional_desc = pick("It shines faintly as it catches the light.","It appears to have a faint inner glow.","It seems to draw you inward as you look it at.","Something twinkles faintly as you look at it.","It's mesmerizing to behold.")
				icon_state = "crystal"
				apply_material_decorations = 0
				if(prob(10))
					apply_image_decorations = 1
			if(19)
				item_type = "jagged pink crystal"
				additional_desc = pick("It shines faintly as it catches the light.","It appears to have a faint inner glow.","It seems to draw you inward as you look it at.","Something twinkles faintly as you look at it.","It's mesmerizing to behold.")
				icon_state = "crystal2"
				apply_material_decorations = 0
				if(prob(10))
					apply_image_decorations = 1
				*/
			//machinery type artifacts?

/obj/item/weapon/storage/box/large/xa_excasuit
	desc = "There's a label on the box: 'Retired Excavation Suit. Dispose ASAP'. The box is warped beyond use, but it could be used in research or broken down and remade."
	can_only_hold = null
	items_to_spawn = list(/obj/item/clothing/head/helmet/space/anomaly, /obj/item/clothing/suit/space/anomaly)
	mech_flags = MECH_SCAN_FAIL

/obj/item/weapon/storage/box/large/xa_anomsuit
	desc = "There's a label on the box: 'Retired Anomaly Suit. Dispose ASAP'. The box is warped beyond use, but it could be used in research or broken down and remade."
	can_only_hold = null
	items_to_spawn = list(/obj/item/clothing/head/bio_hood/anomaly/old, /obj/item/clothing/suit/bio_suit/anomaly/old)
	mech_flags = MECH_SCAN_FAIL

/obj/item/weapon/storage/box/large/nasasuit
	desc = "There's a label on the box: 'Retired Space Suit'. The box is warped beyond use, but it could be used in research or broken down and remade."
	can_only_hold = null
	items_to_spawn = list(/obj/item/clothing/head/helmet/space/ancient, /obj/item/clothing/suit/space/ancient)
	mech_flags = MECH_SCAN_FAIL

/obj/item/weapon/blood_tesseract/xenoarchfind
	mech_flags = MECH_SCAN_FAIL //Redundant flag, but adding it just in case.

/obj/item/weapon/blood_tesseract/xenoarchfind/New()
	..()
	var/list/choices = pick(
		35;list(/obj/item/clothing/head/magus, /obj/item/clothing/suit/magusred),
		25;list(/obj/item/clothing/suit/cultrobes/old),
		20;list(/obj/item/clothing/suit/cultrobes),
		15;list(/obj/item/clothing/head/helmet/space/cult, /obj/item/clothing/suit/space/cult),
		5;list(/obj/item/clothing/head/helmet/space/legacy_cult, /obj/item/clothing/suit/space/legacy_cult)
		)
		//aims to retain something along the lines of the old rarity system for all the cult robes/suits.
	for(var/I in choices)
		I = new I(src)
		contents += I
