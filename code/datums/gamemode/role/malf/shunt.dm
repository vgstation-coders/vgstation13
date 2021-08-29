/mob/living/silicon/shuntedAI
	name = "Shunted AI"
	var/mob/living/silicon/ai/core
	var/list/cables_shown = list()
	var/speeding = FALSE


/mob/living/silicon/shuntedAI/New(loc, var/datum/ai_laws/L, var/mob/living/silicon/ai/A)
	..()
	core = A
	name = A.name
	A.shuntedAI = src

	if(L && istype(L,/datum/ai_laws))
		laws = L
	else
		laws = new /datum/ai_laws/malf()

/mob/living/silicon/shuntedAI/proc/return_to_core()
	if(!core)
		return
	mind.transfer_to(core)
	core.shuntedAI = null
	qdel(src)

/mob/living/silicon/shuntedAI/Login()
	..()
	DisplayUI("Shunted Malf")
	client.CAN_MOVE_DIAGONALLY = TRUE
	

/mob/living/silicon/shuntedAI/movement_delay()
	if(speeding)
		return 1.4
	else 
		return 2.0

/mob/living/silicon/shuntedAI/Life()
	..()
	if(istype(loc, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = loc
		var/obj/item/weapon/cell/cell = A.get_cell()
		if(cell.charge > 0)
			adjustOxyLoss(-1)
		else
			adjustOxyLoss(1)
	if(istype(loc, /obj/structure/cable))
		var/obj/structure/cable/C = loc
		if(C.avail() <= 0)
			adjustOxyLoss(1)



/obj/machinery/power/apc/relaymove(var/mob/living/silicon/shuntedAI/user, direction)
	if(!istype(user))
		return
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		user.shunt_transfer(C)


/obj/structure/cable/relaymove(var/mob/living/silicon/shuntedAI/user, direction)
	if(!istype(user))
		return
	var/list/valid_exit_directions = list()
	var/turf/T = get_turf(src)
//	var/turf/Dest = get_step(src,direction)
	for(var/obj/structure/cable/C in T)
		valid_exit_directions += C.d1
		valid_exit_directions += C.d2
	to_chat(world, valid_exit_directions)
	if(!(locate(direction) in valid_exit_directions))		
		var/obj/machinery/power/apc/A = locate(/obj/machinery/power/apc) in get_turf(src)
		if(A)
			to_chat(world, "TEST1")
			return user.shunt_transfer(A)
		return
	var/obj/structure/cable/target_move = findConnecting(direction)
	if(!target_move)
		var/obj/machinery/power/apc/A = locate(/obj/machinery/power/apc) in get_turf(src)
		if(A)
			to_chat(world, "TEST2")
			return user.shunt_transfer(A)
		return
	if (user.client.prefs.stumble && ((world.time - user.last_movement) > 5))
		user.delayNextMove(3)	

	var/delay = user.movement_delay()
	if(user.speeding)
		target_move.shake(1, 3)
		spark(target_move, 1)
	user.forceMove(target_move, glide_size_override = DELAY2GLIDESIZE(delay))
	user.delayNextMove(delay)
	user.last_movement = world.time



/obj/structure/cable/proc/findConnecting(var/direction)
	for(var/obj/structure/cable/target in get_step(src,direction))
		if(target.d1 == get_dir(target,src) || target.d2 == get_dir(target,src))
			return target



/mob/living/silicon/shuntedAI/proc/shunt_transfer(var/atom/A, var/delay = 1.5 SECONDS)

	var/atom/previous = loc
	if(!(do_after(src, A, delay)))
		return
	forceMove(A)
	previous.update_icon()
	A.update_icon()
	if(istype(A, /obj/structure/cable))
		var/obj/structure/cable/C = A
		var/datum/powernet/P = C.powernet
		for(var/obj/structure/cable/Ca in P.cables)
			var/image/cable_image = image(Ca.icon, Ca.loc, Ca.icon_state, ABOVE_LIGHTING_LAYER)
			cable_image.plane = ABOVE_LIGHTING_PLANE
			cable_image.color = Ca.color
			cables_shown += cable_image
			client.images += cable_image
	else
		for(var/image/I in cables_shown)
			client.images -= I
		client.eye = src
		cables_shown.len = list()













/mob/living/silicon/shuntedAI/ClickOn(var/atom/A, params)
	if(click_delayer.blocked())
		return
	click_delayer.setDelay(1)

	if(client.buildmode) // comes after object.Click to allow buildmode gui objects to be clicked
		build_click(src, client.buildmode, params, A)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["middle"])
		if(modifiers["shift"])
			MiddleShiftClickOn(A)
			return
		else
			MiddleClickOn(A)
			return
	if(modifiers["right"])
		RightClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"]) 
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(attack_delayer.blocked())
		return

	if(lazy_invoke_event(/lazy_event/on_uattack, list("atom" = A))) 
		return
	A.add_hiddenprint(src)
	A.attack_ai(src)

/mob/living/silicon/shuntedAI/UnarmedAttack(atom/A)
	A.attack_ai(src)
/mob/living/silicon/shuntedAI/RangedAttack(atom/A)
	A.attack_ai(src)
/mob/living/silicon/shuntedAI/ShiftClickOn(var/atom/A)
	A.AIShiftClick(src)
/mob/living/silicon/shuntedAI/CtrlClickOn(var/atom/A)
	A.AICtrlClick(src)
/mob/living/silicon/shuntedAI/AltClickOn(var/atom/A)
	A.AIAltClick(src)
/mob/living/silicon/shuntedAI/MiddleShiftClickOn(var/atom/A)
	A.AIMiddleShiftClick(src)
/mob/living/silicon/shuntedAI/RightClickOn(var/atom/A)
	A.AIRightClick(src)

