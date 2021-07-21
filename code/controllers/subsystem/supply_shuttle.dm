//For cargo crates, see /code/defines/obj/supplypacks.dm
//For the cargo computers, see computer/cargo.dm

//Config stuff
#define SUPPLY_DOCKZ 2          //Z-level of the Dock.
#define SUPPLY_STATIONZ 1       //Z-level of the Station.

#define REASON_LEN 140 // max length for reason message, nanoui appears to not like long strings.

#define CENTCOMM_ORDER_DELAY_MIN (20 MINUTES)
#define CENTCOMM_ORDER_DELAY_MAX (40 MINUTES)

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
	var/centcomm_order_cooldown = 9999
	var/centcomm_last_order = 0

/datum/subsystem/supply_shuttle/New()
	NEW_SS_GLOBAL(SSsupply_shuttle)


/datum/subsystem/supply_shuttle/Initialize(timeofday)
	ordernum = rand(1,9000)
	materials_list = new
	var/list/supply_packs = src.supply_packs
	for(var/typepath in subtypesof(/datum/supply_packs))
		var/datum/supply_packs/P = new typepath
		if (P.require_holiday && (Holiday != P.require_holiday))
			continue
		supply_packs[P.name] = P

	add_centcomm_order(new /datum/centcomm_order/per_unit/plasma)

	centcomm_last_order = world.time
	centcomm_order_cooldown = rand(CENTCOMM_ORDER_DELAY_MIN,CENTCOMM_ORDER_DELAY_MAX)
	..()

/datum/subsystem/supply_shuttle/fire(resumed = FALSE)
	if(moving == 1)
		var/ticksleft = eta_timeofday - world.timeofday

		if(ticksleft > 0)
			eta = round(ticksleft / 600, 1)
		else
			eta = 0
			send()

	if (world.time > (centcomm_last_order + centcomm_order_cooldown))


		//1 more simultaneous order for every 10 players.
		//Centcomm uses the crew manifest to determine how many people actually are on the station.
		var/new_orders = 1 + round(data_core.general.len / 10)
		for (var/i = 1 to new_orders)
			create_weighted_order()

		//If the are less than 1 order per 5 crew members, the next order will come sooner, otherwise later.
		var/new_cooldown = 1 + round(data_core.general.len / 5)
		var/modified_min = CENTCOMM_ORDER_DELAY_MIN
		var/modified_max = CENTCOMM_ORDER_DELAY_MAX

		var/delta = (centcomm_orders.len - new_cooldown)// Sign tells us if we need to add or substract time
		new_cooldown = centcomm_orders.len
		modified_max = max(modified_min, modified_max - 5 * delta MINUTES)

		centcomm_last_order = world.time
		centcomm_order_cooldown = rand(modified_min,modified_max)

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

/datum/subsystem/supply_shuttle/proc/SellObjToOrders(var/atom/A,var/in_crate,var/preserve = FALSE)
	if (istype(A,/obj/item/weapon/storage/lockbox))
		for (var/atom/A2 in A)
			SellObjToOrders(A2, 1)
			if(A2 && !preserve)
				qdel(A2)
	// Per-unit orders run last so they don't steal shit.
	var/list/deferred_orders = list()
	for(var/datum/centcomm_order/O in centcomm_orders)
		if(istype(O,/datum/centcomm_order/per_unit))
			deferred_orders += O
			continue
		if(O.CheckShuttleObject(A,in_crate,preserve))
			return
	for(var/datum/centcomm_order/O in deferred_orders)
		if(O.CheckShuttleObject(A,in_crate,preserve))
			return

/datum/subsystem/supply_shuttle/proc/sell()

	var/area/shuttle = cargo_shuttle.linked_area
	if(!shuttle)
		return

	var/datum/money_account/cargo_acct = department_accounts["Cargo"]

	var/recycled_crates = 0
	for(var/atom/movable/MA in shuttle)
		if(MA.anchored && !ismecha(MA))
			continue

		if(istype(MA,/obj/structure/closet/crate))
			recycled_crates++

			var/find_slip = 1
			for(var/obj/A in MA)
				if(find_slip && istype(A,/obj/item/weapon/paper/manifest))
					var/obj/item/weapon/paper/slip = A
					if(slip.stamped && slip.stamped.len) //yes, the clown stamp will work. clown is the highest authority on the station, it makes sense
						var/datum/transaction/T = new()
						T.target_name = "Central Command Administration"
						T.purpose = "Purchase confirmation (Stamped Slip) [A]"
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
				if (!istype(O, /datum/centcomm_order/per_unit))
					O.Pay()//per_unit payments are handled by CheckFulfilled()
				centcomm_orders.Remove(O)
				for(var/obj/machinery/computer/supplycomp/S in supply_consoles)//juiciness!
					S.say("Central Command request fulfilled!")
					playsound(S, 'sound/machines/info.ogg', 50, 1)
		if(MA)
			qdel(MA)

	if (recycled_crates)
		var/datum/transaction/T = new()
		T.target_name = "Central Command Recycling"
		T.purpose = "[recycled_crates] recycled crate[recycled_crates > 1 ? "s" : ""]"
		T.amount = credits_per_crate*recycled_crates
		T.date = current_date_string
		T.time = worldtime2text()
		cargo_acct.transaction_log.Add(T)
		cargo_acct.money += credits_per_crate*recycled_crates

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
			contains = SP.contains.Copy()
			if(SP.selection_from.len) //for adding a 'set' of items
				contains += pick(SP.selection_from)

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
	var/info = {"<h3>Central Command supply requisition form</h3<><hr>
	 			INDEX: #[C.id]<br>
	 			REQUESTED BY: [C.name]<br>
	 			MUST BE IN CRATE(S): [C.must_be_in_crate ? "YES" : "NO"]<br>
	 			REQUESTED ITEMS:<br>
	 			[C.getRequestsByName(1)]
	 			WORTH: [C.worth] credits TO [C.acct_by_string]
	 			"}
	if (C.silent)
		return
	for(var/obj/machinery/computer/supplycomp/S in supply_consoles)
		var/obj/item/weapon/paper/reqform = new /obj/item/weapon/paper(S.loc)
		reqform.name = name
		reqform.info = info
		reqform.update_icon()
		S.say("New Central Command request available!")
		playsound(S, 'sound/machines/twobeep.ogg', 50, 1)

	for (var/obj/machinery/message_server/MS in message_servers)
		if(MS.is_functioning())
			for (var/obj/machinery/requests_console/Console in requests_consoles)
				if (Console.department in C.request_consoles_to_notify)
					Console.screen = 8
					if(Console.newmessagepriority < 1)
						Console.newmessagepriority = 1
						Console.icon_state = "req_comp2"
					if(!Console.silent)
						playsound(Console.loc, 'sound/machines/request.ogg', 50, 1)
						Console.visible_message("The [src] beeps; New Order from [C.name]")
					Console.messages += "<B>[name]</B><BR>[info]"
					Console.set_light(2)


#undef CENTCOMM_ORDER_DELAY_MIN
#undef CENTCOMM_ORDER_DELAY_MAX
