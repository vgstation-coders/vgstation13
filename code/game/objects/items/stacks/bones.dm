var/global/list/datum/stack_recipe/bone_recipes = list ( \
	new/datum/stack_recipe_list("chairs and beds",list( \
		new/datum/stack_recipe("bone chair",	/obj/item/weapon/stool,		5,	one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("bone throne",	/obj/structure/bed/chair,	20,	one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("bone bed",		/obj/structure/bed,			10,	one_per_turf = 1, on_floor = 1), \
		)),\
	new/datum/stack_recipe("bone table parts",		/obj/item/weapon/table_parts,	10), \
	new/datum/stack_recipe("bone rack parts",		/obj/item/weapon/rack_parts,	5), \
	new/datum/stack_recipe("bone closet",			/obj/structure/closet,			15, time = 15, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("bone meat spike",		/obj/structure/kitchenspike,	30, time = 25, one_per_turf = 1, on_floor = 1), \
	null,\
	new/datum/stack_recipe("bone door", /obj/machinery/door/mineral/iron, 20, one_per_turf = 1, on_floor = 1),\
	)

/obj/item/stack/animal/bones
	name = "bones"
	singular_name = "bone"
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "bone"
	amount = 1
	max_amount = 50
	w_class = 2
	force = 5
	throw_speed = 2
	throw_range = 4

/obj/item/stack/animal/bones/New(var/loc, var/amount=null)
	recipes = bone_recipes
	return ..()
