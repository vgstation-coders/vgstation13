/obj/machinery/computer/pda_terminal
	name = "\improper PDA Terminal"
	desc = "It can be used to download Apps on your PDA."
	icon_state = "pdaterm"
	circuit = "/obj/item/weapon/circuitboard/pda_terminal"
	light_color = LIGHT_COLOR_ORANGE

	var/obj/item/device/pda/pda_device = null
	var/machine_id = ""

	machine_flags = EMAGGABLE | SCREWTOGGLE | WRENCHMOVE | FIXED2WORK | MULTITOOL_MENU | PURCHASER

/obj/machinery/computer/pda_terminal/New()
	..()
	machine_id = "[station_name()] PDA Terminal #[multinum_display(num_pda_terminals,4)]"
	num_pda_terminals++

	if(ticker)
		initialize()

/obj/machinery/computer/pda_terminal/proc/format_apps(var/obj/item/device/pda/pda_hardware)//makes a list of all the apps that aren't yet installed on the PDA
	if(!istype(pda_hardware))
		return list()

	var/list/formatted = list()

	var/list/notinstalled = list()

	for(var/app in (typesof(/datum/pda_app) - /datum/pda_app))
		if(!(locate(app) in pda_hardware.applications))
			notinstalled += app

	for(var/app in notinstalled)
		var/datum/pda_app/appli = new app()
		formatted.Add(list(list(
			"app" = get_app_name(appli),
			"app_name" = get_display_name(appli),
			"app_desc" = get_display_desc(appli),
			)))

	return formatted

/obj/machinery/computer/pda_terminal/proc/get_app_name(var/datum/pda_app/app)
	return "[app.name]"

/obj/machinery/computer/pda_terminal/proc/get_display_name(var/datum/pda_app/app)
	return "[app.name] ([!(app.price) ? "free" : "[app.price]$"])"

/obj/machinery/computer/pda_terminal/proc/get_display_desc(var/datum/pda_app/app)
	return "[app.desc]"

/obj/machinery/computer/pda_terminal/attackby(obj/item/device/pda/user_pda, mob/user)
	if(!istype(user_pda))
		return ..()

	if(!pda_device)
		if(user.drop_item(user_pda, src))
			pda_device = user_pda
			update_icon()

	nanomanager.update_uis(src)
	attack_hand(user)

/obj/machinery/computer/pda_terminal/attack_ai(var/mob/user)
	return attack_hand(user)

/obj/machinery/computer/pda_terminal/attack_paw(var/mob/user)
	return attack_hand(user)

/obj/machinery/computer/pda_terminal/attack_hand(var/mob/user)
	if(..())
		return
	if(stat != 0)
		if(pda_device)
			to_chat(usr, "You remove \the [pda_device] from \the [src].")
			pda_device.forceMove(get_turf(src))
			if(!usr.get_active_hand())
				usr.put_in_hands(pda_device)
			pda_device = null
			update_icon()
		else
			to_chat(usr, "There is nothing to remove from the console.")
		return

	ui_interact(user)

/obj/machinery/computer/pda_terminal/ui_interact(mob/user, ui_key="main", datum/nanoui/ui=null, var/force_open=NANOUI_FOCUS)
	user.set_machine(src)

	var/data[0]
	data["src"] = "\ref[src]"
	data["pda_name"] = pda_device ? pda_device.name : "-----"
	data["pda_owner"] = pda_device && pda_device.owner ? pda_device.owner : "Unknown"
	data["has_pda_device"] = !!pda_device
	data["pda_apps"] = format_apps(pda_device)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "pda_terminal.tmpl", src.name, 800, 700)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/pda_terminal/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()
		return 1
	switch(href_list["choice"])
		if ("pda_device")
			if (pda_device)
				if(ishuman(usr))
					pda_device.forceMove(usr.loc)
					if(!usr.get_active_hand())
						usr.put_in_hands(pda_device)
					pda_device = null
				else
					pda_device.forceMove(loc)
					pda_device = null
			else
				var/obj/item/I = usr.get_active_hand()
				if (istype(I, /obj/item/device/pda))
					if(usr.drop_item(I, src))
						pda_device = I
			update_icon()

		if ("purchase")
			if (pda_device)
				var/app_name = href_list["chosen_app"]

				var/datum/pda_app/appdatum

				for(var/app in typesof(/datum/pda_app))
					var/datum/pda_app/A = new app
					if(A.name == app_name)
						appdatum = A
						break

				if(!appdatum)
					to_chat(usr, "[bicon(src)]<span class='warning'>An error occured while trying to download: \"[app_name]\"</span>")
					flick("pdaterm-problem", src)
					return

				if(istype(usr, /mob/living))
					var/obj/item/weapon/card/card = usr.get_card()

					if(!card && pda_device)
						card = pda_device.id

					if(card)
						if (connect_account(usr,card,appdatum))
							appdatum.onInstall(pda_device)
							to_chat(usr, "[bicon(pda_device)]<span class='notice'>Application successfully downloaded!</span>")
							flick("pdaterm-purchase", src)
						else
							flick("pdaterm-problem", src)
					else
						to_chat(usr, "[bicon(src)]<span class='warning'>No ID detected. Cannot proceed with the purchase.</span>")
						flick("pdaterm-problem", src)

		if ("new_pda")
			if(istype(usr, /mob/living))
				var/obj/item/weapon/card/card = usr.get_card()

				if(!card && pda_device)
					card = pda_device.id

				if(card)
					if (connect_account(usr,card,0))
						to_chat(usr, "[bicon(src)]<span class='notice'>Enjoy your new PDA!</span>")
						flick("pdaterm-purchase", src)
						if(prob(10))
							new /obj/item/device/pda/clear(src.loc)//inserting mandatory hidden feature.
						else
							new /obj/item/device/pda(src.loc)
					else
						flick("pdaterm-problem", src)
				else
					to_chat(usr, "[bicon(src)]<span class='warning'>No ID detected. Cannot proceed with the purchase.</span>")
					flick("pdaterm-problem", src)
	return 1

/obj/machinery/computer/pda_terminal/connect_account(var/mob/user,var/obj/item/weapon/card/W,var/appdatum)
	if(istype(W))
		//attempt to connect to a new db, and if that doesn't work then fail
		if(!linked_db)
			reconnect_database()
		if(linked_db)
			if(linked_account)
				return	scan_card(user,W,appdatum)
			else
				to_chat(user, "[bicon(src)]<span class='warning'>Unable to connect to linked account.</span>")
		else
			to_chat(user, "[bicon(src)]<span class='warning'>Unable to connect to accounts database.</span>")
	return	0

/obj/machinery/computer/pda_terminal/scan_card(var/mob/user,var/obj/item/weapon/card/C,var/datum/pda_app/appdatum)
	if(istype(C))
		if(linked_account)
			if(charge_flow(linked_db, C, user, (appdatum ? appdatum.price : 100) /* New PDA if no appdatum */, linked_account, "Purchase of [appdatum ? "[appdatum.name]" : "a new PDA"]", machine_id) != CARD_CAPTURE_SUCCESS)
				return 0
			return 1
		else
			to_chat(usr, "[bicon(src)]<span class='warning'>EFTPOS is not connected to an account.</span>")
			return 0

/obj/machinery/computer/pda_terminal/update_icon()
	..()
	overlays = 0
	if(pda_device)
		overlays += image(icon = icon, icon_state = "pdaterm-full")
		if(stat == 0)
			overlays += image(icon = icon, icon_state = "pdaterm-light")
