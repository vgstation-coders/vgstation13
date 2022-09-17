// This just calls animal_attack() on stuff.
/datum/component/ai/melee/attack_animal/cmd_attack(atom/target)
	if(can_attack(target))
		var/mob/living/L = target
		L.attack_animal(parent)
		return 1 // Accepted
	return 0 // Unaccepted
