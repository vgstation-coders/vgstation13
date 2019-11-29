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
	name = command_name()

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

/datum/centcomm_order/department/New()
	..()
	acct = department_accounts[acct_by_string]

/datum/centcomm_order/department/cargo //Orders that cargo can manage
	acct_by_string = "Cargo"

/datum/centcomm_order/department/cargo/diamonds/New()
	..()
	requested = list(
		/obj/item/stack/sheet/mineral/diamond = rand(5,50)
	)
	worth = (VALUE_DIAMOND+rand(1,3))*requested[requested[1]]

/datum/centcomm_order/department/cargo/uranium/New()
	..()
	requested = list(
		/obj/item/stack/sheet/mineral/uranium = rand(5,50)
	)
	worth = (VALUE_URANIUM*rand(1,3))*requested[requested[1]]

/datum/centcomm_order/department/cargo/gold/New()
	..()
	requested = list(
		/obj/item/stack/sheet/mineral/gold = rand(5,50)
	)
	worth = (VALUE_GOLD*rand(1,3))*requested[requested[1]]

/datum/centcomm_order/department/cargo/silver/New()
	..()
	requested = list(
		/obj/item/stack/sheet/mineral/silver = rand(5,50)
	)
	worth = (VALUE_SILVER*rand(1,3))*requested[requested[1]]

/datum/centcomm_order/department/cargo/phazon/New()
	..()
	requested = list(
		/obj/item/stack/sheet/mineral/phazon = rand(1,10)
	)
	worth = (VALUE_PHAZON*rand(1,3))*requested[requested[1]]

/datum/centcomm_order/department/cargo/clown/New()
	..()
	requested = list(
		/obj/item/stack/sheet/mineral/clown = rand(1,10)
	)
	worth = (VALUE_CLOWN*rand(1,3))*requested[requested[1]]


/datum/centcomm_order/department/science //Orders that science can manage
	acct_by_string = "Science"

/datum/centcomm_order/department/science/nuclear_gun/New()
	..()
	requested = list(
		/obj/item/weapon/gun/energy/gun/nuclear = rand(1,5)
	)
	worth = rand(350,750)*requested[requested[1]]

/datum/centcomm_order/department/science/subspace_tunnel/New()
	..()
	requested = list(
		/obj/item/weapon/subspacetunneler = rand(1,3)
	)
	worth = rand(350,750)*requested[requested[1]]

/datum/centcomm_order/department/medical
	acct_by_string = "Medical"

/datum/centcomm_order/department/medical/kidneys/New()
	..()
	requested = list(
		/obj/item/organ/internal/kidneys = rand(1,3)
	)
	worth = rand(100,300)*requested[requested[1]]

/datum/centcomm_order/department/civilian
	acct_by_string = "Civilian"

/datum/centcomm_order/department/civilian/pie/New()
	..()
	requested = list(
		/obj/item/weapon/reagent_containers/food/snacks/pie = rand(3,12)
	)
	worth = rand(15,30)*requested[requested[1]]
	name = "Clown Federation" //honk

/datum/centcomm_order/department/civilian/poutinecitadel/New()
	..()
	requested = list(
		/obj/structure/poutineocean/poutinecitadel = 1
	)
	worth = rand(1000,3000)*requested[requested[1]]

/datum/centcomm_order/department/civilian/sweetsundaeramen/New()
	..()
	requested = list(
		/obj/item/weapon/reagent_containers/food/snacks/sweetsundaeramen = rand(1,3)
	)
	worth = rand(150,300)*requested[requested[1]]

/datum/centcomm_order/department/civilian/superburger/New()
	..()
	requested = list(
		/obj/item/weapon/reagent_containers/food/snacks/superbiteburger = rand(1,3)
	)
	worth = rand(250,500)*requested[requested[1]]

/datum/centcomm_order/department/civilian/turkey/New()
	..()
	requested = list(
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/turkey = rand(1,2)
	)
	worth = rand(200,400)*requested[requested[1]]

/datum/centcomm_order/department/civilian/popcake/New()
	..()
	requested = list(
		/obj/structure/popout_cake = 1
	)
	worth = rand(600,1200)*requested[requested[1]]

/datum/centcomm_order/department/civilian/bkipper/New()
	..()
	requested = list(
		/obj/item/weapon/reagent_containers/food/snacks/bleachkipper = rand(2,5)
	)
	worth = rand(120,500)*requested[requested[1]]

/datum/centcomm_order/department/civilian/potentham/New()
	..()
	requested = list(
		/obj/item/weapon/reagent_containers/food/snacks/potentham = rand(1,2)
	)
	worth = rand(400,2001)*requested[requested[1]]

/datum/centcomm_order/department/civilian/sundayroast/New()
	..()
	requested = list(
		/obj/item/weapon/reagent_containers/food/snacks/sundayroast = rand(1,2)
	)
	worth = rand(400,900)*requested[requested[1]]

/proc/create_centcomm_order(var/datum/centcomm_order/C)
	SSsupply_shuttle.add_centcomm_order(C)

/proc/get_potential_orders()
	var/list/orders = list()
	orders.Add(subtypesof(/datum/centcomm_order/department/cargo))
	orders.Add(subtypesof(/datum/centcomm_order/department/science))
	orders.Add(subtypesof(/datum/centcomm_order/department/medical))
	orders.Add(subtypesof(/datum/centcomm_order/department/civilian))

	return orders

/proc/create_random_order()
	var/choice = pick(get_potential_orders())
	create_centcomm_order(new choice)

/proc/create_random_orders(var/num_orders)
	var/list/choices = get_potential_orders()
	for(var/i = 1 to num_orders)
		var/choice = pick_n_take(choices)
		create_centcomm_order(new choice)