/datum/design/intellicard
	name = "Intellicard AI Transportation System"
	desc = "Allows for the construction of an intellicard."
	id = "intellicard"
	req_tech = list(Tc_PROGRAMMING = 4, Tc_MATERIALS = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 200)
	category = "Data"
	build_path = /obj/item/device/aicard

/datum/design/paicard
	name = "Personal Artificial Intelligence Card"
	desc = "Allows for the construction of a pAI Card."
	id = "paicard"
	req_tech = list(Tc_PROGRAMMING = 2)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 500, MAT_IRON = 500)
	category = "Data"
	build_path = /obj/item/device/paicard

/datum/design/np_dispenser
	name = "Nano Paper Dispenser"
	desc = "A machine to create Nano Paper."
	id = "np_dispenser"
	req_tech = list(Tc_PROGRAMMING = 2, Tc_MATERIALS = 2)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 500, MAT_IRON = 1000, MAT_GOLD = 500)
	category = "Data"
	build_path = /obj/item/weapon/paper_bin/nano

/datum/design/diskette_box
	name = "Diskette Box"
	desc = "A small box for storing additional disks."
	id = "disk_box"
	req_tech = list(Tc_MATERIALS = 2)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 50, MAT_IRON = 200)
	category = "Data"
	build_path = /obj/item/weapon/storage/lockbox/diskettebox

/datum/design/design_disk
	name = "Design Storage Disk"
	desc = "Produce additional disks for storing device designs."
	id = "design_disk"
	req_tech = list(Tc_PROGRAMMING = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_IRON = 30, MAT_GLASS = 10)
	category = "Data"
	build_path = /obj/item/weapon/disk/design_disk

/datum/design/tech_disk
	name = "Technology Data Storage Disk"
	desc = "Produce additional disks for storing technology data."
	id = "tech_disk"
	req_tech = list(Tc_PROGRAMMING = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_IRON = 30, MAT_GLASS = 10)
	category = "Data"
	build_path = /obj/item/weapon/disk/tech_disk

/datum/design/archive_diskset
	name = "Archive-Ready Diskset"
	desc = "A set of nine disks ready to be archived. The disks are printed with the technology data from this terminal in a process that is convenient but very resource wasteful."
	req_tech = list(Tc_PROGRAMMING = 5)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 20000, MAT_GLASS = 10000)
	id = "archivedisks"
	category = "Data"
	build_path = /obj/item/weapon/storage/lockbox/diskettebox/archive

/datum/design/archive_diskset/after_craft(var/obj/O, var/obj/machinery/r_n_d/fabricator/F)
	for(var/datum/tech/T in get_list_of_elements(F.linked_console.files.known_tech))
		if(T.id in list("syndicate", "Nanotrasen", "anomaly"))
			continue
		var/obj/item/weapon/disk/tech_disk/TD = new(O)
		TD.stored = create_tech(T.id)
		TD.stored.level = T.level
	O.update_icon()

/datum/design/botany_disk
	name = "Floral Data Disk"
	desc = "Produce additional disks for copying botany genetic data."
	id = "floral_disk"
	req_tech = list(Tc_PROGRAMMING = 2, Tc_BIOTECH = 2)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_IRON = 30, MAT_GLASS = 10)
	category = "Data"
	build_path = /obj/item/weapon/disk/botany

/datum/design/cloning_disk
	name = "Genetic Data Disk"
	desc = "Produce additional disks for copying cloning genetic data."
	id = "cloning_disk"
	req_tech = list(Tc_PROGRAMMING = 2, Tc_BIOTECH = 3)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_IRON = 30, MAT_GLASS = 10)
	category = "Data"
	build_path = /obj/item/weapon/disk/data
