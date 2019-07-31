

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

	var/list/purchase_log = list()
	var/datum/black_market_item/selected_item = null
	var/datum/black_market_player_item/new_listing = null
	
	var/money_stored
	var/market_cut = 0.2
	var/advanced_uplink = 0
	var/scan_time = 20
	
	var/scanning = 0
	
/obj/item/device/illegalradio/advanced
	name = "advanced black market uplink"
	icon_state = "illegalradio_adv"
	item_state = "illegalradio_adv"
	desc = "If there's one thing you can always trust a Vox will do, it's getting his money's worth."
	advanced_uplink = 1
	
/obj/item/device/illegalradio/New()
	..()
	money_stored = 0

/obj/item/device/illegalradio/interact(mob/user as mob) //Whenever called, return to main menu.
	selected_item = null
	new_listing = null
	open_html(src.generate_main_menu(user))
	return

/obj/item/device/illegalradio/attack_self(mob/user as mob)
	user.set_machine(src)
	interact(user)

	

/obj/item/device/illegalradio/Topic(href, href_list)
	..()
	
	if(href_list["open_main"])
		interact(usr)
		
	else if(href_list["show_desc"])
		//show_description = text2num(href_list["show_desc"])
		//interact(usr)	
		
	else if (href_list["dispense_change"])
		dispense_change()	
		
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
					open_html(generate_delivery_menu(usr,item))
					return
					
	else if(href_list["buy_item"])
		var/delivery_method = href_list["buy_item"]	
		delivery_method = text2num(delivery_method)
		selected_item.buy(src, delivery_method, usr)
		selected_item = null
		interact(usr)

	else if(href_list["buy_local_item"])
		var/input = href_list["open_local_delivery_menu"]
		var/list/split = splittext(input, ":")

		if(split.len == 2)
			var/category = split[1]
			var/number = text2num(split[2])
			if(player_market_items[number])
				var/datum/black_market_player_item/item = player_market_items[number]
				if(item)
					selected_item = item
					//open_html(generate_delivery_menu(usr,item))
					return
		
	else if(href_list["open_local_market_hub"])
		open_html(generate_local_market_hub(usr))

	else if(href_list["local_market_input_price"])
		var/price = input("Enter your desired price.", "Price", new_listing ? new_listing.selected_price : 0) as num
		if(!price || !new_listing)
			return
		new_listing.selected_price = price
		open_html(generate_local_market_hub(usr))
		
	else if(href_list["local_market_input_name"])
		var/name = input("Enter your desired name.", "Name", new_listing ? "[new_listing.selected_name]" : "N/A") as text
		if(!name || !new_listing)
			return
		new_listing.selected_name = name
		open_html(generate_local_market_hub(usr))
		
	else if(href_list["local_market_input_desc"])
		var/desc = input("Enter your desired description", "Description", new_listing ? "[new_listing.selected_description]" : "N/A") as text
		if(!desc || !new_listing)
			return
		new_listing.selected_description = desc
		open_html(generate_local_market_hub(usr))	
		
	else if(href_list["local_market_confirm_listing"])
		if(new_listing)
			player_market_items += new_listing
			new_listing = null
		else
			visible_message("The [src] beeps: <span class='warning'>There was an unexpected error! Try again.</span>")	
		interact(usr)
		
	..()


/obj/item/device/illegalradio/proc/generate_main_menu(mob/user)
	var/welcome = pick("Stop wasting bandwidth, buy something already!","Telecrystals ain't cheap, kid. Pay up.","There ain't nothing better than a good deal.","Back in my day, we didn't have 'teleporters'.","Human and Vox slaves NOT accepted as payment.","Absolutely no affiliation with Discount Dan.","Free from Nanotrasen regulation.","Too shy to come in person?","Unaffiliated with Spessmart(TM) supermarts.","Cluck, cluck. We've got no chickens.","What doth the greytide desire?","Wow, shooting spree? How original.","Uwa~ Senpai! Buy my stuff.","Japanese animes tolerated but condemned.","Goods from the TG1153 sector are prohibited. Go away.")

	var/dat = list()
	
	//First, generate the header.
	dat += "<B><font size=5>The Black Market</font></B><BR>"
	dat += "<B>[welcome]</B><BR>"
	dat += "Cash stored: [src.money_stored]<BR>"
	dat += "<A href='byond://?src=\ref[src];dispense_change=1'>Eject Cash</a> <A href='byond://?src=\ref[src];open_local_market_hub=1'>Sell Item</a>"
	dat += "<HR>"
	dat += "<B>Request item:</B><BR>"
	dat += "<I>Each item costs the price that follows its name. Cash only.</I><br><BR>"
	var/list/buyable_items = get_black_market_items()
	
	//Next, create the player market entries at the top.
	dat += "<b>Locally Sourced Goods</b><br>"
	if(!player_market_items.len)
		dat += "<font color='grey'><i>There are no items sourced from your station right now.</i></font>"
	else
		var/iterator = 0
		var/merchandise_list = list()
		for(var/datum/black_market_item/item in player_market_items)
			iterator++
			var/stock = item.get_stock()
			var/itemcost = item.get_cost()
			var/cost_text = ""
			var/desc = "[item.desc]"
			var/final_text = ""
			cost_text = "([itemcost])"
			if(itemcost <= money_stored && (stock > 0 || stock == -1))
				final_text += "<A href='byond://?src=\ref[src];open_local_delivery_menu=[iterator];'>[item.name]</A> [cost_text] "
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
			
	//Then, loop through the round-spawn entries.
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

	dat = jointext(dat,"")
	return dat

/obj/item/device/illegalradio/proc/generate_local_market_hub(mob/user)
	var/dat = list()
	if(!new_listing)
		dat += "<B><font size=5>The Black Market</font></B><BR>"
		dat += "<B>Welcome to the Local Market hub.</B><BR>"
		dat += "<B>A [market_cut*100]% fee will be applied to all transactions.</B><BR>"
		dat += "<A href='byond://?src=\ref[src];open_main=1'>Return</a>"
		dat = jointext(dat,"")
	else
		dat += "<B><font size=5>The Black Market</font></B><BR>"
		dat += "<B>Item verified. Please complete your listing.</B><BR>"
		dat += "<B>A [market_cut*100]% fee will be applied to all transactions.</B><BR>"
		dat += "<A href='byond://?src=\ref[src];open_main=1'>Return</a>"
		dat += "<BR><HR><BR>"
		dat += "Display Name: <A href='byond://?src=\ref[src];local_market_input_name=1'>[new_listing.selected_name]</a><br>"
		dat += "Price: <A href='byond://?src=\ref[src];local_market_input_price=1'>[new_listing.selected_price]</a><br>"
		dat += "Description: <A href='byond://?src=\ref[src];local_market_input_desc=1'>[new_listing.selected_description]</a><br>"
		dat += "<B><A href='byond://?src=\ref[src];local_market_confirm_listing=1'>Confirm Listing</a></B><br>"
		dat = jointext(dat,"")
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

		
		
		
		
/obj/item/device/illegalradio/proc/generate_new_local_listing(atom/target)
	new_listing = new /datum/black_market_player_item()
	new_listing.item = target
	new_listing.selected_name = "[target]"
	new_listing.seller_radio = src
	open_html(generate_local_market_hub(usr))
		
/obj/item/device/illegalradio/afterattack(atom/A as mob|obj, mob/user as mob)
	if(istype(A, /obj/item/weapon/spacecash) && A.Adjacent(user))
		var/obj/item/weapon/spacecash/cash = A
		money_stored += cash.get_total()
		qdel(cash)
		visible_message("<span class='info'>[usr] inserts a credit chip into [src].</span>")
		interact(usr)
	else if((istype(A, /obj) || istype(A, /mob)) && A.Adjacent(user) && !scanning)
		visible_message("The [name] beeps: <span class='warning'>Scanning item...</span>")
		scanning = 1
		if(do_after(user, A, scan_time))
			generate_new_local_listing(A)
		scanning = 0				

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

/obj/item/device/illegalradio/proc/dispense_change()
	if(money_stored > 0)
		dispense_cash(money_stored,get_turf(src))
		money_stored = 0
	interact(usr)
	
/obj/item/device/illegalradio/proc/open_html(var/dat_input)
	var/dat = "<body link='yellow' alink='white' bgcolor='#331461'><font color='white'>"
	dat += dat_input
	dat += "</body></font>"
	usr << browse(dat, "window=hidden")
	onclose(usr, "hidden")	
	
/obj/item/device/illegalradio/Destroy()
	..()
	money_stored = 0
	