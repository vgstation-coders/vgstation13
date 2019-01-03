/** Fuzzy rule datums
	Pass it an object, and it will evaluate it
	Will return the membership value (a value between 1 and 0), this is 'how true' this object is to this ruling
**/

/datum/fuzzy_ruling
	var/weighting = 1 //Value between 1 and 0, how much the evaluation value will be timesd by
	var/list/args //Generic list of arguments

/datum/fuzzy_ruling/proc/evaluate(var/datum/D)
	return 1

/datum/fuzzy_ruling/is_mob/evaluate(var/datum/D)
	if(ismob(D))
		return 1
	return 0

/datum/fuzzy_ruling/is_obj/evaluate(var/datum/D)
	if(isobj(D))
		return 1
	return 0

/datum/fuzzy_ruling/distance
	var/atom/source

/datum/fuzzy_ruling/distance/proc/set_source(var/atom/A)
	source = A

/datum/fuzzy_ruling/distance/evaluate(var/datum/D)
	return 1/max(get_dist(source,D), 1)

/**
	Evaluate_list
		Orders the list in highest priority first, according to the ruleset provided to it
	@params:
		L: List: The list of objects/datums/atoms to evalute.
		ruleS: List: The list of rules to evaluate these objects by

	@return:
		List: comparison, ordered with the most relevant objects (according to the rules given) to the least relevant objects
**/
/proc/evaluate_list(var/list/L, var/list/rules)
	if(!L.len || L.len < 2 || !rules.len) //List is empty, or only has one element so can't compare, or no rules to compare with
		return L
	var/list/comparison = L.Copy()
	//First, we associate a value with each object in the comparison list
	for(var/datum/D in comparison)
		var/relevance
		for(var/datum/fuzzy_ruling/FR in rules)
			relevance += FR.evaluate(D)*FR.weighting
		comparison[D] = relevance
	//Then, we use sortTim with descending numeric arg, so we get them from highest to lowest
	sortTim(comparison, /proc/cmp_numeric_dsc,TRUE)

	for(var/datum/D in L)
		comparison[D] = L[D] //So we don't lose assoc values, should there be any

	return comparison