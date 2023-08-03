/datum/component/ai/melee

/datum/component/ai/melee/initialize()
	parent.register_event(/event/comp_ai_cmd_attack, src, nameof(src::cmd_attack()))
	return TRUE

/datum/component/ai/melee/Destroy()
	parent.unregister_event(/event/comp_ai_cmd_attack, src, nameof(src::cmd_attack()))
	..()

/datum/component/ai/melee/proc/can_attack(atom/target)
	return target.Adjacent(parent)

/datum/component/ai/melee/proc/cmd_attack(atom/target)
	return can_attack(target)
