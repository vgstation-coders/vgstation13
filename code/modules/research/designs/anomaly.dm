/datum/design/scienceglasses
	name = "Science Goggles"
	desc = "You expect those glasses to protect you from science-related hazards. Maybe you shouldn't."
	id = "scienceglasses"
	req_tech = list(Tc_MATERIALS = 1, Tc_ANOMALY = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 700, MAT_GLASS = 2000)
	category = "Anomaly"
	build_path = /obj/item/clothing/glasses/science

/datum/design/depth_scanner
	name = "Depth Analysis Scanner"
	desc = "Used to check spatial depth and density of rock outcroppings."
	id = "depth_scanner"
	req_tech = list(Tc_MATERIALS = 1, Tc_ANOMALY = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 500, MAT_GLASS = 1000, MAT_GOLD = 200, MAT_SILVER = 200)
	category = "Anomaly"
	build_path = /obj/item/device/depth_scanner
/*
/datum/design/ano_scanner
	name = "Alden-Saraspova Counter"
	desc = "Aids in triangulation of exotic particles."
	id = "ano_scanner"
	req_tech = list(Tc_MATERIALS = 1, Tc_ANOMALY = 6)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 500, MAT_GLASS = 1000, MAT_GOLD = 200, MAT_URANIUM = 200)
	category = "Anomaly"
	build_path = /obj/item/device/ano_scanner
*/