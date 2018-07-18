/datum/component/ai/get_def_zone/Initialize()
	..()
	RegisterSignal(parent, COMSIG_GETDAMTYPE, .proc/get_damage_type)

/datum/component/ai/get_def_zone/proc/get_damage_type()
	return "melee"
