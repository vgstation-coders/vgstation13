// The communications computer
/obj/machinery/computer/communications
	name = "communications console"
	desc = "A console used for high-priority announcements and emergencies."
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_HEADS)
	circuit = /obj/item/circuitboard/computer/communications
	var/authenticated = 0
	var/auth_id = "Unknown" //Who is currently logged in?
	var/list/datum/comm_message/messages = list()
	var/datum/comm_message/currmsg
	var/datum/comm_message/aicurrmsg
	var/state = STATE_DEFAULT
	var/aistate = STATE_DEFAULT
	var/message_cooldown = 0
	var/ai_message_cooldown = 0
	var/tmp_alertlevel = 0
	var/const/STATE_DEFAULT = 1
	var/const/STATE_CALLSHUTTLE = 2
	var/const/STATE_CANCELSHUTTLE = 3
	var/const/STATE_MESSAGELIST = 4
	var/const/STATE_VIEWMESSAGE = 5
	var/const/STATE_DELMESSAGE = 6
	var/const/STATE_STATUSDISPLAY = 7
	var/const/STATE_ALERT_LEVEL = 8
	var/const/STATE_CONFIRM_LEVEL = 9
	var/const/STATE_TOGGLE_EMERGENCY = 10
	var/const/STATE_PURCHASE = 11

	var/stat_msg1
	var/stat_msg2

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/communications/proc/checkCCcooldown()
	var/obj/item/circuitboard/computer/communications/CM = circuit
	if(CM.lastTimeUsed + 600 > world.time)
		return FALSE
	return TRUE

/obj/machinery/computer/communications/Initialize()
	. = ..()
	GLOB.shuttle_caller_list += src

/obj/machinery/computer/communications/process()
	if(..())
		if(state != STATE_STATUSDISPLAY && state != STATE_CALLSHUTTLE && state != STATE_PURCHASE)
			updateDialog()

/obj/machinery/computer/communications/Topic(href, href_list)
	if(..())
		return
	if(!is_station_level(z) && !is_centcom_level(z)) //Can only use on centcom and SS13
		to_chat(usr, "<span class='boldannounce'>Unable to establish a connection</span>: \black You're too far away from the station!")
		return
	usr.set_machine(src)

	var/area/A = get_area(usr)
	var/area_name = A.name

	if(!href_list["operation"])
		return
	var/obj/item/circuitboard/computer/communications/CM = circuit
	switch(href_list["operation"])
		// main interface
		if("main")
			state = STATE_DEFAULT
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		if("login")
			var/mob/M = usr

			var/obj/item/card/id/I = M.get_active_held_item()
			if(!istype(I))
				I = M.get_idcard()

			if(I && istype(I))
				if(check_access(I))
					authenticated = 1
					auth_id = "[I.registered_name] ([I.assignment])"
					if((20 in I.access))
						authenticated = 2
					playsound(src, 'sound/machines/terminal_on.ogg', 50, 0)
				if(obj_flags & EMAGGED)
					authenticated = 2
					auth_id = "Unknown"
					to_chat(M, "<span class='warning'>[src] lets out a quiet alarm as its login is overriden.</span>")
					playsound(src, 'sound/machines/terminal_on.ogg', 50, 0)
					playsound(src, 'sound/machines/terminal_alert.ogg', 25, 0)
					if(prob(25))
						for(var/mob/living/silicon/ai/AI in active_ais())
							SEND_SOUND(AI, sound('sound/machines/terminal_alert.ogg', volume = 10)) //Very quiet for balance reasons
		if("logout")
			authenticated = 0
			playsound(src, 'sound/machines/terminal_off.ogg', 50, 0)

		if("swipeidseclevel")
			var/mob/M = usr
			var/obj/item/card/id/I = M.get_active_held_item()
			if (istype(I, /obj/item/device/pda))
				var/obj/item/device/pda/pda = I
				I = pda.id
			if (I && istype(I))
				if(ACCESS_CAPTAIN in I.access)
					var/old_level = GLOB.security_level
					if(!tmp_alertlevel)
						tmp_alertlevel = SEC_LEVEL_GREEN
					if(tmp_alertlevel < SEC_LEVEL_GREEN)
						tmp_alertlevel = SEC_LEVEL_GREEN
					if(tmp_alertlevel > SEC_LEVEL_BLUE)
						tmp_alertlevel = SEC_LEVEL_BLUE //Cannot engage delta with this
					set_security_level(tmp_alertlevel)
					if(GLOB.security_level != old_level)
						to_chat(usr, "<span class='notice'>Authorization confirmed. Modifying security level.</span>")
						playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
						//Only notify people if an actual change happened
						var/security_level = get_security_level()
						log_game("[key_name(usr)] has changed the security level to [security_level].")
						message_admins("[key_name_admin(usr)] has changed the security level to [security_level].")
						deadchat_broadcast("<span class='deadsay'><span class='name'>[usr.name]</span> has changed the security level to [security_level] at <span class='name'>[area_name]</span>.</span>", usr)
					tmp_alertlevel = 0
				else
					to_chat(usr, "<span class='warning'>You are not authorized to do this!</span>")
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
					tmp_alertlevel = 0
				state = STATE_DEFAULT
			else
				to_chat(usr, "<span class='warning'>You need to swipe your ID!</span>")
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)

		if("announce")
			if(authenticated==2)
				playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
				make_announcement(usr)

		if("crossserver")
			if(authenticated==2)
				if(!checkCCcooldown())
					to_chat(usr, "<span class='warning'>Arrays recycling.  Please stand by.</span>")
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
					return
				var/input = stripped_multiline_input(usr, "Please choose a message to transmit to allied stations.  Please be aware that this process is very expensive, and abuse will lead to... termination.", "Send a message to an allied station.", "")
				if(!input || !(usr in view(1,src)) || !checkCCcooldown())
					return
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
				send2otherserver("[station_name()]", input,"Comms_Console")
				minor_announce(input, title = "Outgoing message to allied station")
				log_talk(usr,"[key_name(usr)] has sent a message to the other server: [input]",LOGSAY)
				message_admins("[key_name_admin(usr)] has sent a message to the other server.")
				deadchat_broadcast("<span class='deadsay bold'>[usr.name] has sent an outgoing message to the other station(s).</span>", usr)
				CM.lastTimeUsed = world.time

		if("purchase_menu")
			state = STATE_PURCHASE

		if("buyshuttle")
			if(authenticated==2)
				var/list/shuttles = flatten_list(SSmapping.shuttle_templates)
				var/datum/map_template/shuttle/S = locate(href_list["chosen_shuttle"]) in shuttles
				if(S && istype(S))
					if(SSshuttle.emergency.mode != SHUTTLE_RECALL && SSshuttle.emergency.mode != SHUTTLE_IDLE)
						to_chat(usr, "It's a bit late to buy a new shuttle, don't you think?")
						return
					if(SSshuttle.shuttle_purchased)
						to_chat(usr, "A replacement shuttle has already been purchased.")
					else if(!S.prerequisites_met())
						to_chat(usr, "You have not met the requirements for purchasing this shuttle.")
					else
						if(SSshuttle.points >= S.credit_cost)
							var/obj/machinery/shuttle_manipulator/M = locate() in GLOB.machines
							if(M)
								SSshuttle.shuttle_purchased = TRUE
								M.unload_preview()
								M.load_template(S)
								M.existing_shuttle = SSshuttle.emergency
								M.action_load(S)
								SSshuttle.points -= S.credit_cost
								minor_announce("[usr.name] has purchased [S.name] for [S.credit_cost] credits." , "Shuttle Purchase")
								message_admins("[key_name_admin(usr)] purchased [S.name].")
								SSblackbox.record_feedback("text", "shuttle_purchase", 1, "[S.name]")
							else
								to_chat(usr, "Something went wrong! The shuttle exchange system seems to be down.")
						else
							to_chat(usr, "Not enough credits.")

		if("callshuttle")
			state = STATE_DEFAULT
			if(authenticated)
				state = STATE_CALLSHUTTLE
		if("callshuttle2")
			if(authenticated)
				SSshuttle.requestEvac(usr, href_list["call"])
				if(SSshuttle.emergency.timer)
					post_status("shuttle")
			state = STATE_DEFAULT
		if("cancelshuttle")
			state = STATE_DEFAULT
			if(authenticated)
				state = STATE_CANCELSHUTTLE
		if("cancelshuttle2")
			if(authenticated)
				SSshuttle.cancelEvac(usr)
			state = STATE_DEFAULT
		if("messagelist")
			currmsg = 0
			state = STATE_MESSAGELIST
		if("viewmessage")
			state = STATE_VIEWMESSAGE
			if (!currmsg)
				if(href_list["message-num"])
					var/msgnum = text2num(href_list["message-num"])
					currmsg = messages[msgnum]
				else
					state = STATE_MESSAGELIST
		if("delmessage")
			state = currmsg ? STATE_DELMESSAGE : STATE_MESSAGELIST
		if("delmessage2")
			if(authenticated)
				if(currmsg)
					if(aicurrmsg == currmsg)
						aicurrmsg = null
					messages -= currmsg
					currmsg = null
				state = STATE_MESSAGELIST
			else
				state = STATE_VIEWMESSAGE
		if("respond")
			var/answer = text2num(href_list["answer"])
			if(!currmsg || !answer || currmsg.possible_answers.len < answer)
				state = STATE_MESSAGELIST
			currmsg.answered = answer
			log_game("[key_name(usr)] answered [currmsg.title] comm message. Answer : [currmsg.answered]")
			if(currmsg)
				currmsg.answer_callback.Invoke()

			state = STATE_VIEWMESSAGE
		if("status")
			state = STATE_STATUSDISPLAY
		if("securitylevel")
			tmp_alertlevel = text2num( href_list["newalertlevel"] )
			if(!tmp_alertlevel)
				tmp_alertlevel = 0
			state = STATE_CONFIRM_LEVEL
		if("changeseclevel")
			state = STATE_ALERT_LEVEL

		if("emergencyaccess")
			state = STATE_TOGGLE_EMERGENCY
		if("enableemergency")
			make_maint_all_access()
			log_game("[key_name(usr)] enabled emergency maintenance access.")
			message_admins("[key_name_admin(usr)] enabled emergency maintenance access.")
			deadchat_broadcast("<span class='deadsay'><span class='name'>[usr.name]</span> enabled emergency maintenance access at <span class='name'>[area_name]</span>.</span>", usr)
			state = STATE_DEFAULT
		if("disableemergency")
			revoke_maint_all_access()
			log_game("[key_name(usr)] disabled emergency maintenance access.")
			message_admins("[key_name_admin(usr)] disabled emergency maintenance access.")
			deadchat_broadcast("<span class='deadsay'><span class='name'>[usr.name]</span> disabled emergency maintenance access at <span class='name'>[area_name]</span>.</span>", usr)
			state = STATE_DEFAULT

		// Status display stuff
		if("setstat")
			playsound(src, "terminal_type", 50, 0)
			switch(href_list["statdisp"])
				if("message")
					post_status("message", stat_msg1, stat_msg2)
				if("alert")
					post_status("alert", href_list["alert"])
				else
					post_status(href_list["statdisp"])

		if("setmsg1")
			stat_msg1 = reject_bad_text(input("Line 1", "Enter Message Text", stat_msg1) as text|null, 40)
			updateDialog()
		if("setmsg2")
			stat_msg2 = reject_bad_text(input("Line 2", "Enter Message Text", stat_msg2) as text|null, 40)
			updateDialog()

		// OMG CENTCOM LETTERHEAD
		if("MessageCentCom")
			if(authenticated==2)
				if(!checkCCcooldown())
					to_chat(usr, "<span class='warning'>Arrays recycling.  Please stand by.</span>")
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to CentCom via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination.  Transmission does not guarantee a response.", "Send a message to CentCom.", "")
				if(!input || !(usr in view(1,src)) || !checkCCcooldown())
					return
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
				CentCom_announce(input, usr)
				to_chat(usr, "<span class='notice'>Message transmitted to Central Command.</span>")
				log_talk(usr,"[key_name(usr)] has made a CentCom announcement: [input]",LOGSAY)
				deadchat_broadcast("<span class='deadsay'><span class='name'>[usr.name]</span> has messaged CentCom, \"[input]\" at <span class='name'>[area_name]</span>.</span>", usr)
				CM.lastTimeUsed = world.time

		// OMG SYNDICATE ...LETTERHEAD
		if("MessageSyndicate")
			if((authenticated==2) && (obj_flags & EMAGGED))
				if(!checkCCcooldown())
					to_chat(usr, "<span class='warning'>Arrays recycling.  Please stand by.</span>")
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to \[ABNORMAL ROUTING COORDINATES\] via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination. Transmission does not guarantee a response.", "Send a message to /??????/.", "")
				if(!input || !(usr in view(1,src)) || !checkCCcooldown())
					return
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
				Syndicate_announce(input, usr)
				to_chat(usr, "<span class='danger'>SYSERR @l(19833)of(transmit.dm): !@$ MESSAGE TRANSMITTED TO SYNDICATE COMMAND.</span>")
				log_talk(usr,"[key_name(usr)] has made a Syndicate announcement: [input]",LOGSAY)
				deadchat_broadcast("<span class='deadsay'><span class='name'>[usr.name]</span> has messaged the Syndicate, \"[input]\" at <span class='name'>[area_name]</span>.</span>", usr)
				CM.lastTimeUsed = world.time

		if("RestoreBackup")
			to_chat(usr, "<span class='notice'>Backup routing data restored!</span>")
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
			obj_flags &= ~EMAGGED
			updateDialog()

		if("nukerequest") //When there's no other way
			if(authenticated==2)
				if(!checkCCcooldown())
					to_chat(usr, "<span class='warning'>Arrays recycling. Please stand by.</span>")
					return
				var/input = stripped_input(usr, "Please enter the reason for requesting the nuclear self-destruct codes. Misuse of the nuclear request system will not be tolerated under any circumstances.  Transmission does not guarantee a response.", "Self Destruct Code Request.","")
				if(!input || !(usr in view(1,src)) || !checkCCcooldown())
					return
				Nuke_request(input, usr)
				to_chat(usr, "<span class='notice'>Request sent.</span>")
				log_talk(usr,"[key_name(usr)] has requested the nuclear codes from CentCom",LOGSAY)
				priority_announce("The codes for the on-station nuclear self-destruct have been requested by [usr]. Confirmation or denial of this request will be sent shortly.", "Nuclear Self Destruct Codes Requested",'sound/ai/commandreport.ogg')
				CM.lastTimeUsed = world.time


		// AI interface
		if("ai-main")
			aicurrmsg = null
			aistate = STATE_DEFAULT
		if("ai-callshuttle")
			aistate = STATE_CALLSHUTTLE
		if("ai-callshuttle2")
			SSshuttle.requestEvac(usr, href_list["call"])
			aistate = STATE_DEFAULT
		if("ai-messagelist")
			aicurrmsg = null
			aistate = STATE_MESSAGELIST
		if("ai-viewmessage")
			aistate = STATE_VIEWMESSAGE
			if (!aicurrmsg)
				if(href_list["message-num"])
					var/msgnum = text2num(href_list["message-num"])
					aicurrmsg = messages[msgnum]
				else
					aistate = STATE_MESSAGELIST
		if("ai-delmessage")
			aistate = aicurrmsg ? STATE_DELMESSAGE : STATE_MESSAGELIST
		if("ai-delmessage2")
			if(aicurrmsg)
				if(currmsg == aicurrmsg)
					currmsg = null
				messages -= aicurrmsg
				aicurrmsg = null
			aistate = STATE_MESSAGELIST
		if("ai-respond")
			var/answer = text2num(href_list["answer"])
			if(!aicurrmsg || !answer || aicurrmsg.possible_answers.len < answer)
				aistate = STATE_MESSAGELIST
			aicurrmsg.answered = answer
			log_game("[key_name(usr)] answered [aicurrmsg.title] comm message. Answer : [aicurrmsg.answered]")
			if(aicurrmsg.answer_callback)
				aicurrmsg.answer_callback.Invoke()
			aistate = STATE_VIEWMESSAGE
		if("ai-status")
			aistate = STATE_STATUSDISPLAY
		if("ai-announce")
			make_announcement(usr, 1)
		if("ai-securitylevel")
			tmp_alertlevel = text2num( href_list["newalertlevel"] )
			if(!tmp_alertlevel)
				tmp_alertlevel = 0
			var/old_level = GLOB.security_level
			if(!tmp_alertlevel)
				tmp_alertlevel = SEC_LEVEL_GREEN
			if(tmp_alertlevel < SEC_LEVEL_GREEN)
				tmp_alertlevel = SEC_LEVEL_GREEN
			if(tmp_alertlevel > SEC_LEVEL_BLUE)
				tmp_alertlevel = SEC_LEVEL_BLUE //Cannot engage delta with this
			set_security_level(tmp_alertlevel)
			if(GLOB.security_level != old_level)
				//Only notify people if an actual change happened
				var/security_level = get_security_level()
				log_game("[key_name(usr)] has changed the security level to [security_level].")
				message_admins("[key_name_admin(usr)] has changed the security level to [security_level].")
				deadchat_broadcast("<span class='deadsay'><span class='name'>[usr.name]</span> has changed the security level to [security_level].</span>", usr)
			tmp_alertlevel = 0
			aistate = STATE_DEFAULT
		if("ai-changeseclevel")
			aistate = STATE_ALERT_LEVEL
		if("ai-emergencyaccess")
			aistate = STATE_TOGGLE_EMERGENCY
		if("ai-enableemergency")
			make_maint_all_access()
			log_game("[key_name(usr)] enabled emergency maintenance access.")
			message_admins("[key_name_admin(usr)] enabled emergency maintenance access.")
			deadchat_broadcast("<span class='deadsay bold'>[usr.name] enabled emergency maintenance access.</span>", usr)
			aistate = STATE_DEFAULT
		if("ai-disableemergency")
			revoke_maint_all_access()
			log_game("[key_name(usr)] disabled emergency maintenance access.")
			message_admins("[key_name_admin(usr)] disabled emergency maintenance access.")
			deadchat_broadcast("<span class='deadsay bold'>[usr.name] disabled emergency maintenance access.</span>", usr)
			aistate = STATE_DEFAULT

	updateUsrDialog()

/obj/machinery/computer/communications/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/card/id))
		attack_hand(user)
	else
		return ..()

/obj/machinery/computer/communications/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	if(authenticated == 1)
		authenticated = 2
	to_chat(user, "<span class='danger'>You scramble the communication routing circuits!</span>")
	playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)

/obj/machinery/computer/communications/ui_interact(mob/user)
	. = ..()
	if (z > 6)
		to_chat(user, "<span class='boldannounce'>Unable to establish a connection</span>: \black You're too far away from the station!")
		return

	var/dat = ""
	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/timeleft = SSshuttle.emergency.timeLeft()
		dat += "<B>Emergency shuttle</B>\n<BR>\nETA: [timeleft / 60 % 60]:[add_zero(num2text(timeleft % 60), 2)]"


	var/datum/browser/popup = new(user, "communications", "Communications Console", 400, 500)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))

	if(issilicon(user))
		var/dat2 = interact_ai(user) // give the AI a different interact proc to limit its access
		if(dat2)
			dat +=  dat2
			popup.set_content(dat)
			popup.open()
		return

	switch(state)
		if(STATE_DEFAULT)
			if (authenticated)
				if(SSshuttle.emergencyCallAmount)
					if(SSshuttle.emergencyLastCallLoc)
						dat += "Most recent shuttle call/recall traced to: <b>[format_text(SSshuttle.emergencyLastCallLoc.name)]</b><BR>"
					else
						dat += "Unable to trace most recent shuttle call/recall signal.<BR>"
				dat += "Logged in as: [auth_id]"
				dat += "<BR>"
				dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=logout'>Log Out</A> \]<BR>"
				dat += "<BR><B>General Functions</B>"
				dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=messagelist'>Message List</A> \]"
				switch(SSshuttle.emergency.mode)
					if(SHUTTLE_IDLE, SHUTTLE_RECALL)
						dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=callshuttle'>Call Emergency Shuttle</A> \]"
					else
						dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=cancelshuttle'>Cancel Shuttle Call</A> \]"

				dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=status'>Set Status Display</A> \]"
				if (authenticated==2)
					dat += "<BR><BR><B>Captain Functions</B>"
					dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=announce'>Make a Captain's Announcement</A> \]"
					var/cross_servers_count = length(CONFIG_GET(keyed_string_list/cross_server))
					if(cross_servers_count)
						dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=crossserver'>Send a message to [cross_servers_count == 1 ? "an " : ""]allied station[cross_servers_count > 1 ? "s" : ""]</A> \]"
					if(SSmapping.config.allow_custom_shuttles)
						dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=purchase_menu'>Purchase Shuttle</A> \]"
					dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=changeseclevel'>Change Alert Level</A> \]"
					dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=emergencyaccess'>Emergency Maintenance Access</A> \]"
					dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=nukerequest'>Request Nuclear Authentication Codes</A> \]"
					if(!(obj_flags & EMAGGED))
						dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=MessageCentCom'>Send Message to CentCom</A> \]"
					else
						dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=MessageSyndicate'>Send Message to \[UNKNOWN\]</A> \]"
						dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=RestoreBackup'>Restore Backup Routing Data</A> \]"
			else
				dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=login'>Log In</A> \]"
		if(STATE_CALLSHUTTLE)
			dat += get_call_shuttle_form()
			playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
		if(STATE_CANCELSHUTTLE)
			dat += get_cancel_shuttle_form()
			playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
		if(STATE_MESSAGELIST)
			dat += "Messages:"
			for(var/i in 1 to messages.len)
				var/datum/comm_message/M = messages[i]
				dat += "<BR><A HREF='?src=[REF(src)];operation=viewmessage;message-num=[i]'>[M.title]</A>"
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
		if(STATE_VIEWMESSAGE)
			if (currmsg)
				dat += "<B>[currmsg.title]</B><BR><BR>[currmsg.content]"
				if(!currmsg.answered && currmsg.possible_answers.len)
					for(var/i in 1 to currmsg.possible_answers.len)
						var/answer = currmsg.possible_answers[i]
						dat += "<br>\[ <A HREF='?src=[REF(src)];operation=respond;answer=[i]'>Answer : [answer]</A> \]"
				else if(currmsg.answered)
					var/answered = currmsg.possible_answers[currmsg.answered]
					dat += "<br> Archived Answer : [answered]"
				dat += "<BR><BR>\[ <A HREF='?src=[REF(src)];operation=delmessage'>Delete</A> \]"
			else
				aistate = STATE_MESSAGELIST
				attack_hand(user)
				return
		if(STATE_DELMESSAGE)
			if (currmsg)
				dat += "Are you sure you want to delete this message? \[ <A HREF='?src=[REF(src)];operation=delmessage2'>OK</A> | <A HREF='?src=[REF(src)];operation=viewmessage'>Cancel</A> \]"
			else
				state = STATE_MESSAGELIST
				attack_hand(user)
				return
		if(STATE_STATUSDISPLAY)
			dat += "Set Status Displays<BR>"
			dat += "\[ <A HREF='?src=[REF(src)];operation=setstat;statdisp=blank'>Clear</A> \]<BR>"
			dat += "\[ <A HREF='?src=[REF(src)];operation=setstat;statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
			dat += "\[ <A HREF='?src=[REF(src)];operation=setstat;statdisp=message'>Message</A> \]"
			dat += "<ul><li> Line 1: <A HREF='?src=[REF(src)];operation=setmsg1'>[ stat_msg1 ? stat_msg1 : "(none)"]</A>"
			dat += "<li> Line 2: <A HREF='?src=[REF(src)];operation=setmsg2'>[ stat_msg2 ? stat_msg2 : "(none)"]</A></ul><br>"
			dat += "\[ Alert: <A HREF='?src=[REF(src)];operation=setstat;statdisp=alert;alert=default'>None</A> |"
			dat += " <A HREF='?src=[REF(src)];operation=setstat;statdisp=alert;alert=redalert'>Red Alert</A> |"
			dat += " <A HREF='?src=[REF(src)];operation=setstat;statdisp=alert;alert=lockdown'>Lockdown</A> |"
			dat += " <A HREF='?src=[REF(src)];operation=setstat;statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR><HR>"
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
		if(STATE_ALERT_LEVEL)
			dat += "Current alert level: [get_security_level()]<BR>"
			if(GLOB.security_level == SEC_LEVEL_DELTA)
				dat += "<font color='red'><b>The self-destruct mechanism is active. Find a way to deactivate the mechanism to lower the alert level or evacuate.</b></font>"
			else
				dat += "<A HREF='?src=[REF(src)];operation=securitylevel;newalertlevel=[SEC_LEVEL_BLUE]'>Blue</A><BR>"
				dat += "<A HREF='?src=[REF(src)];operation=securitylevel;newalertlevel=[SEC_LEVEL_GREEN]'>Green</A>"
		if(STATE_CONFIRM_LEVEL)
			dat += "Current alert level: [get_security_level()]<BR>"
			dat += "Confirm the change to: [num2seclevel(tmp_alertlevel)]<BR>"
			dat += "<A HREF='?src=[REF(src)];operation=swipeidseclevel'>Swipe ID</A> to confirm change.<BR>"
		if(STATE_TOGGLE_EMERGENCY)
			playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
			if(GLOB.emergency_access == 1)
				dat += "<b>Emergency Maintenance Access is currently <font color='red'>ENABLED</font></b>"
				dat += "<BR>Restore maintenance access restrictions? <BR>\[ <A HREF='?src=[REF(src)];operation=disableemergency'>OK</A> | <A HREF='?src=[REF(src)];operation=viewmessage'>Cancel</A> \]"
			else
				dat += "<b>Emergency Maintenance Access is currently <font color='green'>DISABLED</font></b>"
				dat += "<BR>Lift access restrictions on maintenance and external airlocks? <BR>\[ <A HREF='?src=[REF(src)];operation=enableemergency'>OK</A> | <A HREF='?src=[REF(src)];operation=viewmessage'>Cancel</A> \]"

		if(STATE_PURCHASE)
			dat += "Budget: [SSshuttle.points] Credits.<BR>"
			for(var/shuttle_id in SSmapping.shuttle_templates)
				var/datum/map_template/shuttle/S = SSmapping.shuttle_templates[shuttle_id]
				if(S.can_be_bought && S.credit_cost < INFINITY)
					dat += "[S.name] | [S.credit_cost] Credits<BR>"
					dat += "[S.description]<BR>"
					if(S.prerequisites)
						dat += "Prerequisites: [S.prerequisites]<BR>"
					dat += "<A href='?src=[REF(src)];operation=buyshuttle;chosen_shuttle=[REF(S)]'>(<font color=red><i>Purchase</i></font>)</A><BR><BR>"

	dat += "<BR><BR>\[ [(state != STATE_DEFAULT) ? "<A HREF='?src=[REF(src)];operation=main'>Main Menu</A> | " : ""]<A HREF='?src=[REF(user)];mach_close=communications'>Close</A> \]"

	popup.set_content(dat)
	popup.open()
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/communications/proc/get_javascript_header(form_id)
	var/dat = {"<script type="text/javascript">
						function getLength(){
							var reasonField = document.getElementById('reasonfield');
							if(reasonField.value.length >= [CALL_SHUTTLE_REASON_LENGTH]){
								reasonField.style.backgroundColor = "#DDFFDD";
							}
							else {
								reasonField.style.backgroundColor = "#FFDDDD";
							}
						}
						function submit() {
							document.getElementById('[form_id]').submit();
						}
					</script>"}
	return dat

/obj/machinery/computer/communications/proc/get_call_shuttle_form(ai_interface = 0)
	var/form_id = "callshuttle"
	var/dat = get_javascript_header(form_id)
	dat += "<form name='callshuttle' id='[form_id]' action='?src=[REF(src)]' method='get' style='display: inline'>"
	dat += "<input type='hidden' name='src' value='[REF(src)]'>"
	dat += "<input type='hidden' name='operation' value='[ai_interface ? "ai-callshuttle2" : "callshuttle2"]'>"
	dat += "<b>Nature of emergency:</b><BR> <input type='text' id='reasonfield' name='call' style='width:250px; background-color:#FFDDDD; onkeydown='getLength() onkeyup='getLength()' onkeypress='getLength()'>"
	dat += "<BR>Are you sure you want to call the shuttle? \[ <a href='#' onclick='submit()'>Call</a> \]"
	return dat

/obj/machinery/computer/communications/proc/get_cancel_shuttle_form()
	var/form_id = "cancelshuttle"
	var/dat = get_javascript_header(form_id)
	dat += "<form name='cancelshuttle' id='[form_id]' action='?src=[REF(src)]' method='get' style='display: inline'>"
	dat += "<input type='hidden' name='src' value='[REF(src)]'>"
	dat += "<input type='hidden' name='operation' value='cancelshuttle2'>"

	dat += "<BR>Are you sure you want to cancel the shuttle? \[ <a href='#' onclick='submit()'>Cancel</a> \]"
	return dat

/obj/machinery/computer/communications/proc/interact_ai(mob/living/silicon/ai/user)
	var/dat = ""
	switch(aistate)
		if(STATE_DEFAULT)
			if(SSshuttle.emergencyCallAmount)
				if(SSshuttle.emergencyLastCallLoc)
					dat += "Latest emergency signal trace attempt successful.<BR>Last signal origin: <b>[format_text(SSshuttle.emergencyLastCallLoc.name)]</b>.<BR>"
				else
					dat += "Latest emergency signal trace attempt failed.<BR>"
			if(authenticated)
				dat += "Current login: [auth_id]"
			else
				dat += "Current login: None"
			dat += "<BR><BR><B>General Functions</B>"
			dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=ai-messagelist'>Message List</A> \]"
			if(SSshuttle.emergency.mode == SHUTTLE_IDLE)
				dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=ai-callshuttle'>Call Emergency Shuttle</A> \]"
			dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=ai-status'>Set Status Display</A> \]"
			dat += "<BR><BR><B>Special Functions</B>"
			dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=ai-announce'>Make an Announcement</A> \]"
			dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=ai-changeseclevel'>Change Alert Level</A> \]"
			dat += "<BR>\[ <A HREF='?src=[REF(src)];operation=ai-emergencyaccess'>Emergency Maintenance Access</A> \]"
		if(STATE_CALLSHUTTLE)
			dat += get_call_shuttle_form(1)
		if(STATE_MESSAGELIST)
			dat += "Messages:"
			for(var/i in 1 to messages.len)
				var/datum/comm_message/M = messages[i]
				dat += "<BR><A HREF='?src=[REF(src)];operation=ai-viewmessage;message-num=[i]'>[M.title]</A>"
		if(STATE_VIEWMESSAGE)
			if (aicurrmsg)
				dat += "<B>[aicurrmsg.title]</B><BR><BR>[aicurrmsg.content]"
				if(!aicurrmsg.answered && aicurrmsg.possible_answers.len)
					for(var/i in 1 to aicurrmsg.possible_answers.len)
						var/answer = aicurrmsg.possible_answers[i]
						dat += "<br>\[ <A HREF='?src=[REF(src)];operation=ai-respond;answer=[i]'>Answer : [answer]</A> \]"
				else if(aicurrmsg.answered)
					var/answered = aicurrmsg.possible_answers[aicurrmsg.answered]
					dat += "<br> Archived Answer : [answered]"
				dat += "<BR><BR>\[ <A HREF='?src=[REF(src)];operation=ai-delmessage'>Delete</A> \]"
			else
				aistate = STATE_MESSAGELIST
				attack_hand(user)
				return null
		if(STATE_DELMESSAGE)
			if(aicurrmsg)
				dat += "Are you sure you want to delete this message? \[ <A HREF='?src=[REF(src)];operation=ai-delmessage2'>OK</A> | <A HREF='?src=[REF(src)];operation=ai-viewmessage'>Cancel</A> \]"
			else
				aistate = STATE_MESSAGELIST
				attack_hand(user)
				return

		if(STATE_STATUSDISPLAY)
			dat += "Set Status Displays<BR>"
			dat += "\[ <A HREF='?src=[REF(src)];operation=setstat;statdisp=blank'>Clear</A> \]<BR>"
			dat += "\[ <A HREF='?src=[REF(src)];operation=setstat;statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
			dat += "\[ <A HREF='?src=[REF(src)];operation=setstat;statdisp=message'>Message</A> \]"
			dat += "<ul><li> Line 1: <A HREF='?src=[REF(src)];operation=setmsg1'>[ stat_msg1 ? stat_msg1 : "(none)"]</A>"
			dat += "<li> Line 2: <A HREF='?src=[REF(src)];operation=setmsg2'>[ stat_msg2 ? stat_msg2 : "(none)"]</A></ul><br>"
			dat += "\[ Alert: <A HREF='?src=[REF(src)];operation=setstat;statdisp=alert;alert=default'>None</A> |"
			dat += " <A HREF='?src=[REF(src)];operation=setstat;statdisp=alert;alert=redalert'>Red Alert</A> |"
			dat += " <A HREF='?src=[REF(src)];operation=setstat;statdisp=alert;alert=lockdown'>Lockdown</A> |"
			dat += " <A HREF='?src=[REF(src)];operation=setstat;statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR><HR>"

		if(STATE_ALERT_LEVEL)
			dat += "Current alert level: [get_security_level()]<BR>"
			if(GLOB.security_level == SEC_LEVEL_DELTA)
				dat += "<font color='red'><b>The self-destruct mechanism is active. Find a way to deactivate the mechanism to lower the alert level or evacuate.</b></font>"
			else
				dat += "<A HREF='?src=[REF(src)];operation=ai-securitylevel;newalertlevel=[SEC_LEVEL_BLUE]'>Blue</A><BR>"
				dat += "<A HREF='?src=[REF(src)];operation=ai-securitylevel;newalertlevel=[SEC_LEVEL_GREEN]'>Green</A>"

		if(STATE_TOGGLE_EMERGENCY)
			if(GLOB.emergency_access == 1)
				dat += "<b>Emergency Maintenance Access is currently <font color='red'>ENABLED</font></b>"
				dat += "<BR>Restore maintenance access restrictions? <BR>\[ <A HREF='?src=[REF(src)];operation=ai-disableemergency'>OK</A> | <A HREF='?src=[REF(src)];operation=ai-viewmessage'>Cancel</A> \]"
			else
				dat += "<b>Emergency Maintenance Access is currently <font color='green'>DISABLED</font></b>"
				dat += "<BR>Lift access restrictions on maintenance and external airlocks? <BR>\[ <A HREF='?src=[REF(src)];operation=ai-enableemergency'>OK</A> | <A HREF='?src=[REF(src)];operation=ai-viewmessage'>Cancel</A> \]"

	dat += "<BR><BR>\[ [(aistate != STATE_DEFAULT) ? "<A HREF='?src=[REF(src)];operation=ai-main'>Main Menu</A> | " : ""]<A HREF='?src=[REF(user)];mach_close=communications'>Close</A> \]"
	return dat

/obj/machinery/computer/communications/proc/make_announcement(mob/living/user, is_silicon)
	if(!SScommunications.can_announce(user, is_silicon))
		to_chat(user, "Intercomms recharging. Please stand by.")
		return
	var/input = stripped_input(user, "Please choose a message to announce to the station crew.", "What?")
	if(!input || !user.canUseTopic(src))
		return
	SScommunications.make_announcement(user, is_silicon, input)
	var/area/A = get_area(user)
	deadchat_broadcast("<span class='deadsay'><span class='name'>[user.name]</span> made an priority announcement at <span class='name'>[A.name]</span>.</span>", user)

/obj/machinery/computer/communications/proc/post_status(command, data1, data2)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

	if(!frequency)
		return

	var/datum/signal/status_signal = new(list("command" = command))
	switch(command)
		if("message")
			status_signal.data["msg1"] = data1
			status_signal.data["msg2"] = data2
		if("alert")
			status_signal.data["picture_state"] = data1

	frequency.post_signal(src, status_signal)


/obj/machinery/computer/communications/Destroy()
	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()
	return ..()

/obj/machinery/computer/communications/proc/overrideCooldown()
	var/obj/item/circuitboard/computer/communications/CM = circuit
	CM.lastTimeUsed = 0

/obj/machinery/computer/communications/proc/add_message(datum/comm_message/new_message)
	messages += new_message

/datum/comm_message
	var/title
	var/content
	var/list/possible_answers = list()
	var/answered
	var/datum/callback/answer_callback

/datum/comm_message/New(new_title,new_content,new_possible_answers)
	..()
	if(new_title)
		title = new_title
	if(new_content)
		content = new_content
	if(new_possible_answers)
		possible_answers = new_possible_answers
