/*
 * Recipe datum
 * For the actual crafting that uses these datums, see stack.dm
 */
/datum/stack_recipe
	var/title = "ERROR"
	var/result_type
	var/req_amount = 1
	var/res_amount = 1
	var/max_res_amount = 1
	var/time = 0
	var/one_per_turf = 0
	var/on_floor = 0
	var/start_unanchored = 0
	var/list/other_reqs = list()
	New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1, time = 0, one_per_turf = 0, on_floor = 0, start_unanchored = 0, other_reqs = list())
		src.title = title
		src.result_type = result_type
		src.req_amount = req_amount
		src.res_amount = res_amount
		src.max_res_amount = max_res_amount
		src.time = time
		src.one_per_turf = one_per_turf
		src.on_floor = on_floor
		src.start_unanchored = start_unanchored
		src.other_reqs = other_reqs

/datum/stack_recipe/proc/can_build_here(var/mob/usr, var/turf/T)
	if(one_per_turf && locate(result_type) in T)
		to_chat(usr, "<span class='warning'>There is another [title] here!</span>")
		return 0
	if(on_floor && (istype(T, /turf/space)))
		to_chat(usr, "<span class='warning'>\The [title] must be constructed on solid floor!</span>")
		return 0
	return 1

/datum/stack_recipe/proc/finish_building(var/mob/usr, var/obj/item/stack/S, var/R) //This will be called after the recipe is done building, useful for doing something to the result if you want.
	return

//Recipe list datum
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes = null
	var/req_amount = 1
	New(title, recipes, req_amount = 1)
		src.title = title
		src.recipes = recipes
		src.req_amount = req_amount

/* =====================================================================
							METAL RECIPES
===================================================================== */
/datum/stack_recipe/chair/can_build_here(var/mob/usr, var/turf/T)
	if(one_per_turf)
		for(var/atom/movable/AM in T)
			if(istype(AM, /obj/structure/bed/chair/vehicle)) //Bandaid to allow people in vehicles (and wheelchairs) build chairs
				continue
			else if(istype(AM, /obj/structure/bed/chair))
				to_chat(usr, "<span class='warning'>There is already a chair here!</span>")
				return 0
	if(on_floor && (istype(T, /turf/space)))
		to_chat(usr, "<span class='warning'>\The [title] must be constructed on solid floor!</span>")
		return 0
	return 1

/datum/stack_recipe/conveyor_frame/can_build_here(var/mob/usr, var/turf/T)
	if(on_floor && (istype(T, /turf/space)))
		to_chat(usr, "<span class='warning'>\The [title] must be constructed on solid floor!</span>")
		return 0
	return 1

/datum/stack_recipe/dorf
	var/inherit_material
	var/gen_quality

/datum/stack_recipe/dorf/New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1, time = 0, one_per_turf = 0, on_floor = 0, start_unanchored = 0, other_reqs = list(), inherit_material = FALSE, gen_quality = FALSE)
	..()
	src.inherit_material = inherit_material
	src.gen_quality = gen_quality


/datum/stack_recipe/dorf/finish_building(mob/usr, var/obj/item/stack/S, var/obj/R)
	if(inherit_material)
		var/datum/material/mat
		var/datum/materials/materials_list = new
		if(istype(S, /obj/item/stack/sheet/))
			var/obj/item/stack/sheet/SS = S
			mat = materials_list.getMaterial(SS.mat_type)
		if(mat)
			var/icon/original = icon(R.icon, R.icon_state)
			if(mat.color)
				original.ColorTone(mat.color)
				var/obj/item/I = R
				if(istype(I))
					var/icon/t_state
					for(var/hand in list("left_hand", "right_hand"))
						t_state = icon(I.inhand_states[hand], I.item_state)
						t_state.ColorTone(mat.color)
						I.inhand_states[hand] = t_state
			else if(mat.color_matrix)
				R.color = mat.color_matrix
			R.icon = original
			R.alpha = mat.alpha
			R.material_type = mat
			R.sheet_type = mat.sheettype
			//if(gen_quality)
			R.gen_quality()
			if(R.quality > SUPERIOR)
				R.gen_description()
		if(!findtext(lowertext(R.name), lowertext(mat.name)))
			R.name = "[R.quality == NORMAL ? "": "[lowertext(qualityByString[R.quality])] "][lowertext(mat.name)] [R.name]"

var/list/datum/stack_recipe/metal_recipes = list (
	new/datum/stack_recipe("floor tile", /obj/item/stack/tile/plasteel, 1, 4, 60),
	new/datum/stack_recipe("metal rod",  /obj/item/stack/rods,          1, 2, 60),
	new/datum/stack_recipe("conveyor belt", /obj/item/stack/conveyor_assembly, 2, 1, 20),
	null,
	new/datum/stack_recipe("computer frame", /obj/structure/computerframe,                      5, time = 25, one_per_turf = 1			    ),
	new/datum/stack_recipe("wall girders",   /obj/structure/girder,                             2, time = 50, one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe("firelock frame", /obj/item/firedoor_frame,                          5, time = 50),
	new/datum/stack_recipe("machine frame",  /obj/machinery/constructable_frame/machine_frame,  5, time = 25, one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe("mirror frame",   /obj/structure/mirror_frame,                       5, time = 25, one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe("turret frame",   /obj/machinery/porta_turret_construct,             5, time = 25, one_per_turf = 1, on_floor = 1),
	null,
	new/datum/stack_recipe_list("chairs and beds",list(
		new/datum/stack_recipe/chair("dark office chair",  /obj/structure/bed/chair/office/dark,  1, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("light office chair", /obj/structure/bed/chair/office/light, 1, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("beige comfy chair",  /obj/structure/bed/chair/comfy/beige,  1, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("black comfy chair",  /obj/structure/bed/chair/comfy/black,  1, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("brown comfy chair",  /obj/structure/bed/chair/comfy/brown,  1, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("lime comfy chair",   /obj/structure/bed/chair/comfy/lime,   1, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("teal comfy chair",   /obj/structure/bed/chair/comfy/teal,   1, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("stool",              /obj/item/weapon/stool												   ),
		new/datum/stack_recipe/chair("bar stool",          /obj/item/weapon/stool/bar                                              ),
		new/datum/stack_recipe/chair("chair",              /obj/structure/bed/chair,                 one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("folding chair",      /obj/structure/bed/chair/folding,         one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("bed",                      /obj/structure/bed,                    2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/dorf("dorf chair",              /obj/structure/bed/chair,                 one_per_turf = 1, on_floor = 1, inherit_material = TRUE),
		)),
	new/datum/stack_recipe_list("couch parts", list(
		new/datum/stack_recipe/chair("beige couch left end",      /obj/structure/bed/chair/comfy/couch/left/beige,         2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("beige couch right end",     /obj/structure/bed/chair/comfy/couch/right/beige,        2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("beige couch straight",      /obj/structure/bed/chair/comfy/couch/mid/beige,          2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("beige couch inwards turn",  /obj/structure/bed/chair/comfy/couch/turn/inward/beige,  2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("beige couch outwards turn", /obj/structure/bed/chair/comfy/couch/turn/outward/beige, 2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("brown couch left end",      /obj/structure/bed/chair/comfy/couch/left/brown,         2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("brown couch right end",     /obj/structure/bed/chair/comfy/couch/right/brown,        2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("brown couch straight",      /obj/structure/bed/chair/comfy/couch/mid/brown,          2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("brown couch inwards turn",  /obj/structure/bed/chair/comfy/couch/turn/inward/brown,  2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("brown couch outwards turn", /obj/structure/bed/chair/comfy/couch/turn/outward/brown, 2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("black couch left end",      /obj/structure/bed/chair/comfy/couch/left/black,         2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("black couch right end",     /obj/structure/bed/chair/comfy/couch/right/black,        2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("black couch straight",      /obj/structure/bed/chair/comfy/couch/mid/black,          2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("black couch inwards turn",  /obj/structure/bed/chair/comfy/couch/turn/inward/black,  2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("black couch outwards turn", /obj/structure/bed/chair/comfy/couch/turn/outward/black, 2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("teal couch left end",       /obj/structure/bed/chair/comfy/couch/left/teal,          2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("teal couch right end",      /obj/structure/bed/chair/comfy/couch/right/teal,         2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("teal couch straight",       /obj/structure/bed/chair/comfy/couch/mid/teal,           2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("teal couch inwards turn",   /obj/structure/bed/chair/comfy/couch/turn/inward/teal,   2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("teal couch outwards turn",  /obj/structure/bed/chair/comfy/couch/turn/outward/teal,  2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("lime couch left end",       /obj/structure/bed/chair/comfy/couch/left/lime,          2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("lime couch right end",      /obj/structure/bed/chair/comfy/couch/right/lime,         2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("lime couch straight",       /obj/structure/bed/chair/comfy/couch/mid/lime,           2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("lime couch inwards turn",   /obj/structure/bed/chair/comfy/couch/turn/inward/lime,   2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("lime couch outwards turn",  /obj/structure/bed/chair/comfy/couch/turn/outward/lime,  2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("grey couch left end",       /obj/structure/bed/chair/comfy/couch/left,               2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("grey couch right end",      /obj/structure/bed/chair/comfy/couch/right,              2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("grey couch straight",       /obj/structure/bed/chair/comfy/couch/mid,                2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("grey couch inwards turn",   /obj/structure/bed/chair/comfy/couch/turn/inward,        2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("grey couch outwards turn",  /obj/structure/bed/chair/comfy/couch/turn/outward,       2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("red couch left end",        /obj/structure/bed/chair/comfy/couch/left/red,           2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("red couch right end",       /obj/structure/bed/chair/comfy/couch/right/red,          2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("red couch straight",        /obj/structure/bed/chair/comfy/couch/mid/red,            2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("red couch inwards turn",    /obj/structure/bed/chair/comfy/couch/turn/inward/red,    2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("red couch outwards turn",   /obj/structure/bed/chair/comfy/couch/turn/outward/red,   2, one_per_turf = 1, on_floor = 1),
		)),
	new/datum/stack_recipe("table parts", /obj/item/weapon/table_parts,                           2                                ),
	new/datum/stack_recipe("rack parts",  /obj/item/weapon/rack_parts                                                              ),
	new/datum/stack_recipe("closet",      /obj/structure/closet/basic,                            2, one_per_turf = 1, time = 15   ),
	new/datum/stack_recipe("metal crate", /obj/structure/closet/crate/basic,                      2,                   time = 15   ),
	null,
	new/datum/stack_recipe_list("airlock assemblies", list(
		new/datum/stack_recipe("standard airlock assembly",      /obj/structure/door_assembly,                            4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("command airlock assembly",       /obj/structure/door_assembly/door_assembly_com,          4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("security airlock assembly",      /obj/structure/door_assembly/door_assembly_sec,          4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("engineering airlock assembly",   /obj/structure/door_assembly/door_assembly_eng,          4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("mining airlock assembly",        /obj/structure/door_assembly/door_assembly_min,          4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("atmospherics airlock assembly",  /obj/structure/door_assembly/door_assembly_atmo,         4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("research airlock assembly",      /obj/structure/door_assembly/door_assembly_research,     4, time = 50, one_per_turf = 1, on_floor = 1),
/*		new/datum/stack_recipe("science airlock assembly",       /obj/structure/door_assembly/door_assembly_science,      4, time = 50, one_per_turf = 1, on_floor = 1), */
		new/datum/stack_recipe("medical airlock assembly",       /obj/structure/door_assembly/door_assembly_med,          4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("maintenance airlock assembly",   /obj/structure/door_assembly/door_assembly_mai,          4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("external airlock assembly",      /obj/structure/door_assembly/door_assembly_ext,          4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("freezer airlock assembly",       /obj/structure/door_assembly/door_assembly_fre,          4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("airtight hatch assembly",        /obj/structure/door_assembly/door_assembly_hatch,        4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("maintenance hatch assembly",     /obj/structure/door_assembly/door_assembly_mhatch,       4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("high security airlock assembly", /obj/structure/door_assembly/door_assembly_highsecurity, 4, time = 50, one_per_turf = 1, on_floor = 1),
/*		new/datum/stack_recipe("multi-tile airlock assembly",    /obj/structure/door_assembly/multi_tile,                 4, time = 50, one_per_turf = 1, on_floor = 1), */
		), 4),
	null,
	new/datum/stack_recipe("canister",        /obj/machinery/portable_atmospherics/canister, 10, time = 15, one_per_turf = 1			  ),
	new/datum/stack_recipe("iv drip",         /obj/machinery/iv_drip,                         2, time = 25, one_per_turf = 1			  ),
	new/datum/stack_recipe("meat spike",      /obj/structure/kitchenspike,                    2, time = 25, one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe("grenade casing",  /obj/item/weapon/grenade/chem_grenade                                                       ),
	new/datum/stack_recipe("desk bell shell", /obj/item/device/deskbell_assembly,             2                                           ),
	new/datum/stack_recipe("bunsen burner",   /obj/machinery/bunsen_burner,                   4, time = 50, one_per_turf = 1, on_floor = 1),
	null,
	new/datum/stack_recipe_list("mounted frames", list(
		new/datum/stack_recipe("apc frame",                 /obj/item/mounted/frame/apc_frame,            2                                           ),
		new/datum/stack_recipe("air alarm frame",           /obj/item/mounted/frame/alarm_frame,          2                                           ),
		new/datum/stack_recipe("fire alarm frame",          /obj/item/mounted/frame/firealarm,            2                                           ),
		new/datum/stack_recipe("lightswitch frame",         /obj/item/mounted/frame/light_switch,         2                                           ),
		new/datum/stack_recipe("intercom frame",            /obj/item/mounted/frame/intercom,             2                                           ),
		new/datum/stack_recipe("sound system frame",		/obj/item/mounted/frame/soundsystem,		  2											  ),
		new/datum/stack_recipe("nanomed frame",             /obj/item/mounted/frame/wallmed,              3, time = 25, one_per_turf = 0, on_floor = 1),
		new/datum/stack_recipe("station holomap frame",     /obj/item/mounted/frame/station_map,          3, time = 25, one_per_turf = 0, on_floor = 1),
		new/datum/stack_recipe("light fixture frame",       /obj/item/mounted/frame/light_fixture,        2                                           ),
		new/datum/stack_recipe("small light fixture frame", /obj/item/mounted/frame/light_fixture/small,  1                                           ),
		new/datum/stack_recipe("embedded controller frame", /obj/item/mounted/frame/airlock_controller,   1, time = 50, one_per_turf = 0, on_floor = 1),
		new/datum/stack_recipe("access button frame",       /obj/item/mounted/frame/access_button,        1, time = 50, one_per_turf = 0, on_floor = 1),
		new/datum/stack_recipe("airlock sensor frame",      /obj/item/mounted/frame/airlock_sensor,       1, time = 50, one_per_turf = 0, on_floor = 1),
		new/datum/stack_recipe("mass driver button frame",  /obj/item/mounted/frame/driver_button,        1, time = 50, one_per_turf = 0, on_floor = 1),
		new/datum/stack_recipe("lantern hook",              /obj/item/mounted/frame/hanging_lantern_hook, 1, time = 25, one_per_turf = 0, on_floor = 0),
		new/datum/stack_recipe("extinguisher cabinet", 		/obj/item/mounted/frame/extinguisher_cabinet, 2, time = 50, one_per_turf = 0, on_floor = 0),
		)),
	null,
	new/datum/stack_recipe("iron door", /obj/machinery/door/mineral/iron, 					20, 			one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe("stove", /obj/machinery/space_heater/campfire/stove, 			5, time = 25, 	one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe/dorf("training sword", /obj/item/weapon/melee/training_sword,	4, time = 12,	on_floor = 1, inherit_material = TRUE),
	)

/* ========================================================================
							PLASTEEL RECIPES
======================================================================== */
var/list/datum/stack_recipe/plasteel_recipes = list (
	new/datum/stack_recipe("AI core",						/obj/structure/AIcore,								4,	time = 50,	one_per_turf = 1				),
	new/datum/stack_recipe("Cage",							/obj/structure/cage,								6,  time = 100, one_per_turf = 1				),
	new/datum/stack_recipe("RUST fuel assembly port frame",	/obj/item/mounted/frame/rust_fuel_assembly_port,	12,	time = 50,	one_per_turf = 1				),
	new/datum/stack_recipe("RUST fuel compressor frame",	/obj/item/mounted/frame/rust_fuel_compressor,		12,	time = 50,	one_per_turf = 1				),
	new/datum/stack_recipe("Mass Driver frame",				/obj/machinery/mass_driver_frame,					3,	time = 50,	one_per_turf = 1				),
	new/datum/stack_recipe("Tank dispenser",				/obj/structure/dispenser/empty,						2,	time = 10,	one_per_turf = 1				),
	new/datum/stack_recipe("Fireaxe cabinet",				/obj/item/mounted/frame/fireaxe_cabinet_frame,		2,	time = 50									),
	null,
	new/datum/stack_recipe("Vault Door assembly",			/obj/structure/door_assembly/door_assembly_vault,	8,	time = 50,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe/dorf("dorf chair",              /obj/structure/bed/chair,                 one_per_turf = 1, on_floor = 1, inherit_material = TRUE),
	)

/* ====================================================================
							WOOD RECIPES
==================================================================== */
var/list/datum/stack_recipe/wood_recipes = list (
	new/datum/stack_recipe("wood floor tile",	/obj/item/stack/tile/wood,				1,4,20												),
	new/datum/stack_recipe("wall girders",		/obj/structure/girder/wood,				2, 		time = 25, 	one_per_turf = 1, 	on_floor = 1),
	new/datum/stack_recipe("wooden door",		/obj/machinery/door/mineral/wood,		10,		time = 20,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe("barricade kit",		/obj/item/weapon/barricade_kit,			5													),
	null,
	new/datum/stack_recipe("table parts",		/obj/item/weapon/table_parts/wood,		2													),
	new/datum/stack_recipe("wooden chair",		/obj/structure/bed/chair/wood/normal,	1,		time = 10,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe/dorf("dorf chair",              /obj/structure/bed/chair,                 one_per_turf = 1, on_floor = 1, inherit_material = TRUE),
	new/datum/stack_recipe("throne",			/obj/structure/bed/chair/wood/throne,	40,		time = 100,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe("bookcase",			/obj/structure/bookcase,				5,		time = 50,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe("coffin",			/obj/structure/closet/coffin,			5,		time = 15,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe("chest",				/obj/structure/closet/crate/chest,		10,		time = 50,	one_per_turf = 1,	on_floor = 1, other_reqs = list(/obj/item/stack/sheet/plasteel = 5)),
	new/datum/stack_recipe("coat rack",			/obj/structure/coatrack,				2,		time = 20,	one_per_turf = 1,	on_floor = 1),
	null,
	new/datum/stack_recipe("campfire",			/obj/machinery/space_heater/campfire,	4,		time = 35,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe("spit",				/obj/machinery/cooking/grill/spit,		1,		time = 10,	one_per_turf = 1,	on_floor = 1),
	null,
	new/datum/stack_recipe("wooden block",		/obj/structure/block/wood,				10,		time = 50,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe("apiary",			/obj/item/apiary,						10,		time = 25,	one_per_turf = 0,	on_floor = 0),
	new/datum/stack_recipe("blank canvas",		/obj/item/mounted/frame/painting/blank,	2,		time = 15									),
	new/datum/stack_recipe("trophy mount",		/obj/item/mounted/frame/trophy_mount,	2,		time = 15									),
	new/datum/stack_recipe("notice board",		/obj/structure/noticeboard,				2,		time = 15,	one_per_turf = 1,	on_floor = 1),
	null,
	new/datum/stack_recipe("wooden sandals",	/obj/item/clothing/shoes/sandal																),
	new/datum/stack_recipe("peg limb",			/obj/item/weapon/peglimb,				2,		time = 50									),
	new/datum/stack_recipe("clipboard",			/obj/item/weapon/storage/bag/clipboard,	1													),
	new/datum/stack_recipe("bowl",				/obj/item/trash/bowl,					1													),
	null,
	new/datum/stack_recipe("boomerang",			/obj/item/weapon/boomerang,				6,		time = 50									),
	new/datum/stack_recipe("buckler",			/obj/item/weapon/shield/riot/buckler,	5,		time = 50									),
	new/datum/stack_recipe("wooden paddle",		/obj/item/weapon/macuahuitl,			1,		time = 50									),
	new/datum/stack_recipe/dorf("training sword", /obj/item/weapon/melee/training_sword,	4, time = 12,	on_floor = 1, inherit_material = TRUE)
	)

/* =========================================================================
							CARDBOARD RECIPES
========================================================================= */
var/list/datum/stack_recipe/cardboard_recipes = list (
	new/datum/stack_recipe("box",                           /obj/item/weapon/storage/box                            ),
	new/datum/stack_recipe("large box",                     /obj/item/weapon/storage/box/large,                  4  ),
	new/datum/stack_recipe("light tubes box",               /obj/item/weapon/storage/box/lights/tubes               ),
	new/datum/stack_recipe("light bulbs box",               /obj/item/weapon/storage/box/lights/bulbs               ),
	new/datum/stack_recipe("mouse traps box",               /obj/item/weapon/storage/box/mousetraps                 ),
	new/datum/stack_recipe("candle box",                    /obj/item/weapon/storage/fancy/candle_box/empty         ),
	new/datum/stack_recipe("crayon box",                    /obj/item/weapon/storage/fancy/crayons/empty            ),
	new/datum/stack_recipe("cardborg suit",                 /obj/item/clothing/suit/cardborg,                    3  ),
	new/datum/stack_recipe("cardborg helmet",               /obj/item/clothing/head/cardborg                        ),
	new/datum/stack_recipe("pizza box",                     /obj/item/pizzabox                                      ),
	new/datum/stack_recipe("folder",                        /obj/item/weapon/folder                                 ),
	new/datum/stack_recipe("flare box",                     /obj/item/weapon/storage/fancy/flares/empty             ),
	new/datum/stack_recipe("donut box",                     /obj/item/weapon/storage/fancy/donut_box/empty          ),
	new/datum/stack_recipe("eggbox",                        /obj/item/weapon/storage/fancy/egg_box/empty            ),
	new/datum/stack_recipe("paper bin",                     /obj/item/weapon/paper_bin/empty                        ),
	new/datum/stack_recipe("empty recharge pack",           /obj/structure/vendomatpack/custom,                  4  ),
	)

/* ========================================================================
							LEATHER RECIPES
======================================================================== */
/datum/stack_recipe/leather/finish_building(var/mob/usr, var/obj/item/stack/S, var/obj/R)
	if(istype(S, /obj/item/stack/sheet/leather))
		var/obj/item/stack/sheet/leather/L = S
		if(findtext(lowertext(R.name), "leather"))
			R.name = "[L.source_string ? "[L.source_string]" : ""] [R.name]"
		else
			R.name = "[L.source_string ? "[L.source_string] leather " : ""] [R.name]"

var/list/datum/stack_recipe/leather_recipes = list (
	new/datum/stack_recipe/leather("Bullwhip",		/obj/item/weapon/bullwhip,					10,	time = 100,),
	new/datum/stack_recipe/leather("Cowboy hat",	/obj/item/clothing/head/cowboy,				4,	time = 70,),
	new/datum/stack_recipe/leather("Leather gloves",/obj/item/clothing/gloves/botanic_leather,	2,	time = 90,),
	new/datum/stack_recipe/leather("Leather shoes",	/obj/item/clothing/shoes/leather,			4,	time = 80,),
	new/datum/stack_recipe/leather("Leather satchel",/obj/item/weapon/storage/backpack/satchel,	12,	time = 130,),
	new/datum/stack_recipe/leather("Leather wallet",/obj/item/weapon/storage/wallet,			4,	time = 90,),
	new/datum/stack_recipe/leather("Leather helmet",/obj/item/clothing/head/leather,			3,	time = 90,on_floor = 1),
	new/datum/stack_recipe/leather("Leather armor",/obj/item/clothing/suit/leather,				6,	time = 90,on_floor = 1),
	)

/* ========================================================================
							BRASS RECIPES
======================================================================== */

var/list/datum/stack_recipe/brass_recipes = list (
	new/datum/stack_recipe("brass window", /obj/structure/window/reinforced/clockwork, 2, time = 10, on_floor = TRUE, other_reqs = list(/obj/item/stack/sheet/ralloy = 1)),
	new/datum/stack_recipe("brass full window", /obj/structure/window/full/reinforced/clockwork, 4, time = 20, one_per_turf = TRUE, on_floor = TRUE, other_reqs = list(/obj/item/stack/sheet/ralloy = 1)),
	new/datum/stack_recipe("brass table parts", /obj/item/weapon/table_parts/clockwork, 4),
	new/datum/stack_recipe("clockwork girders", /obj/structure/girder/clockwork, 3, time = 70, one_per_turf = TRUE, on_floor = TRUE, other_reqs = list(/obj/item/stack/sheet/ralloy = 3)),
	new/datum/stack_recipe/dorf("dorf chair", /obj/structure/bed/chair, one_per_turf = TRUE, on_floor = TRUE, inherit_material = TRUE),
	new/datum/stack_recipe/dorf("training sword", /obj/item/weapon/melee/training_sword, 4, time = 12,	on_floor = TRUE, inherit_material = TRUE),
	)

/* ========================================================================
							REPLICANT ALLOY RECIPES
======================================================================== */

var/list/datum/stack_recipe/ralloy_recipes = list (
	new/datum/stack_recipe("replicant grille", /obj/structure/grille/replicant, 2, time = 10, one_per_turf = TRUE, on_floor = TRUE),
	new/datum/stack_recipe/dorf("dorf chair", /obj/structure/bed/chair, one_per_turf = TRUE, on_floor = TRUE, inherit_material = TRUE),
	new/datum/stack_recipe/dorf("training sword", /obj/item/weapon/melee/training_sword, 4, time = 12,	on_floor = TRUE, inherit_material = TRUE),
	)
