/********************
* Track orders made by centcomm
*
* Used for the new cargo system
*********************/
var/global/current_centcomm_order_id=124901

/datum/centcomm_order
	var/id = 0 // Some bullshit ID we use for fluff.
	var/name = "CentComm" // Name of the ordering entity. Fluff.
	var/datum/money_account/acct // account we pay to
	var/acct_by_string = "unknown"

	// Amount decided upon
	var/worth = 0

	var/must_be_in_crate = 1
	var/recurring = 0

	// /type = amount
	var/list/requested=list()
	var/list/fulfilled=list()

/datum/centcomm_order/New()
	..()
	id = current_centcomm_order_id++

/datum/centcomm_order/proc/CheckShuttleObject(var/obj/O, var/in_crate)
	if(must_be_in_crate && !in_crate)
		return 0
	if(!O)
		return 0
	if(O.type in requested)
		var/amount = 1
		if(istype(O, /obj/item/stack))
			var/obj/item/stack/S = O
			amount = S.amount
		if(!(O.type in fulfilled))
			fulfilled[O.type]=0
		// Don't claim stuff that other orders may want.
		if(fulfilled[O.type]==requested[O.type])
			return 0
		fulfilled[O.type]+=amount
		qdel(O)
		return 1

/datum/centcomm_order/proc/CheckFulfilled(var/obj/O, var/in_crate)
	for(var/typepath in requested)
		if(!(typepath in fulfilled) || fulfilled[typepath] < requested[typepath])
			return 0
	return 1

/datum/centcomm_order/proc/Pay()
	acct.charge(-worth,null,"Payment for order #[id]",dest_name = name)

/datum/centcomm_order/proc/getRequestsByName(var/html_format = 0)
	var/manifest = ""
	if(html_format)
		manifest = "<ul>"
	for(var/path in requested)
		if(!path)
			continue
		var/atom/movable/AM = path
		if(html_format)
			manifest += "<li>[initial(AM.name)], amount: [requested[path]]</li>"
		else
			manifest += "[initial(AM.name)], amount: [requested[path]]"
	if(html_format)
		manifest += "</ul>"
	return manifest

/datum/centcomm_order/proc/getFulfilledByName(var/html_format = 0)
	var/manifest = ""
	if(html_format)
		manifest = "<ul>"
	for(var/path in fulfilled)
		if(!path)
			continue
		var/atom/movable/AM = path
		if(html_format)
			manifest += "<li>[initial(AM.name)], amount: [fulfilled[path]]</li>"
		else
			manifest += "[initial(AM.name)], amount: [fulfilled[path]]"
	if(html_format)
		manifest += "</ul>"
	return manifest

/datum/centcomm_order/proc/OnPostUnload()
	return

// These run *last*.
/datum/centcomm_order/per_unit
	recurring=1
	var/list/unit_prices=list()

// Same as normal, but will take every last bit of what you provided.
/datum/centcomm_order/per_unit/CheckShuttleObject(var/obj/O, var/in_crate)
	if(must_be_in_crate && !in_crate)
		return 0
	if(!O)
		return 0
	if(O.type in requested)
		if(!(O.type in fulfilled))
			fulfilled[O.type]=0
		fulfilled[O.type]=fulfilled[O.type]+1

		qdel(O)
		return 1

/datum/centcomm_order/per_unit/CheckFulfilled()
	var/toPay=0
	for(var/typepath in fulfilled)
		var/worth_per_unit = unit_prices[typepath]
		var/amount         = fulfilled[typepath]
		toPay += amount * worth_per_unit
		if(requested[typepath]!=INFINITY)
			requested[typepath] = max(0,requested[typepath] - fulfilled[typepath])
		fulfilled[typepath]=0
	if(toPay)
		acct.charge(-toPay,null,"Payment for order #[id]",dest_name = name)
	return

//////////////////////////////////////////////
// ORDERS START HERE
//////////////////////////////////////////////
/datum/centcomm_order/per_unit/plasma
	name = "Nanotrasen"
	recurring = 1
	requested = list(
		/obj/item/stack/sheet/mineral/plasma = INFINITY
	)
	unit_prices=list(
		/obj/item/stack/sheet/mineral/plasma = 0.5 // 1 credit per two plasma sheets.
	)