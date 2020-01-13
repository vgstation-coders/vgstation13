//For cargo crates, see /code/defines/obj/supplypacks.dm
//For the cargo computers, see computer/cargo.dm

//Config stuff
#define SUPPLY_DOCKZ 2          //Z-level of the Dock.
#define SUPPLY_STATIONZ 1       //Z-level of the Station.

#define REASON_LEN 140 // max length for reason message, nanoui appears to not like long strings.

var/datum/subsystem/supply_shuttle/SSsupply_shuttle

/datum/subsystem/supply_shuttle
	name       = "Supply Shuttle"
	init_order = SS_INIT_SUPPLY_SHUTTLE
	flags      = SS_NO_TICK_CHECK
	wait       = 1 SECONDS
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
	var/list/supply_consoles = list()
	//shuttle movement
	var/at_station = 0
	var/movetime = 2 MINUTES
	var/moving = 0
	var/eta_timeofday
	var/eta
	var/datum/materials/materials_list
	var/restriction = 1 //Who can approve orders? 0 = autoapprove; 1 = has access; 2 = has an ID (omits silicons); 3 = actions require PIN
	var/requisition = 0 //Are orders being paid for by the department? 0 = no; 1 = auto; possible future: allow with pin?

/datum/subsystem/supply_shuttle/New()
	NEW_SS_GLOBAL(SSsupply_shuttle)


/datum/subsystem/supply_shuttle/Initialize(timeofday)
	ordernum = rand(1,9000)
	materials_list = new
	var/list/supply_packs = src.supply_packs
	for(var/typepath in subtypesof(/datum/supply_packs))
		var/datum/supply_packs/P = new typepath
		supply_packs[P.name] = P

	..()

/datum/subsystem/supply_shuttle/fire(resumed = FALSE)
	if(moving == 1)
		var/ticksleft = eta_timeofday - world.timeofday

		if(ticksleft > 0)
			eta = round(ticksleft / 600, 1)
		else
			eta = 0
			send()

/datum/supply_order
	var/ordernum
	var/datum/supply_packs/object = null
	var/datum/money_account/account = null
	var/orderedby = null
	var/authorized_name = null
	var/comment = null

/datum/supply_order/proc/OnConfirmed(var/mob/user)
	object.OnConfirmed(user)

/datum/subsystem/supply_shuttle/proc/send()

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
/datum/subsystem/supply_shuttle/proc/can_move()
	if(moving)
		return 0

	if(forbidden_atoms_check(cargo_shuttle.linked_area))
		return 0

	return 1

/datum/subsystem/supply_shuttle/proc/SellObjToOrders(var/atom/A,var/in_crate)
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

/datum/subsystem/supply_shuttle/proc/sell()

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
			var/datum/material/mat = materials_list.getMaterial(P.mat_type)
			var/amount = (mat.value * 10) * P.amount
			cargo_acct.money += amount
			var/datum/transaction/T = new()
			T.target_name = cargo_acct.owner_name
			T.purpose = "Central Command Plasma sale"
			T.amount = amount
			T.date = current_date_string
			T.time = worldtime2text()
			cargo_acct.transaction_log.Add(T)
		// Must be in a crate!
		else if(istype(MA,/obj/structure/closet/crate))
			cargo_acct.money += credits_per_crate
			var/find_slip = 1

			for(var/obj/A in MA)
				if(istype(A, /obj/item/stack/sheet/mineral/plasma))
					var/obj/item/stack/sheet/mineral/plasma/P = A
					if(P.redeemed)
						continue
					var/datum/material/mat = materials_list.getMaterial(P.mat_type)
					var/amount = (mat.value * 10) * P.amount
					cargo_acct.money += amount
					var/datum/transaction/T = new()
					T.target_name = cargo_acct.owner_name
					T.purpose = "Central Command Plasma sale"
					T.amount = amount
					T.date = current_date_string
					T.time = worldtime2text()
					cargo_acct.transaction_log.Add(T)
					continue
				if(find_slip && istype(A,/obj/item/weapon/paper/manifest))
					var/obj/item/weapon/paper/slip = A
					if(slip.stamped && slip.stamped.len) //yes, the clown stamp will work. clown is the highest authority on the station, it makes sense
						var/datum/transaction/T = new()
						T.target_name = cargo_acct.owner_name
						T.purpose = "Central Command purchase confirmation (Stamped Slip) [A]"
						T.amount = credits_per_slip
						T.date = current_date_string
						T.time = worldtime2text()
						cargo_acct.transaction_log.Add(T)
						cargo_acct.money += credits_per_slip
						find_slip = 0
					qdel(A)
					continue

				SellObjToOrders(A,1)

				if(A)
					qdel(A)
		else
			SellObjToOrders(MA,0)

		// PAY UP BITCHES
		for(var/datum/centcomm_order/O in centcomm_orders)
			if(O.CheckFulfilled())
				O.Pay()
				centcomm_orders.Remove(O)
		qdel(MA)


/datum/subsystem/supply_shuttle/proc/buy()
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
		var/atom/A
		if(Holiday == APRIL_FOOLS_DAY && prob(10))
			if(prob(5))
				A = new /mob/living/simple_animal/hostile/mimic/crate/chest(pickedloc)
			else
				A = new /mob/living/simple_animal/hostile/mimic/crate(pickedloc)
		else
			A = new SP.containertype(pickedloc)
		A.name = "[SP.containername] [SO.comment ? "([SO.comment])":"" ]"

		//supply manifest generation begin

		var/obj/item/weapon/paper/manifest/slip = new /obj/item/weapon/paper/manifest(A)

		slip.name = "Shipping Manifest for [SO.orderedby]'s Order"
		slip.info = {"<h3>[command_name()] Shipping Manifest for [SO.orderedby]'s Order</h3><hr><br>
			Order #[SO.ordernum]<br>
			Destination: [station_name]<br>
			[shoppinglist.len] PACKAGES IN THIS SHIPMENT<br>
			CONTENTS:<br><ul>"}
		//spawn the stuff, finish generating the manifest while you're at it
		if(SP.access && istype(A, /obj/structure/closet))
			A:req_access = SP.access

		if(SP.one_access && istype(A, /obj/structure/closet))
			A:req_one_access = SP.one_access

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

		SP.post_creation(A)

		//manifest finalisation

		slip.info += {"</ul><br>
			CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>"}
		if (SP.contraband)
			slip.forceMove(null)	//we are out of blanks for Form #44-D Ordering Illicit Drugs.
		shoppinglist.Remove(S)

/datum/subsystem/supply_shuttle/proc/forbidden_atoms_check(atom/A)
	var/contents = get_contents_in_object(A)
	for(var/mob/living/simple_animal/hostile/mimic/M in contents)
		M.angry = 0
		M.apply_disguise()
	for(var/mob/living/M in contents)
		if(!istype(M, /mob/living/simple_animal/hostile/mimic))
			return TRUE

	if (locate(/obj/item/weapon/disk/nuclear) in contents)
		return TRUE
	if (locate(/obj/machinery/nuclearbomb) in contents)
		return TRUE
	if (locate(/obj/item/beacon) in contents)
		return TRUE
	if (locate(/obj/effect/portal) in contents)//you crafty fuckers
		return TRUE
	return FALSE

/datum/subsystem/supply_shuttle/proc/confirm_order(datum/supply_order/O,mob/user,var/position) //position represents where it falls in the request list
	var/datum/supply_packs/P = O.object
	var/datum/money_account/cargo_acct = department_accounts["Cargo"]

	if(requisition) //This one's on the house, but Cargo gets no share because they're paying for it
		if(cargo_acct.money >= P.cost)
			requestlist.Cut(position,position+1)
			cargo_acct.charge(P.cost,null,"Supply Order #[O.ordernum] ([P.name])",src.name,dest_name = "CentComm")
			shoppinglist += O
		else
			to_chat(user, "<span class='warning'>The department account does not have enough funds for this request.</span>")
	else
		var/datum/money_account/A = O.account
		if(A && A.money >= P.cost)
			requestlist.Cut(position,position+1)
			var/cargo_share = round(P.cost*0.2)
			var/centcom_share = (P.cost)-cargo_share
			A.charge(centcom_share,null,"Supply Order #[O.ordernum] ([P.name])",src.name,dest_name = "CentComm")
			A.charge(cargo_share,cargo_acct,"Order Tax",src.name)
			shoppinglist += O
		else
			to_chat(user, "<span class='warning'>[O.orderedby] does not have enough funds for this request.</span>")

/datum/subsystem/supply_shuttle/proc/add_centcomm_order(var/datum/centcomm_order/C)
	centcomm_orders.Add(C)
	var/name = "External order form - [C.name] order number [C.id]"
	var/info = {"<h3>Central command supply requisition form</h3<><hr>
	 			INDEX: #[C.id]<br>
	 			REQUESTED BY: [C.name]<br>
	 			MUST BE IN CRATE: [C.must_be_in_crate ? "YES" : "NO"]<br>
	 			REQUESTED ITEMS:<br>
	 			[C.getRequestsByName(1)]
	 			WORTH: [C.worth] credits TO [C.acct_by_string]
	 			"}
	for(var/obj/machinery/computer/supplycomp/S in supply_consoles)
		var/obj/item/weapon/paper/reqform = new /obj/item/weapon/paper(S.loc)
		reqform.name = name
		reqform.info = info
		reqform.update_icon()
		S.say("New central command request available")
