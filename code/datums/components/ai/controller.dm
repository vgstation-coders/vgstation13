/datum/component/controller

	var/_busy=FALSE
	var/atom/_target=null

	var/_state=HOSTILE_STANCE_IDLE

/datum/component/controller/Initialize()
	RegisterSignal(parent, COMSIG_BUSY, .proc/setBusy)
	RegisterSignal(parent, COMSIG_TARGET, .proc/setTarget)
	RegisterSignal(parent, COMSIG_STATE, .proc/setState)
	RegisterSignal(parent, COMSIG_SET_BODYTEMP, .proc/setBodyTemperature)

/datum/component/controller/proc/setBusy(var/yes)
	_busy = yes
	SEND_SIGNAL(parent, COMSIG_BUSY, _busy)

/datum/component/controller/proc/getBusy()
	return _busy

/datum/component/controller/proc/setTarget(var/atom/target)
	_target = target
	SEND_SIGNAL(parent, COMSIG_TARGET, target)

/datum/component/controller/proc/getTarget()
	return _target

/datum/component/controller/proc/setState(var/new_state)
	_state = new_state
	SEND_SIGNAL(parent, COMSIG_STATE, new_state)

/datum/component/controller/proc/getState()
	return _state

/datum/component/controller/proc/setBodyTemperature(var/temp)
	SEND_SIGNAL(parent, COMSIG_SET_BODYTEMP, temp, src)

/datum/component/controller/proc/canAttack(var/atom/A)
	var/mob/living/simple_animal/SA = parent
	if(istype(SA))
		return SA.CanAttack(A)
	return FALSE
