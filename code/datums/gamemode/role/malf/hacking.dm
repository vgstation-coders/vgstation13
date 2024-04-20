#define MACHINE_HACK_TIME 60 SECONDS
#define APC_HACK_TIME 60 SECONDS
#define MALF_DISRUPT_TIME 30 SECONDS

/obj/machinery
	var/obj/effect/hack_overlay/hack_overlay
	var/datum/role/malfAI/malf_owner
	var/malf_hack_time = MACHINE_HACK_TIME
	var/malf_disrupted = FALSE
	var/aicontrolbypass = FALSE

	var/hack_abilities = list(
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/oneuse/overload_quiet
	)

/obj/machinery/proc/initialize_malfhack_abilities()
	var/list/initialized_abilities = list()
	for(var/ability in hack_abilities)
		if(!ispath(ability))
			continue
		initialized_abilities += new ability(src)
	hack_abilities = initialized_abilities

/obj/machinery/AIRightClick(var/mob/user)
	var/mob/living/silicon/A = user
	if(istype(A))
		hack_interact(user)

/mob/living/silicon/ai/AIRightClick(var/mob/user)
	var/mob/living/silicon/ai/A = user
	var/datum/role/malfAI/M = A.mind.GetRole(MALF)
	if(istype(A) && istype(M) && A == src)
		upgrade_radial()

/obj/machinery/proc/disable_AI_control(var/disrupt = TRUE)
	if(aicontrolbypass)
		return
	else
		stat |= NOAICONTROL
		if(malf_owner && disrupt)
			malf_disrupt(MALF_DISRUPT_TIME, TRUE)

/obj/machinery/proc/enable_AI_control(var/bypass)
	stat &= ~NOAICONTROL
	aicontrolbypass = bypass

/obj/machinery/proc/hack_interact(var/mob/living/silicon/malf)
	var/datum/role/malfAI/M = malf.mind.GetRole(MALF)
	if(!istype(M) || !istype(malf))
		return
	if(malf.stat != CONSCIOUS)
		return
	if(!(stat & (BROKEN|NOPOWER)))
		if(M == malf_owner)
			if(!malf_disrupted)
				hack_radial(malf)
		else
			take_control(malf)


/obj/machinery/proc/malf_disrupt(var/duration, var/bypassafter = FALSE, var/permanent = TRUE)
	if(malf_disrupted || !malf_owner)
		return
	set_hack_overlay_icon("disrupted")
	malf_disrupted = TRUE
	if(!permanent)
		spawn(duration)
			malf_undisrupt(bypassafter)

/obj/machinery/proc/malf_undisrupt(var/bypass)
	malf_disrupted = FALSE
	set_hack_overlay_icon("hacked")
	if(bypass)
		enable_AI_control(TRUE)

/obj/machinery/proc/take_control(var/mob/living/silicon/malf)
	var/datum/role/malfAI/M = malf.mind.GetRole(MALF)
	if(!istype(M))
		return
	if(!malfhack_valid(malf))
		return
	if(!start_malfhack(malf))
		to_chat(malf, "<span class='warning'>An unexpected error occured.</span>")
		return
	sleep(malf_hack_time)
	set_malf_owner(M)
	check_for_ai_control()

/obj/machinery/proc/check_for_ai_control()
	if(stat & NOAICONTROL)	//ai control wire was cut before hack could complete
		malf_disrupt(MALF_DISRUPT_TIME, TRUE)
	else
		set_hack_overlay_icon("hacked")

/obj/machinery/door/airlock/check_for_ai_control()
	if(aiControlDisabled == 1)
		malf_disrupt(MALF_DISRUPT_TIME, TRUE)
	else
		set_hack_overlay_icon("hacked")

/obj/machinery/proc/malfhack_valid(var/mob/living/silicon/malf)
	var/datum/role/malfAI/M = malf.mind.GetRole(MALF)
	if(!istype(M) || !istype(malf))
		to_chat(malf, "<span class='warning'>You are not a malfunctioning AI.</span>")
		return FALSE
	if(src in M.currently_hacking_machines)
		to_chat(malf, "<span class='warning'>You are already taking control of the [src].</span>")
		return FALSE
	if(M.currently_hacking_machines.len >= (M.apcs.len + 1))
		to_chat(malf, "<span class='warning'>You cannot hack any more machines at this time. Hack more APCs to increase your limit.</span>")
		return FALSE
	return TRUE

/obj/machinery/proc/start_malfhack(var/mob/living/silicon/malf)
	var/datum/role/malfAI/M = malf.mind.GetRole(MALF)
	if(!istype(M) || !istype(malf))
		return
	new /obj/effect/hack_overlay(null, malf, src)
	M.currently_hacking_machines += src
	return TRUE


/obj/machinery/proc/set_hack_overlay_icon(var/newstate)
	hack_overlay.set_icon(newstate)

/obj/machinery/camera/set_hack_overlay_icon(var/newstate)
	hack_overlay.set_icon("[newstate]-camera")

/obj/machinery/proc/is_malf_owner(var/mob/user)
	if(!istype(user))
		return
	var/datum/role/malfAI/M = user.mind?.GetRole(MALF)
	if(M && M == malf_owner)
		return TRUE
	return FALSE

/obj/machinery/proc/set_malf_owner(var/datum/role/malfAI/M)
	if(!istype(M))
		return
	M.currently_hacking_machines -= src
	malf_owner = M
	return TRUE

//Generate the radial for this machine.
/obj/machinery/proc/hack_radial(var/mob/living/silicon/malf)
	var/list/choice_to_ability = list()
	var/list/choices = list()
	for(var/datum/malfhack_ability/A in hack_abilities)
		A.before_radial()
		var/icon_to_display
		if(istype(A, /datum/malfhack_ability/toggle))
			var/datum/malfhack_ability/toggle/AT = A
			icon_to_display = AT.toggled ? AT.icon_toggled : AT.icon
		else
			icon_to_display = A.icon
		var/name_to_display = A.name
		if(A.cost > 0)
			name_to_display = "[A.name] ([A.cost])"
		var/locked = FALSE
		if(!A.check_available(malf))
			continue
		else if(!A.check_cost(malf))
			locked = TRUE
		var/list/C = list(list(A.name, icon_to_display, A.desc, name_to_display, locked))
		choices += C
		choice_to_ability[name_to_display] = A
	var/choice = show_radial_menu(user=malf,anchor=src,choices=choices, icon_file='icons/obj/malf_radial.dmi',tooltip_theme="radial-malf",close_other_menus=TRUE)
	var/datum/malfhack_ability/A = choice_to_ability[choice]
	if(!A)
		return
	else
		A.activate(malf)


/mob/living/silicon/ai/proc/upgrade_radial()
	var/datum/role/malfAI/M = mind.GetRole(MALF)
	if(!M)
		return
	var/list/choice_to_ability = list()
	var/list/choices = list()
	for(var/datum/malfhack_ability/core/A in M.core_upgrades)
		A.before_radial()
		var/icon_to_display = A.icon
		var/name_to_display = A.name
		if(A.cost > 0)
			name_to_display = "[A.name] ([A.cost])"
		var/locked = FALSE
		if(!A.check_available(src))
			continue
		else if(!A.check_cost(src))
			locked = TRUE
		var/list/C = list(list(A.name, icon_to_display, A.desc, name_to_display, locked))
		choices += C
		choice_to_ability[name_to_display] = A
	var/choice = show_radial_menu(user=src,anchor=src,choices=choices, icon_file='icons/obj/malf_radial.dmi',tooltip_theme="radial-malf",close_other_menus=TRUE)
	var/datum/malfhack_ability/A = choice_to_ability[choice]
	if(!A)
		return
	else
		A.activate(src)



/obj/machinery/atmospherics/hack_interact(var/mob/living/silicon/malf)
	return

/obj/machinery/portable_atmospherics/hack_interact(mob/living/silicon/malf)
	return

/obj/machinery/door/poddoor/hack_interact(mob/living/silicon/malf)
	return

/obj/machinery/iv_drip/hack_interact(mob/living/silicon/malf)
	return

/obj/machinery/light/hack_interact(mob/living/silicon/malf)
	return


/obj/effect/hack_overlay
	name = ""
	icon = 'icons/effects/malf.dmi'
	icon_state = ""
	opacity = 0
	mouse_opacity = 1
	invisibility = 101
	throwforce = 0
	var/image/particleimg
	var/obj/machinery/machine

// We want the "hack particles" to be only visible to the AI, but we also want it to be mutable.
// Since image objects can't be directly added to vis_contents (i think?) they're instead carried by an effect obj
// An invisible effect object is created, which carries an image object for the "hack particles"
// The effect object is added to the machines vis_contents and to a list in the malf's role datum.

/obj/effect/hack_overlay/New(var/turf/loc, var/mob/living/silicon/ai/malf, var/obj/machinery/new_machine)
	machine = new_machine
	name = new_machine.name
	particleimg = image('icons/effects/malf.dmi',src,"hacking")
	particleimg.plane = STATIC_PLANE
	particleimg.layer = HACK_LAYER
	if(istype(machine, /obj/machinery/camera))		// layer above static if its a camera
		particleimg.layer = REACTIVATE_CAMERA_LAYER
	particleimg.appearance_flags = RESET_COLOR|RESET_ALPHA
	machine.vis_contents += src
	machine.hack_overlay = src
	malf.client.images |= particleimg

	var/datum/role/malfAI/M = malf.mind.GetRole(MALF)
	if(M)
		M.hack_overlays += src

/obj/effect/hack_overlay/proc/set_icon(var/newstate)
	particleimg.icon_state = newstate

// Any clicks on the overlay should to count as clicks on the machine. This is mostly
// for convenience, but its necessary for doing things like re-enabling cameras

/obj/effect/hack_overlay/AIMiddleShiftClick(var/mob/living/silicon/ai/user)
	machine.AIMiddleShiftClick(user)
/obj/effect/hack_overlay/AIShiftClick(var/mob/living/silicon/ai/user)
	machine.AIShiftClick(user)
/obj/effect/hack_overlay/AICtrlClick(var/mob/living/silicon/ai/user)
	machine.AICtrlClick(user)
/obj/effect/hack_overlay/AIRightClick(var/mob/living/silicon/ai/user)
	machine.AIRightClick(user)
/obj/effect/hack_overlay/AIAltClick(var/mob/living/silicon/ai/user)
	machine.AIAltClick(user)
/obj/effect/hack_overlay/attack_ai(var/mob/living/silicon/ai/user)
	machine.attack_ai(user)

