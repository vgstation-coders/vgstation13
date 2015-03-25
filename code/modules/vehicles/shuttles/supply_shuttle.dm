//Config stuff
#define SUPPLY_DOCKZ 2          //Z-level of the Dock.
#define SUPPLY_STATIONZ 1       //Z-level of the Station.
#define SUPPLY_STATION_AREATYPE "/area/supply/station" //Type of the supply shuttle area for station
#define SUPPLY_DOCK_AREATYPE "/area/supply/dock"	//Type of the supply shuttle area for dock
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

/area/supply/station //DO NOT TURN THE lighting_use_dynamic STUFF ON FOR SHUTTLES. IT BREAKS THINGS.
	name = "supply shuttle"
	icon_state = "shuttle3"
	luminosity = 1
	lighting_use_dynamic = 0
	requires_power = 0

/area/supply/dock //DO NOT TURN THE lighting_use_dynamic STUFF ON FOR SHUTTLES. IT BREAKS THINGS.
	name = "supply shuttle"
	icon_state = "shuttle3"
	luminosity = 1
	lighting_use_dynamic = 0
	requires_power = 0

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
	var/area/from
	var/area/dest
	var/area/the_shuttles_way
	switch(at_station)
		if(1)
			from = locate(SUPPLY_STATION_AREATYPE)
			dest = locate(SUPPLY_DOCK_AREATYPE)
			the_shuttles_way = from
			at_station = 0
		if(0)
			from = locate(SUPPLY_DOCK_AREATYPE)
			dest = locate(SUPPLY_STATION_AREATYPE)
			the_shuttles_way = dest
			at_station = 1
	moving = 0

	//Do I really need to explain this loop?
	if(at_station)
		for(var/atom/A in the_shuttles_way)
			if(istype(A,/mob/living))
				var/mob/living/unlucky_person = A
				unlucky_person.gib()
			// Weird things happen when this shit gets in the way.
			if(istype(A,/obj/structure/lattice) \
					|| istype(A, /obj/structure/window) \
				|| istype(A, /obj/structure/grille))
				del(A)

	from.move_contents_to(dest)

	//Check whether the shuttle is allowed to move
/datum/controller/supply_shuttle/proc/can_move()
	if(moving) return 0

	var/area/shuttle = locate(/area/supply/station)
	if(!shuttle) return 0

	if(forbidden_atoms_check(shuttle))
		return 0

	return

	//To stop things being sent to centcomm which should not be sent to centcomm. Recursively checks for these types.
/datum/controller/supply_shuttle/proc/forbidden_atoms_check(atom/A)
	//TODO: Make this into a restricted objects/list or assign a var
	if(istype(A,/mob/living))
		return 1
	if(istype(A,/obj/item/weapon/disk/nuclear))
		return 1
	if(istype(A,/obj/machinery/nuclearbomb))
		return 1
	if(istype(A,/obj/item/device/radio/beacon))
		return 1

	for(var/i=1, i<=A.contents.len, i++)
		var/atom/B = A.contents[i]
		if(.(B))
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
	var/shuttle_at
	if(at_station)	shuttle_at = SUPPLY_STATION_AREATYPE
	else			shuttle_at = SUPPLY_DOCK_AREATYPE

	var/area/shuttle = locate(shuttle_at)
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
		//world << "deleting [MA]/[MA.type] it was [!MA.anchored ? "not ": ""] anchored"
		qdel(MA)

	//Buyin
/datum/controller/supply_shuttle/proc/buy()
	if(!shoppinglist.len) return

	var/shuttle_at
	if(at_station)	shuttle_at = SUPPLY_STATION_AREATYPE
	else			shuttle_at = SUPPLY_DOCK_AREATYPE

	var/area/shuttle = locate(shuttle_at)
	if(!shuttle)	return

	var/list/clear_turfs = list()

	for(var/turf/T in shuttle)
		if(T.density || T.contents.len)	continue
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

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\game\supplyshuttle.dm:298: slip.info = "<h3>[command_name()] Shipping Manifest</h3><hr><br>"
		slip.info = {"<h3>[command_name()] Shipping Manifest</h3><hr><br>
			Order #[SO.ordernum]<br>
			Destination: [station_name]<br>
			[supply_shuttle.shoppinglist.len] PACKAGES IN THIS SHIPMENT<br>
			CONTENTS:<br><ul>"}
		// END AUTOFIX
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

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\game\supplyshuttle.dm:326: slip.info += "</ul><br>"
		slip.info += {"</ul><br>
			CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>"}
		// END AUTOFIX
		if (SP.contraband) slip.loc = null	//we are out of blanks for Form #44-D Ordering Illicit Drugs.

	supply_shuttle.shoppinglist.len = 0
	return