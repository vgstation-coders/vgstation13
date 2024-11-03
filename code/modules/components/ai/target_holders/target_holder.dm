/datum/component/ai/target_holder

/datum/component/ai/target_holder/initialize()
	parent.register_event(/event/comp_ai_cmd_add_target, src, nameof(src::cmd_add_target()))
	parent.register_event(/event/comp_ai_cmd_remove_target, src, nameof(src::cmd_remove_target()))
	parent.register_event(/event/comp_ai_cmd_get_best_target, src, nameof(src::cmd_get_best_target()))
	return TRUE

/datum/component/ai/target_holder/proc/cmd_add_target(var/atom/A)
	return

/datum/component/ai/target_holder/proc/cmd_remove_target(var/atom/A)
	return


/**
 * Get the best target
 *
 * @return null if not target found, /atom if a target is found.
 */
/datum/component/ai/target_holder/proc/cmd_get_best_target()
	return
