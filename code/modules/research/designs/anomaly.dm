/datum/design/scienceglasses
	name = "Science Goggles"
	desc = "You expect those glasses to protect you from science-related hazards. Maybe you shouldn't."
	id = "scienceglasses"
	req_tech = list(Tc_MATERIALS = 1, Tc_ANOMALY = 1)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 700, MAT_GLASS = 2000)
	category = "Anomaly"
	build_path = /obj/item/clothing/glasses/science

/datum/design/depth_scanner
	name = "Depth Analysis Scanner"
	desc = "Used to check spatial depth and density of rock outcroppings."
	id = "depth_scanner"
	req_tech = list(Tc_MATERIALS = 1, Tc_ANOMALY = 1)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 1000, MAT_GLASS = 2000)
	category = "Anomaly"
	build_path = /obj/item/device/depth_scanner

/datum/design/measuring_tape
	name = "Measuring Tape"
	desc = "A coiled metallic tape used to check dimensions and lengths."
	id = "measuring_tape"
	req_tech = list(Tc_MATERIALS = 1, Tc_ANOMALY = 1)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 3000, MAT_GLASS = 500)
	category = "Anomaly"
	build_path = /obj/item/device/measuring_tape

/datum/design/core_sampler
	name = "Core Sampler"
	desc = "Used to extract geological core samples."
	id = "core_sampler"
	req_tech = list(Tc_MATERIALS = 1, Tc_ANOMALY = 1)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 4000, MAT_GLASS = 700)
	category = "Anomaly"
	build_path = /obj/item/device/core_sampler

/datum/design/xenoarch_scanner
	name = "Xenoarchaeology digsite locator"
	desc = "Shows digsites in vicinity, whether they're hidden or not."
	id = "xenoarch_scanner"
	req_tech  =list(Tc_MAGNETS = 2, Tc_ANOMALY = 2)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS=1000, MAT_IRON = 1000)
	category = "Anomaly"
	build_path = /obj/item/device/xenoarch_scanner

/datum/design/xenoarch_scanner_adv
	name = "Advanced xenoarchaeology digsite locator"
	desc = "Shows digsites in vicinity, whether they're hidden or not. Shows you their reagent via highlighting them a specific colour"
	id = "xenoarch_scanner_adv"
	req_tech  =list(Tc_MAGNETS = 3, Tc_ANOMALY = 3)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS=2500, MAT_IRON = 2500, MAT_PLASMA = 300)
	category = "Anomaly"
	build_path = /obj/item/device/xenoarch_scanner/adv

/datum/design/phazon_glowstick
	name = "Phazon Glowstick"
	desc = "A glowstick filled with phazon material that will change colors upon agitation. It has a string on it so you can wear it."
	id = "phazon_glowstick"
	req_tech = list(Tc_MATERIALS = 6, Tc_ANOMALY = 2)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS=1000, MAT_PHAZON=20)
	category = "Anomaly"
	build_path = /obj/item/clothing/accessory/glowstick/phazon

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
