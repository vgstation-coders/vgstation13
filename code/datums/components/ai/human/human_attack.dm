/datum/component/ai/melee/attack_human
//	var/datum/component/ai/human_brain/B

/datum/component/ai/melee/attack_human/OnAttackingTarget(var/atom/target)
	if(..())
		var/mob/living/carbon/human/H = parent
		H.a_intent = I_HURT
		var/damage_type = SEND_SIGNAL(parent, COMSIG_GETDAMTYPE, H)
		var/def_zone = SEND_SIGNAL(parent, COMSIG_GETDEFZONE, target, damage_type)
		SEND_SIGNAL(parent, COMSIG_CLICKON, target, def_zone)
		return 1 // Accepted
	return 0 // Unaccepted
