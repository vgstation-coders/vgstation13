#define MAX_SHUTTLE_NAME_LEN

/obj/machinery/computer/shuttle_control
	name = "shuttle console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	req_access = null
	circuit = "/obj/item/weapon/circuitboard/mining_shuttle"

	machine_flags = EMAGGABLE | SCREWTOGGLE

	l_color = "#0000B4"

	var/datum/shuttle/shuttle

	var/obj/structure/docking_port/selected_port

/obj/machinery/computer/shuttle_control/New()
	if(shuttle)
		name = "[shuttle.name] console"

	.=..()

/obj/machinery/computer/shuttle_control/attack_hand(user as mob)
	if(..(user))
		return
	src.add_fingerprint(usr)
	var/shuttle_name = "Unknown shuttle"
	var/dat

	if(shuttle)
		shuttle_name = shuttle.name
		if(shuttle.lockdown)
			dat += "<h2><font color='red'>THIS SHUTTLE IS LOCKED DOWN</font></h2><br>"
			if(istext(shuttle.lockdown))
				dat += shuttle.lockdown
			else
				dat += "Additional information has not been provided."
		else
			if(shuttle.moving)
				if(shuttle.destination_port)
					dat += "<h3>Currently moving to [shuttle.destination_port.areaname]</h3>"
				else
					dat += "<h3>Currently moving</h3>"
			else
				dat += "Location: <b>[shuttle.current_port.areaname]</b><br>"
				dat += "Ready to move[max(shuttle.last_moved + shuttle.cooldown - world.time, 0) ? " in [max(round((shuttle.last_moved + shuttle.cooldown - world.time) * 0.1), 0)] seconds" : ": now"]<br>"

				//Write a list of all possible areas
				var/text
				for(var/obj/structure/docking_port/D in shuttle.docking_ports)
					if(D == shuttle.current_port)
						continue
					else
						text = D.areaname

					dat += " | [text]"

				dat += " |<BR>"
				dat += "<center>[shuttle_name]:<br> <b><A href='?src=\ref[src];move=[1]'>Send[selected_port ? " to [selected_port.areaname]" : ""]</A></b></center><BR>"
	else //No shuttle
		dat = "<h1>NO SHUTTLE LINKED</h1><br>"
		dat += "<a href='?src=\ref[src];link_to_shuttle=1'>Link to a shuttle</a>"

	if(isAdminGhost(user))
		dat += "<br><hr><br>"
		dat += "<b><font color='red'>SPECIAL OPTIONS</font></h1></b>"
		dat += "<i>These are only available to administrators. Abuse may result in fun.</i><br><br>"
		dat += "<a href='?src=\ref[src];admin_link_to_shuttle=1'>Link to a shuttle</a><br><i>This allows you to link this computer to any existing shuttle, even if it's normally impossible to do so.</i><br>"
		if(shuttle)
			dat += "<a href='?src=\ref[src];admin_unlink_shuttle=1'>Unlink current shuttle</a><br><i>Unlink this computer from [shuttle.name]</i><br>"
			dat += "<a href='?src=\ref[src];admin_toggle_lockdown=1'>Toggle lockdown</a><br>"

	user << browse("[dat]", "window=shuttle_control;size=575x450")

/obj/machinery/computer/shuttle_control/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["move"])
		if(shuttle)
			src.say("fuck you")

			src.updateUsrDialog()
	if(href_list["select"])
		var/obj/structure/docking_port/A = locate(href_list["select"])
		if(!A)
			return

		selected_port = A
		src.updateUsrDialog()
	if(href_list["link_to_shuttle"])
		var/list/L = list()
		for(var/datum/shuttle/S in shuttles)
			var/name = S.name
			switch(S.can_link_to_computer)
				if(LINK_PASSWORD_ONLY)
					name = "[name] (requires password)"
				if(LINK_FORBIDDEN)
					continue

			L += name
			L[name] = S

		var/choice = input(usr,"Select a shuttle to link this computer to", "Shuttle control console") in L as text|null
		if(!Adjacent(usr)) return
		if(L[choice] && istype(L[choice],/datum/shuttle))
			shuttle = L[choice]


	if(href_list["admin_link_to_shuttle"])
		if(!isAdminGhost(usr))
			usr << "You must be an admin for this"
			return

		var/list/L = list()
		for(var/datum/shuttle/S in shuttles)
			var/name = S.name
			switch(S.can_link_to_computer)
				if(LINK_PASSWORD_ONLY)
					name = "[name] (password)"
				if(LINK_FORBIDDEN)
					name = "[name] (private)"

			L += name
			L[name] = S

		var/choice = input(usr,"Select a shuttle to link this computer to", "Admin abuse") in L as text|null
		if(L[choice] && istype(L[choice],/datum/shuttle))
			shuttle = L[choice]

	if(href_list["admin_unlink_shuttle"])
		if(!isAdminGhost(usr))
			usr << "You must be an admin for this"
			return

		shuttle = null

	if(href_list["admin_toggle_lockdown"])
		if(!isAdminGhost(usr))
			usr << "You must be an admin for this"
			return

		if(!shuttle.lockdown)
			var/choice = input(usr,"Would you like to specify a reason?", "Admin abuse") in list("Yes","No","Cancel")

			if(choice == "Cancel")
				return

			shuttle.lockdown = 1
			if(choice == "Yes")
				shuttle.lockdown = input(usr,"Please write a reason for locking the [capitalize(shuttle.name)] down.", "Admin abuse")
		else
			shuttle.lockdown = 0

/obj/machinery/computer/shuttle_control/bullet_act(var/obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")

/obj/machinery/computer/shuttle_control/proc/link_to(var/datum/shuttle/S, var/add_to_list = 1)
	if(shuttle)
		if(src in shuttle.control_consoles)
			shuttle.control_consoles -= src

	shuttle = S
	if(add_to_list)
		shuttle.control_consoles |= src
	src.updateUsrDialog()
//Custom shuttles below

/obj/machinery/computer/shuttle_core
	name = "shuttle core computer"
	desc = ""
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttlecore"
	req_access = null
	circuit = "/obj/item/weapon/circuitboard/mining_shuttle"

	machine_flags = EMAGGABLE | SCREWTOGGLE
	l_color = "#00B400"

#undef MAX_SHUTTLE_NAME_LEN