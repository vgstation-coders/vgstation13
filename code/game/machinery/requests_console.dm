/******************** Requests Console ********************/
/** Originally written by errorage, updated by: Carn, needs more work though. I just added some security fixes */

GLOBAL_LIST_EMPTY(req_console_assistance)
GLOBAL_LIST_EMPTY(req_console_supplies)
GLOBAL_LIST_EMPTY(req_console_information)
GLOBAL_LIST_EMPTY(allConsoles)

#define NO_NEW_MESSAGE				0
#define NORMAL_MESSAGE_PRIORITY 	1
#define HIGH_MESSAGE_PRIORITY		2
#define EXTREME_MESSAGE_PRIORITY	3 // not implemented, will probably require some hacking... everything needs to have a hidden feature in this game.

/obj/machinery/requests_console
	name = "requests console"
	desc = "A console intended to send requests to different departments on the station."
	anchored = TRUE
	icon = 'icons/obj/terminals.dmi'
	icon_state = "req_comp0"
	var/department = "Unknown" //The list of all departments on the station (Determined from this variable on each unit) Set this to the same thing if you want several consoles in one department
	var/list/messages = list() //List of all messages
	var/departmentType = 0
		// 0 = none (not listed, can only replied to)
		// 1 = assistance
		// 2 = supplies
		// 3 = info
		// 4 = ass + sup //Erro goddamn you just HAD to shorten "assistance" down to "ass"
		// 5 = ass + info
		// 6 = sup + info
		// 7 = ass + sup + info
	var/newmessagepriority = NO_NEW_MESSAGE
	var/screen = 0
		// 0 = main menu,
		// 1 = req. assistance,
		// 2 = req. supplies
		// 3 = relay information
		// 4 = write msg - not used
		// 5 = choose priority - not used
		// 6 = sent successfully
		// 7 = sent unsuccessfully
		// 8 = view messages
		// 9 = authentication before sending
		// 10 = send announcement
	var/silent = FALSE // set to 1 for it not to beep all the time
	var/hackState = FALSE
	var/announcementConsole = FALSE // FALSE = This console cannot be used to send department announcements, TRUE = This console can send department announcements
	var/open = FALSE // TRUE if open
	var/announceAuth = FALSE //Will be set to 1 when you authenticate yourself for announcements
	var/msgVerified = "" //Will contain the name of the person who verified it
	var/msgStamped = "" //If a message is stamped, this will contain the stamp name
	var/message = "";
	var/dpt = ""; //the department which will be receiving the message
	var/priority = -1 ; //Priority of the message being sent
	var/obj/item/device/radio/Radio
	var/emergency //If an emergency has been called by this device. Acts as both a cooldown and lets the responder know where it the emergency was triggered from
	var/receive_ore_updates = FALSE //If ore redemption machines will send an update when it receives new ores.
	max_integrity = 300
	armor = list("melee" = 70, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 90, "acid" = 90)

/obj/machinery/requests_console/power_change()
	..()
	update_icon()

/obj/machinery/requests_console/update_icon()
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(1.4,0.7,"#34D352")//green light
	if(open)
		if(!hackState)
			icon_state="req_comp_open"
		else
			icon_state="req_comp_rewired"
	else if(stat & NOPOWER)
		if(icon_state != "req_comp_off")
			icon_state = "req_comp_off"
	else
		if(emergency || (newmessagepriority == EXTREME_MESSAGE_PRIORITY))
			icon_state = "req_comp3"
		else if(newmessagepriority == HIGH_MESSAGE_PRIORITY)
			icon_state = "req_comp2"
		else if(newmessagepriority == NORMAL_MESSAGE_PRIORITY)
			icon_state = "req_comp1"
		else
			icon_state = "req_comp0"

/obj/machinery/requests_console/Initialize()
	. = ..()
	name = "\improper [department] requests console"
	GLOB.allConsoles += src
	switch(departmentType)
		if(1)
			if(!("[department]" in GLOB.req_console_assistance))
				GLOB.req_console_assistance += department
		if(2)
			if(!("[department]" in GLOB.req_console_supplies))
				GLOB.req_console_supplies += department
		if(3)
			if(!("[department]" in GLOB.req_console_information))
				GLOB.req_console_information += department
		if(4)
			if(!("[department]" in GLOB.req_console_assistance))
				GLOB.req_console_assistance += department
			if(!("[department]" in GLOB.req_console_supplies))
				GLOB.req_console_supplies += department
		if(5)
			if(!("[department]" in GLOB.req_console_assistance))
				GLOB.req_console_assistance += department
			if(!("[department]" in GLOB.req_console_information))
				GLOB.req_console_information += department
		if(6)
			if(!("[department]" in GLOB.req_console_supplies))
				GLOB.req_console_supplies += department
			if(!("[department]" in GLOB.req_console_information))
				GLOB.req_console_information += department
		if(7)
			if(!("[department]" in GLOB.req_console_assistance))
				GLOB.req_console_assistance += department
			if(!("[department]" in GLOB.req_console_supplies))
				GLOB.req_console_supplies += department
			if(!("[department]" in GLOB.req_console_information))
				GLOB.req_console_information += department

	Radio = new /obj/item/device/radio(src)
	Radio.listening = 0

/obj/machinery/requests_console/Destroy()
	QDEL_NULL(Radio)
	GLOB.allConsoles -= src
	return ..()

/obj/machinery/requests_console/ui_interact(mob/user)
	. = ..()
	var/dat = ""
	if(!open)
		switch(screen)
			if(1)	//req. assistance
				dat += "Which department do you need assistance from?<BR><BR>"
				dat += "<table width='100%'>"
				for(var/dpt in GLOB.req_console_assistance)
					if (dpt != department)
						dat += "<tr>"
						dat += "<td width='55%'>[dpt]</td>"
						dat += "<td width='45%'><A href='?src=[REF(src)];write=[ckey(dpt)]'>Normal</A> <A href='?src=[REF(src)];write=[ckey(dpt)];priority=2'>High</A>"
						if(hackState)
							dat += "<A href='?src=[REF(src)];write=[ckey(dpt)];priority=3'>EXTREME</A>"
						dat += "</td>"
						dat += "</tr>"
				dat += "</table>"
				dat += "<BR><A href='?src=[REF(src)];setScreen=0'><< Back</A><BR>"

			if(2)	//req. supplies
				dat += "Which department do you need supplies from?<BR><BR>"
				dat += "<table width='100%'>"
				for(var/dpt in GLOB.req_console_supplies)
					if (dpt != department)
						dat += "<tr>"
						dat += "<td width='55%'>[dpt]</td>"
						dat += "<td width='45%'><A href='?src=[REF(src)];write=[ckey(dpt)]'>Normal</A> <A href='?src=[REF(src)];write=[ckey(dpt)];priority=2'>High</A>"
						if(hackState)
							dat += "<A href='?src=[REF(src)];write=[ckey(dpt)];priority=3'>EXTREME</A>"
						dat += "</td>"
						dat += "</tr>"
				dat += "</table>"
				dat += "<BR><A href='?src=[REF(src)];setScreen=0'><< Back</A><BR>"

			if(3)	//relay information
				dat += "Which department would you like to send information to?<BR><BR>"
				dat += "<table width='100%'>"
				for(var/dpt in GLOB.req_console_information)
					if (dpt != department)
						dat += "<tr>"
						dat += "<td width='55%'>[dpt]</td>"
						dat += "<td width='45%'><A href='?src=[REF(src)];write=[ckey(dpt)]'>Normal</A> <A href='?src=[REF(src)];write=[ckey(dpt)];priority=2'>High</A>"
						if(hackState)
							dat += "<A href='?src=[REF(src)];write=[ckey(dpt)];priority=3'>EXTREME</A>"
						dat += "</td>"
						dat += "</tr>"
				dat += "</table>"
				dat += "<BR><A href='?src=[REF(src)];setScreen=0'><< Back</A><BR>"

			if(6)	//sent successfully
				dat += "<span class='good'>Message sent.</span><BR><BR>"
				dat += "<A href='?src=[REF(src)];setScreen=0'>Continue</A><BR>"

			if(7)	//unsuccessful; not sent
				dat += "<span class='bad'>An error occurred.</span><BR><BR>"
				dat += "<A href='?src=[REF(src)];setScreen=0'>Continue</A><BR>"

			if(8)	//view messages
				for (var/obj/machinery/requests_console/Console in GLOB.allConsoles)
					if (Console.department == department)
						Console.newmessagepriority = NO_NEW_MESSAGE
						Console.update_icon()

				newmessagepriority = NO_NEW_MESSAGE
				update_icon()
				var/messageComposite = ""
				for(var/msg in messages) // This puts more recent messages at the *top*, where they belong.
					messageComposite = "<div class='block'>[msg]</div>" + messageComposite
				dat += messageComposite
				dat += "<BR><A href='?src=[REF(src)];setScreen=0'><< Back to Main Menu</A><BR>"

			if(9)	//authentication before sending
				dat += "<B>Message Authentication</B><BR><BR>"
				dat += "<b>Message for [dpt]: </b>[message]<BR><BR>"
				dat += "<div class='notice'>You may authenticate your message now by scanning your ID or your stamp</div><BR>"
				dat += "<b>Validated by:</b> [msgVerified ? msgVerified : "<i>Not Validated</i>"]<br>"
				dat += "<b>Stamped by:</b> [msgStamped ? msgStamped : "<i>Not Stamped</i>"]<br><br>"
				dat += "<A href='?src=[REF(src)];department=[dpt]'>Send Message</A><BR>"
				dat += "<BR><A href='?src=[REF(src)];setScreen=0'><< Discard Message</A><BR>"

			if(10)	//send announcement
				dat += "<h3>Station-wide Announcement</h3>"
				if(announceAuth)
					dat += "<div class='notice'>Authentication accepted</div><BR>"
				else
					dat += "<div class='notice'>Swipe your card to authenticate yourself</div><BR>"
				dat += "<b>Message: </b>[message ? message : "<i>No Message</i>"]<BR>"
				dat += "<A href='?src=[REF(src)];writeAnnouncement=1'>[message ? "Edit" : "Write"] Message</A><BR><BR>"
				if ((announceAuth || IsAdminGhost(user)) && message)
					dat += "<A href='?src=[REF(src)];sendAnnouncement=1'>Announce Message</A><BR>"
				else
					dat += "<span class='linkOff'>Announce Message</span><BR>"
				dat += "<BR><A href='?src=[REF(src)];setScreen=0'><< Back</A><BR>"

			else	//main menu
				screen = 0
				announceAuth = FALSE
				if (newmessagepriority == NORMAL_MESSAGE_PRIORITY)
					dat += "<div class='notice'>There are new messages</div><BR>"
				if (newmessagepriority == HIGH_MESSAGE_PRIORITY)
					dat += "<div class='notice'>There are new <b>PRIORITY</b> messages</div><BR>"
				if (newmessagepriority == EXTREME_MESSAGE_PRIORITY)
					dat += "<div class='notice'>There are new <b>EXTREME PRIORITY</b> messages</div><BR>"
				dat += "<A href='?src=[REF(src)];setScreen=8'>View Messages</A><BR><BR>"

				dat += "<A href='?src=[REF(src)];setScreen=1'>Request Assistance</A><BR>"
				dat += "<A href='?src=[REF(src)];setScreen=2'>Request Supplies</A><BR>"
				dat += "<A href='?src=[REF(src)];setScreen=3'>Relay Anonymous Information</A><BR><BR>"

				if(!emergency)
					dat += "<A href='?src=[REF(src)];emergency=1'>Emergency: Security</A><BR>"
					dat += "<A href='?src=[REF(src)];emergency=2'>Emergency: Engineering</A><BR>"
					dat += "<A href='?src=[REF(src)];emergency=3'>Emergency: Medical</A><BR><BR>"
				else
					dat += "<B><font color='red'>[emergency] has been dispatched to this location.</font></B><BR><BR>"

				if(announcementConsole)
					dat += "<A href='?src=[REF(src)];setScreen=10'>Send Station-wide Announcement</A><BR><BR>"
				if (silent)
					dat += "Speaker <A href='?src=[REF(src)];setSilent=0'>OFF</A>"
				else
					dat += "Speaker <A href='?src=[REF(src)];setSilent=1'>ON</A>"
		var/datum/browser/popup = new(user, "req_console", "[department] Requests Console", 450, 440)
		popup.set_content(dat)
		popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
		popup.open()
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
			if (text2num(href_list["priority"]) < 2)
				priority = -1
			else
				priority = text2num(href_list["priority"])
		else
			dpt = "";
			msgVerified = ""
			msgStamped = ""
			screen = 0
			priority = -1

	if(href_list["writeAnnouncement"])
		var/new_message = copytext(reject_bad_text(input(usr, "Write your message:", "Awaiting Input", "")),1,MAX_MESSAGE_LEN)
		if(new_message)
			message = new_message
			if (text2num(href_list["priority"]) < 2)
				priority = -1
			else
				priority = text2num(href_list["priority"])
		else
			message = ""
			announceAuth = FALSE
			screen = 0

	if(href_list["sendAnnouncement"])
		if(!announcementConsole)
			return
		if(isliving(usr))
			var/mob/living/L = usr
			message = L.treat_message(message)
		minor_announce(message, "[department] Announcement:")
		GLOB.news_network.SubmitArticle(message, department, "Station Announcements", null)
		log_talk(usr,"[key_name(usr)] has made a station announcement: [message]",LOGSAY)
		message_admins("[key_name_admin(usr)] has made a station announcement.")
		announceAuth = FALSE
		message = ""
		screen = 0

	if(href_list["emergency"])
		if(!emergency)
			var/radio_freq
			switch(text2num(href_list["emergency"]))
				if(1) //Security
					radio_freq = FREQ_SECURITY
					emergency = "Security"
				if(2) //Engineering
					radio_freq = FREQ_ENGINEERING
					emergency = "Engineering"
				if(3) //Medical
					radio_freq = FREQ_MEDICAL
					emergency = "Medical"
			if(radio_freq)
				Radio.set_frequency(radio_freq)
				Radio.talk_into(src,"[emergency] emergency in [department]!!",radio_freq,get_spans(),get_default_language())
				update_icon()
				addtimer(CALLBACK(src, .proc/clear_emergency), 3000)

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
			var/pass = FALSE
			var/datum/data_rc_msg/log = new(href_list["department"], department, log_msg, msgStamped, msgVerified, priority)
			for (var/obj/machinery/telecomms/message_server/MS in GLOB.telecomms_list)
				if (MS.toggled)
					MS.rc_msgs += log
					pass = TRUE

			if(pass)
				var/radio_freq = 0
				switch(href_list["department"])
					if("bridge")
						radio_freq = FREQ_COMMAND
					if("medbay")
						radio_freq = FREQ_MEDICAL
					if("science")
						radio_freq = FREQ_SCIENCE
					if("engineering")
						radio_freq = FREQ_ENGINEERING
					if("security")
						radio_freq = FREQ_SECURITY
					if("cargobay" || "mining")
						radio_freq = FREQ_SUPPLY
				Radio.set_frequency(radio_freq)
				var/authentic
				if(msgVerified || msgStamped)
					authentic = " (Authenticated)"

				var/alert = ""
				for (var/obj/machinery/requests_console/Console in GLOB.allConsoles)
					if (ckey(Console.department) == ckey(href_list["department"]))
						switch(priority)
							if(2)		//High priority
								alert = "PRIORITY Alert in [department][authentic]"
								Console.createmessage(src, alert, sending, 2, 1)
							if(3)		// Extreme Priority
								alert = "EXTREME PRIORITY Alert from [department][authentic]"
								Console.createmessage(src, alert , sending, 3, 1)
							else		// Normal priority
								alert = "Message from [department][authentic]"
								Console.createmessage(src, alert , sending, 1, 1)
						screen = 6

				if(radio_freq)
					Radio.talk_into(src,"[alert]: <i>[message]</i>",radio_freq,get_spans(),get_default_language())

				switch(priority)
					if(2)
						messages += "<span class='bad'>High Priority</span><BR><b>To:</b> [dpt]<BR>[sending]"
					else
						messages += "<b>To: [dpt]</b><BR>[sending]"
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
		if(5)		//choose priority
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
			silent = TRUE
		else
			silent = FALSE

	updateUsrDialog()
	return

/obj/machinery/requests_console/say_mod(input, message_mode)
	var/ending = copytext(input, length(input) - 2)
	if (ending == "!!!")
		. = "blares"
	else
		. = ..()

/obj/machinery/requests_console/proc/clear_emergency()
	emergency = null
	update_icon()

/obj/machinery/requests_console/proc/createmessage(source, title, message, priority)
	var/linkedsender
	if(istype(source, /obj/machinery/requests_console))
		var/obj/machinery/requests_console/sender = source
		linkedsender = "<a href='?src=[REF(src)];write=[ckey(sender.department)]'>[sender.department]</a>"
	else
		capitalize(source)
		linkedsender = source
	capitalize(title)
	switch(priority)
		if(2)		//High priority
			if(newmessagepriority < HIGH_MESSAGE_PRIORITY)
				newmessagepriority = HIGH_MESSAGE_PRIORITY
				update_icon()
			if(!silent)
				playsound(src, 'sound/machines/twobeep.ogg', 50, 1)
				say(title)
				messages += "<span class='bad'>High Priority</span><BR><b>From:</b> [linkedsender]<BR>[message]"

		if(3)		// Extreme Priority
			if(newmessagepriority < EXTREME_MESSAGE_PRIORITY)
				newmessagepriority = EXTREME_MESSAGE_PRIORITY
				update_icon()
			if(1)
				playsound(src, 'sound/machines/twobeep.ogg', 50, 1)
				say(title)
			messages += "<span class='bad'>!!!Extreme Priority!!!</span><BR><b>From:</b> [linkedsender]<BR>[message]"

		else		// Normal priority
			if(newmessagepriority < NORMAL_MESSAGE_PRIORITY)
				newmessagepriority = NORMAL_MESSAGE_PRIORITY
				update_icon()
			if(!src.silent)
				playsound(src, 'sound/machines/twobeep.ogg', 50, 1)
				say(title)
			messages += "<b>From:</b> [linkedsender]<BR>[message]"

/obj/machinery/requests_console/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/crowbar))
		if(open)
			to_chat(user, "<span class='notice'>You close the maintenance panel.</span>")
			open = FALSE
		else
			to_chat(user, "<span class='notice'>You open the maintenance panel.</span>")
			open = TRUE
		update_icon()
		return
	if(istype(O, /obj/item/screwdriver))
		if(open)
			hackState = !hackState
			if(hackState)
				to_chat(user, "<span class='notice'>You modify the wiring.</span>")
			else
				to_chat(user, "<span class='notice'>You reset the wiring.</span>")
			update_icon()
		else
			to_chat(user, "<span class='warning'>You must open the maintenance panel first!</span>")
		return

	var/obj/item/card/id/ID = O.GetID()
	if(ID)
		if(screen == 9)
			msgVerified = "<font color='green'><b>Verified by [ID.registered_name] ([ID.assignment])</b></font>"
			updateUsrDialog()
		if(screen == 10)
			if (ACCESS_RC_ANNOUNCE in ID.access)
				announceAuth = TRUE
			else
				announceAuth = FALSE
				to_chat(user, "<span class='warning'>You are not authorized to send announcements!</span>")
			updateUsrDialog()
		return
	if (istype(O, /obj/item/stamp))
		if(screen == 9)
			var/obj/item/stamp/T = O
			msgStamped = "<span class='boldnotice'>Stamped with the [T.name]</span>"
			updateUsrDialog()
		return
	return ..()

#undef NO_NEW_MESSAGE
#undef NORMAL_MESSAGE_PRIORITY
#undef HIGH_MESSAGE_PRIORITY
#undef EXTREME_MESSAGE_PRIORITY
