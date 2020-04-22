/datum/component/ai/melee/attack_human
//	var/datum/component/ai/human_brain/B

/datum/component/ai/melee/attack_human/OnAttackingTarget(var/atom/target)
	if(..(target))
		var/mob/living/carbon/human/H = owner
		H.a_intent = I_HURT
		var/damage_type = owner.ReturnFromSignalFirst(COMSIG_GETDAMTYPE, list("user" = H))
		var/def_zone = owner.ReturnFromSignalFirst(COMSIG_GETDEFZONE, list("target" = target, "damage_type" = damage_type))
		SendSignal(COMSIG_CLICKON, list("target" = target, "def_zone" = def_zone))
		return 1 // Accepted
	return 0 // Unaccepted