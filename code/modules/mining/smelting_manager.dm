/**
 * Handles all the common smelting stuff.
 */
/datum/smelting_manager
	var/list/recipes=list()
	var/list/selected[0]
	var/datum/materials/materials

/datum/smelting_manager/New(var/datum/materials/matstorage)
	materials=matstorage
	for(var/recipetype in typesof(/datum/smelting_recipe) - /datum/smelting_recipe)
		var/datum/smelting_recipe/recipe = new recipetype
		// Sanity
		for(var/ingredient in recipe.ingredients)
			if(!(ingredient in materials.storage))
				warning("Unknown ingredient [ingredient] in recipe [recipe.name]!")
		recipes += recipe

/**
 * Smelt materials into the desired recipes.
 * @param T Where to spawn the results?
 * @param multiplier How many batches of the recipe do we attempt? (Will fail if the required materials are not present)
 * @return 1 = success
 *         0 = no recipe found
 *        -1 = Recipe found, but not enough ore.
 */
/datum/smelting_manager/proc/smelt(var/turf/T, var/list/selected, var/multiplier=1, var/no_slag=0)

	// For every recipe
	for(var/datum/smelting_recipe/recipe in recipes)
		// Check if it's selected and we have the ingredients
		var/signal=recipe.checkIngredients(materials, selected, multiplier)

		// If we have a matching recipe but we're out of ore,
		// Shut off but DO NOT spawn slag.
		if(signal==-1)
			return -1

		// Otherwise, if we've matched
		else if(signal==1)
			recipe.smelt(T,materials,multiplier)

			return 1

	// If we haven't found a matching recipe (and slag is on)
	if(!no_slag)
		// Spawn slag
		var/obj/item/weapon/ore/slag/slag = new /obj/item/weapon/ore/slag(T)

		// Take one of every ore selected and give it to the slag.
		for(var/ore_id in materials.storage)
			if(materials.getAmount(ore_id)>0 && ore_id in selected)
				materials.removeAmount(ore_id, 1)
				slag.mats.addAmount(ore_id, 1)

/**
 * See what recipes are possible.
 * @return /list List of recipe name => recipe_id.
 */
/datum/smelting_manager/proc/getAvailableRecipes()
	var/list/recipeList=list()

	// For every recipe
	for(var/datum/smelting_recipe/recipe in recipes)
		// Check if it's selected and we have the ingredients
		if(recipe.getMaxBatches(materials) > 0)
			recipeList[recipe.name] = recipe

	return recipeList

