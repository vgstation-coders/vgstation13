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
	
	var/money_stored		        // Money placed in the buffer
	// List of items not to shove in their hands.
	var/list/purchase_log = list()
	var/show_description = null
	var/active = 0
	var/job = null
	
/obj/item/device/illegalradio/New()
	..()
	if(ticker)
		initialize()
		return

/obj/item/device/illegalradio/initialize()
	if(ticker.mode)
		money_stored = 0
		
/obj/item/device/illegalradio/interact(mob/user as mob)
	var/dat = "<body link='yellow' alink='white' bgcolor='#331461'><font color='white'>"
	dat += src.generate_menu(user)
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
		
	else if (href_list["dispense_change"])
		dispense_change()

		
/obj/item/device/illegalradio/proc/generate_menu(mob/user as mob)
	
	var/welcome = pick("Stop wasting bandwidth, buy something already!","Telecrystals ain't cheap, kid. Pay up.","There ain't nothing better than a good deal.","Back in my day, we didn't have 'teleporters'.","Human and Vox slaves NOT accepted as payment.","Absolutely no affiliation with Discount Dan.")

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
				final_text += "<A href='byond://?src=\ref[src];buy_item=[url_encode(category)]:[i];'>[item.name]</A> [cost_text] "
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

		// Break up the categories, if it isn't the last.
		if(buyable_items.len != index)
			dat += "<br>"

	dat += "<HR>"
	dat = jointext(dat,"") //Optimize BYOND's shittiness by making "dat" actually a list of strings and join it all together afterwards! Yes, I'm serious, this is actually a big deal
	return dat
	
/obj/item/device/illegalradio/proc/dispense_change()
	if(money_stored > 0)
		dispense_cash(money_stored,get_turf(src))
		money_stored = 0
	interact(usr)
	
/obj/item/device/illegalradio/afterattack(atom/A as mob|obj, mob/user as mob)
	if(istype(A, /obj/item/weapon/spacecash))
		var/obj/item/weapon/spacecash/cash = A
		money_stored += cash.get_total()
		qdel(cash)
		visible_message("<span class='info'>[usr] inserts a credit chip into [src].</span>")
		interact(usr)
			
/obj/item/device/illegalradio/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/spacecash))
		var/obj/item/weapon/spacecash/C = W
		insert_cash(C, user)
		interact(user)
	else if(istype(W, /obj/item/weapon/card/emag))
		visible_message("<span class='warning'>[usr] swipes a card through [src], and it explodes!</warning>")
		explosion(user, -1, 0, 2)
		to_chat(user, "<span class='notice'>You hear a faint laughter in your head.<span>")	
		qdel(src)
	else if(istype(W, /obj/item/organ/external))
		visible_message("<span class='info'>The black market uplink buzzes: \"We take organs, not limbs, dummy.\"</span>")
	else if(istype(W, /obj/item/organ/internal))
		var/obj/item/organ/internal/organ = W
		if(organ.had_mind && !organ.is_printed && !organ.robotic) //We want da real stuff
			var/price = rand(200,300)
			visible_message("<span class='info'>The black market uplink buzzes: \"You have been paid [price] credits. Thank you for your business!\"</span>")
			money_stored += price
			qdel(W)
		else
			visible_message("<span class='info'>The black market uplink buzzes: \"Sorry, pal. That organ ain't real. Our buyers want natural ones.\"</span>")
	
/obj/item/device/illegalradio/proc/insert_cash(var/obj/item/weapon/spacecash/C, mob/user)
	visible_message("<span class='info'>[usr] inserts a credit chip into [src].</span>")
	money_stored += C.get_total()
	qdel(C)
		
/obj/item/device/illegalradio/Destroy()
	..()
	money_stored = 0