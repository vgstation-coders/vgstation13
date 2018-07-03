/******************** Requests Console ********************/

var/req_console_assistance = list()
var/req_console_supplies = list()
var/req_console_information = list()
var/list/obj/machinery/requests_console/allConsoles = list()

/obj/machinery/requests_console
	name = "requests console"
	desc = "A console intended to send requests to various departments on the station."
	anchored = 1
	icon = 'icons/obj/terminals.dmi'
	icon_state = "req_comp0"
	var/department = "Unknown" //The list of all departments on the station (Determined from this variable on each unit) Set this to the same thing if you want several consoles in one department
	var/list/messages = list() //List of all messages
	var/departmentType = 0
		// 0 = none (not listed, can only repeplied to)
		// 1 = assistance
		// 2 = supplies
		// 3 = info
		// 4 = ass + sup //Erro goddamn you just HAD to shorten "assistance" down to "ass"
		// 5 = ass + info
		// 6 = sup + info
		// 7 = ass + sup + info
	var/newmessagepriority = 0
		// 0 = no new message
		// 1 = normal priority
		// 2 = high priority
		// 3 = extreme priority - not implemented, will probably require some hacking... everything needs to have a hidden feature in this game.
	var/screen = 0
		// 0 = main menu,
		// 1 = req. assistance,
		// 2 = req. supplies
		// 3 = relay information
		// 4 = write msg - not used
		// 5 = configure panel
		// 6 = sent successfully
		// 7 = sent unsuccessfully
		// 8 = view messages
		// 9 = authentication before sending
		// 10 = send announcement
	var/silent = 0 // set to 1 for it not to beep all the time
	var/hackState = 0
		// 0 = not hacked
		// 1 = hacked
	var/announcementConsole = 0
		// 0 = This console cannot be used to send department announcements
		// 1 = This console can send department announcementsf
	var/open = 0 // 1 if open
	var/announceAuth = 0 //Will be set to 1 when you authenticate yourself for announcements
	var/msgVerified = "" //Will contain the name of the person who varified it
	var/msgStamped = "" //If a message is stamped, this will contain the stamp name
	var/message = "";
	var/dpt = ""; //the department which will be receiving the message
	var/priority = -1 ; //Priority of the message being sent
	var/announceSound = 'sound/vox/bloop.wav'
	luminosity = 0

/obj/machinery/requests_console/power_change()
	..()
	update_icon()

/obj/machinery/requests_console/update_icon()
	if(stat & NOPOWER)
		if(icon_state != "req_comp_off")
			icon_state = "req_comp_off"
	else
		if(icon_state == "req_comp_off")
			icon_state = "req_comp0"

/obj/machinery/requests_console/New()
	allConsoles.Add(src)
	set_department(department,departmentType)
	return ..()

/obj/machinery/requests_console/proc/set_department(var/name, var/D)
	department = name
	departmentType = D
	name = "[department] Requests Console"
	if("[department]" in req_console_assistance)
		req_console_assistance -= department
	if("[department]" in req_console_supplies)
		req_console_supplies -= department
	if("[department]" in req_console_information)
		req_console_information -= department
	switch(departmentType)
		if(1)
			if(!("[department]" in req_console_assistance))
				req_console_assistance += department
		if(2)
			if(!("[department]" in req_console_supplies))
				req_console_supplies += department
		if(3)
			if(!("[department]" in req_console_information))
				req_console_information += department
		if(4)
			if(!("[department]" in req_console_assistance))
				req_console_assistance += department
			if(!("[department]" in req_console_supplies))
				req_console_supplies += department
		if(5)
			if(!("[department]" in req_console_assistance))
				req_console_assistance += department
			if(!("[department]" in req_console_information))
				req_console_information += department
		if(6)
			if(!("[department]" in req_console_supplies))
				req_console_supplies += department
			if(!("[department]" in req_console_information))
				req_console_information += department
		if(7)
			if(!("[department]" in req_console_assistance))
				req_console_assistance += department
			if(!("[department]" in req_console_supplies))
				req_console_supplies += department
			if(!("[department]" in req_console_information))
				req_console_information += department

/obj/machinery/requests_console/attack_hand(user as mob)
	if(..(user))
		return
	var/dat
	dat = text("<HEAD><TITLE>Requests Console</TITLE></HEAD><H3>[department] Requests Console</H3>")
	if(!open)
		switch(screen)
			if(1)	//req. assistance
				dat += text("Which department do you need assistance from?<BR><BR>")
				for(var/dpt in req_console_assistance)
					if (dpt != department)
						dat += text("[dpt] (<A href='?src=\ref[src];write=[ckey(dpt)]'>Message</A> or ")
						dat += text("<A href='?src=\ref[src];write=[ckey(dpt)];priority=2'>High Priority</A>")
//						if (hackState == 1)
//							dat += text(" or <A href='?src=\ref[src];write=[ckey(dpt)];priority=3'>EXTREME</A>)")
						dat += text(")<BR>")
				dat += text("<BR><A href='?src=\ref[src];setScreen=0'>Back</A><BR>")

			if(2)	//req. supplies
				dat += text("Which department do you need supplies from?<BR><BR>")
				for(var/dpt in req_console_supplies)
					if (dpt != department)
						dat += text("[dpt] (<A href='?src=\ref[src];write=[ckey(dpt)]'>Message</A> or ")
						dat += text("<A href='?src=\ref[src];write=[ckey(dpt)];priority=2'>High Priority</A>")
//						if (hackState == 1)
//							dat += text(" or <A href='?src=\ref[src];write=[ckey(dpt)];priority=3'>EXTREME</A>)")
						dat += text(")<BR>")
				dat += text("<BR><A href='?src=\ref[src];setScreen=0'>Back</A><BR>")

			if(3)	//relay information
				dat += text("Which department would you like to send information to?<BR><BR>")
				for(var/dpt in req_console_information)
					if (dpt != department)
						dat += text("[dpt] (<A href='?src=\ref[src];write=[ckey(dpt)]'>Message</A> or ")
						dat += text("<A href='?src=\ref[src];write=[ckey(dpt)];priority=2'>High Priority</A>")
//						if (hackState == 1)
//							dat += text(" or <A href='?src=\ref[src];write=[ckey(dpt)];priority=3'>EXTREME</A>)")
						dat += text(")<BR>")
				dat += text("<BR><A href='?src=\ref[src];setScreen=0'>Back</A><BR>")
			if(5)   //configure panel
				dat += text("<B>Configure Panel</B><BR><BR>")
				if(announceAuth)
					dat += text("<b>Authentication accepted</b><BR><BR>")
				else
					dat += text("Swipe your card to authenticate yourself.<BR><BR>")
				if (announceAuth)
					dat += text("Configure department. Set to 0 to release internal locks for deconstruction.<BR><BR>")
					dat += text("<A href='?src=\ref[src];setDepartment=0'>No Contact</A><BR>")
					dat += text("<A href='?src=\ref[src];setDepartment=1'>Assistance</A><BR>")
					dat += text("<A href='?src=\ref[src];setDepartment=2'>Supply</A><BR>")
					dat += text("<A href='?src=\ref[src];setDepartment=3'>Anonymous Tip Recipient</A><BR>")
					dat += text("<A href='?src=\ref[src];setDepartment=4'>Assistance + Supply</A><BR>")
					dat += text("<A href='?src=\ref[src];setDepartment=5'>Assistance + Tips</A><BR>")
					dat += text("<A href='?src=\ref[src];setDepartment=6'>Supply + Tips</A><BR>")
					dat += text("<A href='?src=\ref[src];setDepartment=7'>All</A><BR>")
				dat += text("<BR><A href='?src=\ref[src];setScreen=0'>Back</A><BR>")
			if(6)	//sent successfully
				dat += text("<FONT COLOR='GREEN'>Message sent</FONT><BR><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=0'>Continue</A><BR>")

			if(7)	//unsuccessful; not sent
				dat += text("<FONT COLOR='RED'>An error occurred. </FONT><BR><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=0'>Continue</A><BR>")

			if(8)	//view messages
				for (var/obj/machinery/requests_console/Console in allConsoles)
					if (Console.department == department)
						Console.newmessagepriority = 0
						Console.icon_state = "req_comp0"
						Console.set_light(1)
				newmessagepriority = 0
				icon_state = "req_comp0"
				for(var/msg in messages)
					dat += text("[msg]<BR>")
				dat += text("<A href='?src=\ref[src];setScreen=0'>Back to main menu</A><BR>")

			if(9)	//authentication before sending
				dat += text("<B>Message Authentication</B><BR><BR>")
				dat += text("<b>Message for [dpt]: </b>[message]<BR><BR>")
				dat += text("You may authenticate your message now by scanning your ID or your stamp<BR><BR>")
				dat += text("Validated by: [msgVerified]<br>");
				dat += text("Stamped by: [msgStamped]<br>");
				dat += text("<A href='?src=\ref[src];department=[dpt]'>Send</A><BR>");
				dat += text("<BR><A href='?src=\ref[src];setScreen=0'>Back</A><BR>")

			if(10)	//send announcement
				dat += text("<B>Station wide announcement</B><BR><BR>")
				if(announceAuth)
					dat += text("<b>Authentication accepted</b><BR><BR>")
				else
					dat += text("Swipe your card to authenticate yourself.<BR><BR>")
				dat += text("<b>Message: </b>[message] <A href='?src=\ref[src];writeAnnouncement=1'>Write</A><BR><BR>")
				if (announceAuth && message)
					dat += text("<A href='?src=\ref[src];sendAnnouncement=1'>Announce</A><BR>");
				dat += text("<BR><A href='?src=\ref[src];setScreen=0'>Back</A><BR>")

			else	//main menu
				screen = 0
				announceAuth = 0
				if (newmessagepriority == 1)
					dat += text("<FONT COLOR='RED'>There are new messages</FONT><BR>")
				if (newmessagepriority == 2)
					dat += text("<FONT COLOR='RED'><B>NEW PRIORITY MESSAGES</B></FONT><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=8'>View Messages</A><BR><BR>")

				dat += text("<A href='?src=\ref[src];setScreen=1'>Request Assistance</A><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=2'>Request Supplies</A><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=3'>Relay Anonymous Information</A><BR><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=5'>Configure Panel</A><BR><BR>")
				if(announcementConsole)
					dat += text("<A href='?src=\ref[src];setScreen=10'>Send station-wide announcement</A><BR><BR>")
				if (silent)
					dat += text("Speaker <A href='?src=\ref[src];setSilent=0'>OFF</A>")
				else
					dat += text("Speaker <A href='?src=\ref[src];setSilent=1'>ON</A>")

		user << browse("[dat]", "window=request_console")
		onclose(user, "req_console")
	return

/obj/machinery/requests_console/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)

	if(reject_bad_text(href_list["write"]))
		dpt = ckey(href_list["write"]) //write contains the string of the receiving department's name

		var/new_message = copytext(reject_bad_text(input(usr, "Write your message:", "Awaiting Input", "")),1,MAX_MESSAGE_LEN)
		if(new_message)
			message = new_message
			screen = 9
			switch(href_list["priority"])
				if("2")
					priority = 2
				else
					priority = -1
		else
			to_chat(usr, "<span class='warning'>Invalid characters found in the text.</span>")
			dpt = "";
			msgVerified = ""
			msgStamped = ""
			screen = 0
			priority = -1

	if(href_list["writeAnnouncement"])
		var/new_message = copytext(reject_bad_text(input(usr, "Write your message:", "Awaiting Input", "")),1,MAX_MESSAGE_LEN)
		if(new_message)
			message = new_message
			switch(href_list["priority"])
				if("2")
					priority = 2
				else
					priority = -1
		else
			to_chat(usr, "<span class='warning'>Invalid characters found in the text.</span>")
			message = ""
			announceAuth = 0
			screen = 0

	if(href_list["sendAnnouncement"])
		make_announcement(message)

	if( href_list["department"] && message )
		var/log_msg = message
		var/sending = message
		sending += "<br>"
		if (msgVerified)
			sending += msgVerified
			sending += "<br>"
		if (msgStamped)
			sending += msgStamped
			sending += "<br>"
		screen = 7 //if it's successful, this will get overrwritten (7 = unsufccessfull, 6 = successfull)
		if (sending)
			var/pass = 0
			for (var/obj/machinery/message_server/MS in message_servers)
				if(!MS.is_functioning())
					continue
				MS.send_rc_message(href_list["department"],department,log_msg,msgStamped,msgVerified,priority)
				log_rc("[key_name(usr)] sent a message through \the [src] ([department]) to [href_list["department"]]. Message: \"[log_msg]\". Stamped: [msgStamped || "No"]. Verified: [msgVerified || "No"]. Prority: [priority]")
				pass = 1

			if(pass)

				for (var/obj/machinery/requests_console/Console in allConsoles)
					if (ckey(Console.department) == ckey(href_list["department"]))

						switch(priority)
							if(2)		//High priority
								if(Console.newmessagepriority < 2)
									Console.newmessagepriority = 2
									Console.icon_state = "req_comp3"
								if(!Console.silent)
									playsound(Console.loc, 'sound/machines/request_urgent.ogg', 50, 1)
									say("PRIORITY Alert in [department]")
								Console.messages += "<B><FONT color='red'>High Priority message from <A href='?src=\ref[Console];write=[ckey(department)]'>[department]</A></FONT></B><BR>[sending]"

		//					if("3")		//Not implemanted, but will be 		//Removed as it doesn't look like anybody intends on implimenting it ~Carn
		//						if(Console.newmessagepriority < 3)
		//							Console.newmessagepriority = 3
		//							Console.icon_state = "req_comp3"
		//						if(!Console.silent)
		//							playsound(Console.loc, 'sound/machines/twobeep.ogg', 50, 1)
		//							for (var/mob/O in hearers(7, Console.loc))
		//								O.show_message(text("[bicon(Console)] *The Requests Console yells: 'EXTREME PRIORITY alert in [department]'"))
		//						Console.messages += "<B><FONT color='red'>Extreme Priority message from [ckey(department)]</FONT></B><BR>[message]"

							else		// Normal priority
								if(Console.newmessagepriority < 1)
									Console.newmessagepriority = 1
									Console.icon_state = "req_comp2"
								if(!Console.silent)
									playsound(Console.loc, 'sound/machines/request.ogg', 50, 1)
									say("Message from [department]")
								Console.messages += "<B>Message from <A href='?src=\ref[Console];write=[ckey(department)]'>[department]</A></FONT></B><BR>[message]"

						screen = 6
						Console.set_light(2)
				messages += "<B>Message sent to [dpt]</B><BR>[message]"
			else
				say("NOTICE: No server detected!")


	//Handle screen switching
	switch(text2num(href_list["setScreen"]))
		if(null)	//skip
		if(1)		//req. assistance
			screen = 1
		if(2)		//req. supplies
			screen = 2
		if(3)		//relay information
			screen = 3
//		if(4)		//write message
//			screen = 4
		if(5)		//configure
			screen = 5
		if(6)		//sent successfully
			screen = 6
		if(7)		//unsuccessfull; not sent
			screen = 7
		if(8)		//view messages
			screen = 8
		if(9)		//authentication
			screen = 9
		if(10)		//send announcement
			if(!announcementConsole)
				return
			screen = 10
		else		//main menu
			dpt = ""
			msgVerified = ""
			msgStamped = ""
			message = ""
			priority = -1
			screen = 0

	//Handle silencing the console
	switch( href_list["setSilent"] )
		if(null)	//skip
		if("1")
			silent = 1
		else
			silent = 0

	switch( href_list["setDepartment"] )
		if(null)	//skip
		else
			var/name = reject_bad_text(input(usr,"Name:","Name this department.","Public") as null|text)
			set_department(name,text2num(href_list["setDepartment"]))

	updateUsrDialog()
	return

/obj/machinery/say_quote(var/text)
	var/ending = copytext(text, length(text) - 2)
	if(ending == "!!!")
		return "blares, [text]"

	return "beeps, [text]"

/obj/machinery/requests_console/proc/make_announcement(msg, mob/user = usr)
	if(!announcementConsole)
		return

	for(var/mob/M in player_list)
		if(!istype(M,/mob/new_player) && M.client)
			to_chat(M, "<b><font size = 3><font color = red>[department] announcement:</font color> [msg]</font size></b>")
			M << sound(announceSound)
	log_say("[key_name(user)] ([formatJumpTo(get_turf(user))]) has made an announcement from \the [src]: [msg]")
	message_admins("[key_name_admin(user)] has made an announcement from \the [src].", 1)
	announceAuth = 0
	message = ""
	screen = 0

/obj/machinery/requests_console/npc_tamper_act(mob/living/L)
	if(announcementConsole && isgremlin(L) && prob(10)) //10% chance per use to generate an announcement
		var/mob/living/simple_animal/hostile/gremlin/G = L
		var/msg = G.generate_markov_chain()

		if(msg)
			make_announcement(msg, G)

					//deconstruction and hacking
/obj/machinery/requests_console/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if (iscrowbar(O))
		if(open)
			open = 0
			icon_state="req_comp0"
		else
			open = 1
			if(!hackState)
				icon_state="req_comp_open"
			else
				icon_state="req_comp_rewired"
	if (isscrewdriver(O))
		if(open)
			if(!hackState)
				hackState = 1
				icon_state="req_comp_rewired"
			else
				hackState = 0
				icon_state="req_comp_open"
		else
			to_chat(user, "You can't do much with that.")
	if(iswrench(O) && open && !departmentType)
		user.visible_message("<span class='notice'>[user] disassembles the [src]!</span>", "<span class='notice'>You disassemble the [src]</span>")
		playsound(src, 'sound/items/Ratchet.ogg', 100, 1)
		new /obj/item/stack/sheet/metal (src.loc,2)
		qdel(src)
		return
	if (istype(O, /obj/item/weapon/card/id) || istype(O, /obj/item/device/pda))
		if(screen == 5)
			var/obj/item/weapon/card/id/ID = O.GetID()
			if (hackState || ID.access.Find(access_engine_equip))
				announceAuth = 1
			else
				announceAuth = 0
				to_chat(user, "<span class='warning'>You are not authorized to configure this panel.</span>")
			updateUsrDialog()
		if(screen == 9)
			var/obj/item/weapon/card/id/ID = O.GetID()
			msgVerified = "<font color='green'><b>Verified by [ID.registered_name] ([ID.assignment])</b></font>"
			updateUsrDialog()
		if (screen == 10)
			var/obj/item/weapon/card/id/ID = O.GetID()

			if (!isnull(ID) && ID.access.Find(access_RC_announce) || hackState)
				announceAuth = TRUE
			else
				announceAuth = FALSE
				to_chat(user, "<span class='warning'>You are not authorized to send announcements.</span>")

			updateUsrDialog()
	if (istype(O, /obj/item/weapon/stamp))
		if(screen == 9)
			var/obj/item/weapon/stamp/T = O
			msgStamped = text("<font color='blue'><b>Stamped with the [T.name]</b></font>")
			updateUsrDialog()
	return

/obj/machinery/requests_console/mechanic
	name = "\improper Mechanics requests console"
	department = "Mechanics"
	departmentType = 4
