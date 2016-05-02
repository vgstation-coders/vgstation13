obj/machinery/recharger/defibcharger/wallcharger // obj/machinery/recharger/defibcharger define doesn't exist, don't bother trying to look for it
	name = "defibrillator recharger"
	desc = "A special wall mounted recharger meant for emergency defibrillators"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "wrecharger0"
	anchored = 1
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 150

	machine_flags = SCREWTOGGLE | CROWDESTROY //| WRENCHMOVE | FIXED2WORK if we want it to be wrenchable

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/recharger/defibcharger/wallcharger/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/defib_recharger,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

obj/machinery/recharger/defibcharger/wallcharger/attack_hand(mob/user as mob)
	add_fingerprint(user)

	if(charging)
		charging.update_icon()
		charging.loc = loc
		charging = null
		use_power = 1
		update_icon()

obj/machinery/recharger/defibcharger/wallcharger/attack_paw(mob/user as mob)
	return attack_hand(user)

obj/machinery/recharger/defibcharger/wallcharger/emp_act(severity)
	if(stat & (NOPOWER|BROKEN) || !anchored)
		..(severity)
		return

	if(istype(charging, /obj/item/weapon/melee/defibrillator))
		var/obj/item/weapon/melee/defibrillator/B = charging
		B.charges = 0
	..(severity)

obj/machinery/recharger/defibcharger/wallcharger/update_icon()	//we have an update_icon() in addition to the stuff in process to make it feel a tiny bit snappier.
	if(charging)
		icon_state = "wrecharger1"
	else
		icon_state = "wrecharger0"



obj/machinery/recharger/defibcharger/wallcharger/process()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		return

	if(charging)
		if(istype(charging, /obj/item/weapon/melee/defibrillator))
			var/obj/item/weapon/melee/defibrillator/B = charging
			if(B.charges < initial(B.charges))
				B.charges++
				icon_state = "wrecharger1"
				use_power(150)
			else
				icon_state = "wrecharger2"

/obj/machinery/recharger/defibcharger/wallcharger/togglePanelOpen(var/obj/toggleitem, var/mob/user)
	if(charging)
		to_chat(user, "<span class='warning'>Not while [src] is charging!</span>")
		return
	return(..())

/obj/machinery/recharger/defibcharger/wallcharger/crowbarDestroy()
	if(..() == 1)
		if(charging)
			charging.forceMove(src.loc)
			charging = null
		return 1
	return -1

obj/machinery/recharger/defibcharger/wallcharger/attackby(obj/item/weapon/G as obj, mob/user as mob)
	if(istype(G, /obj/item/weapon/melee/defibrillator))
		if(..())
			return
		var/obj/item/weapon/melee/defibrillator/D = G
		if(D.ready)
			to_chat(user, "<span class='warning'>\The [D] won't fit. Try putting the paddles back on!</span>")
			return
		if(user.drop_item(G, src))
			charging = G
			use_power = 2
			update_icon()
	else if (isscrewdriver(G) || iscrowbar(G))
		..()
	else
		to_chat(user, "<span class='warning'>\The [G] isn't a defibrillator, it won't fit!</span>")