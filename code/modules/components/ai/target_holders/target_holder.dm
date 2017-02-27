/datum/component/ai/target_holder

/datum/component/ai/target_holder/proc/AddTarget(var/atom/A)
	return

/datum/component/ai/target_holder/proc/RemoveTarget(var/atom/A)
	return


/**
 * Get the best target
 *
 * @param objRef Direct reference to the holding object containing the target validation callback
 * @param procName Name of the callback proc
 * @param from_finder Use /datum/component/ai/target_finder.GetTargets()
 * @return null if not target found, /atom if a target is found.
 */
/datum/component/ai/target_holder/proc/GetBestTarget(var/objRef, var/procName, var/from_finder=1)
	return
