//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

#define DEFAULT_SEQUENCE_TIME	120 SECONDS

/obj/machinery/computer/robotics
	name = "robotics control"
	desc = "Used to remotely lockdown or detonate linked Cyborgs."
	icon = 'icons/obj/computer.dmi'
	icon_state = "robot"
	req_access = list(access_robotics)
	circuit = "/obj/item/weapon/circuitboard/robotics"

	var/hacking = 0
	var/id = 0.0
	var/temp = null
	var/stop = 0.0
	var/screen = 0 // 0 - Main Menu, 1 - Cyborg Status, 2 - Kill 'em All! -- In text

	hack_abilities = list(
		/datum/malfhack_ability/oneuse/explosive_borgs,
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/oneuse/overload_quiet
	)

	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/robotics/say_quote(text)
	return "beeps, [text]"

/obj/machinery/computer/robotics/proc/speak(var/message)
	if(stat & (NOPOWER|FORCEDISABLE))	//sanity
		return
	if (!message)
		return
	say(message)

/obj/machinery/computer/robotics/attack_paw(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/robotics/attack_hand(var/mob/user as mob)
	if(..())
		return
	if (z > 6)
		to_chat(user, "<span class='danger'>Unable to establish a connection: </span>You're too far away from the station!")
		return
	tgui_interact(user)


/obj/machinery/computer/robotics/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RoboticsControlConsole")
		ui.open()

/obj/machinery/computer/robotics/ui_data(mob/user)
	var/list/data = list()

	data["can_hack"] = FALSE
	if((isAI(user) && ismalf(user)) || isAdminGhost(user))
		data["can_hack"] = TRUE
	if(hacking)
		data["can_hack"] = FALSE

	data["sequence_activated"] = FALSE
	if(cyborg_detonation_time > world.time)
		data["sequence_activated"] = TRUE
	data["sequence_timeleft"] = (cyborg_detonation_time-world.time)/10

	data["cyborgs"] = list()
	for(var/mob/living/silicon/robot/R in cyborg_list)
		if(!can_control(R,user))
			continue
		var/list/cyborg_data = list(
			name = R.name,
			locked_down = R.lockdown,
			status = R.stat,
			charge = R.cell ? R.cell.percent() : null,
			module = R.module ? "[R.modtype] Module" : "No Module Installed",
			master = R.connected_ai,
			emagged = R.emagged,
			borgimage = iconsouth2base64(getFlatIcon(R)),
			ref = ref(R)
		)
		data["cyborgs"] += list(cyborg_data)

	return data


/obj/machinery/computer/robotics/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("killbot")
			if(allowed(usr))
				var/mob/living/silicon/robot/R = locate(params["ref"])
				if(!can_control(R,usr))
					return
				to_chat(usr, "<span class='warning'>You send a detonation signal to [R.name].</span>")

				var/turf/T = get_turf(src)
				message_admins("[key_name(usr)] [formatJumpTo(usr)] detonated [key_name(R)] [formatJumpTo(get_turf(R))] using a robotics console!")
				log_game("[key_name(usr)] detonated [key_name(R)] using a robotics console at [T.loc] (@[T.x],[T.y],[T.z])!")
				if(R.connected_ai && usr != R.connected_ai)
					to_chat(R.connected_ai, "<span style=\"font-family:Courier\"><b>\[<span class='danger'>ALERT</span>\] Slaved Cyborg [R.name] detonated. Signal traced to [get_area(src).name].</b></span>")
					R.connected_ai << 'sound/machines/twobeep.ogg'
				R.self_destruct()

			else
				to_chat(usr, "<span class='warning'>Access Denied.</span>")

		if("lockdown")
			if(allowed(usr))
				var/mob/living/silicon/robot/R = locate(params["ref"])
				if(!can_control(R, usr))
					return TRUE
				var/turf/T = get_turf(src)
				to_chat(usr, "<span class='warning'>You send a lockdown signal to [R.name].</span>")
				if(!R.SetLockdown(!R.lockdown, TRUE))
					return TRUE
				if(R.connected_ai && usr != R.connected_ai)
					message_admins("[key_name(usr)] [formatJumpTo(usr)] [!R.lockdown ? "locked down" : "released"] [key_name(R)] [formatJumpTo(R)] using a robotics console!")
					log_game("[key_name(usr)] [!R.lockdown ? "locked down" : "released"] [key_name(R)] using a robotics console at [T.loc] (@[T.x],[T.y],[T.z])!")
					if(R.lockdown)
						to_chat(R.connected_ai, "<span style=\"font-family:Courier\"><b>\[<span class='danger'>ALERT</span>\] Slaved Cyborg [R.name] locked down. Signal traced to [get_area(src).name]</b></span>")
						R.connected_ai << 'sound/machines/twobeep.ogg'
					else
						to_chat(R.connected_ai, "<span style=\"font-family:Courier\"><b>\[<span class='notice'>INFO</span>\] The lockdown on cyborg [R.name] has been lifted. Signal traced to [get_area(src).name]</b></span>")
						R.connected_ai << 'sound/misc/notice2.ogg'
			else
				to_chat(usr, "<span class='warning'>Access Denied.</span>")
		if("hack")
			var/mob/living/silicon/robot/R = locate(params["ref"])
			if(isAdminGhost(usr))
				to_chat(usr, "<span class='warning'>You emagged [R].")
				log_game("[key_name(usr)] emagged [key_name(R)] using a robotics console!")
				message_admins("[key_name(usr)] emagged [key_name(R)] using a robotics console!")
				R.SetEmagged(TRUE)
			if(can_control(R, usr) && ismalf(usr))
				if (!hacking)
					hacking = 1
					to_chat(usr, "<span style=\"font-family:Courier\"><b>\[<span class='danger'>ERROR</span>\] [R.name]: SAFETY OVERRIDE INITIATED.</b></span>")
					sleep(600)
					log_game("[key_name(usr)] emagged [key_name(R)] using a robotics console!")
					message_admins("[key_name(usr)] emagged [key_name(R)] using a robotics console!")
					R.SetEmagged(TRUE)
					to_chat(usr, "<span style=\"font-family:Courier\"><b>\[<span class='danger'>ERROR</span>\] [R.name]: SAFETIES DISABLED.</b></span>")
					usr << 'sound/misc/notice2.ogg'
					hacking = 0
				else
					to_chat(usr, "You are already hacking a cyborg.")
		if("sequence")
			if(cyborg_detonation_time == 0 || cyborg_detonation_time < world.time)
				start_sequence()
				message_admins("<span class='notice'>[key_name_admin(usr)] [formatJumpTo(usr)] has initiated the global cyborg killswitch!</span>")
				log_game("<span class='notice'>[key_name(usr)] has initiated the global cyborg killswitch!</span>")
			else
				stop_sequence()
				message_admins("<span class='notice'>[key_name_admin(usr)] [formatJumpTo(usr)] has halted the global cyborg killswitch!</span>")
				log_game("<span class='notice'>[key_name(usr)] has halted the global cyborg killswitch!</span>")
	return TRUE

/obj/machinery/computer/robotics/proc/can_control(var/mob/living/silicon/robot/robot, var/mob/controller)
	if(robot.scrambledcodes)
		return FALSE
	if(isrobot(controller) && controller != robot)
		return FALSE
	if(isAI(controller) && robot.connected_ai != controller)
		return FALSE
	return TRUE


/obj/machinery/computer/robotics/proc/start_sequence()
	speak("Emergency self-destruct sequence initiatied.")
	cyborg_detonation_time = world.time + DEFAULT_SEQUENCE_TIME
	update_icon()

	for(var/mob/living/silicon/ai/A in mob_list)
		to_chat(A, "<span style=\"font-family:Courier\"><b>\[<span class='danger'>ALERT</span>\] Emergency Cyborg Self-Destruct Sequence Activated. Signal traced to [get_area(src).name].</b></span>")
		A << 'sound/machines/warning-buzzer.ogg'
	for(var/mob/living/silicon/robot/R in cyborg_list)
		if(!R.scrambledcodes && !isMoMMI(R))
			to_chat(R, "<span style=\"font-family:Courier\"><b>\[<span class='danger'>ALERT</span>\] Emergency Self-Destruct Sequence Initiated. This unit will self-destruct in [formatTimeDuration(cyborg_detonation_time-world.time)] unless a termination signal is received.</b></span>")
			R << 'sound/machines/warning-buzzer.ogg'


/obj/machinery/computer/robotics/proc/stop_sequence()
	if(cyborg_detonation_time != 0)
		speak("Emergency self-destruct sequence halted.")
	cyborg_detonation_time = 0
	update_icon()

	for(var/mob/living/silicon/ai/A in mob_list)
		to_chat(A, "<span style=\"font-family:Courier\"><b>\[<span class='notice'>INFO</span>\] Emergency Cyborg Self-Destruct Sequence Halted. Signal traced to [get_area(src).name].</b></span>")
		A << 'sound/misc/notice2.ogg'
	for(var/mob/living/silicon/robot/R in cyborg_list)
		if(!R.scrambledcodes && !isMoMMI(R))
			to_chat(R, "<span style=\"font-family:Courier\"><b>\[<span class='notice'>INFO</span>\] Emergency Self-Destruct Sequence Halted.</b></span>")
			R << 'sound/misc/notice2.ogg'

/obj/machinery/computer/robotics/emag_act(mob/user)
	..()
	req_access = list()
	if(user)
		to_chat(user, "You disable the console's access requirement.")

/obj/machinery/computer/robotics/update_icon()
	..()

	if(stat & (BROKEN | NOPOWER | FORCEDISABLE))
		return

	if (cyborg_detonation_time != 0 && cyborg_detonation_time > world.time)
		icon_state = "robot-alert"
	else
		icon_state = "robot"



/obj/machinery/computer/robotics/process()
	..()
	update_icon()


#undef DEFAULT_SEQUENCE_TIME
