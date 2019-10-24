#define CAT_NORMAL 	1
#define CAT_HIDDEN 	2
#define CAT_COIN   	3
#define CAT_VOUCH  	4
#define CAT_HOLIDAY	5

//Maximum price you can assign to an item
#define MAX_ITEM_PRICE 1000000000

var/global/num_vending_terminals = 1

/obj/machinery/vending
	name = "empty vending machine"
	desc = "Just add capitalism!"
	icon = 'icons/obj/vending.dmi'
	icon_state = "empty"
	var/obj/structure/vendomatpack/pack = null
	anchored = 1
	density = 1
	layer = OPEN_DOOR_LAYER //This is below BELOW_OBJ_LAYER because vendors can contain crates/closets
	var/health = 100
	var/maxhealth = 100 //Kicking feature
	var/active = 1		//No sales pitches if off!
	var/vend_ready = 1	//Are we ready to vend?? Is it time??
	var/vend_delay = 10	//How long does it take to vend?
	var/shoot_chance = 2 //How often do we throw items?
	var/datum/data/vending_product/currently_vending = null // A /datum/data/vending_product instance of what we're paying for right now.
	// To be filled out at compile time
	var/list/accepted_coins = list(
			/obj/item/weapon/coin,
			/obj/item/weapon/reagent_containers/food/snacks/chococoin
			)	// Accepted coins by the machine.

	var/list/products	= list()	// For each, use the following pattern:
	var/list/contraband	= list()	// list(/type/path = amount,/type/path2 = amount2)
	var/list/premium 	= list()	// No specified amount = only one in stock
	var/list/prices     = list()	// Prices for each item, list(/type/path = price), items not in the list don't have a price.
	var/list/vouched    = list()	//For voucher-only items. These aren't available in any way without the appropriate voucher.
	var/list/specials    = list()	//Allows you to lock items to certain holidays, otherwise they don't show up

	var/list/custom_stock = list() 	//Custom items are stored inside our contents, but we keep track of them here so we don't vend our component parts or anything.

	var/list/product_slogans = list()	// List of slogans the machine will yell at random intervals, optional
	var/list/product_ads = list()		// List of small ad messages displayed in the vending screen, random chance, optional
	var/list/product_records = list()
	var/list/hidden_records = list()
	var/list/coin_records = list()
	var/list/voucher_records = list()
	var/list/holiday_records = list()
	var/vend_reply				//Thank you for shopping!
	var/last_reply = 0
	var/last_slogan = 0			//When did we last pitch?
	var/slogan_delay = 6000		//How long until we can pitch again?
	var/icon_vend				//Icon_state when vending!
	var/icon_deny				//Icon_state when vending!
	//var/emagged = 0			//Ignores if somebody doesn't have card access to that machine.
	var/seconds_electrified = 0	//Shock customers like an airlock.
	var/shoot_inventory = 0		//Fire items at customers! We're broken!
	var/shut_up = 0				//Stop spouting those godawful pitches!
	var/extended_inventory = 0	//can we access the hidden inventory?
	var/scan_id = 1
	var/unhackable = 0
	var/obj/item/weapon/coin
	var/datum/wires/vending/wires = null
	var/list/overlays_vending[2]//1 is the panel layer, 2 is the dangermode layer

	var/list/vouchers
	var/obj/item/weapon/storage/lockbox/coinbox/coinbox
	var/cardboard = 0 //1 if sheets of cardboard are added

	var/list/categories = list()

	var/machine_id = "#"

	machine_flags = SCREWTOGGLE | WRENCHMOVE | FIXED2WORK | CROWDESTROY | EJECTNOTDEL | PURCHASER | WIREJACK

	var/account_first_linked = 1
	var/is_custom_machine = FALSE // true if this vendor supports editing the prices
	var/edit_mode = FALSE // Used for editing machine stock and information
	var/is_being_filled = FALSE // `in_use` from /obj is already used for tracking users of this machine's UI
	var/credits_held = 0 // How many credits in the machine

/atom/movable/proc/product_name()
	return name
/obj/item/stack/product_name()
	return "A stack of [amount] [name]"

/datum/data/vending_product
	var/custom = FALSE
	var/product_name = "generic"
	var/product_path = null //NON-CUSTOM ONLY - Path to spawn when creating a new one of this product
	var/original_amount = 0 //NON-CUSTOM ONLY - How many items of this product the recharge pack starts with
	var/amount = 0
	var/price = 0
	var/display_color = null //string, "red", "green", "blue", etc
	var/category = CAT_NORMAL //available on holidays, by default, contraband, or premium (requires a coin)
	var/subcategory = null
	var/mini_icon = null
	var/assignedholiday = null //Add an item to the 'specials' list to make it only show up on a certain holiday

/* TODO: Add this to deconstruction for vending machines
/obj/item/compressed_vend
	name = "compressed sale cartridge"
	desc = "A compressed matter variant used to load vending machines."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	var/list/products
	var/list/contraband
	var/list/premium
*/

/obj/machinery/vending/cultify()
	new /obj/structure/cult_legacy/forge(loc)
	..()

/obj/machinery/vending/New()
	..()
	machine_id = "[name] #[multinum_display(num_vending_machines,4)]"
	num_vending_machines++

	overlays_vending[1] = "[icon_state]-panel"

	component_parts = newlist(\
		/obj/item/weapon/circuitboard/vendomat,\
		/obj/item/weapon/stock_parts/matter_bin,\
		/obj/item/weapon/stock_parts/manipulator,\
		/obj/item/weapon/stock_parts/scanning_module\
	)

	RefreshParts()

	wires = new(src)
	spawn(4)
		// So not all machines speak at the exact same time.
		// The first time this machine says something will be at slogantime + this random value,
		// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is crated.
		src.last_slogan = world.time + rand(0, slogan_delay)

		power_change()

	coinbox = new(src)

	if(ticker)
		initialize()

/obj/machinery/vending/initialize()
	build_inventories()
	link_to_account()

/obj/machinery/vending/proc/build_inventories()
	product_records = new/list()
	build_inventory(products)
	build_inventory(contraband, 1)
	build_inventory(premium, 0, 1)
	build_inventory(vouched, 0, 0, 1)

/obj/machinery/vending/proc/link_to_account()
	reconnect_database()
	linked_account = vendor_account

/obj/machinery/vending/RefreshParts()
	var/manipcount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/manipulator))
			manipcount += SP.rating
	shoot_chance = manipcount * 3

/obj/machinery/vending/Destroy()
	if(wires)
		qdel(wires)
		wires = null

	if(product_records.len && cardboard) //Only spit out if we have slotted cardboard
		if(is_custom_machine)
			var/obj/structure/vendomatpack/custom/newpack = new(src.loc)
			for(var/obj/item/I in custom_stock)
				I.forceMove(newpack)
				custom_stock.Remove(I)
		else
			var/obj/structure/vendomatpack/partial/newpack = new(src.loc)
			newpack.stock = products
			newpack.secretstock = contraband
			newpack.preciousstock = premium
			newpack.targetvendomat = src.type
			newpack.product_records = product_records
			newpack.hidden_records = hidden_records
			newpack.coin_records = coin_records

	if(coinbox)
		coinbox.forceMove(get_turf(src))
	..()

/obj/machinery/vending/examine(var/mob/user)
	..()
	if(currently_vending)
		to_chat(user, "<span class='notice'>Its small, red segmented display reads $[num2septext(currently_vending.price - credits_held)]</span>")

/obj/machinery/vending/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover) && mover.checkpass(PASSMACHINE))
		return 1
	if(seconds_electrified > 0)
		if(istype(mover, /obj/item))
			var/obj/item/I = mover
			if(I.siemens_coefficient > 0)
				spark(src, 5)
	return ..()

/obj/machinery/vending/MouseDropTo(atom/movable/O as mob|obj, mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return

	if(user.incapacitated() || user.lying)
		return
	if(!Adjacent(user) || !user.Adjacent(src) || !user.Adjacent(O))
		return

	if(istype(O,/obj/structure/vendomatpack))
		var/obj/structure/vendomatpack/P = O
		if(!anchored)
			to_chat(user, "<span class='warning'>You need to anchor the vending machine before you can refill it.</span>")
			return
		if(!pack)
			if(is_being_filled)
				to_chat(user, "<span class='warning'>\The [src] is already in use!</span>")
				return
			if(P.in_use)
				to_chat(user, "<span class='warning'>\The [P] is already in use!</span>")
				return
			is_being_filled = TRUE
			P.in_use = TRUE
			to_chat(user, "<span class='notice'>You start filling the vending machine with the recharge pack's materials.</span>")
			if(do_after_many(user, list(src, P), 3 SECONDS))
				var/obj/machinery/vending/newmachine = new P.targetvendomat(loc)
				to_chat(user, "<span class='notice'>[bicon(newmachine)] You finish filling the vending machine, and use the stickers inside the pack to decorate the frame.</span>")
				playsound(newmachine, 'sound/machines/hiss.ogg', 50, 0, 0)
				newmachine.pack = P.type
				getFromPool(/obj/item/stack/sheet/cardboard, P.loc, 4)
				if(istype(P, /obj/structure/vendomatpack/custom))
					for(var/obj/item/I in P.contents)
						newmachine.loadCustomItem(I)
				else if(P.stock.len) //This is true if the vendopack is a used recharge pack. "Stock" packs have nada.
					newmachine.products = P.stock
					newmachine.contraband = P.secretstock
					newmachine.premium = P.preciousstock
					newmachine.product_records = P.product_records
					newmachine.hidden_records = P.hidden_records
					newmachine.coin_records = P.coin_records
				qdel(P)
				if(user.machine==src)
					newmachine.attack_hand(user)
				component_parts = 0
				qdel(coinbox)
				qdel(src)
			else
				is_being_filled = FALSE
				P.in_use = FALSE
		else
			if(istype(P,pack))
				if(is_being_filled)
					to_chat(user, "<span class='warning'>\The [src] is already in use!</span>")
					return
				if(P.in_use)
					to_chat(user, "<span class='warning'>\The [P] is already in use!</span>")
					return
				is_being_filled = TRUE
				P.in_use = TRUE
				to_chat(user, "<span class='notice'>You start refilling the vending machine with the recharge pack's materials.</span>")
				if(do_after_many(user, list(src, P), 3 SECONDS))
					to_chat(user, "<span class='notice'>[bicon(src)] You finish refilling the vending machine.</span>")
					playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
					if(is_custom_machine)
						custom_refill(P, user)
					else
						normal_refill(P, user)
				else
					P.in_use = FALSE // Only update this if `do_after_many` failed, as P gets deleted
				is_being_filled = FALSE

			else
				to_chat(user, "<span class='warning'>This recharge pack isn't meant for this kind of vending machines.</span>")

/obj/machinery/vending/proc/normal_refill(obj/structure/vendomatpack/P, mob/user) //TODO: This is totally fucking broken
	for (var/datum/data/vending_product/D in product_records)
		D.amount = D.original_amount
	for (var/datum/data/vending_product/D in hidden_records)
		D.amount = D.original_amount
	getFromPool(/obj/item/stack/sheet/cardboard, P.loc, 4)
	qdel(P)
	if(user.machine==src)
		src.attack_hand(user)

/obj/machinery/vending/proc/custom_refill(obj/structure/vendomatpack/P, mob/user)
	for(var/obj/item/I in P.contents)
		loadCustomItem(I)
	getFromPool(/obj/item/stack/sheet/cardboard, P.loc, 4)
	qdel(P)

/obj/machinery/vending/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				malfunction()


/obj/machinery/vending/blob_act()
	if(prob(75))
		malfunction()
	else
		qdel(src)

/obj/machinery/vending/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return
	switch(severity)
		if(1.0)
			malfunction()
		if(2.0)
			if(prob(50))
				malfunction()
		if(3.0)
			if(prob(25))
				malfunction()

//This proc is not used by custom vending machines.
/obj/machinery/vending/proc/build_inventory(var/list/productlist,hidden=0,req_coin=0,voucher_only=0)
	for(var/typepath in productlist)
		var/amount = productlist[typepath]
		var/price = prices[typepath]
		var/special = specials[typepath]

		if (isnull(amount))
			amount = 1

		var/datum/data/vending_product/R = new()
		R.product_path = typepath
		R.amount = amount
		R.original_amount = amount
		R.price = price
		R.assignedholiday = special
		if (!R.display_color)
			R.display_color = pick("red", "blue", "green")
		if (hidden)
			R.category=CAT_HIDDEN
			hidden_records  += R
		else if (req_coin)
			R.category=CAT_COIN
			coin_records    += R
		else if (voucher_only)
			voucher_records += R
			R.category=CAT_VOUCH
		else if (R.assignedholiday)
			R.category=CAT_HOLIDAY
			R.display_color = pick("orange", "purple", "navy")
			if(R.assignedholiday == Holiday)
				holiday_records += R //only add it to the lists if today's our day
		else
			R.category = CAT_NORMAL
			product_records.Add(R)

		var/obj/item/initializer = typepath
		if(!is_custom_machine)
			R.product_name = initial(initializer.name)
		R.subcategory = initial(initializer.vending_cat)

/obj/machinery/vending/proc/get_item_by_type(var/this_type)
	var/list/datum_products = list()
	datum_products |= hidden_records
	datum_products |= coin_records
	datum_products |= voucher_records
	datum_products |= holiday_records
	datum_products |= product_records
	for(var/datum/data/vending_product/product in datum_products)
		if(product.product_path == this_type)
			return product
	return null

//		to_chat(world, "Added: [R.product_name]] - [R.amount] - [R.product_path]")

/obj/machinery/vending/emag(mob/user)
	if(!emagged || !extended_inventory || scan_id)
		emagged = 1
		extended_inventory = 1
		scan_id = 0
		return 1
	return 0 //Fucking gross

/obj/machinery/vending/npc_tamper_act(mob/living/L)
	if(!panel_open)
		togglePanelOpen(null, L)
	if(wires)
		wires.npc_tamper(L)


/obj/machinery/vending/proc/can_accept_voucher(var/obj/item/voucher/voucher, mob/user)
	if(istype(voucher, /obj/item/voucher/free_item))
		var/obj/item/voucher/free_item/free_vouch = voucher
		for(var/vend_item in free_vouch.freebies)
			var/datum/data/vending_product/product = get_item_by_type(vend_item)
			if(product && product.amount)
				return 1
	return 0

//this should ideally be called last as a parent method, since it can delete the voucher
/obj/machinery/vending/proc/voucher_act(var/obj/item/voucher/voucher, mob/user)
	if(istype(voucher, /obj/item/voucher/free_item))
		var/obj/item/voucher/free_item/free_vouch = voucher
		for(var/i = 1; i <= free_vouch.vend_amount; i++)
			if(!free_vouch.freebies || !free_vouch.freebies.len)
				break
			var/to_vend = pick(free_vouch.freebies)
			if(free_vouch.single_items)
				free_vouch.freebies.Remove(to_vend)
			var/datum/data/vending_product/product = get_item_by_type(to_vend)
			if(product && product.amount)
				src.vend(product, user, by_voucher = 1)

	if(voucher.shred_on_use)
		qdel(voucher)
	else
		if(!vouchers)
			vouchers = list()
		vouchers.Add(voucher)
		if(coinbox)
			voucher.forceMove(coinbox)
	return 1

/obj/machinery/vending/attackby(obj/item/W, mob/user)
	if(stat & (BROKEN) && !iswrench(W))
		if(istype(W, /obj/item/stack/sheet/glass/rglass))
			var/obj/item/stack/sheet/glass/rglass/G = W
			to_chat(user, "<span class='notice'>You replace the broken glass.</span>")
			G.use(1)
			stat &= ~BROKEN
			src.health = 100
			power_change()
			getFromPool(/obj/item/weapon/shard, loc)
		else
			to_chat(user, "<span class='notice'>The glass in \the [src] is broken! Fix it with reinforced glass first.</span>")
			return
	. = ..()
	if(.)
		return .
	if(!cardboard && istype(W, /obj/item/stack/sheet/cardboard))
		var/obj/item/stack/sheet/cardboard/C = W
		if(C.amount>=4)
			C.use(4)
			to_chat(user, "<span class='notice'>You slot some cardboard into \the [src].</span>")
			cardboard = 1
			src.updateUsrDialog()
	if(iswiretool(W))
		if(panel_open)
			attack_hand(user)
		return
	else if(premium.len > 0 && is_type_in_list(W, accepted_coins))
		if (isnull(coin))
			if(user.drop_item(W, src))
				coin = W
				to_chat(user, "<span class='notice'>You insert a coin into [src].</span>")
				src.updateUsrDialog()
		else
			to_chat(user, "<SPAN CLASS='notice'>There's already a coin in [src].</SPAN>")
		return

	else if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/customizable/candy/coin))
		to_chat(user, "<span class='rose'>That coin is smudgy and oddly soft, you don't think that would work.</span>")
		return

	else if(istype(W, /obj/item/voucher))
		if(can_accept_voucher(W, user))
			if(user.drop_item(W, src))
				to_chat(user, "<span class='notice'>You insert [W] into [src].</span>")
				return voucher_act(W, user)
				src.updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>\The [src] refuses to take [W].</span>")
			return 1

	else if(istype(W, /obj/item/weapon/spacecash))
		var/obj/item/weapon/spacecash/C = W
		pay_with_cash(C, user)

	else if(istype(W, /obj/item/weapon/card/emag))
		visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
		to_chat(user, "<span class='notice'>You swipe \the [W] through [src]</span>")
		if (emag())
			to_chat(user, "<span class='info'>[src] responds with a soft beep.</span>")
		else
			to_chat(user, "<span class='info'>Nothing happens.</span>")

	else if(istype(W, /obj/item/weapon/card))
		if(!linked_db)
			reconnect_database()

		if(currently_vending) //We're trying to pay, not set the account
			connect_account(user, W)
			src.updateUsrDialog()
			return

		if(account_first_linked && linked_account) // Account check
			if(!user.Adjacent(src))
				return 0
			var/obj/item/weapon/card/card_swiped = W
			visible_message("<span class='info'>[user] swipes a card through [src].</span>")
			if(card_swiped.associated_account_number != linked_account.account_number)
				to_chat(user, "[bicon(src)]<span class='warning'> Access denied. Your ID doesn't match the vending machine's connected account.</span>")
				return 0
			else if (!edit_mode && charge_flow_verify_security(linked_db, card_swiped, user, null, TRUE) != CARD_CAPTURE_SUCCESS)
				to_chat(user, "[bicon(src)]<span class='warning'> Access denied. Security Violation.</span>")
				return 0
			edit_mode = !edit_mode
			src.updateUsrDialog()
			return
		if(!user.Adjacent(src))
			return 0

		connect_to_user_account(user)

	else if(istype(W, /obj/item/) && edit_mode)
		if(istype(W, /obj/item/weapon/disk/nuclear))
			to_chat(user, "<span class='notice'>Suddenly your hand stops responding. You can't do it.</span>")
			return
		if(user.drop_item(W, src))
			loadCustomItem(W)
			src.updateUsrDialog()

/obj/machinery/vending/proc/loadCustomItem(var/obj/item/item)
	for(var/datum/data/vending_product/VP in product_records)
		if(VP.custom && VP.product_name == item.product_name())
			VP.amount += 1
			custom_stock += item
			if(item.loc != src)
				item.forceMove(src)
			return
	//If this code block is reached, no existing vending_product exists, so we must create one
	var/datum/data/vending_product/R = new()
	R.custom = TRUE
	R.product_name = item.product_name()
	R.mini_icon = costly_bicon(item)
	R.display_color = pick("red", "blue", "green")
	R.amount = 1
	if(item.loc != src)
		item.forceMove(src)
	product_records += R
	custom_stock += item

/obj/machinery/vending/proc/connect_to_user_account(mob/user)
	var/new_account = input(user,"Please enter the account to connect to.","New account link") as num
	if(!user.Adjacent(src) || !new_account)
		return FALSE
	for(var/datum/money_account/D in all_money_accounts)
		if(D.account_number == new_account)
			linked_account = D
			if(!account_first_linked)
				account_first_linked = 1
			playsound(src, 'sound/machines/twobeep.ogg', 50, 0)
			to_chat(user, "[bicon(src)]<span class='notice'>New connection established: [D.owner_name].</span>")
			edit_mode = !edit_mode
			src.updateUsrDialog()
			return TRUE
	to_chat(user, "[bicon(src)]<span class='warning'>The specified account doesn't exist.</span>")
	return FALSE
/obj/machinery/vending/proc/dispense_change(var/amount = 0)
	if(!amount)
		amount = credits_held
		credits_held = 0
	if(amount > 0)
		dispense_cash(amount,src.loc)

/**
 *  Receive payment with cashmoney.
 *
 *  usr is the mob who gets the change.
 */
/obj/machinery/vending/proc/pay_with_cash(var/obj/item/weapon/spacecash/cashmoney, mob/user)
	if(!currently_vending)
		return
	visible_message("<span class='info'>[usr] inserts a credit chip into [src].</span>", "You hear a whirr.")
	credits_held += cashmoney.get_total()
	qdel(cashmoney)
	if(credits_held >= currently_vending.price)
		credits_held -= currently_vending.price
		dispense_change()
		vend(src.currently_vending, usr)
		currently_vending = null
		updateUsrDialog()
		return 1
	else
		return 0

/obj/machinery/vending/scan_card(var/obj/item/weapon/card/I)
	if(!currently_vending)
		return
	if (istype(I, /obj/item/weapon/card))
		var/charge_response = charge_flow(linked_db, I, usr, currently_vending.price - credits_held, linked_account, "Purchase of [currently_vending.product_name]", src.name, machine_id)
		switch(charge_response)
			if(CARD_CAPTURE_SUCCESS)
				playsound(src, 'sound/machines/chime.ogg', 50, 1)
				visible_message("[bicon(src)] \The [src] chimes.")
				if(credits_held)
					linked_account.charge(-credits_held, null, "Partial purchase of [currently_vending.product_name]", src.name, machine_id, linked_account.owner_name)
					credits_held=0
				// Vend the item
				src.vend(src.currently_vending, usr)
				currently_vending = null
				src.updateUsrDialog()
			if(CARD_CAPTURE_FAILURE_USER_CANCELED)
				currently_vending = null
				src.updateUsrDialog()
			else
				playsound(src, 'sound/machines/alert.ogg', 50, 1)
				visible_message("[bicon(src)] \The [src] buzzes.")

/obj/machinery/vending/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/vending/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/vending/proc/GetProductLine(var/datum/data/vending_product/P)
	var/micon = !isnull(P.mini_icon) ? "<td class='fridgeIcon cropped'>[P.mini_icon]</td>" : ""
	var/dat = {"[micon]<FONT color = '[P.display_color]'><B>[P.product_name]</B>:
		<b>[P.amount]</b> </font>"}
	if(P.price)
		dat += " <b>($[P.price])</b>"
	if (P.amount > 0)
		var/idx=GetProductIndex(P)
		dat += " <a href='byond://?src=\ref[src];vend=[idx];cat=[P.category]'>(Vend)</A>"
		if (edit_mode)
			dat += " <a href='byond://?src=\ref[src];set_price=[idx];cat=[P.category]'>(Set Price)</A>"
	else
		dat += " <span class='warning'>SOLD OUT</span>"
		if(edit_mode)
			var/idx=GetProductIndex(P)
			dat += " <a href='byond://?src=\ref[src];delete_entry=[idx];cat=[P.category]'>(Delete Entry)</A>"
	dat += "<br>"

	return dat

/obj/machinery/vending/proc/GetProductIndex(var/datum/data/vending_product/P)
	var/list/plist
	switch(P.category)
		if(CAT_HOLIDAY)
			plist=holiday_records
		if(CAT_NORMAL)
			plist=product_records
		if(CAT_HIDDEN)
			plist=hidden_records
		if(CAT_COIN)
			plist=coin_records
		else
			warning("UNKNOWN CATEGORY [P.category] IN TYPE [P.product_path] INSIDE [type]!")
	return plist.Find(P)

/obj/machinery/vending/proc/GetProductByID(var/pid, var/category)
	switch(category)
		if(CAT_HOLIDAY)
			return holiday_records[pid]
		if(CAT_NORMAL)
			return product_records[pid]
		if(CAT_HIDDEN)
			return hidden_records[pid]
		if(CAT_COIN)
			return coin_records[pid]
		else
			warning("UNKNOWN PRODUCT: PID: [pid], CAT: [category] INSIDE [type]!")
			return null

/obj/machinery/vending/proc/TurnOff(var/ticks) //Turn off for a while. 10 ticks = 1 second
	if(stat & (BROKEN|NOPOWER))
		return

	stat |= NOPOWER
	src.update_vicon()
	src.visible_message("<span class='warning'>[src] goes off!</span>")

	spawn(ticks)

	power_change()

/obj/machinery/vending/proc/update_vicon()
	if(stat & (BROKEN))
		src.icon_state = "[initial(icon_state)]-broken"
		return
	else if (stat & (NOPOWER))
		src.icon_state = "[initial(icon_state)]-off"
	else
		src.icon_state = "[initial(icon_state)]"

/obj/machinery/vending/proc/damaged(var/coef=1)
	src.health -= 4*coef
	if(src.health <= 0)
		stat |= BROKEN
		src.update_vicon()
		return
	if(prob(2*coef)) //Jackpot!
		malfunction()
	if(prob(2*coef))
		src.TurnOff(600) //A whole minute
	/*if(prob(1))
		to_chat(usr, "<span class='warning'>You fall down and break your leg!</span>")
		user.audible_scream()
		shake_camera(user, 2, 1)*/

/obj/machinery/vending/kick_act(mob/living/carbon/human/user)
	..()

	damaged()

/obj/machinery/vending/attack_construct(var/mob/user)
	if (!Adjacent(user))
		return 0
	if(istype(user,/mob/living/simple_animal/construct/armoured))
		shake(1, 3)
		playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
		damaged(4)
		return 1
	return 0

/obj/machinery/vending/attack_hand(mob/living/user as mob)
	if(stat & (BROKEN))
		to_chat(user, "<span class='notice'>The glass in \the [src] is broken, it refuses to work.</span>")
		return

	if(stat & (NOPOWER))
		to_chat(user, "<span class='notice'>\The [src] is dark and unresponsive.</span>")
		return

	if(!isAdminGhost(usr) && (user.lying || user.incapacitated()))
		return 0

	if(M_TK in user.mutations && user.a_intent == "hurt" && iscarbon(user))
		if(!Adjacent(user))
			to_chat(user, "<span class='danger'>You slam \the [src] with your mind!</span>")
			visible_message("<span class='danger'>[src] dents slightly, as if it was struck!</span>")
			damaged()

	if(seconds_electrified > 0)
		if(shock(user, 100))
			return
	else if (seconds_electrified)
		seconds_electrified = 0

	user.set_machine(src)

	var/vendorname = (src.name)  //import the machine's name

	var/vertical = 400

	if(src.currently_vending)
		var/dat = "<TT><center><b>[vendorname]</b></center><hr /><br>" //display the name, and added a horizontal rule

		dat += {"<b>You have selected [currently_vending.product_name].<br>Please ensure your ID is in your ID holder or hand.</b><br>
			<a href='byond://?src=\ref[src];buy=1'>Pay</a> |
			<a href='byond://?src=\ref[src];cancel_buying=1'>Cancel</a>"}
		user << browse(dat, "window=vending")
		onclose(user, "")
		return

	var/dat = "<TT><center><b>[vendorname]</b></center><hr/>" //display the name, and added a horizontal rule
	if(product_ads.len)
		dat += "<marquee>[pick(product_ads)]</marquee><hr/>"
	dat += "<br><b>Select an item: </b><br><br>" //the rest is just general spacing and bolding

	if (premium.len > 0)
		dat += "<b>Coin slot:</b> [coin ? coin : "No coin inserted"] (<a href='byond://?src=\ref[src];remove_coin=1'>Remove</A>)<br><br>"

	if (src.product_records.len == 0)
		dat += "<font color = 'red'>No products loaded!</font><br><br></TT>"
	else
		var/list/display_records = src.product_records.Copy()

		if(Holiday)
			display_records += src.holiday_records
		if(src.extended_inventory)
			display_records += src.hidden_records
		if(src.coin)
			display_records += src.coin_records

		if(display_records.len > 12)
			vertical = min(400 + (16 * (display_records.len - 12)),840)

		categories["default"] = list()
		var/list/category_names = list()
		for (var/datum/data/vending_product/R in product_records)
			if(R.subcategory)
				if(!(R.subcategory in category_names))
					category_names += R.subcategory
					categories[R.subcategory] = list()
				categories[R.subcategory] += R
			else
				categories["default"] += R

		if(Holiday && holiday_records.len)
			var/col = pick("orange", "purple", "navy")
			dat += {"<FONT color = [col]><B>&nbsp;&nbsp;[Holiday] specials</B></font>:<br>"}
			for (var/datum/data/vending_product/R in holiday_records)
				dat += GetProductLine(R)
			dat += "<br>"

		if(is_custom_machine)
			for(var/datum/data/vending_product/VP in product_records)
				if(!istype(VP))
					continue
				dat += GetProductLine(VP)
		else
			for (var/datum/data/vending_product/R in categories["default"])
				dat += GetProductLine(R)
		dat += "<br>"

		for(var/cat_name in category_names)
			dat += {"<B>&nbsp;&nbsp;[cat_name]</B>:<br>"}
			for (var/datum/data/vending_product/R in categories[cat_name])
				dat += GetProductLine(R)
			dat += "<br>"

		if(src.extended_inventory)
			dat += {"<B>&nbsp;&nbsp;contraband</B>:<br>"}
			for (var/datum/data/vending_product/R in hidden_records)
				dat += GetProductLine(R)
			dat += "<br>"

		if(src.coin)
			dat += {"<B>&nbsp;&nbsp;premium</B>:<br>"}
			for (var/datum/data/vending_product/R in coin_records)
				dat += GetProductLine(R)
			dat += "<br>"

		dat += "</TT>"

	if(panel_open)
		dat += wires()

		if(product_slogans != "")
			dat += "The speaker switch is [shut_up ? "off" : "on"]. <a href='?src=\ref[src];togglevoice=[1]'>(Toggle)</a><br>"

	if(is_custom_machine)
		if(edit_mode)
			dat += "Machine name: [src.name] <a href='?src=\ref[src];rename=1'>(Rename)</a><br>"
			dat += "Current slogans: " + (product_slogans.len >= CUSTOM_VENDING_MAX_SLOGANS ? "" : "<a href='?src=\ref[src];add_slogan=1'>(Add a Slogan)</a>") + "<br>"
			for(var/i = 1, i <= product_slogans.len, i++) // list slogans
				dat += "[product_slogans[i]] <a href='?src=\ref[src];delete_slogan_line=[i]'>(Delete)</a><br>"
			dat += "Edit mode is on."
		if(!account_first_linked)
			dat += "<br><br><i>Note: Remember to slide your ID on this machine to link your account. Once this is done, sliding your ID will enable editing and loading.</i>"

	user << browse(dat, "window=vending;size=400x[vertical]")
	onclose(user, "vending")

// returns the wire panel text
/obj/machinery/vending/proc/wires()
	return wires.GetInteractWindow()

/obj/machinery/vending/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=vending")
		return 1

	//testing("..(): [href]")
	var/free_vend = 0
	if(isAdminGhost(usr))
		free_vend = 1
	if(istype(usr,/mob/living/silicon))
		var/can_vend = 1
		if (href_list["vend"] && src.vend_ready && !currently_vending)
			var/idx=text2num(href_list["vend"])
			var/cat=text2num(href_list["cat"])
			var/datum/data/vending_product/R = GetProductByID(idx,cat)
			if(R.price)
				can_vend = FALSE //all borgs can buy free items from vending machines
		if(istype(usr,/mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = usr
			if(HAS_MODULE_QUIRK(R, MODULE_CAN_BUY))
				can_vend = TRUE //But if their module allows it..
		if(!can_vend || is_custom_machine) //currently made it so that silicon cannot buy from custom machine. Could make it so that selling to silicon is a toggleable option that bills the station.
			to_chat(usr, "<span class='warning'>The vending machine refuses to interface with you, as you are not in its target demographic!</span>")
			return
		else
			free_vend = 1//so that don't have to swipe their non-existant IDs

	if(href_list["remove_coin"])
		if(!coin)
			to_chat(usr, "There is no coin in this machine.")
			return

		coin.forceMove(get_turf(src))
		if(!usr.get_active_hand())
			usr.put_in_hands(coin)
		to_chat(usr, "<span class='notice'>You remove \the [coin] from \the [src]</span>")
		coin = null
	usr.set_machine(src)


	if (href_list["vend"] && src.vend_ready && !currently_vending)
		//testing("vend: [href]")

		if (!allowed(usr) && !emagged && scan_id) //For SECURE VENDING MACHINES YEAH
			to_chat(usr, "<span class='warning'>Access denied.</span>")//Unless emagged of course

			flick(src.icon_deny,src)
			return

		var/idx=text2num(href_list["vend"])
		var/cat=text2num(href_list["cat"])

		var/datum/data/vending_product/R = GetProductByID(idx,cat)
		if (!R || !istype(R) || R.amount <= 0)
			return

		if(R.price == null || !R.price)
			src.vend(R, usr)
		else if(free_vend)//for MoMMI and Service Borgs
			src.vend(R, usr)
		else
			src.currently_vending = R
			src.updateUsrDialog()

		return

	else if (href_list["set_price"] && src.vend_ready && !currently_vending && edit_mode)
		//testing("vend: [href]")

		if (!allowed(usr) && !emagged && scan_id) //For SECURE VENDING MACHINES YEAH
			to_chat(usr, "<span class='warning'>Access denied.</span>")//Unless emagged of course

			flick(src.icon_deny,src)
			return

		var/idx=text2num(href_list["set_price"])
		var/cat=text2num(href_list["cat"])

		var/datum/data/vending_product/R = GetProductByID(idx,cat)
		if (!R || !istype(R) || R.amount <= 0)
			return

		var/new_price = input("Enter a price", "Change price", R.price) as null|num
		if(new_price == null || new_price < 0)
			new_price = R.price
		new_price = min(new_price, MAX_ITEM_PRICE)

		R.price = new_price

	else if (href_list["delete_entry"] && src.vend_ready && !currently_vending && edit_mode)
		if (!allowed(usr) && !emagged && scan_id) //For SECURE VENDING MACHINES YEAH
			to_chat(usr, "<span class='warning'>Access denied.</span>")//Unless emagged of course

			flick(src.icon_deny,src)
			return

		var/idx=text2num(href_list["delete_entry"])
		var/cat=text2num(href_list["cat"])

		var/datum/data/vending_product/R = GetProductByID(idx,cat)
		if(!R || !istype(R) || R.amount > 0)
			return
		deleteEntry(R)

	else if (href_list["cancel_buying"])
		dispense_change()
		src.currently_vending = null

	else if (href_list["buy"])
		var/obj/item/weapon/card/card = usr.get_card()
		if(card)
			connect_account(usr, card)
		else
			to_chat(usr, "<span class='warning'>Please present a valid ID.</span>")

	else if ((href_list["togglevoice"]) && (src.panel_open))
		src.shut_up = !src.shut_up

	else if (href_list["rename"] && edit_mode)
		var/newname = input(usr,"Please enter a new name for the vending machine.","Rename Machine") as text
		if(length(newname) > 0 && length(newname) <= CUSTOM_VENDING_MAX_NAME_LENGTH)
			src.name = html_encode(newname)

	else if (href_list["add_slogan"] && edit_mode)
		var/newslogan = input(usr,"Please enter a new slogan that is between 1 and [CUSTOM_VENDING_MAX_SLOGAN_LENGTH] characters long.","Add a New Slogan") as text
		if(length(newslogan) > 0 && length(newslogan) <= CUSTOM_VENDING_MAX_SLOGAN_LENGTH)
			product_slogans += html_encode(newslogan)

	else if (href_list["delete_slogan_line"] && edit_mode && product_slogans.len > 0)
		product_slogans -= product_slogans[text2num(href_list["delete_slogan_line"])]

	src.add_fingerprint(usr)
	src.updateUsrDialog()

/obj/machinery/vending/proc/deleteEntry(datum/data/vending_product/R)
	if(R.custom)
		for(var/obj/item/I in custom_stock)
			if(I.product_name() == R.product_name)
				custom_stock -= I
	else
		for(var/obj/item/I in products)
			if(I.type == R.product_path)
				products -= I
				break
	product_records -= R
	qdel(R)

/obj/machinery/vending/proc/vend(datum/data/vending_product/R, mob/user, by_voucher = 0)
	if (!allowed(user) && !emagged && wires.IsIndexCut(VENDING_WIRE_IDSCAN)) //For SECURE VENDING MACHINES YEAH
		to_chat(user, "<span class='warning'>Access denied.</span>")//Unless emagged of course

		flick(src.icon_deny,src)
		return
	src.vend_ready = 0 //One thing at a time!!

	if (!by_voucher && (R in coin_records))
		if (isnull(coin))
			to_chat(user, "<SPAN CLASS='notice'>You need to insert a coin to get this item.</SPAN>")
			return

		var/return_coin = 0
		if(istype(coin, /obj/item/weapon/coin/))
			var/obj/item/weapon/coin/real_coin = coin
			if(real_coin.string_attached)
				if(prob(50))
					to_chat(user, "<SPAN CLASS='notice'>You successfully pulled the coin out before \the [src] could swallow it.</SPAN>")
					return_coin = 1
				else
					to_chat(user, "<SPAN CLASS='notice'>You weren't able to pull the coin out fast enough, the machine ate it, string and all.</SPAN>")

		if(return_coin)
			user.put_in_hands(coin)
		else
			if (!isnull(coinbox))
				if (coinbox.can_be_inserted(coin, TRUE))
					coinbox.handle_item_insertion(coin, TRUE)

		coin = null

	if(((src.last_reply + (src.vend_delay + 200)) <= world.time) && src.vend_reply)
		spawn(0)
			src.speak(src.vend_reply)
			src.last_reply = world.time

	use_power(5)
	if (src.icon_vend) //Show the vending animation if needed
		flick(src.icon_vend,src)
	R.amount--
	src.updateUsrDialog()
	visible_message("\The [src.name] whirrs as it vends", "You hear a whirr")
	spawn(vend_delay)
		if(!R.custom)
			new R.product_path(get_turf(src))
		else
			for(var/obj/O in custom_stock)
				if(O.product_name() == R.product_name)
					O.forceMove(src.loc)
					custom_stock.Remove(O)
					break
		src.vend_ready = 1
		src.updateUsrDialog()

/obj/machinery/vending/process()
	if(stat & (BROKEN|NOPOWER))
		return

	if(!src.active)
		return

	if(src.seconds_electrified > 0)
		src.seconds_electrified--

	//Pitch to the people!  Really sell it!
	if(((src.last_slogan + src.slogan_delay) <= world.time) && (src.product_slogans.len > 0) && (!src.shut_up) && prob(5))
		var/slogan = pick(src.product_slogans)
		src.speak(slogan)
		src.last_slogan = world.time

	if(src.shoot_inventory && prob(shoot_chance))
		src.throw_item()

/obj/machinery/vending/proc/speak(var/message)
	if(stat & NOPOWER)
		return

	if (!message)
		return
	say(message)

/obj/machinery/vending/say_quote(text)
	return "beeps, [text]"

/obj/machinery/vending/power_change()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else
		if( powered() )
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = "[initial(icon_state)]-off"
				stat |= NOPOWER

//Oh no we're malfunctioning!  Dump out some product and break.
/obj/machinery/vending/proc/malfunction()
	var/lost_inventory = rand(1,12)
	while(lost_inventory>0)
		throw_item()
		lost_inventory--
	stat |= BROKEN
	src.icon_state = "[initial(icon_state)]-broken"

//Somebody cut an important wire and now we're following a new definition of "pitch."
/obj/machinery/vending/proc/throw_item()

	var/mob/living/target = locate() in view(7, src)

	if (!target)
		return 0

	var/list/throwables = product_records.Copy()
	var/tries = 10 //Give up eventually


	if(extended_inventory)
		throwables += hidden_records

	if(!throwables.len)
		return 0

	while(tries)
		var/obj/throw_item
		var/datum/data/vending_product/R = pick(throwables)

		if(R.amount <= 0)
			tries--
			continue

		R.amount--
		if(!R.custom)
			throw_item = new R.product_path(get_turf(src))
		else
			for(var/obj/O in custom_stock)
				if(O.product_name() == R.product_name)
					O.forceMove(src.loc)
					custom_stock.Remove(O)
					throw_item = O
					break

		if(!throw_item)
			tries--
			continue

		spawn(0)
			throw_item.throw_at(target, 16, 3)

		src.visible_message("<span class='danger'>[src] launches [throw_item.name] at [target.name]!</span>")
		src.updateUsrDialog()
		return 1

	return 0

/obj/machinery/vending/update_icon()
	if(panel_open)
		overlays += overlays_vending[1]
	else
		overlays -= overlays_vending[1]

	overlays -= overlays_vending[2]
	if(emagged)
		overlays += overlays_vending[2]

/obj/machinery/vending/wirejack(var/mob/living/silicon/pai/P)
	if(..())
		extended_inventory = !extended_inventory
		scan_id = !scan_id
		return 1
	return 0


/*
 * Vending machine types
 */

/*

/obj/machinery/vending/[vendors name here]   // --vending machine template   :)
	name = ""
	desc = ""
	icon = ''
	icon_state = ""
	vend_delay = 15
	products = list()
	contraband = list()
	premium = list()

*/

/*
/obj/machinery/vending/atmospherics //Commenting this out until someone ponies up some actual working, broken, and unpowered sprites - Quarxink
	name = "Tank Vendor"
	desc = "A vendor with a wide variety of masks and gas tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	product_paths = "/obj/item/weapon/tank/oxygen;/obj/item/weapon/tank/plasma;/obj/item/weapon/tank/emergency_oxygen;/obj/item/weapon/tank/emergency_oxygen/engi;/obj/item/clothing/mask/breath"
	product_amounts = "10;10;10;5;25"
	vend_delay = 0
*/

/obj/machinery/vending/boozeomat
	name = "\improper Booze-O-Mat"
	desc = "A vending machine containing multiple drinks for bartending."
	req_access = list(access_bar)
	icon_state = "boozeomat"        //////////////18 drink entities below, plus the glasses, in case someone wants to edit the number of bottles
	icon_deny = "boozeomat-deny"
	products = list(
		/obj/item/weapon/reagent_containers/food/drinks/bottle/gin = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/tequila = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/rum = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/wine = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/sake = 5,
		/obj/item/weapon/reagent_containers/food/drinks/beer = 6,
		/obj/item/weapon/reagent_containers/food/drinks/ale = 6,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice = 4,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice = 4,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice = 4,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/cream = 4,
		/obj/item/weapon/reagent_containers/food/drinks/milk = 4,
		/obj/item/weapon/reagent_containers/food/drinks/soymilk = 4,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/tonic = 8,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola = 8,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sodawater = 15,
		/obj/item/weapon/reagent_containers/food/drinks/drinkingglass = 30,
		/obj/item/weapon/reagent_containers/food/drinks/ice = 9,
		)
	contraband = list(
		/obj/item/weapon/reagent_containers/food/drinks/tea = 10,
		/obj/item/weapon/reagent_containers/food/drinks/coffee = 10,
		/obj/item/weapon/reagent_containers/food/drinks/mug = 10
		)
	premium = list(
		/obj/item/weapon/reagent_containers/food/drinks/bottle/pwine = 1
	)
	product_slogans = list(
		"I hope nobody asks me for a bloody cup o' tea...",
		"Alcohol is humanity's friend. Would you abandon a friend?",
		"Quite delighted to serve you!",
		"Is nobody thirsty on this station?"
	)
	product_ads = list(
		"Drink up!",
		"Booze is good for you!",
		"Alcohol is humanity's best friend.",
		"Quite delighted to serve you!",
		"Care for a nice, cold beer?",
		"Nothing cures you like booze!",
		"Have a sip!",
		"Have a drink!",
		"Have a beer!",
		"Beer is good for you!",
		"Only the finest alcohol!",
		"Best quality booze since 2053!",
		"Award-winning wine!",
		"Maximum alcohol!",
		"Man loves beer.",
		"A toast for progress!"
	)
	pack = /obj/structure/vendomatpack/boozeomat

/obj/machinery/vending/assist
	name = "\improper Vendomat"
	desc = "A vending machine containing generic parts."
	icon_state = "generic"
	products = list(
		/obj/item/device/assembly/prox_sensor = 5,
		/obj/item/device/assembly/igniter = 3,
		/obj/item/device/assembly/signaler = 4,
		/obj/item/weapon/wirecutters = 1,
		/obj/item/weapon/cartridge/signal = 4,
		/obj/item/weapon/stock_parts/manipulator = 5,
		/obj/item/weapon/stock_parts/micro_laser = 3,
		/obj/item/weapon/stock_parts/matter_bin = 5,
		/obj/item/weapon/stock_parts/scanning_module = 3,
		/obj/item/weapon/stock_parts/capacitor = 2,
		/obj/item/weapon/stock_parts/console_screen = 4,
		)
	contraband = list(
		/obj/item/device/flashlight = 5,
		/obj/item/device/assembly/timer = 2,
		)
	premium = list(
		/obj/item/device/assembly_frame = 1
		)
	vouched = list(
		/obj/item/weapon/glowstick = 2,
		/obj/item/weapon/glowstick/red = 2,
		/obj/item/weapon/glowstick/blue = 2,
		/obj/item/weapon/glowstick/yellow = 2,
		/obj/item/weapon/glowstick/magenta = 2
		)
	product_ads = list(
		"Only the finest!",
		"Have some tools.",
		"The most robust equipment.",
		"The finest gear in space!"
	)
	pack = /obj/structure/vendomatpack/assist

/obj/machinery/vending/coffee
	name = "\improper Hot Drinks machine"
	desc = "A vending machine that dispenses hot drinks."
	product_ads = list(
		"Have a drink!",
		"Drink up!",
		"It's good for you!",
		"Would you like a hot joe?",
		"I'd kill for some coffee!",
		"The best beans in the galaxy.",
		"Only the finest brew for you.",
		"Mmmm. Nothing like a coffee.",
		"I like coffee, don't you?",
		"Coffee helps you work!",
		"Try some tea.",
		"We hope you like the best!",
		"Try our new chocolate!"
	)
	icon_state = COFFEE
	icon_vend = "coffee-vend"
	vend_delay = 34
	products = list(
		/obj/item/weapon/reagent_containers/food/drinks/coffee = 25,
		/obj/item/weapon/reagent_containers/food/drinks/tea = 25,
		/obj/item/weapon/reagent_containers/food/drinks/h_chocolate = 25,
		/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/irishcoffee/ = 25,
		)
	premium = list(
		/obj/item/weapon/reagent_containers/food/drinks/tomatosoup = 3,
		)
	contraband = list(
		/obj/item/weapon/reagent_containers/food/drinks/ice = 10,
		)
	prices = list(
		/obj/item/weapon/reagent_containers/food/drinks/coffee = 25,
		/obj/item/weapon/reagent_containers/food/drinks/tea = 25,
		/obj/item/weapon/reagent_containers/food/drinks/h_chocolate = 25,
		/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/irishcoffee/ = 40,
		)
	specials = list(
		/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/irishcoffee/ = ST_PATRICKS_DAY,
	)

	pack = /obj/structure/vendomatpack/coffee



/obj/machinery/vending/snack
	name = "\improper Getmore Chocolate Corp"
	desc = "A vending machine containing snacks."
	product_slogans = list(
		"Try our new nougat bar!",
		"Half the calories for double the price!",
		"It's better than Dan's!"
	)
	product_ads = list(
		"The healthiest!",
		"Award-winning chocolate bars!",
		"Mmm! So good!",
		"Oh my god it's so juicy!",
		"Have a snack.",
		"Snacks are good for you!",
		"Have some more Getmore!",
		"Best quality snacks straight from Mars.",
		"We love chocolate!",
		"Try our new jerky!"
	)
	icon_state = "snack"
	icon_vend = "snack-vend"
	vend_delay = 25
	products = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy = 6,
		/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/heating = 6,
		/obj/item/weapon/reagent_containers/food/snacks/chips =6,
		/obj/item/weapon/reagent_containers/food/snacks/sosjerky = 6,
		/obj/item/weapon/reagent_containers/food/snacks/no_raisin = 6,
		/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie = 6,
		/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers = 6,
		/obj/item/weapon/reagent_containers/food/snacks/chococoin/wrapped = 2,
		/obj/item/weapon/storage/fancy/cigarettes/gum = 10,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = 100,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/valentine = 2,
		)
	contraband = list(
		/obj/item/weapon/reagent_containers/food/snacks/syndicake = 4,
		/obj/item/weapon/reagent_containers/food/snacks/bustanuts = 4,
		/obj/item/weapon/reagent_containers/food/snacks/oldempirebar = 4,
		/obj/item/weapon/reagent_containers/food/snacks/magbites = 6,
		)
	prices = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy = 13,
		/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/heating = 15,
		/obj/item/weapon/reagent_containers/food/snacks/chips = 30,
		/obj/item/weapon/reagent_containers/food/snacks/sosjerky = 40,
		/obj/item/weapon/reagent_containers/food/snacks/no_raisin = 60,
		/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie = 12,
		/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers = 40,
		/obj/item/weapon/reagent_containers/food/snacks/chococoin/wrapped = 75,
		/obj/item/weapon/reagent_containers/food/snacks/magbites = 110,
		/obj/item/weapon/storage/fancy/cigarettes/gum = 10,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = 1,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/valentine = 100,
		)
	vouched = list(
		/obj/item/weapon/reagent_containers/food/snacks/donkpocket/self_heating = 2
		)
	specials = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = ST_PATRICKS_DAY,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/valentine = VALENTINES_DAY,
		)

	pack = /obj/structure/vendomatpack/snack


/obj/machinery/vending/cola
	name = "\improper Robust Softdrinks"
	desc = "A softdrink vendor provided by Robust Industries, LLC."
	icon_state = "Cola_Machine"
	icon_vend = "Cola_Machine-vend"
	vend_delay = 11
	product_slogans = list(
		"Robust Softdrinks: More robust than a toolbox to the head!",
		"At least we aren't Dan!"
	)
	product_ads = list(
		"Refreshing!",
		"Hope you're thirsty!",
		"Over 1 million drinks sold!",
		"Thirsty? Why not cola?",
		"Please, have a drink!",
		"Drink up!",
		"The best drinks in space."
	)
	products = list(
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/dr_gibb = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_up = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/gunka_cola = 2,
		/obj/item/weapon/storage/box/diy_soda = 2,
		)
	contraband = list(
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/thirteenloko = 5,
		)
	premium = list(
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cannedcoffee = 3,
		)
	prices = list(
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/dr_gibb = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_up = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/gunka_cola = 50,
		/obj/item/weapon/storage/box/diy_soda = 95,
		)

	pack = /obj/structure/vendomatpack/cola

/obj/machinery/vending/offlicence
	name = "\improper Offworld Off-Licence"
	desc = "A vendor containing all you need to drown your sorrows and your finances."
	icon_state = "offlicence"
	product_slogans = list(
		"Offworld Off-Licence: Think outcider the box!",
		"People may abandon you, but alcohol will always be there for you.",
		"Recommended by 8 out of 10 chavs!"
	)
	product_ads = list(
		"The best mistake you've ever made.",
		"Made with real imitation Karmotrine!",
		"Dan-free since 2561!"
	)
	vend_reply = "Drink irresponsibly."
	products = list(
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/blebweiser = 6,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/bluespaceribbon = 6,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/codeone = 6,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/gibness = 6,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/orchardtides = 6,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sleimiken = 6,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/strongebow = 6,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/bear = 6,
		)
	contraband = list(
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/greyshitvodka = 2,
		)
	prices = list(
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/blebweiser = 15,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/bluespaceribbon = 15,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/codeone = 15,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/gibness = 15,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/orchardtides = 15,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sleimiken = 15,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/strongebow = 15,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/bear = 20,
		)

	pack = /obj/structure/vendomatpack/offlicence

//This one's from bay12
/obj/machinery/vending/cart
	name = "\improper PTech"
	desc = "A vending machine containing Personal Data Assistant cartridges."
	req_access = list(access_change_ids)
	product_slogans = list("Carts to go!")
	icon_state = "cart"
	icon_deny = "cart-deny"
	icon_vend = "cart-vend"
	products = list(
		/obj/item/weapon/cartridge/captain = 3,
		/obj/item/weapon/cartridge/hop = 3,
		/obj/item/weapon/cartridge/cmo = 3,
		/obj/item/weapon/cartridge/medical = 5,
		/obj/item/weapon/cartridge/chemistry = 5,
		/obj/item/weapon/cartridge/ce = 3,
		/obj/item/weapon/cartridge/engineering = 5,
		/obj/item/weapon/cartridge/atmos = 5,
		/obj/item/weapon/cartridge/mechanic = 5,
		/obj/item/weapon/cartridge/rd = 3,
		/obj/item/weapon/cartridge/signal/toxins = 5,
		/obj/item/weapon/cartridge/robotics = 5,
		/obj/item/weapon/cartridge/hos = 3,
		/obj/item/weapon/cartridge/security = 5,
		/obj/item/weapon/cartridge/detective = 5,
		/obj/item/weapon/cartridge/lawyer = 5,
		/obj/item/weapon/cartridge/clown = 3,
		/obj/item/weapon/cartridge/mime = 3,
		/obj/item/weapon/cartridge/quartermaster = 5,
		/obj/item/weapon/cartridge/chef = 5,
		/obj/item/weapon/cartridge/janitor = 5,
		)

	pack = /obj/structure/vendomatpack/undefined

/obj/machinery/vending/cigarette
	name = "\improper Cigarette machine" //OCD had to be uppercase to look nice with the new formating
	desc = "A vending machine containing smoking supplies."
	product_slogans = list(
		"Space cigs taste good like a cigarette should.",
		"I'd rather toolbox than switch.",
		"Smoke!",
		"Don't believe the reports - smoke today!"
	)
	product_ads = list(
		"Probably not bad for you!",
		"Don't believe the scientists!",
		"It's good for you!",
		"Don't quit, buy more!",
		"Smoke!",
		"Nicotine heaven.",
		"Best cigarettes since 2150.",
		"Award-winning cigs."
	)
	icon_state = "cigs"
	icon_vend = "cigs-vend"
	vend_delay = 21
	products = list(
		/obj/item/weapon/storage/fancy/cigarettes = 10,
		/obj/item/weapon/storage/fancy/matchbox = 10,
		/obj/item/weapon/lighter/random = 4,
		)
	contraband = list(
		/obj/item/weapon/lighter/zippo = 4,
		)
	premium = list(
		/obj/item/weapon/storage/fancy/matchbox/strike_anywhere = 10,
		/obj/item/clothing/mask/cigarette/cigar/havana = 2,
		/obj/item/clothing/mask/holopipe = 1,
		)
	prices = list(
		/obj/item/weapon/storage/fancy/cigarettes = 20,
		/obj/item/weapon/storage/fancy/matchbox = 25,
		/obj/item/weapon/lighter/random = 25,
		)

	pack = /obj/structure/vendomatpack/cigarette

/obj/machinery/vending/medical
	name = "\improper NanoMed Plus"
	desc = "A vending machine containing medical supplies."
	req_access = list(access_medical)
	icon_state = "med"
	icon_deny = "med-deny"
	icon_vend = "med-vend"
	vend_delay = 18
	product_ads = list(
		"Go save some lives!",
		"The best stuff for your medbay.",
		"Only the finest tools.",
		"Natural chemicals!",
		"This stuff saves lives.",
		"Don't you want some?",
		"Ping!"
	)
	products = list(
		/obj/item/weapon/reagent_containers/glass/bottle/antitoxin = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/stoxin = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/toxin = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/charcoal = 4,
		/obj/item/weapon/reagent_containers/syringe/antiviral = 4,
		/obj/item/weapon/reagent_containers/syringe = 12,
		/obj/item/weapon/reagent_containers/glass/beaker/vial = 8,
		/obj/item/device/healthanalyzer = 5,
		/obj/item/device/antibody_scanner = 5,
		/obj/item/weapon/reagent_containers/glass/beaker = 4,
		/obj/item/weapon/reagent_containers/dropper = 2,
		/obj/item/stack/medical/splint = 4,
		/obj/item/weapon/thermometer = 3,
		)
	contraband = list(
		/obj/item/weapon/reagent_containers/pill/tox = 3,
		/obj/item/weapon/reagent_containers/pill/stox = 4,
		/obj/item/weapon/reagent_containers/pill/antitox = 6,
		/obj/item/weapon/reagent_containers/blood/OMinus = 1,
		/obj/item/weapon/storage/pill_bottle/random = 2,
		)
	premium = list(
		/obj/item/weapon/storage/pill_bottle/time_release = 2,
		)
	vouched = list(
		/obj/item/weapon/medbot_cube = 2
		)

	pack = /obj/structure/vendomatpack/medical

/obj/machinery/vending/medical/New()
	..()
	if(map.nameShort == "deff")
		icon = 'maps/defficiency/medbay.dmi'

//This one's from bay12
/obj/machinery/vending/plasmaresearch
	name = "\improper Toximate 3000"
	desc = "All the fine parts you need in one vending machine!"
	products = list(
		/obj/item/clothing/under/rank/scientist = 6,
		/obj/item/clothing/suit/bio_suit = 6,
		/obj/item/clothing/head/bio_hood = 6,
		/obj/item/device/transfer_valve = 6,
		/obj/item/device/assembly/timer = 6,
		/obj/item/device/assembly/signaler = 6,
		/obj/item/device/assembly/prox_sensor = 6,
		/obj/item/device/assembly/igniter = 6,
		)

	pack = /obj/structure/vendomatpack/undefined

/obj/machinery/vending/wallmed1
	name = "\improper NanoMed"
	desc = "Wall-mounted medical equipment dispenser."
	//req_access = list(access_medical)
	product_ads = list(
		"Go save some lives!",
		"The best stuff for your medbay.",
		"Only the finest tools.",
		"Natural chemicals!",
		"This stuff saves lives.",
		"Don't you want some?"
	)
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	density = 0 //It is wall-mounted, and thus, not dense. --Superxpdude
	products = list(
		/obj/item/stack/medical/bruise_pack = 2,
		/obj/item/stack/medical/ointment = 2,
		/obj/item/weapon/reagent_containers/syringe/inaprovaline = 4,
		/obj/item/device/healthanalyzer = 1,
		/obj/item/device/antibody_scanner = 1,
		/obj/item/stack/medical/splint = 1,
		)
	contraband = list(
		/obj/item/weapon/reagent_containers/syringe/antitoxin = 4,
		/obj/item/weapon/reagent_containers/syringe/antiviral = 4,
		/obj/item/weapon/reagent_containers/pill/tox = 1,
		)

	pack = /obj/structure/vendomatpack/medical//can be reloaded with NanoMed Plus packs
	component_parts = 0

/obj/machinery/vending/wallmed2
	name = "\improper NanoMed"
	desc = "Wall-mounted medical equipment dispenser."
	//req_access = list(access_medical)
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	density = 0 //It is wall-mounted, and thus, not dense. --Superxpdude
	products = list(
		/obj/item/weapon/reagent_containers/syringe/inaprovaline = 5,
		/obj/item/weapon/reagent_containers/syringe/antitoxin = 3,
		/obj/item/stack/medical/bruise_pack = 3,
		/obj/item/stack/medical/ointment =3,
		/obj/item/device/healthanalyzer = 3,
		/obj/item/device/antibody_scanner = 3,
		)
	contraband = list(
		/obj/item/weapon/reagent_containers/pill/tox = 3,
		)
	component_parts = 0

	pack = /obj/structure/vendomatpack/medical//can be reloaded with NanoMed Plus packs

////////WALL-MOUNTED NANOMED FRAME//////
/obj/machinery/vending/wallmed1/New(turf/loc)
	..()
	component_parts = 0

/obj/machinery/vending/wallmed2/New(turf/loc)
	..()
	component_parts = 0

/obj/machinery/vending/wallmed1/crowbarDestroy(mob/user)
	user.visible_message(	"[user] begins to pry out the NanoMed from the wall.",
							"You begin to pry out the NanoMed from the wall...")
	if(do_after(user, src, 40))
		user.visible_message(	"[user] detaches the NanoMed from the wall.",
								"You detach the NanoMed from the wall.")
		playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
		new /obj/item/mounted/frame/wallmed(src.loc)

		for(var/obj/I in src)
			qdel(I)

		new /obj/item/weapon/circuitboard/vendomat(src.loc)
		new /obj/item/stack/cable_coil(loc,5)

		return 1
	return -1

/obj/machinery/vending/wallmed2/crowbarDestroy(mob/user)
	user.visible_message(	"[user] begins to pry out the NanoMed from the wall.",
							"You begin to pry out the NanoMed from the wall...")
	if(do_after(user, src, 40))
		user.visible_message(	"[user] detaches the NanoMed from the wall.",
								"You detach the NanoMed from the wall.")
		playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
		new /obj/item/mounted/frame/wallmed(src.loc)

		for(var/obj/I in src)
			qdel(I)

		new /obj/item/weapon/circuitboard/vendomat(src.loc)
		new /obj/item/stack/cable_coil(loc,5)

		return 1
	return -1

/obj/machinery/wallmed_frame
	name = "\improper NanoMed frame"
	desc = "Wall-mounted Medical Equipment dispenser."
	icon = 'icons/obj/vending.dmi'
	icon_state = "wallmed_frame0"
	anchored = 1

	var/on = 1

	var/build = 0        // Build state
	var/boardtype=/obj/item/weapon/circuitboard/vendomat
	var/obj/item/weapon/circuitboard/_circuitboard

/obj/machinery/wallmed_frame/New(turf/loc, var/ndir)
	..()
	// offset 32 pixels in direction of dir
	// this allows the NanoMed to be embedded in a wall, yet still inside an area
	dir = ndir
	pixel_x = (dir & 3)? 0 : (dir == 4 ? 30 * PIXEL_MULTIPLIER: -30 * PIXEL_MULTIPLIER)
	pixel_y = (dir & 3)? (dir ==1 ? 30 * PIXEL_MULTIPLIER: -30 * PIXEL_MULTIPLIER) : 0

/obj/machinery/wallmed_frame/update_icon()
	icon_state = "wallmed_frame[build]"

/obj/machinery/wallmed_frame/attackby(var/obj/item/W as obj, var/mob/user as mob)
	switch(build)
		if(0) // Empty hull
			if(W.is_screwdriver(user))
				to_chat(usr, "You begin removing screws from \the [src] backplate...")
				if(do_after(user, src, 50))
					to_chat(usr, "<span class='notice'>You unscrew \the [src] from the wall.</span>")
					playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
					new /obj/item/mounted/frame/wallmed(get_turf(src))
					qdel(src)
				return 1
			if(istype(W, /obj/item/weapon/circuitboard))
				var/obj/item/weapon/circuitboard/C=W
				if(!(istype(C,/obj/item/weapon/circuitboard/vendomat)))
					to_chat(user, "<span class='warning'>You cannot install this type of board into a NanoMed frame.</span>")
					return
				to_chat(usr, "You begin to insert \the [C] into \the [src].")
				if(do_after(user, src, 10))
					if(user.drop_item(C, src))
						to_chat(usr, "<span class='notice'>You secure \the [C]!</span>")
						_circuitboard=C
						playsound(src, 'sound/effects/pop.ogg', 50, 0)
						build++
						update_icon()
				return 1
		if(1) // Circuitboard installed
			if(iscrowbar(W))
				to_chat(usr, "You begin to pry out \the [W] into \the [src].")
				if(do_after(user, src, 10))
					playsound(src, 'sound/effects/pop.ogg', 50, 0)
					build--
					update_icon()
					var/obj/item/weapon/circuitboard/C
					if(_circuitboard)
						_circuitboard.forceMove(get_turf(src))
						C=_circuitboard
						_circuitboard=null
					else
						C=new boardtype(get_turf(src))
					user.visible_message(\
						"<span class='warning'>[user.name] has removed \the [C]!</span>",\
						"You remove \the [C].")
				return 1
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C=W
				to_chat(user, "You start adding cables to \the [src]...")
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				if(do_after(user, src, 20) && C.amount >= 5)
					C.use(5)
					build++
					update_icon()
					user.visible_message(\
						"<span class='warning'>[user.name] has added cables to \the [src]!</span>",\
						"You add cables to \the [src].")
		if(2) // Circuitboard installed, wired.
			if(iswirecutter(W))
				to_chat(usr, "You begin to remove the wiring from \the [src].")
				if(do_after(user, src, 50))
					new /obj/item/stack/cable_coil(loc,5)
					user.visible_message(\
						"<span class='warning'>[user.name] cut the cables.</span>",\
						"You cut the cables.")
					build--
					update_icon()
				return 1
			if(W.is_screwdriver(user))
				to_chat(user, "You begin to complete \the [src]...")
				playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
				if(do_after(user, src, 20))
					if(!_circuitboard)
						_circuitboard=new boardtype(src)
					build++
					update_icon()
					user.visible_message(\
						"<span class='warning'>[user.name] has finished \the [src]!</span>",\
						"You finish \the [src].")
				return 1
		if(3) // Waiting for a recharge pack
			if(W.is_screwdriver(user))
				to_chat(user, "You begin to unscrew \the [src]...")
				playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
				if(do_after(user, src, 30))
					build--
					update_icon()
				return 1
	..()

/obj/machinery/wallmed_frame/MouseDropTo(atom/movable/O as mob|obj, mob/user as mob)
	if(user.incapacitated() || user.lying)
		return
	if(!Adjacent(user) || !user.Adjacent(O))
		return
	if(build==3)
		if(istype(O,/obj/structure/vendomatpack))
			if(istype(O,/obj/structure/vendomatpack/medical))
				to_chat(user, "<span class='notice'>You start refilling the vending machine with the recharge pack's materials.</span>")
				var/user_loc = user.loc
				var/pack_loc = O.loc
				var/self_loc = src.loc
				sleep(30)
				if(!user || !O || !src)
					return
				if (user.loc == user_loc && O.loc == pack_loc && anchored && self_loc == src.loc && !(user.incapacitated()))
					to_chat(user, "<span class='notice'>[bicon(src)] You finish refilling the vending machine.</span>")
					playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
					var/obj/machinery/vending/wallmed1/newnanomed = new /obj/machinery/vending/wallmed1(src.loc)
					newnanomed.name = "\improper Emergency NanoMed"
					newnanomed.pixel_x = pixel_x
					newnanomed.pixel_y = pixel_y
					var/obj/item/emptyvendomatpack/emptypack = new /obj/item/emptyvendomatpack(O.loc)
					emptypack.icon_state = O.icon_state
					emptypack.overlays += image('icons/obj/vending_pack.dmi',"emptypack")
					qdel(O)
					contents = 0
					qdel(src)
			else
				to_chat(user, "<span class='warning'>This recharge pack isn't meant for this kind of vending machines.</span>")

////////////////////////////////////////


/obj/machinery/vending/security
	name = "\improper SecTech"
	desc = "A vending machine containing Security equipment. A label reads \"SECURITY PERSONNEL ONLY\"."
	req_access = list(access_security)
	product_ads = list(
		"Crack capitalist skulls!",
		"Beat some heads in!",
		"Don't forget - harm is good!",
		"Your weapons are right here.",
		"Handcuffs!",
		"Freeze, scumbag!",
		"Tase them, bro.",
		"Why not have a donut?"
	)
	icon_state = "sec"
	icon_deny = "sec-deny"
	icon_vend = "sec-vend"
	vend_delay = 14
	products = list(
		/obj/item/weapon/handcuffs = 8,
		/obj/item/weapon/grenade/flashbang = 4,
		/obj/item/device/flash = 5,
		/obj/item/weapon/reagent_containers/food/snacks/donut/normal = 12,
		/obj/item/weapon/storage/box/evidence = 6,
		/obj/item/weapon/legcuffs/bolas = 8,
		/obj/item/taperoll/police = 5,
		)
	contraband = list(
		/obj/item/clothing/glasses/sunglasses/security = 2,
		/obj/item/weapon/storage/fancy/donut_box = 2,
		)
	premium = list(
		/obj/item/clothing/head/helmet/siren = 2,
		/obj/item/clothing/head/helmet/police = 2,
		/obj/item/clothing/under/police = 2,
		)
	vouched = list(
		/obj/item/ammo_storage/magazine/m380auto = 10,
		/obj/item/ammo_storage/magazine/m380auto/rubber = 10
		)

	pack = /obj/structure/vendomatpack/security

/obj/machinery/vending/security/used
	req_access = "0"
	extended_inventory = 1
	products = list(
		/obj/item/weapon/handcuffs = 1,
		/obj/item/weapon/grenade/flashbang = 1,
		/obj/item/device/flash = 2,
		/obj/item/weapon/reagent_containers/food/snacks/donut/normal = 24,
		/obj/item/weapon/storage/box/evidence = 1,
		/obj/item/weapon/legcuffs/bolas = 2,
		)
	contraband = list(
		/obj/item/clothing/glasses/sunglasses = 2,
		/obj/item/weapon/storage/fancy/donut_box = 2,
		)

/obj/machinery/vending/hydronutrients
	name = "\improper NutriMax"
	desc = "A vending machine containing nutritional substances for plants and botanical tools."
	product_slogans = list(
		"Aren't you glad you don't have to fertilize the natural way?",
		"Now with 50% less stink!",
		"Plants are people too!"
	)
	product_ads = list(
		"We like plants!",
		"Don't you want some?",
		"The greenest thumbs ever.",
		"We like big plants.",
		"Soft soil..."
	)
	icon_state = "nutri"
	icon_deny = "nutri-deny"
	icon_vend = "nutri-vend"
	vend_delay = 26
	products = list(
		/obj/item/weapon/reagent_containers/food/snacks/beezeez = 20,
		/obj/item/weapon/reagent_containers/glass/bottle/eznutrient = 30,
		/obj/item/weapon/reagent_containers/glass/bottle/left4zed = 20,
		/obj/item/weapon/reagent_containers/glass/bottle/robustharvest = 10,
		/obj/item/weapon/plantspray/pests = 20,
		/obj/item/weapon/reagent_containers/syringe = 5,
		/obj/item/weapon/reagent_containers/dropper = 2,
		/obj/item/weapon/storage/bag/plants = 5,
		)
	contraband = list(
		/obj/item/weapon/reagent_containers/glass/bottle/ammonia = 10,
		/obj/item/weapon/reagent_containers/glass/bottle/diethylamine = 5,
		)

	pack = /obj/structure/vendomatpack/hydronutrients

/obj/machinery/vending/hydroseeds
	name = "\improper MegaSeed Servitor"
	desc = "A vending machine containing plant seeds."
	product_slogans = list(
		"THIS'S WHERE TH' SEEDS LIVE! GIT YOU SOME!",
		"Hands down the best seed selection on the station!",
		"Also certain mushroom varieties available, more for experts! Get certified today!"
	)
	product_ads = list(
		"We like plants!",
		"Grow some crops!",
		"Grow, baby, growww!",
		"Aw h'yeah son!"
	)
	icon_state = "seeds"
	icon_vend = "seeds-vend"
	vend_delay = 13
	products = list(
		/obj/item/seeds/bananaseed = 3,
		/obj/item/seeds/berryseed = 3,
		/obj/item/seeds/carrotseed = 3,
		/obj/item/seeds/chantermycelium = 3,
		/obj/item/seeds/chiliseed = 3,
		/obj/item/seeds/cornseed = 3,
		/obj/item/seeds/eggplantseed = 3,
		/obj/item/seeds/potatoseed = 3,
		/obj/item/seeds/dionanode = 3,
		/obj/item/seeds/soyaseed = 3,
		/obj/item/seeds/sunflowerseed = 3,
		/obj/item/seeds/tomatoseed = 3,
		/obj/item/seeds/towermycelium = 3,
		/obj/item/seeds/wheatseed = 3,
		/obj/item/seeds/appleseed = 3,
		/obj/item/seeds/poppyseed = 3,
		/obj/item/seeds/ambrosiavulgarisseed = 3,
		/obj/item/seeds/whitebeetseed = 3,
		/obj/item/seeds/sugarcaneseed = 3,
		/obj/item/seeds/watermelonseed = 3,
		/obj/item/seeds/limeseed = 3,
		/obj/item/seeds/lemonseed = 3,
		/obj/item/seeds/orangeseed = 3,
		/obj/item/seeds/grassseed = 3,
		/obj/item/seeds/cocoapodseed = 3,
		/obj/item/seeds/cabbageseed = 3,
		/obj/item/seeds/grapeseed = 3,
		/obj/item/seeds/pumpkinseed = 3,
		/obj/item/seeds/cherryseed = 3,
		/obj/item/seeds/plastiseed = 3,
		/obj/item/seeds/riceseed = 3,
		/obj/item/seeds/cinnamomum = 3,
		/obj/item/seeds/avocadoseed = 3,
		/obj/item/seeds/pearseed = 3,
		)//,/obj/item/seeds/synthmeatseed = 3)
	contraband = list(
		/obj/item/seeds/amanitamycelium = 2,
		/obj/item/seeds/glowshroom = 2,
		/obj/item/seeds/libertymycelium = 2,
		/obj/item/seeds/nettleseed = 2,
		/obj/item/seeds/plumpmycelium = 2,
		/obj/item/seeds/reishimycelium = 2,
		/obj/item/seeds/harebell = 3,
		)//,/obj/item/seeds/synthbuttseed = 3)
	premium = list(
		/obj/item/toy/waterflower = 1,
		)

	pack = /obj/structure/vendomatpack/hydroseeds

/obj/machinery/vending/voxseeds
	name = "\improper Vox Seed 'n' Feed"
	desc = "A vending machine containing exotic seeds. A label reads: \"When not having time to get human seeds!\""
	product_slogans = list(
		"SEEDS LIVING HERE! GETTING SOME!",
		"Claws down, best seed selection on Vox Outpost.",
		"Sell, sell!"
	)
	product_ads = list(
		"Making more gravy soon?",
		"Growing profits!",
		"Is good!",
		"Vox food being best."
	)
	icon_state = "voxseed"
	products = list(
		/obj/item/seeds/breadfruit = 3,
		/obj/item/seeds/woodapple = 3,
		/obj/item/seeds/chickenshroom = 3,
		/obj/item/seeds/garlic = 3,
		/obj/item/seeds/aloe = 3,
		/obj/item/seeds/pitcher = 3,
		/obj/item/seeds/vaporsac = 3,
		/obj/item/seeds/mushroommanspore = 3
		)
	contraband = list(
		/obj/item/seeds/eggyseed = 2,
		/obj/item/seeds/nofruitseed = 2,
		/obj/item/seeds/glowshroom = 2
		)
	premium = list(
		/obj/item/weapon/storage/box/boxen = 1
		)

/obj/machinery/vending/magivend
	name = "\improper MagiVend"
	desc = "A mystical vending machine containing magical garments and magic supplies."
	icon_state = "MagiVend"
	product_slogans = list(
		"Sling spells the proper way with MagiVend!",
		"Be your own Houdini! Use MagiVend!"
	)
	vend_delay = 15
	vend_reply = "Have an enchanted evening!"
	product_ads = list(
		"FJKLFJSD",
		"AJKFLBJAKL",
		"1234 LOONIES LOL!",
		">MFW",
		"Kill them fuckers!",
		"GET DAT FUKKEN DISK",
		"HONK!",
		"EI NATH!",
		"Destroy the station!",
		"Admin conspiracies since forever!",
		"Space-time bending hardware!"
	)
	products = list(
		/obj/item/clothing/head/wizard = 5,
		/obj/item/clothing/suit/wizrobe = 5,
		/obj/item/clothing/head/wizard/red = 5,
		/obj/item/clothing/suit/wizrobe/red = 5,
		/obj/item/clothing/head/wizard/clown = 5,
		/obj/item/clothing/suit/wizrobe/clown = 5,
		/obj/item/clothing/mask/gas/clown_hat/wiz = 5,
		/obj/item/clothing/head/wizard/marisa = 5,
		/obj/item/clothing/suit/wizrobe/marisa = 5,
		/obj/item/clothing/suit/wizrobe/magician = 5,
		/obj/item/clothing/head/that/magic = 5,
		/obj/item/clothing/head/wizard/necro = 5,
		/obj/item/clothing/suit/wizrobe/necro = 5,
		/obj/item/clothing/head/wizard/magus = 5,
		/obj/item/clothing/suit/wizrobe/magusred = 5,
		/obj/item/clothing/suit/wizrobe/magusblue = 5,
		/obj/item/clothing/head/wizard/amp = 5,
		/obj/item/clothing/suit/wizrobe/psypurple = 5,
		/obj/item/clothing/head/pharaoh = 5,
		/obj/item/clothing/suit/wizrobe/pharaoh = 5,
		/obj/item/clothing/shoes/sandal/marisa/leather = 5,
		/obj/item/clothing/shoes/sandal = 10,
		/obj/item/clothing/shoes/sandal/marisa = 5,
		/obj/item/weapon/staff = 5,
		/obj/item/weapon/staff/broom = 5,
		/obj/item/clothing/glasses/monocle = 5,
		/obj/item/weapon/storage/bag/wiz_cards/full = 1,
		/obj/item/weapon/storage/bag/potion = 5,
		/obj/item/clothing/suit/wizrobe/hallowiz = 5,
		/obj/item/clothing/head/wizard/hallowiz = 5,
		)
	contraband = list(
		/obj/item/weapon/reagent_containers/glass/bottle/wizarditis = 1,
		)	//No one can get to the machine to hack it anyways; for the lulz - Microwave
	premium = list(
		/obj/item/clothing/back/magiccape = 1,
		)
	specials = list(
		/obj/item/clothing/suit/wizrobe/hallowiz = HALLOWEEN,
		/obj/item/clothing/head/wizard/hallowiz = HALLOWEEN,
		)

	pack = /obj/structure/vendomatpack/magivend	//Who's laughing now? wizarditis doesn't do shit anyway. - Deity Link of 2014
												//How about I make a foul of myself 5 years later? Wizarditis is now a proper symptom. - Deity Link of 2019

/obj/machinery/vending/dinnerware
	name = "\improper Dinnerware"
	desc = "A vending machine containing kitchen and restaurant equipment."
	product_ads = list(
		"Mm, food stuffs!",
		"Food and food accessories.",
		"Get your plates!",
		"You like forks?",
		"I like forks.",
		"Woo, utensils.",
		"You don't really need these..."
	)
	icon_state = "dinnerware"
	icon_vend = "dinnerware-vend"
	products = list(
		/obj/item/weapon/tray = 8,
		/obj/item/weapon/kitchen/utensil/fork = 6,
		/obj/item/weapon/kitchen/utensil/knife/large = 3,
		/obj/item/weapon/reagent_containers/food/drinks/drinkingglass = 8,
		/obj/item/clothing/suit/chef/classic = 2,
		/obj/item/trash/bowl = 20,
		/obj/item/trash/plate = 20,
		/obj/item/weapon/reagent_containers/food/condiment/peppermill = 5,
		/obj/item/weapon/reagent_containers/food/condiment/saltshaker	= 5,
		/obj/item/weapon/reagent_containers/food/condiment/vinegar = 5,
		/obj/item/weapon/storage/bag/food = 5
		)
	contraband = list(
		/obj/item/weapon/kitchen/utensil/spoon = 2,
		/obj/item/weapon/kitchen/utensil/knife = 2,
		/obj/item/weapon/kitchen/rollingpin = 2,
		/obj/item/weapon/kitchen/utensil/knife/large/butch = 2,
		)
	premium = list(
		/obj/item/weapon/reagent_containers/dropper/baster = 1)

	pack = /obj/structure/vendomatpack/dinnerware

/obj/machinery/vending/sovietsoda
	name = "\improper BODA"
	desc = "An old vending machine containing sweet water."
	icon_state = "sovietsoda"
	icon_vend = "sovietsoda-vend"
	product_slogans = list(
		"BODA: We sell drink.",
		"BODA: Drink today.",
		"BODA: We're better then Comrade Dan."
	)
	product_ads = list(
		"For Tsar and Country.",
		"Have you fulfilled your nutrition quota today?",
		"Very nice!",
		"We are simple people, for this is all we eat.",
		"If there is a person, there is a problem. If there is no person, then there is no problem."
	)
	products = list(
		/obj/item/weapon/reagent_containers/food/drinks/plastic/water = 10,
		/obj/item/weapon/reagent_containers/food/drinks/plastic/water/small = 20,
		/obj/item/weapon/reagent_containers/food/drinks/plastic/sodawater = 8,
		)
	contraband = list(
		/obj/item/weapon/reagent_containers/food/drinks/plastic/cola = 20,
		)
	prices = list(
		/obj/item/weapon/reagent_containers/food/drinks/plastic/water = 10,
		/obj/item/weapon/reagent_containers/food/drinks/plastic/water/small = 5,
		/obj/item/weapon/reagent_containers/food/drinks/plastic/sodawater = 15,
		)

	pack = /obj/structure/vendomatpack/sovietsoda

/obj/machinery/vending/tool
	name = "\improper YouTool"
	desc = "A vending machine containing standard tools. A label reads: \"Tools for tools.\""
	//req_access = list(access_maint_tunnels)
	icon_state = "tool"
	icon_deny = "tool-deny"
	icon_vend = "tool-vend"
	vend_delay = 11
	products = list(
		/obj/item/stack/cable_coil/random = 10,
		/obj/item/weapon/crowbar = 5,
		/obj/item/weapon/weldingtool = 3,
		/obj/item/weapon/wirecutters = 5,
		/obj/item/weapon/wrench = 5,
		/obj/item/device/analyzer = 5,
		/obj/item/device/t_scanner = 5,
		/obj/item/weapon/screwdriver = 5,
		/obj/item/weapon/solder = 3,
		/obj/item/device/silicate_sprayer = 2
		)
	contraband = list(
		/obj/item/weapon/weldingtool/hugetank = 2,
		/obj/item/clothing/gloves/fyellow = 2,
		)
	premium = list(
		/obj/item/clothing/gloves/yellow = 1,
		)

	pack = /obj/structure/vendomatpack/tool

/obj/machinery/vending/engivend
	name = "\improper Engi-Vend"
	desc = "Spare tool vending. What? Did you expect some witty description?"
	req_access = list(access_engine_equip)//Engineering Equipment access
	icon_state = "engivend"
	icon_deny = "engivend-deny"
	icon_vend = "engivend-vend"
	vend_delay = 21
	products = list(
		/obj/item/clothing/glasses/scanner/meson = 2,
		/obj/item/clothing/glasses/scanner/material = 2,
		/obj/item/device/multitool = 4,
		/obj/item/weapon/circuitboard/airlock = 10,
		/obj/item/weapon/circuitboard/power_control = 10,
		/obj/item/weapon/circuitboard/air_alarm = 10,
		/obj/item/weapon/circuitboard/fire_alarm = 10,
		/obj/item/weapon/intercom_electronics = 10,
		/obj/item/weapon/cell/high = 10,
		/obj/item/weapon/reagent_containers/glass/fuelcan = 5,
		/obj/item/weapon/stock_parts/capacitor = 10,
		/obj/item/device/holomap = 2,
		/obj/item/weapon/reagent_containers/glass/bottle/sacid = 3,
		/obj/item/blueprints/construction_permit = 4, // permits
		/obj/item/taperoll/engineering = 5,
		/obj/item/taperoll/atmos = 5,
		)
	contraband = list(
		/obj/item/weapon/cell/potato = 3,
		/obj/item/weapon/grenade/chem_grenade/metalfoam = 1,
		)
	premium = list(
		/obj/item/weapon/storage/belt/utility = 3,
		/obj/item/weapon/grenade/chem_grenade/metalfoam = 3,
		)

	pack = /obj/structure/vendomatpack/engivend

/obj/machinery/vending/building
	name = "\improper Habitat Depot"
	desc = "Habitat, sweet habitat. All you need for remodeling."
	icon_state = "building"
	products = list(
		/obj/item/stack/sheet/metal/bigstack = 10,
		/obj/item/stack/sheet/glass/glass/bigstack = 10,
		/obj/item/stack/sheet/wood/bigstack = 10,
		/obj/item/stack/tile/carpet/bigstack = 10,
		/obj/item/stack/tile/arcade/bigstack = 10,
		/obj/item/mounted/poster = 6,
		/obj/item/weapon/storage/box/lights/mixed = 4
	)
	contraband = list(
		/obj/item/stack/sheet/glass/plasmaglass/bigstack = 1,
		/obj/item/stack/sheet/mineral/plastic/bigstack = 1,
		/obj/item/weapon/storage/box/lights/he = 2
	)
	premium = list(
		/obj/item/device/rcd/rpd = 1,
		/obj/item/device/rcd/matter/rsf = 1,
		/obj/item/device/rcd/tile_painter = 1,
	)
	prices = list(
		/obj/item/stack/sheet/metal/bigstack = 10,
		/obj/item/stack/sheet/glass/glass/bigstack = 10,
		/obj/item/stack/sheet/wood/bigstack = 20,
		/obj/item/stack/tile/carpet/bigstack = 20,
		/obj/item/stack/tile/arcade/bigstack = 20,
		/obj/item/mounted/poster = 5,
		/obj/item/weapon/storage/box/lights/mixed = 5,
		/obj/item/stack/sheet/glass/plasmaglass/bigstack = 40,
		/obj/item/stack/sheet/mineral/plastic/bigstack = 40,
		/obj/item/weapon/storage/box/lights/he = 20
	)

	pack = /obj/structure/vendomatpack/building

//This one's from bay12
/obj/machinery/vending/engineering
	name = "\improper Robco Tool Maker"
	desc = "A vending machine containing many engineering supplies. A label reads: \"Everything you need for do-it-yourself station repair.\""
	req_access = list(access_engine_equip)
	icon_state = "engi"
	icon_deny = "engi-deny"
	products = list(
		/obj/item/clothing/under/rank/engineer = 4,
		/obj/item/clothing/under/rank/atmospheric_technician = 4,
		/obj/item/clothing/under/rank/maintenance_tech/ = 4,
		/obj/item/clothing/under/rank/engine_tech = 4,
		/obj/item/clothing/under/rank/electrician = 4,
		/obj/item/clothing/shoes/orange = 4,
		/obj/item/clothing/head/hardhat = 4,
		/obj/item/clothing/head/hardhat/orange = 4,
		/obj/item/clothing/head/hardhat/red = 4,
		/obj/item/clothing/head/hardhat/white = 4,
		/obj/item/clothing/head/hardhat/dblue = 4,
		/obj/item/weapon/storage/belt/utility = 4,
		/obj/item/clothing/glasses/scanner/meson = 4,
		/obj/item/clothing/gloves/yellow = 4,
		/obj/item/weapon/screwdriver = 12,
		/obj/item/weapon/crowbar = 12,
		/obj/item/weapon/wirecutters = 12,
		/obj/item/device/multitool = 12,
		/obj/item/weapon/wrench = 12,
		/obj/item/device/t_scanner = 12,
		/obj/item/device/analyzer = 12,
		/obj/item/stack/cable_coil = 8,
		/obj/item/weapon/cell = 8,
		/obj/item/weapon/weldingtool = 8,
		/obj/item/clothing/head/welding = 8,
		/obj/item/weapon/light/tube = 10,
		/obj/item/clothing/suit/fire = 4,
		/obj/item/weapon/stock_parts/scanning_module = 5,
		/obj/item/weapon/stock_parts/micro_laser = 5,
		/obj/item/weapon/stock_parts/matter_bin = 5,
		/obj/item/weapon/stock_parts/manipulator = 5,
		/obj/item/weapon/stock_parts/console_screen = 5,
		)
	contraband = list(
		/obj/item/weapon/wrench/socket = 1,
		/obj/item/weapon/extinguisher/foam = 1,
		/obj/item/device/device_analyser = 2,
		)
	premium = list(
		/obj/item/clothing/under/rank/chief_engineer = 2,
		/obj/item/weapon/storage/belt/utility = 2,
		) //belt is the best belt in the game. - update paths dickbags
	// There was an incorrect entry (cablecoil/power).  I improvised to cablecoil/heavyduty.
	// Another invalid entry, /obj/item/weapon/circuitry.  I don't even know what that would translate to, removed it.
	// The original products list wasn't finished.  The ones without given quantities became quantity 5.  -Sayu

	pack = /obj/structure/vendomatpack/undefined

//This one's from bay12
/obj/machinery/vending/robotics
	name = "\improper Robotech Deluxe"
	desc = "A vending machine containing roboticizing supplies. A label reads: \"All the tools you need to create your own robot army.\""
	req_access = list(access_robotics)
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	products = list(
		/obj/item/clothing/suit/storage/labcoat = 4,
		/obj/item/clothing/under/rank/roboticist = 4,
		/obj/item/stack/cable_coil = 4,
		/obj/item/device/flash = 4,
		/obj/item/weapon/cell/high = 12,
		/obj/item/device/assembly/prox_sensor = 3,
		/obj/item/device/assembly/signaler = 3,
		/obj/item/device/healthanalyzer = 3,
		/obj/item/weapon/scalpel = 2,
		/obj/item/weapon/circular_saw = 2,
		/obj/item/weapon/tank/anesthetic = 2,
		/obj/item/clothing/mask/breath/medical = 5,
		/obj/item/weapon/screwdriver = 5,
		/obj/item/weapon/crowbar = 5,
		)
	//everything after the power cell had no amounts, I improvised.  -Sayu

	pack = /obj/structure/vendomatpack/undefined

/obj/machinery/vending/autodrobe
	name = "\improper AutoDrobe"
	desc = "A vending machine containing costumes."
	icon_state = "theater"
	icon_deny = "theater-deny"
	req_access = list(access_theatre)
	product_slogans = list(
		"Dress for success!",
		"Suited and booted!",
		"It's show time!",
		"Why leave style up to fate? Use AutoDrobe!"
	)
	vend_delay = 15
	vend_reply = "Thank you for using AutoDrobe!"
	products = list(
		/obj/item/clothing/suit/chickensuit = 3,
		/obj/item/clothing/head/chicken = 3,
		/obj/item/clothing/suit/monkeysuit = 3,
		/obj/item/clothing/mask/gas/monkeymask = 3,
		/obj/item/clothing/suit/xenos = 3,
		/obj/item/clothing/head/xenos = 3,
		/obj/item/clothing/under/gladiator = 3,
		/obj/item/clothing/head/helmet/gladiator = 3,
		/obj/item/clothing/under/gimmick/rank/captain/suit = 3,
		/obj/item/clothing/head/flatcap = 3,
		/obj/item/clothing/glasses/gglasses = 3,
		/obj/item/clothing/shoes/jackboots = 3,
		/obj/item/clothing/under/schoolgirl = 3,
		/obj/item/clothing/shoes/kneesocks = 3,
		/obj/item/clothing/head/kitty = 3,
		/obj/item/clothing/under/blackskirt = 3,
		/obj/item/clothing/head/beret = 3,
		/obj/item/clothing/suit/hastur = 3,
		/obj/item/clothing/head/hasturhood = 3,
		/obj/item/clothing/suit/wcoat = 3,
		/obj/item/clothing/under/suit_jacket = 3,
		/obj/item/clothing/head/that = 3,
		/obj/item/clothing/head/cueball = 3,
		/obj/item/clothing/under/scratch = 3,
		/obj/item/clothing/under/kilt = 3,
		/obj/item/clothing/head/beret = 3,
		/obj/item/clothing/suit/wcoat = 3,
		/obj/item/clothing/glasses/monocle =3,
		/obj/item/clothing/head/bowlerhat = 3,
		/obj/item/weapon/cane = 3,
		/obj/item/clothing/under/sl_suit = 3,
		/obj/item/clothing/mask/fakemoustache = 3,
		/obj/item/clothing/suit/bio_suit/plaguedoctorsuit = 3,
		/obj/item/clothing/head/plaguedoctorhat = 3,
		/obj/item/clothing/mask/gas/plaguedoctor = 3,
		/obj/item/clothing/under/owl = 3,
		/obj/item/clothing/mask/gas/owl_mask = 3,
		/obj/item/clothing/suit/apron = 3,
		/obj/item/clothing/under/waiter = 3,
		/obj/item/clothing/under/pirate = 3,
		/obj/item/clothing/glasses/eyepatch = 3,
		/obj/item/clothing/suit/pirate = 3,
		/obj/item/clothing/head/pirate = 3,
		/obj/item/clothing/head/bandana = 3,
		/obj/item/clothing/head/bandana = 3,
		/obj/item/clothing/under/soviet = 3,
		/obj/item/clothing/head/ushanka = 3,
		/obj/item/clothing/suit/imperium_monk = 3,
		/obj/item/clothing/mask/gas/cyborg = 3,
		/obj/item/clothing/suit/holidaypriest = 3,
		/obj/item/clothing/head/wizard/marisa/fake = 3,
		/obj/item/clothing/suit/wizrobe/marisa/fake = 3,
		/obj/item/clothing/under/sundress = 3,
		/obj/item/clothing/head/witchwig = 3,
		/obj/item/weapon/staff/broom = 3,
		/obj/item/clothing/suit/wizrobe/fake = 3,
		/obj/item/clothing/head/wizard/fake = 3,
		/obj/item/weapon/staff = 3,
		/obj/item/clothing/mask/gas/sexyclown = 3,
		/obj/item/clothing/under/sexyclown = 3,
		/obj/item/clothing/mask/gas/sexymime = 3,
		/obj/item/clothing/under/sexymime = 3,
		/obj/item/clothing/suit/apron/overalls = 3,
		/obj/item/clothing/head/rabbitears = 3,
		/obj/item/clothing/head/lordadmiralhat = 3,
		/obj/item/clothing/suit/lordadmiral = 3,
		/obj/item/clothing/suit/doshjacket = 3,
		/obj/item/clothing/under/jester = 3,
		/obj/item/clothing/head/jesterhat = 3,
		/obj/item/clothing/shoes/jestershoes = 3,
		/obj/item/clothing/suit/kefkarobe = 3,
		/obj/item/clothing/head/helmet/aviatorhelmet = 3,
		/obj/item/clothing/shoes/aviatorboots = 3,
		/obj/item/clothing/under/aviatoruniform = 3,
		/obj/item/clothing/head/libertyhat = 3,
		/obj/item/clothing/suit/libertycoat = 3,
		/obj/item/clothing/under/libertyshirt = 3,
		/obj/item/clothing/shoes/libertyshoes = 3,
		/obj/item/clothing/head/helmet/megahelmet = 3,
		/obj/item/clothing/under/mega = 3,
		/obj/item/clothing/gloves/megagloves = 3,
		/obj/item/clothing/shoes/megaboots =3,
		/obj/item/clothing/head/helmet/protohelmet = 3,
		/obj/item/clothing/under/proto =3,
		/obj/item/clothing/gloves/protogloves =3,
		/obj/item/clothing/shoes/protoboots =3,
		/obj/item/clothing/under/roll = 3,
		/obj/item/clothing/head/maidhat =3,
		/obj/item/clothing/under/maid = 3,
		/obj/item/clothing/suit/maidapron = 3,
		/obj/item/clothing/head/mitre = 3,
		/obj/item/clothing/under/clownpiece = 3,
		/obj/item/clothing/suit/clownpiece = 3,
		/obj/item/clothing/head/clownpiece = 3,
		/obj/item/clothing/head/cowboy = 3,
		/obj/item/clothing/under/rottensuit = 5,
		/obj/item/clothing/shoes/rottenshoes = 5,
		/obj/item/clothing/under/franksuit = 3,
		/obj/item/clothing/gloves/frankgloves = 3,
		/obj/item/clothing/shoes/frankshoes =3,
		/obj/item/clothing/suit/kimono/sakura = 3,
		/obj/item/clothing/head/widehat_red = 3,
		/obj/item/clothing/suit/red_suit = 3,
		/obj/item/clothing/head/sombrero = 3,
		/obj/item/clothing/suit/poncho = 3
		) //Pretty much everything that had a chance to spawn.
	contraband = list(
		/obj/item/clothing/suit/cardborg = 3,
		/obj/item/clothing/head/cardborg = 3,
		/obj/item/clothing/suit/judgerobe = 3,
		/obj/item/clothing/head/powdered_wig = 3,
		/obj/item/toy/gun = 3
		)
	premium = list(
		/obj/item/clothing/suit/hgpirate = 3,
		/obj/item/clothing/head/hgpiratecap = 3,
		/obj/item/clothing/head/helmet/roman = 3,
		/obj/item/clothing/head/helmet/roman/legionaire = 3,
		/obj/item/clothing/under/roman = 3,
		/obj/item/clothing/shoes/roman = 3,
		/obj/item/weapon/shield/riot/roman = 3,
		/obj/item/clothing/under/stilsuit = 3,
		/obj/item/clothing/head/helmet/breakhelmet = 3,
		/obj/item/clothing/head/helmet/joehelmet = 3,
		/obj/item/clothing/under/joe = 3,
		/obj/item/clothing/gloves/joegloves = 3,
		/obj/item/clothing/shoes/joeboots =3,
		/obj/item/weapon/shield/riot/proto = 3,
		/obj/item/weapon/shield/riot/joe = 3,
		/obj/item/clothing/under/darkholme = 3,
		/obj/item/clothing/suit/wizrobe/magician/fake = 3,
		/obj/item/clothing/head/that/magic = 3,
		/obj/item/clothing/suit/kimono = 3,
		/obj/item/clothing/gloves/white = 3,
		/obj/item/clothing/mask/gas/lola = 3,
		/obj/item/clothing/under/lola = 3,
		/obj/item/clothing/shoes/clown_shoes/lola = 3,
		/obj/item/clothing/under/clownsuit = 3
		)

	pack = /obj/structure/vendomatpack/autodrobe

/obj/machinery/vending/hatdispenser
	name = "\improper Hatlord 9000"
	desc = "A vending machine containing hats."
	icon_state = "hats"
	vend_reply = "Take care now!"
	product_ads = list(
		"Buy some hats!",
		"A bare head is absolutely ASKING for a robusting!"
	)
	product_slogans = list(
		"Warning, not all hats are dog/monkey compatible. Apply forcefully with care.",
		"Apply directly to the forehead.",
		"Who doesn't love spending cash on hats?!",
		"From the people that brought you collectable hat crates, Hatlord!"
	)
	products = list(
		/obj/item/clothing/head/bowlerhat = 10,
		/obj/item/clothing/head/beaverhat = 10,
		/obj/item/clothing/head/boaterhat = 10,
		/obj/item/clothing/head/fedora = 10,
		/obj/item/clothing/head/fez = 10,
		/obj/item/clothing/head/soft/blue = 10,
		/obj/item/clothing/head/soft/green = 10,
		/obj/item/clothing/head/soft/grey = 10,
		/obj/item/clothing/head/soft/orange = 10,
		/obj/item/clothing/head/soft/purple = 10,
		/obj/item/clothing/head/soft/red = 10,
		/obj/item/clothing/head/soft/yellow = 10,
		/obj/item/clothing/head/soft/black = 10,
		)
	contraband = list(
		/obj/item/clothing/head/bearpelt = 5,
		/obj/item/clothing/head/energy_dome = 5
		)
	premium = list(
		/obj/item/clothing/head/soft/rainbow = 1,
		/obj/item/clothing/head/widehat_red =1,
		)

	pack = /obj/structure/vendomatpack/hatdispenser

/obj/machinery/vending/suitdispenser
	name = "\improper Suitlord 9000"
	desc = "A vending machine containing jumpsuits and dress garments."
	icon_state = "suits"
	vend_reply = "Come again!"
	product_ads = list(
		"Skinny? Looking for some clothes? Suitlord is the machine for you!",
		"BUY MY PRODUCT!"
	)
	product_slogans = list(
		"Pre-Ironed, Pre-Washed, Pre-Wor-*BZZT*",
		"Blood of your enemies washes right out!",
		"Who are YOU wearing?",
		"Look dapper! Look like an idiot!",
		"Don't carry your size? How about you shave off some pounds you fat lazy- *BZZT*"
	)
	products = list(
		/obj/item/clothing/under/color/black = 10,
		/obj/item/clothing/under/color/blue = 10,
		/obj/item/clothing/under/color/green = 10,
		/obj/item/clothing/under/color/grey = 10,
		/obj/item/clothing/under/color/pink = 10,
		/obj/item/clothing/under/color/red = 10,
		/obj/item/clothing/under/color/white = 10,
		/obj/item/clothing/under/color/yellow = 10,
		/obj/item/clothing/under/lightblue = 10,
		/obj/item/clothing/under/aqua = 10,
		/obj/item/clothing/under/purple = 10,
		/obj/item/clothing/under/lightgreen = 10,
		/obj/item/clothing/under/lightblue = 10,
		/obj/item/clothing/under/lightbrown = 10,
		/obj/item/clothing/under/brown = 10,
		/obj/item/clothing/under/yellowgreen = 10,
		/obj/item/clothing/under/darkblue = 10,
		/obj/item/clothing/under/lightred = 10,
		/obj/item/clothing/under/darkred = 10,
		/obj/item/clothing/under/bluepants = 10,
		/obj/item/clothing/under/blackpants = 10,
		/obj/item/clothing/under/redpants = 10,
		/obj/item/clothing/under/greypants = 10,
		/obj/item/clothing/under/dress/plaid_purple = 10,
		/obj/item/clothing/under/dress/plaid_red = 10,
		/obj/item/clothing/under/dress/plaid_blue = 10,
		/obj/item/clothing/under/greaser = 10,
		/obj/item/clothing/under/sl_suit = 10,
		)
	contraband = list(
		/obj/item/clothing/under/syndicate/tacticool = 5,
		/obj/item/clothing/under/color/orange = 5,
		/obj/item/clothing/under/psyche = 5,
		)
	premium = list(
		/obj/item/clothing/under/rainbow = 1,
		/obj/item/clothing/suit/red_suit = 1,
		)

	pack = /obj/structure/vendomatpack/suitdispenser

//THIS IS WHERE THE FEET LIVE, GIT YE SOME
/obj/machinery/vending/shoedispenser
	name = "\improper Shoelord 9000"
	desc = "A vending machine containing footwear."
	icon_state = "shoes"
	vend_reply = "Enjoy your pair!"
	product_ads = list(
		"Dont be a hobbit: Choose Shoelord.",
		"Shoes snatched? Get on it with Shoelord."
	)
	product_slogans = list(
		"Put your foot down!",
		"One size fits all!",
		"IM WALKING ON SUNSHINE!",
		"No hobbits allowed.",
		"NO PLEASE WILLY, DONT HURT ME- *BZZT*"
	)
	products = list(
		/obj/item/clothing/shoes/black = 10,
		/obj/item/clothing/shoes/brown = 10,
		/obj/item/clothing/shoes/blue = 10,
		/obj/item/clothing/shoes/green = 10,
		/obj/item/clothing/shoes/yellow = 10,
		/obj/item/clothing/shoes/purple = 10,
		/obj/item/clothing/shoes/red = 10,
		/obj/item/clothing/shoes/white = 10,
		/obj/item/clothing/shoes/workboots = 10,
		)
	contraband = list(
		/obj/item/clothing/shoes/jackboots = 5,
		/obj/item/clothing/shoes/orange = 5,
		/obj/item/clothing/shoes/laceup = 5,
		)
	premium = list(
		/obj/item/clothing/shoes/rainbow = 1,
		)

	pack = /obj/structure/vendomatpack/shoedispenser

//HEIL ADMINBUS
/obj/machinery/vending/nazivend
	name = "\improper Nazivend"
	desc = "A vending machine containing Nazi German supplies. A label reads: \"Remember the gorrilions lost.\""
	icon_state = "nazi"
	vend_reply = "SIEG HEIL!"
	product_ads = list(
		"BESTRAFEN die Juden.",
		"BESTRAFEN die Alliierten."
	)
	product_slogans = list(
		"Das Vierte Reich wird zuruckkehren!",
		"ENTFERNEN JUDEN!",
		"Billiger als die Juden jemals geben!",
		"Rader auf dem adminbus geht rund und rund.",
		"Warten Sie, warum wir wieder hassen Juden?- *BZZT*"
	)
	products = list(
		/obj/item/clothing/head/stalhelm = 20,
		/obj/item/clothing/head/panzer = 20,
		/obj/item/clothing/suit/soldiercoat = 20,
		/obj/item/clothing/under/soldieruniform = 20,
		/obj/item/clothing/shoes/jackboots = 20,
		)
	contraband = list(
		/obj/item/clothing/head/naziofficer = 10,
		/obj/item/clothing/suit/officercoat = 10,
		/obj/item/clothing/under/officeruniform = 10,
		)
	premium = list(
		/obj/item/clothing/under/varsity = 1,
		)

	pack = /obj/structure/vendomatpack/nazivend

	machine_flags = SCREWTOGGLE | WRENCHMOVE | FIXED2WORK | CROWDESTROY | EJECTNOTDEL | EMAGGABLE

/obj/machinery/vending/nazivend/emag(mob/user)
	if(!emagged)
		if(user)
			to_chat(user, "<span class='warning'>As you slide the card into the machine, you hear something unlocking inside. The machine emits an evil glow.</span>")
			message_admins("[key_name_admin(user)] unlocked a Nazivend's DANGERMODE!")
		contraband[/obj/item/clothing/head/helmet/space/rig/nazi] = 3
		contraband[/obj/item/clothing/suit/space/rig/nazi] = 3
		contraband[/obj/item/weapon/gun/energy/plasma/MP40k] = 4
		src.build_inventory(contraband, 1)
		emagged = 1
		overlays = 0
		var/image/dangerlay = image(icon,"[icon_state]-dangermode", ABOVE_LIGHTING_LAYER)
		dangerlay.plane = LIGHTING_PLANE
		overlays_vending[2] = dangerlay
		update_icon()
		return 1

//NaziVend++
/obj/machinery/vending/nazivend/DANGERMODE
	products = list(
		/obj/item/clothing/head/stalhelm = 20,
		/obj/item/clothing/head/panzer = 20,
		/obj/item/clothing/suit/soldiercoat = 20,
		/obj/item/clothing/under/soldieruniform = 20,
		/obj/item/clothing/shoes/jackboots = 20,
		)
	contraband = list(
		/obj/item/clothing/head/naziofficer = 10,
		/obj/item/clothing/suit/officercoat = 10,
		/obj/item/clothing/under/officeruniform = 10,
		/obj/item/clothing/head/helmet/space/rig/nazi = 3,
		/obj/item/clothing/suit/space/rig/nazi = 3,
		/obj/item/weapon/gun/energy/plasma/MP40k = 4,
		)
	premium = list(
		/obj/item/clothing/under/varsity = 1,
		)

	pack = /obj/structure/vendomatpack/nazivend //can be reloaded with the same packs as the regular one

/obj/machinery/vending/nazivend/DANGERMODE/New()
	..()
	emagged = 1
	overlays = 0
	var/image/dangerlay = image(icon,"[icon_state]-dangermode", ABOVE_LIGHTING_LAYER)
	dangerlay.plane = LIGHTING_PLANE
	overlays_vending[2] = dangerlay
	update_icon()

//MOTHERBUSLAND
/obj/machinery/vending/sovietvend
	name = "\improper KomradeVendtink"
	desc = "Rodina-mat' zovyot!"
	icon_state = "soviet"
	vend_reply = "The fascist and capitalist svin'ya shall fall, komrade!"
	product_ads = list(
		"Quality worth waiting in line for!",
		"Get Hammer and Sickled!",
		"Sosvietsky soyuz above all!",
		"With capitalist pigsky, you would have paid a fortunetink!"
	)
	product_slogans = list(
		"Craftink in Motherland herself!"
	)
	products = list(
		/obj/item/clothing/under/soviet = 20,
		/obj/item/clothing/head/ushanka = 20,
		/obj/item/clothing/shoes/jackboots = 20,
		/obj/item/clothing/head/squatter_hat = 20,
		/obj/item/clothing/under/squatter_outfit = 20,
		/obj/item/clothing/under/russobluecamooutfit = 20,
		/obj/item/clothing/head/russobluecamohat = 20,
		)
	contraband = list(
		/obj/item/clothing/under/syndicate/tacticool = 4,
		/obj/item/clothing/mask/balaclava = 4,
		/obj/item/clothing/suit/russofurcoat = 4,
		/obj/item/clothing/head/russofurhat = 4,
		)

	pack = /obj/structure/vendomatpack/sovietvend

	machine_flags = SCREWTOGGLE | WRENCHMOVE | FIXED2WORK | CROWDESTROY | EJECTNOTDEL | EMAGGABLE


/obj/machinery/vending/sovietvend/emag(mob/user)
	if(!emagged)
		if(user)
			to_chat(user, "<span class='warning'>As you slide the card into the machine, you hear something unlocking inside. The machine emits an evil glow.</span>")
			message_admins("[key_name_admin(user)] unlocked a Sovietvend's DANGERMODE!")
		contraband[/obj/item/clothing/head/helmet/space/rig/soviet] = 3
		contraband[/obj/item/clothing/suit/space/rig/soviet] = 3
		contraband[/obj/item/weapon/gun/energy/laser/LaserAK] = 4
		src.build_inventory(contraband, 1)
		emagged = 1
		overlays = 0
		var/image/dangerlay = image(icon,"[icon_state]-dangermode", ABOVE_LIGHTING_LAYER)
		dangerlay.plane = LIGHTING_PLANE
		overlays_vending[2] = dangerlay
		update_icon()
		return 1
	return

//SovietVend++
/obj/machinery/vending/sovietvend/DANGERMODE
	products = list(
		/obj/item/clothing/under/soviet = 20,
		/obj/item/clothing/head/ushanka = 20,
		/obj/item/clothing/shoes/jackboots = 20,
		/obj/item/clothing/head/squatter_hat = 20,
		/obj/item/clothing/under/squatter_outfit = 20,
		/obj/item/clothing/under/russobluecamooutfit = 20,
		/obj/item/clothing/head/russobluecamohat = 20,
		)
	contraband = list(
		/obj/item/clothing/under/syndicate/tacticool = 4,
		/obj/item/clothing/mask/balaclava = 4,
		/obj/item/clothing/suit/russofurcoat = 4,
		/obj/item/clothing/head/russofurhat = 4,
		/obj/item/clothing/head/helmet/space/rig/soviet = 3,
		/obj/item/clothing/suit/space/rig/soviet = 3,
		/obj/item/weapon/gun/energy/laser/LaserAK = 4,
		)

	pack = /obj/structure/vendomatpack/sovietvend//can be reloaded with the same packs as the regular one

/obj/machinery/vending/sovietvend/DANGERMODE/New()
	..()
	emagged = 1
	overlays = 0
	var/image/dangerlay = image(icon,"[icon_state]-dangermode", ABOVE_LIGHTING_LAYER)
	dangerlay.plane = LIGHTING_PLANE
	overlays_vending[2] = dangerlay
	update_icon()

/obj/machinery/vending/discount
	name = "\improper Discount Dan's"
	desc = "A vending machine containing discount snacks. It is owned by the infamous 'Discount Dan' franchise."
	product_slogans = list(
		"Discount Dan, he's the man!",
		"There ain't nothing better in this world than a bite of mystery.",
		"Don't listen to those other machines, buy my product!",
		"Quantity over Quality!",
		"Don't listen to those eggheads at the CDC, buy now!",
		"Discount Dan's: We're good for you! Nope, couldn't say it with a straight face.",
		"Discount Dan's: Only the best quality produ-*BZZT*"
	)
	product_ads = list(
		"Discount Dan(tm) is not responsible for any damages caused by misuse of his product."
	)
	vend_reply = "No refunds."
	icon_state = DISCOUNT
	products = list(
		/obj/item/weapon/reagent_containers/food/snacks/discountchocolate = 6,
		/obj/item/weapon/reagent_containers/food/snacks/danitos = 6,
		/obj/item/weapon/reagent_containers/food/snacks/discountburger = 6,
		/obj/item/weapon/reagent_containers/food/drinks/discount_ramen = 6,
		/obj/item/weapon/reagent_containers/food/snacks/discountburrito = 6,
		/obj/item/weapon/reagent_containers/food/snacks/pie/discount = 6,
		/obj/item/weapon/reagent_containers/food/drinks/discount_sauce = 12
		)
	contraband = list(
		/obj/item/weapon/reagent_containers/pill/antitox = 10
		)
	prices = list(
		/obj/item/weapon/reagent_containers/food/snacks/discountchocolate = 8,
		/obj/item/weapon/reagent_containers/food/snacks/danitos = 10,
		/obj/item/weapon/reagent_containers/food/snacks/discountburger = 10,
		/obj/item/weapon/reagent_containers/food/drinks/discount_ramen = 2,
		/obj/item/weapon/reagent_containers/food/snacks/discountburrito = 10,
		/obj/item/weapon/reagent_containers/food/snacks/pie/discount = 8,
		/obj/item/weapon/reagent_containers/pill/antitox = 10,
		/obj/item/weapon/reagent_containers/food/drinks/discount_sauce = 1
		)

	pack = /obj/structure/vendomatpack/discount

/obj/machinery/vending/groans
	name = "\improper Groans Soda"
	desc = "A vending machine containing discount drinks. It is owned by the infamous 'Groans' franchise."
	product_slogans = list(
		"Groans: Drink up!",
		"Sponsored by Discount Dan!",
		"Take a sip!",
		"Just one sip, do it!"
	)
	product_ads = list(
		"Try our new 'Double Dan' flavor!"
	)
	vend_reply = "No refunds."
	icon_state = "groans"
	products = list(
		/obj/item/weapon/reagent_containers/food/drinks/groans = 10,
		/obj/item/weapon/reagent_containers/food/drinks/filk = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/grifeo = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/mannsdrink = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sportdrink = 10,
		)
	prices = list(
		/obj/item/weapon/reagent_containers/food/drinks/groans = 20,
		/obj/item/weapon/reagent_containers/food/drinks/filk = 20,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/grifeo = 30,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/mannsdrink = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sportdrink = 50,
		/obj/item/weapon/reagent_containers/food/drinks/groansbanned = 50,
		)
	contraband = list(
		/obj/item/weapon/reagent_containers/food/drinks/groansbanned = 10,
		)

	pack = /obj/structure/vendomatpack/groans

/obj/machinery/vending/nuka
	name = "\improper Nuka Cola Machine"
	desc = "A vending machine filled to the brim with ice cold Nuka Cola!"
	product_slogans = list(
		"A refreshing burst of atomic energy!",
		"Drink like there's no tomorrow!",
		"Take the leap... enjoy a Quantum!"
	)
	product_ads = list(
		"Wouldn't you enjoy an ice cold Nuka Cola right about now?"
	)
	vend_reply = "Enjoy a Nuka break!"
	icon_state = "nuka"
	products = list(/obj/item/weapon/reagent_containers/food/drinks/soda_cans/nuka = 15)
	prices = list(/obj/item/weapon/reagent_containers/food/drinks/soda_cans/nuka = 20, /obj/item/weapon/reagent_containers/food/drinks/soda_cans/quantum = 50)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/soda_cans/quantum = 5)

	pack = /obj/structure/vendomatpack/nuka

/obj/machinery/vending/chapel
	name = "\improper PietyVend"
	desc = "A vending machine containing religious supplies and clothing. A label reads: \"A holy vendor for a pious man.\""
	req_access = list(access_chapel_office)
	product_slogans = list(
		"Bene orasse est bene studuisse.",
		"Beati pauperes spiritu.",
		"Di immortales virtutem approbare, non adhibere debent."
	)
	product_ads = list(
		"Deus tecum."
	)
	vend_reply = "Deus vult!"
	icon_state = "chapel"
	products = list(
		/obj/item/clothing/under/rank/chaplain = 2,
		/obj/item/clothing/shoes/laceup = 2,
		/obj/item/clothing/suit/nun = 2,
		/obj/item/clothing/head/nun_hood = 2,
		/obj/item/clothing/suit/chaplain_hoodie = 2,
		/obj/item/clothing/head/chaplain_hood = 2,
		/obj/item/clothing/suit/holidaypriest = 2,
		/obj/item/clothing/under/wedding/bride_white = 2,
		/obj/item/clothing/head/hasturhood = 2,
		/obj/item/clothing/suit/hastur = 2,
		/obj/item/clothing/suit/unathi/robe = 2,
		/obj/item/clothing/head/wizard/amp = 2,
		/obj/item/clothing/suit/wizrobe/psypurple = 2,
		/obj/item/clothing/suit/imperium_monk = 2,
		/obj/item/clothing/mask/chapmask = 2,
		/obj/item/clothing/under/sl_suit = 2,
		/obj/item/weapon/storage/backpack/cultpack = 2,
		/obj/item/weapon/storage/fancy/candle_box = 5,
		/obj/item/weapon/reagent_containers/food/snacks/eucharist = 7,
		/obj/item/weapon/storage/fancy/incensebox/harebells = 3,
		/obj/item/incense_oilbox/harebells = 2,
		/obj/item/weapon/storage/fancy/collection_plate = 1,
		)
	contraband = list(
		/obj/item/clothing/head/clockwork_hood = 2,
		/obj/item/clothing/suit/clockwork_robes = 2,
		/obj/item/clothing/shoes/clockwork_boots = 2,
		/obj/item/clothing/suit/kimono/ronin = 2
		)
	premium = list(
		/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater = 1,
		/obj/item/clothing/head/helmet/knight/templar = 2,
 		/obj/item/clothing/suit/armor/knight/templar = 5,
		/obj/item/clothing/head/helmet/knight/interrogator = 2,
 		/obj/item/clothing/suit/armor/knight/interrogator = 2,
 		/obj/item/clothing/suit/armor/knight/interrogator/red = 2,
		/obj/item/clothing/head/inquisitor = 2,
		/obj/item/clothing/suit/inquisitor = 2,
		/obj/item/clothing/under/inquisitor = 2,
		/obj/item/clothing/shoes/jackboots/inquisitor = 2,
		/obj/item/weapon/thurible = 1,
		/obj/item/weapon/storage/fancy/candle_box/holo = 5,
		)
	pack = /obj/structure/vendomatpack/chapelvend


/obj/machinery/vending/trader	// Boxes are defined in trader.dm
	name = "\improper Trader Supply"
	desc = "Its wiring has been modified to prevent hacking."
	unhackable = 1
	desc = "Make much coin."
	req_access = list(access_trade)
	product_slogans = list(
		"Profits."
	)
	product_ads = list(
		"When you charge a customer $100, and he pays you by mistake $200, you have an ethical dilemma: should you tell your partner?"
	)
	vend_reply = "Money money money!"
	icon_state = "voxseed"
	products = list (
		/obj/item/weapon/storage/fancy/donut_box = 2,
		/obj/item/clothing/suit/storage/trader = 3,
		/obj/item/device/pda/trader = 3,
		/obj/item/weapon/card/id/vox/extra = 3,
		/obj/item/weapon/stamp/trader = 3,
		/obj/item/weapon/capsule = 60,
		/obj/item/weapon/implantcase/peace = 5,
		/obj/item/vaporizer = 1,
		/obj/item/weapon/storage/trader_chemistry = 1,
		/obj/structure/closet/secure_closet/wonderful = 1,
		/obj/item/weapon/disk/shuttle_coords/vault/mecha_graveyard = 1,
		/obj/item/weapon/reagent_containers/glass/beaker/bluespace = 1,
		/obj/item/weapon/storage/bluespace_crystal = 1,
		/obj/item/weapon/reagent_containers/food/snacks/borer_egg = 1,
		/obj/item/clothing/shoes/clown_shoes/advanced = 1,
		/obj/item/fish_eggs/seadevil = 1,
		/obj/machinery/power/antiquesynth = 1,
		/obj/item/crackerbox = 1,
		/obj/structure/closet/crate/chest/alcatraz = 1,
		/obj/structure/largecrate/secure = 1,
		/obj/structure/largecrate/secure/magmaw = 1,
		/obj/structure/largecrate/secure/frankenstein = 1,
		/obj/item/weapon/boxofsnow = 3,
		/obj/item/weapon/vinyl/echoes = 1,
		/obj/item/stack/sheet/brass/bigstack = 3,
		/obj/item/stack/sheet/ralloy/bigstack = 3,
		/obj/item/device/vampirehead = 1,
		/obj/item/key/security/spare = 1,
		/obj/item/weapon/depocket_wand = 4,
		/obj/item/weapon/ram_kit = 1,
		)
	prices = list(
		/obj/item/clothing/suit/storage/trader = 100,
		/obj/item/device/pda/trader = 100,
		/obj/item/weapon/card/id/vox/extra = 100,
		/obj/item/weapon/stamp/trader = 20,
		/obj/item/weapon/capsule = 10,
		/obj/item/weapon/implantcase/peace = 100,
		/obj/item/vaporizer = 100,
		/obj/item/weapon/storage/trader_chemistry = 200,
		/obj/structure/closet/secure_closet/wonderful = 350,
		/obj/item/weapon/disk/shuttle_coords/vault/mecha_graveyard = 100,
		/obj/item/weapon/reagent_containers/glass/beaker/bluespace = 100,
		/obj/item/weapon/storage/bluespace_crystal = 150,
		/obj/item/weapon/reagent_containers/food/snacks/borer_egg = 100,
		/obj/item/clothing/shoes/clown_shoes/advanced = 50,
		/obj/item/fish_eggs/seadevil = 50,
		/obj/machinery/power/antiquesynth = 350,
		/obj/structure/closet/crate/chest/alcatraz = 300,
		/obj/structure/largecrate/secure = 100,
		/obj/structure/largecrate/secure/magmaw = 100,
		/obj/structure/largecrate/secure/frankenstein = 100,
		/obj/item/weapon/boxofsnow = 50,
		/obj/item/crackerbox = 200,
		/obj/item/weapon/vinyl/echoes = 50,
		/obj/item/stack/sheet/brass/bigstack = 50,
		/obj/item/stack/sheet/ralloy/bigstack = 50,
		/obj/item/device/vampirehead = 150,
		/obj/item/key/security/spare = 50,
		/obj/item/weapon/depocket_wand = 100,
		/obj/item/weapon/ram_kit = 200,
		)

/obj/machinery/vending/trader/New()
	load_dungeon(/datum/map_element/dungeon/mecha_graveyard)
	var/list/upgrades = existing_typesof(/obj/item/borg/upgrade) - /obj/item/borg/upgrade/magnetic_gripper
	for(var/i = 1 to 3)
		premium.Add(pick_n_take(upgrades))

	..()

/obj/machinery/vending/trader/throw_item()
	var/mob/living/target = locate() in view(7, src)

	if (!target)
		return 0
	for(var/i = 0 to rand(3,12))
		var/obj/I = new /obj/item/weapon/reagent_containers/food/snacks/egg(get_turf(src))
		I.throw_at(target, 16, 3)

/obj/machinery/vending/barber
	name = "\improper BarberVend"
	desc = "The ultimate vendor for any aspiring space stylist."
	product_slogans = list(
		"Haircuts for everyone!",
		"Choose your own style!",
		"A new look available now!"
	)
	product_ads = list(
		"Our new hairdye formula, now available in any color!"
	)
	vend_reply = "Enjoy your new look!"
	icon_state = "barber"
	products = list(
		/obj/item/weapon/hair_dye = 4,
		/obj/item/weapon/razor = 4,
		/obj/item/weapon/pocket_mirror = 4,
		/obj/item/clothing/mask/fakemoustache = 4,
		/obj/item/clothing/under/rank/barber = 4,
		/obj/item/clothing/head/barber = 4,
		/obj/item/clothing/shoes/white = 4,
		/obj/item/clothing/gloves/white = 4,
		)
	contraband = list(
		/obj/item/weapon/lipstick/random = 5,
		)
	pack = /obj/structure/vendomatpack/barbervend


/obj/machinery/vending/makeup
	name = "\improper Sapphire Cosmetics"
	desc = "A vending machine full of cosmetics and beauty products."
	product_slogans = list(
		"There is no such thing as natural beauty.",
		"Wear the look of the future.",
		"Be the beauty in the eye of every beholder."
	)
	product_ads = list(
		"Why be yourself when you can be perfection?"
	)
	vend_reply = "The other girls will be so envious."
	icon_state = "makeup"
	products = list(
		/obj/item/weapon/eyeshadow = 3,
		/obj/item/weapon/eyeshadow/jade = 3,
		/obj/item/weapon/eyeshadow/purple = 3,
		/obj/item/weapon/lipstick/black = 3,
		/obj/item/weapon/lipstick/blue = 3,
		/obj/item/weapon/lipstick/jade = 3,
		/obj/item/weapon/lipstick/purple = 3,
		/obj/item/weapon/lipstick = 3,
		/obj/item/weapon/pocket_mirror = 3,
		)
	contraband = list(
		/obj/item/weapon/hair_dye = 3,
		)
	premium = list(
		/obj/item/clothing/head/hairflower = 3,
		)
	pack = /obj/structure/vendomatpack/makeup

/obj/machinery/vending/circus
	name = "\improper Circus of Values"
	desc = "The Circus of Values Vending Machine offers a variety of items for sale. Most Vending Machines have items at the bottom that will only become available if you successfully hack the machine."
	//Desc text is a direct quote from the Bioshock description
	product_slogans = list(
		"Hahahahahahaha!",
		"Welcome to the Circus of Values!",
		"Come back when you get some money, buddy!",
		"Hey, I've got a family to feed!",
		"No refunds, no returns!"
	)
	vend_reply = "Tell your friends about the Circus of Values!"
	icon_state = "circus"
	products = list(
		/obj/item/toy/balloon = 20,
		/obj/item/toy/waterballoon = 20,
		/obj/item/toy/blink = 6,
		/obj/item/toy/spinningtoy = 6,
		/obj/item/toy/bomb = 2,
		/obj/item/toy/minimeteor = 2,
		/obj/item/toy/snappop = 4,
		/obj/item/toy/syndicateballoon/ntballoon = 1,
		/obj/item/toy/sword = 2,
		/obj/item/toy/katana = 2,
		/obj/item/toy/foamblade = 2,
		/obj/item/weapon/capsule = 20,
		/obj/item/toy/cards = 2,
		/obj/item/toy/cards/une = 2
	)
	contraband = list(
		/obj/item/toy/gun = 2,
		/obj/item/toy/ammo/gun = 10,
		/obj/item/toy/crossbow = 2,
		/obj/item/toy/ammo/crossbow = 20,
	)
	premium = list(
		/obj/item/weapon/storage/bag/wiz_cards/frog = 1
	)
	prices = list(
		/obj/item/toy/balloon = 5,
		/obj/item/toy/waterballoon = 5,
		/obj/item/toy/blink = 10,
		/obj/item/toy/spinningtoy = 20,
		/obj/item/toy/bomb = 20,
		/obj/item/toy/minimeteor = 20,
		/obj/item/toy/snappop = 35,
		/obj/item/toy/gun = 50,
		/obj/item/toy/ammo/gun = 5,
		/obj/item/toy/crossbow = 50,
		/obj/item/toy/ammo/crossbow = 2,
		/obj/item/toy/sword = 50,
		/obj/item/toy/katana = 50,
		/obj/item/toy/foamblade = 50,
		/obj/item/toy/syndicateballoon/ntballoon = 100,
		/obj/item/weapon/capsule = 10,
		/obj/item/toy/cards = 35,
		/obj/item/toy/cards/une = 35
	)
	pack = /obj/structure/vendomatpack/circus

/obj/machinery/vending/sale
	name = "Sales"
	desc = "Buy, sell, repeat."
	icon_state = "sale"
	is_custom_machine = TRUE
	//vend_reply = "Insert another joke here"
	//product_ads = "Another joke here"
	//product_slogans = "Jokes"
	account_first_linked = 0
	machine_flags = SCREWTOGGLE | WRENCHMOVE | FIXED2WORK | CROWDESTROY | EJECTNOTDEL | PURCHASER | WIREJACK | SECUREDPANEL
	products = list()

	pack = /obj/structure/vendomatpack/custom

/obj/machinery/vending/sale/link_to_account()
	return

/obj/machinery/vending/toggleSecuredPanelOpen(var/obj/toggleitem, var/mob/user)
	if(!is_custom_machine)
		return ..()
	var/obj/item/weapon/card/C = user.get_card() //Looks for a debit card first
	if(!account_first_linked || (C && C.associated_account_number == linked_account.account_number))
		togglePanelOpen(toggleitem, user)
		return 1
	to_chat(user, "<span class='warning'>The machine requires an ID to unlock it.</span>")
	return 0

/obj/machinery/vending/mining
	name = "\improper Dwarven Mining Equipment"
	desc = "Get your mining equipment here, and above all keep digging!"
	req_access = list(access_cargo)
	product_slogans = list(
		"This asteroid isn't going to dig itself!",
		"Stay safe in the tunnels, bring two Kinetic Accelerators!",
		"Jetpacks, anyone?"
	)
	product_ads = list(
		"Hungry, thirsty or unequipped? We have your fix!"
	)
	vend_reply = "What a glorious time to mine!"
	icon_state = "mining"
	products = list(
		/obj/item/toy/canary = 10,
		/obj/item/weapon/reagent_containers/food/snacks/hotchili = 10,
		/obj/item/clothing/mask/cigarette/cigar/havana = 5,
		/obj/item/clothing/accessory/holster/knife/boot/preloaded/skinning = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey = 10,
		/obj/item/weapon/soap/nanotrasen = 10,
		/obj/item/clothing/mask/facehugger/toy = 10,
		/obj/item/weapon/storage/belt/lazarus = 3,
		/obj/item/device/mobcapsule = 10,
		/obj/item/weapon/lazarus_injector = 10,
		/obj/item/weapon/pickaxe/jackhammer = 5,
		/obj/item/weapon/mining_drone_cube = 5,
		/obj/item/device/wormhole_jaunter = 10,
		/obj/item/weapon/resonator = 5,
		/obj/item/voucher/warp/kinetic_accelerator = 10,
		/obj/item/weapon/tank/jetpack/carbondioxide = 3,
		/obj/item/weapon/gun/hookshot = 3,
		/obj/item/weapon/lazarus_injector/advanced = 4,
		)
	contraband = list(
		/obj/item/weapon/storage/bag/money = 2,
		)
	premium = list(
		/obj/item/weapon/pickaxe/silver = 1,
		/obj/item/weapon/pickaxe/gold = 1,
		/obj/item/weapon/pickaxe/diamond = 1,
		/obj/item/borg/upgrade/hook = 1,
		)
	prices = list(
		/obj/item/toy/canary = 20,
		/obj/item/weapon/reagent_containers/food/snacks/hotchili = 20,
		/obj/item/clothing/mask/cigarette/cigar/havana = 20,
		/obj/item/clothing/accessory/holster/knife/boot/preloaded/skinning = 15,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey = 15,
		/obj/item/weapon/soap/nanotrasen = 15,
		/obj/item/clothing/mask/facehugger/toy = 25,
		/obj/item/weapon/storage/belt/lazarus = 50,
		/obj/item/device/mobcapsule = 25,
		/obj/item/weapon/lazarus_injector = 50,
		/obj/item/weapon/pickaxe/jackhammer = 50,
		/obj/item/weapon/mining_drone_cube = 50,
		/obj/item/device/wormhole_jaunter = 25,
		/obj/item/weapon/resonator = 75,
		/obj/item/weapon/storage/bag/money = 10,
		/obj/item/voucher/warp/kinetic_accelerator = 25,
		/obj/item/weapon/pickaxe/silver = 100,
		/obj/item/weapon/pickaxe/gold = 200,
		/obj/item/weapon/tank/jetpack/carbondioxide = 300,
		/obj/item/weapon/gun/hookshot = 300,
		/obj/item/weapon/lazarus_injector/advanced = 150,
		/obj/item/weapon/pickaxe/diamond = 300,
		/obj/item/borg/upgrade/hook = 300,
		)

	pack = /obj/structure/vendomatpack/mining

/obj/machinery/vending/games
	name = "\improper Al's Fun And Games"
	desc = "A vending machine that sells various games and toys."
	product_slogans = list(
		"It's all fun and games at Al's Fun And Games!",
		"Roll for initiative!",
		"It's a full house of fun!",
		"Caves and Wyverns 3rd edition available now!"
	)
	product_ads = list(
		"Sponsored by Warlocks of the Shore.",
		"Al's Fun And Games Co. is not liable for friendships damaged by use of the Product."
	)
	icon_state = "games"
	products = list(
		/obj/item/toy/cards = 5,
		/obj/item/toy/cards/une = 5,
		/obj/item/weapon/storage/pill_bottle/dice = 5
		)
	contraband = list(
		/obj/item/weapon/dice/loaded = 3,
		/obj/item/weapon/dice/loaded/d20 = 3
		)
	premium = list(
		/obj/item/weapon/skull = 1,
		/obj/item/weapon/storage/bag/wiz_cards/frog = 3
		)
	prices = list(
		/obj/item/toy/cards = 5,
		/obj/item/toy/cards/une = 10,
		/obj/item/weapon/storage/pill_bottle/dice = 10,
		/obj/item/weapon/dice/loaded = 15,
		/obj/item/weapon/dice/loaded/d20 = 15,
		/obj/item/weapon/skull = 20,
		/obj/item/weapon/storage/bag/wiz_cards/frog = 20
		)

	pack = /obj/structure/vendomatpack/games
	vend_reply = "Don't have too much fun!"
