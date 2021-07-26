#define MACHINE_HACK_TIME 3 SECONDS


/obj/machinery
	var/mob/living/silicon/ai/malf_owner = null
	var/hack_abilities = list(
		/datum/malfhack_ability/disable,
		/datum/malfhack_ability/electrify
	)

/obj/machinery/proc/initialize_malfhack_abilities()
	var/list/initialized_abilities = list()
	for(var/ability in hack_abilities) 
		initialized_abilities += new ability(src)
		hack_abilities = initialized_abilities


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
	if(malf_owner != malf && !(stat & (BROKEN|NOPOWER)))
		if(src in M.currently_hacking_machines)
			to_chat(malf, "<span class='warning'>You are already taking control of this machine.</span>")
			return
//		if(M.currently_hacking_machines.len >= M.apcs.len)
//			to_chat(malf, "<span class='warning'>You cannot hack any more machines at this time. Hack more APCs to increase your limit.</span>")
//			return
		M.currently_hacking_machines += src
		//TODO- visual indicator that the machine is being hacked
		sleep(MACHINE_HACK_TIME)
		M.currently_hacking_machines -= src
		malf_owner = malf
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
	toggled ? (machine.stat &= ~MALFLOCKED) : (machine.stat |= MALFLOCKED)
	toggled = !toggled

/datum/malfhack_ability/electrify
	name = "Electrify"
	desc = "Electrify/Unelectrify this machine."
	icon = "radial_zap"
	icon_toggled = "radial_unzap"

/datum/malfhack_ability/electrify/activate()
	toggled ? (machine.stat &= ~ELECTRIFIED) : (machine.stat |= ELECTRIFIED)
	toggled = !toggled

