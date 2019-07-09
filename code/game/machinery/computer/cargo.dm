/* Contents:
 - supplycomp (This one approves orders)
 - ordercomp (This is the public-facing one)
For the shuttle controller, see supplyshuttle.dm
For cargo crates, see supplypacks.dm
For vending packs, see vending_packs.dm*/

// returns an associate list of information needed for cargo consoles.  returns 0 if ID or account is missing

#define ACCOUNT_DB_OFFLINE (!linked_db.activated || linked_db.stat & (BROKEN|NOPOWER))
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
		acc_info["idrank"] = usr_id.GetJobName()
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
	var/list/current_acct
	var/screen = SCR_MAIN
	light_color = LIGHT_COLOR_BROWN

/obj/machinery/computer/supplycomp/New()
	..()
	SSsupply_shuttle.supply_consoles.Add(src)
	reconnect_database()

/obj/machinery/computer/supplycomp/initialize()
	reconnect_database()

/obj/machinery/computer/supplycomp/Destroy()
	SSsupply_shuttle.supply_consoles.Remove(src)
	..()


/obj/machinery/computer/supplycomp/attack_ai(var/mob/user as mob)
	add_hiddenprint(user)
	return attack_hand(user)

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

	current_acct = get_account_info(user, linked_db)

	user.set_machine(src)
	post_signal("supply")

	ui_interact(user)

	onclose(user, "computer")

/obj/machinery/computer/supplycomp/attackby(obj/item/I as obj, user as mob)
	if(istype(I,/obj/item/weapon/card/emag) && !hacked)
		to_chat(user, "<span class='notice'>Special supplies unlocked.</span>")
		hacked = 1
		return
	if(I.is_screwdriver(user))
		playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(do_after(user, src, 20))
			if (stat & BROKEN)
				to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( loc )
				getFromPool(/obj/item/weapon/shard, loc)
				var/obj/item/weapon/circuitboard/supplycomp/M = new /obj/item/weapon/circuitboard/supplycomp( A )
				for (var/obj/C in src)
					C.forceMove(loc)
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
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
				qdel(src)
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

	// list of packs we are displaying
	var/packs_list[0]
	for(var/set_name in SSsupply_shuttle.supply_packs)
		var/datum/supply_packs/pack = SSsupply_shuttle.supply_packs[set_name]
		// Check if the pack is allowed to be shown
		if((pack.hidden && src.hacked) || (pack.contraband && src.can_order_contraband) || (!pack.contraband && !pack.hidden))
			if(last_viewed_group == pack.group)
				packs_list.Add(list(list("name" = pack.name, "amount" = pack.amount, "cost" = pack.cost, "command1" = list("doorder" = "[set_name]0"), "command2" = list("doorder" = "[set_name]1"))))
				// command1 is for a single crate order, command2 is for multi crate order

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
		centcomm_list.Add(list(list("id" = O.id, "requested" = O.getRequestsByName(), "fulfilled" = O.getFulfilledByName(), "name" = O.name, "worth" = O.worth, "to" = O.acct_by_string)))
	data["centcomm_orders"] = centcomm_list

	var/datum/money_account/account = current_acct["account"]
	data["name_of_source_account"] = account.owner_name
	data["authorized_name"] = current_acct["authorized_name"]
	data["money"] = account.fmtBalance()
	data["send"] = list("send" = 1)
	data["moving"] = SSsupply_shuttle.moving
	data["at_station"] = SSsupply_shuttle.at_station
	data["show_permissions"] = permissions_screen
	data["restriction"] = SSsupply_shuttle.restriction
	data["requisition"] = SSsupply_shuttle.requisition

	data["hacked"] = can_order_contraband
	data["screen"] = screen

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "supply_console.tmpl", name, 600, 660)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/supplycomp/Topic(href, href_list)
	if(..())
		return 1
	add_fingerprint(usr)
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
	//Calling the shuttle
	else if(href_list["send"])
		if(!map.linked_to_centcomm)
			to_chat(usr, "<span class='warning'>You aren't able to establish contact with central command, so the shuttle won't move.</span>")
		else if(!SSsupply_shuttle.can_move())
			to_chat(usr, "<span class='warning'>For safety reasons the automated supply shuttle cannot transport live organisms, classified nuclear weaponry or homing beacons.</span>")
		else if(!check_restriction(usr))
			to_chat(usr, "<span class='warning'>Your credentials were rejected by the current permissions protocol.</span>")

		else if(SSsupply_shuttle.at_station)
			SSsupply_shuttle.moving = -1
			SSsupply_shuttle.sell()
			SSsupply_shuttle.send()
		else
			SSsupply_shuttle.moving = 1
			SSsupply_shuttle.buy()
			SSsupply_shuttle.eta_timeofday = (world.timeofday + SSsupply_shuttle.movetime) % 864000
			post_signal("supply")
		return 1
	else if (href_list["doorder"])
		if(world.time < reqtime)
			for(var/mob/V in hearers(src))
				V.show_message("<b>[src]</b>'s monitor flashes, \"[world.time - reqtime] seconds remaining until another requisition form may be printed.\"")
			return

		var/pack_name = copytext(href_list["doorder"], 1, lentext(href_list["doorder"]))
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
			var/tempcount = input(usr, "Amount:", "How many crates?", "") as num
			crates = Clamp(round(text2num(tempcount)), 1, 20)

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
		var/reason = stripped_input(usr,"Reason:","Why do you require this item?","",REASON_LEN)
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
		return 1
	else if (href_list["access_restriction"])
		if(!check_restriction(usr))
			return
		SSsupply_shuttle.restriction = text2num(href_list["access_restriction"])
		return 1
	else if (href_list["requisition_status"])
		if(!check_restriction(usr))
			return
		SSsupply_shuttle.requisition = text2num(href_list["requisition_status"])
		current_acct = get_account_info(usr, linked_db)
		return 1
	else if (href_list["screen"])
		if(!check_restriction(usr))
			return
		var/result = text2num(href_list["screen"])
		if(result == SCR_MAIN || result == SCR_CENTCOM)
			screen = result
		return 1
	else if (href_list["close"])
		current_acct = null
		if(usr.machine == src)
			usr.unset_machine()
		return 1

/obj/machinery/computer/supplycomp/proc/post_signal(var/command)


	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency)
		return

	var/datum/signal/status_signal = getFromPool(/datum/signal)
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	frequency.post_signal(src, status_signal)

/obj/machinery/computer/ordercomp
	name = "Supply ordering console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "request"
	circuit = "/obj/item/weapon/circuitboard/ordercomp"
	var/reqtime = 0 //Cooldown for requisitions - Quarxink
	var/last_viewed_group = "Supplies" // not sure how to get around hard coding this
	var/list/current_acct
	light_color = LIGHT_COLOR_BROWN

/obj/machinery/computer/ordercomp/New()
	. = ..()
	reconnect_database()

/obj/machinery/computer/ordercomp/initialize()
	reconnect_database()

/obj/machinery/computer/ordercomp/attack_ai(var/mob/user as mob)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/ordercomp/attack_hand(var/mob/user as mob)
	if(..())
		return
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

	// current supply group packs being displayed
	var/packs_list[0]
	for(var/set_name in SSsupply_shuttle.supply_packs)
		var/datum/supply_packs/pack = SSsupply_shuttle.supply_packs[set_name]
		if(!pack.contraband && !pack.hidden)
			if(last_viewed_group == pack.group)
				packs_list.Add(list(list("name" = pack.name, "amount" = pack.amount, "cost" = pack.cost, "command1" = list("doorder" = "[set_name]0"), "command2" = list("doorder" = "[set_name]1"))))
				// command1 is for a single crate order, command2 is for multi crate order
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
				orders_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name)))
	data["orders"] = orders_list
	var/datum/money_account/account = current_acct["account"]
	data["name_of_source_account"] = account.owner_name
	data["authorized_name"] = current_acct["authorized_name"]
	data["money"] = account.fmtBalance()

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "order_console.tmpl", name, 600, 660)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/ordercomp/Topic(href, href_list)
	if(..())
		return 1
	add_fingerprint(usr)
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
		var/pack_name = copytext(href_list["doorder"], 1, lentext(href_list["doorder"]))
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
			var/num_input = input(usr, "Amount:", "How many crates?", "") as num
			// Maximum 20 crates ordered at a time
			crates = Clamp(round(text2num(num_input)), 1, 20)

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
		var/reason = stripped_input(usr,"Reason:","Why do you require this item?","",REASON_LEN)
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
		if(usr.machine == src)
			usr.unset_machine()
		return 1

#undef SCR_MAIN
#undef SCR_CENTCOM
