/datum/outfit/ninja
	name = "Space Ninja"
	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/space/space_ninja
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/space_ninja
	head = /obj/item/clothing/head/helmet/space/space_ninja
	ears = /obj/item/device/radio/headset
	shoes = /obj/item/clothing/shoes/space_ninja
	gloves = /obj/item/clothing/gloves/space_ninja
	back = /obj/item/tank/jetpack/carbondioxide
	l_pocket = /obj/item/grenade/plastic/x4
	r_pocket = /obj/item/tank/internals/emergency_oxygen
	internals_slot = slot_r_store
	belt = /obj/item/energy_katana
	implants = list(/obj/item/implant/explosive)


/datum/outfit/ninja/post_equip(mob/living/carbon/human/H)
	if(istype(H.wear_suit, suit))
		var/obj/item/clothing/suit/space/space_ninja/S = H.wear_suit
		if(istype(H.belt, belt))
			S.energyKatana = H.belt
		S.randomize_param()

