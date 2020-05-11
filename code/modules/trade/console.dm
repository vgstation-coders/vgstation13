/obj/machinery/computer/trade
	name = "Trade Console"
	desc = "Console used for long-range communication with Shoal traders."
	icon_state = "id"	
	circuit = "/obj/item/weapon/circuitboard/trade"
	machine_flags = SCREWTOGGLE | WRENCHMOVE | FIXED2WORK

/obj/machinery/computer/trade/attack_ai(var/mob/user)
	return attack_hand(user)

/obj/machinery/computer/trade/attack_paw(var/mob/user)
	return attack_hand(user)

/obj/machinery/computer/trade/attack_hand(var/mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/trade/ui_interact(mob/user, ui_key="main", datum/nanoui/ui=null, var/force_open=NANOUI_FOCUS)
	user.set_machine(src)

	var/data[0]
	data["src"] = "\ref[src]"

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "trade_console.tmpl", src.name, 800, 700)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/trade/Topic(href, href_list)
	if(..())
		return 1