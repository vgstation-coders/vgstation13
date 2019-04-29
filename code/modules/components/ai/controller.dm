/datum/component/controller
	var/atom/holder

	var/_busy=FALSE
	var/atom/_target=null

	var/_state=HOSTILE_STANCE_IDLE

/datum/component/controller/New(var/datum/component_container/container, var/atom/_holder)
	..(container)
	holder=_holder

// Called when we are bumped by another movable atom.
/datum/component/controller/proc/OnBumped(var/atom/A)
	if(istype(A, /atom/movable))
		var/atom/movable/AM = A
		SendSignal(COMSIG_BUMPED, list("movable"=AM))

// Called when we bump another movable atom.
/datum/component/controller/proc/Onto_bump(var/atom/A)
	if(istype(A, /atom/movable))
		var/atom/movable/AM = A
		SendSignal(COMSIG_BUMP, list("movable"=AM))

// Called when we receive the Life() tick from the MC/scheduler/whatever
/datum/component/controller/proc/Life()
	SendSignal(COMSIG_LIFE, list())

//* Mob calls these to send signals to components. */
/datum/component/controller/proc/AttackTarget(var/atom/A)
	container.SendSignalToFirst(/datum/component/ai, COMSIG_ATTACKING, list("target"=A))

/datum/component/controller/proc/setBusy(var/yes)
	_busy = yes
	SendSignal(COMSIG_BUSY, list("state"=_busy))

/datum/component/controller/proc/getBusy()
	return _busy

/datum/component/controller/proc/setTarget(var/atom/A)
	_target = A
	SendSignal(COMSIG_TARGET, list("target"=_target))

/datum/component/controller/proc/getTarget()
	return _target

/datum/component/controller/proc/setState(var/new_state)
	_state = new_state
	SendSignal(COMSIG_STATE, list("state"=_state))

/datum/component/controller/proc/getState()
	return _state

/datum/component/controller/proc/setBodyTemperature(var/temp)
	SendSignal(COMSIG_SET_BODYTEMP, list("temp"=temp,"from"=src))

/datum/component/controller/proc/getBodyTemperature()
	return -1

/datum/component/controller/proc/canAttack(var/atom/A)
	if(istype(container.holder, /mob/living/simple_animal))
		var/mob/living/simple_animal/SA = container.holder
		return SA.CanAttack(A)
	return FALSE
