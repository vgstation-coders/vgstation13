/obj/machinery/computer/trade
	name = "Trade Console"
	desc = "Console used for long-range communication with Shoal traders."
	icon_state = "trade"
	circuit = "/obj/item/weapon/circuitboard/trade"
	var/id_tag = "trade_console"
	var/obj/machinery/trade_telepad/telepad
	var/obj/structure/closet/crate/objective_crate

/obj/machinery/computer/trade/proc/find_crate()
	objective_crate = locate(/obj/structure/closet/crate, telepad.loc)
	return objective_crate

/obj/machinery/computer/trade/proc/trade(var/trade_id)
	if(!can_trade(trade_id))
		return 0

	spark(telepad, 5)
	flick("pad-beam", telepad)

	var/datum/trade/T = trades[trade_id]
	dispense_cash(T.reward, get_turf(src))
	playsound(src, "polaroid", 50, 1)

	qdel(objective_crate)
	remove_trade(trade_id)
	nanomanager.update_uis(src)
	
	return 1

/obj/machinery/computer/trade/proc/can_trade(var/trade_id)
	objective_crate = find_crate()
	var/datum/trade/T = trades[trade_id]
	if(!objective_crate || !T || !telepad)
		return 0

	var/crate_has_objectives = T.check(objective_crate)
	if(!crate_has_objectives)
		return 0

	return 1

/obj/machinery/computer/trade/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return ""

/obj/machinery/computer/trade/canLink(var/obj/T)
	return (istype(T,/obj/machinery/trade_telepad) && get_dist(src,T) < 7)

/obj/machinery/computer/trade/isLinkedWith(var/obj/T)
	return (telepad == T)

/obj/machinery/computer/trade/linkWith(var/mob/user, var/obj/T, var/list/context)
	if(istype(T, /obj/machinery/trade_telepad))
		telepad = T
		telepad.linked = src
		return 1

/obj/machinery/computer/trade/unlinkFrom(mob/user, obj/buffer)
	if(telepad.linked)
		telepad.linked = null
	if(telepad)
		telepad = null
	return 1

/obj/machinery/computer/trade/canClone(var/obj/machinery/T)
	return (istype(T, /obj/machinery/trade_telepad) && get_dist(src, T) < 7)

/obj/machinery/computer/trade/clone(var/obj/machinery/T)
	if(istype(T, /obj/machinery/computer/trade))
		telepad = T
		telepad.linked = src
		return 1

/obj/machinery/computer/trade/Destroy()
	if (telepad)
		telepad.linked = null
		telepad = null
	..()

/obj/machinery/computer/trade/attack_ai(var/mob/user)
	return attack_hand(user)

/obj/machinery/computer/trade/attack_paw(var/mob/user)
	return attack_hand(user)

/obj/machinery/computer/trade/attack_hand(var/mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/trade/proc/format_trades(list/trades)
	var/list/formatted = list()	
	for(var/datum/trade/T in trades)
		formatted.Add(list(list(
			"display" = format_display(T.display),
			"reward" = T.reward,
			"id" = T.id)))		

	return formatted

/obj/machinery/computer/trade/proc/format_display(list/display)
	var/formatted = ""
	var/index = 1
	for(var/line in display)
		formatted += line
		if(index != 1)
			formatted += "<br/>"
		index++

	return formatted

/obj/machinery/computer/trade/ui_interact(mob/user, ui_key="main", datum/nanoui/ui=null, var/force_open=NANOUI_FOCUS)
	user.set_machine(src)

	var/data[0]
	data["src"] = "\ref[src]"
	data["trades"] = format_trades(trades)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "trade_console.tmpl", src.name, 400, 500)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/trade/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["trade"])
		var/trade_id = href_list["trade"]
		if(can_trade(trade_id))
			trade(trade_id)
		else
			to_chat(usr, "<span class='warning'>Cannot execute trade</span>")
		return 1

