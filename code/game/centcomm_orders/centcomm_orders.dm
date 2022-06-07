/********************
* Track orders made by centcomm
*
* Used for the new cargo system
*********************/
var/global/current_centcomm_order_id=124901

/datum/centcomm_order
	var/id = 0 // Some bullshit ID we use for fluff.
	var/name = "Central Command" // Name of the ordering entity. Fluff.
	var/datum/money_account/acct // account we pay to
	var/acct_by_string = ""
	var/silent = 0

	// Amount decided upon
	var/worth = 0

	var/cargo_contribution = 0.1

	var/must_be_in_crate = 1

	var/extra_requirements = ""//specify when you want the items to have been modified in a certain way or have certain properties.
								//then use ExtraChecks() to verify that the shipped item has those requested properties
								//for example: to verify that a shipped organ is still alive.

	// /type = amount
	var/list/requested=list()
	var/list/fulfilled=list()

	var/list/name_override=list()//use when you want the requested to appear with a different name, useful when you want to be more descriptive
								//for example: "vials of infected blood"

	var/list/request_consoles_to_notify=list()//when the order is created, Request Consoles in this list will immediately

	var/hidden = FALSE //orders that we don't want to see randomly appear

/* list of all request consoles "department" vars currently used in our maps.
	Engineering
		"Chief Engineer's Desk"
		"Atmospherics"
		"Engineering"
		"Pod Bay"
		"Mechanics"

	Medbay
		"Chief Medical Officer's Desk"
		"Medbay"
		"Chemistry"
		"Genetics"
		"Virology"

	Security
		"Head of Security's Desk"
		"Security"

	Service
		"Head of Personnel's Desk"
		"Kitchen"
		"Bar"
		"Hydroponics"
		"Cargo Bay"
		"Janitorial"
		"Chapel"

	Science
		"Research Director's Desk"
		"Science"
		"Robotics"
		"Telecoms Admin"

	probably won't even need to notify need those
		"AI"
		"Bridge"
		"Captain's Desk"
		"Locker Room"
		"Tool Storage"
		"Arrival Shuttle"
		"EVA"
*/

/datum/centcomm_order/New()
	..()
	id = current_centcomm_order_id++

	if (acct_by_string)
		acct = department_accounts[acct_by_string]
	else
		acct = station_account
		acct_by_string = station_name()

/datum/centcomm_order/Destroy()
	acct = null
	..()

/datum/centcomm_order/proc/ExtraChecks(var/atom/movable/AM)
	return 1

// For cargo crate forwarding
/datum/centcomm_order/proc/BuildToExtraChecks(var/atom/movable/AM)
	return

/datum/centcomm_order/proc/CheckShuttleObject(var/obj/O, var/in_crate, var/preserve = FALSE)
	if(must_be_in_crate && !in_crate)
		return 0
	if(!O)
		return 0
	if(is_type_in_list(O, requested))
		var/amount = 1
		if(istype(O, /obj/item/stack))
			var/obj/item/stack/S = O
			amount = S.amount
		if(!is_type_in_list(O, fulfilled))
			fulfilled[O.type] = 0
		// Don't claim stuff that other orders may want.
		if(fulfilled[O.type] == requested[O.type])
			return 0
		if (!ExtraChecks(O))
			return 0
		fulfilled[O.type] += amount
		if (!preserve)
			qdel(O)
		return 1
	return 0

/datum/centcomm_order/proc/CheckFulfilled()
	for(var/typepath in requested)
		if(!(typepath in fulfilled) || fulfilled[typepath] < requested[typepath])
			return FALSE
	score.stuffshipped++
	return TRUE

/datum/centcomm_order/proc/Pay(var/complete = TRUE)
	acct.charge(-worth,null,"Payment for order #[id]",dest_name = name)

	if (cargo_contribution > 0 && acct_by_string != "Cargo")//cargo gets some extra coin from every order shipped
		var/datum/money_account/cargo_acct = department_accounts["Cargo"]
		cargo_acct.charge(round(-worth/10),null,"Contribution for order #[id]",dest_name = name)


/datum/centcomm_order/proc/getRequestsByName(var/html_format = 0)
	var/manifest = ""
	if(html_format)
		manifest = "<ul>"
	for(var/path in requested)
		if(!path)
			continue
		var/atom_name
		if (path in name_override)
			atom_name = name_override[path]
		else
			var/atom/movable/AM = path
			atom_name = initial(AM.name)
		var/amount = "[requested[path]]"
		if (requested[path]==INFINITY)
			amount = "Just keep it comin'"
		if(html_format)
			manifest += "<li>[atom_name], amount: [amount]</li>"
		else
			manifest += "[atom_name], amount: [amount]"
	if(html_format)
		manifest += "</ul>"
		if (extra_requirements)
			if(html_format)
				manifest += "<i>[extra_requirements]</i><br>"
	return manifest

/datum/centcomm_order/proc/getFulfilledByName(var/html_format = 0)
	var/manifest = ""
	if(html_format)
		manifest = "<ul>"
	for(var/path in fulfilled)
		if(!path)
			continue
		var/atom_name
		if (path in name_override)
			atom_name = name_override[path]
		else
			var/atom/movable/AM = path
			atom_name = initial(AM.name)
		if(html_format)
			manifest += "<li>[atom_name], amount: [fulfilled[path]]</li>"
		else
			manifest += "[atom_name], amount: [fulfilled[path]]"
	if(html_format)
		manifest += "</ul>"
	return manifest

/datum/centcomm_order/proc/OnPostUnload()
	return

// These run *last*.
/datum/centcomm_order/per_unit
	var/list/unit_prices = list()
	var/left_to_check = list()
	var/toPay = 0


/datum/centcomm_order/per_unit/Pay(var/complete = TRUE)
	if(toPay)
		if(complete)
			acct.charge(-toPay,null,"Complete payment for per-unit order #[id]",dest_name = name)
			score.stuffshipped++
		else
			acct.charge(-toPay,null,"Partial payment for per-unit order #[id]",dest_name = name)

		if (cargo_contribution > 0 && acct_by_string != "Cargo")//cargo gets some extra coin from every order shipped
			var/datum/money_account/cargo_acct = department_accounts["Cargo"]
			cargo_acct.charge(round(-toPay * cargo_contribution),null,"Contribution for partial order #[id]",dest_name = name)
		toPay = 0

// Same as normal, but will take every last bit of what you provided.
/datum/centcomm_order/per_unit/CheckShuttleObject(var/obj/O, var/in_crate, var/preserve = FALSE)
	if(must_be_in_crate && !in_crate)
		return 0
	if(!O)
		return 0
	if(is_type_in_list(O, requested))
		var/amount = 1
		if(istype(O, /obj/item/stack))
			var/obj/item/stack/S = O
			amount = S.amount
		if(!is_type_in_list(O, left_to_check))
			left_to_check[O.type]=0
		if (!ExtraChecks(O))
			return 0
		left_to_check[O.type] += amount
		if (!preserve)
			qdel(O)
		return 1
	return 0

/datum/centcomm_order/per_unit/CheckFulfilled()
	toPay = 0
	for(var/typepath in left_to_check)
		var/worth_per_unit = unit_prices[typepath]
		var/amount         = left_to_check[typepath]
		toPay += amount * worth_per_unit
		if(requested[typepath] != INFINITY)
			requested[typepath] = max(0,requested[typepath] - left_to_check[typepath])
		if(!(typepath in fulfilled))
			fulfilled[typepath] = 0
		fulfilled[typepath] += left_to_check[typepath]
		left_to_check[typepath] = 0
	. = ..()
	Pay(.)

///////////////////////////////

/proc/create_random_orders(var/num_orders)//This one is used at roundstart to add a couple random orders immediately
	var/list/choices = get_all_orders()
	for(var/i = 1 to num_orders)
		var/choice = pick_n_take(choices)
		var/datum/centcomm_order/new_order = new choice
		SSsupply_shuttle.add_centcomm_order(new_order)

/proc/get_all_orders()
	var/list/orders = list()
	orders.Add(subtypesof(/datum/centcomm_order/per_unit/department/cargo))
	orders.Add(subtypesof(/datum/centcomm_order/department/science))
	orders.Add(subtypesof(/datum/centcomm_order/department/medical))
	orders.Add(subtypesof(/datum/centcomm_order/department/engineering))
	orders.Add(subtypesof(/datum/centcomm_order/department/civilian))
	orders.Add(subtypesof(/datum/centcomm_order/per_unit/department/civilian))
	return orders


///////////////////////////////////////

/proc/get_weighted_order()
	var/list/active_with_role = get_dept_pop()

	var/list/department_weights = list(
		"Cargo" = 3,
		"Civilian" = 5,
		"Medical" = 5,
		"Science" = 5,
		"Engineering" = 5,
		)

	for(var/dept in department_weights)
		if(active_with_role[dept] < 1)
			department_weights[dept] = 1//departments with no employees are very unlikely to receive an order

	var/list/order_exists = list(
		"Cargo" = 0,
		"Civilian" = 0,
		"Medical" = 0,
		"Science" = 0,
		"Engineering" = 0,
		)

	for(var/datum/centcomm_order/O in SSsupply_shuttle.centcomm_orders)
		if (O.acct_by_string in order_exists)
			order_exists[O.acct_by_string] += 1

	for(var/dept in order_exists)
		department_weights[dept] = max(1, department_weights[dept] - order_exists[dept])//the more active orders a department has, the less likely it'll get another one

	var/chosen_dept = pick(
		department_weights["Cargo"];"Cargo",
		department_weights["Civilian"];"Civilian",
		department_weights["Medical"];"Medical",
		department_weights["Science"];"Science",
		department_weights["Engineering"];"Engineering")

	var/list/orders = list()
	switch(chosen_dept)
		if ("Cargo")
			orders.Add(subtypesof(/datum/centcomm_order/per_unit/department/cargo))
		if ("Civilian")
			orders.Add(subtypesof(/datum/centcomm_order/department/civilian))
			orders.Add(subtypesof(/datum/centcomm_order/per_unit/department/civilian))
		if ("Medical")
			orders.Add(subtypesof(/datum/centcomm_order/department/medical))
		if ("Science")
			orders.Add(subtypesof(/datum/centcomm_order/department/science))
		if ("Engineering")
			orders.Add(subtypesof(/datum/centcomm_order/department/engineering))

	orders -= SSsupply_shuttle.centcomm_orders//we don't want a duplicate order

	for (var/O in orders)//removing hidden orders
		var/datum/centcomm_order/CO = O
		if (initial(CO.hidden))
			orders -= O

	if (!orders.len)
		return

	return pick(orders)


/proc/get_dept_pop()
	var/list/active_with_role = list()
	active_with_role["Cargo"] = 0
	active_with_role["Service"] = 0
	active_with_role["Medical"] = 0
	active_with_role["Science"] = 0
	active_with_role["Engineering"] = 0

	for(var/mob/M in player_list)
		if(!M.mind || !M.client || M.client.inactivity > 10 * 10 * 60) // longer than 10 minutes AFK counts them as inactive
			continue

		if(M.mind.assigned_role in engineering_positions)
			active_with_role["Engineer"]++

		if(M.mind.assigned_role in medical_positions)
			active_with_role["Medical"]++

		if(M.mind.assigned_role in science_positions)
			active_with_role["Scientist"]++

		if(M.mind.assigned_role in (service_positions - "Head of Personnel"))//HoP has stuff to do
			active_with_role["Service"]++

		/* Since Cargo orders are mining only, we'll exclusively check the miner count for now
		if(M.mind.assigned_role in (cargo_positions - "Head of Personnel"))
			active_with_role["Cargo"]++
		*/
		if(M.mind.assigned_role == "Shaft Miner")
			active_with_role["Cargo"]++

	return active_with_role

/proc/get_dept_leaderboard()
	var/list/dept_leaderboard = list()
	var/list/depts = list(
		"Cargo",
		"Science",
		"Medical",
		"Civilian",
		"Engineering")
	for (var/dept in depts)
		var/datum/money_account/acct = department_accounts[dept]
		dept_leaderboard[dept] = acct.money
		for (var/i = dept_leaderboard.len, i > 1, i--)
			if (dept_leaderboard[dept_leaderboard[i]] > dept_leaderboard[dept_leaderboard[i-1]])
				dept_leaderboard.Swap(i,i-1)
	return dept_leaderboard
