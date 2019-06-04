#define MAX_PRESSURE 4500

/*
This pump takes air from its input to bring its output to the target pressure.

node1, air1, network1 correspond to the input
node2, air2, network2 correspond to the output

The pump has two buffers on the output and input side, air1 and air2 respectively.
air1.volume
	this is the maximum volume of gas the pump will move per tick. It's 200 litres for the basic pump type.
air2.volume
	this is legacy shit that now basically only serves to muddle up the calculation. It also has a volume of 200.
	used to be this was the only thing considered in the pressure calculation, but now the pump considers the
	entire output side pipe network.
*/

/obj/machinery/atmospherics/binary/pump
	icon = 'icons/obj/atmospherics/pump.dmi'
	icon_state = "intact_off"

	name = "Gas pump"
	desc = "A pump."
	var/target_pressure = ONE_ATMOSPHERE

	var/frequency = 0
	var/id_tag = null
	var/datum/radio_frequency/radio_connection

	machine_flags = MULTITOOL_MENU

/obj/machinery/atmospherics/binary/pump/highcap
	name = "High capacity gas pump"
	desc = "A high capacity pump"

	target_pressure = 15000000 // Holy fuck man

/obj/machinery/atmospherics/binary/pump/on
	on = 1
	icon_state = "intact_on"

/obj/machinery/atmospherics/binary/pump/update_icon()
	if(stat & NOPOWER)
		icon_state = "intact_off"
	else if(node1 && node2)
		icon_state = "intact_[on?("on"):("off")]"
	..()

/obj/machinery/atmospherics/binary/pump/process()
	. = ..()
	if((stat & (NOPOWER|BROKEN)) || !on)
		return

	var/output_starting_pressure = air2.return_pressure()
	var/pressure_delta = target_pressure - output_starting_pressure

	if(pressure_delta > 0.01 && (air1.temperature > 0 || air2.temperature > 0))
		//Figure out how much gas to transfer to meet the target pressure.
		var/air_temperature = (air1.temperature > 0) ? air1.temperature : air2.temperature
		var/output_volume = air2.volume + (network2 ? network2.volume : 0)
		//get the number of moles that would have to be transfered to bring sink to the target pressure
		var/transfer_moles = (pressure_delta * output_volume) / (air_temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = air1.remove(transfer_moles)
		air2.merge(removed)

		if(network1)
			network1.update = 1
		if(network2)
			network2.update = 1

	return 1

//Radio remote control


/obj/machinery/atmospherics/binary/pump/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, filter = RADIO_ATMOSIA)

/obj/machinery/atmospherics/binary/pump/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = getFromPool(/datum/signal)
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id_tag,
		"device" = "AGP",
		"power" = on,
		"target_output" = target_pressure,
		"sigtype" = "status"
	)

	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	return 1

/obj/machinery/atmospherics/binary/pump/interact(mob/user as mob)
	var/dat = {"<b>Power: </b><a href='?src=\ref[src];power=1'>[on?"On":"Off"]</a><br>
				<b>Desirable output pressure: </b>
				[round(target_pressure,0.1)]kPa | <a href='?src=\ref[src];set_press=1'>Change</a>
				"}

	user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD><TT>[dat]</TT>", "window=atmo_pump")
	onclose(user, "atmo_pump")

/obj/machinery/atmospherics/binary/pump/initialize()
	..()
	if(frequency)
		set_frequency(frequency)



/obj/machinery/atmospherics/binary/pump/receive_signal(datum/signal/signal)
	if(!CHECK_ATMOS_COMMAND_SIGNAL(SIGNAL_TYPE_ATMOS_GAS_PUMP))
		return 0

	var/old_on = on

	switch(signal.data["command"])
		if("power")
			on = text2num(signal.data["value"])
		if("set_target_pressure")
			target_pressure = Clamp(text2num(signal.data["value"]), 0, MAX_PRESSURE)
			investigation_log(I_ATMOS, "was set to [target_pressure] kPa by a remote signal.")
	if("status" in signal.data)
		spawn(2)
			broadcast_status()
		return //do not update_icon

	spawn(2)
		broadcast_status()
	update_icon()

	if(old_on != on)
		investigation_log(I_ATMOS,"was turned [on ? "on" : "off"] by a remote signal.")

/obj/machinery/atmospherics/binary/pump/attack_hand(user as mob)
	if(..())
		return
	src.add_fingerprint(usr)
	if(!src.allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	usr.set_machine(src)
	interact(user)
	return

/obj/machinery/atmospherics/binary/pump/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[1439]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag","set_id")]</a></li>
	</ul>
	"}

/obj/machinery/atmospherics/binary/pump/Topic(href,href_list)
	if(..())
		return
	if(href_list["power"])
		on = !on
		investigation_log(I_ATMOS,"was turned [on ? "on" : "off"] by [key_name(usr)].")
	if(href_list["set_press"])
		var/new_pressure = input(usr,"Enter new output pressure (0-[MAX_PRESSURE]kPa)","Pressure control",src.target_pressure) as num
		src.target_pressure = max(0, min(MAX_PRESSURE, new_pressure))
		investigation_log(I_ATMOS,"was set to [target_pressure] kPa by [key_name(usr)].")
	usr.set_machine(src)
	src.update_icon()
	src.updateUsrDialog()

/obj/machinery/atmospherics/binary/pump/multitool_topic(var/mob/user, var/list/href_list, var/obj/O)
	if("set_id" in href_list)
		var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag for this machine", src, id_tag) as null|text), 1, MAX_MESSAGE_LEN)
		if(newid)
			id_tag = newid
			initialize()
		return MT_UPDATE

	if("set_freq" in href_list)
		var/newfreq=frequency
		if(href_list["set_freq"]!="-1")
			newfreq=text2num(href_list["set_freq"])
		else
			newfreq = input(usr, "Specify a new frequency (GHz). Decimals assigned automatically.", src, frequency) as null|num
		if(newfreq)
			if(findtext(num2text(newfreq), "."))
				newfreq *= 10 // shift the decimal one place
			if(newfreq < 10000)
				frequency = newfreq
				initialize()
		return MT_UPDATE

	return ..()

/obj/machinery/atmospherics/binary/pump/power_change()
	..()
	update_icon()

/obj/machinery/atmospherics/binary/pump/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if (!iswrench(W))
		return ..()
	if (!(stat & NOPOWER) && on)
		to_chat(user, "<span class='warning'>You cannot unwrench this [src], turn it off first.</span>")
		return 1
	return ..()

/obj/machinery/atmospherics/binary/pump/npc_tamper_act(mob/living/L)
	if(prob(50)) //Turn on/off
		on = !on
		investigation_log(I_ATMOS,"was turned [on ? "on" : "off"] by [key_name(L)]")
	else //Change pressure
		src.target_pressure = rand(0, MAX_PRESSURE)
		investigation_log(I_ATMOS,"was set to [target_pressure] kPa by [key_name(L)]")

	src.update_icon()
	src.updateUsrDialog()

/obj/machinery/atmospherics/binary/pump/canClone(var/obj/O)
	return istype(O, /obj/machinery/atmospherics/binary/pump)

/obj/machinery/atmospherics/binary/pump/clone(var/obj/machinery/atmospherics/binary/pump/O)
	id_tag = O.id_tag
	set_frequency(O.frequency)
	return 1

#undef MAX_PRESSURE
