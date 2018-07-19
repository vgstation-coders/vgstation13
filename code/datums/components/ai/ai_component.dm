/datum/component/ai
	var/datum/component/controller/controller

	var/state=0 // AI_STATE_* of the AI.

/datum/component/ai/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	controller = parent.GetComponent(/datum/component/controller)
	RegisterSignal(parent, COMSIG_STATE, .proc/set_state)

/datum/component/ai/proc/set_state(var/state)
	src.state = state
