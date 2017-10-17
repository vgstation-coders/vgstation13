var/list/potential_theft_objectives=list(
	"traitor" = typesof(/datum/theft_objective/traitor) - /datum/theft_objective/traitor,
	"special" = typesof(/datum/theft_objective/special) - /datum/theft_objective/special,
	"heist_easy"   = typesof(/datum/theft_objective/number/heist_easy) - /datum/theft_objective/number/heist_easy,
	"heist_hard"   = typesof(/datum/theft_objective/number/heist_hard) - /datum/theft_objective/number/heist_hard,
)

/datum/objective/target/steal
	var/target_category = "traitor"
	var/datum/theft_objective/steal_target

/datum/objective/target/steal/find_target()
	var/list/possibleObjectives = potential_theft_objectives[target_category]
	var/loopSanity = possibleObjectives.len

	while(isnull(steal_target) && loopSanity > 0)
		loopSanity--

		var/pickedObjective = pick(possibleObjectives)
		var/datum/theft_objective/objective = new pickedObjective

		if(objective.typepath in map.unavailable_items)
			continue

		if(owner && owner.assigned_role in objective.protected_jobs)
			continue

		steal_target = objective
		explanation_text = format_explanation()
		return

/datum/objective/target/steal/proc/format_explanation()
	return "Steal [steal_target.name]."

/datum/objective/target/steal/proc/select_target()
	var/list/possible_items_all = potential_theft_objectives[target_category]+"custom"
	var/new_target = input("Select target:", "Objective target", null) as null|anything in possible_items_all
	if (!new_target)
		return
	if (new_target == "custom")
		var/datum/theft_objective/O=new
		O.typepath = input("Select type:","Type") as null|anything in typesof(/obj/item)
		if (!O.typepath)
			return
		var/tmp_obj = new O.typepath
		var/custom_name = tmp_obj:name
		qdel(tmp_obj)
		O.name = copytext(sanitize(input("Enter target name:", "Objective target", custom_name) as text|null),1,MAX_NAME_LEN)
		if (!O.name)
			return
		steal_target = O
		explanation_text = format_explanation()
	else
		steal_target = new new_target
		explanation_text = format_explanation()
	return steal_target

/datum/objective/target/steal/IsFulfilled()
	..()
	if(!steal_target)
		return TRUE // Free Objective
	return steal_target.check_completion(owner)
