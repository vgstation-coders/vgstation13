// Currently only used to control /obj/machinery/inlet/filter
// todo: expand to vent control as well?

/obj/machinery/filter_control/New()
	..()
	spawn(5)	//wait for world
		for(var/obj/machinery/inlet/filter/F in machines)
			if(F.control == control)
				F.f_mask = f_mask
		desc = "A remote control for a filter: [control]"

/obj/machinery/filter_control/attack_ai(mob/user as mob)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/filter_control/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/filter_control/attackby(obj/item/weapon/W, mob/user as mob)
	if(istype(W, /obj/item/weapon/detective_scanner))
		return ..()
	if(istype(W, /obj/item/weapon/screwdriver))
		add_fingerprint(user)
		user.show_message(text("<span class='warning'>Now [] the panel...</span>", (locked) ? "unscrewing" : "reattaching"), 1)
		sleep(30)
		locked =! locked
		updateicon()
		return
	if(istype(W, /obj/item/weapon/wirecutters) && !locked)
		stat ^= BROKEN
		add_fingerprint(user)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("<span class='warning'>[] has []activated []!</span>", user, (stat&BROKEN) ? "de" : "re", src), 1)
		updateicon()
		return
	if(istype(W, /obj/item/weapon/card/emag) && !emagged)
		emagged++
		for(var/mob/O in viewers(user, null))
			O.show_message(text("<span class='warning'>[] has shorted out the []'s access system with an electromagnetic card!</span>", user, src), 1)
		updateicon()
		return attack_hand(user)
	return attack_hand(user)

/obj/machinery/filter_control/process()
	if(!(stat & NOPOWER))
		use_power(5,ENVIRON)
		AutoUpdateAI(src)
		updateUsrDialog()
	updateicon()

/obj/machinery/filter_control/attack_hand(mob/user as mob)
	if(stat & NOPOWER)
		user << browse(null, "window=filter_control")
		user.machine = null
		return
	if(user.stat || user.lying)
		return
	if ((get_dist(src, user) > 1 || !istype(loc, /turf)) && !istype(user, /mob/living/silicon/ai))
		return 0

	var/list/gases = list("O2", "N2", "Plasma", "CO2", "N2O")
	var/dat
	user.machine = src

	var/IGoodConnection = 0
	var/IBadConnection = 0

	for(var/obj/machinery/inlet/filter/F in machines)
		if((F.control == control) && !(F.stat && (NOPOWER|BROKEN)))
			IGoodConnection++
		else if(F.control == control)
			IBadConnection++
	var/ITotalConnections = IGoodConnection+IBadConnection

	if(ITotalConnections && !(stat & BROKEN))	//ugly
		dat += "Connection status: Inlets:[ITotalConnections]/[IGoodConnection]<BR>\n Control ID: [control]<BR><BR>\n"
	else
		dat += "<font color=red>No Connections Detected!</font><BR>\n Control ID: [control]<BR>\n"
	if(!stat & BROKEN)
		for (var/i = 1; i <= gases.len; i++)
			dat += "[gases[i]]: <A HREF='?src=\ref[src];tg=[1 << (i - 1)]'>[(f_mask & 1 << (i - 1)) ? "Siphoning" : "Passing"]</A><BR>\n"
	else
		dat += "<big><font color='red'>Warning! Severe Internal Memory Corruption!</big><BR>\n<BR>\nConsult a qualified station technician immediately!</font><BR>\n"
		dat += "<BR>\n<small>Error codes: 0x0000001E 0x0000007B</small><BR>\n"

	dat += "<BR>\n<A href='?src=\ref[src];close=1'>Close</A><BR>\n"
	user << browse(dat, "window=filter_control;size=300x225")
	onclose(user, "filter_control")
/obj/machinery/filter_control/Topic(href, href_list)
	if (href_list["close"])
		usr << browse(null, "window=filter_control;")
		usr.machine = null
		return	//Who cares if we're dead or whatever let us close the fucking window
	if(..())
		return 1
	else
		usr.machine = src
		if (allowed(usr) || emagged && !(stat & BROKEN))
			if (href_list["tg"])	//someone modified the html so I added a check here
				// toggle gas
				f_mask ^= text2num(href_list["tg"])
				for(var/obj/machinery/inlet/filter/FI in machines)
					if(FI.control == control)
						FI.f_mask ^= text2num(href_list["tg"])
		else
			usr.see("<span class='warning'>Access Denied ([name] operation restricted to authorized atmospheric technicians.)</span>")
		AutoUpdateAI(src)
		updateUsrDialog()
		add_fingerprint(usr)
	else
		usr << browse(null, "window=filter_control")
		usr.machine = null
		return

/obj/machinery/filter_control/proc/updateicon()
	overlays.len = 0
	if(stat & NOPOWER)
		icon_state = "filter_control-nopower"
		return
	icon_state = "filter_control"
	if(locked && (stat & BROKEN))
		overlays += image('icons/obj/stationobjs.dmi', "filter_control00")
		return
	else if(!locked)
		icon_state = "filter_control-unlocked"
		if(stat & BROKEN)
			overlays += image('icons/obj/stationobjs.dmi', "filter_control-wirecut")
			overlays += image('icons/obj/stationobjs.dmi', "filter_control00")
			return

	var/GoodConnection = 0
	for(var/obj/machinery/inlet/filter/F in machines)
		if((F.control == control) && !(F.stat && (NOPOWER|BROKEN)))
			GoodConnection++
			break

	if(GoodConnection && f_mask)
		overlays += image('icons/obj/stationobjs.dmi', "filter_control1")
	else if(GoodConnection)
		overlays += image('icons/obj/stationobjs.dmi', "filter_control10")
	else if(f_mask)
		overlays += image('icons/obj/stationobjs.dmi', "filter_control0")
	else
		overlays += image('icons/obj/stationobjs.dmi', "filter_control00")

	if (f_mask & (GAS_N2O|GAS_PL))
		overlays += image('icons/obj/stationobjs.dmi', "filter_control-tox")
	if (f_mask & GAS_O2)
		overlays += image('icons/obj/stationobjs.dmi', "filter_control-o2")
	if (f_mask & GAS_N2)
		overlays += image('icons/obj/stationobjs.dmi', "filter_control-n2")
	if (f_mask & GAS_CO2)
		overlays += image('icons/obj/stationobjs.dmi', "filter_control-co2")
	return

/obj/machinery/filter_control/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	spawn(rand(1,15))
		updateicon()
	return