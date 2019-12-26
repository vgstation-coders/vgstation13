//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31


/obj/machinery/computer/robotics
	name = "robotics control"
	desc = "Used to remotely lockdown or detonate linked Cyborgs."
	icon = 'icons/obj/computer.dmi'
	icon_state = "robot"
	req_access = list(access_robotics)
	circuit = "/obj/item/weapon/circuitboard/robotics"
	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/robotics/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/computer/robotics/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/robotics/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.set_machine(src)
	var/dat
	dat += {"<h3>Cyborg Control Console</h3><BR>"}
	for(var/mob/living/silicon/robot/R in mob_list)
		if(istype(user, /mob/living/silicon/ai))
			if(R.connected_ai != user)
				continue
		if(istype(user, /mob/living/silicon/robot))
			if(R != user)
				continue
		if(R.scrambledcodes)
			continue
		if(z != R.z) //Not on the same z-level
			continue
		dat += "[R.name] |"
		if(R.stat)
			dat += " Not Responding |"
		else if (!R.canmove)
			dat += " Locked Down |"
		else
			dat += " Operating Normally |"
		if (!R.canmove)
		else if(R.cell)
			dat += " Battery Installed ([R.cell.charge]/[R.cell.maxcharge]) |"
		else
			dat += " No Cell Installed |"
		if(R.module)
			dat += " Module Installed ([R.module.name]) |"
		else
			dat += " No Module Installed |"
		if(R.connected_ai)
			dat += " Slaved to [R.connected_ai.name] |"
		else
			dat += " Independent from AI |"
		if(ismalf(user) && R.connected_ai == user)
			if(R.emagged != MALFHACKED)
				dat += "<A href='?src=\ref[src];hackbot=\ref[R]'>(<font color=blue><i>Hack</i></font>)</A>"
			else
				dat += "<font color=green>Hacked</font>"
/*
			else if(R.emagged == MALFHACKED)
				dat += "<A href='?src=\ref[src];unhackbot=\ref[R]'>(<font color=blue><i>Repair</i></font>)</A>"
*/
		dat += {"<A href='?src=\ref[src];stopbot=\ref[R]'>(<font color=green><i>[R.canmove ? "Lockdown" : "Release"]</i></font>)</A>
			<A href='?src=\ref[src];lockbot=\ref[R]'>(<font color=orange><i>[R.modulelock ? "Module-unlock" : "Module-lock"]</i></font>)</A>
			<A href='?src=\ref[src];killbot=\ref[R]'>(<font color=red><i>Destroy</i></font>)</A>
			<BR><BR>"}

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/robotics/Topic(href, href_list)
	if(..())
		return 1
	else
		usr.set_machine(src)
		if(href_list["killbot"])
			if(allowed(usr))
				var/mob/living/silicon/robot/R = locate(href_list["killbot"])
				if(R)
					sanity_check(usr, R)
					var/choice = input("Are you certain you wish to detonate [R.name]?") in list("Confirm", "Abort")
					if(choice == "Confirm")
						if(R && istype(R))
							if(R.self_destruct())
								message_admins("<span class='notice'>[key_name_admin(usr)] detonated [R.name]!</span>")
								log_game("<span class='notice'>[key_name_admin(usr)] detonated [R.name]!</span>")
			else
				to_chat(usr, "<span class='warning'>Access Denied.</span>")
		else if(href_list["lockbot"])
			if(allowed(usr))
				var/mob/living/silicon/robot/R = locate(href_list["lockbot"])
				if(R && istype(R))
					if(!sanity_check(usr, R))
						return
					message_admins("<span class='notice'>[key_name_admin(usr)] [R.modulelock ? "module-unlocked" : "module-locked"] [R.name]!</span>")
					log_game("[key_name(usr)] [R.modulelock ? "module-unlocked" : "module-locked"] [R.name]!")
					R.toggle_modulelock()
					to_chat(R, "<span class='info' style=\"font-family:Courier\">Your modules have been remotely [R.modulelock ? "" : "un"]locked!</span>")
			else
				to_chat(usr, "<span class='warning'>Access Denied.</span>")
		else if(href_list["stopbot"])
			if(allowed(usr))
				var/mob/living/silicon/robot/R = locate(href_list["stopbot"])
				if(R && istype(R)) // Extra sancheck because of input var references
					if(!sanity_check(usr, R))
						return
					message_admins("<span class='notice'>[key_name_admin(usr)] [R.canmove ? "locked down" : "released"] [R.name]!</span>")
					log_game("[key_name(usr)] [R.canmove ? "locked down" : "released"] [R.name]!")
					R.canmove = !R.canmove
					if(R.lockcharge)
						R.lockcharge = !R.lockcharge
						to_chat(R, "Your lockdown has been lifted!")
					else
						R.lockcharge = !R.lockcharge
						to_chat(R, "You have been locked down!")
			else
				to_chat(usr, "<span class='warning'>Access Denied.</span>")
		else if(href_list["hackbot"])
			var/mob/living/silicon/robot/R = locate(href_list["hackbot"])
			if(R && istype(R))
				if(!sanity_check(usr, R))
					return
				log_game("[key_name(usr)] hacked [R.name] using the robotics console!")
				R.SetEmagged(MALFHACKED)
				if(R.mind.special_role)
					R.verbs += /mob/living/silicon/robot/proc/ResetSecurityCodes
/* //Unhacking borgs doesn't remove their emagged module currently
		else if(href_list["unhackbot"])
			var/mob/living/silicon/robot/R = locate(href_list["unhackbot"])
			if(R && istype(R))
				if(!sanity_check(usr, R))
					return
				log_game("[key_name(usr)] un-hacked [R.name] using the robotics console!")
				R.SetEmagged(UNHACKED)
*/
		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

//Because the console is made in HTML, it requires a slight copypasted check so that the conditions remain true, namely
//checking if the robot is still connected to the AI if the user is an AI, and if the borg got scrambled codes from traitorborg shenanigans
/obj/machinery/computer/robotics/proc/sanity_check(var/mob/user, var/mob/living/silicon/robot/R)
	if(istype(user, /mob/living/silicon/ai))
		if(R.connected_ai != user)
			return 0
	if(R.scrambledcodes)
		return 0
	else
		return 1

/obj/machinery/computer/robotics/emag(mob/user)
	..()
	req_access = list()
	if(user)
		to_chat(user, "You disable the console's access requirement.")