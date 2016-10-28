/datum/design/flora_gun
	name = "Floral Somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells. Harmless to other organic life."
	id = "flora_gun"
	req_tech = list(Tc_MATERIALS = 2, Tc_BIOTECH = 3, Tc_POWERSTORAGE = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 2000, MAT_GLASS = 500, MAT_URANIUM = 500)
	category = "Misc"
	build_path = /obj/item/weapon/gun/energy/floragun

/datum/design/janicart_upgrade
	name = "Janicart Upgrade Module"
	desc = "Used to allow the janicart to clean surfaces while moving."
	id = "janicart_upgrade"
	build_type = PROTOLATHE | MECHFAB
	build_path = /obj/item/mecha_parts/janicart_upgrade
	req_tech = list(Tc_ENGINEERING = 1, Tc_MATERIALS = 1)
	materials = list(MAT_IRON=10000)
	category = "Misc"

/datum/design/chempack
	name = "Chemical Pack"
	desc = "Useful for the storage and transport of large volumes of chemicals. Can be used in conjunction with a wide range of chemical-dispensing devices."
	id = "chempack"
	build_type = PROTOLATHE
	build_path = /obj/item/weapon/reagent_containers/chempack
	req_tech = list(Tc_ENGINEERING = 5, Tc_MATERIALS = 3, Tc_BLUESPACE = 3)
	materials = list(MAT_GLASS = 8000, MAT_IRON=2000)
	category = "Misc"

/datum/design/mannequin_frame
	name = "Cyber Mannequin Frame"
	desc = "So much effort just just display material goods."
	id = "mannequin_frame"
	build_type = MECHFAB
	build_path = /obj/structure/mannequin_frame
	req_tech = list(Tc_ENGINEERING = 1, Tc_MATERIALS = 1)
	materials = list(MAT_IRON=37500)
	category = "Misc"
