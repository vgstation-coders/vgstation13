//Config stuff
#define SUPPLY_DOCKZ 2          //Z-level of the Dock.
#define SUPPLY_STATIONZ 1       //Z-level of the Station.

#define SCREEN_WIDTH 480 // Dimensions of supply computer windows
#define SCREEN_HEIGHT 590
#define REASON_LEN 140 // max length for reason message, nanoui appears to not like long strings.
var/datum/controller/supply_shuttle/supply_shuttle = new

//For cargo crates, see /code/defines/obj/supplypacks.dm
//For the cargo computers, see computer/cargo.dm

/datum/supply_order
	var/ordernum
	var/datum/supply_packs/object = null
	var/datum/money_account/account = null
	var/orderedby = null
	var/comment = null

/datum/controller/supply_shuttle
	var/processing = 1
	var/processing_interval = 300
	var/iteration = 0
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
	var/restriction = 1 //Who can approve orders? 0 = autoapprove; 1 = has access; 2 = has an ID (omits silicons); 3 = actions require PIN
	var/requisition = 0 //Are orders being paid for by the department? 0 = no; 1 = auto; possible future: allow with pin?

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

/datum/controller/supply_shuttle/proc/confirm_order(datum/supply_order/O,mob/user,var/position) //position represents where it falls in the request list
	var/datum/supply_packs/P = O.object
	var/datum/money_account/cargo_acct = department_accounts["Cargo"]

	if(requisition) //This one's on the house, but Cargo gets no share because they're paying for it
		if(cargo_acct.money >= P.cost)
			supply_shuttle.requestlist.Cut(position,position+1)
			cargo_acct.charge(P.cost,null,"Supply Order #[O.ordernum] ([P.name])",src.name,dest_name = "CentComm")
			shoppinglist += O
		else
			to_chat(user, "<span class='warning'>The department account does not have enough funds for this request.</span>")
	else
		var/datum/money_account/A = O.account
		if(A && A.money >= P.cost)
			supply_shuttle.requestlist.Cut(position,position+1)
			var/cargo_share = round(P.cost*0.2)
			var/centcom_share = (P.cost)-cargo_share
			A.charge(centcom_share,null,"Supply Order #[O.ordernum] ([P.name])",src.name,dest_name = "CentComm")
			A.charge(cargo_share,cargo_acct,"Order Tax",src.name)
			shoppinglist += O
		else
			to_chat(user, "<span class='warning'>[O.orderedby] does not have enough funds for this request.</span>")