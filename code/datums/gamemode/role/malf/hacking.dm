#define MACHINE_HACK_TIME 5 SECONDS
#define APC_HACK_TIME 7 SECONDS
#define MALF_DISRUPT_TIME 10 SECONDS

/obj/machinery
	var/obj/effect/hack_overlay/hack_overlay
	var/datum/role/malfAI/malf_owner
	var/malf_hack_time = MACHINE_HACK_TIME
	var/malf_disrupted = FALSE
	var/aicontrolbypass = FALSE
	var/hack_abilities = list(
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/overload
	)

/obj/machinery/proc/initialize_malfhack_abilities()
	var/list/initialized_abilities = list()
	for(var/ability in hack_abilities) 
		initialized_abilities += new ability(src)
		hack_abilities = initialized_abilities

/obj/machinery/AIRightClick(var/mob/user)
	var/mob/living/silicon/A = user
	if(istype(A))
		hack_interact(user)

/obj/machinery/proc/disable_AI_control()
	if(aicontrolbypass)
		return
	else
		stat |= NOAICONTROL
		if(malf_owner)
			malf_disrupt(MALF_DISRUPT_TIME, TRUE)

/obj/effect/hack_overlay
	name = "hax particles"
	icon = 'icons/effects/malf.dmi'
	icon_state = ""
	opacity = 0
	mouse_opacity = 0
	invisibility = 101
	throwforce = 0
	var/image/particleimg 
	

/obj/effect/hack_overlay/New(var/turf/loc, var/mob/living/silicon/ai/malf, var/obj/machinery/machine)
	particleimg = image('icons/effects/malf.dmi',src,"hacking")
	particleimg.plane = HUD_PLANE
	particleimg.layer = UNDER_HUD_LAYER
	particleimg.appearance_flags = RESET_COLOR|RESET_ALPHA
	machine.vis_contents += src
	machine.hack_overlay = src
	malf.client.images |= particleimg

	var/datum/role/malfAI/M = malf.mind.GetRole(MALF)
	if(M)
		M.hack_overlays += src
	

/obj/effect/hack_overlay/proc/set_icon(var/newstate)
	particleimg.icon_state = newstate

/obj/machinery/proc/hack_interact(var/mob/living/silicon/malf)
	var/datum/role/malfAI/M = malf.mind.GetRole(MALF)
	if(!istype(M) || !istype(malf))		
		return
	if(malf.stat != CONSCIOUS)
		return
	if(istype(malf, /mob/living/silicon/shuntedAI) && !istype(malf.loc, /obj/machinery/power/apc))
		to_chat(malf, "<span class='warning'>Your connection isn't strong enough to hack while outside an APC.</span>")
		return
	if(!(stat & (BROKEN|NOPOWER)))
		if(M == malf_owner)
			if(!malf_disrupted)
				hack_radial(malf) 
		else
			take_control(malf)


/obj/machinery/proc/malf_disrupt(var/duration, var/bypassafter = FALSE)
	if(malf_disrupted || !malf_owner)
		return
	hack_overlay.set_icon("disrupted")
	malf_disrupted = TRUE
	spawn(duration)
		if(bypassafter)
			aicontrolbypass = TRUE
			stat &= ~NOAICONTROL
		malf_disrupted = FALSE
		set_hack_overlay_icon("hacked")

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
	if(stat & NOAICONTROL)	//ai control wire was cut before hack could complete
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
	if(M.currently_hacking_machines.len >= M.apcs.len)
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
		var/icon_to_display = A.toggled ? A.icon_toggled : A.icon
		var/name_to_display = A.name
		var/locked = FALSE
		if(!A.check_available(malf))
			name_to_display = A.name + " (Requires Module)"
			locked = TRUE
		else if(!A.check_cost(malf))
			locked = TRUE
		var/list/C = list(list(A.name, icon_to_display, A.desc, name_to_display, locked))
		choices += C
		choice_to_ability[A.name] = A
	var/choice = show_radial_menu(user=malf,anchor=src,choices=choices, icon_file='icons/obj/malf_radial.dmi',tooltip_theme="radial-malf",close_other_menus=TRUE)
	var/datum/malfhack_ability/A = choice_to_ability[choice]
	if(!A)
		return
	else 
		A.activate(malf)


/obj/machinery/atmospherics/hack_interact(var/mob/living/silicon/malf)
	return

/obj/machinery/portable_atmospherics/hack_interact(mob/living/silicon/malf)
	return
	
/obj/machinery/door/poddoor/hack_interact(mob/living/silicon/malf)
	return