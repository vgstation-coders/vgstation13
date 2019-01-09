/obj/machinery/door_control/taxi/abandoned
	name = "taxi caller"
	desc = "...Taxi?"
	req_access = list()

/obj/machinery/door_control/taxi/abandoned/attack_hand(mob/user)
	add_fingerprint(user)
	icon_state = "doorctrl1"
	visible_message("<span class='rose'>UNKNOWN TAXI engines are on cooldown. Plea-</span>")

	spawn(3 SECONDS)
		icon_state = initial(icon_state)
