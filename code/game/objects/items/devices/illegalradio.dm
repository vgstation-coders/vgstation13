/obj/item/device/illegalradio
	icon = 'icons/obj/radio.dmi'
	name = "black market uplink"
	suffix = "\[3\]"
	icon_state = "illegalradio"
	item_state = "illegalradio"
	desc = "A modified radio with a link to the black market. Use with caution."

	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throw_speed = 2
	throw_range = 9
	w_class = W_CLASS_SMALL
	starting_materials = list(MAT_IRON = 75, MAT_GLASS = 25)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC
	
	
	var/credits_held //For cash payment
	var/linked_db //For card payment
	
	var/welcome 					// Welcoming menu message
	var/money_stored = 5000			// Money placed in the buffer
	// List of items not to shove in their hands.
	var/list/purchase_log = list()
	var/show_description = null
	var/active = 0
	var/job = null
	
/obj/item/device/illegalradio/interact(mob/user as mob)
	var/dat = "<body link='yellow' alink='white' bgcolor='#331461'><font color='white'>"
	dat += src.generate_menu(user)

	dat += {"<A href='byond://?src=\ref[src];lock=1'>Lock</a>
		</font></body>"}
	user << browse(dat, "window=hidden")
	onclose(user, "hidden")
	return

/obj/item/device/illegalradio/attack_self(mob/user as mob)
	user.set_machine(src)
	interact(user)	
	
/obj/item/device/illegalradio/Topic(href, href_list)
	..()
		
	if (href_list["buy_item"])
		var/item = href_list["buy_item"]
		var/list/split = splittext(item, ":") // throw away variable

		if(split.len == 2)
			// Collect category and number
			var/category = split[1]
			var/number = text2num(split[2])

			var/list/buyable_items = get_black_market_items()

			var/list/uplink = buyable_items[category]
			if(uplink && uplink.len >= number)
				var/datum/uplink_item/I = uplink[number]
				if(I)
					I.buy(src, usr)
			else
				var/text = "[key_name(usr)] tried to purchase a black market item that doesn't exist."
				var/textalt = "[key_name(usr)] tried to purchase a black market item that doesn't exist: [item]."
				message_admins(text)
				log_game(textalt)
				admin_log.Add(textalt)

	else if(href_list["show_desc"])
		show_description = text2num(href_list["show_desc"])
		interact(usr)
		
/obj/item/device/illegalradio/proc/generate_menu(mob/user as mob)
	welcome = pick("Stop wasting bandwidth, buy something already!","Telecrystals ain't cheap, kid. Pay up.","There ain't nothing better than a good deal.","Back in my day, we didn't have 'teleporters'.","Human and Vox slaves NOT accepted as payment.","The black market - for when spare rushing doesn't cut it.")
	if(!job)
		job = user.mind.assigned_role

	var/dat = list()
	dat += "<B>[src.welcome]</B><BR>"

	dat += {"Tele-Crystals left: [src.money_stored]<BR>
		<HR>
		<B>Request item:</B><BR>
		<I>Each item costs the price that follows its name. Cash only.</I><br><BR>"}
	var/list/buyable_items = get_black_market_items()

	// Loop through categories
	var/index = 0
	for(var/category in buyable_items)

		index++
		dat += "<b>[category]</b><br>"

		var/merchandise_list = list()

		var/i = 0
		// Loop through items in category
		for(var/datum/uplink_item/item in buyable_items[category])
			i++
			var/itemcost = item.get_cost()
			var/cost_text = ""
			var/desc = "[item.desc]"
			var/final_text = ""
			if(itemcost > 0)
				cost_text = "([itemcost])"
			if(itemcost <= money_stored)
				final_text += "<A href='byond://?src=\ref[src];buy_item=[url_encode(category)]:[i];'>[item.name]</A> [cost_text] "
			else
				final_text += "<font color='grey'><i>[item.name] [cost_text] </i></font>"
			if(item.refundable)
				final_text += "<span style='color: yellow;'>\[R\]</span>"
			if(item.desc)
				if(show_description == 2)
					final_text += "<A href='byond://?src=\ref[src];show_desc=1'><font size=2>\[-\]</font></A><BR><font size=2>[desc][item.refundable ? " Use this item on your uplink to refund it for [item.refund_amount || item.cost] TC.":""]</font>"
				else
					final_text += "<A href='byond://?src=\ref[src];show_desc=2' title='[html_encode(desc)]'><font size=2>\[?\]</font></A>"
			final_text += "<BR>"
			merchandise_list += final_text

		for(merchandise_list) 
			dat += text

		// Break up the categories, if it isn't the last.
		if(buyable_items.len != index)
			dat += "<br>"

	dat += "<HR>"
	dat = jointext(dat,"") //Optimize BYOND's shittiness by making "dat" actually a list of strings and join it all together afterwards! Yes, I'm serious, this is actually a big deal
	return dat
	
	
	
	
	
/*/obj/item/device/illegalradio/proc/pay_with_cash(var/obj/item/weapon/spacecash/cashmoney, mob/user)
	visible_message("<span class='info'>[usr] inserts a credit chip into [src].</span>")
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
		
/obj/item/device/illegalradio/proc/scan_card(var/obj/item/weapon/card/I)
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


/obj/machinery/vending/attackby(obj/item/W, mob/user)
	else if(istype(W, /obj/item/weapon/spacecash))
		var/obj/item/weapon/spacecash/C = W
		pay_with_cash(C, user)
	else if(istype(W, /obj/item/weapon/card))
		connect_account(user, W)
		src.updateUsrDialog()
		return			
	else if(istype(W, /obj/item/weapon/card/emag))
		visible_message("<span class='info'>[usr] swipes a card through [src], and it explodes!</span>")
		to_chat(user, "<span class='notice'>You swipe \the [W] through [src], and it explodes!</span>")
		//Explode
		to_chat(user, "<span class='notice'>You hear a faint laughter in your head.<span>")
		
/obj/machinery/proc/connect_account(var/mob/user, var/obj/item/W)
	if(istype(W, /obj/item/weapon/card))
		if(!linked_db)
			reconnect_database()
		if(linked_db)
			if(linked_account)
				var/obj/item/weapon/card/I = W
				scan_card(I)
			else
				to_chat(user, "[bicon(src)]<span class='warning'>Unable to connect to linked account.</span>")
		else
			to_chat(user, "[bicon(src)]<span class='warning'>Unable to connect to accounts database.</span>")
*/
/obj/item/device/illegalradio/Destroy()
	..()