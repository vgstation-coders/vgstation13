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

proc/initialize_materials()
	for(var/matdata in subtypesof(/datum/material))
		var/datum/material/mat = new matdata
		material_list += list(mat.id = mat)
		if (!mat.sheettype)
			continue
		initial_materials += list(mat.id = 0) // This is for machines in r&d who have a material holder. If you can't make sheets of the material, you can't put in an r_n_d machine to begin with.

var/global/list/material_list		//Stores an instance of all the datums as an assoc with their matids
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

/datum/materials/resetVariables(args)
	var/newargs
	if(args)
		newargs = args + "storage"
	else
		newargs = "storage"

	..(arglist(newargs))

	if(!initial_materials)
		initialize_materials()

	storage = initial_materials.Copy()

/datum/materials/proc/getVolume()
	var/volume=0
	for(var/mat_id in storage)
		volume += storage[mat_id]
	return volume

//Gives total value, doing mat value * stored mat
/datum/materials/proc/getValue()
	var/value=0
	for(var/mat_id in storage)
		var/datum/material/mat = getMaterial(mat_id)
		value += mat.value * storage[mat_id]
	return value

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

//Adds all of the given materials datum's resources to ours. If zero_after, we set their storage amounts to 0
/datum/materials/proc/addFrom(var/datum/materials/mats, var/zero_after=0)
	if(mats == null)
		return
	for(var/mat_id in storage)
		if(mats.storage[mat_id]>0)
			storage[mat_id] += mats.storage[mat_id]
			if(zero_after)
				mats.storage[mat_id] = 0

//Used to remove all materials from a given materials datum, and transfer it to ours
/datum/materials/proc/removeFrom(var/datum/materials/mats)
	src.addFrom(mats,zero_after=1)

//Sanely removes an amount from us, of a given material ID, and transfers it to somebody else. Returns the given amount
/datum/materials/proc/Transfer(var/mat_id, var/amount, var/datum/materials/receiver)
	ASSERT(receiver)
	if(!mat_id in storage)
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

//HOOKS//
/atom/proc/onMaterialChange(matID, amount)
	return


///MATERIALS///
/datum/material
	var/name=""
	var/processed_name=""
	var/id=""
	var/cc_per_sheet=CC_PER_SHEET_MISC
	var/oretype=null
	var/sheettype=null
	var/cointype=null
	var/value=0
	var/color
	var/color_matrix
	var/alpha = 255
	//Modifier multipliers.
	var/brunt_damage_mod = 1
	var/sharpness_mod = 1
	var/quality_mod = 1
	var/melt_temperature = MELTPOINT_STEEL
	var/armor_mod = 1


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
	value=0.2
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
	value=0.2
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
		playsound(get_turf(source), "shatter", 70, 1)
		qdel(source)

/datum/material/diamond
	name="Diamond"
	id=MAT_DIAMOND
	value=4
	cc_per_sheet = 1750
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
	value=0.2
	oretype=/obj/item/stack/ore/plasma
	sheettype=/obj/item/stack/sheet/mineral/plasma
	cointype=/obj/item/weapon/coin/plasma
	color = "#500064" //rgb: 80, 0, 100
	brunt_damage_mod = 1.2
	sharpness_mod = 1.4
	quality_mod = 1.3

/datum/material/plasma/on_use(obj/source, atom/target, mob/user)
	if(!..())
		return
	if(isliving(target))
		var/mob/living/L = target
		L.adjustToxLoss(rand(1,source.quality))

/datum/material/gold
	name="Gold"
	id=MAT_GOLD
	value=1
	oretype=/obj/item/stack/ore/gold
	sheettype=/obj/item/stack/sheet/mineral/gold
	cointype=/obj/item/weapon/coin/gold
	color = "#F7C430" //rgb: 247, 196, 48
	brunt_damage_mod = 0.5
	sharpness_mod = 0.5
	quality_mod = 1.7
	melt_temperature = MELTPOINT_GOLD

/datum/material/silver
	name="Silver"
	id=MAT_SILVER
	value=1
	oretype=/obj/item/stack/ore/silver
	sheettype=/obj/item/stack/sheet/mineral/silver
	cointype=/obj/item/weapon/coin/silver
	color = "#D0D0D0" //rgb: 208, 208, 208
	brunt_damage_mod = 0.7
	sharpness_mod = 0.7
	quality_mod = 1.5
	melt_temperature = MELTPOINT_SILVER


/datum/material/uranium
	name="Uranium"
	id=MAT_URANIUM
	value=1
	oretype=/obj/item/stack/ore/uranium
	sheettype=/obj/item/stack/sheet/mineral/uranium
	cointype=/obj/item/weapon/coin/uranium
	color = "#247124" //rgb: 36, 113, 36
	brunt_damage_mod = 1.8
	sharpness_mod = 0.2
	quality_mod = 1.4
	melt_temperature = MELTPOINT_URANIUM


/datum/material/uranium/on_use(obj/source, atom/target, mob/user)
	if(!..())
		return
	if(isliving(target))
		var/mob/living/L = target
		L.apply_radiation(rand(1,3)*source.quality, RAD_EXTERNAL)

/datum/material/clown
	name="Bananium"
	id=MAT_CLOWN
	value=1
	oretype=/obj/item/stack/ore/clown
	sheettype=/obj/item/stack/sheet/mineral/clown
	cointype=/obj/item/weapon/coin/clown
	melt_temperature = MELTPOINT_POTASSIUM

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
		playsound(get_turf(source), 'sound/items/bikehorn.ogg', 100, 1)

/datum/material/phazon
	name="Phazon"
	id=MAT_PHAZON
	value=1
	cc_per_sheet = 1500
	oretype=/obj/item/stack/ore/phazon
	sheettype=/obj/item/stack/sheet/mineral/phazon
	cointype=/obj/item/weapon/coin/phazon
	color = "#5E02F8" //rgb: 94, 2, 248
	brunt_damage_mod = 1.4
	sharpness_mod = 1.8
	quality_mod = 2.2
	melt_temperature = MELTPOINT_PLASMA

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
		if(prob(20*source.quality))
			to_chat(user, "<span class = 'warning'>\The [source] phases out of reality!</span>")
			qdel(source)

/datum/material/plastic
	name="Plastic"
	id=MAT_PLASTIC
	value=0
	oretype=null
	sheettype=/obj/item/stack/sheet/mineral/plastic
	cointype=null
	color = "#F8F8FF" //rgb: 248, 248, 255

/datum/material/cardboard
	name="Cardboard"
	id=MAT_CARDBOARD
	value=0
	oretype=null
	sheettype=/obj/item/stack/sheet/cardboard
	cointype=null
	cc_per_sheet = CC_PER_SHEET_METAL

/datum/material/wood
	name="Wood"
	id=MAT_WOOD
	value=0
	oretype=null
	sheettype=/obj/item/stack/sheet/wood
	cointype=null
	cc_per_sheet = CC_PER_SHEET_METAL
	color = "#663300" //rgb: 102, 51, 0

/datum/material/brass
	name = "Brass"
	id = MAT_BRASS
	value = 0
	oretype = null
	sheettype = /obj/item/stack/sheet/brass
	cointype = null
	cc_per_sheet = CC_PER_SHEET_METAL
	color = "#A97F1B"
	melt_temperature = MELTPOINT_BRASS

/datum/material/ralloy
	name = "Replicant Alloy"
	id = MAT_RALLOY
	value = 0
	oretype = null
	sheettype = /obj/item/stack/sheet/ralloy
	cointype = null
	cc_per_sheet = CC_PER_SHEET_METAL
	color = "#363636"

/datum/material/ice
	name = "Ice"
	id = MAT_ICE
	value = 0
	oretype = /obj/item/ice_crystal

/datum/material/mythril
	name="mythril"
	id=MAT_MYTHRIL
	value=1
	oretype=/obj/item/stack/ore/mythril
	sheettype=/obj/item/stack/sheet/mineral/mythril
	cointype=/obj/item/weapon/coin/mythril
	color = "#FFEDD2" //rgb: 255,237,238
	brunt_damage_mod = 1.4
	sharpness_mod = 0.6
	quality_mod = 1.5
	armor_mod = 1.75

/datum/material/telecrystal
	name="telecrystal"
	id=MAT_TELECRYSTAL
	value=1
	oretype=/obj/item/stack/ore/telecrystal
	sheettype=/obj/item/bluespace_crystal
	cointype=null


/* //Commented out to save save space in menus listing materials until they are used
/datum/material/pharosium
	name="Pharosium"
	id="pharosium"
	value=10
	oretype=/obj/item/stack/ore/pharosium
	sheettype=/obj/item/stack/sheet/mineral/pharosium
	cointype=null

/datum/material/char
	name="Char"
	id="char"
	value=5
	oretype=/obj/item/stack/ore/char
	sheettype=/obj/item/stack/sheet/mineral/char
	cointype=null


/datum/material/claretine
	name="Claretine"
	id="claretine"
	value=50
	oretype=/obj/item/stack/ore/claretine
	sheettype=/obj/item/stack/sheet/mineral/claretine
	cointype=null


/datum/material/bohrum
	name="Bohrum"
	id="bohrum"
	value=50
	oretype=/obj/item/stack/ore/bohrum
	sheettype=/obj/item/stack/sheet/mineral/bohrum
	cointype=null


/datum/material/syreline
	name="Syreline"
	id="syreline"
	value=70
	oretype=/obj/item/stack/ore/syreline
	sheettype=/obj/item/stack/sheet/mineral/syreline
	cointype=null


/datum/material/erebite
	name="Erebite"
	id="erebite"
	value=50
	oretype=/obj/item/stack/ore/erebite
	sheettype=/obj/item/stack/sheet/mineral/erebite
	cointype=null


/datum/material/cytine
	name="Cytine"
	id="cytine"
	value=30
	oretype=/obj/item/stack/ore/cytine
	sheettype=/obj/item/stack/sheet/mineral/cytine
	cointype=null


/datum/material/uqill
	name="Uqill"
	id="uqill"
	value=90
	oretype=/obj/item/stack/ore/uqill
	sheettype=/obj/item/stack/sheet/mineral/uqill
	cointype=null


/datum/material/mauxite
	name="Mauxite"
	id="mauxite"
	value=5
	oretype=/obj/item/stack/ore/mauxite
	sheettype=/obj/item/stack/sheet/mineral/mauxite
	cointype=null


/datum/material/cobryl
	name="Cobryl"
	id="cobryl"
	value=30
	oretype=/obj/item/stack/ore/cobryl
	sheettype=/obj/item/stack/sheet/mineral/cobryl
	cointype=null


/datum/material/cerenkite
	name="Cerenkite"
	id="cerenkite"
	value=50
	oretype=/obj/item/stack/ore/cerenkite
	sheettype=/obj/item/stack/sheet/mineral/cerenkite
	cointype=null

/datum/material/molitz
	name="Molitz"
	id="molitz"
	value=10
	oretype=/obj/item/stack/ore/molitz
	sheettype=/obj/item/stack/sheet/mineral/molitz
	cointype=null
*/
