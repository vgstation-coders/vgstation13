/datum/design/mech_armor_mining
	name = "Module Design (Mecha Mining Plating)"
	id = "mech_armor_mining"
	build_type = MECHFAB
	req_tech = list(Tc_MATERIALS = 1)
	build_path = /obj/item/mecha_parts/component/armor/mining
	category = "Exosuit_Armor"
	materials = list(MAT_IRON=15000)

/datum/design/mech_armor_lightweight
	name = "Module Design (Mecha Lightweight Plating)"
	id = "mech_armor_lightweight"
	build_type = MECHFAB
	req_tech = list(Tc_MATERIALS = 1)
	build_path = /obj/item/mecha_parts/component/armor/lightweight
	category = "Exosuit_Armor"
	materials = list(MAT_IRON = 5000, MAT_PLASTIC = 2500, MAT_GLASS = 2500)

/datum/design/mech_armor_reinforced
	name = "Module Design (Mecha Reinforced Plating)"
	id = "mech_armor_reinforced"
	build_type = MECHFAB
	req_tech = list(Tc_MATERIALS = 3)
	build_path = /obj/item/mecha_parts/component/armor/reinforced
	category = "Exosuit_Armor"
	materials = list(MAT_IRON = 30000)

/datum/design/mech_armor_military
	name = "Module Design (Mecha Military Plating)"
	id = "mech_armor_military"
	build_type = MECHFAB
	req_tech = list(Tc_MATERIALS = 5, Tc_COMBAT = 4)
	build_path = /obj/item/mecha_parts/component/armor/military
	category = "Exosuit_Armor"
	materials = list(MAT_IRON = 30000, MAT_PLASMA = 20000)

/datum/design/mech_armor_marshal
	name = "Module Design (Mecha Marshal Plating)"
	id = "mech_armor_marshal"
	build_type = MECHFAB
	req_tech = list(Tc_MATERIALS = 5, Tc_COMBAT = 4)
	build_path = /obj/item/mecha_parts/component/armor/marshal
	category = "Exosuit_Armor"
	materials = list(MAT_IRON = 15000, MAT_PLASTIC = 15000, MAT_GLASS = 15000, MAT_SILVER = 5000)

/datum/design/mech_armor_striker
	name = "Module Design (Mecha Striker Plating)"
	id = "mech_armor_striker"
	build_type = MECHFAB
	req_tech = list(Tc_MATERIALS = 7, Tc_COMBAT = 6)
	build_path = /obj/item/mecha_parts/component/armor/marshal/striker
	category = "Exosuit_Armor"
	materials = list(MAT_IRON = 5000, MAT_PLASTIC = 15000, MAT_PLASMA = 15000, MAT_GLASS = 15000, MAT_SILVER = 5000, MAT_DIAMOND = 5000)

/datum/design/mech_armor_marauder
	name = "Module Design (Mecha Marauder/Ultraheavy Plating)"
	id = "mech_armor_marauder"
	build_type = MECHFAB
	req_tech = list(Tc_MATERIALS = 9, Tc_COMBAT = 6, Tc_NANOTRASEN = 5)
	build_path = /obj/item/mecha_parts/component/armor/military/marauder
	category = "Exosuit_Armor"
	materials = list(MAT_IRON = 50000, MAT_PLASMA = 30000, MAT_URANIUM = 30000, MAT_DIAMOND = 10000)

/datum/design/mech_armor_alien
	name = "Module Design (Mecha Bizarre Plating)"
	id = "mech_armor_alien"
	build_type = MECHFAB
	req_tech = list(Tc_MATERIALS = 9, Tc_BLUESPACE = 10)
	build_path = /obj/item/mecha_parts/component/armor/alien
	category = "Exosuit_Armor"
	materials = list(MAT_IRON = 15000, MAT_PHAZON = 15000, MAT_DIAMOND = 5000)
