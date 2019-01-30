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

/////////////////////////////LOCK MOVE//////////////////////////////

/datum/control/lock_move
	control_flags = LOCK_MOVEMENT_OF_CONTROLLER | LOCK_EYE_TO_CONTROLLED

///////////////////////////////SOULBLADE CONTROLLER///////////////////////////////

/datum/control/soulblade
	var/obj/item/weapon/melee/soulblade/blade = null
	var/move_delay = 0

/datum/control/soulblade/New(var/mob/new_controller, var/atom/new_controlled)
	..()
	blade = new_controlled

/datum/control/soulblade/is_valid(var/direction)
	if (blade.blood <= 0 || move_delay || blade.throwing)
		return 0
	if (!isturf(blade.loc))
		if (istype(blade.loc,/obj/structure/cult/altar))
			var/obj/structure/cult/altar/A = blade.loc
			blade.forceMove(A.loc)
			A.blade = null
			playsound(A.loc, 'sound/weapons/blade1.ogg', 50, 1)
			if (A.is_locking(A.lock_type))
				var/mob/M = A.get_locked(A.lock_type)[1]
				A.unlock_atom(M)
			A.update_icon()
		else
			return 0
	return ..()

/datum/control/soulblade/Move_object(var/direction)
	if(!controlled)
		return
	var/atom/start = blade.loc
	if(!is_valid())
		return
	step(controlled,direction)
	controlled.dir = direction
	if (blade.loc != start)
		blade.blood = max(blade.blood-1,0)
		move_delay = 1
		spawn(blade.movespeed)
			move_delay = 0

	var/matrix/M = matrix()
	M.Scale(1,blade.blood/blade.maxblood)
	var/total_offset = (60 + (100*(blade.blood/blade.maxblood))) * PIXEL_MULTIPLIER
	controller.hud_used.mymob.gui_icons.soulblade_bloodbar.transform = M
	controller.hud_used.mymob.gui_icons.soulblade_bloodbar.screen_loc = "WEST,CENTER-[8-round(total_offset/WORLD_ICON_SIZE)]:[total_offset%WORLD_ICON_SIZE]"
	controller.hud_used.mymob.gui_icons.soulblade_coverLEFT.maptext = "[blade.blood]"