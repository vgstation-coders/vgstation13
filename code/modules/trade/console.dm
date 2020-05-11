/obj/machinery/computer/trade
	name = "Trade Console"
	desc = "Console used for long-range communication with Shoal traders."
	icon_state = "trade"
	circuit = "/obj/item/weapon/circuitboard/trade"
	machine_flags = SCREWTOGGLE | WRENCHMOVE | FIXED2WORK | MULTITOOL_MENU
	var/obj/machinery/trade_telepad/telepad

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