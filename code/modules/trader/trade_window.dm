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
	var/list/last_greeted = list()
	var/closed = FALSE //closes if atmos fails

/obj/structure/trade_window/New()
	..()
	merchant_name = capitalize("[pick(vox_name_syllables)][pick(vox_name_syllables)] the [capitalize(pick(adjectives))]")
	SStrade.all_twindows += src
	processing_objects += src
	trader_language = new /datum/language/vox

/obj/structure/trade_window/Destroy()
	SStrade.all_twindows -= src
	processing_objects -= src
	..()

/obj/structure/trade_window/ex_act()
	return

/obj/structure/trade_window/blob_act()
	return

/obj/structure/trade_window/examine(mob/user)
	..()
	if(closed)
		to_chat(user, "<span class='warning'>It's closed due to the bad atmosphere.</span>")

/obj/structure/trade_window/process()
	var/turf/T = get_turf(src)
	if(T && !T.c_airblock(T)) //we are on an airflowing tile with pressure between 80 and 180
		var/datum/gas_mixture/current_air = T.return_air()
		var/pressure = current_air.return_pressure()
		if(pressure <= 180 && pressure >= 80)
			if(closed)
				say("That's more like it. Opening shop back up.")
			closed = FALSE
			update_icon()
			return
	if(!closed)
		say("Eck! Closing up!")
	closed = TRUE
	update_icon()

/obj/structure/trade_window/update_icon()
	icon_state = "trade_window[closed ? "-closed" : ""]"

/obj/structure/trade_window/attackby(obj/item/W, mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(istype(W, /obj/item/weapon/spacecash))
		var/obj/item/weapon/spacecash/C = W
		pay_with_cash(C, user)

	if(istype(W, /obj/item/weapon/card/id/vox/extra) && !(user.get_face_name() in SStrade.loyal_customers))
		if(user.get_face_name() == "Unknown")
			say("Show it to me again, but this time without your face covered.")
		else
			say("Good. Now let me see...")
			var/obj/item/weapon/card/id/vox/extra/E = W
			if(E.canSet)
				say("You haven't set the name on here. I'll help with that.")
				E.registered_name = user.get_face_name()
				E.name = "[E.registered_name]'s ID card ([E.assignment])"
				E.canSet = FALSE
			else
				if(E.registered_name == user.get_face_name())
					say("Okay, this all matches -- I'll get your paperwork.")
				else
					say("This isn't your card. Name doesn't match. Sorry, can't help you.")
					return
			//Haven't exited because of an invalid card.
			var/obj/TA = new /obj/item/weapon/paper/traderapplication(loc, user.get_face_name())
			TA.pixel_x = rand(-5,5) * PIXEL_MULTIPLIER
			TA.pixel_y = -3 * PIXEL_MULTIPLIER
			TA.shake(1,3)
			playsound(TA, "pageturn", 50, 1)

	if(istype(W,/obj/item/weapon/paper/traderapplication))
		var/obj/item/weapon/paper/traderapplication/P = W
		if(findtext(P.stamps,"inkpad"))
			if(!(user.get_face_name() in SStrade.loyal_customers))
				say("So who's vouching for you? I want it from them.")
			else
				say("Well, that settles it then. [user.get_face_name()], [P.applicant] is your responsibility.")
				SStrade.loyal_customers[P.applicant] = 0
		else
			say("Go on, get that stamped.")

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
	say(pick(tw_market_flux))
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
		if(ismonkey(user))
			say("Just a sprout. Come back when you're bigger.")
		else
			say("I don't think I can do business with you.")
		return

	if(user.get_face_name() == "Unknown")
		var/datum/organ/external/head/head_organ = user.get_organ(LIMB_HEAD)
		if(head_organ.disfigured)
			say("What the fuck happened to your face? Who are you supposed to be?")
			if(user.real_name in SStrade.loyal_customers)
				say("Oh, it's you, [user.real_name]. Get that hideous thing fixed.")
			else
				return
		else
			say(pick(tw_face_not_visible))
			return

	if(!(user.get_face_name() in SStrade.loyal_customers))
		say("I don't know you. You want to join up? You need someone to vouch for you. Bring a fresh ID and an inkpad to my table when you do.")
		return
	else
		greet(user)

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
	if(closed)
		return
	if(usr.incapacitated() || (!Adjacent(usr)&&!isAdminGhost(usr)) || !usr.dexterity_check())
		return
	if(!ishuman(usr)&&!isAdminGhost(usr))
		return
	var/mob/living/carbon/human/H = usr
	if(!(H.get_face_name() in SStrade.loyal_customers) && !isAdminGhost(usr))
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
	if(isAdminGhost(user))
		say(pick("Keh, freebie. Someone likes you.", "Word from top, something free.", "Eh, for you, take it.", "This one, free."))
		TP.totalsold++
		new TP.path(loc)
		flick("trade_sold",src)
		nanomanager.update_uis(src)
		return
	var/saleslines = tw_sale_generic.Copy()
	if(TP.current_price(user) >= 200)
		saleslines += tw_sale_expensive
	if(TP.flux_rate <= 0.85)
		saleslines += tw_sale_good_deal
	if(change_money(TP.current_price(user)))
		SStrade.loyal_customers[user.get_face_name()] += TP.current_price(user)
		TP.totalsold++
		var/atom/movable/AM = new TP.path(user.loc)
		if(isitem(AM))
			user.put_in_hands(AM)
		else
			AM.shake(1, 3) //Just a little movement to make it obvious it's here.

		say(pick(saleslines))
		flick("trade_sold",src)
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