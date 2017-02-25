// This just calls animal_attack() on stuff.
/datum/component/ai/melee/attack_animal/OnAttackingTarget(var/atom/target)
	if(..(target))
		var/mob/living/L = target
		L.attack_animal(container.holder)
		return 1 // Accepted
	return 0 // Unaccepted
