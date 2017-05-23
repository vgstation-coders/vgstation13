#define COOLDOWN 1 SECONDS

/obj/item/device/geiger_counter
	name = "geiger counter"
	desc = "a device about the size of a briefcase, used for detecting and measuring ambient radiation."
	icon_state = "geiger_counter"
	w_class = W_CLASS_LARGE
	origin_tech = Tc_ENGINEERING + "=3;" + Tc_MATERIALS + "=4"
	var/on = 0
	var/last_call = 0
	var/event_key

/obj/item/device/geiger_counter/New()
	..()
	update_icon()

/obj/item/device/geiger_counter/pickup(mob/user)
	event_key = user.on_irradiate.Add(src, "measure_rad")

/obj/item/device/geiger_counter/dropped(mob/user)
	user.on_irradiate.Remove(event_key)
	event_key = null


/obj/item/device/geiger_counter/proc/measure_rad(list/arguments)
	var/mob/user = arguments["user"]
	var/rads = arguments["rads"]
	if(on && world.time > last_call + COOLDOWN)
		to_chat(user, "<span class = 'notice'>Radiation detected.</span>")
		last_call = world.time
		spawn(5)
			if(user && on)
				to_chat(user, "<span class = 'soghun'>Radiation dosage: [rads] rads.</span>")


/obj/item/device/geiger_counter/attack_self(mob/user)
	on = !on
	update_icon()

/obj/item/device/geiger_counter/update_icon()
	icon_state = initial(icon_state)+"[on]"

#undef COOLDOWN