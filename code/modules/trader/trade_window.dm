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
	var/merchant_name
	var/datum/trade_product/product_selected = null //targets a datum in the list
	var/category = TRADE_VARIETY
	var/time_last_speech = 0
	var/datum/language/trader_language

/obj/structure/trade_window/New()
	..()
	merchant_name = capitalize("[pick(vox_name_syllables)][pick(vox_name_syllables)] the [capitalize(pick(adjectives))]")
	SStrade.all_twindows += src
	trader_language = new /datum/language/vox

/obj/structure/trade_window/Destroy()
	SStrade.all_twindows -= src
	..()

/obj/structure/trade_window/wrenchable()
	return FALSE

/obj/structure/trade_window/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/spacecash))
		var/obj/item/weapon/spacecash/C = W
		pay_with_cash(C, user)

	/*else if(istype(W, /obj/item/weapon/card) && product_selected)
		//Does not check for linked database because we're not NT
		var/obj/item/weapon/card/C = W
		pay_with_card(C, user)
		updateUsrDialog()*/

/obj/structure/trade_window/proc/pay_with_cash(obj/item/weapon/spacecash/C, mob/user)
	if(user.drop_item(C, loc))
		C.pixel_x = rand(-5,5) * PIXEL_MULTIPLIER
		C.pixel_y = -3 * PIXEL_MULTIPLIER
	/*if(product_selected && credits_held() >= product_selected.current_price(user))
		trade(user)*/
	nanomanager.update_uis(src)

/obj/structure/trade_window/proc/market_flux()
	say("Market flux!")
	nanomanager.update_uis(src)

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

	if(!istype(user))
		say("I don't think I can do business with you.")
		return

	if(user.get_face_name() == "Unknown")
		say(pick(tw_face_not_visible))
		return

	if(!(user.get_face_name() in SStrade.loyal_customers))
		var/datum/organ/external/head/head_organ = user.get_organ(LIMB_HEAD)
		if(head_organ.disfigured)
			say("What the fuck happened to your face? Who are you supposed to be?")
			if(user.real_name in SStrade.loyal_customers)
				say("Oh, it's you, [user.real_name]. Get that hideous thing fixed.")
			else
				return
		else
			say("I don't know you. You want to join up? You need someone to vouch for you.")
			return

	// this is the data which will be sent to the ui
	var/data[0]
	data["selected"] = product_selected
	data["credsheld"] = credits_held()
	data["shoalmoney"] = trader_account.money
	data["shoaldiscount"] = round(100*(SStrade.shoal_prestige_factor()-1))
	if(user.get_face_name() in SStrade.loyal_customers)
		data["pastbusiness"] = SStrade.loyal_customers[user.get_face_name()]
		data["pastdiscount"] = round(100*(SStrade.loyal_customer(user)-1))
	else
		data["pastbusiness"] = 0
		data["pastdiscount"] = "+50"
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
	if(change_money(TP.current_price(user)))
		SStrade.loyal_customers[user.get_face_name()] += TP.current_price(user)
		TP.totalsold++
		var/atom/movable/AM = new TP.path(user.loc)
		if(isitem(AM))
			user.put_in_hands(AM)
		else
			AM.shake(1, 3) //Just a little movement to make it obvious it's here.
		say(pick(tw_sale_generic))
	nanomanager.update_uis(src)

/obj/structure/trade_window/proc/credits_held()
	return count_cash(loc.contents)

/obj/structure/trade_window/proc/change_money(var/price)
	var/total = 0
	var/list/counted_bills = list()
	for(var/obj/item/weapon/spacecash/C in loc.contents)
		counted_bills += C
		total += C.get_total()
		if(total>price)
			break
	if(total < price)
		say("Put some more cash up.")
		return FALSE
	else
		playsound(loc, pick('sound/items/polaroid1.ogg','sound/items/polaroid2.ogg'), 70, 1)
		for(var/obj/O in counted_bills)
			counted_bills -= O
			qdel(O)
		dispense_cash(total-price,loc)
		for(var/obj/item/weapon/spacecash/C in loc)
			C.pixel_x = rand(-5,5) * PIXEL_MULTIPLIER
			C.pixel_y = -3 * PIXEL_MULTIPLIER
	return TRUE

/obj/structure/trade_window/say(var/message)
	//visible_message("<B>[merchant_name]</B> says, \"[message]\"")
	..(message, trader_language)
	if(world.time>time_last_speech+5 SECONDS)
		time_last_speech = world.time
		playsound(loc, pick(voice_vox_sound), 120, 0)

/obj/structure/trade_window/GetVoice()
	return merchant_name