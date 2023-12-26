// Powersink - used to drain station power

/obj/item/device/powersink
	desc = "A nulling power sink which drains energy from electrical systems."
	name = "power sink"
	icon_state = "powersink0"
	item_state = "electronic"
	w_class = W_CLASS_LARGE
	flags = FPRINT
	siemens_coefficient = 1
	throwforce = 5
	throw_speed = 1
	throw_range = 2
	starting_materials = list(MAT_IRON = 750)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_STEEL
	origin_tech = Tc_POWERSTORAGE + "=3;" + Tc_SYNDICATE + "=5"
	var/drain_rate = 600000		// amount of power to drain per tick
	var/last_drain = 0			// amount we tried to drain last tick
	var/apc_drain_rate = 50 	// amount of power to drain out of each apc per tick if there's not enough power on the grid
	var/power_drained = 0 		// has drained this much power
	var/max_power = 1e8		// maximum power that can be drained before exploding
	var/mode = 0		// 0 = off, 1=clamped (off), 2=operating
	var/dev_multi = 3	// dude bombs

	var/datum/power_connection/consumer/cable/power_connection = null

/obj/item/device/powersink/New()
	. = ..()
	power_connection = new(src)
	power_connection.power_priority = POWER_PRIORITY_BYPASS

/obj/item/device/powersink/Destroy()
	set_light(0)
	processing_objects.Remove(src)
	if(power_connection)
		QDEL_NULL(power_connection)
	. = ..()

/obj/item/device/powersink/attackby(var/obj/item/I, var/mob/user)
	if(I.is_screwdriver(user))
		if(mode == 0)
			var/turf/T = loc
			if(isturf(T) && !T.intact)
				if(!(locate(/obj/structure/cable) in T))
					to_chat(user, "No exposed cable here to attach to.")
					return
				else
					power_connection.connect()
					anchored = 1
					mode = 1
					to_chat(user, "You attach the device to the cable.")
					for(var/mob/M in viewers(user))
						if(M == user)
							continue
						to_chat(M, "[user] attaches the power sink to the cable.")
					return
			else
				to_chat(user, "Device must be placed over an exposed cable to attach to it.")
				return
		else
			if (mode == 2)
				processing_objects.Remove(src) // Now the power sink actually stops draining the station's power if you unhook it. --NeoFite
			anchored = 0
			mode = 0
			to_chat(user, "You detach the device from the cable.")
			power_connection.disconnect()
			for(var/mob/M in viewers(user))
				if(M == user)
					continue
				to_chat(M, "[user] detaches the power sink from the cable.")
			set_light(0)
			icon_state = "powersink0"

			return
	else
		..()

/obj/item/device/powersink/attack_paw()
	return

/obj/item/device/powersink/attack_ai()
	return

/obj/item/device/powersink/attack_hand(var/mob/user)
	switch(mode)
		if(0)
			..()

		if(1)
			to_chat(user, "You activate the device!")
			for(var/mob/M in viewers(user))
				if(M == user)
					continue
				to_chat(M, "[user] activates the power sink!")
			mode = 2
			icon_state = "powersink1"
			playsound(src, 'sound/effects/phasein.ogg', 30, 1)
			processing_objects.Add(src)
			last_drain = 0
		if(2)  //This switch option wasn't originally included. It exists now. --NeoFite
			to_chat(user, "You deactivate the device!")
			for(var/mob/M in viewers(user))
				if(M == user)
					continue
				to_chat(M, "[user] deactivates the power sink!")
			mode = 1
			set_light(0)
			icon_state = "powersink0"
			playsound(src, 'sound/effects/teleport.ogg', 50, 1)
			processing_objects.Remove(src)

/obj/item/device/powersink/process()
	if(power_connection.connected)
		var/datum/powernet/PN = power_connection.get_powernet()
		if(PN)
			set_light(12)

			// found a powernet, so drain up to max power from it
			var/drained = power_connection.get_satisfaction() * last_drain // check how much out of our previous tick's request we've actually drained
			power_drained += drained
			last_drain = drain_rate
			power_connection.add_load(last_drain) // request power for next tick

			// if tried to drain more than available on powernet
			// now look for APCs and drain their cells
			if(drained < drain_rate)
				for(var/obj/machinery/power/terminal/T in PN.nodes)
					if(istype(T.master, /obj/machinery/power/apc))
						var/obj/machinery/power/apc/A = T.master
						if(A.operating && A.cell && A.cell.charge > 0)
							var/apc_drained = min(A.cell.charge, apc_drain_rate)
							A.cell.charge -= apc_drained
							power_drained += apc_drained
							if(A.charging == 2)
								A.charging = 1


		if(power_drained > max_power * 0.95)
			playsound(src, 'sound/effects/screech.ogg', 100, 1, 1)
		if(power_drained >= max_power)
			processing_objects.Remove(src)
			explosion(src.loc, 1 * dev_multi, 2 * dev_multi, 3 * dev_multi, 4 * dev_multi)
			qdel(src)
