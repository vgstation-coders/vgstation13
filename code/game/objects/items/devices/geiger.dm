#define COOLDOWN 1 SECONDS

/obj/item/device/geiger_counter
	name = "geiger counter"
	desc = "a device about the size of a briefcase, used for detecting and measuring ambient radiation."
	icon_state = "geiger_counter"
	w_class = W_CLASS_LARGE
	origin_tech = Tc_ENGINEERING + "=3;" + Tc_MATERIALS + "=4"
	var/on = 0
	var/last_call

/obj/item/device/geiger_counter/New()
	..()
	update_icon()

/obj/item/device/geiger_counter/proc/measure_rad(var/mob/user, var/rads)
	if(on && world.time > last_call + COOLDOWN)
		to_chat(user, "<span class = 'notice'>Radiation detected.</span>")
		spawn(5)
			to_chat(user, "<span class = 'soghun'>Radiation dosage: [rads] rads</span>")
			last_call = world.time

/obj/item/device/geiger_counter/attack_self(mob/user)
	on = !on
	update_icon()

/obj/item/device/geiger_counter/update_icon()
	icon_state = initial(icon_state)+"[on]"