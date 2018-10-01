/**
 * vox heist objectives
 */

#define MAX_VOX_KILLS 5 // number of kills during the round before the inviolate is broken
						// would be nice to use vox-specific kills but is currently not feasible

/*
 * heist
 */

/datum/objective/heist/proc/choose_target()
	return

/*
 * kidnap
 */

/datum/objective/heist/kidnap/choose_target()
	var/list/roles = list("Chief Engineer", "Research Director", "Roboticist", "Chemist", "Medical Doctor", "Janitor", "Bartender")

	for(var/role in shuffle(roles))
		find_target_by_role(role)

		if(target)
			break

	if(isnull(target)) // if we cannot find some target at certain roles
		find_target()

	if(target)
		explanation_text = "The Shoal has a need for [target.current.real_name], the [target.assigned_role]. Take them alive."
	else
		explanation_text = "Free Objective"

	return target

/datum/objective/heist/kidnap/check_completion()
	if(target)
		if(isnull(target.current)/* || target.current.stat == DEAD*/) // Removed dead check, we can clone them after we get them back anyway.
			return FALSE // they're destroyed. fail.

		var/end_area = get_area(locate(/area/shuttle/vox/station))

		if(get_area(target.current) != end_area)
			return FALSE

		//if(!target.current.restrained())
			//return FALSE // they're loose. close but no cigar.

		return TRUE // they're restrained on the shuttle. success.

/*
 * inviolate
 */

/datum/objective/heist/inviolate_crew
	explanation_text = "Do not leave any Vox behind, alive or dead."

/datum/objective/heist/inviolate_crew/check_completion()
	var/datum/game_mode/heist/H = ticker.mode
	return H.is_raider_crew_safe()

/datum/objective/heist/inviolate_death
	explanation_text = "Follow the Inviolate. Minimise death and loss of resources."

/datum/objective/heist/inviolate_death/check_completion()
	if(vox_kills > MAX_VOX_KILLS)
		return FALSE

	return TRUE

#undef MAX_VOX_KILLS

/*
 * theft
 */

/*
 * heist
 */

/datum/objective/steal/heist_easy
	target_category = "heist_easy"

/datum/objective/steal/heist_hard
	target_category = "heist_hard"

/datum/objective/steal/heist_easy/format_explanation()
	return "We are lacking in some trivial devices. Steal [steal_target.name]."

/datum/objective/steal/heist_hard/format_explanation()
	return "We are lacking in expensive hardware or bioware. Steal [steal_target.name]."

/*
 * salvage


/datum/objective/steal/salvage
	target_category = "salvage"

/datum/objective/steal/salvage/format_explanation()
	return "Ransack the station and escape with [steal_target.name]."

/datum/theft_objective/number/salvage
	areas = list(/area/shuttle/vox/station)

/datum/theft_objective/number/salvage/check_completion()
	var/found_amount = 0
	var/list/search = list()
	for(var/A in areas)
		var/area/B = locate(A)
		search += recursive_type_check(B,typepath)
	if(istype(typepath,/obj/item/stack))
		for(var/obj/item/stack/A in search)
			found_amount += A.amount
	else
		found_amount = search.len
	return (found_amount >= required_amount)

/datum/theft_objective/number/salvage/metal
	name = "metal"
	typepath = /obj/item/stack/sheet/metal
	min = 300
	max = 300

/datum/theft_objective/number/salvage/glass
	name = "glass"
	typepath = /obj/item/stack/sheet/glass/glass
	min = 200
	max = 200

/datum/theft_objective/number/salvage/plasteel
	name = "plasteel"
	typepath = /obj/item/stack/sheet/plasteel
	min = 100
	max = 100

/datum/theft_objective/number/salvage/plasma
	name = "plasma"
	typepath = /obj/item/stack/sheet/mineral/plasma
	min = 100
	max = 100

/datum/theft_objective/number/salvage/silver
	name = "silver"
	typepath = /obj/item/stack/sheet/mineral/silver
	min = 50
	max = 50

/datum/theft_objective/number/salvage/gold
	name = "gold"
	typepath = /obj/item/stack/sheet/mineral/gold
	min = 20
	max = 20

/datum/theft_objective/number/salvage/uranium
	name = "uranium"
	typepath = /obj/item/stack/sheet/mineral/uranium
	min = 20
	max = 20

/datum/theft_objective/number/salvage/diamond
	name = "diamond"
	typepath = /obj/item/stack/sheet/mineral/diamond
	min = 20
	max = 20

	*/
