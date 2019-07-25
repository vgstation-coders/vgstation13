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

	var/list/cached_sellables
	var/list/purchase_log = list()
	var/show_description = null
	var/datum/black_market_item/selected_item = null
	
	var/money_stored
	var/nanotrasen_variant = 0
	var/scan_time = 20
	var/teleport_time = 200
	var/advanced_teleport_time = 100
	var/scanning = 0
	

/obj/item/device/illegalradio/nanotrasen
	name = "advanced black market uplink"
	icon_state = "illegalradio_nt"
	item_state = "illegalradio_nt"
	desc = "A highly protected uplink that uses encrypted Centcomm channels to communicate with the black market. It only exists on high-security Nanotrasen records."
	nanotrasen_variant = 1
	
/obj/item/device/illegalradio/New()
	..()
	money_stored = 0
	cached_sellables = get_black_market_sellables()

/obj/item/device/illegalradio/interact(mob/user as mob) //Whenever called, return to main menu.
	selected_item = null
	var/dat = "<body link='yellow' alink='white' bgcolor='#331461'><font color='white'>"
	dat += src.generate_main_menu(user)
	dat += "</body></font>"
	user << browse(dat, "window=hidden")
	onclose(user, "hidden")
	return

/obj/item/device/illegalradio/attack_self(mob/user as mob)
	user.set_machine(src)
	interact(user)

	

/obj/item/device/illegalradio/Topic(href, href_list)
	..()

	if (href_list["buy_item"])
		var/delivery_method = href_list["buy_item"]
		if(!delivery_method)
			to_chat(usr,"Something went wrong. Please tell a coder. Error code: ohfuck593")
			return			
		delivery_method = text2num(delivery_method)
		
		if(!selected_item)
			to_chat(usr,"Something went wrong. Please tell a coder. Error code: ohfuck594")
			return 0

		selected_item.buy(src, delivery_method, usr)
		selected_item = null
		interact(usr)
				
	else if(href_list["open_delivery_menu"])
		var/input = href_list["open_delivery_menu"]
		var/list/split = splittext(input, ":")

		if(split.len == 2)
			var/category = split[1]
			var/number = text2num(split[2])

			var/list/buyable_items = get_black_market_items()
			var/list/category_items = buyable_items[category]
			
			if(category_items && category_items.len >= number)
				var/datum/black_market_item/item = category_items[number]
				if(item)
					selected_item = item
					var/dat = "<body link='yellow' alink='white' bgcolor='#331461'><font color='white'>"
					dat += generate_delivery_menu(usr,item)
					dat += "</body></font>"
					usr << browse(dat, "window=hidden")
					onclose(usr, "hidden")
					return
				
	else if (href_list["open_buyers"])
		var/dat = "<body link='yellow' alink='white' bgcolor='#331461'><font color='white'>"
		dat += src.generate_buyer_menu(usr)
		dat += "</body></font>"
		usr << browse(dat, "window=hidden")
		onclose(usr, "hidden")
		
	else if(href_list["open_main"])
		interact(usr)
	
	else if(href_list["show_desc"])
		show_description = text2num(href_list["show_desc"])
		interact(usr)
		
	else if (href_list["dispense_change"])
		dispense_change()
		
	..()


/obj/item/device/illegalradio/proc/generate_main_menu(mob/user)
	var/welcome = pick("Stop wasting bandwidth, buy something already!","Telecrystals ain't cheap, kid. Pay up.","There ain't nothing better than a good deal.","Back in my day, we didn't have 'teleporters'.","Human and Vox slaves NOT accepted as payment.","Absolutely no affiliation with Discount Dan.","Free from Nanotrasen regulation.","Too shy to come in person?","Unaffiliated with Spessmart(TM) supermarts.","Cluck, cluck. We've got no chickens.","What doth the greytide desire?","Wow, shooting spree? How original.","Uwa~ Senpai! Buy my stuff.","Japanese animes tolerated but condemned.","Goods from the TG1153 sector are prohibited. Go away.")

	var/dat = list()
	dat += "<B><font size=5>["The Black Market"]</font></B><BR>"
	dat += "<B>[welcome]</B><BR>"
	dat += {"Cash stored: [src.money_stored]<BR>"}
	dat += {"<A href='byond://?src=\ref[src];dispense_change=1'>Eject Cash</a>
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
		for(var/datum/black_market_item/item in buyable_items[category])
			i++
			var/stock = item.get_stock()
			var/itemcost = item.get_cost()
			var/cost_text = ""
			var/desc = "[item.desc]"
			var/final_text = ""
			cost_text = "([itemcost])"
			if(itemcost <= money_stored && (stock > 0 || stock == -1))
				final_text += "<A href='byond://?src=\ref[src];open_delivery_menu=[url_encode(category)]:[i];'>[item.name]</A> [cost_text] "
			else
				final_text += "<font color='grey'><i>[item.name] [cost_text] </i></font>"
			if(stock != -1)
				final_text += "<font color='grey'><i>([stock] in stock)</i></font>"
			if(item.desc)
				final_text += "<A href='byond://?src=\ref[src];show_desc=2' title='[html_encode(desc)]'><font size=2>\[?\]</font></A>"
			final_text += "<BR>"
			merchandise_list += final_text

		for(var/text in merchandise_list)
			dat += text

		if(buyable_items.len != index)
			dat += "<br>"

	dat += "<HR><font size=3><A href='byond://?src=\ref[src];open_buyers=1'>Open Buyer Menu</a></font>"
	dat = jointext(dat,"") //Optimize BYOND's shittiness by making "dat" actually a list of strings and join it all together afterwards! Yes, I'm serious, this is actually a big deal
	return dat

	
	
/obj/item/device/illegalradio/proc/generate_delivery_menu(mob/user, var/datum/black_market_item/item)
	var/dat = list()
	dat += "<B><font size=5>The Black Market</font></B><BR>"
	dat += "<B>Please pay for an available delivery option.</B><BR>"
	dat += "<B>You are purchasing the [item.name].</B><BR>"
	dat += "Cash stored: [src.money_stored]<BR><BR>"
	var/list/delivery_titles = list("Thrifty","Normal","Express")
	var/list/delivery_description = list("The item is launched at the station from space. We'll give you some clues to where it hit, cheapass.","The item is teleported somewhere in your station's maintenance. You'll get a 60 second headstart and a location.","The item is teleported straight to you via telecrystal.")
	for(var/i = 1 to 3)
		var/fee = item.get_cost()*item.delivery_fees[i]
		var/final_cost = item.get_cost() + fee
		if(item.delivery_available[i])
			if(final_cost <= money_stored)
				dat += "<A href='byond://?src=\ref[src];buy_item=[i]'>[delivery_titles[i]] : [fee] credits.</A>      [final_cost] total."
			else
				dat += "<font color='grey'><i>[delivery_titles[i]] : [fee] credits.</A>     [final_cost] total.</i></font>"
		else
			dat += "<font color='grey'><i>[delivery_titles[i]] : Not available for this product.</i></font>"
		dat += "<A href='byond://?src=\ref[src];show_desc=2' title='[html_encode(delivery_description[i])]'><font size=2> \[?\]</font></A><br>"	

	dat += "<br><HR><font size=3><A href='byond://?src=\ref[src];open_main=1'>Return</a></font>"
	dat = jointext(dat,"") 
	return dat	

	
	
/obj/item/device/illegalradio/proc/generate_buyer_menu(mob/user)
	var/welcome = pick("These payouts are the highest you'll find anywhere!","We do NOT pay in Vox or Human slaves.","Not accepting Nanotrasen requests.","Anonymous has mysterious interests...","Job-bees are not permitted to sell.")

	var/dat = list()
	dat += "<B><font size=5>["The Black Market"]</font></B><BR>"
	dat += "<B>[welcome]</B><BR>"
	dat += {"Cash stored: [src.money_stored]<BR>"}
	dat += {"<A href='byond://?src=\ref[src];dispense_change=1'>Eject Cash</a>   <A href='byond://?src=\ref[src];open_main=1'>Return</a>
		<HR>
		<B>Available Buyers:</B><BR>
		<I>Following is a list of requests from anonymous buyers. To fulfill an item request, use the uplink on the item that is being requested.</I><br><BR>"}
		
	var/list/sellable_items = get_black_market_sellables()
	var/index = 0
	for(var/category in sellable_items)

		index++
		dat += "<b>[category]</b><br>"

		var/merchandise_list = list()

		for(var/datum/black_market_sellable/item in sellable_items[category])
			var/demand = item.get_demand()
			var/final_text = ""
			if(demand > 0)
				final_text += "[item.name] - [item.get_demand()] wanted for [item.get_price()] credits."
			else
				final_text += "<font color='grey'><i>[item.name] - [demand] wanted for [item.get_price()] credits.]</i></font>"
			if(item.desc)
				final_text += "<A href='byond://?src=\ref[src];show_desc=2' title='[html_encode(item.desc)]'><font size=2> \[?\]</font></A>"
			final_text += "<BR>"
			merchandise_list += final_text
		if(!sellable_items[category].len)
			merchandise_list += "<font color='grey'><i>No requests are available at this time from this category.</i></font><BR>"

		for(var/text in merchandise_list)
			dat += text
			
		if(sellable_items.len != index)
			dat += "<br>"

	dat += "<HR><font size=3><A href='byond://?src=\ref[src];open_main=1'>Return</a></font>"
	dat = jointext(dat,"") 
	return dat	


	
	
/obj/item/device/illegalradio/proc/dispense_change()
	if(money_stored > 0)
		dispense_cash(money_stored,get_turf(src))
		money_stored = 0
	interact(usr)

/obj/item/device/illegalradio/afterattack(atom/A as mob|obj, mob/user as mob)
	if(istype(A, /obj/item/weapon/spacecash) && A.Adjacent(user))
		var/obj/item/weapon/spacecash/cash = A
		money_stored += cash.get_total()
		qdel(cash)
		visible_message("<span class='info'>[usr] inserts a credit chip into [src].</span>")
		interact(usr)
	else if((istype(A, /obj) || istype(A, /mob)) && A.Adjacent(user) && !scanning)
		scanning = 1
		attempt_sell(A,usr)
		scanning = 0
			
/obj/item/device/illegalradio/proc/attempt_sell(var/obj/input, mob/user)	//If statements galore
	visible_message("The [name] beeps: <span class='warning'>Scanning item...</span>")
	if(do_after(user, input, scan_time))
		for(var/category in cached_sellables)
			for(var/datum/black_market_sellable/sellable in cached_sellables[category])
				if((sellable.no_children && input.type == sellable.item) || (!sellable.no_children && istype(input,sellable.item)))
					if(!sellable.get_demand())
						visible_message("The [name] beeps: <span class='warning'>Demand for one buyer has been met. Scanning for other buyers...</span>")
						continue
					var/check = sellable.purchase_check(input, user)
					if(check == "VALID")
						visible_message("The [name] beeps: <span class='warning'>Input validated. Please wait for the teleportation process to finish.</warning>")
						if(do_after(user, input, (nanotrasen_variant ? teleport_time : advanced_teleport_time)))
							if(sellable.get_demand())
								var/payout = sellable.determine_payout(input, src)
								sellable.after_sell(input, user)
								qdel(input)
								playsound(src, 'sound/effects/coins.ogg',60, 0)
								visible_message("The [name] beeps: <span class='warning'> Teleportation successful. A total of [payout] credits has been added to your balance.</span>")
								money_stored += payout
								interact(usr)
								if(!nanotrasen_variant && prob(sellable.sps_chance))
									SPS_black_market_alert(src, "The SPS decryption complex has detected an illegal black market selling of item [sellable.name]")
								return 1
						else
							visible_message("The [name] beeps: <span class='warning'>Teleportation process canceled. Please try again.</span>")
							return 0
					else
						visible_message("The [name] beeps: <span class='warning'>Error! Given reason: [check]</span>")	
						return 0
		visible_message("The [name] beeps: <span class='warning'>No buyers are currently looking for this item.</span>")
		return 0
	
/obj/item/device/illegalradio/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/spacecash))
		var/obj/item/weapon/spacecash/C = W
		insert_cash(C, user)
		interact(user)
	
/obj/item/device/illegalradio/emag_act(mob/user)
	visible_message("<span class='warning'>[usr] swipes a card through [src], and it explodes!</warning>")
	explosion(user, -1, 0, 2)
	to_chat(user, "<span class='notice'>You hear a faint laughter in your head.<span>")
	qdel(src)

/obj/item/device/illegalradio/proc/insert_cash(var/obj/item/weapon/spacecash/C, mob/user)
	visible_message("<span class='info'>[usr] inserts a credit chip into [src].</span>")
	money_stored += C.get_total()
	qdel(C)

/obj/item/device/illegalradio/Destroy()
	..()
	money_stored = 0