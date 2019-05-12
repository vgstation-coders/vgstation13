#define MAX_PRESSURE 4500 //kPa

/obj/machinery/atmospherics/binary/passive_gate
	//Essentially a one-way check valve.
	//If input is higher pressure than output, works to equalize the pressure. If output is higher pressure than input, does nothing.
	icon = 'icons/obj/atmospherics/passive_gate.dmi'
	icon_state = "intact_off"

	name = "Passive gate"
	desc = "A one-way air valve that does not require power"

	var/frequency = 0
	var/id_tag = null
	var/datum/radio_frequency/radio_connection

/obj/machinery/atmospherics/binary/passive_gate/update_icon()
	if(stat & NOPOWER)
		icon_state = "intact_off"
	else if(node1 && node2)
		icon_state = "intact_[on?("on"):("off")]"
	..()
	return

/obj/machinery/atmospherics/binary/passive_gate/process()
	. = ..()
	if(!on)
		return

	var/output_starting_pressure = air2.return_pressure()
	var/input_starting_pressure = air1.return_pressure()
	//var/pressure_delta = min(10000, abs(environment_pressure - air_contents.return_pressure()))
	var/pressure_delta = min(10000, input_starting_pressure - output_starting_pressure)

	if((air1.temperature > 0 || air2.temperature > 0) && pressure_delta > 0.5)
		//Figure out how much gas to transfer to equalize the pressure.
		var/air_temperature = (air2.temperature > 0) ? air2.temperature : air1.temperature
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


/obj/machinery/atmospherics/binary/passive_gate/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, filter = RADIO_ATMOSIA)

/obj/machinery/atmospherics/binary/passive_gate/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = getFromPool(/datum/signal)
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id_tag,
		"device" = "AGP",
		"power" = on,
		"sigtype" = "status"
	)

	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	return 1

/obj/machinery/atmospherics/binary/passive_gate/interact(mob/user as mob)
	var/dat = {"<b>Power: </b><a href='?src=\ref[src];power=1'>[on?"On":"Off"]</a>"}

	user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD><TT>[dat]</TT>", "window=atmo_pump")
	onclose(user, "atmo_pump")

/obj/machinery/atmospherics/binary/passive_gate/initialize()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/binary/passive_gate/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command"))
		return 0

	var/old_on=on
	if("power" in signal.data)
		on = text2num(signal.data["power"])

	if("power_toggle" in signal.data)
		on = !on

	if("status" in signal.data)
		spawn(2)
			broadcast_status()
		return //do not update_icon

	spawn(2)
		broadcast_status()
	update_icon()
	if(old_on!=on)
		investigation_log(I_ATMOS,"was powered [on ? "on" : "off"] by a remote signal")
	return



/obj/machinery/atmospherics/binary/passive_gate/attack_hand(user as mob)
	if(..())
		return
	src.add_fingerprint(usr)
	if(!src.allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	usr.set_machine(src)
	interact(user)
	return

/obj/machinery/atmospherics/binary/passive_gate/Topic(href,href_list)
	if(..())
		return
	if(href_list["power"])
		on = !on
		investigation_log(I_ATMOS,"was turned [on ? "on" : "off"] by [key_name(usr)]")
	usr.set_machine(src)
	src.update_icon()
	src.updateUsrDialog()
	return

/obj/machinery/atmospherics/binary/passive_gate/power_change()
	..()
	update_icon()

/obj/machinery/atmospherics/binary/passive_gate/npc_tamper_act(mob/living/L)
	on = !on
	investigation_log(I_ATMOS,"was turned [on ? "on" : "off"] by [key_name(L)]")

	src.update_icon()
	src.updateUsrDialog()

#undef MAX_PRESSURE
