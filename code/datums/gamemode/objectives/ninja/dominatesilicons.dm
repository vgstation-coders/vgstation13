/datum/objective/target/killsilicons
	name = "\[Ninja\] Dominate Silicons"
	explanation_text = "Assert our dominance of silicon life. Steal 3 active posibrains/MMIs, or destroy every cyborg on the station."
	var/amount = 3

/datum/objective/target/killsilicons/format_explanation()
	return "Assert our dominance of silicon life. Steal [amount] active posibrains/MMIs, or destroy every cyborg on the station."

/datum/objective/target/killsilicons/find_target()
	amount = min(rand(2,4),cyborg_list.len)
	explanation_text = format_explanation()
	return 1

/datum/objective/target/killsilicons/select_target()
	auto_target = FALSE
	var/new_target = input("How many tin can brains?:", "Objective target", null) as num
	if(!new_target)
		return FALSE
	amount = new_target
	explanation_text = format_explanation()
	return TRUE

/datum/objective/target/killsilicons/IsFulfilled()
	if (..())
		return TRUE
	var/any_borgs_alive = FALSE
	for(var/mob/living/silicon/robot/R in cyborg_list)
		var/turf/T = get_turf(R)
		if(T.z == STATION_Z && !(R.stat==DEAD))
			any_borgs_alive = TRUE
			break
	if(!any_borgs_alive)
		return TRUE
	var/collected = 0
	for(var/obj/item/device/mmi/M in recursive_type_check(owner, /obj/item/device/mmi))
		if(istype(M,/obj/item/device/mmi/posibrain))
			if(M.brainmob.mind)
				collected++ //Only posibrains that had a mind
		else
			if(M.brainmob && !M.brainmob.stat)
				collected++ //Has a living brain, good enough for us!
	return collected >= amount

