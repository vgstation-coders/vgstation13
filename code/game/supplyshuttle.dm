//Config stuff
#define SUPPLY_DOCKZ 2          //Z-level of the Dock.
#define SUPPLY_STATIONZ 1       //Z-level of the Station.

#define SUPPLY_TAX 10 // Credits to charge per order.
#define SCREEN_WIDTH 480 // Dimensions of supply computer windows
#define SCREEN_HEIGHT 590
#define REASON_LEN 140 // max length for reason message, nanoui appears to not like long strings.
var/datum/controller/supply_shuttle/supply_shuttle = new

var/list/mechtoys = list(
	/obj/item/toy/prize/ripley,
	/obj/item/toy/prize/fireripley,
	/obj/item/toy/prize/deathripley,
	/obj/item/toy/prize/gygax,
	/obj/item/toy/prize/durand,
	/obj/item/toy/prize/honk,
	/obj/item/toy/prize/marauder,
	/obj/item/toy/prize/seraph,
	/obj/item/toy/prize/mauler,
	/obj/item/toy/prize/odysseus,
	/obj/item/toy/prize/phazon
)
//SUPPLY PACKS MOVED TO /code/defines/obj/supplypacks.dm

/obj/structure/plasticflaps //HOW DO YOU CALL THOSE THINGS ANYWAY
	name = "\improper Plastic flaps"
	desc = "I definitely can't get past those. No way."
	icon = 'icons/obj/stationobjs.dmi' //Change this.
	icon_state = "plasticflaps"
	density = 0
	anchored = 1
	plane = ABOVE_HUMAN_PLANE
	explosion_resistance = 5
	var/airtight = 0

/obj/structure/plasticflaps/attackby(obj/item/I as obj, mob/user as mob)
	if(iscrowbar(I) && anchored == 1)
		if(airtight == 0)
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		else
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		user.visible_message("[user] [airtight? "loosen the [src] from" : "tighten the [src] into"] an airtight position.", "You [airtight? "loosen the [src] from" : "tighten the [src] into"] an airtight position.")
		airtight = !airtight
		name = "\improper [airtight? "Airtight p" : "P"]lastic flaps"
		desc = "[airtight? "Heavy duty, airtight, plastic flaps." : "I definitely can't get past those. No way."]"
		return 1
	if(iswrench(I) && airtight != 1)
		if(anchored == 0)
			playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
		else
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		user.visible_message("[user] [anchored? "loosens" : "tightens"] the flap from its anchoring.", "You [anchored? "loosen" : "tighten"] the flap from its anchoring.")
		anchored = !anchored
		return 1
	else if (iswelder(I) && anchored == 0)
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.remove_fuel(0, user))
			new /obj/item/stack/sheet/mineral/plastic (src.loc,10)
			qdel(src)
			return
	return ..()

/obj/structure/plasticflaps/examine(mob/user as mob)
	..()
	to_chat(user, "It appears to be [anchored? "anchored to" : "unachored from"] the floor, [airtight? "and it seems to be airtight as well." : "but it does not seem to be airtight."]")

/obj/structure/plasticflaps/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return prob(60)

	var/obj/structure/bed/B = mover
	if (istype(mover, /obj/structure/bed) && B.locked_atoms.len)//if it's a bed/chair and someone is locked_to, it will not pass
		return 0

	else if(isliving(mover)) // You Shall Not Pass!
		var/mob/living/M = mover
		if(!M.lying && !istype(M, /mob/living/carbon/monkey) && !istype(M, /mob/living/carbon/slime) && !istype(M, /mob/living/simple_animal/mouse))  //If your not laying down, or a small creature, no pass.
			return 0
	if(!istype(mover)) // Aircheck!
		return !airtight
	return 1

/obj/structure/plasticflaps/ex_act(severity)
	switch(severity)
		if (1)
			qdel(src)
		if (2)
			if (prob(50))
				qdel(src)
		if (3)
			if (prob(5))
				qdel(src)

/obj/structure/plasticflaps/mining
	name = "\improper Airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps."
	airtight = 1

/obj/structure/plasticflaps/cultify()
	new /obj/structure/grille/cult(get_turf(src))
	..()

/obj/machinery/computer/supplycomp
	name = "Supply shuttle console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "supply"
	req_access = list(access_cargo)
	circuit = "/obj/item/weapon/circuitboard/supplycomp"
	var/reqtime = 0 //Cooldown for requisitions - Quarxink
	var/hacked = 0
	var/can_order_contraband = 0
	var/last_viewed_group = "Supplies" // not sure how to get around hard coding this
	var/datum/money_account/current_acct

	light_color = LIGHT_COLOR_BROWN

/obj/machinery/computer/ordercomp
	name = "Supply ordering console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "request"
	circuit = "/obj/item/weapon/circuitboard/ordercomp"
	var/reqtime = 0 //Cooldown for requisitions - Quarxink
	var/last_viewed_group = "Supplies" // not sure how to get around hard coding this
	var/datum/money_account/current_acct

	light_color = LIGHT_COLOR_BROWN

/*
/obj/effect/marker/supplymarker
	icon_state = "X"
	icon = 'icons/misc/mark.dmi'
	name = "X"
	invisibility = 101
	anchored = 1
	opacity = 0
*/

/datum/supply_order
	var/ordernum
	var/datum/supply_packs/object = null
	var/datum/money_account/account = null
	var/orderedby = null
	var/comment = null

/datum/controller/supply_shuttle
	processing = 1
	processing_interval = 300
	//supply points have been replaced with MONEY MONEY MONEY - N3X
	var/credits_per_slip = 2
	var/credits_per_crate = 5
	//var/credits_per_plasma = 0.5 // 2 plasma for 1 point
	//control
	var/ordernum
	var/list/centcomm_orders = list()
	var/list/shoppinglist = list()
	var/list/requestlist = list()
	var/list/supply_packs = list()
	//shuttle movement
	var/at_station = 0
	var/movetime = 1200
	var/moving = 0
	var/eta_timeofday
	var/eta
	var/datum/materials/materials_list = new

/datum/controller/supply_shuttle/New()
	ordernum = rand(1,9000)

	//Supply shuttle ticker - handles supply point regenertion and shuttle travelling between centcomm and the station
/datum/controller/supply_shuttle/proc/process()
	for(var/typepath in (typesof(/datum/supply_packs) - /datum/supply_packs))
		var/datum/supply_packs/P = new typepath()
		supply_packs[P.name] = P

	spawn(0)
		//set background = 1
		while(1)
			if(processing)
				iteration++

				if(moving == 1)
					var/ticksleft = (eta_timeofday - world.timeofday)
					if(ticksleft > 0)
						eta = round(ticksleft/600,1)
					else
						eta = 0
						send()


			sleep(processing_interval)

/datum/controller/supply_shuttle/proc/send()

	var/obj/docking_port/destination

	if(!at_station) //not at station
		destination = cargo_shuttle.dock_station

		at_station = 1

		if(!destination)
			message_admins("WARNING: Cargo shuttle unable to find the station!")
			warning("Cargo shuttle can't find centcomm")
	else //at station
		for(var/obj/structure/shuttle/engine/propulsion/P in cargo_shuttle.linked_area)
			spawn()
				P.shoot_exhaust()
		sleep(3)
		destination = cargo_shuttle.dock_centcom

		at_station = 0

		if(!destination)
			message_admins("WARNING: Cargo shuttle unable to find centcomm!")
			warning("Cargo shuttle can't find centcomm")

	cargo_shuttle.move_to_dock(destination)
	moving = 0

	//Check whether the shuttle is allowed to move
/datum/controller/supply_shuttle/proc/can_move()
	if(moving)
		return 0

	if(forbidden_atoms_check(cargo_shuttle.linked_area))
		return 0

	return 1

/datum/controller/supply_shuttle/proc/SellObjToOrders(var/atom/A,var/in_crate)


	// Per-unit orders run last so they don't steal shit.
	var/list/deferred_order_checks=list()
	var/order_idx=0
	for(var/datum/centcomm_order/O in centcomm_orders)
		order_idx++
		if(istype(O,/datum/centcomm_order/per_unit))
			deferred_order_checks += order_idx
		if(O.CheckShuttleObject(A,in_crate))
			return
	for(var/oid in deferred_order_checks)
		var/datum/centcomm_order/O = centcomm_orders[oid]
		if(O.CheckShuttleObject(A,in_crate))
			return
	//Sellin

/datum/controller/supply_shuttle/proc/sell()

	var/area/shuttle = cargo_shuttle.linked_area
	if(!shuttle)
		return

	var/datum/money_account/cargo_acct = department_accounts["Cargo"]

	for(var/atom/movable/MA in shuttle)
		if(MA.anchored)
			continue

		if(istype(MA, /obj/item/stack/sheet/mineral/plasma))
			var/obj/item/stack/sheet/mineral/plasma/P = MA
			if(P.redeemed)
				continue
			var/datum/material/mat = materials_list.getMaterial(P.sheettype)
			cargo_acct.money += (mat.value * 2) * P.amount // Central Command pays double for plasma they receive that hasn't been redeemed already.

		// Must be in a crate!
		else if(istype(MA,/obj/structure/closet/crate))
			cargo_acct.money += credits_per_crate
			var/find_slip = 1

			for(var/atom/A in MA)
				if(istype(A, /obj/item/stack/sheet/mineral/plasma))
					var/obj/item/stack/sheet/mineral/plasma/P = A
					if(P.redeemed)
						continue
					var/datum/material/mat = materials_list.getMaterial(P.sheettype)
					cargo_acct.money += (mat.value * 2) * P.amount // Central Command pays double for plasma they receive that hasn't been redeemed already.
					continue
				if(find_slip && istype(A,/obj/item/weapon/paper/manifest))
					var/obj/item/weapon/paper/slip = A
					if(slip.stamped && slip.stamped.len) //yes, the clown stamp will work. clown is the highest authority on the station, it makes sense
						cargo_acct.money += credits_per_slip
						find_slip = 0
					qdel(A)
					continue

				SellObjToOrders(A,0)

				// Delete it. (Fixes github #473)
				if(A)
					qdel(A)
		else
			SellObjToOrders(MA,1)

		// PAY UP BITCHES
		for(var/datum/centcomm_order/O in centcomm_orders)
			if(O.CheckFulfilled())
				O.Pay()
				centcomm_orders -= O
//		to_chat(world, "deleting [MA]/[MA.type] it was [!MA.anchored ? "not ": ""] anchored")
		qdel(MA)

	//Buyin
/datum/controller/supply_shuttle/proc/buy()
	if(!shoppinglist.len)
		return

	var/area/shuttle = cargo_shuttle.linked_area
	if(!shuttle)
		return

	var/list/clear_turfs = list()

	for(var/turf/T in shuttle)
		if(T.density)
			continue
		var/contcount
		for(var/atom/A in T.contents)
			if(islightingoverlay(A))
				continue
			contcount++
		if(contcount)
			continue
		clear_turfs += T

	for(var/S in shoppinglist)
		if(!clear_turfs.len)
			break
		var/i = rand(1,clear_turfs.len)
		var/turf/pickedloc = clear_turfs[i]
		clear_turfs.Cut(i,i+1)

		var/datum/supply_order/SO = S
		var/datum/supply_packs/SP = SO.object

		var/atom/A = new SP.containertype(pickedloc)
		A.name = "[SP.containername] [SO.comment ? "([SO.comment])":"" ]"

		//supply manifest generation begin

		var/obj/item/weapon/paper/manifest/slip = new /obj/item/weapon/paper/manifest(A)

		slip.name = "Shipping Manifest for [SO.orderedby]'s Order"
		slip.info = {"<h3>[command_name()] Shipping Manifest for [SO.orderedby]'s Order</h3><hr><br>
			Order #[SO.ordernum]<br>
			Destination: [station_name]<br>
			[supply_shuttle.shoppinglist.len] PACKAGES IN THIS SHIPMENT<br>
			CONTENTS:<br><ul>"}
		//spawn the stuff, finish generating the manifest while you're at it
		if(SP.access)
			A:req_access = list()
			A:req_access += text2num(SP.access)

		var/list/contains
		if(istype(SP,/datum/supply_packs/randomised))
			var/datum/supply_packs/randomised/SPR = SP
			contains = list()
			if(SPR.contains.len)
				for(var/j=1,j<=SPR.num_contained,j++)
					contains += pick(SPR.contains)
		else
			contains = SP.contains

		for(var/typepath in contains)
			if(!typepath)
				continue
			var/atom/B2 = new typepath(A)
			if(SP.amount && B2:amount)
				B2:amount = SP.amount
			slip.info += "<li>[B2.name]</li>" //add the item to the manifest

		//manifest finalisation

		slip.info += {"</ul><br>
			CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>"}
		if (SP.contraband)
			slip.forceMove(null)	//we are out of blanks for Form #44-D Ordering Illicit Drugs.
		shoppinglist.Remove(S)

/datum/controller/supply_shuttle/proc/forbidden_atoms_check(atom/A)
	var/contents = get_contents_in_object(A)

	if (locate(/mob/living) in contents)
		. = TRUE
	else if (locate(/obj/item/weapon/disk/nuclear) in contents)
		. = TRUE
	else if (locate(/obj/machinery/nuclearbomb) in contents)
		. = TRUE
	else if (locate(/obj/item/beacon) in contents)
		. = TRUE
	else if (locate(/obj/effect/portal) in contents)//you crafty fuckers
		. = TRUE
	else
		. = FALSE

/obj/item/weapon/paper/manifest
	name = "Supply Manifest"

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

/obj/machinery/computer/ordercomp/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/supplycomp/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
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

/obj/machinery/computer/ordercomp/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
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

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if(!ui)
		ui = new(user, src, ui_key, "order_console.tmpl", name, SCREEN_WIDTH, SCREEN_HEIGHT)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/ordercomp/Topic(href, href_list)
	if(..())
		return

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
				total_money_req += R_pack.cost + SUPPLY_TAX
		// Check they have enough cash to order another crate
		if(((P.cost + SUPPLY_TAX) * crates + total_money_req > account.money))
			// Tell them how many they can actually afford if they can't afford their order
			var/max_crates = round((account.money - total_money_req) / (P.cost + SUPPLY_TAX))
			to_chat(usr, "<span class='warning'>You can only afford [max_crates] crates.</span>")
			return
		var/reason = copytext(sanitize(input(usr,"Reason:","Why do you require this item?","") as null|text),1,REASON_LEN)
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

	else if (href_list["last_viewed_group"])
		last_viewed_group = href_list["last_viewed_group"]

	else if (href_list["rreq"])
		var/ordernum = text2num(href_list["rreq"])
		for(var/i=1, i<=supply_shuttle.requestlist.len, i++)
			var/datum/supply_order/SO = supply_shuttle.requestlist[i]
			if(SO.ordernum == ordernum)
				supply_shuttle.requestlist.Cut(i,i+1)
				break

	else if (href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()
		return 1

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/supplycomp/attack_hand(var/mob/user as mob)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied.</span>")
		return

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
	return

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

/obj/machinery/computer/supplycomp/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
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

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
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
	//Calling the shuttle
	if(href_list["send"])
		if(!map.linked_to_centcomm)
			to_chat(usr, "<span class='warning'>You aren't able to establish contact with central command, so the shuttle won't move.</span>")
		else if(!supply_shuttle.can_move())
			to_chat(usr, "<span class='warning'>For safety reasons the automated supply shuttle cannot transport live organisms, classified nuclear weaponry or homing beacons.</span>")
		else if(supply_shuttle.at_station)
			supply_shuttle.moving = -1
			supply_shuttle.sell()
			supply_shuttle.send()
		else
			supply_shuttle.moving = 1
			supply_shuttle.buy()
			supply_shuttle.eta_timeofday = (world.timeofday + supply_shuttle.movetime) % 864000
			post_signal("supply")

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
				total_money_req += R_pack.cost + SUPPLY_TAX
		// check they can afford the order
		if((P.cost + SUPPLY_TAX) * crates + total_money_req > account.money)
			var/max_crates = round((account.money - total_money_req) / (P.cost + SUPPLY_TAX))
			to_chat(usr, "<span class='warning'>You can only afford [max_crates] crates.</span>")
			return
		var/timeout = world.time + 600
		var/reason = copytext(sanitize(input(usr, "Reason:", "Why do you require this item?", "") as null|text), 1, REASON_LEN)
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

	else if(href_list["confirmorder"])
		//Find the correct supply_order datum
		var/ordernum = text2num(href_list["confirmorder"])
		var/datum/supply_order/O
		var/datum/supply_packs/P
		var/datum/money_account/A
		var/datum/money_account/cargo_acct = department_accounts["Cargo"]
		for(var/i=1, i<=supply_shuttle.requestlist.len, i++)
			var/datum/supply_order/SO = supply_shuttle.requestlist[i]
			if(SO.ordernum == ordernum)
				O = SO
				P = O.object
				A = SO.account
				if(A && A.money >= P.cost + SUPPLY_TAX)
					supply_shuttle.requestlist.Cut(i,i+1)
					var/cargo_share = round(((P.cost)/100)*20)
					var/centcom_share = (P.cost)-cargo_share
					A.charge(centcom_share,null,"Supply Order #[SO.ordernum] ([P.name])",src.name,dest_name = "CentComm")
					A.charge(cargo_share,cargo_acct,"Order Tax",src.name)
					supply_shuttle.shoppinglist += O
				else
					to_chat(usr, "<span class='warning'>[SO.orderedby] does not have enough funds for this request.</span>")
				break
	else if (href_list["rreq"])
		var/ordernum = text2num(href_list["rreq"])
		for(var/i=1, i<=supply_shuttle.requestlist.len, i++)
			var/datum/supply_order/SO = supply_shuttle.requestlist[i]
			if(SO.ordernum == ordernum)
				supply_shuttle.requestlist.Cut(i,i+1)
				break

	else if (href_list["last_viewed_group"])
		last_viewed_group = href_list["last_viewed_group"]

	else if (href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()
		return 1

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/supplycomp/proc/post_signal(var/command)


	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency)
		return

	var/datum/signal/status_signal = getFromPool(/datum/signal)
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	frequency.post_signal(src, status_signal)
