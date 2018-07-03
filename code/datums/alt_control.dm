/datum/control
	var/name = "controlling something else"
	var/mob/controller
	var/atom/movable/controlled
	var/control_flags = 0
	var/damaged_event_key
	var/is_controlled = FALSE //Whether we're in strict control

/datum/control/New(var/mob/new_controller, var/atom/new_controlled)
	..()
	controller = new_controller
	damaged_event_key = controller.on_damaged.Add(src, "user_damaged")
	controlled = new_controlled

/datum/control/Destroy()
	break_control()
	if(controller)
		controller.control_object.Remove(src)
		controller = null
	controlled = null
	..()

/datum/control/proc/user_damaged(list/arguments)
	var/amount = arguments["amount"]
	if(amount > 0 && control_flags & REVERT_ON_CONTROLLER_DAMAGED)
		break_control()

/datum/control/proc/break_control()
	if(controller && controller.client)
		controller.client.eye = controller.client.mob
		controller.client.perspective = MOB_PERSPECTIVE
		is_controlled = FALSE
		if(control_flags & LOCK_MOVEMENT_OF_CONTROLLER)
			controller.canmove = 1

/datum/control/proc/take_control()
	if(!is_valid(0))
		return
	if(control_flags & LOCK_EYE_TO_CONTROLLED)
		controller.client.perspective = EYE_PERSPECTIVE
		controller.client.eye = controlled
	is_controlled = TRUE
	if(control_flags & LOCK_MOVEMENT_OF_CONTROLLER)
		controller.canmove = 0

/datum/control/proc/is_valid(var/check_control = FALSE)
	if(!controller || !controller.client || !controlled || controller.gcDestroyed || controlled.gcDestroyed)
		qdel(src)
		return 0
	if(check_control && !(control_flags & REQUIRES_CONTROL && is_controlled))
		return 0
	return 1

/datum/control/proc/Move_object(var/direction)
	if(!is_valid())
		return
	if(controlled)
		if(control_flags & LOCK_MOVEMENT_OF_CONTROLLER)
			controller.canmove = 0
		if(controlled.density)
			step(controlled,direction)
			if(!controlled)
				return
			controlled.dir = direction
		else
			controlled.forceMove(get_step(controlled,direction))

/datum/control/proc/Orient_object(var/direction)
	if(!is_valid())
		return
	if(control_flags & LOCK_MOVEMENT_OF_CONTROLLER)
		controller.canmove = 0
	controlled.dir = direction

/datum/control/lock_move
	control_flags = LOCK_MOVEMENT_OF_CONTROLLER | LOCK_EYE_TO_CONTROLLED