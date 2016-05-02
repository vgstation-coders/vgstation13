//Config stuff
#define SUPPLY_DOCKZ 2          //Z-level of the Dock.
#define SUPPLY_STATIONZ 1       //Z-level of the Station.

#define SUPPLY_TAX 10 // Credits to charge per order.
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
	layer = 4
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
	var/temp = null
	var/reqtime = 0 //Cooldown for requisitions - Quarxink
	var/hacked = 0
	var/can_order_contraband = 0
	var/last_viewed_group = "categories"
	var/datum/money_account/current_acct

	light_color = LIGHT_COLOR_BROWN

/obj/machinery/computer/ordercomp
	name = "Supply ordering console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "request"
	circuit = "/obj/item/weapon/circuitboard/ordercomp"
	var/temp = null
	var/reqtime = 0 //Cooldown for requisitions - Quarxink
	var/last_viewed_group = "categories"
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
		destination = cargo_shuttle.dock_centcom

		at_station = 0

		if(!destination)
			message_admins("WARNING: Cargo shuttle unable to find centcomm!")
			warning("Cargo shuttle can't find centcomm")

	cargo_shuttle.move_to_dock(destination)
	moving = 0

	//Check whether the shuttle is allowed to move
/datum/controller/supply_shuttle/proc/can_move()
	if(moving) return 0

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
	if(!shuttle)	return

	var/datum/money_account/cargo_acct = department_accounts["Cargo"]

	for(var/atom/movable/MA in shuttle)
		if(MA.anchored)	continue

		if(istype(MA, /obj/item/stack/sheet/mineral/plasma))
			var/obj/item/stack/sheet/mineral/plasma/P = MA
			if(P.redeemed) continue
			var/datum/material/mat = materials_list.getMaterial(P.sheettype)
			cargo_acct.money += (mat.value * 2) * P.amount // Central Command pays double for plasma they receive that hasn't been redeemed already.

		// Must be in a crate!
		else if(istype(MA,/obj/structure/closet/crate))
			cargo_acct.money += credits_per_crate
			var/find_slip = 1

			for(var/atom/A in MA)
				if(istype(A, /obj/item/stack/sheet/mineral/plasma))
					var/obj/item/stack/sheet/mineral/plasma/P = A
					if(P.redeemed) continue
					var/datum/material/mat = materials_list.getMaterial(P.sheettype)
					cargo_acct.money += (mat.value * 2) * P.amount // Central Command pays double for plasma they receive that hasn't been redeemed already.
					continue
				if(find_slip && istype(A,/obj/item/weapon/paper/manifest))
					var/obj/item/weapon/paper/slip = A
					if(slip.stamped && slip.stamped.len) //yes, the clown stamp will work. clown is the highest authority on the station, it makes sense
						cargo_acct.money += credits_per_slip
						find_slip = 0
					continue

				SellObjToOrders(A,0)

				// Delete it. (Fixes github #473)
				if(A) qdel(A)
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
	if(!shoppinglist.len) return

	var/area/shuttle = cargo_shuttle.linked_area
	if(!shuttle)	return

	var/list/clear_turfs = list()

	for(var/turf/T in shuttle)
		if(T.density)	continue
		var/contcount
		for(var/atom/A in T.contents)
			if(islightingoverlay(A))
				continue
			contcount++
		if(contcount)
			continue
		clear_turfs += T

	for(var/S in shoppinglist)
		if(!clear_turfs.len)	break
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
			if(!typepath)	continue
			var/atom/B2 = new typepath(A)
			if(SP.amount && B2:amount) B2:amount = SP.amount
			slip.info += "<li>[B2.name]</li>" //add the item to the manifest

		//manifest finalisation

		slip.info += {"</ul><br>
			CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>"}
		if (SP.contraband) slip.loc = null	//we are out of blanks for Form #44-D Ordering Illicit Drugs.

	supply_shuttle.shoppinglist.len = 0
	return

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


/obj/machinery/computer/ordercomp/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/ordercomp/attack_paw(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/supplycomp/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/supplycomp/attack_paw(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/ordercomp/attack_hand(var/mob/user as mob)
	if(..())
		return
	current_acct = user.get_worn_id_account()
	user.set_machine(src)
	var/dat
	if(temp)
		dat = temp
	else
		dat += {"<BR><B>Supply shuttle</B><HR>
		Location: [supply_shuttle.moving ? "Moving to station ([supply_shuttle.eta] Mins.)":supply_shuttle.at_station ? "Station":"Dock"]<BR>
		<HR>Bank account credits: [current_acct ? current_acct.fmtBalance() : "PANIC"]<BR>
		<BR>\n<A href='?src=\ref[src];order=categories'>Request items</A><BR><BR>
		<A href='?src=\ref[src];vieworders=1'>View approved orders</A><BR><BR>
		<A href='?src=\ref[src];viewrequests=1'>View requests</A><BR><BR>
		<A href='?src=\ref[user];mach_close=computer'>Close</A>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return

/obj/machinery/computer/ordercomp/Topic(href, href_list)
	if(..())
		return

	if( isturf(loc) && (in_range(src, usr) || istype(usr, /mob/living/silicon)) )
		usr.set_machine(src)

	if(href_list["order"])
		if(href_list["order"] == "categories")
			//all_supply_groups
			//Request what?
			last_viewed_group = "categories"

			temp = {"<b>Bank account credits: [current_acct ? current_acct.fmtBalance() : "PANIC"]</b><BR>
				<A href='?src=\ref[src];mainmenu=1'>Main Menu</A><HR><BR><BR>
				<b>Select a category</b><BR><BR>"}
			for(var/supply_group_name in all_supply_groups )
				temp += "<A href='?src=\ref[src];order=[supply_group_name]'>[supply_group_name]</A><BR>"
		else
			last_viewed_group = href_list["order"]

			temp = {"<b>Bank account credits: [current_acct ? current_acct.fmtBalance() : "PANIC"]</b><BR>
				<A href='?src=\ref[src];order=categories'>Back to all categories</A><HR><BR><BR>
				<b>Request from: [last_viewed_group]</b><BR><BR>"}
			for(var/supply_name in supply_shuttle.supply_packs )
				var/datum/supply_packs/N = supply_shuttle.supply_packs[supply_name]
				if(N.hidden || N.contraband || N.group != last_viewed_group) continue								//Have to send the type instead of a reference to
				temp += "<A href='?src=\ref[src];doorder=[supply_name]'>[supply_name]</A> Cost: $[num2septext(N.cost)]<BR>"		//the obj because it would get caught by the garbage

	else if (href_list["doorder"])
		if(world.time < reqtime)
			for(var/mob/V in hearers(src))
				V.show_message("<b>[src]</b>'s monitor flashes, \"[world.time - reqtime] seconds remaining until another requisition form may be printed.\"")
			return

		//Find the correct supply_pack datum
		var/datum/supply_packs/P = supply_shuttle.supply_packs[href_list["doorder"]]
		if(!istype(P))	return

		var/timeout = world.time + 600
		var/reason = copytext(sanitize(input(usr,"Reason:","Why do you require this item?","") as null|text),1,MAX_MESSAGE_LEN)
		if(world.time > timeout)	return
		if(!reason)	return

		var/idname = "*None Provided*"
		var/idrank = "*None Provided*"
		var/datum/money_account/account
		if(ishuman(usr))
			var/obj/item/weapon/card/id/I = usr.get_id_card()
			if(I)
				idname = I.registered_name
				idrank = I.GetJobName()
				account = get_card_account(I)
			else
				to_chat(usr, "<span class='warning'>Please wear an ID with an associated bank account.</span>")
				return
			to_chat(usr, "[bicon(src)]<span class='notice'>Your request has been saved. The transaction will be performed to your bank account when it has been accepted by cargo staff.</span>")
			if(account && (account.money < P.cost))
				to_chat(usr, "[bicon(src)]<span class='warning'>Your bank account doesn't have enough funds to order this pack. Your request will be on hold until you provide your bank account with the necessary funds.</span>")
		else if(issilicon(usr))
			idname = usr.real_name
			account = station_account

		supply_shuttle.ordernum++
		var/obj/item/weapon/paper/reqform = new /obj/item/weapon/paper(loc)
		reqform.name = "[P.name] Requisition Form - [idname], [idrank]"

		reqform.info += {"<h3>[station_name] Supply Requisition Form</h3><hr>
			INDEX: #[supply_shuttle.ordernum]<br>
			REQUESTED BY: [idname]<br>
			RANK: [idrank]<br>
			REASON: [reason]<br>
			SUPPLY CRATE TYPE: [P.name]<br>
			ACCESS RESTRICTION: [get_access_desc(P.access)]<br>
			CONTENTS:<br>"}
		reqform.info += P.manifest

		reqform.info += {"<hr>
			STAMP BELOW TO APPROVE THIS REQUISITION:<br>"}
		reqform.update_icon()	//Fix for appearing blank when printed.
		reqtime = (world.time + 5) % 1e5

		//make our supply_order datum
		var/datum/supply_order/O = new /datum/supply_order()
		O.ordernum = supply_shuttle.ordernum
		O.object = P
		O.orderedby = idname
		O.account = account
		supply_shuttle.requestlist += O
		stat_collection.crates_ordered++


		temp = {"Thanks for your request. The cargo team will process it as soon as possible.<BR>
			<BR><A href='?src=\ref[src];order=[last_viewed_group]'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"}
	else if (href_list["vieworders"])
		temp = "Current approved orders: <BR><BR>"
		for(var/S in supply_shuttle.shoppinglist)
			var/datum/supply_order/SO = S
			temp += "[SO.object.name] approved by [SO.orderedby] [SO.comment ? "([SO.comment])":""]<BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["viewrequests"])
		temp = "Current requests: <BR><BR>"
		for(var/S in supply_shuttle.requestlist)
			var/datum/supply_order/SO = S
			temp += "#[SO.ordernum] - [SO.object.name] requested by [SO.orderedby]<BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["mainmenu"])
		temp = null

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

	user.set_machine(src)
	post_signal("supply")

	var/dat
	if (temp)
		dat = temp
	else
		dat += {"<BR><B>Supply shuttle</B><HR>
		\nLocation: [supply_shuttle.moving ? "Moving to station ([supply_shuttle.eta] Mins.)":supply_shuttle.at_station ? "Station":"Away"]<BR>
		<HR>\nAvailable Credits: [current_acct ? current_acct.fmtBalance() : "N/A"]<BR>\n<BR>
		[supply_shuttle.moving ? "\n*Must be away to order items*<BR>\n<BR>":supply_shuttle.at_station ? "\n*Must be away to order items*<BR>\n<BR>":"\n<A href='?src=\ref[src];order=categories'>Order items</A><BR>\n<BR>"]
		[supply_shuttle.moving ? "\n*Shuttle already called*<BR>\n<BR>":supply_shuttle.at_station ? "\n<A href='?src=\ref[src];send=1'>Send away</A><BR>\n<BR>":"\n<A href='?src=\ref[src];send=1'>Send to station</A><BR>\n<BR>"]
		\n<A href='?src=\ref[src];viewrequests=1'>View requests</A><BR>\n<BR>
		\n<A href='?src=\ref[src];vieworders=1'>View orders</A><BR>\n<BR>
		\n<A href='?src=\ref[user];mach_close=computer'>Close</A>"}

	user << browse(dat, "window=computer;size=575x450")
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
					C.loc = loc
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
					C.loc = loc
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				qdel(src)
	else
		return ..()

/obj/machinery/computer/supplycomp/Topic(href, href_list)

	if(!supply_shuttle)
		world.log << "## ERROR: Eek. The supply_shuttle controller datum is missing somehow."
		return
	if(..())
		return 1
	//Calling the shuttle
	if(href_list["send"])
		if(!map.linked_to_centcomm)
			temp = "You aren't able to establish contact with central command, so the shuttle won't move. <BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		else if(!supply_shuttle.can_move())
			temp = "For safety reasons the automated supply shuttle cannot transport live organisms, classified nuclear weaponry or homing beacons.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		else if(supply_shuttle.at_station)
			supply_shuttle.moving = -1
			supply_shuttle.sell()
			supply_shuttle.send()
			temp = "The supply shuttle has departed.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		else
			supply_shuttle.moving = 1
			supply_shuttle.buy()
			supply_shuttle.eta_timeofday = (world.timeofday + supply_shuttle.movetime) % 864000
			temp = "The supply shuttle has been called and will arrive in [round(supply_shuttle.movetime/600,1)] minutes.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
			post_signal("supply")
	else if (href_list["order"])
		if(supply_shuttle.moving) return
		if(href_list["order"] == "categories")
			//all_supply_groups
			//Request what?
			last_viewed_group = "categories"
			temp = {"<b>Available credits: [current_acct ? current_acct.fmtBalance() : "PANIC"]</b><BR>
				<A href='?src=\ref[src];mainmenu=1'>Main Menu</A><HR><BR><BR>
				<b>Select a category</b><BR><BR>"}
			for(var/supply_group_name in all_supply_groups )
				temp += "<A href='?src=\ref[src];order=[supply_group_name]'>[supply_group_name]</A><BR>"
		else
			last_viewed_group = href_list["order"]
			temp = {"<b>Available credits: [current_acct ? current_acct.fmtBalance() : "PANIC"]</b><BR>
				<A href='?src=\ref[src];order=categories'>Back to all categories</A><HR><BR><BR>
				<b>Request from: [last_viewed_group]</b><BR><BR>"}
			for(var/supply_name in supply_shuttle.supply_packs )
				var/datum/supply_packs/N = supply_shuttle.supply_packs[supply_name]
				if((N.hidden && !hacked) || (N.contraband && !can_order_contraband) || N.group != last_viewed_group) continue								//Have to send the type instead of a reference to
				temp += "<A href='?src=\ref[src];doorder=[supply_name]'>[supply_name]</A> Cost: [N.cost]<BR>"		//the obj because it would get caught by the garbage
		/*temp = "Supply points: [supply_shuttle.points]<BR><HR><BR>Request what?<BR><BR>"
		for(var/supply_name in supply_shuttle.supply_packs )
			var/datum/supply_packs/N = supply_shuttle.supply_packs[supply_name]
			if(N.hidden && !hacked) continue
			if(N.contraband && !can_order_contraband) continue
			temp += "<A href='?src=\ref[src];doorder=[supply_name]'>[supply_name]</A> Cost: [N.cost]<BR>"    //the obj because it would get caught by the garbage
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"*/
	else if (href_list["doorder"])
		if(world.time < reqtime)
			for(var/mob/V in hearers(src))
				V.show_message("<b>[src]</b>'s monitor flashes, \"[world.time - reqtime] seconds remaining until another requisition form may be printed.\"")
			return
		//Find the correct supply_pack datum
		var/datum/supply_packs/P = supply_shuttle.supply_packs[href_list["doorder"]]
		if(!istype(P))	return
		var/timeout = world.time + 600
		var/reason = copytext(sanitize(input(usr,"Reason:","Why do you require this item?","") as null|text),1,MAX_MESSAGE_LEN)
		if(world.time > timeout)	return
		if(!reason)	return
		var/idname = "*None Provided*"
		var/idrank = "*None Provided*"
		var/datum/money_account/account
		if(ishuman(usr))
			var/obj/item/weapon/card/id/I = usr.get_id_card()
			if(I)
				idname = I.registered_name
				idrank = I.GetJobName()
				account = get_card_account(I)
			else
				to_chat(usr, "[bicon(src)]<span class='warning'>Please wear an ID with an associated bank account.</span>")
				return
			to_chat(usr, "[bicon(src)]<span class='notice'>Your request has been saved. The transaction will be performed to your bank account when it has been accepted by cargo staff.</span>")
			if(account && (account.money < P.cost))
				to_chat(usr, "[bicon(src)]<span class='warning'>Your bank account doesn't have enough funds to order this pack. Your request will be on hold until you provide your bank account with the necessary funds.</span>")
		else if(issilicon(usr))
			idname = usr.real_name
			account = station_account
		supply_shuttle.ordernum++
		var/obj/item/weapon/paper/reqform = new /obj/item/weapon/paper(loc)
		reqform.name = "[P.name] Requisition Form - [idname], [idrank]"
		reqform.info += {"<h3>[station_name] Supply Requisition Form</h3><hr>
			INDEX: #[supply_shuttle.ordernum]<br>
			REQUESTED BY: [idname]<br>
			RANK: [idrank]<br>
			REASON: [reason]<br>
			SUPPLY CRATE TYPE: [P.name]<br>
			ACCESS RESTRICTION: [get_access_desc(P.access)]<br>
			CONTENTS:<br>"}
		reqform.info += P.manifest
		reqform.info += {"<hr>
			STAMP BELOW TO APPROVE THIS REQUISITION:<br>"}
		reqform.update_icon()	//Fix for appearing blank when printed.
		reqtime = (world.time + 5) % 1e5
		//make our supply_order datum
		var/datum/supply_order/O = new /datum/supply_order()
		O.ordernum = supply_shuttle.ordernum
		O.object = P
		O.orderedby = idname
		O.account = account
		supply_shuttle.requestlist += O
		temp = {"Order request placed.<BR>
			<BR><A href='?src=\ref[src];order=[last_viewed_group]'>Back</A> | <A href='?src=\ref[src];mainmenu=1'>Main Menu</A> | <A href='?src=\ref[src];confirmorder=[O.ordernum]'>Authorize Order</A>"}
	else if(href_list["confirmorder"])
		//Find the correct supply_order datum
		var/ordernum = text2num(href_list["confirmorder"])
		var/datum/supply_order/O
		var/datum/supply_packs/P
		var/datum/money_account/A
		var/datum/money_account/cargo_acct = department_accounts["Cargo"]
		temp = "Invalid Request. <br /><A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
		for(var/i=1, i<=supply_shuttle.requestlist.len, i++)
			var/datum/supply_order/SO = supply_shuttle.requestlist[i]
			if(SO.ordernum == ordernum)
				O = SO
				P = O.object
				A = SO.account
				if(A && A.money >= P.cost)
					supply_shuttle.requestlist.Cut(i,i+1)
					var/cargo_share = round((P.cost/100)*20)
					var/centcom_share = P.cost-cargo_share
					A.charge(centcom_share,null,"Supply Order #[SO.ordernum] ([P.name])",src.name,dest_name = "CentComm")
					A.charge(cargo_share,cargo_acct,"Order Tax",src.name)
					supply_shuttle.shoppinglist += O
					temp = {"Thanks for your order.<BR>
						<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"}
				else
					temp = {"Not enough credit.<BR>
						<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"}
				break
	else if (href_list["vieworders"])
		temp = "Current approved orders: <BR><BR>"
		for(var/S in supply_shuttle.shoppinglist)
			var/datum/supply_order/SO = S
			temp += "#[SO.ordernum] - [SO.object.name] approved by [SO.orderedby][SO.comment ? " ([SO.comment])":""]<BR>"// <A href='?src=\ref[src];cancelorder=[S]'>(Cancel)</A><BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
/*
	else if (href_list["cancelorder"])
		var/datum/supply_order/remove_supply = href_list["cancelorder"]
		supply_shuttle_shoppinglist -= remove_supply
		supply_shuttle_points += remove_supply.object.cost
		temp += "Canceled: [remove_supply.object.name]<BR><BR><BR>"
		for(var/S in supply_shuttle_shoppinglist)
			var/datum/supply_order/SO = S
			temp += "[SO.object.name] approved by [SO.orderedby][SO.comment ? " ([SO.comment])":""] <A href='?src=\ref[src];cancelorder=[S]'>(Cancel)</A><BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
*/
	else if (href_list["viewrequests"])
		temp = "Current requests: <BR><BR>"
		for(var/S in supply_shuttle.requestlist)
			var/datum/supply_order/SO = S
			temp += "#[SO.ordernum] - [SO.object.name] requested by [SO.orderedby]  [supply_shuttle.moving ? "":supply_shuttle.at_station ? "":"<A href='?src=\ref[src];confirmorder=[SO.ordernum]'>Approve</A> <A href='?src=\ref[src];rreq=[SO.ordernum]'>Remove</A>"]<BR>"


		temp += {"<BR><A href='?src=\ref[src];clearreq=1'>Clear list</A>
			<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"}
	else if (href_list["rreq"])
		var/ordernum = text2num(href_list["rreq"])
		temp = "Invalid Request.<BR>"
		for(var/i=1, i<=supply_shuttle.requestlist.len, i++)
			var/datum/supply_order/SO = supply_shuttle.requestlist[i]
			if(SO.ordernum == ordernum)
				supply_shuttle.requestlist.Cut(i,i+1)
				temp = "Request removed.<BR>"
				break
		temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

	else if (href_list["clearreq"])
		supply_shuttle.requestlist.len = 0

		temp = {"List cleared.<BR>
			<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"}
	else if (href_list["mainmenu"])
		temp = null

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/supplycomp/proc/post_signal(var/command)


	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency) return

	var/datum/signal/status_signal = getFromPool(/datum/signal)
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	frequency.post_signal(src, status_signal)
