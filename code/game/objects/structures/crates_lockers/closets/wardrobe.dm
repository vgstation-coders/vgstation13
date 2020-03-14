/obj/structure/closet/wardrobe
	name = "wardrobe"
	desc = "It's a storage unit for standard-issue Nanotrasen attire."
	icon_state = "blue"
	icon_closed = "blue"

/obj/structure/closet/wardrobe/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/color/blue = 3,
		/obj/item/clothing/shoes/brown = 3,
	)

/obj/structure/closet/wardrobe/red
	name = "security wardrobe"
	icon_state = "red"
	icon_closed = "red"

/obj/structure/closet/wardrobe/red/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/rank/security = 3,
		/obj/item/clothing/under/rank/security2 = 3,
		/obj/item/clothing/shoes/jackboots = 3,
		/obj/item/clothing/head/soft/sec = 3,
		/obj/item/clothing/head/beret/sec = 3,
		/obj/item/clothing/mask/bandana/red = 3,
	)

/obj/structure/closet/wardrobe/pink
	name = "pink wardrobe"
	icon_state = "pink"
	icon_closed = "pink"

/obj/structure/closet/wardrobe/pink/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/color/pink = 3,
		/obj/item/clothing/shoes/brown = 3,
	)

/obj/structure/closet/wardrobe/black
	name = "black wardrobe"
	icon_state = "black"
	icon_closed = "black"

/obj/structure/closet/wardrobe/black/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/color/black = 3,
		/obj/item/clothing/shoes/black = 3,
		/obj/item/clothing/head/that = 3,
	)


/obj/structure/closet/wardrobe/chaplain_black
	name = "chapel wardrobe"
	desc = "It's a storage unit for Nanotrasen-approved religious attire."
	icon_state = "black"
	icon_closed = "black"

/obj/structure/closet/wardrobe/chaplain_black/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/rank/chaplain,
		/obj/item/clothing/shoes/black,
		/obj/item/clothing/suit/nun,
		/obj/item/clothing/head/nun_hood,
		/obj/item/clothing/suit/chaplain_hoodie,
		/obj/item/clothing/head/chaplain_hood,
		/obj/item/clothing/suit/holidaypriest,
		/obj/item/clothing/under/wedding/bride_white,
		/obj/item/weapon/storage/backpack/cultpack,
		/obj/item/weapon/storage/fancy/candle_box = 2,
	)


/obj/structure/closet/wardrobe/green
	name = "green wardrobe"
	icon_state = "green"
	icon_closed = "green"

/obj/structure/closet/wardrobe/green/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/color/green = 3,
		/obj/item/clothing/shoes/black = 3,
	)

/obj/structure/closet/wardrobe/xenos
	name = "xenos wardrobe"
	icon_state = "green"
	icon_closed = "green"

/obj/structure/closet/wardrobe/xenos/atoms_to_spawn()
	return list(
		/obj/item/clothing/suit/unathi/mantle,
		/obj/item/clothing/suit/unathi/robe,
		/obj/item/clothing/shoes/sandal = 3,
	)


/obj/structure/closet/wardrobe/orange
	name = "prison wardrobe"
	desc = "It's a storage unit for Nanotrasen-regulated prisoner attire."
	icon_state = "orange"
	icon_closed = "orange"

/obj/structure/closet/wardrobe/orange/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/color/prisoner = 3,
		/obj/item/clothing/shoes/orange = 4,
		/obj/item/clothing/suit/space/plasmaman/prisoner,
		/obj/item/clothing/head/helmet/space/plasmaman/prisoner,
	)


/obj/structure/closet/wardrobe/yellow
	name = "yellow wardrobe"
	icon_state = "yellow"
	icon_closed = "yellow"

/obj/structure/closet/wardrobe/yellow/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/color/yellow = 3,
		/obj/item/clothing/shoes/orange = 3,
	)

/obj/structure/closet/wardrobe/atmospherics_yellow
	name = "atmospherics wardrobe"
	icon_state = "yellow"
	icon_closed = "yellow"

/obj/structure/closet/wardrobe/atmospherics_yellow/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/rank/atmospheric_technician = 3,
		/obj/item/clothing/shoes/workboots = 3,
	)


/obj/structure/closet/wardrobe/engineering_yellow
	name = "engineering wardrobe"
	icon_state = "yellow"
	icon_closed = "yellow"

/obj/structure/closet/wardrobe/engineering_yellow/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/rank/engineer = 2,
		/obj/item/clothing/under/rank/engine_tech = 2,
		/obj/item/clothing/under/rank/maintenance_tech = 2,
		/obj/item/clothing/under/rank/electrician = 2,
		/obj/item/clothing/shoes/workboots = 3,
	)


/obj/structure/closet/wardrobe/white
	name = "white wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/white/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/color/white = 3,
		/obj/item/clothing/shoes/white = 3,
	)


/obj/structure/closet/wardrobe/pjs
	name = "Pajama wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/pjs/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/pj/red = 2,
		/obj/item/clothing/under/pj/blue = 2,
		/obj/item/clothing/shoes/white = 2,
		/obj/item/clothing/shoes/slippers = 2,
		/obj/item/clothing/head/pajamahat/blue = 2,
		/obj/item/clothing/head/pajamahat/red = 2,
	)


/obj/structure/closet/wardrobe/toxins_white
	name = "toxins wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/toxins_white/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/rank/scientist,
		/obj/item/clothing/under/rank/xenoarch,
		/obj/item/clothing/under/rank/plasmares,
		/obj/item/clothing/under/rank/xenobio,
		/obj/item/clothing/under/rank/anomalist,
		/obj/item/clothing/suit/storage/labcoat = 3,
		/obj/item/clothing/shoes/white = 3,
		/obj/item/clothing/shoes/slippers = 3,
	)


/obj/structure/closet/wardrobe/robotics_black
	name = "robotics wardrobe"
	icon_state = "black"
	icon_closed = "black"

/obj/structure/closet/wardrobe/robotics_black/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/rank/roboticist = 2,
		/obj/item/clothing/under/rank/mechatronic = 2,
		/obj/item/clothing/under/rank/biomechanical = 2,
		/obj/item/clothing/suit/storage/labcoat = 2,
		/obj/item/clothing/shoes/black = 2,
		/obj/item/clothing/gloves/black,
		pick(
			/obj/item/clothing/glasses/hud/diagnostic,
			/obj/item/clothing/glasses/hud/diagnostic/prescription),
		/obj/item/clothing/glasses/hud/diagnostic
	)

/obj/structure/closet/wardrobe/chemistry_white
	name = "chemistry wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/chemistry_white/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/rank/chemist = 2,
		/obj/item/clothing/under/rank/pharma = 2,
		/obj/item/clothing/shoes/white = 2,
		/obj/item/clothing/suit/storage/labcoat/chemist = 2,
		/obj/item/weapon/storage/backpack/messenger/chem,
		/obj/item/weapon/storage/backpack/satchel_chem,
	)


/obj/structure/closet/wardrobe/oncology_white
	name = "oncology wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/oncology_white/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/rank/medical = 2,
		/obj/item/clothing/shoes/white = 2,
		/obj/item/clothing/suit/storage/labcoat/oncologist = 2,
	)

/obj/structure/closet/wardrobe/genetics_white
	name = "genetics wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/genetics_white/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/rank/geneticist = 2,
		/obj/item/clothing/shoes/white = 2,
		/obj/item/clothing/suit/storage/labcoat/genetics = 2,
		/obj/item/weapon/storage/backpack/satchel_gen,
	)


/obj/structure/closet/wardrobe/virology_white
	name = "virology wardrobe"
	icon_state = "viro"
	icon_closed = "viro"

/obj/structure/closet/wardrobe/virology_white/atoms_to_spawn()
	return list(
		/obj/item/clothing/monkeyclothes/doctor = 2,
		/obj/item/weapon/storage/backpack/messenger/viro,
		/obj/item/weapon/storage/backpack/satchel_vir,
		/obj/item/weapon/book/manual/virology_encyclopedia,
		/obj/item/weapon/book/manual/virology_guide,
		/obj/item/device/antibody_scanner = 2,
		/obj/item/clothing/suit/storage/labcoat/virologist = 2,
		/obj/item/clothing/under/rank/virologist = 2,
		/obj/item/clothing/mask/surgical = 2,
		/obj/item/clothing/shoes/white = 2,
		/obj/item/clothing/glasses/hud/health/prescription = 2,
	)


/obj/structure/closet/wardrobe/medic_white
	name = "medical wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/medic_white/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/rank/medical = 2,
		/obj/item/clothing/under/rank/medical/blue,
		/obj/item/clothing/under/rank/medical/green,
		/obj/item/clothing/under/rank/medical/purple,
		/obj/item/clothing/shoes/white = 2,
		/obj/item/clothing/suit/storage/labcoat = 2,
		/obj/item/clothing/mask/surgical = 2,
	)


/obj/structure/closet/wardrobe/grey
	name = "grey wardrobe"
	icon_state = "grey"
	icon_closed = "grey"

/obj/structure/closet/wardrobe/grey/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/color/grey = 3,
		/obj/item/clothing/shoes/black = 3,
		/obj/item/clothing/head/soft/grey = 3,
	)


/obj/structure/closet/wardrobe/mixed
	name = "mixed wardrobe"
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/structure/closet/wardrobe/mixed/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/color/blue,
		/obj/item/clothing/under/color/yellow,
		/obj/item/clothing/under/color/green,
		/obj/item/clothing/under/color/orange,
		/obj/item/clothing/under/color/pink,
		/obj/item/clothing/under/dress/plaid_blue,
		/obj/item/clothing/under/dress/plaid_red,
		/obj/item/clothing/under/dress/plaid_purple,
		/obj/item/clothing/shoes/blue,
		/obj/item/clothing/shoes/yellow,
		/obj/item/clothing/shoes/green,
		/obj/item/clothing/shoes/orange,
		/obj/item/clothing/shoes/purple,
		/obj/item/clothing/shoes/leather,
		/obj/item/clothing/under/casualwear,
		/obj/item/clothing/under/tourist,
	)
