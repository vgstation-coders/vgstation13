/datum/component/ai/targetting_handler
	var/list/static/potential_targets = list(
		LIMB_HEAD,
		LIMB_CHEST,
		LIMB_GROIN,
		LIMB_LEFT_ARM,
		LIMB_RIGHT_ARM,
		LIMB_LEFT_HAND,
		LIMB_RIGHT_HAND,
		LIMB_LEFT_LEG,
		LIMB_RIGHT_LEG,
		LIMB_LEFT_FOOT,
		LIMB_RIGHT_FOOT,
		TARGET_MOUTH,
	)

/datum/component/ai/targetting_handler/initialize()
	parent.register_event(/event/comp_ai_cmd_evaluate_target, src, nameof(src::evaluate_target()))
	return TRUE

/datum/component/ai/targetting_handler/Destroy()
	parent.unregister_event(/event/comp_ai_cmd_evaluate_target, src, nameof(src::evaluate_target()))
	..()

//Center mass.
/datum/component/ai/targetting_handler/proc/evaluate_target(mob/living/target, damage_type)
	return LIMB_CHEST

//Random
/datum/component/ai/targetting_handler/dumb/evaluate_target(mob/living/target, damage_type)
	return pick(potential_targets)

//Goes for the part with the least armor
/datum/component/ai/targetting_handler/smart/evaluate_target(mob/living/target, damage_type)
	var/weakpoint
	var/weakpoint_armor = 100
	for(var/i in potential_targets)
		var/armor = target.getarmor(i, damage_type)
		if(!weakpoint || weakpoint_armor > armor)
			weakpoint = i

	return weakpoint
