/datum/component/ai/melee

/datum/component/ai/melee/Initialize()
	..()
	RegisterSignal(parent, COMSIG_ATTACKING, .proc/OnAttackingTarget)

/datum/component/ai/melee/proc/OnAttackingTarget(var/atom/target)
	if(!isliving(target))
		return 0
	var/mob/living/L = target
	return L.Adjacent(parent)
