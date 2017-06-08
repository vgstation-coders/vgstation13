/datum/component/ai/melee/attack_human
//	var/datum/component/ai/human_brain/B

/datum/component/ai/melee/attack_human/OnAttackingTarget(var/atom/target)
	if(..(target))
		var/mob/living/carbon/human/H = container.holder
		H.a_intent = I_HURT
		SendSignal(COMSIG_CLICKON, list("target" = target))
		return 1 // Accepted
	return 0 // Unaccepted