/obj/machinery/power/generator
	name = "thermoelectric generator"
	desc = "It's a high efficiency thermoelectric generator."
	icon_state = "teg"
	density = 1
	anchored = 0

	use_power = MACHINE_POWER_USE_NONE
	idle_power_usage = 100 //Watts, I hope.  Just enough to do the computer and display things.

	var/thermal_efficiency = 0.65

	var/tmp/obj/machinery/atmospherics/binary/circulator/circ1
	var/tmp/obj/machinery/atmospherics/binary/circulator/circ2

	var/tmp/last_gen    = 0
	var/tmp/lastgenlev  = 0 // Used in update_icon()
	var/const/max_power = 3000000 // Amount of W produced at which point the meter caps.

	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/power/generator/New()
	..()

	spawn(1)
		reconnect()

	global.pipenet_processing_objects += src

/obj/machinery/power/generator/Destroy()
	. = ..()
	if(circ1)
		circ1.linked_generator = null
		circ1 = null

	if(circ2)
		circ2.linked_generator = null
		circ2 = null

	global.pipenet_processing_objects -= src

/obj/item/weapon/paper/generator
	name = "paper - 'generator instructions'"
	info = "<h2>How to setup the Thermo-Generator</h2><ol> <li>To the top right is a room full of canisters; to the bottom there is a room full of pipes. Connect C02 canisters to the pipe room's top connector ports, the canisters will help act as a buffer so only remove them when refilling the gas..</li> <li>Connect 3 plasma and 2 oxygen canisters to the bottom ports of the pipe room.</li> <li>Turn on all the pumps and valves in the room except for the one connected to the yellow pipe and red pipe, no adjustments to the pump strength needed.</li> <li>Look into the camera monitor to see the burn chamber. When it is full of plasma, press the igniter button.</li> <li>Setup the SMES cells in the North West of Engineering and set an input of half the max; and an output that is half the input.</li></ol>Well done, you should have a functioning generator generating power. If the generator stops working, and there is enough gas and it's hot and cold, it might mean there is too much pressure and you need to turn on the pump that is connected to the red and yellow pipes to release the pressure. Make sure you don't take out too much pressure though.<br>You optimize the generator you must work out how much power your station is using and lowering the circulation pumps enough so that the generator doesn't create excess power, and it will allow the generator to powering the station for a longer duration, without having to replace the canisters. "

//generators connect in dir and reverse_dir(dir) directions
//mnemonic to determine circulator/generator directions: the cirulators orbit clockwise around the generator
//so a circulator to the NORTH of the generator connects first to the EAST, then to the WEST
//and a circulator to the WEST of the generator connects first to the NORTH, then to the SOUTH
//note that the circulator's outlet dir is it's always facing dir, and it's inlet is always the reverse
/obj/machinery/power/generator/proc/reconnect()
	if(circ1)
		circ1.linked_generator = null
		circ1 = null

	if(circ2)
		circ2.linked_generator = null
		circ2 = null

	if(!src.loc || !anchored)
		return

	if(src.dir & (EAST|WEST))
		circ1 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,WEST)
		if(circ1 && !circ1.anchored)
			circ1 = null

		circ2 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,EAST)
		if(circ2 && !circ2.anchored)
			circ2 = null

		if(circ1 && circ2)
			if(circ1.dir != NORTH || circ2.dir != SOUTH)
				circ1 = null
				circ2 = null

	else if(src.dir & (NORTH|SOUTH))
		circ1 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,NORTH)
		circ2 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,SOUTH)

		if(circ1 && circ2 && (circ1.dir != EAST || circ2.dir != WEST))
			circ1 = null
			circ2 = null

	if(circ1)
		circ1.linked_generator = src

	if(circ2)
		circ2.linked_generator = src

	update_icon()

/obj/machinery/power/generator/wrenchAnchor(var/mob/user, var/obj/item/I)
	. = ..()
	if(!.)
		return
	reconnect()

/obj/machinery/power/generator/proc/operable()
	return circ1 && circ2 && anchored && !(stat & (FORCEDISABLE|BROKEN|NOPOWER))

/obj/machinery/power/generator/update_icon()
	overlays = 0

	if(!operable())
		return

	overlays += image(icon = icon, icon_state = "teg_mid")

	if(lastgenlev != 0)
		overlays += image(icon = icon, icon_state = "teg-op[lastgenlev]")

// We actually tick power gen on the pipenet process to make sure we're synced with pipenet updates.
/obj/machinery/power/generator/pipenet_process()
	if(!operable())
		return

	var/datum/gas_mixture/air1 = circ1.return_transfer_air()
	var/datum/gas_mixture/air2 = circ2.return_transfer_air()

	if(air1 && air2)
		var/air1_heat_capacity = air1.heat_capacity()
		var/air2_heat_capacity = air2.heat_capacity()
		var/delta_temperature = abs(air2.temperature - air1.temperature)

		if(delta_temperature > 0 && air1_heat_capacity > 0 && air2_heat_capacity > 0)
			var/energy_transfer = delta_temperature * air2_heat_capacity * air1_heat_capacity / (air2_heat_capacity + air1_heat_capacity)
			var/heat = energy_transfer * (1 - thermal_efficiency)
			last_gen = energy_transfer * thermal_efficiency * 0.3

			//If our circulators are lubed get extra power
			if(circ1.reagents.get_reagent_amount(LUBE)>=1)
				last_gen *= 1 + ((circ1.volume_capacity_used * 100) / 16.5) //Up to x3 if flow capacity is 33%
			if(circ2.reagents.get_reagent_amount(LUBE)>=1)
				last_gen *= 1 + ((circ2.volume_capacity_used * 100) / 16.5)

			if(air2.temperature > air1.temperature)
				air2.temperature = air2.temperature - energy_transfer/air2_heat_capacity
				air1.temperature = air1.temperature + heat/air1_heat_capacity
			else
				air2.temperature = air2.temperature + heat/air2_heat_capacity
				air1.temperature = air1.temperature - energy_transfer/air1_heat_capacity

	//Transfer the air.
	circ1.air2.merge(air1)
	circ2.air2.merge(air2)

	//Update the gas networks.
	if(circ1.network2)
		circ1.network2.update = TRUE

	if(circ2.network2)
		circ2.network2.update = TRUE

	//Update icon overlays and power usage only if displayed level has changed.
	var/genlev = clamp(round(11 * last_gen / max_power), 0, 11)

	if(last_gen > 100 && genlev == 0)
		genlev = 1

	if(genlev != lastgenlev)
		lastgenlev = genlev
		update_icon()

/obj/machinery/power/generator/process()
	if (operable())
		add_avail(last_gen)


/obj/machinery/power/generator/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	tgui_interact(user)

/obj/machinery/power/generator/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TEG")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/power/generator/ui_data()
	var/list/data = list()

	data["vertical"] = dir & (NORTH | SOUTH)
	data["output"] = format_watts(last_gen)

	if(circ1)
		data["first_flow_cap"] = round(circ1.volume_capacity_used * 100)
		data["first_in_pressure"] = round(circ1.air1.return_pressure(), 1)
		data["first_in_temp"] = round(circ1.air1.temperature, 1)
		data["first_out_pressure"] = round(circ1.air2.return_pressure(), 1)
		data["first_out_temp"] = round(circ1.air2.temperature, 1)

	if(circ2)
		data["second_flow_cap"] = round(circ2.volume_capacity_used * 100)
		data["second_in_pressure"] = round(circ2.air1.return_pressure(), 1)
		data["second_in_temp"] = round(circ2.air1.temperature, 1)
		data["second_out_pressure"] = round(circ2.air2.return_pressure(), 1)
		data["second_out_temp"] = round(circ2.air2.temperature, 1)

	return data

/obj/machinery/power/generator/power_change()
	..()
	update_icon()

/obj/machinery/power/generator/verb/rotate_clock()
	set category = "Object"
	set name = "Rotate Generator (Clockwise)"
	set src in view(1)

	if (usr.isUnconscious() || usr.restrained()  || anchored)
		return

	src.dir = turn(src.dir, -90)

/obj/machinery/power/generator/verb/rotate_anticlock()
	set category = "Object"
	set name = "Rotate Generator (Counterclockwise)"
	set src in view(1)

	if (usr.isUnconscious() || usr.restrained()  || anchored)
		return

	src.dir = turn(src.dir, 90)
