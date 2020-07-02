/obj/structure/closet/athletic_mixed
	name = "athletic wardrobe"
	desc = "It's a storage unit for athletic wear."
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/structure/closet/athletic_mixed/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/shorts/grey,
		/obj/item/clothing/under/shorts/black,
		/obj/item/clothing/under/shorts/red,
		/obj/item/clothing/under/shorts/blue,
		/obj/item/clothing/under/shorts/green,
		/obj/item/clothing/under/swimsuit/red,
		/obj/item/clothing/under/swimsuit/black,
		/obj/item/clothing/under/swimsuit/blue,
		/obj/item/clothing/under/swimsuit/green,
		/obj/item/clothing/under/swimsuit/purple,
	)

/obj/structure/closet/boxinggloves
	name = "boxing gloves"
	desc = "It's a storage unit for gloves for use in the boxing ring."

/obj/structure/closet/boxinggloves/atoms_to_spawn()
	return list(
		/obj/item/clothing/gloves/boxing/blue,
		/obj/item/clothing/gloves/boxing/green,
		/obj/item/clothing/gloves/boxing/yellow,
		/obj/item/clothing/gloves/boxing,
	)


/obj/structure/closet/masks
	name = "mask closet"
	desc = "IT'S A STORAGE UNIT FOR FIGHTER MASKS OLE!"

/obj/structure/closet/masks/atoms_to_spawn()
	return list(
		/obj/item/clothing/mask/luchador,
		/obj/item/clothing/mask/luchador/rudos,
		/obj/item/clothing/mask/luchador/tecnicos,
	)


/obj/structure/closet/lasertag/red
	name = "red laser tag equipment"
	desc = "It's a storage unit for laser tag equipment."
	icon_state = "red"
	icon_closed = "red"

/obj/structure/closet/lasertag/red/atoms_to_spawn()
	return list(
		/obj/item/weapon/gun/energy/tag/red = 6,
		/obj/item/clothing/suit/tag/redtag = 6,
	)


/obj/structure/closet/lasertag/blue
	name = "blue laser tag equipment"
	desc = "It's a storage unit for laser tag equipment."
	icon_state = "blue"
	icon_closed = "blue"

/obj/structure/closet/lasertag/blue/atoms_to_spawn()
	return list(
		/obj/item/weapon/gun/energy/tag/blue = 6,
		/obj/item/clothing/suit/tag/bluetag = 6,
	)
