/* Contents:
 - supplycomp (This one approves orders)
 - ordercomp (This is the public-facing one)
For the shuttle controller, see supplyshuttle.dm
For cargo crates, see supplypacks.dm
For vending packs, see vending_packs.dm*/

// returns an associate list of information needed for cargo consoles.  returns 0 if ID or account is missing
/proc/get_account_info(mob/user)
	var/list/acc_info = new
	var/obj/item/weapon/card/id/usr_id = user.get_id_card()
	if(ishuman(user))
		if(usr_id == null)
			to_chat(user, "<span class='warning'>Please wear an ID with an associated bank account.</span>")
			return 0
		acc_info["idname"] = usr_id.registered_name
		acc_info["idrank"] = usr_id.GetJobName()
	else if(issilicon(user))
		acc_info["idname"] = user.real_name
		acc_info["idrank"] = "Cyborg"
	var/datum/money_account/account = user.get_worn_id_account()
	if(!account)
		to_chat(user, "<span class='warning'>Please wear an ID with an associated bank account.</span>")
		return 0
	acc_info["account"] = account
	return acc_info

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
	var/datum/money_account/current_acct

	light_color = LIGHT_COLOR_BROWN

/obj/machinery/computer/supplycomp/attack_ai(var/mob/user as mob)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/supplycomp/proc/check_restriction(mob/user)
	if(!user)
		return FALSE
	var/result = FALSE
	switch(supply_shuttle.restriction)
		if(0)
			result = TRUE
		if(1)
			result = allowed(user)
		if(2)
			result = allowed(user) && iscarbon(user)
		if(3)
			result = pin_query(user)
	if(!result) //This saves a lot of pasted to_chat everywhere else
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

	current_acct = user.get_worn_id_account()
	if(current_acct == null) // don't do anything if they don't have an account they can use
		to_chat(user, "<span class='warning'>Please wear an ID with an associated bank account.</span>")
		return

	user.set_machine(src)
	post_signal("supply")

	ui_interact(user)

	onclose(user, "computer")

/obj/machinery/computer/supplycomp/attackby(I as obj, user as mob)
	if(istype(I,/obj/item/weapon/card/emag) && !hacked)
		to_chat(user, "<span class='notice'>Special supplies unlocked.</span>")
		hacked = 1
		return
	if(isscrewdriver(I))
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
	for(var/set_name in supply_shuttle.supply_packs)
		var/datum/supply_packs/pack = supply_shuttle.supply_packs[set_name]
		// Check if the pack is allowed to be shown
		if((pack.hidden && src.hacked) || (pack.contraband && src.can_order_contraband) || (!pack.contraband && !pack.hidden))
			if(last_viewed_group == pack.group)
				packs_list.Add(list(list("name" = pack.name, "amount" = pack.amount, "cost" = pack.cost, "command1" = list("doorder" = "[set_name]0"), "command2" = list("doorder" = "[set_name]1"))))
				// command1 is for a single crate order, command2 is for multi crate order

	data["supply_packs"] = packs_list

	var/requests_list[0]
	for(var/set_name in supply_shuttle.requestlist)
		var/datum/supply_order/SO = set_name
		if(SO)
			if(!SO.comment)
				SO.comment = "No reason provided."
			requests_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "comment" = SO.comment, "command1" = list("confirmorder" = SO.ordernum), "command2" = list("rreq" = SO.ordernum))))
	data["requests"] = requests_list

	var/orders_list[0]
	for(var/set_name in supply_shuttle.shoppinglist)
		var/datum/supply_order/SO = set_name
		if(SO)
			orders_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "comment" = SO.comment)))
	data["orders"] = orders_list
	data["money"] = current_acct.fmtBalance()
	data["send"] = list("send" = 1)
	data["moving"] = supply_shuttle.moving
	data["at_station"] = supply_shuttle.at_station
	data["show_permissions"] = permissions_screen
	data["restriction"] = supply_shuttle.restriction
	data["requisition"] = supply_shuttle.requisition

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "supply_console.tmpl", name, SCREEN_WIDTH, SCREEN_HEIGHT)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/supplycomp/Topic(href, href_list)
	if(!supply_shuttle)
		world.log << "## ERROR: Eek. The supply_shuttle controller datum is missing somehow."
		return
	if(..())
		return 1
	var/list/account_info = get_account_info(usr)
	if(!account_info)
		return
	var/idname = account_info["idname"]
	var/idrank = account_info["idrank"]
	var/datum/money_account/account = account_info["account"]
	if(supply_shuttle.requisition)
		account = department_accounts["Cargo"]
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
		else if(!supply_shuttle.can_move())
			to_chat(usr, "<span class='warning'>For safety reasons the automated supply shuttle cannot transport live organisms, classified nuclear weaponry or homing beacons.</span>")
		else if(!check_restriction(usr))
			to_chat(usr, "<span class='warning'>Your credentials were rejected by the current permissions protocol.</span>")

		else if(supply_shuttle.at_station)
			supply_shuttle.moving = -1
			supply_shuttle.sell()
			supply_shuttle.send()
		else
			supply_shuttle.moving = 1
			supply_shuttle.buy()
			supply_shuttle.eta_timeofday = (world.timeofday + supply_shuttle.movetime) % 864000
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
		var/datum/supply_packs/P = supply_shuttle.supply_packs[pack_name]
		if(!istype(P))
			return
		var/crates = 1
		if(multi)
			var/tempcount = input(usr, "Amount:", "How many crates?", "") as num
			crates = Clamp(round(text2num(tempcount)), 1, 20)

		// Calculate money tied up in requests
		var/total_money_req = 0
		for(var/i = 1; i <= length(supply_shuttle.requestlist); i++)
			var/datum/supply_order/R = supply_shuttle.requestlist[i]
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
		var/reason = copytext(sanitize(strict_ascii(input(usr, "Reason:", "Why do you require this item?", "") as null|text)), 1, REASON_LEN)
		if(world.time > timeout)
			return
		if(!reason)
			return

		var/obj/item/weapon/paper/reqform = new /obj/item/weapon/paper(loc)
		reqform.name = "[P.name] Requisition Form - [idname], [idrank]"
		reqform.info += {"<h3>[station_name] Supply Requisition Form</h3><hr>
			INDEX: #[supply_shuttle.ordernum]<br>
			REQUESTED BY: [idname]<br>
			RANK: [idrank]<br>
			REASON: [reason]<br>
			SUPPLY CRATE TYPE: [P.name]<br>
			NUMBER OF CRATES: [crates]<br>
			ACCESS RESTRICTION: [get_access_desc(P.access)]<br>
			CONTENTS:<br>"}
		reqform.info += P.manifest
		reqform.info += {"<hr>
			STAMP BELOW TO APPROVE THIS REQUISITION:<br>"}
		reqform.update_icon()	//Fix for appearing blank when printed.
		reqtime = (world.time + 5) % 1e5
		//make our supply_order datum
		for(var/i = 1; i <= crates; i++)
			supply_shuttle.ordernum++
			var/datum/supply_order/O = new /datum/supply_order()
			O.ordernum = supply_shuttle.ordernum
			O.object = P
			O.orderedby = idname
			O.account = account
			O.comment = reason

			supply_shuttle.requestlist += O

			if(!supply_shuttle.restriction) //If set to 0 restriction, auto-approve
				supply_shuttle.confirm_order(O,usr,supply_shuttle.requestlist.len)
		return 1
	else if(href_list["confirmorder"])
		//Find the correct supply_order datum
		if(!check_restriction(usr))
			return
		var/ordernum = text2num(href_list["confirmorder"])
		var/datum/supply_order/O
		for(var/i=1, i<=supply_shuttle.requestlist.len, i++)
			var/datum/supply_order/SO = supply_shuttle.requestlist[i]
			if(SO.ordernum == ordernum)
				O = SO
				supply_shuttle.confirm_order(O,usr,i)
				break
		return 1
	else if (href_list["rreq"])
		if(!check_restriction(usr))
			return
		var/ordernum = text2num(href_list["rreq"])
		for(var/i=1, i<=supply_shuttle.requestlist.len, i++)
			var/datum/supply_order/SO = supply_shuttle.requestlist[i]
			if(SO.ordernum == ordernum)
				supply_shuttle.requestlist.Cut(i,i+1)
				break
		return 1
	else if (href_list["last_viewed_group"])
		last_viewed_group = href_list["last_viewed_group"]
		return 1
	else if (href_list["access_restriction"])
		if(!check_restriction(usr))
			return
		supply_shuttle.restriction = text2num(href_list["access_restriction"])
		return 1
	else if (href_list["requisition_status"])
		if(!check_restriction(usr))
			return
		supply_shuttle.requisition = text2num(href_list["requisition_status"])
		return 1
	else if (href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()
		return 1

	add_fingerprint(usr)

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
	var/datum/money_account/current_acct

	light_color = LIGHT_COLOR_BROWN

/obj/machinery/computer/ordercomp/attack_ai(var/mob/user as mob)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/ordercomp/attack_hand(var/mob/user as mob)
	if(..())
		return
	current_acct = user.get_worn_id_account()
	if(current_acct == null) // don't do anything if they don't have an account they can use
		to_chat(user, "<span class='warning'>Please wear an ID with an associated bank account.</span>")
		return
	user.set_machine(src)
	ui_interact(user)
	onclose(user, "computer")
	return

/obj/machinery/computer/ordercomp/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
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
	for(var/set_name in supply_shuttle.supply_packs)
		var/datum/supply_packs/pack = supply_shuttle.supply_packs[set_name]
		if(!pack.contraband && !pack.hidden)
			if(last_viewed_group == pack.group)
				packs_list.Add(list(list("name" = pack.name, "amount" = pack.amount, "cost" = pack.cost, "command1" = list("doorder" = "[set_name]0"), "command2" = list("doorder" = "[set_name]1"))))
				// command1 is for a single crate order, command2 is for multi crate order
	data["supply_packs"] = packs_list

	var/obj/item/weapon/card/id/I = user.get_id_card()
	// current usr's cargo requests
	var/requests_list[0]
	for(var/set_name in supply_shuttle.requestlist)
		var/datum/supply_order/SO = set_name
		if(SO)
			// Check if usr owns the request
			if(I && SO.orderedby == I.registered_name)
				requests_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "command1" = list("rreq" = SO.ordernum))))
	data["requests"] = requests_list

	var/orders_list[0]
	for(var/set_name in supply_shuttle.shoppinglist)
		var/datum/supply_order/SO = set_name
		if(SO )
			// Check if usr owns the order
			if(I && SO.orderedby == I.registered_name)
				orders_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name)))
	data["orders"] = orders_list
	data["money"] = current_acct.fmtBalance()

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "order_console.tmpl", name, SCREEN_WIDTH, SCREEN_HEIGHT)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/ordercomp/Topic(href, href_list)
	if(..())
		return 1

	if( isturf(loc) && (in_range(src, usr) || istype(usr, /mob/living/silicon)) )
		usr.set_machine(src)

	var/list/account_info = get_account_info(usr)
	if(!account_info)
		return
	var/idname = account_info["idname"]
	var/idrank = account_info["idrank"]
	var/datum/money_account/account = account_info["account"]

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
		var/datum/supply_packs/P = supply_shuttle.supply_packs[pack_name]
		if(!istype(P))
			return
		var/crates = 1
		if(multi)
			var/num_input = input(usr, "Amount:", "How many crates?", "") as num
			// Maximum 20 crates ordered at a time
			crates = Clamp(round(text2num(num_input)), 1, 20)

		// Calculate money tied up in usr's requests
		var/total_money_req = 0
		for(var/i = 1; i <= length(supply_shuttle.requestlist); i++)
			var/datum/supply_order/R = supply_shuttle.requestlist[i]
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
		var/reason = copytext(sanitize(strict_ascii(input(usr,"Reason:","Why do you require this item?","") as null|text)),1,REASON_LEN)
		if(world.time > timeout)
			return
		if(!reason)
			return

		var/obj/item/weapon/paper/reqform = new /obj/item/weapon/paper(loc)
		reqform.name = "[P.name] Requisition Form - [idname], [idrank]"

		reqform.info += {"<h3>[station_name] Supply Requisition Form</h3><hr>
			INDEX: #[supply_shuttle.ordernum]<br>
			REQUESTED BY: [idname]<br>
			RANK: [idrank]<br>
			REASON: [reason]<br>
			SUPPLY CRATE TYPE: [P.name]<br>
			NUMBER OF CRATES: [crates]<br>
			ACCESS RESTRICTION: [get_access_desc(P.access)]<br>
			CONTENTS:<br>"}
		reqform.info += P.manifest

		reqform.info += {"<hr>
			STAMP BELOW TO APPROVE THIS REQUISITION:<br>"}
		reqform.update_icon()	//Fix for appearing blank when printed.
		reqtime = (world.time + 5) % 1e5

		//make our supply_order datum
		for(var/i = 1; i <= crates; i++)
			supply_shuttle.ordernum++
			var/datum/supply_order/O = new /datum/supply_order()
			O.ordernum = supply_shuttle.ordernum
			O.object = P
			O.orderedby = idname
			O.account = account
			O.comment = reason
			supply_shuttle.requestlist += O
			stat_collection.crates_ordered++

			if(!supply_shuttle.restriction) //Restriction = 0, auto order
				supply_shuttle.confirm_order(O,usr,supply_shuttle.requestlist.len) //Position: last
		return 1
	else if (href_list["last_viewed_group"])
		last_viewed_group = href_list["last_viewed_group"]
		return 1
	else if (href_list["rreq"])
		var/ordernum = text2num(href_list["rreq"])
		for(var/i=1, i<=supply_shuttle.requestlist.len, i++)
			var/datum/supply_order/SO = supply_shuttle.requestlist[i]
			if(SO.ordernum == ordernum)
				supply_shuttle.requestlist.Cut(i,i+1)
				break
		return 1
	else if (href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()
		return 1

	add_fingerprint(usr)
