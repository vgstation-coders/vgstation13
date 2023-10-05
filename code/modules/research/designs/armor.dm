/datum/design/xcomsquaddiearmor
	name = "Squaddie Armor"
	desc = "An old armor design from a shadow organization. It offers respectable protection against ballistics."
	id = "xcomsquaddiearmor"
	req_tech = list(Tc_COMBAT = 3, Tc_MATERIALS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000, MAT_GLASS = 1250, MAT_PLASTIC = 750)
	category = "Armor"
	build_path = /obj/item/clothing/suit/armor/xcomsquaddie

/datum/design/xcomoriginalarmor
	name = "Personal Armor"
	desc = "An old armor design from a shadow organization. It offers respectable protection against laser and energy weaponry."
	id = "xcomoriginalarmor"
	req_tech = list(Tc_COMBAT = 3, Tc_MATERIALS = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000, MAT_GLASS = 1250, MAT_PLASMA = 750)
	category = "Armor"
	build_path = /obj/item/clothing/suit/armor/xcomarmor

/datum/design/xcomoriginalarmor_helmet
	name = "Personal Armor Helmet"
	desc = "An old armored balaclava design from a shadow organization. It offers respectable protection against laser and energy weaponry."
	id = "xcomoriginalarmor_helmet"
	req_tech = list(Tc_COMBAT = 3, Tc_MATERIALS = 3)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 1750, MAT_GLASS = 500)
	category = "Armor"
	build_path = /obj/item/clothing/head/helmet/xcom

/*
/datum/design/security_hud
	name = "Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status."
	id = "security_hud"
	req_tech = list(Tc_MAGNETS = 3, Tc_COMBAT = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/hud/security
	category = "Armor"
	locked = 1
*/

/datum/design/sechud_sunglass
	name = "HUDSunglasses"
	desc = "Sunglasses with a heads-up display that scans the humans in view and provides accurate data about their ID status."
	id = "sechud_sunglass"
	req_tech = list(Tc_MAGNETS = 3, Tc_COMBAT = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 50, MAT_GLASS = 50)
	category = "Armor"
	build_path = /obj/item/clothing/glasses/sunglasses/sechud
	locked = 1
	req_lock_access = list(access_security)

/datum/design/ablative_armor_vest
	name = "Ablative Armor Vest"
	desc = "A vest that excels in protecting the wearer against energy projectiles."
	id = "ablative vest"
	req_tech = list(Tc_COMBAT = 4, Tc_MATERIALS = 5)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 1500, MAT_GLASS = 2500, MAT_DIAMOND = 3750, MAT_SILVER = 1000, MAT_URANIUM = 500)
	category = "Armor"
	build_path = /obj/item/clothing/suit/armor/laserproof
	locked = 1
	req_lock_access = list(access_security)

/datum/design/advancedeod
	name = "Advanced EOD Suit"
	desc = "An advanced EOD suit that affords great protection at the cost of mobility."
	id = "advanced eod suit"
	req_tech = list(Tc_COMBAT = 5, Tc_MATERIALS = 5, Tc_BIOTECH = 2)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 10000, MAT_GLASS = 2500, MAT_GOLD = 3750, MAT_SILVER = 1000)
	category = "Armor"
	build_path = /obj/item/clothing/suit/advancedeod

/datum/design/advancedeod_helmet
	name = "Advanced EOD Helmet"
	desc = "An advanced EOD helmet that affords great protection at the cost of mobility."
	id = "advanced eod helmet"
	req_tech = list(Tc_COMBAT = 5, Tc_MATERIALS = 5, Tc_BIOTECH = 2)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 3750, MAT_GLASS = 2500, MAT_GOLD = 3750, MAT_SILVER = 1000)
	category = "Armor"
	build_path = /obj/item/clothing/head/advancedeod_helmet

/datum/design/reactive_teleport_armor
	name = "Reactive Teleport Armor"
	desc = "Someone seperated our Research Director from his own head!"
	id = "reactive_teleport_armor"
	req_tech = list(Tc_BLUESPACE = 4, Tc_MATERIALS = 5)
	build_type = PROTOLATHE
	materials = list(MAT_DIAMOND = 2000, MAT_IRON = 3000, MAT_URANIUM = 3750)
	category = "Armor"
	build_path = /obj/item/clothing/suit/armor/reactive
