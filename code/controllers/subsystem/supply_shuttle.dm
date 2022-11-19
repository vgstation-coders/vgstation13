//For cargo crates, see /code/defines/obj/supplypacks.dm
//For the cargo computers, see computer/cargo.dm

//Config stuff
#define SUPPLY_DOCKZ 2          //Z-level of the Dock.
#define SUPPLY_STATIONZ 1       //Z-level of the Station.

#define REASON_LEN 140 // max length for reason message, nanoui appears to not like long strings.

#define CENTCOMM_ORDER_DELAY_MIN (20 MINUTES)
#define CENTCOMM_ORDER_DELAY_MAX (40 MINUTES)

#define CARGO_FORWARD_DELAY_MIN (5 MINUTES)
#define CARGO_FORWARD_DELAY_MAX (15 MINUTES)

var/datum/subsystem/supply_shuttle/SSsupply_shuttle

/datum/subsystem/supply_shuttle
	name       = "Supply Shuttle"
	init_order = SS_INIT_SUPPLY_SHUTTLE
	flags      = SS_NO_TICK_CHECK
	wait       = 1 SECONDS
	//supply points have been replaced with MONEY MONEY MONEY - N3X
	var/credits_per_slip = 5
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
	var/cargo_forward_cooldown = 0
	var/cargo_last_forward = 0
	var/list/datum/cargo_forwarding/fulfilled_forwards = list() // For persistence
	var/list/datum/cargo_forwarding/previous_forwards = list()

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

	if(config.cargo_forwarding_on_roundstart)
		forwarding_on = TRUE
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
			var/ordertype = get_weighted_order()
			add_centcomm_order(new ordertype)

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

	if(!cargo_shuttle || !cargo_shuttle.linked_area)
		return

	var/datum/money_account/cargo_acct = department_accounts["Cargo"]

	var/recycled_crates = 0

	for(var/atom/movable/MA in cargo_shuttle.linked_area)
		if(MA.anchored && !ismecha(MA))
			continue

		if(isobj(MA))
			var/obj/O = MA
			if(O.associated_forward && (O.associated_forward in cargo_forwards))
				if(O.associated_forward.associated_crate == O)
					O.associated_forward.delete_crate = TRUE
					continue
				if(O.associated_forward.associated_manifest == O)
					O.associated_forward.delete_manifest = TRUE
					continue

		if(istype(MA,/obj/structure/closet/crate))
			recycled_crates++

			var/find_slip = 1
			for(var/obj/A in MA)
				if(find_slip && istype(A,/obj/item/weapon/paper/manifest))
					var/obj/item/weapon/paper/slip = A
					if(slip.stamped && slip.stamped.len) //yes, the clown stamp will work. clown is the highest authority on the station, it makes sense
						new /datum/transaction(cargo_acct,"Purchase confirmation (Stamped Slip) [A]", credits_per_slip, "",\
												"Central Command Administration", send2PDAs = FALSE)
						cargo_acct.money += credits_per_slip
						find_slip = 0
					qdel(A)
					continue

				SellObjToOrders(A,1)

				if(A)
					qdel(A)
		else
			SellObjToOrders(MA,0)

		if(MA)
			qdel(MA)

	// PAY UP
	for(var/datum/centcomm_order/O in centcomm_orders)
		if(O.CheckFulfilled())
			if(prob(50)) // Make this a chance, don't always make them show up as forwards
				var/list/positions_to_check = list()
				switch(O.acct_by_string)
					if("Cargo")
						positions_to_check = CARGO_POSITIONS
					if("Engineering")
						positions_to_check = ENGINEERING_POSITIONS
					if("Medical")
						positions_to_check = MEDICAL_POSITIONS
					if("Science")
						positions_to_check = SCIENCE_POSITIONS
					if("Civilian")
						positions_to_check = CIVILIAN_POSITIONS
				var/list/possible_names = list()
				var/list/possible_position_names = list()
				for(var/mob/living/M in player_list)
					if(positions_to_check && positions_to_check.len && (M.mind.assigned_role in positions_to_check))
						possible_position_names += M.name
					possible_names += M.name
				var/ourname = ""
				if(possible_position_names && possible_position_names.len)
					ourname = pick(possible_position_names)
				else if(possible_names && possible_names.len)
					ourname = pick(possible_names)
				fulfilled_forwards += new /datum/cargo_forwarding/from_centcomm_order(ourname, station_name(), O.type, TRUE)
			if (!istype(O, /datum/centcomm_order/per_unit))
				O.Pay()//per_unit payments are handled by CheckFulfilled()
			centcomm_orders.Remove(O)
			for(var/obj/machinery/computer/supplycomp/S in supply_consoles)//juiciness!
				S.say("Central Command request fulfilled!")
				playsound(S, 'sound/machines/info.ogg', 50, 1)

	for(var/datum/cargo_forwarding/CF in cargo_forwards)
		var/reason = null
		var/specific_reason = FALSE // For debug logs
		if(!CF.associated_crate || get_area(CF.associated_crate) != cargo_shuttle.linked_area)
			reason = "Crate is missing"
			specific_reason = TRUE
			if(!CF.associated_manifest)
				log_debug("CARGO FORWARDING: [CF] denied: Crate was destroyed")
			else
				log_debug("CARGO FORWARDING: [CF] denied: Crate was in [get_area(CF.associated_crate)], not in [cargo_shuttle.linked_area]")
		if(!CF.weighed)
			reason = "Crate not weighed"
		if(!CF.associated_manifest || get_area(CF.associated_manifest) != cargo_shuttle.linked_area)
			reason = "Manifest is missing"
			specific_reason = TRUE
			if(!CF.associated_manifest)
				log_debug("CARGO FORWARDING: [CF] denied: Manifest was destroyed")
			else
				log_debug("CARGO FORWARDING: [CF] denied: Manifest was in [get_area(CF.associated_manifest)], not in [cargo_shuttle.linked_area]")
		if(CF.associated_manifest && (!CF.associated_manifest.stamped || !CF.associated_manifest.stamped.len))
			reason = "Manifest was not stamped"
		if(istype(CF.associated_crate,/obj/structure/closet))
			var/obj/structure/closet/CL = CF.associated_crate
			if(CL.broken)
				reason = "Crate broken into"
		var/list/atom/foreign_atoms = list()
		for(var/atom/A in CF.associated_crate)
			if(!(A in CF.initial_contents))
				foreign_atoms += A
		if(foreign_atoms && foreign_atoms.len)
			reason = "Foreign objects in crate ([counted_english_list(foreign_atoms)])"
		var/list/atom/missing_atoms = list()
		for(var/atom/A in CF.initial_contents)
			if(!(A in CF.associated_crate))
				missing_atoms += A
		if(missing_atoms && missing_atoms.len)
			reason = "[counted_english_list(missing_atoms)] missing from crate"
		if(!specific_reason && reason)
			log_debug("CARGO FORWARDING: [CF] denied: [reason]")
		CF.Pay(reason)

	if (recycled_crates)
		new /datum/transaction(cargo_acct, "[recycled_crates] recycled crate[recycled_crates > 1 ? "s" : ""]",\
								credits_per_crate*recycled_crates, "", "Central Command Recycling", send2PDAs=FALSE)
		cargo_acct.money += credits_per_crate*recycled_crates

/datum/subsystem/supply_shuttle/proc/buy()
	if(!shoppinglist.len && !forwarding_on)
		return

	if(!cargo_shuttle || !cargo_shuttle.linked_area)
		return

	var/list/clear_turfs = list()

	for(var/turf/T in cargo_shuttle.linked_area)
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

	if(forwarding_on)
		if(!clear_turfs.len)
			return
		var/cooldown_left = (cargo_last_forward + cargo_forward_cooldown) - world.time
		if (cooldown_left > 0)
			log_debug("CARGO FORWARDING: Order happened before cooldown, no forwards. ([time2text(cooldown_left, "mm")] minutes [time2text(cooldown_left, "ss")] seconds left)")
			return
		var/amount_forwarded = config.cargo_forwarding_amount_override // Override in server config for debugging
		if(!amount_forwarded) // If nothing from override
			var/cargomen = 0 // How many people are working in cargo?
			for(var/datum/data/record/t in sortRecord(data_core.general))
				if((t.fields["real_rank"] in cargo_positions) || (t.fields["override_dept"] == "Cargo"))
					cargomen++ // Go through manifest and find out
			if(!cargomen)
				cargomen = 1 // Just send one crate if no cargo

			var/datum/money_account/our_account = department_accounts["Cargo"]
			var/multiplier = log(10, (our_account.money / (DEPARTMENT_START_FUNDS / 10) ) ) // So that starting funds equal a 1x multiplier
			amount_forwarded = rand(0,round(cargomen * multiplier))
		log_debug("CARGO FORWARDING: [amount_forwarded] crates forwarded[!amount_forwarded ? ", nothing sent" : ""].")
		if(!amount_forwarded)
			return // Skip this if nothing to send

		cargo_last_forward = world.time // Only set these if a successful forward is about to happen
		cargo_forward_cooldown = rand(CARGO_FORWARD_DELAY_MIN,CARGO_FORWARD_DELAY_MAX)

		var/list/datum/cargo_forwarding/new_forwards = list()
		if(prob(50) && previous_forwards && previous_forwards.len) // Keep it just a chance to get the previous round's forwards so we don't just end up with those
			for(var/k in 1 to amount_forwarded)
				if(!previous_forwards || !previous_forwards.len) // Break out if nothing sent
					break
				var/previous_index = rand(1,previous_forwards.len)
				var/datum/cargo_forwarding/CF = previous_forwards[previous_index]
				cargo_forwards.Add(CF) // Blocked it in the creation of a previous forward, now do it here
				CF.set_time_limit()
				new_forwards.Add(CF)
				previous_forwards.Remove(previous_forwards[previous_index]) // Must be the index to remove a specific one
				log_debug("CARGO FORWARDING: Persistence crate [CF.type] loaded, from [CF.origin_sender_name] of [CF.origin_station_name].")
		if(new_forwards.len < amount_forwarded) // If we got nothing or not the entire amount from the above
			if(new_forwards.len)
				log_debug("CARGO FORWARDING: [new_forwards.len] crates of [amount_forwarded] were persistence crates, now loading them as normal.")
			for(var/j in 1 to (amount_forwarded - new_forwards.len))
				var/cratetype = pick(
					750;/datum/cargo_forwarding/from_supplypack,
					150;/datum/cargo_forwarding/from_centcomm_order,
					40;/datum/cargo_forwarding/janicart,
					40;/datum/cargo_forwarding/gokart,
					10;/datum/cargo_forwarding/random_mob,
					10;/datum/cargo_forwarding/vendotron_stack,
				)
				var/datum/cargo_forwarding/NCF = new cratetype
				new_forwards.Add(NCF)

		for(var/datum/cargo_forwarding/CF in new_forwards)
			if(!clear_turfs.len)
				break
			var/i = rand(1,clear_turfs.len)
			var/turf/pickedloc = clear_turfs[i]
			clear_turfs.Cut(i,i+1)

			CF.associated_crate = new CF.containertype(pickedloc)
			CF.associated_crate.associated_forward = CF
			CF.post_creation()
			CF.associated_crate.name = "[CF.containername]"

			CF.associated_manifest = new /obj/item/weapon/paper/manifest(get_turf(CF.associated_crate))
			CF.associated_manifest.associated_forward = CF
			CF.associated_manifest.name = "Shipping Manifest for [CF.origin_sender_name]'s Order"
			CF.associated_manifest.info = {"<h3>[command_name()] Shipping Manifest for [CF.origin_sender_name]'s Order</h3><hr><br>
				Order #[rand(1,1000)]<br>
				Destination: [CF.origin_station_name]<br>
				[amount_forwarded] PACKAGES IN THIS SHIPMENT<br>
				CONTENTS:<br><ul>"}
			if(CF.access && istype(CF.associated_crate, /obj/structure/closet))
				CF.associated_crate:req_access = CF.access
			if(CF.one_access && istype(CF.associated_crate, /obj/structure/closet))
				CF.associated_crate:req_one_access = CF.one_access

			for(var/typepath in CF.contains)
				if(!typepath)
					continue
				var/atom/B2 = new typepath(CF.associated_crate)
				if(istype(B2,/obj/item/stack))
					var/obj/item/stack/S = B2
					if(CF.amount && S.amount)
						S.amount = CF.amount < S.max_amount ? CF.amount : S.max_amount // Just cap it here
			for(var/atom/thing in CF.associated_crate)
				CF.associated_manifest.info += "<li>[thing.name]</li>" //add the item to the manifest
				CF.initial_contents += thing
				if(istype(CF,/datum/cargo_forwarding/from_centcomm_order))
					var/datum/cargo_forwarding/from_centcomm_order/CO = CF
					CO.initialised_order.BuildToExtraChecks(thing) //make the thing in the crate more like a fulfilled centcomm order

			CF.associated_manifest.info += {"</ul>"}

/datum/subsystem/supply_shuttle/proc/forbidden_atoms_check(atom/A)
	var/contents = get_contents_in_object(A)
	for(var/mob/living/M in contents)
		if(istype(M, /mob/living/simple_animal/hostile/mimic))
			var/mob/living/simple_animal/hostile/mimic/mimic = M
			mimic.angry = 0
			mimic.apply_disguise()
		if(M.key || M.ckey || M.mind) //only mobs that were never player controlled
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

#undef CARGO_FORWARD_DELAY_MIN
#undef CARGO_FORWARD_DELAY_MAX
