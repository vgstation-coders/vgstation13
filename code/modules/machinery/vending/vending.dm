#define CAT_NORMAL 1
#define CAT_HIDDEN 2
#define CAT_COIN   3

/datum/data/vending_product
	var/product_name = "generic"
	var/product_path = null
	var/original_amount = 0
	var/amount = 0
	var/price = 0
	var/display_color = "blue"
	var/category = CAT_NORMAL

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

/obj/machinery/vending
	name = "Empty vending machine"
	desc = "Just add some capitalism."
	icon = 'icons/obj/vending.dmi'
	icon_state = "empty"
	var/obj/structure/vendomatpack/pack = null
	layer = 2.9
	anchored = 1
	density = 1
	var/active = 1		//No sales pitches if off!
	var/vend_ready = 1	//Are we ready to vend?? Is it time??
	var/vend_delay = 10	//How long does it take to vend?
	var/datum/data/vending_product/currently_vending = null // A /datum/data/vending_product instance of what we're paying for right now.
	var/delay_product_spawn // If set, uses sleep() in product spawn proc (mostly for seeds to retrieve correct names).
	// To be filled out at compile time
	var/list/products	= list()	// For each, use the following pattern:
	var/list/contraband	= list()	// list(/type/path = amount,/type/path2 = amount2)
	var/list/premium 	= list()	// No specified amount = only one in stock
	var/list/prices     = list()	// Prices for each item, list(/type/path = price), items not in the list don't have a price.

	var/product_slogans = ""	//String of slogans separated by semicolons, optional
	var/product_ads = ""		//String of small ad messages in the vending screen - random chance
	var/list/product_records = list()
	var/list/hidden_records = list()
	var/list/coin_records = list()
	var/list/slogan_list = list()
	var/list/small_ads = list()	//Small ad messages in the vending screen - random chance of popping up whenever you open it
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
	var/obj/item/weapon/coin/coin
	var/datum/wires/vending/wires = null
	var/list/overlays_vending[2]//1 is the panel layer, 2 is the dangermode layer

	var/list/vouchers
	var/obj/item/weapon/storage/lockbox/coinbox/coinbox

	machine_flags = SCREWTOGGLE | WRENCHMOVE | FIXED2WORK | CROWDESTROY | EJECTNOTDEL
	languages = HUMAN

	var/obj/machinery/account_database/linked_db
	var/datum/money_account/linked_account

/obj/machinery/vending/cultify()
	new /obj/structure/cult/forge(loc)
	..()

/obj/machinery/vending/New()
	..()

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
		src.slogan_list = text2list(src.product_slogans, ";")

		// So not all machines speak at the exact same time.
		// The first time this machine says something will be at slogantime + this random value,
		// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is crated.
		src.last_slogan = world.time + rand(0, slogan_delay)

		src.build_inventory(products)
		 //Add hidden inventory
		src.build_inventory(contraband, 1)
		src.build_inventory(premium, 0, 1)
		power_change()

		reconnect_database()
		linked_account = vendor_account

	coinbox = new(src)
	coinbox.req_access |= src.req_access

	return

/obj/machinery/vending/Destroy()
	if(wires)
		wires.Destroy()
		wires = null

/*	var/obj/item/compressed_vend/cvc = new(src.loc)
	cvc.products = products
	cvc.contraband = contraband
	cvc.premium = premium
*/
	if(coinbox)
		coinbox.loc = get_turf(src)
	..()

/obj/machinery/vending/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return

	if(istype(O,/obj/structure/vendomatpack))
		var/obj/structure/vendomatpack/P = O
		if(!anchored)
			user << "<span class='warning'>You need to anchor the vending machine before you can refill it.</span>"
			return
		if(!pack)
			user << "<span class='notice'>You start filling the vending machine with the recharge pack's materials.</span>"
			var/user_loc = user.loc
			var/pack_loc = P.loc
			var/self_loc = src.loc
			sleep(30)
			if(!user || !P || !src)
				return
			if (user.loc == user_loc && P.loc == pack_loc && anchored && self_loc == src.loc && !(user.stat) && (!user.stunned && !user.weakened && !user.paralysis && !user.lying))
				var/obj/machinery/vending/newmachine = new P.targetvendomat(loc)
				user << "<span class='notice'>\icon[newmachine] You finish filling the vending machine, and use the stickers inside the pack to decorate the frame.</span>"
				playsound(newmachine, 'sound/machines/hiss.ogg', 50, 0, 0)
				newmachine.pack = P.type
				var/obj/item/emptyvendomatpack/emptypack = new /obj/item/emptyvendomatpack(P.loc)
				emptypack.icon_state = P.icon_state
				emptypack.overlays += image('icons/obj/vending_pack.dmi',"emptypack")
				qdel(P)
				if(user.machine==src)
					newmachine.attack_hand(user)
				component_parts = 0
				qdel(src)
		else
			if(istype(P,pack))
				user << "<span class='notice'>You start refilling the vending machine with the recharge pack's materials.</span>"
				var/user_loc = user.loc
				var/pack_loc = P.loc
				var/self_loc = src.loc
				sleep(30)
				if(!user || !P || !src)
					return
				if (user.loc == user_loc && P.loc == pack_loc && anchored && self_loc == src.loc && !(user.stat) && (!user.stunned && !user.weakened && !user.paralysis && !user.lying))
					user << "<span class='notice'>\icon[src] You finish refilling the vending machine.</span>"
					playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
					for (var/datum/data/vending_product/D in product_records)
						D.amount = D.original_amount
					for (var/datum/data/vending_product/D in hidden_records)
						D.amount = D.original_amount
					var/obj/item/emptyvendomatpack/emptypack = new /obj/item/emptyvendomatpack(P.loc)
					emptypack.icon_state = P.icon_state
					emptypack.overlays += image('icons/obj/vending_pack.dmi',"emptypack")
					qdel(P)
					if(user.machine==src)
						src.attack_hand(user)
			else
				user << "<span class='warning'>This recharge pack isn't meant for this kind of vending machines.</span>"

/obj/machinery/vending/proc/reconnect_database()
	for(var/obj/machinery/account_database/DB in account_DBs)
		//Checks for a database on its Z-level, else it checks for a database at the main Station.
		if((DB.z == src.z) || (DB.z == STATION_Z))
			if((DB.stat == 0))//If the database if damaged or not powered, people won't be able to use the vending machines anymore.
				linked_db = DB
				break

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
		del(src)


/obj/machinery/vending/proc/build_inventory(var/list/productlist,hidden=0,req_coin=0)
	for(var/typepath in productlist)
		var/amount = productlist[typepath]
		var/price = prices[typepath]
		if(isnull(amount)) amount = 1

		var/atom/temp = new typepath(null)
		var/datum/data/vending_product/R = new /datum/data/vending_product()
		R.product_path = typepath
		R.amount = amount
		R.original_amount = amount
		R.price = price
		R.display_color = pick("red","blue","green")

		if(hidden)
			R.category=CAT_HIDDEN
			hidden_records  += R
		else if(req_coin)
			R.category=CAT_COIN
			coin_records    += R
		else
			R.category=CAT_NORMAL
			product_records += R

		if(delay_product_spawn)
			sleep(1)
			R.product_name = temp.name
		else
			R.product_name = temp.name

/obj/machinery/vending/proc/get_item_by_type(var/this_type)
	var/list/datum_products = list()
	datum_products |= hidden_records
	datum_products |= coin_records
	datum_products |= product_records
	for(var/datum/data/vending_product/product in datum_products)
		if(product.product_path == this_type)
			return product
	return null

//		world << "Added: [R.product_name]] - [R.amount] - [R.product_path]"

/obj/machinery/vending/emag(mob/user)
	if(!emagged)
		emagged = 1
		user << "You short out the product lock on \the [src]"
		return 1
	return -1

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
			voucher.loc = coinbox
	return 1

/obj/machinery/vending/attackby(obj/item/weapon/W, mob/user)
	. = ..()
	if(.)
		return .
	if(istype(W, /obj/item/device/multitool)||istype(W, /obj/item/weapon/wirecutters))
		if(panel_open)
			attack_hand(user)
		return
	else if(istype(W, /obj/item/weapon/coin) && premium.len > 0)
		if (isnull(coin))
			user.drop_item(src)
			coin = W
			user << "<span class='notice'>You insert a coin into [src].</span>"
		else
			user << "<SPAN CLASS='notice'>There's already a coin in [src].</SPAN>"

		return
	else if(istype(W, /obj/item/voucher))
		if(can_accept_voucher(W, user))
			user.drop_item(src)
			user << "<span class='notice'>You insert [W] into [src].</span>"
			return voucher_act(W, user)
		else
			user << "<span class='notice'>\The [src] refuses to take [W].</span>"
			return 1
	/*else if(istype(W, /obj/item/weapon/card) && currently_vending)
		//attempt to connect to a new db, and if that doesn't work then fail
		if(!linked_db)
			reconnect_database()
		if(linked_db)
			if(linked_account)
				var/obj/item/weapon/card/I = W
				scan_card(I)
			else
				usr << "\icon[src]<span class='warning'>Unable to connect to linked account.</span>"
		else
			usr << "\icon[src]<span class='warning'>Unable to connect to accounts database.</span>"*/

//H.wear_id
/obj/machinery/vending/proc/connect_account(var/obj/item/W)
	if(istype(W, /obj/item/device/pda))
		W=W:id // Cheating, but it'll work.  Hopefully.
	if(istype(W, /obj/item/weapon/card) && currently_vending)
		//attempt to connect to a new db, and if that doesn't work then fail
		if(!linked_db)
			reconnect_database()
		if(linked_db)
			if(linked_account)
				var/obj/item/weapon/card/I = W
				scan_card(I)
			else
				usr << "\icon[src]<span class='warning'>Unable to connect to linked account.</span>"
		else
			usr << "\icon[src]<span class='warning'>Unable to connect to accounts database.</span>"

/obj/machinery/vending/proc/scan_card(var/obj/item/weapon/card/I)
	if(!currently_vending) return
	if (istype(I, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/C = I
		visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
		if(linked_account)
			var/datum/money_account/D = linked_db.attempt_account_access(C.associated_account_number, 0, 2, 0) // Pin = 0, Sec level 2, PIN not required.
			if(D)
				var/transaction_amount = currently_vending.price
				if(transaction_amount <= D.money)

					//transfer the money
					D.money -= transaction_amount
					linked_account.money += transaction_amount

					usr << "\icon[src]<span class='notice'>Remaining balance: [D.money]$</span>"

					//create entries in the two account transaction logs
					var/datum/transaction/T = new()
					T.target_name = "[linked_account.owner_name] (via [src.name])"
					T.purpose = "Purchase of [currently_vending.product_name]"
					T.amount = "[transaction_amount]"
					T.source_terminal = src.name
					T.date = current_date_string
					T.time = worldtime2text()
					D.transaction_log.Add(T)
					//
					T = new()
					T.target_name = D.owner_name
					T.purpose = "Purchase of [currently_vending.product_name]"
					T.amount = "[transaction_amount]"
					T.source_terminal = src.name
					T.date = current_date_string
					T.time = worldtime2text()
					linked_account.transaction_log.Add(T)

					// Vend the item
					src.vend(src.currently_vending, usr)
					currently_vending = null
				else
					usr << "\icon[src]<span class='warning'>You don't have that much money!</span>"
			else
				usr << "\icon[src]<span class='warning'>Unable to access account. Check security settings and try again.</span>"
		else
			usr << "\icon[src]<span class='warning'>EFTPOS is not connected to an account.</span>"

/obj/machinery/vending/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/vending/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/vending/proc/GetProductIndex(var/datum/data/vending_product/P)
	var/list/plist
	switch(P.category)
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
		if(CAT_NORMAL)
			return product_records[pid]
		if(CAT_HIDDEN)
			return hidden_records[pid]
		if(CAT_COIN)
			return coin_records[pid]
		else
			warning("UNKNOWN PRODUCT: PID: [pid], CAT: [category] INSIDE [type]!")
			return null

/obj/machinery/vending/attack_hand(mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return

	if(seconds_electrified > 0)
		if(shock(user, 100))
			return
	else if (seconds_electrified)
		seconds_electrified = 0

	user.set_machine(src)

	var/vendorname = (src.name)  //import the machine's name

	if(src.currently_vending)
		var/dat = "<TT><center><b>[vendorname]</b></center><hr /><br>" //display the name, and added a horizontal rule

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\vending.dm:260: dat += "<b>You have selected [currently_vending.product_name].<br>Please ensure your ID is in your ID holder or hand.</b><br>"
		dat += {"<b>You have selected [currently_vending.product_name].<br>Please ensure your ID is in your ID holder or hand.</b><br>
			<a href='byond://?src=\ref[src];buy=1'>Pay</a> |
			<a href='byond://?src=\ref[src];cancel_buying=1'>Cancel</a>"}
		// END AUTOFIX
		user << browse(dat, "window=vending")
		onclose(user, "")
		return

	var/dat = "<TT><center><b>[vendorname]</b></center><hr /><br>" //display the name, and added a horizontal rule
	dat += "<b>Select an item: </b><br><br>" //the rest is just general spacing and bolding

	if (premium.len > 0)
		dat += "<b>Coin slot:</b> [coin ? coin : "No coin inserted"] (<a href='byond://?src=\ref[src];remove_coin=1'>Remove</A>)<br><br>"

	if (src.product_records.len == 0)
		dat += "<font color = 'red'>No products loaded!</font>"
	else
		var/list/display_records = src.product_records.Copy()

		if(src.extended_inventory)
			display_records += src.hidden_records
		if(src.coin)
			display_records += src.coin_records

		for (var/datum/data/vending_product/R in display_records)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\vending.dm:285: dat += "<FONT color = '[R.display_color]'><B>[R.product_name]</B>:"
			dat += {"<FONT color = '[R.display_color]'><B>[R.product_name]</B>:
				<b>[R.amount]</b> </font>"}
			// END AUTOFIX
			if(R.price)
				dat += " <b>($[R.price])</b>"
			if (R.amount > 0)
				var/idx=GetProductIndex(R)
				dat += " <a href='byond://?src=\ref[src];vend=[idx];cat=[R.category]'>(Vend)</A>"
			else
				dat += " <font color = 'red'>SOLD OUT</font>"
			dat += "<br>"

		dat += "</TT>"

	if(panel_open)
		dat += wires()

		if(product_slogans != "")
			dat += "The speaker switch is [shut_up ? "off" : "on"]. <a href='?src=\ref[src];togglevoice=[1]'>Toggle</a>"

	user << browse(dat, "window=vending")
	onclose(user, "vending")
	return


// returns the wire panel text
/obj/machinery/vending/proc/wires()
	return wires.GetInteractWindow()

/obj/machinery/vending/Topic(href, href_list)
	if(..())
		return

	//testing("..(): [href]")

	if(istype(usr,/mob/living/silicon))
		if(istype(usr,/mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = usr
			if(!(R.module && istype(R.module,/obj/item/weapon/robot_module/butler) ) && !isMoMMI(R))
				usr << "\red The vending machine refuses to interface with you, as you are not in its target demographic!"
				return
		else
			usr << "\red The vending machine refuses to interface with you, as you are not in its target demographic!"
			return

	if(href_list["remove_coin"])
		if(!coin)
			usr << "There is no coin in this machine."
			return

		coin.loc = get_turf(src)
		if(!usr.get_active_hand())
			usr.put_in_hands(coin)
		usr << "\blue You remove the [coin] from the [src]"
		coin = null
	usr.set_machine(src)


	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		if (href_list["vend"] && src.vend_ready && !currently_vending)
			//testing("vend: [href]")

			if (!allowed(usr) && !emagged && scan_id) //For SECURE VENDING MACHINES YEAH
				usr << "\red Access denied." //Unless emagged of course
				flick(src.icon_deny,src)
				return

			var/idx=text2num(href_list["vend"])
			var/cat=text2num(href_list["cat"])

			var/datum/data/vending_product/R = GetProductByID(idx,cat)
			if (!R || !istype(R) || !R.product_path || R.amount <= 0)
				message_admins("Invalid vend request by [formatJumpTo(src.loc)]: [href]")
				return

			if(R.price == null || !R.price)
				src.vend(R, usr)
			else
				src.currently_vending = R
				src.updateUsrDialog()

			return

		else if (href_list["cancel_buying"])
			src.currently_vending = null
			src.updateUsrDialog()
			return

		else if (href_list["buy"])
			if(istype(usr, /mob/living/carbon/human))
				var/mob/living/carbon/human/H=usr
				var/obj/item/weapon/card/card = null
				var/obj/item/device/pda/pda = null
				if(istype(H.wear_id,/obj/item/weapon/card))
					card=H.wear_id
				else if(istype(H.get_active_hand(),/obj/item/weapon/card))
					card=H.get_active_hand()
				else if(istype(H.wear_id,/obj/item/device/pda))
					pda=H.wear_id
					if(pda.id)
						card=pda.id
				else if(istype(H.get_active_hand(),/obj/item/device/pda))
					pda=H.get_active_hand()
					if(pda.id)
						card=pda.id
				if(card)
					connect_account(card)
			src.updateUsrDialog()
			return

		else if ((href_list["togglevoice"]) && (src.panel_open))
			src.shut_up = !src.shut_up

		src.add_fingerprint(usr)
		src.updateUsrDialog()
	else
		usr << browse(null, "window=vending")
		return
	return

/obj/machinery/vending/proc/vend(datum/data/vending_product/R, mob/user, by_voucher = 0)
	if (!allowed(user) && !emagged && wires.IsIndexCut(VENDING_WIRE_IDSCAN)) //For SECURE VENDING MACHINES YEAH
		user << "\red Access denied." //Unless emagged of course
		flick(src.icon_deny,src)
		return
	src.vend_ready = 0 //One thing at a time!!

	if (!by_voucher && (R in coin_records))
		if (isnull(coin))
			user << "<SPAN CLASS='notice'>You need to insert a coin to get this item.</SPAN>"
			return

		if (coin.string_attached)
			if (prob(50))
				user.put_in_hands(coin)
				user << "<SPAN CLASS='notice'>You successfully pulled the coin out before the [src] could swallow it.</SPAN>"
			else
				user << "<SPAN CLASS='notice'>You weren't able to pull the coin out fast enough, the machine ate it, string and all.</SPAN>"

		if (!isnull(coinbox))
			if (coinbox.can_be_inserted(coin, TRUE))
				coinbox.handle_item_insertion(coin, TRUE)

		coin = null

	R.amount--

	if(((src.last_reply + (src.vend_delay + 200)) <= world.time) && src.vend_reply)
		spawn(0)
			src.speak(src.vend_reply)
			src.last_reply = world.time

	use_power(5)
	if (src.icon_vend) //Show the vending animation if needed
		flick(src.icon_vend,src)
	spawn(src.vend_delay)
		new R.product_path(get_turf(src))
		src.vend_ready = 1
		return

	src.updateUsrDialog()

/obj/machinery/vending/process()
	if(stat & (BROKEN|NOPOWER))
		return

	if(!src.active)
		return

	if(src.seconds_electrified > 0)
		src.seconds_electrified--

	//Pitch to the people!  Really sell it!
	if(((src.last_slogan + src.slogan_delay) <= world.time) && (src.slogan_list.len > 0) && (!src.shut_up) && prob(5))
		var/slogan = pick(src.slogan_list)
		src.speak(slogan)
		src.last_slogan = world.time

	if(src.shoot_inventory && prob(2))
		src.throw_item()

	return

/obj/machinery/vending/proc/speak(var/message)
	if(stat & NOPOWER)
		return

	if (!message)
		return
	say(message)

/obj/machinery/vending/say_quote(text)
	return "beeps, \"[text]\""

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
	for(var/datum/data/vending_product/R in src.product_records)
		if (R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = R.product_path
		if (!dump_path)
			continue

		while(R.amount>0)
			new dump_path(src.loc)
			R.amount--
		break

	stat |= BROKEN
	src.icon_state = "[initial(icon_state)]-broken"
	return

//Somebody cut an important wire and now we're following a new definition of "pitch."
/obj/machinery/vending/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return 0

	for(var/datum/data/vending_product/R in src.product_records)
		if (R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = R.product_path
		if (!dump_path)
			continue

		R.amount--
		throw_item = new dump_path(src.loc)
		break
	if (!throw_item)
		return 0
	spawn(0)
		throw_item.throw_at(target, 16, 3)
	src.visible_message("\red <b>[src] launches [throw_item.name] at [target.name]!</b>")
	return 1

/obj/machinery/vending/update_icon()
	if(panel_open)
		overlays += overlays_vending[1]
	else
		overlays -= overlays_vending[1]

	overlays -= overlays_vending[2]
	if(emagged)
		overlays += overlays_vending[2]


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

//This one's from bay12
/obj/machinery/vending/cart
	name = "PTech"
	desc = "Cartridges for PDAs"
	product_slogans = "Carts to go!"
	icon_state = "cart"
	icon_deny = "cart-deny"
	products = list(/obj/item/weapon/cartridge/medical = 10,/obj/item/weapon/cartridge/engineering = 10,/obj/item/weapon/cartridge/security = 10,
					/obj/item/weapon/cartridge/janitor = 10,/obj/item/weapon/cartridge/signal/toxins = 10,/obj/item/device/pda/heads = 10,
					/obj/item/weapon/cartridge/captain = 3,/obj/item/weapon/cartridge/quartermaster = 10)

	pack = /obj/structure/vendomatpack/undefined

//This one's from bay12
/obj/machinery/vending/plasmaresearch
	name = "Toximate 3000"
	desc = "All the fine parts you need in one vending machine!"
	products = list(/obj/item/clothing/under/rank/scientist = 6,/obj/item/clothing/suit/bio_suit = 6,/obj/item/clothing/head/bio_hood = 6,
					/obj/item/device/transfer_valve = 6,/obj/item/device/assembly/timer = 6,/obj/item/device/assembly/signaler = 6,
					/obj/item/device/assembly/prox_sensor = 6,/obj/item/device/assembly/igniter = 6)

	pack = /obj/structure/vendomatpack/undefined

/obj/machinery/vending/wallmed1
	name = "NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?"
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	//req_access_txt = "5"
	density = 0 //It is wall-mounted, and thus, not dense. --Superxpdude
	products = list(/obj/item/stack/medical/bruise_pack = 2,/obj/item/stack/medical/ointment = 2,/obj/item/weapon/reagent_containers/syringe/inaprovaline = 4,/obj/item/device/healthanalyzer = 1)
	contraband = list(/obj/item/weapon/reagent_containers/syringe/antitoxin = 4,/obj/item/weapon/reagent_containers/syringe/antiviral = 4,/obj/item/weapon/reagent_containers/pill/tox = 1)

	pack = /obj/structure/vendomatpack/medical//can be reloaded with NanoMed Plus packs
	component_parts = 0

/obj/machinery/vending/wallmed2
	name = "NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	//req_access_txt = "5"
	density = 0 //It is wall-mounted, and thus, not dense. --Superxpdude
	products = list(/obj/item/weapon/reagent_containers/syringe/inaprovaline = 5,/obj/item/weapon/reagent_containers/syringe/antitoxin = 3,/obj/item/stack/medical/bruise_pack = 3,
					/obj/item/stack/medical/ointment =3,/obj/item/device/healthanalyzer = 3)
	contraband = list(/obj/item/weapon/reagent_containers/pill/tox = 3)
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
	if(do_after(user, 40))
		user.visible_message(	"[user] detaches the NanoMed from the wall.",
								"You detach the NanoMed from the wall.")
		playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
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
	if(do_after(user, 40))
		user.visible_message(	"[user] detaches the NanoMed from the wall.",
								"You detach the NanoMed from the wall.")
		playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
		new /obj/item/mounted/frame/wallmed(src.loc)

		for(var/obj/I in src)
			qdel(I)

		new /obj/item/weapon/circuitboard/vendomat(src.loc)
		new /obj/item/stack/cable_coil(loc,5)

		return 1
	return -1

/obj/machinery/wallmed_frame
	name = "NanoMed frame"
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
	pixel_x = (dir & 3)? 0 : (dir == 4 ? 30 : -30)
	pixel_y = (dir & 3)? (dir ==1 ? 30 : -30) : 0

/obj/machinery/wallmed_frame/update_icon()
	icon_state = "wallmed_frame[build]"

/obj/machinery/wallmed_frame/attackby(var/obj/item/W as obj, var/mob/user as mob)
	switch(build)
		if(0) // Empty hull
			if(istype(W, /obj/item/weapon/screwdriver))
				usr << "You begin removing screws from \the [src] backplate..."
				if(do_after(user, 50))
					usr << "<span class='notice'>You unscrew \the [src] from the wall.</span>"
					playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
					new /obj/item/mounted/frame/wallmed(get_turf(src))
					del(src)
				return 1
			if(istype(W, /obj/item/weapon/circuitboard))
				var/obj/item/weapon/circuitboard/C=W
				if(!(istype(C,/obj/item/weapon/circuitboard/vendomat)))
					user << "<span class='warning'>You cannot install this type of board into a NanoMed frame.</span>"
					return
				usr << "You begin to insert \the [C] into \the [src]."
				if(do_after(user, 10))
					usr << "<span class='notice'>You secure \the [C]!</span>"
					user.drop_item(src)
					_circuitboard=C
					playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
					build++
					update_icon()
				return 1
		if(1) // Circuitboard installed
			if(istype(W, /obj/item/weapon/crowbar))
				usr << "You begin to pry out \the [W] into \the [src]."
				if(do_after(user, 10))
					playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
					build--
					update_icon()
					var/obj/item/weapon/circuitboard/C
					if(_circuitboard)
						_circuitboard.loc=get_turf(src)
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
				user << "You start adding cables to \the [src]..."
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				if(do_after(user, 20) && C.amount >= 5)
					C.use(5)
					build++
					update_icon()
					user.visible_message(\
						"<span class='warning'>[user.name] has added cables to \the [src]!</span>",\
						"You add cables to \the [src].")
		if(2) // Circuitboard installed, wired.
			if(istype(W, /obj/item/weapon/wirecutters))
				usr << "You begin to remove the wiring from \the [src]."
				if(do_after(user, 50))
					new /obj/item/stack/cable_coil(loc,5)
					user.visible_message(\
						"<span class='warning'>[user.name] cut the cables.</span>",\
						"You cut the cables.")
					build--
					update_icon()
				return 1
			if(istype(W, /obj/item/weapon/screwdriver))
				user << "You begin to complete \the [src]..."
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				if(do_after(user, 20))
					if(!_circuitboard)
						_circuitboard=new boardtype(src)
					build++
					update_icon()
					user.visible_message(\
						"<span class='warning'>[user.name] has finished \the [src]!</span>",\
						"You finish \the [src].")
				return 1
		if(3) // Waiting for a recharge pack
			if(istype(W, /obj/item/weapon/screwdriver))
				user << "You begin to unscrew \the [src]..."
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				if(do_after(user, 30))
					build--
					update_icon()
				return 1
	..()

/obj/machinery/wallmed_frame/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if(build==3)
		if(istype(O,/obj/structure/vendomatpack))
			if(istype(O,/obj/structure/vendomatpack/medical))
				user << "<span class='notice'>You start refilling the vending machine with the recharge pack's materials.</span>"
				var/user_loc = user.loc
				var/pack_loc = O.loc
				var/self_loc = src.loc
				sleep(30)
				if(!user || !O || !src)
					return
				if (user.loc == user_loc && O.loc == pack_loc && anchored && self_loc == src.loc && !(user.stat) && (!user.stunned && !user.weakened && !user.paralysis && !user.lying))
					user << "<span class='notice'>\icon[src] You finish refilling the vending machine.</span>"
					playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
					var/obj/machinery/vending/wallmed1/newnanomed = new /obj/machinery/vending/wallmed1(src.loc)
					newnanomed.name = "Emergency NanoMed"
					newnanomed.pixel_x = pixel_x
					newnanomed.pixel_y = pixel_y
					var/obj/item/emptyvendomatpack/emptypack = new /obj/item/emptyvendomatpack(O.loc)
					emptypack.icon_state = O.icon_state
					emptypack.overlays += image('icons/obj/vending_pack.dmi',"emptypack")
					qdel(O)
					contents = 0
					qdel(src)
			else
				user << "<span class='warning'>This recharge pack isn't meant for this kind of vending machines.</span>"

////////////////////////////////////////
