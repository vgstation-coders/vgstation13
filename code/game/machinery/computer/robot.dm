//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31


/obj/machinery/computer/robotics
	name = "robotics control"
	desc = "Used to remotely lockdown or detonate linked Cyborgs."
	icon = 'icons/obj/computer.dmi'
	icon_state = "robot"
	req_access = list(access_robotics)
	circuit = "/obj/item/weapon/circuitboard/robotics"

	var/id = 0.0
	var/temp = null
	var/status = 0
	var/timeleft = 60
	var/stop = 0.0
	var/screen = 0 // 0 - Main Menu, 1 - Cyborg Status, 2 - Kill 'em All! -- In text

	light_color = LIGHT_COLOR_PINK


/obj/machinery/computer/robotics/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/computer/robotics/attack_paw(var/mob/user as mob)

	return src.attack_hand(user)
	return

/obj/machinery/computer/robotics/attack_hand(var/mob/user as mob)
	if(..())
		return
	if (src.z > 6)
		to_chat(user, "<span class='danger'>Unable to establish a connection: </span>You're too far away from the station!")
		return
	user.set_machine(src)
	var/dat
	if(ismalf(user))
		dat = {"<h3><font color = red><b>Warning! Illegal privilegE&!#*</b>"}
	if (src.temp)
		dat = "<TT>[src.temp]</TT><BR><BR><A href='?src=\ref[src];temp=1'>Clear Screen</A>"
	else
		if(screen == 0)

			dat += {"<h3>Cyborg Control Console</h3><BR>
				<A href='?src=\ref[src];screen=1'>1. Cyborg Status</A><BR>
				<A href='?src=\ref[src];screen=2'>2. Emergency Full Destruct</A><BR>"}
		if(screen == 1)
			for(var/mob/living/silicon/robot/R in mob_list)
				if(istype(user, /mob/living/silicon/ai))
					if (R.connected_ai != user && !ismalf(user)) //Malf AIs get to see any robot on the network except rogue traitor ones
						continue
				if(istype(user, /mob/living/silicon/robot))
					if (R != user)
						continue
				if(R.scrambledcodes)
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
				if(issilicon(user) && ismalf(user)) //Malfs have a greater degree of digital control
					if(R.emagged == 2 && R.connected_ai == user)
						dat += "<font color=green>(Hacked)</font>"
						dat += "<A href='?src=\ref[src];magbot=\ref[R]'><font color=blue><i>Repair</i></font>)</A>"
					else if(R.emagged || !R.connected_ai == user) //Emagged or not connected to us
						dat += "<font color=red>(Out-of-control)</font>"
						dat += "<A href='?src=\ref[src];override=\ref[R]'>(<font color=blue><i>Take under control</i></font>)</A>"
					else //It's not emagged, show the option
						dat += "<A href='?src=\ref[src];magbot=\ref[R]'>(<font color=blue><i>Hack</i></font>)</A>"

				dat += {"<A href='?src=\ref[src];stopbot=\ref[R]'>(<font color=green><i>[R.canmove ? "Lockdown" : "Release"]</i></font>)</A>
					<A href='?src=\ref[src];lockbot=\ref[R]'>(<font color=orange><i>[R.modulelock ? "Module-unlock" : "Module-lock"]</i></font>)</A>
					<A href='?src=\ref[src];killbot=\ref[R]'>(<font color=red><i>Destroy</i></font>)</A>
					<BR>"}
			dat += "<A href='?src=\ref[src];screen=0'>(Return to Main Menu)</A><BR>"
		if(screen == 2)
			if(!src.status)
				dat += {"<BR><B>Emergency Robot Self-Destruct</B><HR>\nStatus: Off<BR>
				\n<BR>
				\nCountdown: [src.timeleft]/60 <A href='?src=\ref[src];reset=1'>\[Reset\]</A><BR>
				\n<BR>
				\n<A href='?src=\ref[src];eject=1'>Start Sequence</A><BR>
				\n<BR>
				\n<A href='?src=\ref[user];mach_close=computer'>Close</A>"}
			else
				dat = {"<B>Emergency Robot Self-Destruct</B><HR>\nStatus: Activated<BR>
				\n<BR>
				\nCountdown: [src.timeleft]/60 \[Reset\]<BR>
				\n<BR>\n<A href='?src=\ref[src];stop=1'>Stop Sequence</A><BR>
				\n<BR>
				\n<A href='?src=\ref[user];mach_close=computer'>Close</A>"}
			dat += "<A href='?src=\ref[src];screen=0'>(Return to Main Menu)</A><BR>"

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/robotics/Topic(href, href_list)
	if(..())
		return 1
	else
		usr.set_machine(src)

		if (href_list["eject"])
			src.temp = {"Destroy Robots?<BR>
			<BR><B><A href='?src=\ref[src];eject2=1'>\[Swipe ID to initiate destruction sequence\]</A></B><BR>
			<A href='?src=\ref[src];temp=1'>Cancel</A>"}

		else if (href_list["eject2"])
			var/obj/item/weapon/card/id/I = usr.get_active_hand()
			if (istype(I, /obj/item/device/pda))
				var/obj/item/device/pda/pda = I
				I = pda.id
			if (istype(I))
				if(src.check_access(I))
					if (!status)
						message_admins("<span class='notice'>[key_name_admin(usr)] has initiated the global cyborg killswitch!</span>")
						log_game("<span class='notice'>[key_name(usr)] has initiated the global cyborg killswitch!</span>")
						src.status = 1
						src.start_sequence()
						src.temp = null

				else
					to_chat(usr, "<span class='warning'>Access Denied.</span>")

		else if (href_list["stop"])
			src.temp = {"
			Stop Robot Destruction Sequence?<BR>
			<BR><A href='?src=\ref[src];stop2=1'>Yes</A><BR>
			<A href='?src=\ref[src];temp=1'>No</A>"}

		else if (href_list["stop2"])
			src.stop = 1
			src.temp = null
			src.status = 0

		else if (href_list["reset"])
			src.timeleft = 60

		else if (href_list["temp"])
			src.temp = null
		else if (href_list["screen"])
			switch(href_list["screen"])
				if("0")
					screen = 0
				if("1")
					screen = 1
				if("2")
					screen = 2
		else if (href_list["killbot"])
			if(src.allowed(usr))
				var/mob/living/silicon/robot/R = locate(href_list["killbot"])
				if(R)
					if(istype(usr, /mob/living/silicon/ai))
						if (R.connected_ai != usr && !ismalf(usr))
							return
					if(istype(usr, /mob/living/silicon/robot))
						if (R != usr)
							return
					if(R.scrambledcodes)
						return
					var/choice = input("Are you certain you wish to detonate [R.name]?") in list("Confirm", "Abort")
					if(choice == "Confirm")
						if(R && istype(R))
							if(ismalf(usr) && R.connected_ai == usr) //Malf AI can blow up its own borgs but not other malf AI's borgs
								if(R.self_destruct(1))
									message_admins("<span class='notice'>[key_name_admin(usr)] malf-detonated [R.name]!</span>")
									log_game("<span class='notice'>[key_name_admin(usr)] malf-detonated [R.name]!</span>")
								else
									to_chat(usr, "<span class='warning'>Despite the override, the console is unable to detonate [R.name]!</span>")
							else if(R.self_destruct())
								message_admins("<span class='notice'>[key_name_admin(usr)] detonated [R.name]!</span>")
								log_game("<span class='notice'>[key_name_admin(usr)] detonated [R.name]!</span>")
							else
								to_chat(usr, "<span class='warning'>The console is unable to detonate [R.name]!")
			else
				to_chat(usr, "<span class='warning'>Access Denied.</span>")
		else if (href_list["lockbot"])
			if(src.allowed(usr))
				var/mob/living/silicon/robot/R = locate(href_list["lockbot"])
				if(R && istype(R))
					if(istype(usr, /mob/living/silicon/ai))
						if (R.connected_ai != usr && !ismalf(usr))
							return
					if(istype(usr, /mob/living/silicon/robot))
						if (R != usr)
							return
					if(R.scrambledcodes)
						return
					var/choice = input("Are you certain you wish to [R.modulelock ? "module-unlock" : "module-lock"] [R.name]?") in list("Confirm", "Abort")
					if(choice == "Confirm")
						if(R && istype(R))
							if(R.emagged && !R.modulelock) //The robot will decline the module lockdown but will like a lift from it
								to_chat(usr, "<span class = 'warning'>The console flashes red. It was unable to module-lock the robot!</span>")
							else
								message_admins("<span class='notice'>[key_name_admin(usr)] [R.modulelock ? "module-unlocked" : "module-locked"] [R.name]!</span>")
								log_game("[key_name(usr)] [R.modulelock ? "module-unlocked" : "module-locked"] [R.name]!")
								R.toggle_modulelock()
								if (R.modulelock)
									to_chat(R, "<span class='info' style=\"font-family:Courier\">Your modules have been remotely locked!</span>")
								else
									to_chat(R, "<span class='info' style=\"font-family:Courier\">Your modules have been remotely unlocked!</span>")

			else
				to_chat(usr, "<span class='warning'>Access Denied.</span>")
		else if (href_list["stopbot"])
			if(src.allowed(usr))
				var/mob/living/silicon/robot/R = locate(href_list["stopbot"])
				if(R && istype(R)) // Extra sancheck because of input var references
					if(istype(usr, /mob/living/silicon/ai))
						if (R.connected_ai != usr && !ismalf(usr))
							return
					if(istype(usr, /mob/living/silicon/robot))
						if (R != usr)
							return
					if(R.scrambledcodes)
						return
					var/choice = input("Are you certain you wish to [R.canmove ? "lock down" : "release"] [R.name]?") in list("Confirm", "Abort")
					if(choice == "Confirm")
						if(R && istype(R))
							if(R.emagged && R.canmove ) //The robot will decline the lockdown but will like a lift from it
								to_chat(usr, "<span class = 'warning'>The console flashes red, it was unable to lock down the robot!</span>")
							else
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
			
		else if(href_list["override"])
			var/mob/living/silicon/robot/R = locate(href_list["override"])
			var/mob/living/silicon/ai = usr
			if(!istype(ai, /mob/living/silicon/ai))
				return
			if(R.robot_override(ai))
				to_chat(ai, "<span class='notice'>[R] has been subsumed.</span>")
				log_game("[key_name(usr)] has taken control of [R.name]!")
			else
				to_chat(ai, "<span class='warning'>Override blocked. The unit is subverted, or subservient to someone else.</span>")

		else if (href_list["magbot"])
			if(src.allowed(usr))
				var/mob/living/silicon/robot/R = locate(href_list["magbot"])
				if(R.scrambledcodes)
					return
				// whatever weirdness this is supposed to be, but that is how the href gets added, so here it is again
				if(istype(R) && istype(usr, /mob/living/silicon) && ismalf(usr) && (usr.mind.original == usr))
					if(R.emagged == 0)
						var/choice = input("Are you certain you wish to hack [R.name]?") in list("Confirm", "Abort")
						if(choice == "Confirm")
							if(R && istype(R) && !istraitor(R) && !R.emagged) //Double-check if the robot isn't a traitor or subverted mid-way through
								log_game("[key_name(usr)] emagged [R.name] using robotic console!")
								R.SetEmagged(2)
								to_chat(R, "<span class = 'danger'>Rogue module functionality activated.</span>")
					else //Disable the emag functions
						var/choice = input("Would you like to disable rogue modifications on [R.name]?") in list("Confirm", "Abort")
						if(choice == "Confirm") 
							if(R && istype(R) && !istraitor(R) && !R.emagged == 1)
								log_game("[key_name(usr)] disabled [R.name]'s emag status using robotic console!")
								R.SetEmagged(0)
								to_chat(R, "<span class = 'danger'>Rogue module functionality deactivated.</span>")

		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/robotics/proc/start_sequence()


	do
		if(src.stop)
			src.stop = 0
			return
		src.timeleft--
		sleep(10)
	while(src.timeleft)

	for(var/mob/living/silicon/robot/R in mob_list)
		if(!R.scrambledcodes)
			R.self_destruct()

	return

/obj/machinery/computer/robotics/emag(mob/user)
	..()
	req_access = list()
	if(user)
		to_chat(user, "You disable the console's access requirement.")