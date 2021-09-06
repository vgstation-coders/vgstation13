/*
var/datum/controller/target_finder/TF = GetComponent(/datum/controller/target_finder)
var/list/target = TF.GetTargets()
*/
/datum/component/ai/target_finder
	var/range=0
	var/list/exclude_types=list(
			/obj/effect,
			/atom/movable/light,
			/turf
	)

/datum/component/ai/target_finder/proc/GetTargets()
	return list()
