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
	var/z_up_required = 0
	var/z_down_required = 0
	var/list/other_reqs = list()
	var/list/extra_data = list()

/datum/stack_recipe/New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1, time = 0, one_per_turf = 0, on_floor = 0, start_unanchored = 0, other_reqs = list(), z_up_required = 0, z_down_required = 0)
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
	src.z_up_required = z_up_required
	src.z_down_required = z_down_required

/datum/stack_recipe/proc/can_build_here(var/mob/usr, var/turf/T)
	if(one_per_turf && locate(result_type) in T)
		to_chat(usr, "<span class='warning'>There is another [title] here!</span>")
		return 0
	if(on_floor && (istype(T, /turf/space)))
		to_chat(usr, "<span class='warning'>\The [title] must be constructed on solid floor!</span>")
		return 0
	return 1

/datum/stack_recipe/proc/finish_building(var/mob/usr, var/obj/item/stack/S, var/R) //This will be called after the recipe is done building, useful for doing something to the result if you want.
	return R

/datum/stack_recipe/proc/before_build(var/mob/user)
	return TRUE

/datum/stack_recipe/proc/build(var/mob/usr, var/obj/item/stack/S, var/multiplier = 1, var/turf/construct_loc)
	if (!before_build(usr))
		return
	if (S.amount < req_amount*multiplier)
		if (res_amount*multiplier>1)
			to_chat(usr, "<span class='warning'>You haven't got enough [S.irregular_plural ? S.irregular_plural : "[S.singular_name]\s"] to build [res_amount*multiplier] [title]\s!</span>")
		else
			to_chat(usr, "<span class='warning'>You haven't got enough [S.irregular_plural ? S.irregular_plural : "[S.singular_name]\s"] to build \the [title]!</span>")
		return
	if(!construct_loc)
		construct_loc = usr.loc
	if (!can_build_here(usr, construct_loc))
		return
	var/current_work = round(world.time)
	S.last_work = current_work
	if (time)
		var/actual_time = S.time_modifier(time)
		if (!do_after(usr, get_turf(S), actual_time))
			S.stop_build(current_work == S.last_work)
			return
	if (S.amount < req_amount*multiplier)
		S.stop_build(current_work == S.last_work)
		return
	var/list/stacks_to_consume = list()
	if(other_reqs.len)
		for(var/i=1 to other_reqs.len)
			var/looking_for = other_reqs[i]
			var/req_amount
			var/found = FALSE
			if(ispath(looking_for, /obj/item/stack))
				req_amount = other_reqs[looking_for]
			if(ispath(usr.get_inactive_hand(), looking_for))
				found = TRUE
				if(req_amount) //It's of a stack/sheet subtype
					var/obj/item/stack/SS = usr.get_inactive_hand()
					if(SS.amount < req_amount)
						found = FALSE
					else
						stacks_to_consume.Add(SS)
						stacks_to_consume[S] = req_amount
					continue
			for(var/obj/I in range(get_turf(usr),1))
				if(ispath(looking_for, I))
					found = TRUE
					if(req_amount) //It's of a stack/sheet subtype
						var/obj/item/stack/SS = I
						if(SS.amount < req_amount)
							found = FALSE
						else
							stacks_to_consume.Add(SS)
							stacks_to_consume[SS] = req_amount
			if(!found)
				S.stop_build(current_work == S.last_work)
				return
	var/atom/O
	if(ispath(result_type, /obj/item/stack))
		O = drop_stack(result_type, construct_loc, (max_res_amount>1 ? res_amount*multiplier : 1), usr)
		var/obj/item/stack/SS = O
		SS.update_materials()
	else
		for(var/i = 1 to (max_res_amount>1 ? res_amount*multiplier : 1))
			O = new result_type(construct_loc)

	S.stop_build(current_work == S.last_work)
	O.change_dir(usr.dir)
	if(start_unanchored)
		var/obj/A = O
		A.anchored = 0
	var/put_in_hand = finish_building(usr, S, O)

	//if (R.max_res_amount>1)
	//	var/obj/item/stack/new_item = O
	//	new_item.amount = R.res_amount*multiplier
	//	//new_item.add_to_stacks(usr)

	S.use(req_amount*multiplier)
	for(var/obj/item/stack/SS in stacks_to_consume)
		SS.use(stacks_to_consume[SS])
	if (S.amount<=0)
		usr.before_take_item(S)
		if(put_in_hand && istype(O,/obj/item))
			usr.put_in_hands(O)
	O.add_fingerprint(usr)
	//BubbleWrap - so newly formed boxes are empty //This is pretty shitcode but I'm not fixing it because even if sloth is a sin I am already going to hell anyways
	if (istype(O, /obj/item/weapon/storage) )
		for(var/obj/item/I in O)
			qdel(I)

	return put_in_hand

//Recipe list datum
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes = null
	var/req_amount = 1

/datum/stack_recipe_list/New(title, recipes, req_amount = 1)
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

/datum/stack_recipe/chair/finish_building(var/mob/usr, var/obj/item/stack/S, var/R) //This will be called after the recipe is done building, useful for doing something to the result if you want.
	var/obj/structure/bed/chair/new_chair = R
	if (istype(new_chair))
		new_chair.handle_layer()
	return R

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

		//Figure out the material
		if(istype(S, /obj/item/stack/sheet/))
			var/obj/item/stack/sheet/SS = S
			mat = materials_list.getMaterial(SS.mat_type)
		else if(S.material_type)
			mat = S.material_type

		// Make it recyclable back into the materials it's made out of
		// Initialize materials list if doesn't exist already
		if (R.materials == null)
			R.materials = new /datum/materials(src)

		// Add main materials off the stack
		R.materials.addRatioFrom(S.materials, req_amount/(S.amount * res_amount))

		// Add extra materials off additional recipe requisites
		for (var/req in other_reqs)
			// other_reqs contains typepaths, so create an instance and use it's materials as base
			// TODO: pull the materials from the actual object that was used to fulfill the other_req
			var/atom/movable/A = new req
			if (A.materials)
				R.materials.addRatioFrom(A.materials, other_reqs[req]/res_amount)

		R.dorfify(mat)
	return 1


/datum/stack_recipe/blacksmithing
	var/req_strikes = 15

/datum/stack_recipe/blacksmithing/New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1, time = 0, one_per_turf = 0, on_floor = 0, start_unanchored = 0, other_reqs = list(), inherit_material = FALSE, gen_quality = FALSE, required_strikes = 0)
	..()
	src.req_strikes = required_strikes

/datum/stack_recipe/blacksmithing/finish_building(mob/usr, var/obj/item/stack/S, var/obj/R)
	// Figure out main material from stack
	if(istype(S, /obj/item/stack/sheet/))
		var/obj/item/stack/sheet/SS = S
		var/datum/materials/materials_list = new
		R.material_type = materials_list.getMaterial(SS.mat_type)
		qdel(materials_list)
	else if(S.material_type)
		R.material_type = S.material_type

	// Apply material info to end product for recycling
	// Initialize materials list if doesn't exist already
	if (R.materials == null)
		R.materials = new /datum/materials(src)

	// Add main materials off the stack
	R.materials.addRatioFrom(S.materials, req_amount/(S.amount * res_amount))

	// Add extra materials off additional recipe requisites
	for (var/req in other_reqs)
		// other_reqs contains typepaths, so create an instance and use it's materials as base
		// TODO: pull the materials from the actual object that was used to fulfill the other_req
		var/atom/movable/A = new req
		if (A.materials)
			R.materials.addRatioFrom(A.materials, other_reqs[req]/res_amount)

	//Yeah nah let's put you in a blacksmith_placeholder
	var/obj/item/I = new /obj/item/smithing_placeholder(usr.loc, S, R, req_strikes)
	I.name = "unforged [R.name]"
	return 0

var/datum/stack_recipe_list/blacksmithing_recipes = new("blacksmithing recipes", list(
	new/datum/stack_recipe/blacksmithing("hammer head", /obj/item/item_head/hammer_head,			4, time = 5 SECONDS, required_strikes = 6),
	new/datum/stack_recipe/blacksmithing("pickaxe head", /obj/item/item_head/pickaxe_head,			4, time = 5 SECONDS, required_strikes = 8),
	new/datum/stack_recipe/blacksmithing("pitchfork head", /obj/item/item_head/pitchfork_head,		4, time = 5 SECONDS, required_strikes = 6),
	new/datum/stack_recipe/blacksmithing("sword crossguard", /obj/item/cross_guard,					4, time = 5 SECONDS, required_strikes = 4),
	null,
	new/datum/stack_recipe/blacksmithing("sword blade", /obj/item/item_head/sword,					8, time = 8 SECONDS, required_strikes = 13),
	new/datum/stack_recipe/blacksmithing("scimitar blade", /obj/item/item_head/sword/scimitar,		8, time = 8 SECONDS, required_strikes = 13),
	new/datum/stack_recipe/blacksmithing("shortsword blade", /obj/item/item_head/sword/shortsword,	8, time = 8 SECONDS, required_strikes = 13),
	new/datum/stack_recipe/blacksmithing("gladius blade", /obj/item/item_head/sword/gladius,		8, time = 8 SECONDS, required_strikes = 13),
	new/datum/stack_recipe/blacksmithing("sabre blade", /obj/item/item_head/sword/sabre,			8, time = 8 SECONDS, required_strikes = 13),
	new/datum/stack_recipe/blacksmithing("tower shield", /obj/item/item_head/tower_shield,			20, time = 10 SECONDS, required_strikes = 20, other_reqs = list(/obj/item/stack/sheet/plasteel = 5)),
	))


var/list/datum/stack_recipe/metal_recipes = list (
	new/datum/stack_recipe("floor tile", /obj/item/stack/tile/metal, 1, 4, 60),
	new/datum/stack_recipe("metal rod",  /obj/item/stack/rods,          1, 2, 60),
	new/datum/stack_recipe("conveyor belt", /obj/item/stack/conveyor_assembly, 2, 1, 20),
	//new/datum/stack_recipe/dorf("chain", /obj/item/stack/chains, 2, 1, 20, 5, inherit_material = TRUE),
	null,
	new/datum/stack_recipe("computer frame", /obj/structure/computerframe,                      5, time = 25, one_per_turf = 1			    ),
	new/datum/stack_recipe("wall girders",   /obj/structure/girder,                             2, time = 50, one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe("railings",   /obj/structure/railing/loose,             				2, time = 25, on_floor = 1),
	new/datum/stack_recipe("firelock frame", /obj/item/firedoor_frame,                          5, time = 50),
	new/datum/stack_recipe("machine frame",  /obj/machinery/constructable_frame/machine_frame,  5, time = 25, one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe("mirror frame",   /obj/structure/mirror_frame,                       5, time = 25, one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe("turret frame",   /obj/machinery/porta_turret_construct,             5, time = 25, one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe("solar assembly",   /obj/machinery/power/solar_assembly,             5, time = 25),
	null,
	new/datum/stack_recipe_list("chairs and beds",list(
		new/datum/stack_recipe/chair("dark office chair",  /obj/structure/bed/chair/office/dark,  1, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("light office chair", /obj/structure/bed/chair/office/light, 1, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("beige comfy chair",  /obj/structure/bed/chair/comfy/beige,  1, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("black comfy chair",  /obj/structure/bed/chair/comfy/black,  1, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("brown comfy chair",  /obj/structure/bed/chair/comfy/brown,  1, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("lime comfy chair",   /obj/structure/bed/chair/comfy/lime,   1, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("teal comfy chair",   /obj/structure/bed/chair/comfy/teal,   1, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("red comfy chair",   /obj/structure/bed/chair/comfy/red,   1, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("stool",              /obj/item/weapon/stool												   ),
		new/datum/stack_recipe/chair("bar stool",          /obj/item/weapon/stool/bar                                              ),
		new/datum/stack_recipe/chair("chair",              /obj/structure/bed/chair,                 one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("folding chair",      /obj/structure/bed/chair/folding,         one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("bed",                      /obj/structure/bed,                    2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/dorf("dorf chair",              /obj/structure/bed/chair,                 one_per_turf = 1, on_floor = 1, inherit_material = TRUE, gen_quality = TRUE),
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
		), 2),
	new/datum/stack_recipe("table parts", /obj/item/weapon/table_parts,                           2                                ),
	new/datum/stack_recipe("rack parts",  /obj/item/weapon/rack_parts,                                                             ),
	new/datum/stack_recipe("filing cabinet", /obj/structure/filingcabinet/filingcabinet,						  2, one_per_turf = 1, time = 15   ),
	new/datum/stack_recipe("closet",      /obj/structure/closet/basic,                            2, one_per_turf = 1, time = 15   ),
	new/datum/stack_recipe("metal crate", /obj/structure/closet/crate/basic,                      2, one_per_turf = 1, time = 15   ),
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
	new/datum/stack_recipe("metal bucket", /obj/item/weapon/reagent_containers/glass/metal_bucket, 3, time = 3 SECONDS, one_per_turf = 0, on_floor = 0),
	new/datum/stack_recipe("barrel",          /obj/structure/reagent_dispensers/cauldron/barrel, 20, time = 5 SECONDS, one_per_turf = 1   ),
	new/datum/stack_recipe("gas tank",        /obj/machinery/atmospherics/unary/tank/empty/unanchored, 5, time = 15, one_per_turf = 1),
	new/datum/stack_recipe("canister",        /obj/machinery/portable_atmospherics/canister, 10, time = 15, one_per_turf = 1			  ),
	new/datum/stack_recipe("cauldron",        /obj/structure/reagent_dispensers/cauldron,                       20, time = 5 SECONDS, one_per_turf = 1,	  ),
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
		new/datum/stack_recipe("embedded controller frame", /obj/item/mounted/frame/airlock_controller,   2, time = 50, one_per_turf = 0, on_floor = 1),
		new/datum/stack_recipe("access button frame",       /obj/item/mounted/frame/access_button,        1, time = 50, one_per_turf = 0, on_floor = 1),
		new/datum/stack_recipe("airlock sensor frame",      /obj/item/mounted/frame/airlock_sensor,       1, time = 50, one_per_turf = 0, on_floor = 1),
		new/datum/stack_recipe("mass driver button frame",  /obj/item/mounted/frame/driver_button,        1, time = 50, one_per_turf = 0, on_floor = 1),
		new/datum/stack_recipe("lantern hook",              /obj/item/mounted/frame/hanging_lantern_hook, 1, time = 25, one_per_turf = 0, on_floor = 0),
		new/datum/stack_recipe("extinguisher cabinet", 		/obj/item/mounted/frame/extinguisher_cabinet, 2, time = 50, one_per_turf = 0, on_floor = 0),
		)),
	null,
	new/datum/stack_recipe_list("transit tube parts", list(
		new/datum/stack_recipe("straight tube",				/obj/structure/transit_tube_frame,				4, time = 4 SECONDS, one_per_turf = 0   ),
		new/datum/stack_recipe("diagonal tube",				/obj/structure/transit_tube_frame/diag,			4, time = 4 SECONDS, one_per_turf = 0   ),
		new/datum/stack_recipe("bent tube",					/obj/structure/transit_tube_frame/bent,			4, time = 4 SECONDS, one_per_turf = 0   ),
		new/datum/stack_recipe("inverted bent tube",		/obj/structure/transit_tube_frame/bent_invert,	4, time = 4 SECONDS, one_per_turf = 0   ),
		new/datum/stack_recipe("fork tube",					/obj/structure/transit_tube_frame/fork,			4, time = 4 SECONDS, one_per_turf = 0   ),
		new/datum/stack_recipe("inverted fork tube",		/obj/structure/transit_tube_frame/fork_invert,	4, time = 4 SECONDS, one_per_turf = 0   ),
		new/datum/stack_recipe("station",					/obj/structure/transit_tube_frame/station,		4, time = 4 SECONDS, one_per_turf = 0   ),
		new/datum/stack_recipe("pod",						/obj/structure/transit_tube_frame/pod,			4, time = 4 SECONDS, one_per_turf = 0   ),
		), 4),
	null,
	new/datum/stack_recipe("iron door", /obj/machinery/door/mineral/iron, 					20, 			one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe("stove", /obj/machinery/space_heater/campfire/stove, 			5, time = 25, 	one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe/dorf("chain", /obj/item/stack/chains, 2, 1, 20, 5, inherit_material = TRUE),
	new/datum/stack_recipe("spring", /obj/item/spring, 					1, time = 25, one_per_turf = 0, on_floor = 0),
	new/datum/stack_recipe("cannonball", /obj/item/cannonball/iron, 20, time = 4 SECONDS, one_per_turf = 0, on_floor = 1),
	new/datum/stack_recipe("frying pan", /obj/item/weapon/reagent_containers/pan, 10, time = 4 SECONDS, one_per_turf = 0, on_floor = 0),
	new/datum/stack_recipe("lunch box", /obj/item/weapon/storage/lunchbox/metal, 1, time = 2 SECONDS, one_per_turf = 0, on_floor = 0),
	null,
	blacksmithing_recipes,
	null,
	new/datum/stack_recipe("multi-floor stairs",   /obj/structure/stairs_frame, 4, time = 100, one_per_turf = 1, on_floor = 1, z_up_required = 1),
	)

/* ========================================================================
							PLASTEEL RECIPES
======================================================================== */
var/list/datum/stack_recipe/plasteel_recipes = list (
	new/datum/stack_recipe("reinforced floor tile", /obj/item/stack/tile/metal/plasteel, 1, 4, 60),
	new/datum/stack_recipe("plasteel bolts",				/obj/item/stack/bolts,								1,	time = 20),
	new/datum/stack_recipe("railings",   					/obj/structure/railing/plasteel/loose,             	2, time = 50, on_floor = 1),
	new/datum/stack_recipe("AI core",						/obj/structure/AIcore,								4,	time = 50,	one_per_turf = 1				),
	new/datum/stack_recipe("Cage",							/obj/structure/cage,								6,  time = 100, one_per_turf = 1				),
	new/datum/stack_recipe("Small Cage",					/obj/item/critter_cage,								2,  time = 50,	one_per_turf = 0				),
	new/datum/stack_recipe("RUST fuel assembly port frame",	/obj/item/mounted/frame/rust_fuel_assembly_port,	12,	time = 50,	one_per_turf = 1				),
	new/datum/stack_recipe("RUST fuel compressor frame",	/obj/item/mounted/frame/rust_fuel_compressor,		12,	time = 50,	one_per_turf = 1				),
	new/datum/stack_recipe("Mass Driver frame",				/obj/machinery/mass_driver_frame,					3,	time = 50,	one_per_turf = 1				),
	new/datum/stack_recipe("Tank dispenser",				/obj/structure/dispenser/empty,						2,	time = 10,	one_per_turf = 1				),
	new/datum/stack_recipe("Fireaxe cabinet",				/obj/item/mounted/frame/fireaxe_cabinet_frame,		2,	time = 50									),
	null,
	new/datum/stack_recipe("Vault Door assembly",			/obj/structure/door_assembly/door_assembly_vault,	8,	time = 50,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe/dorf("dorf chair",              /obj/structure/bed/chair,                 one_per_turf = 1, on_floor = 1, inherit_material = TRUE, gen_quality = TRUE),
	null,
	new/datum/stack_recipe("Weight Machine",				/obj/structure/weightlifter,						2,	time = 50,	one_per_turf = 1				),
	new/datum/stack_recipe_list("Vehicle Beds",list(
		new/datum/stack_recipe("race car bed",                      /obj/structure/bed/racecar,                    2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("classic race car bed",                      /obj/structure/bed/racecar/classic,                    2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("shuttle bed",                      /obj/structure/bed/racecar/shuttle,                    2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("fire truck bed",                      /obj/structure/bed/racecar/firetruck,                    2, one_per_turf = 1, on_floor = 1),
		)),
	)

/* ====================================================================
							WOOD RECIPES
==================================================================== */
var/list/datum/stack_recipe/wood_recipes = list (
	new/datum/stack_recipe("wood floor tile",	/obj/item/stack/tile/wood,				1,4,20												),
	new/datum/stack_recipe("wall girders",		/obj/structure/girder/wood,				2, 		time = 25, 	one_per_turf = 1, 	on_floor = 1),
	new/datum/stack_recipe("wooden door",		/obj/machinery/door/mineral/wood,		10,		time = 20,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe("barricade kit",		/obj/item/weapon/barricade_kit,			5													),
	new/datum/stack_recipe("railings",   		/obj/structure/railing/wood/loose,      2,		time = 25, on_floor = 1),
	null,
	new/datum/stack_recipe("barrel",            /obj/structure/reagent_dispensers/cauldron/barrel/wood, 20, time = 5 SECONDS, one_per_turf = 1   ),
	new/datum/stack_recipe("table parts",		/obj/item/weapon/table_parts/wood,		2													),
	new/datum/stack_recipe("wooden chair",		/obj/structure/bed/chair/wood/normal,	1,		time = 10,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe/dorf("dorf chair",              /obj/structure/bed/chair,                 one_per_turf = 1, on_floor = 1, inherit_material = TRUE, gen_quality = TRUE),
	new/datum/stack_recipe("throne",			/obj/structure/bed/chair/wood/throne,	40,		time = 100,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe("bookcase",			/obj/structure/bookcase,				5,		time = 50,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe("closet",			/obj/structure/closet/cabinet/basic,			2,		time = 15,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe("coffin",			/obj/structure/closet/coffin,			5,		time = 15,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe("chest",				/obj/structure/closet/crate/chest,		10,		time = 50,	one_per_turf = 1,	on_floor = 1, other_reqs = list(/obj/item/stack/sheet/plasteel = 5)),
	new/datum/stack_recipe("coat rack",			/obj/structure/coatrack,				2,		time = 20,	one_per_turf = 1,	on_floor = 1),
	null,
	new/datum/stack_recipe("campfire",			/obj/machinery/space_heater/campfire,	4,		time = 35,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe("spit",				/obj/machinery/cooking/grill/spit,		1,		time = 10,	one_per_turf = 1,	on_floor = 1),
	null,
	new/datum/stack_recipe("apiary",			/obj/item/apiary,						10,		time = 25,	one_per_turf = 0,	on_floor = 0),
	new/datum/stack_recipe("trophy mount",		/obj/item/mounted/frame/trophy_mount,	2,		time = 15									),
	new/datum/stack_recipe("notice board",		/obj/structure/noticeboard,				2,		time = 15,	one_per_turf = 1,	on_floor = 1),
	null,
	//Painting
	new/datum/stack_recipe("knitting needles",	/obj/item/knitting_needles,				1,		time = 10,	one_per_turf = 0,	on_floor = 0),
	new/datum/stack_recipe("manual loom",		/obj/structure/spinning_wheel,			10,		time = 25,	one_per_turf = 0,	on_floor = 0),
	new/datum/stack_recipe_list("art supplies", list(
		new/datum/stack_recipe("wooden block",		/obj/structure/block/wood,							10,	time = 50,	one_per_turf = 1,	on_floor = 1),
		null,
		new/datum/stack_recipe("painting brush",	/obj/item/painting_brush,					1,	time = 15									),
		new/datum/stack_recipe("small canvas",		/obj/item/mounted/frame/painting/custom,			2,	time = 15									),
		new/datum/stack_recipe("portrait canvas",	/obj/item/mounted/frame/painting/custom/portrait,	3,	time = 15									),
		new/datum/stack_recipe("landscape canvas",	/obj/item/mounted/frame/painting/custom/landscape,	3,	time = 15									),
		new/datum/stack_recipe("large canvas",		/obj/item/mounted/frame/painting/custom/large,		5,	time = 15									),
		new/datum/stack_recipe("palette",			/obj/item/palette,							3,	time = 15									),
		new/datum/stack_recipe("easel",				/obj/structure/easel,								3,	time = 15									),
	)),
	null,
	new/datum/stack_recipe("wooden sandals",	/obj/item/clothing/shoes/sandal																),
	new/datum/stack_recipe("peg limb",			/obj/item/weapon/peglimb,				2,		time = 50									),
	new/datum/stack_recipe("clipboard",			/obj/item/weapon/storage/bag/clipboard,	1													),
	new/datum/stack_recipe("bowl",				/obj/item/trash/bowl,					1													),
	null,
	new/datum/stack_recipe("boomerang",			/obj/item/weapon/boomerang,				6,		time = 50									),
	new/datum/stack_recipe("buckler",			/obj/item/weapon/shield/riot/buckler,	5,		time = 50									),
	new/datum/stack_recipe("item handle",		/obj/item/item_handle,					1,2,20,	time = 2 SECONDS							),
	new/datum/stack_recipe("sword handle",		/obj/item/sword_handle,					1,2,10,	time = 2 SECONDS,							other_reqs = list(/obj/item/stack/sheet/metal = 1)),
	new/datum/stack_recipe("wooden paddle",		/obj/item/weapon/macuahuitl,			1,		time = 50									),
	new/datum/stack_recipe("baseball bat",		/obj/item/weapon/bat,					10,		time = 8 SECONDS							),
	)

/* =========================================================================
							CARDBOARD RECIPES
========================================================================= */
var/list/datum/stack_recipe/cardboard_recipes = list (
	new/datum/stack_recipe("box",                           /obj/item/weapon/storage/box                            ),
	new/datum/stack_recipe("large box",                     /obj/item/weapon/storage/box/large,                  4  ),
	new/datum/stack_recipe("light tubes box",               /obj/item/weapon/storage/box/lights/tubes               ),
	new/datum/stack_recipe("light bulbs box",               /obj/item/weapon/storage/box/lights               ),
	new/datum/stack_recipe("mouse traps box",               /obj/item/weapon/storage/box/mousetraps                 ),
	new/datum/stack_recipe("candle box",                    /obj/item/weapon/storage/fancy/candle_box/empty         ),
	new/datum/stack_recipe("crayon box",                    /obj/item/weapon/storage/fancy/crayons/empty            ),
	new/datum/stack_recipe("cardborg suit",                 /obj/item/clothing/suit/cardborg,                    3  ),
	new/datum/stack_recipe("cardborg helmet",               /obj/item/clothing/head/cardborg                        ),
	new/datum/stack_recipe("pizza box",                     /obj/item/pizzabox                                      ),
	new/datum/stack_recipe("folder",                        /obj/item/weapon/folder                                 ),
	new/datum/stack_recipe("flare box",                     /obj/item/weapon/storage/fancy/flares/empty             ),
	new/datum/stack_recipe("donut box",                     /obj/item/weapon/storage/fancy/donut_box/empty          ),
	new/datum/stack_recipe("beer box",						/obj/item/weapon/storage/fancy/beer_box/empty			),
	new/datum/stack_recipe("eggbox",                        /obj/item/weapon/storage/fancy/egg_box/empty            ),
	new/datum/stack_recipe("paper bin",                     /obj/item/weapon/paper_bin/empty                        ),
	new/datum/stack_recipe("empty recharge pack",           /obj/structure/vendomatpack/custom,                  4  ),
	)

/* =========================================================================
							CLOTH RECIPES
========================================================================= */

var/list/datum/stack_recipe/cloth_recipes_by_hand = list (
	"Simple Items",
	new/datum/stack_recipe/cloth("Cleaning Rag",	/obj/item/weapon/reagent_containers/glass/rag,	1,	time = 20),
	new/datum/stack_recipe/cloth("Toga",			/obj/item/clothing/under/toga,					3,	time = 50),
	new/datum/stack_recipe/cloth("Bedsheet",		/obj/item/weapon/bedsheet/linen,				2,	time = 20),
	)

//keep in mind that tool crafting time is reduced by x0.75 with needles and x0.5 with a sewing machine, then all the way down to x0.1 with upgrades
//a rule of thumb I settled on is 40 ticks per cloth used for the recipe
var/list/datum/stack_recipe/cloth_recipes_with_tool = list (
	null,
	"Uniforms",
	new/datum/stack_recipe/cloth("Jumpsuit",				/obj/item/clothing/under/color/linen,			5,	time = 200),
	new/datum/stack_recipe/cloth/composite("Composite Set",	/obj/item/clothing/under/composite,2),
	new/datum/stack_recipe/cloth("Sleeve-less Dress",		/obj/item/clothing/under/dress,					4,	time = 160),
	new/datum/stack_recipe/cloth("Villager Dress",			/obj/item/clothing/under/villager_dress,		5,	time = 200),
	"Suits",
	new/datum/stack_recipe/cloth("Labcoat",					/obj/item/clothing/suit/storage/labcoat/linen,	3,	time = 120),
	"Hats",
	new/datum/stack_recipe/cloth("Soft Cap",				/obj/item/clothing/head/soft/linen,				2,	time = 80),
	new/datum/stack_recipe/cloth("Flat Cap",				/obj/item/clothing/head/flatcap/linen,			2,	time = 80),
	new/datum/stack_recipe/cloth("Ushanka",					/obj/item/clothing/head/ushanka/linen,			3,	time = 120),
	"Masks",
	new/datum/stack_recipe/cloth("Ski Mask",				/obj/item/clothing/mask/balaclava/skimask/linen,2,	time = 80),
	new/datum/stack_recipe/cloth("Scarf",					/obj/item/clothing/mask/scarf/linen,			1,	time = 40),
	"Gloves",
	new/datum/stack_recipe/cloth("Mittens",					/obj/item/clothing/gloves/mittens,				2,	time = 80),
	"Accessories",
	new/datum/stack_recipe/cloth("Tie",						/obj/item/clothing/accessory/tie/linen,			1,	time = 40),
	new/datum/stack_recipe/cloth("Armband",					/obj/item/clothing/accessory/armband/linen,		1,	time = 40),
	)

/datum/stack_recipe/cloth/composite/before_build(var/mob/user)
	//first we pick some pants
	extra_data = list()
	time = 0
	req_amount = 0
	var/list/available_pants = list(
		"Short Pants (2 cloth)" = list("shortpants",2),
		"Long Pants (3 cloth)" = list("pants",3),
		"Tartan Kilt (2 cloth)" = list("tartankilt",2),
		"Pleated Skirt (3 cloth)" = list("pleatedskirt",3),
		"Straight Skirt (2 cloth)" = list("straightskirt",2),
		)
	var/choice = input(user, "What kind of pants?","Composite Set",null) as null|anything in available_pants
	if (!choice)
		req_amount = 2
		return FALSE

	var/list/result = available_pants[choice]
	extra_data += result[1]
	req_amount += result[2]

	//then we may pick a top or none
	var/list/available_tops = list(
		"None" = null,
		"Polo (2 cloth)" = list("polo",2),
		"T-Shirt (2 cloth)" = list("tshirt",2),
		)
	choice = input(user, "What kind of top?","Composite Set",null) as null|anything in available_tops

	if (choice && (choice != "None"))
		result = available_tops[choice]
		extra_data += result[1]
		req_amount += result[2]

	//the total time depends on the amount of cloth needed
	time = req_amount * 40

	return TRUE

/datum/stack_recipe/cloth/finish_building(var/mob/usr, var/obj/item/stack/S, var/obj/R)
	R.color = S.color
	return R

/datum/stack_recipe/cloth/composite/finish_building(var/mob/usr, var/obj/item/stack/S, var/R)
	var/obj/item/clothing/under/composite/new_clothing = R
	new_clothing.color = S.color
	new_clothing.permanent_parts =  extra_data.Copy()
	new_clothing.set_dyeable_parts()
	new_clothing.update_icon()
	return R

/* =========================================================================
							WAX RECIPES
========================================================================= */
var/list/datum/stack_recipe/wax_recipes = list (
	new/datum/stack_recipe/wax("candle",                           /obj/item/candle                            ),
	)

/datum/stack_recipe/wax/finish_building(var/mob/usr, var/obj/item/stack/S, var/obj/R)
	R.color = S.color
	if (R.color in colors_all)
		R.name = "[colors_all[R.color]] [R.name]"
	return R

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
	return 1

var/list/datum/stack_recipe/leather_recipes = list (
	new/datum/stack_recipe/leather("Bullwhip",		/obj/item/weapon/gun/hookshot/whip,			10,	time = 100,),
	new/datum/stack_recipe/leather("Cowboy hat",	/obj/item/clothing/head/cowboy,				4,	time = 70,),
	new/datum/stack_recipe/leather("Cowboy boots",	/obj/item/clothing/shoes/jackboots/cowboy,	4, 	time = 80,),
	new/datum/stack_recipe/leather("Rags",			/obj/item/clothing/under/leather_rags,		3,	time = 80,),
	new/datum/stack_recipe/leather("Leather gloves",/obj/item/clothing/gloves/botanic_leather,	2,	time = 90,),
	new/datum/stack_recipe/leather("Leather shoes",	/obj/item/clothing/shoes/leather,			4,	time = 80,),
	new/datum/stack_recipe/leather("Leather satchel",/obj/item/weapon/storage/backpack/satchel,	12,	time = 130,),
	new/datum/stack_recipe/leather("Leather wallet",/obj/item/weapon/storage/wallet,			4,	time = 90,),
	new/datum/stack_recipe/leather("Leather helmet",/obj/item/clothing/head/leather,			3,	time = 90,on_floor = 1),
	new/datum/stack_recipe/leather("Leather armor",/obj/item/clothing/suit/leather,				6,	time = 90,on_floor = 1),
	new/datum/stack_recipe/leather("Leather belt",/obj/item/weapon/storage/belt/leather,		3,	time = 60),
	new/datum/stack_recipe/leather("Leather strip",/obj/item/stack/leather_strip,				1,4,20,time = 2 SECONDS, on_floor = 1),
	new/datum/stack_recipe/leather("Ammunition Pouch",/obj/item/weapon/storage/bag/ammo_pouch,	4,	time = 4 SECONDS,on_floor = 1),
	)

/* ========================================================================
							BRASS RECIPES
======================================================================== */

var/list/datum/stack_recipe/brass_recipes = list (
	new/datum/stack_recipe("brass table parts", /obj/item/weapon/table_parts/clockwork, 4),
	null,
	new/datum/stack_recipe("clockwork airlock", /obj/structure/door_assembly/clockwork, 4, time = 70, one_per_turf = TRUE, on_floor = TRUE, other_reqs = list(/obj/item/stack/sheet/ralloy = 4)),
	new/datum/stack_recipe("clockwork girders", /obj/structure/girder/clockwork, 3, time = 70, one_per_turf = TRUE, on_floor = TRUE, other_reqs = list(/obj/item/stack/sheet/ralloy = 3)),
	new/datum/stack_recipe("brass window door", /obj/structure/windoor_assembly/clockwork, 5, time = 10, one_per_turf = TRUE, on_floor = TRUE, other_reqs = list(/obj/item/stack/sheet/ralloy = 1)),
	new/datum/stack_recipe("brass window", /obj/structure/window/reinforced/clockwork/loose, 2, time = 10, on_floor = TRUE, other_reqs = list(/obj/item/stack/sheet/ralloy = 1)),
	new/datum/stack_recipe("brass full window", /obj/structure/window/full/reinforced/clockwork/loose, 4, time = 20, one_per_turf = TRUE, on_floor = TRUE, other_reqs = list(/obj/item/stack/sheet/ralloy = 1)),
	null,
	new/datum/stack_recipe/dorf("dorf chair", /obj/structure/bed/chair, one_per_turf = TRUE, on_floor = TRUE, inherit_material = TRUE, gen_quality = TRUE),
	new/datum/stack_recipe/dorf("training sword", /obj/item/weapon/melee/training_sword, 4, time = 12,	on_floor = TRUE, inherit_material = TRUE, gen_quality = TRUE),
	)

/* ========================================================================
							REPLICANT ALLOY RECIPES
======================================================================== */

var/list/datum/stack_recipe/ralloy_recipes = list (
	new/datum/stack_recipe("replicant grille", /obj/structure/grille/replicant, 2, time = 10, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new/datum/stack_recipe("clockwork airlock", /obj/structure/door_assembly/clockwork, 4, time = 70, one_per_turf = TRUE, on_floor = TRUE, other_reqs = list(/obj/item/stack/sheet/brass = 4)),
	new/datum/stack_recipe("clockwork girders", /obj/structure/girder/clockwork, 3, time = 70, one_per_turf = TRUE, on_floor = TRUE, other_reqs = list(/obj/item/stack/sheet/brass = 3)),
	null,
	new/datum/stack_recipe/dorf("dorf chair", /obj/structure/bed/chair, one_per_turf = TRUE, on_floor = TRUE, inherit_material = TRUE, gen_quality = TRUE),
	new/datum/stack_recipe/dorf("training sword", /obj/item/weapon/melee/training_sword, 4, time = 12,	on_floor = TRUE, inherit_material = TRUE, gen_quality = TRUE),
	)
