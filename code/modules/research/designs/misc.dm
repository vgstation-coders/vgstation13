/datum/design/flora_gun
	name = "Floral Somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells. Harmless to other organic life."
	id = "flora_gun"
	req_tech = list("materials" = 2, "biotech" = 3, "powerstorage" = 3)
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
	req_tech = list("engineering" = 1, "materials" = 1)
	materials = list(MAT_IRON=10000)
	category = "Misc"

/datum/design/chempack
	name = "Chemical Pack"
	desc = "Useful for the storage and transport of large volumes of chemicals. Can be used in conjunction with a wide range of chemical-dispensing devices."
	id = "chempack"
	build_type = PROTOLATHE
	build_path = /obj/item/weapon/reagent_containers/chempack
	req_tech = list("engineering" = 5, "materials" = 3, "bluespace" = 3)
	materials = list(MAT_GLASS = 8000, MAT_IRON=2000)
	category = "Misc"

/datum/design/uvlight
	name = "UV Light"
	desc = "A stock part used in the construction of various devices."
	id = "uvlight"
	req_tech = list("magnets" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	build_path = /obj/item/device/uv_light
	materials = list(MAT_IRON = 50, MAT_GLASS = 20)
	category = "Misc"
