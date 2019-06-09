obj/machinery/atmospherics/trinary/mixer
	icon = 'icons/obj/atmospherics/mixer.dmi'
	icon_state = "intact_off"

	name = "Gas mixer"

	mirror = /obj/machinery/atmospherics/trinary/mixer/mirrored

	var/on = 0

	var/target_pressure = ONE_ATMOSPHERE
	var/node1_concentration = 0.5
	var/node2_concentration = 0.5

	//node 3 is the outlet, nodes 1 & 2 are intakes

	ex_node_offset = 5

obj/machinery/atmospherics/trinary/mixer/update_icon()
	if(stat & NOPOWER)
		icon_state = "intact_off"
	else if(node2 && node3 && node1)
		icon_state = "intact_[on?("on"):("off")]"
	else
		icon_state = "intact_off"
		on = 0
	..()

obj/machinery/atmospherics/trinary/mixer/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		on = !on
		update_icon()

obj/machinery/atmospherics/trinary/mixer/New()
	..()
	air3.volume = 300


obj/machinery/atmospherics/trinary/mixer/process()
	. = ..()
	if(!on)
		return

	var/output_starting_pressure = air3.return_pressure()
	var/pressure_delta = target_pressure - output_starting_pressure
	
	if(pressure_delta > 0.01 && ((air1.temperature > 0 && air2.temperature > 0) || air3.temperature > 0))
		var/output_volume = air3.volume + (network3 ? network3.volume : 0)
		//get gas from input #1
		var/air_temperature1 = (air1.temperature > 0 ) ? air1.temperature : air3.temperature
		var/transfer_moles1 = ((node1_concentration * pressure_delta) * output_volume) / (air_temperature1 * R_IDEAL_GAS_EQUATION)
		//get gas from input #2
		var/air_temperature2 = (air2.temperature > 0 ) ? air2.temperature : air3.temperature
		var/transfer_moles2 = ((node2_concentration * pressure_delta) * output_volume) / (air_temperature2 * R_IDEAL_GAS_EQUATION)

		//fix the mix if one of the inputs has insufficient gas
		var/air1_moles = air1.total_moles()
		var/air2_moles = air2.total_moles()
		if((air1_moles < transfer_moles1) || (air2_moles < transfer_moles2))
			if(!transfer_moles1 || !transfer_moles2)
				return
			var/ratio = min(air1_moles/transfer_moles1, air2_moles/transfer_moles2)
			transfer_moles1 *= ratio
			transfer_moles2 *= ratio
		
		//actually transfer the gas
		var/datum/gas_mixture/removed1 = air1.remove(transfer_moles1)
		var/datum/gas_mixture/removed2 = air2.remove(transfer_moles2)
		air3.merge(removed1)
		air3.merge(removed2)
		
		if(network1)
			network1.update = 1
		if(network2)
			network2.update = 1
		if(network3)
			network3.update = 1

	return 1

obj/machinery/atmospherics/trinary/mixer/attack_hand(user as mob)
	if(..())
		return
	src.add_fingerprint(usr)
	if(!src.allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	usr.set_machine(src)
	var/dat = {"<b>Power: </b><a href='?src=\ref[src];power=1'>[on?"On":"Off"]</a><br>
				<b>Desirable output pressure: </b>
				[target_pressure]kPa | <a href='?src=\ref[src];set_press=1'>Change</a>
				<br>
				<b>Node 1 ([dir2text(pipe_flags & IS_MIRROR ? dir : turn(dir, -180))]) Concentration:</b>
				<a href='?src=\ref[src];node1_c=-0.1'><b>-</b></a>
				<a href='?src=\ref[src];node1_c=-0.01'>-</a>
				[node1_concentration]([node1_concentration*100]%)
				<a href='?src=\ref[src];node1_c=0.01'><b>+</b></a>
				<a href='?src=\ref[src];node1_c=0.1'>+</a>
				<br>
				<b>Node 2 ([dir2text(turn(dir, -90))]) Concentration:</b>
				<a href='?src=\ref[src];node2_c=-0.1'><b>-</b></a>
				<a href='?src=\ref[src];node2_c=-0.01'>-</a>
				[node2_concentration]([node2_concentration*100]%)
				<a href='?src=\ref[src];node2_c=0.01'><b>+</b></a>
				<a href='?src=\ref[src];node2_c=0.1'>+</a>
				"}

	user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD><TT>[dat]</TT>", "window=atmo_mixer;size=450x110")
	onclose(user, "atmo_mixer")
	return

obj/machinery/atmospherics/trinary/mixer/Topic(href,href_list)
	if(..())
		return
	if(href_list["power"])
		on = !on
	if(href_list["set_press"])
		var/new_pressure = input(usr,"Enter new output pressure (0-4500kPa)","Pressure control",src.target_pressure) as num
		src.target_pressure = max(0, min(4500, new_pressure))
	if(href_list["node1_c"])
		var/value = text2num(href_list["node1_c"])
		src.node1_concentration = max(0, min(1, src.node1_concentration + value))
		src.node2_concentration = max(0, min(1, src.node2_concentration - value))
	if(href_list["node2_c"])
		var/value = text2num(href_list["node2_c"])
		src.node2_concentration = max(0, min(1, src.node2_concentration + value))
		src.node1_concentration = max(0, min(1, src.node1_concentration - value))
	src.update_icon()
	src.updateUsrDialog()
	return

/obj/machinery/atmospherics/trinary/mixer/mirrored
	icon_state = "intactm_off"
	pipe_flags = IS_MIRROR

/obj/machinery/atmospherics/trinary/mixer/mirrored/update_icon()
	..()
	if(stat & NOPOWER)
		icon_state = "intactm_off"
	else if(node2 && node3 && node1)
		icon_state = "intactm_[on?("on"):("off")]"
	else
		icon_state = "intactm_off"
		on = 0
	return
