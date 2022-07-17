/obj/item/weapon/circuitboard/merch
	name = "\improper Merchandise Computer Circuitboard"
	build_path = /obj/machinery/computer/merch

/obj/machinery/computer/merch
	name = "Merch Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "store"
	circuit = "/obj/item/weapon/circuitboard/merch"
	var/machine_id = ""
	machine_flags = EMAGGABLE | SCREWTOGGLE | WRENCHMOVE | FIXED2WORK | MULTITOOL_MENU | PURCHASER
	light_color = LIGHT_COLOR_ORANGE

/obj/machinery/computer/merch/New()
	..()
	machine_id = "[station_name()] Merch Computer #[multinum_display(num_merch_computers,4)]"
	num_merch_computers++

/obj/machinery/computer/merch/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	tgui_interact(user)

/obj/machinery/computer/merch/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Merch")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/computer/merch/ui_data(mob/user)
	var/list/data = list()
	for(var/category in centcomm_store.items)
		var/list/cat = list(
			"name" = category,
			"items" = list()
		)
		var/list/items = centcomm_store.items[category]
		for(var/datum/storeitem/item in items)
			if(!item.available_to_user(user))
				continue
			cat["items"] += list(list(
				"name" = item.name,
				"cost" = item.cost,
				"desc" = item.desc,
				"stock" = item.stock,
				"path" = replacetext(replacetext("[item.typepath]", "/obj/item/", ""), "/", "-")
			))
		if(!length(cat["items"]))
			continue
		data["categories"] += list(cat)
	return data

/obj/machinery/computer/merch/ui_assets()
	return list(/datum/asset/spritesheet/merch)

/obj/machinery/computer/merch/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("buy")
			if(!centcomm_store.PlaceOrder(usr, params["name"], src))
				to_chat(usr, "[bicon(src)]<span class='warning'>Unable to charge your account.</span>")
			else
				to_chat(usr, "[bicon(src)]<span class='notice'>Transaction complete! Enjoy your product.</span>")
			return TRUE

/obj/machinery/computer/merch/update_icon()
	if(stat & BROKEN)
		icon_state = "comm_logsb"
	else if(stat & (FORCEDISABLE|NOPOWER))
		icon_state = "comm_logs0"
	else
		icon_state = initial(icon_state)
