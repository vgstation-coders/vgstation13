/* * * * * * * * * * * * * * * * * * * * * * * * * *
 * /datum/recipe by rastaf0            13 apr 2011 *
 * * * * * * * * * * * * * * * * * * * * * * * * * *
 * This is powerful and flexible recipe system.
 * It exists not only for food.
 * supports both reagents and objects as prerequisites.
 * In order to use this system you have to define a deriative from /datum/recipe
 * * reagents are reagents. Acid, milc, booze, etc.
 * * items are objects. Fruits, tools, circuit boards.
 * * result is type to create as new object
 * * time is optional parameter, you shall use in in your machine,
     default /datum/recipe/ procs does not rely on this parameter.
 *
 *  Functions you need:
 *  /datum/recipe/proc/make(var/obj/container as obj)
 *    Creates result inside container,
 *    deletes prerequisite reagents,
 *    transfers reagents from prerequisite objects,
 *    deletes all prerequisite objects (even not needed for recipe at the moment).
 *
 *  /proc/select_recipe(list/datum/recipe/avaiable_recipes, obj/obj as obj, exact = 1)
 *    Wonderful function that select suitable recipe for you.
 *    obj is a machine (or magik hat) with prerequisites,
 *    exact = 0 forces algorithm to ignore superfluous stuff.
 *
 *  Functions you do not need to call directly but could:
 *  /datum/recipe/proc/check_reagents(var/datum/reagents/avail_reagents)
 *    //1 = precisely,  0 = insufficiently, -1 = superfluous
 *
 *  /datum/recipe/proc/check_items(var/obj/container as obj)
 *    //1 = precisely, 0=insufficiently, -1 = superfluous
 *
 * */
/datum/recipe

	var/list/reagents //List of reagents needed and their amount, reagents = list(BERRYJUICE = 5)
	var/list/reagents_forbidden //List of reagents that will not be transfered to the cooked item if found. reagents_forbidden = list(TOXIN, WATER)
	var/list/items //List of items needed, items = list(/obj/item/tool/crowbar, /obj/item/weapon/welder)
	var/result //Result of a complete recipe. result = /obj/item/weapon/reagent_containers/food/snacks/donut/normal
	var/silver_slime_result //Result with a silver slime on the item
	var/time = 10 SECONDS //Length of time it takes to complete the recipe. In 10ths of a second
	var/priority = 0 //To check which recipe takes priority if they share ingredients
	var/cookable_with = COOKABLE_WITH_HEAT //How this recipe can be cooked, eg. COOKABLE_WITH_MICROWAVE (see setup.dm).

/*
	check_reagents function
	Looks for reagents in the reagent container passed to it, and if this matches what we require.

	args:
		/datum/reagents: avail_reagents: The reagent container we are checking

	return:
		0/FALSE: Unable to find all reagents we require
		1/TRUE: Able to find enough reagents to satisfy requirements
		-1: Found what we require, but there is more reagents than just what we need
*/

/datum/recipe/proc/check_reagents(var/datum/reagents/avail_reagents)
	. = 1
	for(var/r_r in reagents)
		if(islist(r_r)) //The reagents required is a list, so could be satisfied by one or another reagent (SACIDS can be satisfied by sulphuric acid, or formic acid)
			var/list/L = r_r
			var/found = FALSE
			for(var/I in L)
				var/reagent_amount = avail_reagents.get_reagent_amount(I)
				if(abs(reagent_amount - reagents[r_r])<0.1)
					found = TRUE
					if(reagent_amount > reagents[r_r])
						. = -1
					break
			if(!found)
				return 0
		else
			var/reagent_amount = avail_reagents.get_reagent_amount(r_r)
			if(abs(reagent_amount - reagents[r_r])<0.1)
				if(reagent_amount > reagents[r_r])
					. = -1
			else
				return 0

	if((reagents ? reagents.len : 0) < avail_reagents.reagent_list.len)
		return -1
	return .

/*
	check_items function
	Checks if the container passed, contains the objects required to satisfy the recipes requirements.
	args:
		obj: container: What container we will be checking.

	return:
		1/TRUE: Able to find enough objects to satisfy requirements
		0/FALSE: Unable to find enough objects to satisfy requirements
		-1: Found enough objects to satisfy requirements, and more.

*/
/datum/recipe/proc/check_items(var/obj/container as obj)
	if(!items) //If there's no items in our recipe
		if(locate(/obj/) in container) //but we find something, at the least.
			return -1
		else
			return 1 //Technically, we've satisfied the requirements, as the requirements are null
	. = 1
	var/list/checklist = items.Copy()
	for(var/obj/O in container) //Let's loop through all the objects in our recipe machine
		var/found = 0 //If what we found is part of the recipe
		for(var/type in checklist)
			if(istype(O, type)) //Is that what we are looking for
				checklist -= type //Good, strike it out of our checklist
				found = TRUE
				break //Break that loop, continue downwards
		if(!found) //We found something that's not part of our recipe
			. = -1
	if(checklist.len) //Are there still items on our recipe checklist ?
		return 0 //Something is missing, abort
	return .

/*
	make_food function
	Final function in the chain of successes. This makes the resulting object, and handles transferring reagents from its assumed component parts to the product.
	args:
		obj:container: What the object is being made within (Microwave, oven, etc.)

	return:
		obj: Resulting object.
*/
/datum/recipe/proc/make_food(var/obj/container, var/mob/user)
	var/obj/result_obj
	if((container.has_slimes & SLIME_SILVER) && silver_slime_result)
		result_obj = new silver_slime_result(container)
	else
		result_obj = new result(container)
	for(var/obj/O in (container.contents - result_obj))
		if(O.arcanetampered && istype(container,/obj/machinery/microwave))
			var/obj/machinery/microwave/M = container
			M.fail(O.arcanetampered)
			return
		if(O.reagents)
			//Should we have forbidden reagents, purge them first.
			for(var/r_r in reagents_forbidden)
				if(islist(r_r))
					var/list/L = r_r
					for(var/I in L)
						O.reagents.del_reagent(I)
				O.reagents.del_reagent(r_r)
			//Transfer any reagents found in the object, to the resulting object
			O.reagents.trans_to(result_obj, O.reagents.total_volume)
		//Transfer any luckiness from the ingredients, to the resulting item
		if(isitem(result_obj) && isitem(O))
			var/obj/item/I = O
			var/obj/item/result_item = result_obj
			if(I.luckiness)
				result_item.luckiness += I.luckiness
		qdel(O)
	container.reagents.clear_reagents() //Clear all the reagents we haven't transfered, for instance if we need to cook in water
	score.meals++
	return result_obj


/*
	Select_recipe function
	Loop through all recipes that we are passed, return the ones we can work with
	Args:
		available recipes: Potential recipes we will check against
		recipe_source: The object to check for the reagents and items within (A microwave, oven, etc.)
		exact: Should what we find in the obj be exactly what we're looking for (TRUE) or not (FALSE)

	return:
		Recipe that works with what we have.
*/
/proc/select_recipe(var/list/datum/recipe/available_recipes, var/obj/recipe_source, var/exact = TRUE)
	if(!exact)
		exact = -1 //Change it to -1 for simplicity, too much or not enough is the same problem now
	var/list/possible_recipes = list()

	for(var/datum/recipe/recipe in available_recipes)
		if(recipe.check_reagents(recipe_source.reagents) == exact && recipe.check_items(recipe_source) == exact)
			possible_recipes += recipe
	//If there is no possible recipes, return a fail
	if(possible_recipes.len == 0)
		return null
	//If only one possible recipe, return only it
	else if(possible_recipes.len == 1)
		return possible_recipes[1]
	//Else, we return the best fitting recipe.
	else
		var/reagents_count = 0
		var/items_count = 0
		. = possible_recipes[1] //We'll estimate the first recipe we found is the correct one until we start looping, to avoid returning nothing

		//Loop through all those recipes we found to be matching, return the last one that we find to be usable.
		for(var/datum/recipe/recipe in possible_recipes)
			var/items_number = (recipe.items) ? (recipe.items.len) : 0
			var/reagents_number = (recipe.reagents) ? (recipe.reagents.len) : 0

			 //If there's more items or as much items and more reagents than the previous recipe
			if(items_number > items_count || (items_number == items_count && reagents_number > reagents_count))
				reagents_count = reagents_number
				items_count = items_number
				. = recipe
		return .
