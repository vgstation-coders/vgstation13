/**
* Materials system
*
* Replaces all of the horrible variables that tracked each individual thing.
*/

/**
* MATERIALS DATUM
*
* Tracks and manages material storage for an object.
*/

/proc/initialize_materials()
	for(var/matdata in subtypesof(/datum/material))
		var/datum/material/mat = new matdata
		material_list += list(mat.id = mat)
		if (!mat.sheettype)
			continue
		initial_materials += list(mat.id = 0) // This is for machines in r&d who have a material holder. If you can't make sheets of the material, you can't put in an r_n_d machine to begin with.

var/global/list/datum/material/material_list		//Stores an instance of all the datums as an assoc with their matids
var/global/list/initial_materials	//Stores all the matids = 0 in helping New

/datum/materials
	var/atom/holder
	var/list/storage

/datum/materials/New(atom/newholder)
	holder = newholder
	storage = list()

	if(!material_list)
		initialize_materials()

	if(!storage.len)
		storage = initial_materials.Copy()

/datum/materials/Destroy()
	holder = null
	return ..()

/datum/materials/proc/getVolume()
	var/volume=0
	for(var/mat_id in storage)
		volume += storage[mat_id]
	return volume

//Gives total value, doing mat value * stored mat
/datum/materials/proc/getValue()
	. = 0
	for(var/mat_id in storage)
		. += getValueByMaterial(mat_id)

//Same as above but for individual mats

/datum/materials/proc/getValueByAmount(var/mat_id,var/amount)
	. = 0
	var/datum/material/mat = getMaterial(mat_id)
	. = mat.value * (amount/mat.cc_per_sheet)

/datum/materials/proc/getValueByMaterial(var/mat_id)
	return getValueByAmount(mat_id,storage[mat_id])

//Returns however much we have of that material
/datum/materials/proc/getAmount(var/mat_id)
	if(!(mat_id in storage))
		warning("getAmount(): Unknown material [mat_id]!")
		return 0

	return storage[mat_id]

//Returns the material datum according to the given ID
/datum/materials/proc/getMaterial(var/mat_id)
	if(!(mat_id in material_list))
		warning("getMaterial(): Unknown material [mat_id]!")
		return 0

	return material_list[mat_id]

//Adds the given amount of the given mat_ID to our storage
/datum/materials/proc/addAmount(var/mat_id,var/amount)
	if(!(mat_id in storage))
		warning("addAmount(): Unknown material [mat_id]!")
		return
	// I HATE BYOND
	// storage[mat_id].stored++
	storage[mat_id] = max(0, storage[mat_id] + amount)

/datum/materials/proc/GetAmountByValue(var/mat_id,var/amount)
	. = 0
	var/datum/material/mat = getMaterial(mat_id)
	. = mat.value ? ((amount/mat.value) * mat.cc_per_sheet) : 0

/datum/materials/proc/addAmountByValue(var/mat_id,var/amount)
	addAmount(mat_id,GetAmountByValue(mat_id,amount))

//Adds all of the given materials datum's resources to ours. If zero_after, we set their storage amounts to 0
/datum/materials/proc/addFrom(var/datum/materials/mats, var/zero_after=0)
	if(mats == null)
		return
	for(var/mat_id in storage)
		if(mats.storage[mat_id]>0)
			storage[mat_id] += mats.storage[mat_id]
			if(zero_after)
				mats.storage[mat_id] = 0

/datum/materials/proc/addRatioFrom(var/datum/materials/mats, var/ratio)
	if(mats == null)
		return
	for(var/mat_id in storage)
		if(mats.storage[mat_id]>0)
			storage[mat_id] += mats.storage[mat_id] * abs(ratio)

//Used to remove all materials from a given materials datum, and transfer it to ours
/datum/materials/proc/removeFrom(var/datum/materials/mats)
	src.addFrom(mats,zero_after=1)

//Sanely removes an amount from us, of a given material ID, and transfers it to somebody else. Returns the given amount
/datum/materials/proc/Transfer(var/mat_id, var/amount, var/datum/materials/receiver)
	ASSERT(receiver)
	if(!(mat_id in storage))
		warning("Transfer(): Unknown material [mat_id]!")
		return 0
	amount = min(getAmount(mat_id), amount)
	receiver.addAmount(mat_id, amount)
	removeAmount(mat_id, amount)
	return amount

//Itterates through every material ID we have, and transfers the percentage of how much we have of that material to the receiver
/datum/materials/proc/TransferPercent(var/percentage, var/datum/materials/receiver)
	var/amount_transferred = 0
	for(var/mat_id in storage)
		var/amount = Transfer(mat_id, getAmount(mat_id) * (percentage/100), receiver)
		amount_transferred += amount
	return amount_transferred

/datum/materials/proc/TransferAll(var/datum/materials/receiver)
	return TransferPercent(100, receiver)

/datum/materials/proc/removeAmount(var/mat_id,var/amount)
	if(!(mat_id in storage))
		warning("removeAmount(): Unknown material [mat_id]!")
		return
	addAmount(mat_id,-amount)


/datum/materials/proc/removeAmountByValue(var/mat_id,var/amount)
	addAmountByValue(mat_id,-amount)

/datum/materials/proc/makeSheets(var/atom/loc)
	for (var/id in storage)
		var/amount = getAmount(id)
		if(amount)
			var/datum/material/mat = getMaterial(id)
			drop_stack(mat.sheettype, loc, Floor(amount / mat.cc_per_sheet))

/datum/materials/proc/makeOre(var/atom/loc)
	for(var/id in storage)
		var/amount = getAmount(id)
		if(amount)
			var/datum/material/mat = getMaterial(id)
			drop_stack(mat.oretype, loc, amount)

/datum/materials/proc/makeAndRemoveOre(var/atom/loc)
	makeOre(loc)
	for(var/id in storage)
		removeAmount(id, storage[id])

/proc/get_material_cc_per_sheet(var/matID)
	var/datum/material/mat = material_list[matID]
	return mat.cc_per_sheet

//HOOKS//
/atom/proc/onMaterialChange(matID, amount)
	return


///MATERIALS///
/datum/material
	var/name=""
	var/processed_name=""
	var/id=""
	var/cc_per_sheet=CC_PER_SHEET_DEFAULT
	var/oretype=null
	var/sheettype=null
	var/cointype=null
	var/value=VALUE_MISC
	var/color
	var/color_matrix
	var/alpha = 255
	//Modifier multipliers.
	var/brunt_damage_mod = 1
	var/sharpness_mod = 1
	var/quality_mod = 1
	var/melt_temperature = MELTPOINT_STEEL
	var/armor_mod = 1
	var/default_show_in_menus = TRUE // If false, stuff like the smelter won't show these *unless it has some*.


/datum/material/New()
	if(processed_name=="")
		processed_name=name

/datum/material/proc/on_use(obj/source, atom/target, mob/user)
	ASSERT(source)
	if(isobserver(user))
		return FALSE
	return TRUE

/datum/material/iron
	name="Iron"
	id=MAT_IRON
	value=VALUE_IRON
	cc_per_sheet=CC_PER_SHEET_METAL
	oretype=/obj/item/stack/ore/iron
	sheettype=/obj/item/stack/sheet/metal
	cointype=/obj/item/weapon/coin/iron
	color = "#666666" //rgb: 102, 102, 102
	brunt_damage_mod = 1.1
	sharpness_mod = 0.8
	quality_mod = 1.1
	melt_temperature = MELTPOINT_STEEL

/datum/material/glass
	name="Sand"
	processed_name="Glass"
	id=MAT_GLASS
	value=VALUE_GLASS
	cc_per_sheet=CC_PER_SHEET_GLASS
	oretype=/obj/item/stack/ore/glass
	sheettype=/obj/item/stack/sheet/glass/glass
	color = "#6E8DA2" //rgb: 110, 141, 162
	alpha = 122
	brunt_damage_mod = 0.7
	sharpness_mod = 1.4
	melt_temperature = MELTPOINT_GLASS

/datum/material/glass/on_use(obj/source)
	if(!..())
		return
	if(prob(25/source.quality))
		source.visible_message("<span class = 'warning'>\The [source] shatters!</span>")
		new /obj/item/weapon/shard(get_turf(source))
		playsound(source, "shatter", 70, 1)
		qdel(source)

/datum/material/diamond
	name="Diamond"
	id=MAT_DIAMOND
	value=VALUE_DIAMOND
	cc_per_sheet = CC_PER_SHEET_DIAMOND
	oretype=/obj/item/stack/ore/diamond
	sheettype=/obj/item/stack/sheet/mineral/diamond
	cointype=/obj/item/weapon/coin/diamond
	color = "#74C6C6" //rgb: 116, 198, 198
	alpha = 200
	brunt_damage_mod = 1.4
	sharpness_mod = 1.6
	quality_mod = 2
	melt_temperature = MELTPOINT_CARBON

/datum/material/plasma
	name="Plasma"
	id=MAT_PLASMA
	value=VALUE_PLASMA
	oretype=/obj/item/stack/ore/plasma
	sheettype=/obj/item/stack/sheet/mineral/plasma
	cointype=/obj/item/weapon/coin/plasma
	color = "#500064" //rgb: 80, 0, 100
	brunt_damage_mod = 1.2
	sharpness_mod = 1.4
	quality_mod = 1.3
	cc_per_sheet = CC_PER_SHEET_PLASMA

/datum/material/plasma/on_use(obj/source, atom/target, mob/user)
	if(!..())
		return
	if(isliving(target))
		var/mob/living/L = target
		L.adjustToxLoss(rand(1,source.quality))

/datum/material/gold
	name="Gold"
	id=MAT_GOLD
	value=VALUE_GOLD
	oretype=/obj/item/stack/ore/gold
	sheettype=/obj/item/stack/sheet/mineral/gold
	cointype=/obj/item/weapon/coin/gold
	color = "#F7C430" //rgb: 247, 196, 48
	brunt_damage_mod = 0.9
	sharpness_mod = 0.5
	quality_mod = 1.8
	melt_temperature = MELTPOINT_GOLD
	cc_per_sheet = CC_PER_SHEET_GOLD

/datum/material/silver
	name="Silver"
	id=MAT_SILVER
	value=VALUE_SILVER
	oretype=/obj/item/stack/ore/silver
	sheettype=/obj/item/stack/sheet/mineral/silver
	cointype=/obj/item/weapon/coin/silver
	color = "#D0D0D0" //rgb: 208, 208, 208
	brunt_damage_mod = 0.2
	sharpness_mod = 1.8
	quality_mod = 1.5
	melt_temperature = MELTPOINT_SILVER
	cc_per_sheet = CC_PER_SHEET_SILVER

/datum/material/uranium
	name="Uranium"
	id=MAT_URANIUM
	value=VALUE_URANIUM
	oretype=/obj/item/stack/ore/uranium
	sheettype=/obj/item/stack/sheet/mineral/uranium
	cointype=/obj/item/weapon/coin/uranium
	color = "#247124" //rgb: 36, 113, 36
	brunt_damage_mod = 1.8
	sharpness_mod = 0.2
	quality_mod = 1.4
	melt_temperature = MELTPOINT_URANIUM
	cc_per_sheet = CC_PER_SHEET_URANIUM


/datum/material/uranium/on_use(obj/source, atom/target, mob/user)
	if(!..())
		return
	if(isliving(target))
		var/mob/living/L = target
		L.apply_radiation(rand(1,3)*source.quality, RAD_EXTERNAL)

/datum/material/clown
	name="Bananium"
	id=MAT_CLOWN
	value=VALUE_CLOWN
	oretype=/obj/item/stack/ore/clown
	sheettype=/obj/item/stack/sheet/mineral/clown
	cointype=/obj/item/weapon/coin/clown
	melt_temperature = MELTPOINT_POTASSIUM
	cc_per_sheet = CC_PER_SHEET_CLOWN

/datum/material/clown/New()
	if(!..())
		return
	brunt_damage_mod = rand(1,2)/rand(1,8)
	sharpness_mod = rand(1,2)/rand(1,8)
	quality_mod = rand(1,2)/rand(1,8)

	color_matrix = list(rand(),rand(),rand(),0,
						rand(),rand(),rand(),0,
						rand(),rand(),rand(),0,
						0,0,0,1,
						0,0,0,0)

/datum/material/clown/on_use(obj/source) //May [ticker.deity] have mercy
	if(!..())
		return
	if(prob(10*source.quality))
		playsound(source, 'sound/items/bikehorn.ogg', 100, 1)

/datum/material/phazon
	name="Phazon"
	id=MAT_PHAZON
	value=VALUE_PHAZON
	cc_per_sheet = 1500
	oretype=/obj/item/stack/ore/phazon
	sheettype=/obj/item/stack/sheet/mineral/phazon
	cointype=/obj/item/weapon/coin/phazon
	color = "#5E02F8" //rgb: 94, 2, 248
	brunt_damage_mod = 1.4
	sharpness_mod = 1.8
	quality_mod = 2.2
	melt_temperature = MELTPOINT_PLASMA
	cc_per_sheet = CC_PER_SHEET_PHAZON

/datum/material/phazon/on_use(obj/source, atom/target, mob/user)
	if(!..())
		return
	if(prob(5*source.quality))
		switch(rand(1,2))
			if(1) //EMP
				empulse(get_turf(pick(source,target,user)), 0.25*source.quality, 0.5*source.quality, 1)
			if(2) //Teleport
				var/atom/movable/victim = pick(target,user)
				if(victim)
					do_teleport(victim, get_turf(victim), 1*source.quality, asoundin = 'sound/effects/phasein.ogg')
		if(prob(20/source.quality))
			to_chat(user, "<span class = 'warning'>\The [source] teleports away!</span>")
			do_teleport(source, get_turf(source), 1.45*source.quality, asoundin = 'sound/effects/phasein.ogg') //teleports to a random tile within up to 13 tiles of itself, based on quality

/datum/material/plastic
	name="Plastic"
	id=MAT_PLASTIC
	sheettype=/obj/item/stack/sheet/mineral/plastic
	color = "#F8F8FF" //rgb: 248, 248, 255
	cc_per_sheet = CC_PER_SHEET_PLASTIC

/datum/material/cardboard
	name="Cardboard"
	id=MAT_CARDBOARD
	sheettype=/obj/item/stack/sheet/cardboard
	cc_per_sheet = CC_PER_SHEET_CARDBOARD

/datum/material/wood
	name="Wood"
	id=MAT_WOOD
	sheettype=/obj/item/stack/sheet/wood
	cc_per_sheet = CC_PER_SHEET_WOOD
	color = "#663300" //rgb: 102, 51, 0

/datum/material/fabric
	name="Fabric"
	id=MAT_FABRIC
	sheettype=/obj/item/stack/sheet/cloth
	cc_per_sheet = CC_PER_SHEET_FABRIC
	color = COLOR_LINEN

/datum/material/wax
	name="Wax"
	id=MAT_WAX
	sheettype=/obj/item/stack/sheet/wax
	cc_per_sheet = CC_PER_SHEET_WAX
	color = COLOR_BEESWAX

/datum/material/brass
	name = "Brass"
	id = MAT_BRASS
	sheettype = /obj/item/stack/sheet/brass
	cc_per_sheet = CC_PER_SHEET_BRASS
	color = "#A97F1B"
	melt_temperature = MELTPOINT_BRASS

/datum/material/ralloy
	name = "Replicant Alloy"
	id = MAT_RALLOY
	sheettype = /obj/item/stack/sheet/ralloy
	cc_per_sheet = CC_PER_SHEET_RALLOY
	color = "#363636"

/datum/material/ice
	name = "Ice"
	id = MAT_ICE
	value = 0
	oretype = /obj/item/ice_crystal
	cc_per_sheet = CC_PER_SHEET_ICE

/datum/material/mythril
	name="mythril"
	id=MAT_MYTHRIL
	value=VALUE_MYTHRIL
	oretype=/obj/item/stack/ore/mythril
	sheettype=/obj/item/stack/sheet/mineral/mythril
	cointype=/obj/item/weapon/coin/mythril
	color = "#FFEDD2" //rgb: 255,237,238
	brunt_damage_mod = 1.4
	sharpness_mod = 0.6
	quality_mod = 3 //stupidly rare material (not to mention blacksmithing itself almost never happens)
	armor_mod = 1.75 //if only armorsmithing were a thing
	cc_per_sheet = CC_PER_SHEET_MYTHRIL

/datum/material/telecrystal
	name="telecrystal"
	id=MAT_TELECRYSTAL
	value=VALUE_TELECRYSTAL
	oretype=/obj/item/stack/ore/telecrystal
	sheettype=/obj/item/bluespace_crystal
	cc_per_sheet = CC_PER_SHEET_TELECRYSTAL


/datum/material/pharosium
	name="Pharosium"
	id=MAT_PHAROSIUM
	value=10
	oretype=/obj/item/stack/ore/pharosium
	sheettype=/obj/item/stack/sheet/mineral/pharosium
	default_show_in_menus = FALSE
	cc_per_sheet = CC_PER_SHEET_PHAROSIUM


/datum/material/char
	name="Char"
	id=MAT_CHAR
	value=5
	oretype=/obj/item/stack/ore/char
	sheettype=/obj/item/stack/sheet/mineral/char
	default_show_in_menus = FALSE
	cc_per_sheet = CC_PER_SHEET_CHAR


/datum/material/claretine
	name="Claretine"
	id=MAT_CLARETINE
	value=50
	oretype=/obj/item/stack/ore/claretine
	sheettype=/obj/item/stack/sheet/mineral/claretine
	default_show_in_menus = FALSE
	cc_per_sheet = CC_PER_SHEET_CLARETINE


/datum/material/bohrum
	name="Bohrum"
	id=MAT_BOHRUM
	value=50
	oretype=/obj/item/stack/ore/bohrum
	sheettype=/obj/item/stack/sheet/mineral/bohrum
	default_show_in_menus = FALSE
	cc_per_sheet = CC_PER_SHEET_BOHRUM


/datum/material/syreline
	name="Syreline"
	id=MAT_SYRELINE
	value=70
	oretype=/obj/item/stack/ore/syreline
	sheettype=/obj/item/stack/sheet/mineral/syreline
	default_show_in_menus = FALSE
	cc_per_sheet = CC_PER_SHEET_SYRELINE


/datum/material/erebite
	name="Erebite"
	id=MAT_EREBITE
	value=50
	oretype=/obj/item/stack/ore/erebite
	sheettype=/obj/item/stack/sheet/mineral/erebite
	default_show_in_menus = FALSE
	cc_per_sheet = CC_PER_SHEET_EREBITE


/datum/material/cytine
	name="Cytine"
	id=MAT_CYTINE
	value=30
	oretype=/obj/item/stack/ore/cytine
	sheettype=/obj/item/stack/sheet/mineral/cytine
	default_show_in_menus = FALSE
	cc_per_sheet = CC_PER_SHEET_CYTINE


/datum/material/uqill
	name="Uqill"
	id=MAT_UQILL
	value=90
	oretype=/obj/item/stack/ore/uqill
	sheettype=/obj/item/stack/sheet/mineral/uqill
	default_show_in_menus = FALSE
	cc_per_sheet = CC_PER_SHEET_UQILL


/datum/material/mauxite
	name="Mauxite"
	id=MAT_MAUXITE
	value=5
	oretype=/obj/item/stack/ore/mauxite
	sheettype=/obj/item/stack/sheet/mineral/mauxite
	default_show_in_menus = FALSE
	cc_per_sheet = CC_PER_SHEET_MAUXITE


/datum/material/cobryl
	name="Cobryl"
	id=MAT_COBRYL
	value=30
	oretype=/obj/item/stack/ore/cobryl
	sheettype=/obj/item/stack/sheet/mineral/cobryl
	default_show_in_menus = FALSE
	cc_per_sheet = CC_PER_SHEET_COBRYL


/datum/material/cerenkite
	name="Cerenkite"
	id=MAT_CERENKITE
	value=50
	oretype=/obj/item/stack/ore/cerenkite
	sheettype=/obj/item/stack/sheet/mineral/cerenkite
	default_show_in_menus = FALSE
	cc_per_sheet = CC_PER_SHEET_CERENKITE

/datum/material/molitz
	name="Molitz"
	id=MAT_MOLITZ
	value=10
	oretype=/obj/item/stack/ore/molitz
	sheettype=/obj/item/stack/sheet/mineral/molitz
	default_show_in_menus = FALSE
	cc_per_sheet = CC_PER_SHEET_MOLITZ

/datum/material/gingerbread
	name="Gingerbread"
	id=MAT_GINGERBREAD
	sheettype=/obj/item/stack/sheet/mineral/gingerbread
	default_show_in_menus = FALSE
	cc_per_sheet = CC_PER_SHEET_GINGERBREAD
