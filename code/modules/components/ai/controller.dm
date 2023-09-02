/datum/component/controller
	var/_busy = FALSE
	var/atom/_target = null

	var/_state = HOSTILE_STANCE_IDLE

/datum/component/controller/initialize()
	parent.register_event(/event/comp_ai_cmd_set_busy, src, nameof(src::cmd_set_busy()))
	parent.register_event(/event/comp_ai_cmd_get_busy, src, nameof(src::cmd_get_busy()))

	parent.register_event(/event/comp_ai_cmd_set_target, src, nameof(src::cmd_set_target()))
	parent.register_event(/event/comp_ai_cmd_get_target, src, nameof(src::cmd_get_target()))

	parent.register_event(/event/comp_ai_cmd_set_state, src, nameof(src::cmd_set_state()))
	parent.register_event(/event/comp_ai_cmd_get_state, src, nameof(src::cmd_get_state()))

	return TRUE

/datum/component/controller/Destroy()
	parent.unregister_event(/event/comp_ai_cmd_set_busy, src, nameof(src::cmd_set_busy()))
	parent.unregister_event(/event/comp_ai_cmd_get_busy, src, nameof(src::cmd_get_busy()))

	parent.unregister_event(/event/comp_ai_cmd_set_target, src, nameof(src::cmd_set_target()))
	parent.unregister_event(/event/comp_ai_cmd_get_target, src, nameof(src::cmd_get_target()))

	parent.unregister_event(/event/comp_ai_cmd_set_state, src, nameof(src::cmd_set_state()))
	parent.unregister_event(/event/comp_ai_cmd_get_state, src, nameof(src::cmd_get_state()))
	return ..()

/datum/component/controller/proc/cmd_set_busy(yes)
	_busy = yes

/datum/component/controller/proc/cmd_get_busy()
	return _busy

/datum/component/controller/proc/cmd_set_target(atom/target)
	_target = target

/datum/component/controller/proc/cmd_get_target()
	return _target

/datum/component/controller/proc/cmd_set_state(new_state)
	_state = new_state

/datum/component/controller/proc/cmd_get_state()
	return _state
