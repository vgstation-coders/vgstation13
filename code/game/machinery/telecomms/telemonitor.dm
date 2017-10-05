


/*
	Telecomms monitor tracks the overall trafficing of a telecommunications network
	and displays a heirarchy of linked machines.
*/


/obj/machinery/computer/telecomms/monitor
	name = "telecommunications network monitoring console"
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "network_monitor"
	circuit = "/obj/item/weapon/circuitboard/comm_monitor"

	var/screen = 0				// the screen number:
	var/list/machinelist = list()	// the machines located by the computer
	var/obj/machinery/telecomms/SelectedMachine

	var/network = "NULL"		// the network to probe

	var/temp = ""				// temporary feedback messages

	light_color = LIGHT_COLOR_GREEN

/obj/machinery/computer/telecomms/monitor/attack_hand(mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return
	user.set_machine(src)
	var/dat = "<TITLE>Telecommunications Monitor</TITLE><center><b>Telecommunications Monitor</b></center>"

	switch(screen)


	  // --- Main Menu ---

		if(0)

			dat += {"<br>[temp]<br><br>
				<br>Current Network: <a href='?src=\ref[src];network=1'>[network]</a><br>"}
			if(machinelist.len)
				dat += "<br>Detected Network Entities:<ul>"
				for(var/obj/machinery/telecomms/T in machinelist)
					dat += "<li><a href='?src=\ref[src];viewmachine=[T.id]'>\ref[T] [T.name]</a> ([T.id])</li>"

				dat += {"</ul>
					<br><a href='?src=\ref[src];operation=release'>\[Flush Buffer\]</a>"}
			else
				dat += "<a href='?src=\ref[src];operation=probe'>\[Probe Network\]</a>"


	  // --- Viewing Machine ---

		if(1)

			dat += {"<br>[temp]<br>
				<center><a href='?src=\ref[src];operation=mainmenu'>\[Main Menu\]</a></center>
				<br>Current Network: [network]<br>
				Selected Network Entity: [SelectedMachine.name] ([SelectedMachine.id])<br>
				Linked Entities: <ol>"}
			for(var/obj/machinery/telecomms/T in SelectedMachine.links)
				if(!T.hide)
					dat += "<li><a href='?src=\ref[src];viewmachine=[T.id]'>\ref[T.id] [T.name]</a> ([T.id])</li>"
			dat += "</ol>"



	user << browse(dat, "window=comm_monitor;size=575x400")
	onclose(user, "server_control")

	temp = ""
	return


/obj/machinery/computer/telecomms/monitor/Topic(href, href_list)
	if(..())
		return


	add_fingerprint(usr)
	usr.set_machine(src)

	if(href_list["viewmachine"])
		screen = 1
		for(var/obj/machinery/telecomms/T in machinelist)
			if(T.id == href_list["viewmachine"])
				SelectedMachine = T
				break

	if(href_list["operation"])
		switch(href_list["operation"])

			if("release")
				machinelist = list()
				screen = 0

			if("mainmenu")
				screen = 0

			if("probe")
				if(machinelist.len > 0)
					temp = "<font color = #D70B00>- FAILED: CANNOT PROBE WHEN BUFFER FULL -</font color>"

				else
					for(var/obj/machinery/telecomms/T in range(25, src))
						if(T.network == network)
							machinelist.Add(T)

					if(!machinelist.len)
						temp = "<font color = #D70B00>- FAILED: UNABLE TO LOCATE NETWORK ENTITIES IN \[[network]\] -</font color>"
					else
						temp = "<font color = #336699>- [machinelist.len] ENTITIES LOCATED & BUFFERED -</font color>"

					screen = 0


	if(href_list["network"])

		var/newnet = input(usr, "Which network do you want to view?", "Comm Monitor", network) as null|text
		if(newnet && ((usr in range(1, src) || issilicon(usr))))
			if(length(newnet) > 15)
				temp = "<font color = #D70B00>- FAILED: NETWORK TAG STRING TOO LENGHTLY -</font color>"

			else
				network = newnet
				screen = 0
				machinelist = list()
				temp = "<font color = #336699>- NEW NETWORK TAG SET IN ADDRESS \[[network]\] -</font color>"

	updateUsrDialog()
	return

/obj/machinery/computer/telecomms/monitor/attackby(var/obj/item/weapon/D as obj, var/mob/user as mob)
	if(..())
		return 1
	src.updateUsrDialog()

/obj/machinery/computer/telecomms/monitor/emag(mob/user)
	if(!emagged)
		playsound(get_turf(src), 'sound/effects/sparks4.ogg', 75, 1)
		emagged = 1
		to_chat(user, "<span class='notice'>You you disable the security protocols</span>")
		return 1
	return
