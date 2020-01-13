/datum/component/ai/targetting_handler/RecieveAndReturnSignal(var/message_type, var/list/args)
	if(message_type == COMSIG_GETDEFZONE)
		var/mob/living/target = args["target"]
		var/damagetype = args["damage_type"]
		ASSERT(istype(target))
		return EvaluateTarget(target, damagetype)

/datum/component/ai/targetting_handler/proc/EvaluateTarget(var/mob/living/target, var/damagetype) //Center mass.
	return LIMB_CHEST

/datum/component/ai/targetting_handler/dumb/EvaluateTarget(var/mob/living/target, var/damagetype) //Random
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
		TARGET_MOUTH)
	return pick(potential_targets)

/datum/component/ai/targetting_handler/smart/EvaluateTarget(var/mob/living/target, var/damagetype) //Goes for the part with the least armor
	var/list/static/potential_target = list(
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
		TARGET_MOUTH)
	var/weakpoint
	var/weakpoint_armor = 100
	for(var/i in potential_target)
		var/armor = target.getarmor(i, damagetype)
		if(!weakpoint || weakpoint_armor > armor)
			weakpoint = i

	return weakpoint
