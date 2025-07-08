var/list/name_to_mineral

/proc/SetupMinerals()
	SetupMineralSpawnLists()
	name_to_mineral = list()
	for(var/type in typesof(/mineral) - /mineral)
		var/mineral/new_mineral = new type
		if(!new_mineral.name)
			continue
		name_to_mineral[new_mineral.name] = new_mineral
	return 1

/mineral
	///What am I called?
	var/name
	var/display_name
	///How much ore?
	var/result_amount
	///Does this type of deposit spread?
	var/spread = 1
	///Chance of spreading in any direction
	var/spread_chance
	///Fortune multiplier for pyrite extract pickaxes
	var/fortune_multiplier

	///Path to the resultant ore.
	var/ore

/mineral/New()
	. = ..()
	if(!display_name)
		display_name = name

/mineral/proc/UpdateTurf(var/turf/unsimulated/mineral/T)
	T.UpdateMineral()

/mineral/proc/DropMineral(var/turf/unsimulated/mineral/T)
	var/obj/item/O = drop_stack(ore, T, result_amount)
	if(O.pixel_x != 0 && O.pixel_y != 0) //give it a little jiggle
		O.pixel_x = rand(-16,16) * PIXEL_MULTIPLIER
		O.pixel_y = rand(-16,16) * PIXEL_MULTIPLIER
	if(istype(O, /obj/item/stack/ore))
		var/obj/item/stack/ore/OR = O
		if(!T.geologic_data)
			T.geologic_data = new/datum/geosample(T)
		T.geologic_data.UpdateNearbyArtifactInfo(T)
		OR.geologic_data = T.geologic_data
	return O

/mineral/uranium
	name = "Uranium"
	result_amount = 5
	spread_chance = 10
	fortune_multiplier = 2
	ore = /obj/item/stack/ore/uranium

/mineral/iron
	name = "Iron"
	result_amount = 5
	spread_chance = 25
	ore = /obj/item/stack/ore/iron

/mineral/diamond
	name = "Diamond"
	result_amount = 5
	spread_chance = 10
	fortune_multiplier = 4
	ore = /obj/item/stack/ore/diamond

/mineral/gold
	name = "Gold"
	result_amount = 5
	spread_chance = 10
	fortune_multiplier = 2
	ore = /obj/item/stack/ore/gold

/mineral/silver
	name = "Silver"
	result_amount = 5
	spread_chance = 10
	fortune_multiplier = 2
	ore = /obj/item/stack/ore/silver

/mineral/electrum
	name = "Electrum"
	result_amount = 5
	spread_chance = 10
	fortune_multiplier = 2
	ore = /obj/item/stack/ore/electrum

/mineral/plasma
	name = "Plasma"
	result_amount = 5
	spread_chance = 25
	ore = /obj/item/stack/ore/plasma

/mineral/nanotrasite
	name = "Nanotrasite"
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/stack/ore/nanotrasite

/mineral/clown
	display_name = "Bananium"
	name = "Clown"
	result_amount = 3
	spread = 0
	fortune_multiplier = 8
	ore = /obj/item/stack/ore/clown

/mineral/phazon
	display_name = "Phazon"
	name = "Phazon"
	result_amount = 3
	spread = 0
	fortune_multiplier = 8
	ore = /obj/item/stack/ore/phazon

/mineral/pharosium
	name = "Pharosium"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/stack/ore/pharosium

/mineral/char
	name = "Char"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/stack/ore/char

/mineral/claretine
	name = "Claretine"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/stack/ore/claretine

/mineral/bohrum
	name = "Bohrum"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/stack/ore/bohrum

/mineral/syreline
	name = "Syreline"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/stack/ore/syreline

/mineral/erebite
	name = "Erebite"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/stack/ore/erebite

/mineral/cytine
	name = "Cytine"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/stack/ore/cytine

/mineral/uqill
	name = "Uqill"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/stack/ore/uqill

/mineral/telecrystal
	name = "Telecrystal"
	result_amount = 1
	spread_chance = 5
	fortune_multiplier = 8
	ore = /obj/item/stack/ore/telecrystal

/mineral/mauxite
	name = "Mauxite"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/stack/ore/mauxite

/mineral/cobryl
	name = "Cobryl"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/stack/ore/cobryl

/mineral/cerenkite
	name = "Cerenkite"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/stack/ore/cerenkite

/mineral/molitz
	name = "Molitz"
	result_amount = 5
	spread_chance = 5
	ore = /obj/item/stack/ore/molitz

/mineral/gibtonite
	display_name = "Gibtonite"
	name = "Gibtonite"
	result_amount = 1
	spread = 1
	ore = /obj/item/weapon/gibtonite

/mineral/gibtonite/UpdateTurf(var/turf/unsimulated/mineral/T)
	if(!istype(T,/turf/unsimulated/mineral/gibtonite))
		var/old_state = T.icon_state
		var/turf/unsimulated/mineral/newturf = T.ChangeTurf(/turf/unsimulated/mineral/gibtonite)
		newturf.base_icon_state = old_state
		newturf.icon_state = old_state
	else
		..()


/mineral/ice
	display_name = "Ice"
	name = "Ice"
	result_amount = 3
	spread = 3
	ore = /obj/item/ice_crystal

/mineral/cave
	display_name = "Cave"
	name = "Cave"
	result_amount = 1
	spread = 1
	ore = null

/mineral/cave/UpdateTurf(var/turf/T)
	if(!istype(T,/turf/unsimulated/floor/asteroid/cave))
		T.ChangeTurf(/turf/unsimulated/floor/asteroid/cave)
	else
		..()

/mineral/cave/ice
	display_name = "Ice Cave"
	name = "Ice Cave"

/mineral/cave/ice/UpdateTurf(var/turf/T)
	if(!istype(T,/turf/unsimulated/floor/asteroid/cave/permafrost))
		T.ChangeTurf(/turf/unsimulated/floor/asteroid/cave/permafrost)
	else
		..()

/mineral/mythril
	display_name = "Silver"
	name = "Mythril"
	result_amount = 4
	spread = 2
	fortune_multiplier = 8
	ore = /obj/item/stack/ore/mythril
