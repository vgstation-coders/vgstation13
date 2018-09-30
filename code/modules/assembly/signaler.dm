#define VALUE_CODE "Code (1 to 100)"
#define VALUE_FREQUENCY "Frequency (whole numbers such as 1457)"

/obj/item/device/assembly/signaler
	name = "remote signaling device"
	short_name = "signaler"

	desc = "Used to remotely activate devices."
	icon_state = "signaller"
	item_state = "signaler"
	starting_materials = list(MAT_IRON = 1000, MAT_GLASS = 200)
	w_type = RECYK_ELECTRONIC
	origin_tech = Tc_MAGNETS + "=1"
	wires = WIRE_RECEIVE | WIRE_PULSE | WIRE_RADIO_PULSE | WIRE_RADIO_RECEIVE

	secured = 1

	var/code = 30
	var/frequency = 1457
	var/delay = 0
	var/datum/wires/connected = null
	var/datum/radio_frequency/radio_connection
	var/deadman = 0

	accessible_values = list(\
		VALUE_CODE = "code;"+VT_NUMBER+";1;100",\
		VALUE_FREQUENCY = "frequency;"+VT_NUMBER)

/obj/item/device/assembly/signaler/New()
	..()
	spawn(40)//delay so the radio_controller has time to initialize
		set_frequency(frequency)
	return

/obj/item/device/assembly/signaler/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = W
		if(R.amount >= 1)
			R.use(1)
			new /obj/machinery/conveyor_switch(get_turf(src.loc))
			user.u_equip(src,0)
			qdel(src)

	if(istype(W, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/R = W
		if(R.amount >= 1)
			R.use(1)
			var/obj/item/mounted/frame/driver_button/signaler_button/I = new (get_turf(src.loc))
			I.code = src.code
			I.frequency = src.frequency
			user.u_equip(src,0)
			qdel(src)

/obj/item/device/assembly/signaler/activate()
	if(cooldown > 0)
		return 0
	cooldown = 2
	spawn(10)
		process_cooldown()

	signal()
	return 1

/obj/item/device/assembly/signaler/update_icon()
	if(holder)
		holder.update_icon()
	return

/obj/item/device/assembly/signaler/interact(mob/user as mob, flag1)
	var/t1 = "-------"
//		if ((src.b_stat && !( flag1 )))
//			t1 = text("-------<BR>\nGreen Wire: []<BR>\nRed Wire:   []<BR>\nBlue Wire:  []<BR>\n", (src.wires & 4 ? text("<A href='?src=\ref[];wires=4'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=4'>Mend Wire</A>", src)), (src.wires & 2 ? text("<A href='?src=\ref[];wires=2'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=2'>Mend Wire</A>", src)), (src.wires & 1 ? text("<A href='?src=\ref[];wires=1'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=1'>Mend Wire</A>", src)))
//		else
//			t1 = "-------"	Speaker: [src.listening ? "<A href='byond://?src=\ref[src];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];listen=1'>Disengaged</A>"]<BR>
	var/dat = {"
		<TT>

		<A href='byond://?src=\ref[src];send=1'>Send Signal</A><BR>
		<B>Frequency/Code</B> for signaler:<BR>
		Frequency:
		<A href='byond://?src=\ref[src];freq=-10'>-</A>
		<A href='byond://?src=\ref[src];freq=-2'>-</A>
		[format_frequency(src.frequency)]
		<A href='byond://?src=\ref[src];freq=2'>+</A>
		<A href='byond://?src=\ref[src];freq=10'>+</A><BR>

		Code:
		<A href='byond://?src=\ref[src];code=-5'>-</A>
		<A href='byond://?src=\ref[src];code=-1'>-</A>
		[src.code]
		<A href='byond://?src=\ref[src];code=1'>+</A>
		<A href='byond://?src=\ref[src];code=5'>+</A><BR>
		[t1]
		</TT>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return


/obj/item/device/assembly/signaler/Topic(href, href_list)
	..()
	if(usr.stat || usr.restrained() || !in_range(loc, usr) || (!usr.canmove && !usr.locked_to))
		//If the user is handcuffed or out of range, or if they're unable to move,
		//but NOT if they're unable to move as a result of being buckled into something, they're unable to use the device.
		usr << browse(null, "window=radio")
		onclose(usr, "radio")
		return

	if(href_list["freq"])
		var/new_frequency = (frequency + text2num(href_list["freq"]))
		if(new_frequency < MINIMUM_FREQUENCY || new_frequency > MAXIMUM_FREQUENCY)
			new_frequency = sanitize_frequency(new_frequency)
		set_frequency(new_frequency)

	if(href_list["code"])
		src.code += text2num(href_list["code"])
		src.code = round(src.code)
		src.code = min(100, src.code)
		src.code = max(1, src.code)

	if(href_list["send"])
		spawn( 0 )
			signal()

	if(usr)
		attack_self(usr)

/obj/item/device/assembly/signaler/proc/signal()
	if(!radio_connection)
		return

	if(!(frequency in (MINIMUM_FREQUENCY to MAXIMUM_FREQUENCY)))
		return
	if(!(code in (1 to 100)))
		return

	var/datum/signal/signal = getFromPool(/datum/signal)
	signal.source = src
	signal.encryption = code
	signal.data["message"] = "ACTIVATE"
	radio_connection.post_signal(src, signal)

	if(istype(loc, /obj/item/device/assembly_holder))
		investigation_log(I_WIRES, "used as signaler in \a [loc]. Last touched by: [fingerprintslast], Last user processed: [key_name(usr)] - [format_frequency(frequency)]/[code]")
	else
		investigation_log(I_WIRES, "used as signaler. Last touched by: [fingerprintslast], Last user processed: [key_name(usr)] - [format_frequency(frequency)]/[code]")

/*
	for(var/obj/item/device/assembly/signaler/S in world)
		if(!S)
			continue
		if(S == src)
			continue
		if((S.frequency == src.frequency) && (S.code == src.code))
			spawn(0)
				if(S)
					S.pulse(0)
	return 0*/


/obj/item/device/assembly/signaler/pulse(var/radio = 0)
	if(src.connected && src.wires)
		connected.Pulse(src)
	else
		return ..(radio)


/obj/item/device/assembly/signaler/receive_signal(datum/signal/signal)
	if(!signal)
		return 0
	if(signal.encryption != code)
		return 0
	if(!(src.wires & WIRE_RADIO_RECEIVE))
		return 0
	pulse(1)

	if(!holder)
		for(var/mob/O in hearers(1, src.loc))
			O.show_message("[bicon(src)] *beep* *beep*", 1, "*beep* *beep*", 2)
	return


/obj/item/device/assembly/signaler/proc/set_frequency(new_frequency)
	if(!radio_controller)
		spawn(20)
			if(!radio_controller)
				visible_message("Cannot initialize the radio_controller, this is a bug, tell a coder")
				return
			else
				radio_controller.remove_object(src, frequency)
				frequency = new_frequency
				radio_connection = radio_controller.add_object(src, frequency, RADIO_CHAT)
	else
		radio_controller.remove_object(src, frequency)
		frequency = new_frequency
		radio_connection = radio_controller.add_object(src, frequency, RADIO_CHAT)
	return

/obj/item/device/assembly/signaler/process()
	if(loc)
		var/atom/A = loc
		if(A.timestopped)
			return
	if(!deadman)
		processing_objects.Remove(src)
	var/mob/M = src.loc

	if(!M || !ismob(M))
		if(prob(5))
			signal()
		deadman = 0
		processing_objects.Remove(src)
	else if(prob(5))
		M.visible_message("[M]'s finger twitches a bit over [src]'s signal button!")
	return

/obj/item/device/assembly/signaler/verb/deadman_it()
	set src in usr
	set name = "Threaten to push the button!"
	set desc = "BOOOOM!"

	if(usr)
		var/mob/user = usr
		deadman = 1
		processing_objects.Add(src)
		user.visible_message("<span class='warning'>[user] moves their finger over [src]'s signal button...</span>")

///Mounted Signaler Button///
/obj/item/device/assembly/signaler/signaler_button
	name = "signaler button"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "Can be used to send signals to various frequencies."
	var/id_tag = "default"
	var/active = 0
	anchored = 1.0
	show_status = 0
	var/activated = 0

	ghost_read = 0 // Deactivate ghost touching.
	ghost_write = 0

/obj/item/device/assembly/signaler/signaler_button/New(turf/loc, var/w_dir=null)
	..()
	switch(w_dir)
		if(NORTH)
			pixel_y = 25 * PIXEL_MULTIPLIER
		if(SOUTH)
			pixel_y = -25 * PIXEL_MULTIPLIER
		if(EAST)
			pixel_x = 25 * PIXEL_MULTIPLIER
		if(WEST)
			pixel_x = -25 * PIXEL_MULTIPLIER

/obj/item/device/assembly/signaler/signaler_button/attack_hand(mob/user)
	if(!activated)
		activated = 1
		icon_state = "launcheract"
		activate()
		sleep(20)
		icon_state = "launcherbtt"
		activated = 0

/obj/item/device/assembly/signaler/signaler_button/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/pen)) //Naming the button without having to use a labeler
		var/n_name = copytext(sanitize(input(user, "What would you like to name this button?", "Button Labeling", null) as text|null), 1, MAX_NAME_LEN*3)
		if(n_name && Adjacent(user) && !user.stat)
			name = "[n_name]"
		return
	if(iscrowbar(W))
		to_chat(user, "You begin prying \the [src] off the wall.")
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, src,10))
			to_chat(user, "<span class='notice'>You pry the button off of the wall.</span>")
			var/obj/item/mounted/frame/driver_button/signaler_button/I = new (get_turf(user))
			I.code = src.code
			I.frequency = src.frequency
			qdel(src)
		return
	if(istype(W, /obj/item/device/multitool))
		interact(user, null)
		return

/obj/item/device/assembly/signaler/set_value(var/var_name, var/new_value)
	if(var_name == "frequency")
		set_frequency(sanitize_frequency(new_value))
	else
		return ..()
