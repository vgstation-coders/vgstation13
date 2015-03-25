/*
FIRE ALARM
*/
/obj/machinery/firealarm
	name = "Fire Alarm"
	desc = "<i>\"Pull this in case of emergency\"</i>. Thus, keep pulling it forever."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire0"
	var/detecting = 1.0
	var/working = 1.0
	var/time = 10.0
	var/timing = 0.0
	var/lockdownbyai = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON
	var/last_process = 0
	var/wiresexposed = 0
	var/buildstage = 2 // 2 = complete, 1 = no wires,  0 = circuit gone

/obj/machinery/firealarm/update_icon()

	if(wiresexposed)
		switch(buildstage)
			if(2)
				icon_state="fire_b2"
			if(1)
				icon_state="fire_b1"
			if(0)
				icon_state="fire_b0"

		return

	if(stat & BROKEN)
		icon_state = "firex"
	else if(stat & NOPOWER)
		icon_state = "firep"
	else if(!src.detecting)
		icon_state = "fire1"
	else
		icon_state = "fire0"

/obj/machinery/firealarm/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(src.detecting)
		if(exposed_temperature > T0C+200)
			src.alarm()			// added check of detector status here
	return

/obj/machinery/firealarm/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/firealarm/bullet_act(BLAH)
	return src.alarm()

/obj/machinery/firealarm/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/firealarm/emp_act(severity)
	if(prob(50/severity)) alarm()
	..()

/obj/machinery/firealarm/attackby(obj/item/W as obj, mob/user as mob)
	src.add_fingerprint(user)

	if (istype(W, /obj/item/weapon/screwdriver) && buildstage == 2)
		wiresexposed = !wiresexposed
		update_icon()
		return

	if(wiresexposed)
		switch(buildstage)
			if(2)
				if (ismultitool(W))
					src.detecting = !( src.detecting )
					if (src.detecting)
						user.visible_message("<span class='attack'>[user] has reconnected [src]'s detecting unit!</span>", "You have reconnected [src]'s detecting unit.")
					else
						user.visible_message("<span class='attack'>[user] has disconnected [src]'s detecting unit!</span>", "You have disconnected [src]'s detecting unit.")
				if(iswirecutter(W))
					if(do_after(user,50))
						buildstage=1
						user.visible_message("<span class='attack'>[user] has cut the wiring from \the [src]!</span>", "You have cut the last of the wiring from \the [src].")
						update_icon()
						new /obj/item/stack/cable_coil(user.loc,5)
						playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
			if(1)
				if(iscoil(W))
					var/obj/item/stack/cable_coil/coil = W
					if(coil.amount < 5)
						user << "You need more cable for this!"
						return
					coil.use(5)

					buildstage = 2
					user << "You wire \the [src]!"
					update_icon()

				else if(istype(W, /obj/item/weapon/crowbar))
					user << "You pry out the circuit!"
					playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
					spawn(20)
						var/obj/item/weapon/circuitboard/fire_alarm/circuit = new /obj/item/weapon/circuitboard/fire_alarm()
						circuit.loc = user.loc
						buildstage = 0
						update_icon()
			if(0)
				if(istype(W, /obj/item/weapon/circuitboard/fire_alarm))
					user << "You insert the circuit!"
					qdel(W)
					buildstage = 1
					update_icon()

				else if(iswrench(W))
					user << "You remove the fire alarm assembly from the wall!"
					new /obj/item/mounted/frame/firealarm(get_turf(user))
					playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
					qdel(src)
		return

	src.alarm()
	return

/obj/machinery/firealarm/process()//Note: this processing was mostly phased out due to other code, and only runs when needed
	if(stat & (NOPOWER|BROKEN))
		return

	if(src.timing)
		if(src.time > 0)
			src.time = src.time - ((world.timeofday - last_process)/10)
		else
			src.alarm()
			src.time = 0
			src.timing = 0
			processing_objects.Remove(src)
		src.updateDialog()
	last_process = world.timeofday

	if(locate(/obj/fire) in loc)
		alarm()

	return

/obj/machinery/firealarm/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
		update_icon()
	else
		spawn(rand(0,15))
			stat |= NOPOWER
			update_icon()

/obj/machinery/firealarm/attack_hand(mob/user as mob)
	if((user.stat && !isobserver(user)) || stat & (NOPOWER|BROKEN))
		return

	if (buildstage != 2)
		return

	user.set_machine(src)
	var/d1
	var/d2
	if (istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon) || isobserver(user))

		if (areaMaster.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>Reset - Lockdown</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>Alarm - Lockdown</A>", src)
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>Stop Time Lock</A>", src)
		else
			d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Lock</A>", src)
		var/second = round(src.time) % 60
		var/minute = (round(src.time) - second) / 60
		var/dat = "<HTML><HEAD></HEAD><BODY><TT><B>Fire alarm</B> [d1]\n<HR>The current alert level is: [get_security_level()]</b><br><br>\nTimer System: [d2]<BR>\nTime Left: [(minute ? "[minute]:" : null)][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>\n</TT></BODY></HTML>"
		user << browse(dat, "window=firealarm")
		onclose(user, "firealarm")
	else
		if (areaMaster.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>[]</A>", src, stars("Reset - Lockdown"))
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>[]</A>", src, stars("Alarm - Lockdown"))
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>[]</A>", src, stars("Stop Time Lock"))
		else
			d2 = text("<A href='?src=\ref[];time=1'>[]</A>", src, stars("Initiate Time Lock"))
		var/second = round(src.time) % 60
		var/minute = (round(src.time) - second) / 60
		var/dat = "<HTML><HEAD></HEAD><BODY><TT><B>[stars("Fire alarm")]</B> [d1]\n<HR><b>The current alert level is: [stars(get_security_level())]</b><br><br>\nTimer System: [d2]<BR>\nTime Left: [(minute ? text("[]:", minute) : null)][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>\n</TT></BODY></HTML>"
		user << browse(dat, "window=firealarm")
		onclose(user, "firealarm")
	return

/obj/machinery/firealarm/Topic(href, href_list)
	if(..()) return 1
	if (usr.stat || stat & (BROKEN|NOPOWER))
		return

	if (buildstage != 2)
		return

	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)
		if (href_list["reset"])
			src.reset()
		else if (href_list["alarm"])
			src.alarm()
		else if (href_list["time"])
			src.timing = text2num(href_list["time"])
			last_process = world.timeofday
			processing_objects.Add(src)
		else if (href_list["tp"])
			var/tp = text2num(href_list["tp"])
			src.time += tp
			src.time = min(max(round(src.time), 0), 120)

		src.updateUsrDialog()

		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=firealarm")
		return
	return

/obj/machinery/firealarm/proc/reset()
	if (!( src.working ))
		return
	areaMaster.firereset()
	update_icon()
	return

/obj/machinery/firealarm/proc/alarm()
	if (!( src.working ))
		return
	areaMaster.firealert()
	update_icon()
	//playsound(get_turf(src), 'sound/ambience/signal.ogg', 75, 0)
	return

/obj/machinery/firealarm/New(loc, dir, building)
	..()
	name = "[areaMaster.name] fire alarm"
	if(loc)
		src.loc = loc

	if(dir)
		src.dir = dir

	if(building)
		buildstage = 0
		wiresexposed = 1
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0

	if(z == 1)
		if(security_level)
			src.overlays += image('icons/obj/monitors.dmi', "overlay_[get_security_level()]")
		else
			src.overlays += image('icons/obj/monitors.dmi', "overlay_green")

	machines.Remove(src)
	update_icon()