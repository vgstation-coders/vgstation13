/*
	Recipes randomly generated at roundstart

	On New, the chemical reaction generates, picking reagent defines from the lists of possible reagents and
	possible catalysts given

	This can be over-ridden by manually inserting required_reagents or required_catalysts as you would
	a normal recipe
*/

/datum/random_chemical_recipe
	var/datum/chemical_reaction/random/recipe //What this recipe will be making
	var/list/possible_reagents = new/list() //List of possible reagents the recipe may require. THIS MUST HAVE SOMETHING
	var/min_reagents_count = 1 //Minimum list of reagents required
	var/max_reagents_count = 1//Maximum list of reagents, up to the maximum in possible_reagents
	var/max_reagents_amount = 1//Maximum amount of a reagent the recipe may require
	var/min_reagents_amount = 1
	var/list/possible_catalysts = new/list() //List of possible catalysts the recipe may require
	var/max_catalysts_count = 1//Maxmimum list of catalysts, up to the maximum in possible_catalysts
	var/min_catalysts_count = 1
	var/max_catalysts_amount = 1//Maximum amount of a catalyst the recipe may require
	var/min_catalysts_amount = 1
	var/possible_min_result = 1
	var/possible_max_result = 1//How much the recipe may yield

/datum/random_chemical_recipe/proc/generate_recipe()
	if(!recipe)
		testing("RANDOM RECIPES: No recipe on [src], aborting.")
		return 0

	var/datum/chemical_reaction/D = new recipe()
	var/list/reaction_ids = list()

	//Tard management
	max_reagents_count = min(max_reagents_count, possible_reagents.len)
	max_catalysts_count = min(max_catalysts_count, possible_catalysts.len)
	//Reagent generation
	if(!D.required_reagents.len)
		var/reagent_count = rand(min_reagents_count,max_reagents_count)
		for(var/i = 0;i<reagent_count;i++)
			var/list/total_reagents = possible_reagents-D.required_reagents
			if(total_reagents.len > 0)
				var/chosen_reagent = pick(total_reagents)
				var/reagent_amount = rand(min_reagents_amount,max_reagents_amount)
				testing("RANDOM RECIPES: Reagent [i] is [reagent_amount] of [chosen_reagent]")
				D.required_reagents.Add(chosen_reagent)
				D.required_reagents[chosen_reagent] = reagent_amount

	if(!D.required_catalysts.len && possible_catalysts)
		var/catalysts_count = rand(min_catalysts_count,max_catalysts_count)
		for(var/i = 0;i<catalysts_count;i++)
			var/list/total_catalysts = possible_catalysts - D.required_catalysts
			if(total_catalysts.len > 0)
				var/chosen_catalyst = pick(total_catalysts)
				var/catalyst_amount = rand(min_catalysts_amount, max_catalysts_amount)
				testing("RANDOM RECIPES: Catalyst [i] is [catalyst_amount] of [chosen_catalyst]")
				D.required_catalysts.Add(chosen_catalyst)
				D.required_catalysts[chosen_catalyst] = catalyst_amount

	D.result_amount = rand(possible_min_result, possible_max_result)

	if(D.required_reagents && D.required_reagents.len)
		for(var/reaction in D.required_reagents)
			reaction_ids += reaction

	// Create filters based on each reagent id in the required reagents list
	for(var/id in reaction_ids)
		if(!chemical_reactions_list[id])
			chemical_reactions_list[id] = list()
		chemical_reactions_list[id] += D
		break // Don't bother adding ourselves to other reagent ids, it is redundant.

	return 1


/datum/random_chemical_recipe/parotsetine
	recipe = /datum/chemical_reaction/random/parotsetine
	possible_reagents = list(WATER, SODIUMCHLORIDE, BLACKPEPPER, LITHIUM, SINGULO, CLONEXADONE, CRYOXADONE)
	min_reagents_count = 2
	max_reagents_count = 5
	max_reagents_amount = 15
	possible_catalysts = list(SODIUMCHLORIDE, BLACKPEPPER, RADIUM, PLASMA)
	min_catalysts_count = 0
	max_catalysts_count = 2
	possible_min_result = 10
	possible_max_result = 20

/datum/chemical_reaction/random/parotsetine
	name = "parotsetine"
	id = "instant_parrot"
	result = null

/datum/chemical_reaction/random/parotsetine/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/turf/T = get_turf(holder.my_atom)

	var/crackers = (round(created_volume, 10))/10

	for(var/i = 0;i<crackers;i++)
		new/mob/living/simple_animal/parrot(T)

	holder.my_atom.visible_message("[pick("<span class = 'notice'>You suddenly feel like having some crackers",\
									"<span class = 'danger'>You feel like checking up on the singularity, just in case.",\
									"<span class = 'notice'>You feel like wiring some solar panels up.")]</span>")

	holder.remove_reagent(created_volume)