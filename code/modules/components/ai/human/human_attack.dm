/datum/component/ai/melee/attack_human
//	var/datum/component/ai/human_brain/B

/datum/component/ai/melee/attack_human/OnAttackingTarget(var/atom/target)
	if(..(target))
		var/mob/living/carbon/human/H = container.holder
		H.a_intent = I_HURT
		var/damage_type = container.ReturnFromSignalFirst(COMSIG_GETDAMTYPE, list("user" = H))
		var/def_zone = container.ReturnFromSignalFirst(COMSIG_GETDEFZONE, list("target" = target, "damage_type" = damage_type))
		SendSignal(COMSIG_CLICKON, list("target" = target, "def_zone" = def_zone))
		return 1 // Accepted
	return 0 // Unaccepted