/obj/machinery/trade_telepad
	name = "trade telepad"
	desc = "A bluespace telepad used for teleporting objects to and from the Shoal."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"
	anchored = 1
	use_power = 1
	idle_power_usage = 200
	active_power_usage = 5000
	machine_flags = MULTITOOL_MENU | WRENCHMOVE
	var/id_tag = "trade_telepad"
	var/obj/machinery/computer/trade/linked

/obj/machinery/trade_telepad/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return ""

/obj/machinery/trade_telepad/canLink(var/obj/T)
	return (istype(T,/obj/machinery/computer/trade) && get_dist(src,T) < 7)

/obj/machinery/trade_telepad/isLinkedWith(var/obj/T)
	return (linked == T)

/obj/machinery/trade_telepad/linkWith(var/mob/user, var/obj/T, var/list/context)
	if(istype(T, /obj/machinery/computer/trade))
		linked = T
		linked.telepad = src
		return 1

/obj/machinery/trade_telepad/unlinkFrom(mob/user, obj/buffer)
	if(linked.telepad)
		linked.telepad = null
	if(linked)
		linked = null
	return 1

/obj/machinery/trade_telepad/canClone(var/obj/machinery/T)
	return (istype(T, /obj/machinery/computer/trade) && get_dist(src, T) < 7)

/obj/machinery/trade_telepad/clone(var/obj/machinery/T)
	if(istype(T, /obj/machinery/computer/trade))
		linked = T
		linked.telepad = src
		return 1

/obj/machinery/trade_telepad/Destroy()
	if (linked)
		linked.telepad = null
		linked = null
	..()