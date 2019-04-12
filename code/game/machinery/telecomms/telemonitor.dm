


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

	var/datum/signal/trace_signal = null //for traceroute
	var/tracert_report = ""
	var/obj/machinery/telecomms/last_machine = null

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
				dat += {"<a href='?src=\ref[src];operation=release'>\[Flush Buffer\]</a><BR>
				<a href='?src=\ref[src];operation=tracert'>\[Traceroute\]</a><BR>
				<br>Detected Network Entities:<ul>"}
				for(var/obj/machinery/telecomms/T in machinelist)
					dat += "<li><a href='?src=\ref[src];viewmachine=[T.id]'>\ref[T] [T.name]</a> ([T.id])</li>"

				dat += "</ul>"
			else
				dat += "<a href='?src=\ref[src];operation=probe'>\[Probe Network\]</a>"


	  // --- Viewing Machine ---

		if(1)

			dat += {"<br>[temp]<br>
				<center><a href='?src=\ref[src];operation=mainmenu'>\[Main Menu\]</a></center>
				<br>Current Network: [network]<br>
				Selected Network Entity: [SelectedMachine.name] ([SelectedMachine.id])<br>
				Machine Integrity: [SelectedMachine.get_integrity() < 100 ? "<font color = #D70B00><b>[SelectedMachine.get_integrity()]%</b></font color>" : "<b>100%</b>"]<br>
				[SelectedMachine.stat & EMPED ? "<b>Local Interference Detected:</b><br>[SelectedMachine.emptime] seconds remaining <a href='?src=\ref[src];operation=boost'>\[Boost Signal\]</a><br>" : ""]
				Filtering Frequencies: [json_encode(SelectedMachine.freq_listening)]<br>
				Linked Entities: <ol>"}
			for(var/obj/machinery/telecomms/T in SelectedMachine.links)
				if(!T.hide)
					dat += "<li><a href='?src=\ref[src];viewmachine=[T.id]'>\ref[T.id] [T.name]</a> ([T.id])</li>"
			dat += "</ol>"


		if(2)
			dat += tracert_report
			dat += {"<br><a href='?src=\ref[src];operation=mainmenu'>\[Dismiss\]</a>"}

		if(3)
			dat += {"Warning: An unexpected device delinkage has occurred. Check network for damaged or missing hardware.
					<br><a href='?src=\ref[src];operation=mainmenu'>\[Dismiss\]</a>"}



	user << browse(dat, "window=comm_monitor;size=575x400")
	onclose(user, "server_control")

	temp = ""
	return

/obj/machinery/computer/telecomms/monitor/update_icon()
	if(stat)
		..() //Handles off or broken
	else
		icon_state = screen == 3 ? "network_unlinked" : "network_monitor" //Special icon if on screen 3

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
				update_icon()

			if("boost")
				if(SelectedMachine.boost_signal())
					temp = "<b>- SUCCESS: \[[SelectedMachine]\] SIGNAL AMPLIFIED -</b>"
				else
					temp = "<font color = #D70B00>- FAILED: NO LOCAL INTERFERENCE DETECTED -</font color>"

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

			if("tracert")
				if(!network)
					temp = "<font color = #D70B00>- ABORTED: VALID NETWORK REQUIRED TO TRACEROUTE -</font color>"
					updateUsrDialog()
					return
				if(trace_signal)
					temp = "<font color = #D70B00>- FAILED: CANNOT RUN CONCURRENT TRACEROUTE  -</font color>"
					updateUsrDialog()
					return
				var/freq = input(usr, "Which frequency would you like to trace?", "Comm Monitor", "1459") as null|num
				if(!freq || freq > 1599 || freq < 1201)
					temp = "<font color = #D70B00>- ABORTED: VALID FREQUENCY REQUIRED TO TRACEROUTE -</font color>"
					updateUsrDialog()
					return
				traceroute(freq)


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

/obj/machinery/computer/telecomms/monitor/proc/traceroute(var/freq)
	//First, generate a signal
	trace_signal = getFromPool(/datum/signal)
	trace_signal.data = list(
		"name" = "Telecommunications Network",
		"job" = "Machine",
		"level" = z,
		"trace" = src,
		"message" = "ping",
		"compression" = rand(45, 50),
		"traffic" = 0,
		"type" = 4,
		"reject" = 0,
		"done" = 0
	)
	trace_signal.frequency = freq
	trace_signal.transmission_method = 2
	screen = 2
	tracert_report = "Beginning tracert on [freq] at [worldtime2text()].<BR>EXPECTED NEXT: Receiver<BR>"
	for(var/obj/machinery/telecomms/receiver/R in telecomms_list)
		R.receive_signal(trace_signal)
	spawn(1 SECONDS)
		if(!trace_signal.data["done"])
			tracert_report += "The operation timed out.<BR><font color = #D70B00>Last Known Machine:</font color> <a href='?src=\ref[src];viewmachine=[last_machine.id]'>\ref[last_machine] [last_machine.id]</a>"
		returnToPool(trace_signal)
		trace_signal = null
		updateUsrDialog()

/obj/machinery/computer/telecomms/monitor/proc/receive_trace(var/obj/machinery/telecomms/T, var/routeinfo)
	tracert_report += "SIGNAL RECEIVED IN [T.id]. EXPECTED NEXT: [routeinfo].<BR>"
	last_machine = T
	updateUsrDialog()

/obj/machinery/computer/telecomms/monitor/attackby(var/obj/item/weapon/D as obj, var/mob/user as mob)
	if(..())
		return 1
	updateUsrDialog()

/obj/machinery/computer/telecomms/monitor/emag(mob/user)
	if(!emagged)
		playsound(src, 'sound/effects/sparks4.ogg', 75, 1)
		emagged = 1
		if(user)
			to_chat(user, "<span class='notice'>You disable the security protocols</span>")
		return 1
	return

/obj/machinery/computer/telecomms/monitor/proc/notify_unlinked()
	screen = 3
	update_icon()
	updateUsrDialog()