//WIP note - dont forget the coin modules
//maybe coins induce market flux?

/obj/structure/trade_window
	name = "Trade Window"
	desc = "Where you stock up on goods to sell at a markup."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "trade_window"
	req_access = list(access_trade)
	anchored = TRUE
	density = TRUE
	var/datum/trade_product/product_selected = null //targets a datum in the list
	var/category = TRADE_VARIETY

/obj/structure/trade_window/New()
	..()
	SStrade.all_twindows += src

/obj/structure/trade_window/Destroy()
	SStrade.all_twindows -= src
	..()

/obj/structure/trade_window/wrenchable()
	return FALSE

/obj/structure/trade_window/attackby(obj/item/W, mob/user)
	..()
	if(!anchored)
		return
	if(istype(W, /obj/item/weapon/spacecash))
		var/obj/item/weapon/spacecash/C = W
		pay_with_cash(C, user)

	/*else if(istype(W, /obj/item/weapon/card) && product_selected)
		//Does not check for linked database because we're not NT
		var/obj/item/weapon/card/C = W
		pay_with_card(C, user)
		updateUsrDialog()*/

/obj/structure/trade_window/proc/pay_with_cash(obj/item/weapon/spacecash/C, mob/user)
	if(user.drop_item(C, src))
		vis_contents += C
		C.pixel_x = rand(-5,5) * PIXEL_MULTIPLIER
		C.pixel_y = -3 * PIXEL_MULTIPLIER
	if(credits_held() >= product_selected.current_price(user))
		trade(user)
		product_selected = null
		updateUsrDialog()

/obj/structure/trade_window/proc/market_flux()
	visible_message("Market flux!")

/obj/structure/trade_window/attack_hand(mob/user)
	if(!isobserver(user) && (!Adjacent(user) || user.incapacitated()))
		return
	ui_interact(user)

/obj/structure/trade_window/ui_interact(mob/living/carbon/human/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	if (gcDestroyed || !get_turf(src) || !anchored)
		if(!ui)
			ui = nanomanager.get_open_ui(user, src, ui_key)
		if(ui)
			ui.close()
		return

	if(!istype(user) || user.get_face_name() == "Unknown")
		say("I don't talk to anyone whose face I can't see.")
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["selected"] = product_selected
	data["credsheld"] = credits_held()
	data["shoalmoney"] = trader_account.money
	if(user.get_face_name() in SStrade.loyal_customers)
		data["pastbusiness"] = SStrade.loyal_customers[user.get_face_name()]
	else
		data["pastbusiness"] = 0
	data["selectedCategory"] = category
	data["categories"] = list(list("category" = TRADE_SINGLE), list("category" = TRADE_VARIETY))
	SStrade.rebuild_databank(user)
	data["databank"] = SStrade.trade_databank //datums converted to a list of lists for the UI

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "tradewindow.tmpl", "Trade Window", 520, 460)
		ui.set_initial_data(data)
		ui.open()

/obj/structure/trade_window/Topic(href, href_list)
	if(..())
		return
	if(usr.incapacitated() || (!Adjacent(usr)&&!isAdminGhost(usr)) || !usr.dexterity_check())
		return
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/H = usr
	if(!(H.get_face_name() in SStrade.loyal_customers))
		say("I don't know you!")
		return
	if(href_list["product"])
		locate_data(href_list["product"], usr) //Even though the list contains a path, hrefs only pass text so let's use name here instead of path
	if(href_list["category"])
		category = href_list["category"]
	update_icon()
	return 1

/obj/structure/trade_window/proc/locate_data(var/product_name, mob/user)
	for(var/datum/trade_product/TP in SStrade.all_trade_merch)
		if(TP.name == product_name)
			product_selected = TP
			trade(user)
			return

/obj/structure/trade_window/proc/trade(mob/living/carbon/human/user, var/datum/trade_product/TP)
	if(!TP)
		if(product_selected)
			TP = product_selected
		else
			say("Buy what?")
			return
	if(change_money(TP.current_price()))
		SStrade.loyal_customers[user.get_face_name()] += TP.current_price(user)
		TP.totalsold++
		new TP.path(user.loc)
	nanomanager.update_uis(src)

/obj/structure/trade_window/proc/credits_held()
	return count_cash(vis_contents)

/obj/structure/trade_window/proc/change_money(var/price)
	var/total = 0
	var/list/counted_bills = list()
	for(var/obj/item/weapon/spacecash/C in vis_contents)
		counted_bills += C
		total += C.get_total()
		if(total>price)
			break
	if(total < price)
		say("Put some more cash up.")
		return FALSE
	else
		for(var/obj/O in counted_bills)
			qdel(O)
		dispense_cash(total-price,loc)
		for(var/obj/item/weapon/spacecash/C in loc)
			vis_contents += C
			C.pixel_x = rand(-5,5) * PIXEL_MULTIPLIER
			C.pixel_y = -3 * PIXEL_MULTIPLIER
	return TRUE

/obj/structure/trade_window/say(var/message)
	visible_message(message)