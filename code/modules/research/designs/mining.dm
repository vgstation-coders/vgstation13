
/datum/design/drill
	name = "Mining Drill"
	desc = "Yours is the drill that will pierce through the rock walls."
	id = "drill"
	req_tech = list(Tc_MATERIALS = 2, Tc_POWERSTORAGE = 3, Tc_ENGINEERING = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 6000, MAT_GLASS = 1000) //expensive, but no need for miners.
	category = "Mining"
	build_path = /obj/item/weapon/pickaxe/drill

/datum/design/plasmacutter
	name = "Plasma Cutter"
	desc = "You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	id = "plasmacutter"
	req_tech = list(Tc_MATERIALS = 4, Tc_PLASMATECH = 3, Tc_ENGINEERING = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 1500, MAT_GLASS = 500, MAT_GOLD = 500, MAT_PLASMA = 500)
	reliability_base = 79
	category = "Mining"
	build_path = /obj/item/weapon/pickaxe/plasmacutter

/datum/design/drill_diamond
	name = "Diamond Mining Drill"
	desc = "Yours is the drill that will pierce the heavens!"
	id = "drill_diamond"
	req_tech = list(Tc_MATERIALS = 6, Tc_POWERSTORAGE = 4, Tc_ENGINEERING = 4)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 3000, MAT_GLASS = 1000, MAT_DIAMOND = 3750) //Yes, a whole diamond is needed.
	reliability_base = 79
	category = "Mining"
	build_path = /obj/item/weapon/pickaxe/drill/diamond

/datum/design/mesons
	name = "Optical Meson Scanners"
	desc = "Used for seeing walls, floors, and stuff through anything."
	id = "mesons"
	req_tech = list(Tc_MAGNETS = 2, Tc_ENGINEERING = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 50, MAT_GLASS = 50)
	category = "Mining"
	build_path = /obj/item/clothing/glasses/scanner/meson

/datum/design/excavationdrill
	name = "Excavation Drill"
	desc = "Basic archaeological drill combining ultrasonic excitation and bluespace manipulation to provide extreme precision. The tip is adjustable from 1 to 30 cms."
	id = "excavationdrill"
	req_tech = list(Tc_MATERIALS = 2, Tc_POWERSTORAGE = 3, Tc_ENGINEERING = 3, Tc_BLUESPACE = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 6000, MAT_GLASS = 1000)
	category = "Mining"
	build_path = /obj/item/weapon/pickaxe/excavationdrill

/datum/design/Dexcavationdrill
	name = "Diamond Excavation Drill"
	desc = "Advanced archaeological drill combining ultrasonic excitation and bluespace manipulation to provide extreme precision. The diamond tip is adjustable from 1 to 100 cms."
	id = "Dexcavationdrill"
	req_tech = list(Tc_MATERIALS = 6, Tc_POWERSTORAGE = 3, Tc_ENGINEERING = 3, Tc_BLUESPACE = 4)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000, MAT_GLASS = 1000, MAT_SILVER = 1000, MAT_DIAMOND = 750)
	category = "Mining"
	build_path = /obj/item/weapon/pickaxe/excavationdrill/adv
