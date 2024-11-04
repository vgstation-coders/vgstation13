//Biosuit complete with shoes (in the item sprite)
/obj/item/clothing/head/bio_hood
	name = "bio hood"
	icon_state = "bio"
	desc = "A hood that protects the head and face from biological comtaminants."
	permeability_coefficient = 0.01
	flags = FPRINT
	clothing_flags = PLASMAGUARD
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 20)
	body_parts_covered = HEAD|EARS|EYES|MOUTH|HIDEHAIR
	body_parts_visible_override = EYES|BEARD
	siemens_coefficient = 0.9
	sterility = 100
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)


/obj/item/clothing/suit/bio_suit
	name = "bio suit"
	desc = "A suit that protects against biological contamination."
	icon_state = "bio"
	item_state = "bio_suit"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED, GREY_SHAPED)
	w_class = W_CLASS_LARGE//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags = FPRINT
	clothing_flags = PLASMAGUARD | ONESIZEFITSALL
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS|HIDETAIL
	slowdown = HARDSUIT_SLOWDOWN_LOW
	allowed = list(/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen,/obj/item/weapon/pen,/obj/item/device/flashlight/pen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 20)
	siemens_coefficient = 0.9
	sterility = 100



//Standard biosuit, orange stripe
/obj/item/clothing/head/bio_hood/general
	icon_state = "bio_general"

/obj/item/clothing/suit/bio_suit/general
	icon_state = "bio_general"


//Virology biosuit, green stripe
/obj/item/clothing/head/bio_hood/virology
	icon_state = "bio_virology"

/obj/item/clothing/suit/bio_suit/virology
	icon_state = "bio_virology"


//Security biosuit, grey with red stripe across the chest
/obj/item/clothing/head/bio_hood/security
	name = "security bio hood"
	desc = "A hood that protects the head and face from biological comtaminants. It has a reinforced synthetic lining to protect against tearing."
	icon_state = "bio_security"
	armor = list(melee = 25, bullet = 10, laser = 15, energy = 5, bomb = 5, bio = 100, rad = 20)

/obj/item/clothing/suit/bio_suit/security
	name = "security bio suit"
	desc = "A suit that protects against biological contamination. It has a reinforced synthetic lining to protect against tearing."
	icon_state = "bio_security"
	species_fit = list(INSECT_SHAPED)
	allowed = list(
		/obj/item/weapon/gun/energy,
		/obj/item/weapon/reagent_containers/spray/pepper,
		/obj/item/weapon/gun/projectile,
		/obj/item/ammo_storage,
		/obj/item/ammo_casing,
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/handcuffs,
		/obj/item/weapon/gun/lawgiver,
		/obj/item/weapon/gun/siren,
		/obj/item/weapon/gun/mahoguny,
		/obj/item/weapon/gun/grenadelauncher,
		/obj/item/weapon/bikehorn/baton,
		/obj/item/weapon/blunderbuss,
		/obj/item/weapon/legcuffs/bolas,
		/obj/item/device/hailer)
	armor = list(melee = 25, bullet = 10, laser = 15, energy = 5, bomb = 5, bio = 100, rad = 20)


//Janitor's biosuit, grey with purple arms
/obj/item/clothing/head/bio_hood/janitor
	icon_state = "bio_janitor"

/obj/item/clothing/suit/bio_suit/janitor
	icon_state = "bio_janitor"


//Scientist's biosuit, white with a pink-ish hue
/obj/item/clothing/head/bio_hood/scientist
	icon_state = "bio_scientist"

/obj/item/clothing/suit/bio_suit/scientist
	icon_state = "bio_scientist"


//CMO's biosuit, blue stripe
/obj/item/clothing/suit/bio_suit/cmo
	icon_state = "bio_cmo"

/obj/item/clothing/head/bio_hood/cmo
	icon_state = "bio_cmo"


//Beekeeper's biosuit, white with a bee on its back
/obj/item/clothing/suit/bio_suit/beekeeping
	name = "beekeeping suit"
	icon_state = "bio_beekeeping"
	species_fit = list(INSECT_SHAPED)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 70, rad = 0)
	sterility = 50

/obj/item/clothing/head/bio_hood/beekeeping
	name = "beekeeping hood"
	icon_state = "bio_beekeeping"

	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 30, rad = 0)
	sterility = 50

	body_parts_visible_override = FACE


//Plague Dr mask can be found in clothing/masks/gasmask.dm
/obj/item/clothing/suit/bio_suit/plaguedoctorsuit
	name = "Plague doctor suit"
	desc = "It protected doctors from the Black Death, back then. You bet your arse it's gonna help you against viruses."
	icon_state = "plaguedoctor"
	item_state = "bio_suit"
	species_fit = list(INSECT_SHAPED)
	clothing_flags = PLASMAGUARD
