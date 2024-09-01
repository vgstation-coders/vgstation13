/* Contents:
 - supplycomp (This one approves orders)
 - ordercomp (This is the public-facing one)
For the shuttle controller, see supplyshuttle.dm
For cargo crates, see supplypacks.dm
For vending packs, see vending_packs.dm*/

// returns an associate list of information needed for cargo consoles.  returns 0 if ID or account is missing

#define ACCOUNT_DB_OFFLINE (!linked_db.activated || linked_db.stat & (BROKEN|NOPOWER|FORCEDISABLE))
#define MENTION_DB_OFFLINE to_chat(user, "<span class='warning'>Account database connection lost. Please retry.</span>")
#define USE_ACCOUNT_ON_ID acc_info["account"] = user.get_worn_id_account(0, user)
#define USE_CARGO_ACCOUNT acc_info["account"] = department_accounts["Cargo"]
#define REQUISITION SSsupply_shuttle.requisition

/proc/get_account_info(mob/user, var/obj/machinery/account_database/linked_db)
	var/list/acc_info = new
	var/obj/item/weapon/card/id/usr_id = user.get_id_card()
	acc_info["authorized_name"] = ""
	if(ishuman(user))
		if(usr_id == null)
			to_chat(user, "<span class='warning'>Please wear an ID for authentication.</span>")
			return 0
		if(ACCOUNT_DB_OFFLINE)
			MENTION_DB_OFFLINE
			return

		var/datum/money_account/bank_account
		if(REQUISITION)
			bank_account = department_accounts["Cargo"]
			acc_info["check"] = FALSE
		else
			// Humans, or really physical people at the terminal, can present a debit card. Let's find one or just find the same ID.
			var/obj/item/weapon/card/debit/debit_card = user.get_card()
			var/using_debit = FALSE
			var/account_number = null
			if(istype(debit_card))
				account_number = debit_card.associated_account_number
				acc_info["authorized_name"] = debit_card.authorized_name
				using_debit = TRUE
			else
				account_number = usr_id.associated_account_number
			bank_account = linked_db.get_account(account_number)
			if(!bank_account)
				to_chat(user, "<span class='warning'>A valid bank account does not exist for \the [using_debit ? "[bicon(debit_card)] [debit_card]" : "[bicon(usr_id)] [usr_id]"]. Please try a different card.</span>")
				return
			acc_info["card"] = using_debit ? debit_card : usr_id
			acc_info["check"] = TRUE
		acc_info["idname"] = usr_id.registered_name
		acc_info["idrank"] = usr_id.assignment
		acc_info["account"] = bank_account
	else if(isAdminGhost(user))
		acc_info["idname"] = "Commander Green"
		acc_info["idrank"] = "Central Commander"
		acc_info["check"] = FALSE
		if(REQUISITION)
			USE_CARGO_ACCOUNT
		else
			USE_ACCOUNT_ON_ID
	else if(isAI(user))
		acc_info["idname"] = user.real_name
		acc_info["idrank"] = "AI"
		acc_info["check"] = FALSE
		if(ACCOUNT_DB_OFFLINE)
			MENTION_DB_OFFLINE
			return
		if(REQUISITION)
			USE_CARGO_ACCOUNT
		else
			USE_ACCOUNT_ON_ID
	else if(issilicon(user))
		acc_info["idname"] = user.real_name
		acc_info["idrank"] = "Cyborg"
		acc_info["check"] = FALSE
		if(ACCOUNT_DB_OFFLINE)
			MENTION_DB_OFFLINE
			return
		if(REQUISITION)
			USE_CARGO_ACCOUNT
		else
			USE_ACCOUNT_ON_ID

	return acc_info

#undef ACCOUNT_DB_OFFLINE
#undef MENTION_DB_OFFLINE
#undef USE_ACCOUNT_ON_ID

/obj/item/weapon/paper/request_form/New(var/loc, var/list/account_information, var/datum/supply_packs/pack, var/number_of_crates, var/reason = "No reason provided.")
	. = ..(loc)
	name = "[pack.name] Requisition Form - [account_information["idname"]], [account_information["idrank"]]"
	info += {"<h3>[station_name] Supply Requisition Form</h3><hr>
		INDEX: #[SSsupply_shuttle.ordernum]<br>
		REQUESTED BY: [account_information["idname"]]<br>"}
	if(account_information["authorized_name"] != "")
		info += "USING DEBIT AS: [account_information["authorized_name"]]<br>"

	info+= {"RANK: [account_information["idrank"]]<br>
		REASON: [reason]<br>
		SUPPLY CRATE TYPE: [pack.name]<br>
		NUMBER OF CRATES: [number_of_crates]<br>
		ACCESS RESTRICTION: [get_access_desc(pack.access)]<br>
		CONTENTS:<br>"}
	info += pack.manifest
	info += {"<hr>
		STAMP BELOW TO APPROVE THIS REQUISITION:<br>"}
	update_icon()

#define SCR_MAIN 1
#define SCR_CENTCOM 2
#define SCR_FORWARD 3

/obj/machinery/computer/supplycomp
	name = "Supply shuttle console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "supply"
	req_access = list(access_cargo)
	circuit = "/obj/item/weapon/circuitboard/supplycomp"
	var/reqtime = 0 //Cooldown for requisitions - Quarxink
	var/hacked = 0
	var/can_order_contraband = 0
	var/permissions_screen = FALSE
	var/last_viewed_group = "Supplies" // not sure how to get around hard coding this
	var/last_viewed_packinfo = "None"
	var/sort_method = "Default"
	var/search_query = null
	var/list/current_acct
	var/list/current_acct_override
	var/screen = SCR_MAIN
	var/printccrequests = TRUE
	var/printordermanifests = TRUE
	var/printshuttlemanifests = TRUE
	light_color = LIGHT_COLOR_BROWN

	hack_abilities = list(
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/oneuse/overload_quiet,
		/datum/malfhack_ability/account_hijack,
		/datum/malfhack_ability/oneuse/emag,
	)

/obj/machinery/computer/supplycomp/New()
	..()
	SSsupply_shuttle.supply_consoles.Add(src)
	reconnect_database()

/obj/machinery/computer/supplycomp/initialize()
	reconnect_database()

/obj/machinery/computer/supplycomp/Destroy()
	SSsupply_shuttle.supply_consoles.Remove(src)
	..()

/obj/machinery/computer/supplycomp/proc/get_supply_shuttle_timer()
	if(SSsupply_shuttle.moving)
		var/timeleft = round((SSsupply_shuttle.eta_timeofday - world.timeofday) / 10,1)
		if(timeleft < 0)
			return "Late"
		return "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"
	return ""

/obj/machinery/computer/supplycomp/proc/check_restriction(mob/user)
	if(!user)
		return FALSE
	var/result = FALSE
	switch(SSsupply_shuttle.restriction)
		if(0)
			result = TRUE
		if(1)
			result = allowed(user)
		if(2)
			result = allowed(user) && iscarbon(user)
		if(3)
			result = pin_query(user)
	if(!result) //This saves a lot of pasted to_chat everywhere else
		if(can_order_contraband)
			result = TRUE
		else
			to_chat(user, "<span class='warning'>Your credentials were rejected by the current permissions protocol.</span>")
	return result

/obj/machinery/computer/supplycomp/proc/pin_query(mob/user)
	if(!user)
		return FALSE
	var/datum/money_account/D = department_accounts["Cargo"]
	var/attemptedpin = input(user, "Please input the Cargo departmental pin.","Department Head Access Required", null) as num|null
	if(attemptedpin == D.remote_access_pin)
		return TRUE
	return FALSE

/obj/machinery/computer/supplycomp/attack_hand(var/mob/user as mob)
	/*if(!check_restriction(user)) Let's allow anyone to READ the computer, but you need access to... (1) approve orders (2) send/call shuttle (3) delete requests (4) change permissions
		to_chat(user, "<span class='warning'>Access Denied.</span>")
		return*/

	if(..())
		return

	if(current_acct_override)
		current_acct = current_acct_override
	else
		current_acct = get_account_info(user, linked_db)

	user.set_machine(src)
	post_signal("supply")

	ui_interact(user)

	onclose(user, "computer")

/obj/machinery/computer/supplycomp/attackby(obj/item/I as obj, user as mob)

	add_fingerprint(user)

	if(I.is_screwdriver(user))
		I.playtoolsound(loc, 50)
		if(do_after(user, src, 20))
			if (stat & BROKEN)
				to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( loc )
				new /obj/item/weapon/shard(loc)
				var/obj/item/weapon/circuitboard/supplycomp/M = new /obj/item/weapon/circuitboard/supplycomp( A )
				for (var/obj/C in src)
					C.forceMove(loc)
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				src.transfer_fingerprints_to(A)
				qdel(src)
			else
				to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( loc )
				var/obj/item/weapon/circuitboard/supplycomp/M = new /obj/item/weapon/circuitboard/supplycomp( A )
				if(can_order_contraband)
					M.contraband_enabled = 1
					req_access = list()
				for (var/obj/C in src)
					C.forceMove(loc)
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				src.transfer_fingerprints_to(A)
				qdel(src)
	else
		return ..()

/obj/machinery/computer/supplycomp/emag_act(mob/user)
	if(!hacked)
		to_chat(user, "<span class='warning'>Special supplies unlocked.</span>")
		hacked = 1
		can_order_contraband = 1
	else
		return ..()

/obj/machinery/computer/supplycomp/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	if(!current_acct)
		return
	// data to send to ui
	var/data[0]
	// make assoc list for supply groups because either I'm retarded or nanoui is retarded
	var/supply_group_data[0]
	for(var/i = 1; i <= all_supply_groups.len; i++)
		supply_group_data.Add(list(list("category" = all_supply_groups[i])))
	data["all_supply_groups"] = supply_group_data
	data["last_viewed_group"] = last_viewed_group
	data["supply_pack_info"] = set_supply_pack_info(last_viewed_packinfo, user)
	data["sort_method"] = sort_method
	data["supply_shuttle_timer"] = get_supply_shuttle_timer()

	// list of packs we are displaying
	var/packs_list[0]
	for(var/set_name in SSsupply_shuttle.supply_packs)
		var/datum/supply_packs/pack = SSsupply_shuttle.supply_packs[set_name]
		// Check if the pack is allowed to be shown
		if((pack.hidden && src.hacked) || (pack.contraband && src.can_order_contraband) || (!pack.contraband && !pack.hidden))
			if(search_query)
				if(findtext(pack.name, search_query))
					packs_list.Add(list(list("name" = pack.name, "amount" = pack.amount, "cost" = pack.cost, "command1" = list("doorder" = "[set_name]0"), "command2" = list("doorder" = "[set_name]1"), "command3" = list("set_supply_info" = "[set_name]"))))
			else
				if(last_viewed_group == pack.group)
					packs_list.Add(list(list("name" = pack.name, "amount" = pack.amount, "cost" = pack.cost, "command1" = list("doorder" = "[set_name]0"), "command2" = list("doorder" = "[set_name]1"), "command3" = list("set_supply_info" = "[set_name]"))))
					// command1 is for a single crate order, command2 is for multi crate order, command3 is for pack info
	switch(sort_method)
		if("Cost, Ascending")
			cmp_field = "cost"
			data["supply_packs"] = sortTim(packs_list, /proc/cmp_list_by_element_asc)
		if("Cost, Descending")
			cmp_field = "cost"
			data["supply_packs"] = sortTim(packs_list, /proc/cmp_list_by_element_desc)
		if("Alphabetical, Ascending")
			cmp_field = "name"
			data["supply_packs"] = sortTim(packs_list, /proc/cmp_list_by_text_element_asc)
		if("Alphabetical, Descending")
			cmp_field = "name"
			data["supply_packs"] = sortTim(packs_list, /proc/cmp_list_by_text_element_desc)
		else
			data["supply_packs"] = packs_list

	var/requests_list[0]
	for(var/set_name in SSsupply_shuttle.requestlist)
		var/datum/supply_order/SO = set_name
		if(SO)
			if(!SO.comment)
				SO.comment = "No reason provided."
			requests_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "authorized_name" = SO.authorized_name, "comment" = SO.comment, "command1" = list("confirmorder" = SO.ordernum), "command2" = list("rreq" = SO.ordernum))))
	data["requests"] = requests_list

	var/orders_list[0]
	for(var/set_name in SSsupply_shuttle.shoppinglist)
		var/datum/supply_order/SO = set_name
		if(SO)
			orders_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "authorized_name" = SO.authorized_name, "comment" = SO.comment)))
	data["orders"] = orders_list

	var/centcomm_list[0]
	for(var/datum/centcomm_order/O in SSsupply_shuttle.centcomm_orders)
		var/displayworth = O.worth
		if (isnum(O.worth))
			displayworth = "[O.worth]$"
		centcomm_list.Add(list(list("id" = O.id, "requested" = O.getRequestsByName(), "extra" = O.extra_requirements, "fulfilled" = O.getFulfilledByName(), "name" = O.name, "worth" = displayworth, "to" = O.acct_by_string)))
	data["centcomm_orders"] = centcomm_list

	data["forwarding"] = SSsupply_shuttle.forwarding_on
	var/forward_list[0]
	for(var/datum/cargo_forwarding/CF in SSsupply_shuttle.cargo_forwards)
		var/displayworth = CF.worth
		if (isnum(CF.worth))
			displayworth = "[CF.worth]$"
		var/timeleft = CF.time_created && CF.time_limit ? ((CF.time_created + (CF.time_limit MINUTES)) - world.time) : 0 // Should never see 0 but just in case
		var/mm = text2num(time2text(timeleft, "mm")) // Set the minute
		var/ss = text2num(time2text(timeleft, "ss")) // Set the second
		var/weighedtext = CF.weighed ? "Yes" : "No"
		var/stampedtext = "No"
		if(CF.associated_manifest)
			stampedtext = CF.associated_manifest.stamped ? "Yes" : "No"
		forward_list.Add(list(list("name" = CF.name, "origin_station_name" = CF.origin_station_name, "origin_sender_name" = CF.origin_sender_name, "worth" = displayworth, "mm" = mm, "ss" = ss, "weighed" = weighedtext, "associated manifest" = CF.associated_manifest ? "Yes" : "No", "stamped" = stampedtext)))
	data["forwards"] = forward_list
	data["are_forwards"] = SSsupply_shuttle.cargo_forwards.len

	var/datum/money_account/account = current_acct["account"]
	if(account)
		data["name_of_source_account"] = account.owner_name
		data["authorized_name"] = current_acct["authorized_name"]
		data["money"] = account.fmtBalance()
	data["send"] = list("send" = 1)
	data["forward"] = list("forward" = 1)
	data["moving"] = SSsupply_shuttle.moving
	data["at_station"] = SSsupply_shuttle.at_station
	data["show_permissions"] = permissions_screen
	data["restriction"] = SSsupply_shuttle.restriction
	data["requisition"] = SSsupply_shuttle.requisition
	data["shuttle_bad_status"] = (!map.linked_to_centcomm || !SSsupply_shuttle.can_move())
	data["printccrequests"] = printccrequests
	data["printordermanifests"] = printordermanifests
	data["printshuttlemanifests"] = printshuttlemanifests

	data["hacked"] = can_order_contraband
	data["screen"] = screen

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "supply_console.tmpl", name, 600, 800)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/supplycomp/Topic(href, href_list)
	if(..())
		return 1
	add_fingerprint(usr)
	if(current_acct_override)
		current_acct = current_acct_override
	else
		current_acct = get_account_info(usr, linked_db)
	var/idname
	var/datum/money_account/account
	if(!current_acct && !href_list["close"])
		return
	else
		idname = current_acct["idname"]
		account = current_acct["account"]
	//Handle access and requisitions
	if(href_list["permissions"])
		if(!permissions_screen && pin_query(usr))
			permissions_screen = TRUE
		else
			permissions_screen = FALSE
		return 1
	//Handle cargo crate forwarding
	if(href_list["forward"])
		SSsupply_shuttle.forwarding_on = !SSsupply_shuttle.forwarding_on
		return 1
	//Calling the shuttle
	else if(href_list["send"])
		if(!map.linked_to_centcomm)
			to_chat(usr, "<span class='warning'>You aren't able to establish contact with central command, so the shuttle won't move.</span>")
		else if(!SSsupply_shuttle.can_move())
			to_chat(usr, "<span class='warning'>For safety reasons the automated supply shuttle cannot transport sapient organisms, classified nuclear weaponry or homing beacons.</span>")
		else if(!check_restriction(usr))
			to_chat(usr, "<span class='warning'>Your credentials were rejected by the current permissions protocol.</span>")

		else if(SSsupply_shuttle.at_station)
			//check to see if there are unprocessed forwards and warn if so
			if(SSsupply_shuttle.cargo_forwards.len)
				var/unfinished_forwards = check_forwards()
				if(unfinished_forwards && alert(usr, "There are crate forwards that are not present, stamped, and weighed. Send the shuttle back anyway?", "Forwarding Warning", "Yes", "No") == "No")
					return 1

			SSsupply_shuttle.moving = -1
			SSsupply_shuttle.sell()
			SSsupply_shuttle.scrub()
			SSsupply_shuttle.send()
		else
			SSsupply_shuttle.moving = 1
			if(printshuttlemanifests)
				var/obj/item/weapon/paper/P = new /obj/item/weapon/paper
				P.name = "Shuttle Order Manifest - [worldtime2text()]"
				P.info += "<h3>[station_name] Shuttle Manifest</h3>Order Placed: [worldtime2text()]"
				for(var/set_name in SSsupply_shuttle.shoppinglist)
					var/datum/supply_order/SO = set_name
					if(SO)
						P.info+= {"<hr><b>#[SO.ordernum] - [SO.object.name]</b><br>
									FOR: [SO.orderedby]<br>
									COMMENT: [SO.comment]<br>"}
				P.info += "<hr><b>STAMP BELOW TO CONFIRM RECEIPT OF ALL CRATES:</b><br>"
				P.update_icon()
				P.forceMove(src.loc)
			SSsupply_shuttle.buy()
			SSsupply_shuttle.eta_timeofday = (world.timeofday + SSsupply_shuttle.movetime) % 864000
			post_signal("supply")
		return 1
	else if (href_list["doorder"])
		if(world.time < reqtime)
			for(var/mob/V in hearers(src))
				V.show_message("<b>[src]</b>'s monitor flashes, \"[world.time - reqtime] seconds remaining until another requisition form may be printed.\"")
			return

		var/pack_name = copytext(href_list["doorder"], 1, -1)
		var/multi = text2num(copytext(href_list["doorder"], -1))
		if(!isnum(multi))
			return
		//Find the correct supply_pack datum
		var/datum/supply_packs/P = SSsupply_shuttle.supply_packs[pack_name]
		if(!istype(P))
			return

		if(current_acct["check"] && charge_flow_verify_security(linked_db, current_acct["card"], usr, account) != CARD_CAPTURE_SUCCESS)
			to_chat(usr, "<span class='warning'>Security violation when attempting to authenticate with bank account.</span>")
			return

		var/crates = 1
		if(multi)
			var/tempcount = input(usr, "Amount:", "How many crates?", "0") as num
			crates = clamp(round(text2num(tempcount)), 1, 20)
			if(text2num(tempcount) == 0)
				return

		// Calculate money tied up in requests
		var/total_money_req = 0
		for(var/i = 1; i <= length(SSsupply_shuttle.requestlist); i++)
			var/datum/supply_order/R = SSsupply_shuttle.requestlist[i]
			var/datum/money_account/R_acc = R.account
			if(R_acc.account_number == account.account_number)
				var/datum/supply_packs/R_pack = R.object
				total_money_req += R_pack.cost
		// check they can afford the order
		if(P.cost * crates + total_money_req > account.money)
			var/max_crates = round((account.money - total_money_req) / P.cost)
			to_chat(usr, "<span class='warning'>You can only afford [max_crates] crates.</span>")
			return
		var/timeout = world.time + 600
		var/reason = stripped_input(usr,"Why do you want this crate and where/to whom would you like it sent?","Reason/Destination:","",REASON_LEN)
		if(world.time > timeout)
			return
		if(!reason)
			return
		if(printordermanifests)
			new /obj/item/weapon/paper/request_form(loc, current_acct, P, crates, reason)
		reqtime = (world.time + 5) % 1e5
		//make our supply_order datum
		for(var/i = 1; i <= crates; i++)
			SSsupply_shuttle.ordernum++
			var/datum/supply_order/O = new /datum/supply_order()
			O.ordernum = SSsupply_shuttle.ordernum
			O.object = P
			O.orderedby = idname
			O.authorized_name = current_acct["authorized_name"]
			O.account = account
			O.comment = reason

			SSsupply_shuttle.requestlist += O

			if(!SSsupply_shuttle.restriction) //If set to 0 restriction, auto-approve
				SSsupply_shuttle.confirm_order(O,usr,SSsupply_shuttle.requestlist.len)
		return 1
	else if(href_list["confirmorder"])
		//Find the correct supply_order datum
		if(!check_restriction(usr))
			return
		var/ordernum = text2num(href_list["confirmorder"])
		var/datum/supply_order/O
		for(var/i=1, i<=SSsupply_shuttle.requestlist.len, i++)
			var/datum/supply_order/SO = SSsupply_shuttle.requestlist[i]
			if(SO.ordernum == ordernum)
				O = SO
				SSsupply_shuttle.confirm_order(O,usr,i)
				O.OnConfirmed(usr)
				break
		return 1
	else if (href_list["rreq"])
		if(!check_restriction(usr))
			return
		var/ordernum = text2num(href_list["rreq"])
		for(var/i=1, i<=SSsupply_shuttle.requestlist.len, i++)
			var/datum/supply_order/SO = SSsupply_shuttle.requestlist[i]
			if(SO.ordernum == ordernum)
				SSsupply_shuttle.requestlist.Cut(i,i+1)
				break
		return 1
	else if (href_list["last_viewed_group"])
		last_viewed_group = href_list["last_viewed_group"]
		last_viewed_packinfo = "None"
		search_query = null
		return 1
	else if (href_list["set_supply_info"])
		last_viewed_packinfo = href_list["set_supply_info"]
		return 1
	else if (href_list["search"])
		var/timeout = world.time + 600
		var/query = stripped_input(usr,"Name of the crate you're looking for?","Search Query:","")
		if(!query)
			return
		if(world.time > timeout)
			return
		search_query = query
		last_viewed_group = "Search"
		last_viewed_packinfo = "None"
		return 1
	else if (href_list["sort"])
		var/list/sort_methods_available = list("Default", "Alphabetical, Ascending", "Alphabetical, Descending", "Cost, Ascending", "Cost, Descending")
		sort_method = input(usr, "What sort method do you want to use?", "[src]") as anything in sort_methods_available
		return 1
	else if (href_list["access_restriction"])
		if(!check_restriction(usr))
			return
		SSsupply_shuttle.restriction = text2num(href_list["access_restriction"])
		return 1
	else if (href_list["access_ccrequests"])
		if(!check_restriction(usr))
			return
		printccrequests = text2num(href_list["access_ccrequests"])
		return 1
	else if (href_list["access_ordermanifests"])
		if(!check_restriction(usr))
			return
		printordermanifests = text2num(href_list["access_ordermanifests"])
		return 1
	else if (href_list["access_shuttlemanifests"])
		if(!check_restriction(usr))
			return
		printshuttlemanifests = text2num(href_list["access_shuttlemanifests"])
		return 1
	else if (href_list["requisition_status"])
		if(!check_restriction(usr))
			return
		SSsupply_shuttle.requisition = text2num(href_list["requisition_status"])
		if(current_acct_override)
			current_acct = current_acct_override
		else
			current_acct = get_account_info(usr, linked_db)
		return 1
	else if (href_list["screen"])
		if(!check_restriction(usr))
			return
		var/result = text2num(href_list["screen"])
		if(result == SCR_MAIN || result == SCR_CENTCOM || result == SCR_FORWARD)
			screen = result
		return 1
	else if (href_list["updateclock"])
		return 1
	else if (href_list["close"])
		current_acct = null
		current_acct_override = null
		if(usr.machine == src)
			usr.unset_machine()
		return 1

/obj/machinery/computer/supplycomp/proc/post_signal(var/command)


	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency)
		return

	var/datum/signal/status_signal = new /datum/signal
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	frequency.post_signal(src, status_signal)


//helper function for sending the supply shuttle back, checks for commonly-missed crate forward mistakes
/obj/machinery/computer/supplycomp/proc/check_forwards()
	if(SSsupply_shuttle.cargo_forwards.len == 0)
		return 0
	for(var/datum/cargo_forwarding/CF in SSsupply_shuttle.cargo_forwards)
		if(!CF.associated_crate || get_area(CF.associated_crate) != cargo_shuttle.linked_area)
			return 1
		if(!CF.weighed)
			return 1
		if(!CF.associated_manifest || get_area(CF.associated_manifest) != cargo_shuttle.linked_area)
			return 1
		if(CF.associated_manifest && (!CF.associated_manifest.stamped || !CF.associated_manifest.stamped.len))
			return 1
	return 0

/obj/machinery/computer/supplycomp/proc/set_supply_pack_info(var/pack_name, mob/user)
	var/list/pack_data = list()
	//var/pack_name = copytext(href_list["doorder"], 1, -1)
	var/datum/supply_packs/P = SSsupply_shuttle.supply_packs[pack_name]
	if(!istype(P))
		if(search_query)
			pack_data.Add(list(name = "Information Panel", packicon = "[bicon(src)]", containsdesc = "Results for [search_query]..."))
			return pack_data
		else
			pack_name = "None"
	if(pack_name == "None")
		var/access_required = ""
		var/has_access = FALSE
		switch(SSsupply_shuttle.restriction)
			if(0)
				access_required = "None, Auto-Approve"
				has_access = TRUE
			if(1)
				access_required = "Cargo Bay"
				has_access = allowed(user)
			if(2)
				access_required = "Cargo Bay and Physical ID"
				has_access = allowed(user) && iscarbon(user)
			if(3)
				access_required = "Departmental Pin"
				has_access = TRUE
		pack_data.Add(list(name = "Information Panel", access = "[access_required]", has_access = "[has_access]", packicon = "[bicon(src)]", containsdesc = "Welcome to the supply ordering console!"))
	else
		var/access_required = ""
		var/has_access = FALSE
		if(P.access || P.one_access)
			var/list/accesslist = list()
			if(P.access)
				for(var/number in P.access)
					accesslist.Add(get_access_desc(number))
				access_required = english_list(accesslist)
				if(can_access(user.GetAccess(),P.access,list()))
					has_access = TRUE
			else
				for(var/number in P.one_access)
					accesslist.Add(get_access_desc(number))
				access_required = english_list(accesslist, "nothing", " or ")
				if(can_access(user.GetAccess(),list(),P.one_access))
					has_access = TRUE

		pack_data.Add(list(name = "[pack_name]", access = "[access_required]", has_access = "[has_access]", packicon = "[bicon(P.containertype)]", containsicon = "[P.containsicon]", containsdesc = "[P.containsdesc]"))
	return pack_data


/obj/machinery/computer/ordercomp
	name = "Supply ordering console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "request"
	circuit = "/obj/item/weapon/circuitboard/ordercomp"
	var/reqtime = 0 //Cooldown for requisitions - Quarxink
	var/last_viewed_group = "Supplies" // not sure how to get around hard coding this
	var/last_viewed_packinfo = "None"
	var/sort_method = "Default"
	var/search_query = null
	var/list/current_acct
	var/list/current_acct_override
	light_color = LIGHT_COLOR_BROWN

	hack_abilities = list(
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/oneuse/overload_quiet,
		/datum/malfhack_ability/account_hijack,
	)

/obj/machinery/computer/ordercomp/New()
	. = ..()
	reconnect_database()

/obj/machinery/computer/ordercomp/initialize()
	reconnect_database()

/obj/machinery/computer/ordercomp/attack_hand(var/mob/user as mob)
	if(..())
		return
	if(current_acct_override)
		current_acct = current_acct_override
	else
		current_acct = get_account_info(user, linked_db)
	user.set_machine(src)
	ui_interact(user)
	onclose(user, "computer")
	return

/obj/machinery/computer/ordercomp/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	if(!current_acct)
		return
	// ui data
	var/data[0]
	// make assoc list for supply groups because either I'm retarded or nanoui is retarded
	var/supply_group_data[0]
	for(var/i = 1; i <= all_supply_groups.len; i++)
		supply_group_data.Add(list(list("category" = all_supply_groups[i])))
	data["all_supply_groups"] = supply_group_data
	data["last_viewed_group"] = last_viewed_group
	data["supply_pack_info"] = set_supply_pack_info(last_viewed_packinfo, user)
	data["sort_method"] = sort_method

	// current supply group packs being displayed
	var/packs_list[0]
	for(var/set_name in SSsupply_shuttle.supply_packs)
		var/datum/supply_packs/pack = SSsupply_shuttle.supply_packs[set_name]
		if(!pack.contraband && !pack.hidden)
			if(search_query)
				if(findtext(pack.name, search_query))
					packs_list.Add(list(list("name" = pack.name, "amount" = pack.amount, "cost" = pack.cost, "command1" = list("doorder" = "[set_name]0"), "command2" = list("doorder" = "[set_name]1"), "command3" = list("set_supply_info" = "[set_name]"))))
			else
				if(last_viewed_group == pack.group)
					packs_list.Add(list(list("name" = pack.name, "amount" = pack.amount, "cost" = pack.cost, "command1" = list("doorder" = "[set_name]0"), "command2" = list("doorder" = "[set_name]1"), "command3" = list("set_supply_info" = "[set_name]"))))
					// command1 is for a single crate order, command2 is for multi crate order, command3 is for pack info
	switch(sort_method)
		if("Cost, Ascending")
			cmp_field = "cost"
			data["supply_packs"] = sortTim(packs_list, /proc/cmp_list_by_element_asc)
		if("Cost, Descending")
			cmp_field = "cost"
			data["supply_packs"] = sortTim(packs_list, /proc/cmp_list_by_element_desc)
		if("Alphabetical, Ascending")
			cmp_field = "name"
			data["supply_packs"] = sortTim(packs_list, /proc/cmp_list_by_text_element_asc)
		if("Alphabetical, Descending")
			cmp_field = "name"
			data["supply_packs"] = sortTim(packs_list, /proc/cmp_list_by_text_element_desc)
		else
			data["supply_packs"] = packs_list

	var/obj/item/weapon/card/id/I = user.get_id_card()
	// current usr's cargo requests
	var/requests_list[0]
	for(var/set_name in SSsupply_shuttle.requestlist)
		var/datum/supply_order/SO = set_name
		if(SO)
			// Check if usr owns the request
			if(I && SO.orderedby == I.registered_name)
				requests_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "command1" = list("rreq" = SO.ordernum))))
	data["requests"] = requests_list

	var/orders_list[0]
	for(var/set_name in SSsupply_shuttle.shoppinglist)
		var/datum/supply_order/SO = set_name
		if(SO )
			// Check if usr owns the order
			if(I && SO.orderedby == I.registered_name)
				orders_list.Add(list(list("ordernum" = SO.ordernum, "orderedby" = SO.orderedby, "supply_type" = SO.object.name)))
	data["orders"] = orders_list
	var/datum/money_account/account = current_acct["account"]
	data["name_of_source_account"] = account.owner_name
	data["authorized_name"] = current_acct["authorized_name"]
	data["money"] = account.fmtBalance()

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "order_console.tmpl", name, 600, 730)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/ordercomp/Topic(href, href_list)
	if(..())
		return 1
	add_fingerprint(usr)
	if(current_acct_override)
		current_acct = current_acct_override
	else
		current_acct = get_account_info(usr, linked_db)
	var/idname
	var/datum/money_account/account
	if(!current_acct && !href_list["close"])
		return
	else
		idname = current_acct["idname"]
		account = current_acct["account"]

	if (href_list["doorder"])
		if(world.time < reqtime)
			for(var/mob/V in hearers(src))
				V.show_message("<b>[src]</b>'s monitor flashes, \"[world.time - reqtime] seconds remaining until another requisition form may be printed.\"")
			return

		var/timeout = world.time + 600
		// Get ordered pack name and multi crate order boolean
		var/pack_name = copytext(href_list["doorder"], 1, -1)
		var/multi = text2num(copytext(href_list["doorder"], -1))
		if(!isnum(multi))
			return
		var/datum/supply_packs/P = SSsupply_shuttle.supply_packs[pack_name]
		if(!istype(P))
			return

		if(current_acct["check"] && charge_flow_verify_security(linked_db, current_acct["card"], usr, account) != CARD_CAPTURE_SUCCESS)
			to_chat(usr, "<span class='warning'>Security violation when attempting to authenticate with bank account.</span>")
			return

		var/crates = 1
		if(multi)
			var/num_input = input(usr, "Amount:", "How many crates?", "0") as num
			if(text2num(num_input) == 0)
				return
			// Maximum 20 crates ordered at a time
			crates = clamp(round(text2num(num_input)), 1, 20)

		// Calculate money tied up in usr's requests
		var/total_money_req = 0
		for(var/i = 1; i <= length(SSsupply_shuttle.requestlist); i++)
			var/datum/supply_order/R = SSsupply_shuttle.requestlist[i]
			var/datum/money_account/R_acc = R.account
			if(R_acc.account_number == account.account_number)
				var/datum/supply_packs/R_pack = R.object
				total_money_req += R_pack.cost
		// Check they have enough cash to order another crate
		if((P.cost * crates + total_money_req > account.money))
			// Tell them how many they can actually afford if they can't afford their order
			var/max_crates = round((account.money - total_money_req) / P.cost)
			to_chat(usr, "<span class='warning'>You can only afford [max_crates] crates.</span>")
			return
		var/reason = stripped_input(usr,"Why do you want this crate and where/to whom would you like it sent?","Reason/Destination:","",REASON_LEN)
		if(world.time > timeout)
			return
		if(!reason)
			return

		new /obj/item/weapon/paper/request_form(loc, current_acct, P, crates, reason)
		reqtime = (world.time + 5) % 1e5

		//make our supply_order datum
		for(var/i = 1; i <= crates; i++)
			SSsupply_shuttle.ordernum++
			var/datum/supply_order/O = new /datum/supply_order()
			O.ordernum = SSsupply_shuttle.ordernum
			O.object = P
			O.orderedby = idname
			O.authorized_name = current_acct["authorized_name"]
			O.account = account
			O.comment = reason
			SSsupply_shuttle.requestlist += O
			stat_collection.crates_ordered++

			if(!SSsupply_shuttle.restriction) //Restriction = 0, auto order
				SSsupply_shuttle.confirm_order(O,usr,SSsupply_shuttle.requestlist.len) //Position: last
		return 1
	else if (href_list["last_viewed_group"])
		last_viewed_group = href_list["last_viewed_group"]
		last_viewed_packinfo = "None"
		search_query = null
		return 1
	else if (href_list["set_supply_info"])
		last_viewed_packinfo = href_list["set_supply_info"]
		return 1
	else if (href_list["search"])
		var/timeout = world.time + 600
		var/query = stripped_input(usr,"Name of the crate you're looking for?","Search Query:","")
		if(!query)
			return
		if(world.time > timeout)
			return
		search_query = query
		last_viewed_group = "Search"
		last_viewed_packinfo = "None"
		return 1
	else if (href_list["sort"])
		var/list/sort_methods_available = list("Default", "Alphabetical, Ascending", "Alphabetical, Descending", "Cost, Ascending", "Cost, Descending")
		sort_method = input(usr, "What sort method do you want to use?", "[src]") as anything in sort_methods_available
		return 1
	else if (href_list["rreq"])
		var/ordernum = text2num(href_list["rreq"])
		for(var/i=1, i<=SSsupply_shuttle.requestlist.len, i++)
			var/datum/supply_order/SO = SSsupply_shuttle.requestlist[i]
			if(SO.ordernum == ordernum)
				SSsupply_shuttle.requestlist.Cut(i,i+1)
				break
		return 1
	else if (href_list["close"])
		current_acct = null
		current_acct_override = null
		if(usr.machine == src)
			usr.unset_machine()
		return 1

//Called each time the UI is updated. Determines if a pack, search, category, or nothing is selected, then
//generates an information panel based off of the contents.
/obj/machinery/computer/ordercomp/proc/set_supply_pack_info(var/pack_name, mob/user)
	var/list/pack_data = list()
	//var/pack_name = copytext(href_list["doorder"], 1, -1)
	var/datum/supply_packs/P = SSsupply_shuttle.supply_packs[pack_name]
	if(!istype(P))
		if(search_query)
			pack_data.Add(list(name = "Information Panel", packicon = "[bicon(src)]", containsdesc = "Results for [search_query]..."))
			return pack_data
		else
			pack_name = "None"
	if(pack_name == "None")
		pack_data.Add(list(name = "Information Panel", packicon = "[bicon(src)]", containsdesc = "Welcome to the supply ordering console!"))
	else
		var/access_required = ""
		var/has_access = FALSE
		if(P.access || P.one_access)
			var/list/accesslist = list()
			if(P.access)
				for(var/number in P.access)
					accesslist.Add(get_access_desc(number))
				access_required = english_list(accesslist)
				if(can_access(user.GetAccess(),P.access,list()))
					has_access = TRUE
			else
				for(var/number in P.one_access)
					accesslist.Add(get_access_desc(number))
				access_required = english_list(accesslist, "nothing", " or ")
				if(can_access(user.GetAccess(),list(),P.one_access))
					has_access = TRUE

		pack_data.Add(list(name = "[pack_name]", access = "[access_required]", has_access = "[has_access]", packicon = "[bicon(P.containertype)]", containsicon = "[P.containsicon]", containsdesc = "[P.containsdesc]"))
	return pack_data

#undef SCR_MAIN
#undef SCR_CENTCOM
