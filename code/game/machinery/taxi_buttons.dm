/obj/machinery/door_control/taxi
	name = "taxi caller"
	desc = "TAXI!"
	var/destination
	power_channel = ENVIRON
	req_access = list(access_taxi)
	var/obj/machinery/computer/taxi_shuttle/connected_computer

/obj/machinery/door_control/taxi/New()
	..()
	spawn(50)
		for(var/obj/machinery/computer/taxi_shuttle/TS in world)
			if(id_tag == TS.id_tag)
				connected_computer = TS
				if(!(src in connected_computer.connected_buttons))
					connected_computer.connected_buttons += src

/obj/machinery/door_control/taxi/attack_hand(mob/user as mob)
	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return

	var/wait_time = 30
	if(!allowed(user) && (wires & 1))
		wait_time = 100

	use_power(5)
	icon_state = "doorctrl1"
	add_fingerprint(user)

	spawn if(!connected_computer.callTo(destination, wait_time))
		src.visible_message("Taxi engines are on cooldown. Please wait before trying again.")

	spawn(30)
		icon_state = initial(icon_state)

/obj/machinery/door_control/taxi/abandoned
	name = "taxi caller"
	desc = "...Taxi?"
	destination = "abandoned"
	id_tag = "taxi_null"
	req_access = list()

/obj/machinery/door_control/taxi/abandoned/attack_hand(mob/user as mob)
	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return

	if(!allowed(user) && (wires & 1))
		user << "<span class='rose'>Access Denied</span>"
		flick("doorctrl-denied",src)
		return

	icon_state = "doorctrl1"
	add_fingerprint(user)

	src.visible_message("<span class='rose'>UNKNOWN TAXI engines are on cooldown. Plea-</span>")

	spawn(30)
		icon_state = initial(icon_state)