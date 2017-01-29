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
		SendSignal("bumped", list("movable"=AM))

// Called when we bump another movable atom.
/datum/component/controller/proc/OnBump(var/atom/A)
	if(istype(A, /atom/movable))
		var/atom/movable/AM = A
		SendSignal("bump", list("movable"=AM))

// Called when we receive the Life() tick from the MC/scheduler/whatever
/datum/component/controller/proc/Life()
	SendSignal("life", list())

//* Mob calls these to send signals to components. */
/datum/component/controller/proc/AttackingTarget(var/atom/A)
	SendSignal("attacking target", list("target"=A))

/datum/component/controller/proc/setBusy(var/yes)
	_busy = yes
	SendSignal("busy", list("state"=_busy))

/datum/component/controller/proc/getBusy()
	return _busy

/datum/component/controller/proc/setTarget(var/atom/A)
	_target = A
	SendSignal("target", list("target"=_target))

/datum/component/controller/proc/getTarget()
	return _target

/datum/component/controller/proc/setState(var/new_state)
	_state = new_state
	SendSignal("state changed", list("state"=_state))

/datum/component/controller/proc/getState()
	return _state

/datum/component/controller/proc/setBodyTemperature(var/temp)
	SendSignal("body temp", list("temp"=temp,"from"=src))

/datum/component/controller/proc/getBodyTemperature()
	return -1

/datum/component/controller/proc/canAttack(var/atom/A)
	if(istype(container.holder, /mob/living/simple_animal))
		var/mob/living/simple_animal/SA = container.holder
		return SA.CanAttack(A)
	return FALSE
