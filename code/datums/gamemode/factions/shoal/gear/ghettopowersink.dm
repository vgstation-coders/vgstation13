/obj/machinery/ghettopowersink
	desc = "A toy wagon carrying an absurd amount of batteries wired in parallel. You wonder if this is safe."
	name = "power sink"
	icon_state = "powersink0"
	machine_flags = EMAGGABLE | WRENCHMOVE | FIXED2WORK

	var/drain_rate = 600000		// amount of power to drain per tick
	var/last_drain = 0			// amount we tried to drain last tick
	var/apc_drain_rate = 50 	// amount of power to drain out of each apc per tick if there's not enough power on the grid
	var/power_drained = 0 		// has drained this much power
	var/max_power = 1e8			// maximum power that can be drained
	var/active = 0

	var/datum/power_connection/consumer/cable/power_connection = null

/obj/machinery/ghettopowersink/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>A meter on the side indicates that it has [format_watts(power_drained)] of power stored</span>.")

/obj/machinery/ghettopowersink/New()
	. = ..()
	power_connection = new(src)
	power_connection.power_priority = POWER_PRIORITY_BYPASS

/obj/machinery/ghettopowersink/Destroy()
	set_light(0)
	processing_objects.Remove(src)
	if(power_connection)
		QDEL_NULL(power_connection)
	. = ..()

// Wrench time is longer. Up to 15 seconds from the default 3.
/obj/machinery/ghettopowersink/wrenchAnchor(var/mob/user, var/obj/item/I, var/time_to_wrench = 15 SECONDS)
	. = ..()

/obj/machinery/ghettopowersink/proc/activate(mob/user)
	if(power_drained >= max_power)
		to_chat(user, "<span class='notice'>[src] is already fully charged!</span>")
		return
	var/turf/T = loc
	if(isturf(T) && !T.intact && locate(/obj/structure/cable) in T)
		power_connection.connect()
		active = TRUE
		processing_objects.Add(src)
		playsound(src, 'sound/effects/phasein.ogg', 30, 1)
		last_drain = 0
		user?.visible_message("<span class='warning'>[user] attaches [src] to the cable.</span>", \
			"<span class='notice'>You attach [src] to the cable.</span>", \
			drugged_message = "<span class='warning'>[user] twists the cord of fate through [src]!</span>")
	else
		user?.visible_message("<span class='notice'>[user] stares at [src] absentmindedly. </span>", \
			"<span class='warning'>There's no exposed cable here to attach to.</span>", \
			drugged_message = "<span class='notice'>[user] admires [src].</span>")

/obj/machinery/ghettopowersink/proc/deactivate(mob/user)
	processing_objects.Remove(src)
	anchored = 0
	active = FALSE
	power_connection.disconnect()
	playsound(src, 'sound/effects/teleport.ogg', 50, 1)
	set_light(0)
	user?.visible_message("<span class='warning'>[user] detaches [src] from the cable.</span>", \
		"<span class='notice'>You detach [src] from the cable.</span>", \
		drugged_message = "<span class='warning'>[user] unravels the cords of reality from [src]!</span>")

/obj/machinery/ghettopowersink/attack_hand(mob/user, ignore_brain_damage)
	. = ..()
	add_fingerprint(user)
	if(state == 1)
		active ? deactivate() : activate()
		update_icon()
	else
		to_chat(user, "<span class='warning'>[src] needs to be wrenched to the ground first!</span>")

/obj/machinery/ghettopowersink/attack_paw()
	return

/obj/machinery/ghettopowersink/attack_ai()
	return

// This is almost identical to the code in powersink.dm
/obj/machinery/ghettopowersink/process()
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

		if(power_drained >= max_power)
			playsound(src, 'sound/machines/charge_finish.ogg', 50)
			visible_message("<span class='notice'>Beeps happily as it finishes charging.</span>")
			deactivate()


/obj/machinery/ghettopowersink/update_icon()
	icon_state = active ? "powersink1" : "powersink0"
