/obj/structure/closet/l3closet
	name = "level-3 biohazard suit closet"
	desc = "It's a storage unit for level-3 biohazard gear."
	icon_state = "bio"

/obj/structure/closet/l3closet/atoms_to_spawn()
	return list(
		/obj/item/clothing/suit/bio_suit/general,
		/obj/item/clothing/head/bio_hood/general,
		/obj/item/clothing/glasses/scanner/science,
	)


/obj/structure/closet/l3closet/general
	icon_state = "bio_general"

/obj/structure/closet/l3closet/general/atoms_to_spawn()
	return list(
		/obj/item/clothing/suit/bio_suit/general,
		/obj/item/clothing/head/bio_hood/general,
		/obj/item/clothing/glasses/scanner/science,
	)


/obj/structure/closet/l3closet/virology
	icon_state = "bio_virology"

/obj/structure/closet/l3closet/virology/atoms_to_spawn()
	return list(
		/obj/item/clothing/suit/bio_suit/virology,
		/obj/item/clothing/head/bio_hood/virology,
		/obj/item/clothing/glasses/scanner/science,
		/obj/item/taperoll/viro
	)


/obj/structure/closet/l3closet/security
	icon_state = "bio_security"

/obj/structure/closet/l3closet/security/atoms_to_spawn()
	return list(
		/obj/item/clothing/suit/bio_suit/security,
		/obj/item/clothing/head/bio_hood/security,
		/obj/item/clothing/glasses/scanner/science,
	)


/obj/structure/closet/l3closet/janitor
	icon_state = "bio_janitor"

/obj/structure/closet/l3closet/janitor/atoms_to_spawn()
	return list(
		/obj/item/clothing/suit/bio_suit/janitor,
		/obj/item/clothing/head/bio_hood/janitor,
		/obj/item/clothing/glasses/scanner/science,
	)


/obj/structure/closet/l3closet/scientist
	icon_state = "bio_scientist"

/obj/structure/closet/l3closet/scientist/atoms_to_spawn()
	return list(
		/obj/item/clothing/suit/bio_suit/scientist,
		/obj/item/clothing/head/bio_hood/scientist,
		/obj/item/clothing/glasses/scanner/science,
	)
