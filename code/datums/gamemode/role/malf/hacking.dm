#define MACHINE_HACK_TIME 5 SECONDS


/obj/machinery
	var/list/malf_owners = list()
	var/hack_abilities = list(
		/datum/malfhack_ability/disable
	)

/obj/machinery/proc/initialize_malfhack_abilities()
	var/list/initialized_abilities = list()
	for(var/ability in hack_abilities) 
		initialized_abilities += new ability(src)
		hack_abilities = initialized_abilities

/obj/machinery/AIRightClick(var/mob/user)
	var/mob/living/silicon/ai/A = user
	if(istype(A))
		hack_interact(user)


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
	malf.client.images |= particleimg

/obj/effect/hack_overlay/proc/set_icon(var/newstate)
	particleimg.icon_state = newstate

/datum/malfhack_ability
	var/name = "HACK"						//ability name (must be unique)
	var/desc = "This does something."	//ability description
	var/icon = "radial_off"				//icon to display in the radial
	var/icon_toggled = "radial_on"
	
	var/toggled = FALSE		

	var/obj/machinery/machine 

/datum/malfhack_ability/New(var/obj/machinery/M)
	machine = M

/datum/malfhack_ability/proc/activate()
	return

/obj/machinery/proc/hack_interact(var/mob/living/silicon/ai/malf)
	var/datum/role/malfAI/M = malf.mind.GetRole(MALF)
	if(!M)		//this shouldn't happen
		return
	if(malf in malf_owners && !(stat & (BROKEN|NOPOWER)))
		if(src in M.currently_hacking_machines)
			to_chat(malf, "<span class='warning'>You are already taking control of this machine.</span>")
			return
//		if(M.currently_hacking_machines.len >= M.apcs.len)
//			to_chat(malf, "<span class='warning'>You cannot hack any more machines at this time. Hack more APCs to increase your limit.</span>")
//			return
		M.currently_hacking_machines += src
		var/obj/effect/hack_overlay/overlay = new /obj/effect/hack_overlay(get_turf(src), malf, src)
		sleep(MACHINE_HACK_TIME)
		overlay.set_icon("hacked")
		M.currently_hacking_machines -= src
		malf_owners += malf
	else 
		var/list/choice_to_ability = list()
		var/list/choices = list()
		for(var/datum/malfhack_ability/A in hack_abilities)
			var/icon_to_display = A.toggled ? A.icon_toggled : A.icon
			var/list/C = list(list(A.name, icon_to_display, A.desc))
			choices += C
			choice_to_ability[A.name] = A
		var/choice = show_radial_menu(malf,loc,choices)
		var/datum/malfhack_ability/A = choice_to_ability[choice]
		if(!A)
			return
		else 
			A.activate()


/datum/malfhack_ability/disable
	name = "Toggle On/Off"
	desc = "Disable/Enable this machine."
	icon = "radial_off"
	icon_toggled = "radial_on"

/datum/malfhack_ability/disable/activate()
	toggled ? (machine.stat &= ~FORCEDISABLE) : (machine.stat |= FORCEDISABLE)
	toggled = !toggled
	machine.update_icon()



