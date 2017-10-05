/obj/machinery/computer/telecomms/traffic
	name = "telecommunications traffic control console"
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "traffic_control"
	circuit = "/obj/item/weapon/circuitboard/comm_traffic"

	var/screen = 0				// the screen number:
	var/list/servers = list()	// the servers located by the computer
	var/mob/editingcode
	var/mob/lasteditor
	var/list/viewingcode = list()
	var/obj/machinery/telecomms/server/SelectedServer

	var/network = "NULL"		// the network to probe
	var/temp = ""				// temporary feedback messages

	var/storedcode = ""			// code stored
	var/obj/item/weapon/card/id/auth = null
	var/list/access_log = list()
	var/process = 0

	light_color = LIGHT_COLOR_ORANGE

	req_access = list(access_tcomsat)

/obj/machinery/computer/telecomms/traffic/proc/stop_editing()
	if(editingcode)
		if(editingcode.client)
			winshow(editingcode, "Telecomms IDE", 0) // hide the window!
		editingcode.unset_machine()
		editingcode = null

/obj/machinery/computer/telecomms/traffic/process()

	if(stat & (NOPOWER|BROKEN))
		stop_editing()
		return

	if(editingcode && editingcode.machine != src)
		stop_editing()
		return

	if(!editingcode)
		if(length(viewingcode) > 0)
			editingcode = pick(viewingcode)
			viewingcode.Remove(editingcode)
		return

	process = !process
	if(!process)
		return

	// loop if there's someone manning the keyboard
	if(!editingcode.client)
		stop_editing()
		return

	// For the typer, the input is enabled. Buffer the typed text
	if(!istype(editingcode))
		return
	storedcode = "[winget(editingcode, "tcscode", "text")]"
	winset(editingcode, "tcscode", "is-disabled=false")

	// If the player's not manning the keyboard anymore, adjust everything
	if(!in_range(src,editingcode) && !issilicon(editingcode) || editingcode.machine != src)
		winshow(editingcode, "Telecomms IDE", 0) // hide the window!
		editingcode = null
		return

	// For other people viewing the typer type code, the input is disabled and they can only view the code
	// (this is put in place so that there's not any magical shenanigans with 50 people inputting different code all at once)

	if(length(viewingcode))
		// This piece of code is very important - it escapes quotation marks so string aren't cut off by the input element
		var/showcode = replacetext(storedcode, "\\\"", "\\\\\"")
		showcode = replacetext(storedcode, "\"", "\\\"")

		for(var/mob/M in viewingcode)

			if( (M.machine == src && in_range(src,M) ) || issilicon(M))
				winset(M, "tcscode", "is-disabled=true")
				winset(M, "tcscode", "text=\"[showcode]\"")
			else
				viewingcode.Remove(M)
				winshow(M, "Telecomms IDE", 0) // hide the windows


/obj/machinery/computer/telecomms/traffic/attack_hand(mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return
	user.set_machine(src)
	var/dat = "<TITLE>Telecommunication Traffic Control</TITLE><center><b>Telecommunications Traffic Control</b></center>"

	dat += {"<br><b><font color='[(auth ? "green" : "red")]'>[(auth ? "AUTHED" : "NOT AUTHED")]:</font></b> <A href='?src=\ref[src];auth=1'>[(!auth ? "Insert ID" : auth.registered_name)]</A><BR>
		<A href='?src=\ref[src];print=1'>View System Log</A><HR>"}
	if(issilicon(user) || auth)

		switch(screen)


		  // --- Main Menu ---

			if(0)

				dat += {"<br>[temp]<br>
					<br>Current Network: <a href='?src=\ref[src];network=1'>[network]</a><br>"}
				if(servers.len)
					dat += "<br>Detected Telecommunication Servers:<ul>"
					for(var/obj/machinery/telecomms/T in servers)
						dat += "<li><a href='?src=\ref[src];viewserver=[T.id]'>\ref[T] [T.name]</a> ([T.id])</li>"

					dat += {"</ul>
						<br><a href='?src=\ref[src];operation=release'>\[Flush Buffer\]</a>"}
				else
					dat += "<br>No servers detected. Scan for servers: <a href='?src=\ref[src];operation=scan'>\[Scan\]</a>"


		  // --- Viewing Server ---

			if(1)
				if(SelectedServer)

					dat += {"<br>[temp]<br>
						<center><a href='?src=\ref[src];operation=mainmenu'>\[Main Menu\]</a>     <a href='?src=\ref[src];operation=refresh'>\[Refresh\]</a></center>
						<br>Current Network: [network]
						<br>Selected Server: [SelectedServer.id]<br><br>
						<br><a href='?src=\ref[src];operation=editcode'>\[Edit Code\]</a>
						<br>Signal Execution: "}
					if(SelectedServer.autoruncode)
						dat += "<a href='?src=\ref[src];operation=togglerun'>ALWAYS</a>"
					else
						dat += "<a href='?src=\ref[src];operation=togglerun'>NEVER</a>"
				else
					screen = 0
					return


	user << browse(dat, "window=traffic_control;size=575x400")
	onclose(user, "server_control")

	temp = ""
	return

/obj/machinery/computer/telecomms/traffic/proc/create_log(var/entry, var/mob/user)
	var/id = null
	if(issilicon(user))
		id = "System Administrator"
	else
		if(auth)
			id = "[auth.registered_name] ([auth.assignment])"
		else
			error("There is a null auth while the user isn't a silicon! ([user.name], [user.type])")
			return
	access_log += "\[[get_timestamp()]\] [id] [entry]"

/obj/machinery/computer/telecomms/traffic/proc/print_logs()
	. = "<center><h2>Traffic Control Telecomms System Log</h2></center><HR>"
	for(var/entry in access_log)
		. += entry + "<BR>"
	return .

/obj/machinery/computer/telecomms/traffic/Topic(href, href_list)
	if(..())
		return


	add_fingerprint(usr)
	usr.set_machine(src)

	if(href_list["auth"])
		if(iscarbon(usr))
			var/mob/living/carbon/C = usr
			if(!auth)
				var/obj/item/weapon/card/id/I = C.get_active_hand()
				if(istype(I))
					if(check_access(I))
						if(C.drop_item(I, src))
							auth = I
							create_log("has logged in.", usr)
			else
				create_log("has logged out.", usr)
				auth.forceMove(src.loc)
				C.put_in_hands(auth)
				auth = null
			updateUsrDialog()
			return

	if(href_list["print"])
		usr << browse(print_logs(), "window=traffic_logs")
		return

	if(!auth && !issilicon(usr) && !emagged)
		to_chat(usr, "<span class='warning'>ACCESS DENIED.</span>")
		return

	if(href_list["viewserver"])
		screen = 1
		for(var/obj/machinery/telecomms/T in servers)
			if(T.id == href_list["viewserver"])
				SelectedServer = T
				create_log("selected server [T.name]", usr)
				break


	if(href_list["operation"])
		create_log("has performed action: [href_list["operation"]].", usr)
		switch(href_list["operation"])

			if("release")
				servers = list()
				screen = 0

			if("mainmenu")
				screen = 0

			if("scan")
				if(servers.len > 0)
					temp = "<font color = #D70B00>- FAILED: CANNOT PROBE WHEN BUFFER FULL -</font color>"

				else
					for(var/obj/machinery/telecomms/server/T in range(25, src))
						if(T.network == network)
							servers.Add(T)

					if(!servers.len)
						temp = "<font color = #D70B00>- FAILED: UNABLE TO LOCATE SERVERS IN \[[network]\] -</font color>"
					else
						temp = "<font color = #336699>- [servers.len] SERVERS PROBED & BUFFERED -</font color>"

					screen = 0

			if("editcode")
				if(editingcode == usr)
					return
				if(usr in viewingcode)
					return

				if(!editingcode)
					lasteditor = usr
					editingcode = usr
					winshow(editingcode, "Telecomms IDE", 1) // show the IDE
					winset(editingcode, "tcscode", "is-disabled=false")
					winset(editingcode, "tcscode", "text=\"\"")
					var/showcode = replacetext(storedcode, "\\\"", "\\\\\"")
					showcode = replacetext(storedcode, "\"", "\\\"")
					winset(editingcode, "tcscode", "text=\"[showcode]\"")

				else
					viewingcode.Add(usr)
					winshow(usr, "Telecomms IDE", 1) // show the IDE
					winset(usr, "tcscode", "is-disabled=true")
					winset(editingcode, "tcscode", "text=\"\"")
					var/showcode = replacetext(storedcode, "\"", "\\\"")
					winset(usr, "tcscode", "text=\"[showcode]\"")

			if("togglerun")
				SelectedServer.autoruncode = !(SelectedServer.autoruncode)

	if(href_list["network"])

		var/newnet = input(usr, "Which network do you want to view?", "Comm Monitor", network) as null|text

		if(newnet && canAccess(usr))
			if(length(newnet) > 15)
				temp = "<font color = #D70B00>- FAILED: NETWORK TAG STRING TOO LENGHTLY -</font color>"

			else

				network = newnet
				screen = 0
				servers = list()
				temp = "<font color = #336699>- NEW NETWORK TAG SET IN ADDRESS \[[network]\] -</font color>"
				create_log("has set the network to [network].", usr)

	updateUsrDialog()
	return

/obj/machinery/computer/telecomms/traffic/attackby(var/obj/item/weapon/D as obj, var/mob/user as mob)
	return ..()

/obj/machinery/computer/telecomms/emag(mob/user)
	if(!emagged)
		playsound(get_turf(src), 'sound/effects/sparks4.ogg', 75, 1)
		emagged = 1
		to_chat(user, "<span class='notice'>You you disable the security protocols</span>")
	src.updateUsrDialog()
	return 1
/obj/machinery/computer/telecomms/traffic/proc/canAccess(var/mob/user)
	if(issilicon(user) || in_range(src,user))
		return 1
	return 0