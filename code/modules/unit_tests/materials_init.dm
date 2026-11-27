/datum/unit_test/materials_initial_storage/start()
	if(!material_list)
		initialize_materials()

	var/datum/material/iron = material_list[MAT_IRON]
	initialize_materials()
	if(material_list[MAT_IRON] != iron)
		fail("initialize_materials() rebuilt the material datums.")

	var/list/old_initial = initial_materials
	initial_materials = null

	var/datum/materials/mats = new
	initial_materials = old_initial

	if(!mats.storage.len)
		fail("a material holder created without initial_materials got an empty storage.")
	else if(!(MAT_IRON in mats.storage))
		fail("the material storage is missing MAT_IRON.")
	else if(mats.storage[MAT_IRON] != 0)
		fail("MAT_IRON should start at 0, got [mats.storage[MAT_IRON]].")

	qdel(mats)
