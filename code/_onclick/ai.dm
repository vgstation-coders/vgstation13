/*
	AI ClickOn()

	Note currently ai restrained() returns 0 in all cases,
	therefore restrained code has been removed

	The AI can double click to move the camera (this was already true but is cleaner),
	or double click a mob to track them.

	Note that AI have no need for the adjacency proc, and so this proc is a lot cleaner.
*/
/mob/living/silicon/ai/DblClickOn(var/atom/A, params)
	if(client.buildmode) // comes after object.Click to allow buildmode gui objects to be clicked
		build_click(src, client.buildmode, params, A)
		return
	if(control_disabled || stat)
		return
	var/list/modifiers = params2list(params)
	if(modifiers["shift"] || modifiers["alt"] || modifiers["ctrl"])
		return
	if(istype(current, /obj/machinery/turret))
		return
	if(ismob(A) || ismecha(A))
		ai_actual_track(A)
	else
		A.move_camera_by_click()


/mob/living/silicon/ai/ClickOn(var/atom/A, params)
	if(click_delayer.blocked())
		return
	click_delayer.setDelay(1)

	if(client.buildmode) // comes after object.Click to allow buildmode gui objects to be clicked
		build_click(src, client.buildmode, params, A)
		return

	if(control_disabled || stat)
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
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(attack_delayer.blocked())
		return

	if(aicamera.in_camera_mode)
		aicamera.toggle_camera_mode()
		aicamera.captureimage(A, src)
		return

	/*
		AI restrained() currently does nothing
	if(restrained())
		RestrainedClickOn(A)
	else
	*/
	if(INVOKE_EVENT(src, /event/uattack, "atom" = A)) //This returns 1 when doing an action intercept
		return
	
	if(istype(current, /obj/machinery/turret))
		var/obj/machinery/turret/T = current
		if(T.enabled && T.raised)
			T.shootAt(A)
	else 
		A.add_hiddenprint(src)
		A.attack_ai(src)

/*
	AI has no need for the UnarmedAttack() and RangedAttack() procs,
	because the AI code is not generic;	attack_ai() is used instead.
	The below is only really for safety, or you can alter the way
	it functions and re-insert it above.
*/
/mob/living/silicon/ai/UnarmedAttack(atom/A)
	A.attack_ai(src)
/mob/living/silicon/ai/RangedAttack(atom/A)
	A.attack_ai(src)

/atom/proc/attack_ai(mob/user as mob)
	return

/*
	Since the AI handles shift, ctrl, and alt-click differently
	than anything else in the game, atoms have separate procs
	for AI shift, ctrl, and alt clicking.
*/
/mob/living/silicon/ai/ShiftClickOn(var/atom/A)
	A.AIShiftClick(src)
/mob/living/silicon/ai/CtrlClickOn(var/atom/A)
	A.AICtrlClick(src)
/mob/living/silicon/ai/AltClickOn(var/atom/A)
	A.AIAltClick(src)
/mob/living/silicon/ai/MiddleShiftClickOn(var/atom/A)
	A.AIMiddleShiftClick(src)
/mob/living/silicon/ai/RightClickOn(var/atom/A)
	A.AIRightClick(src)


/*
	The following criminally helpful code is just the previous code cleaned up;
	I have no idea why it was in atoms.dm instead of respective files.
*/

/atom/proc/AIMiddleShiftClick()
	return

/atom/proc/AIShiftClick()
	return

/atom/proc/AICtrlClick()
	return

/atom/proc/AIRightClick()
	return

/atom/proc/AIAltClick(var/mob/living/silicon/ai/user)
	AltClick(user)
	return
	
/obj/machinery/power/apc/AICtrlClick() // turns off APCs.
	if(allowed(usr))
		Topic("breaker=1", list("breaker"="1"), 0) // 0 meaning no window (consistency! wait...)

/obj/machinery/door/firedoor/AIShiftClick(var/mob/living/silicon/ai/user) // Allows examining firelocks
	examine(user)
