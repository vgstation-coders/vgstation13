//////////////////////////////
// POWER MACHINERY BASE CLASS
//////////////////////////////

/////////////////////////////
// Definitions
/////////////////////////////

/obj/machinery/power
	name = null
	icon = 'icons/obj/power.dmi'
	anchored = 1.0
	use_power = 0
	idle_power_usage = 0
	active_power_usage = 0

	//For powernet rebuilding
	var/build_status = 0 //1 means it needs rebuilding during the next tick or on usage

	var/obj/machinery/power/terminal/terminal = null //not strictly used on all machines - a placeholder
	var/starting_terminal = 0

/obj/machinery/power/New()
	. = ..()
	machines -= src
	power_machines |= src
	add_power_node()

/obj/machinery/power/proc/add_power_node()
	addNode(/datum/net_node/power)

/obj/machinery/power/initialize()
	..()

	if(starting_terminal)
		find_terminal()

/obj/machinery/power/spawned_by_map_element()
	..()

	find_terminal()

/obj/machinery/power/proc/find_terminal()
	for(var/d in cardinal)
		var/turf/T = get_step(src, d)
		for(var/obj/machinery/power/terminal/term in T)
			if(term && term.dir == turn(d, 180))
				terminal = term
				break
		if(terminal)
			break
	if(terminal)
		terminal.master = src
		update_icon()

/obj/machinery/power/Destroy()
	disconnect_from_network()
	power_machines -= src

	if (terminal)
		terminal.master = null
		terminal = null

	..()

///////////////////////////////
// General procedures
//////////////////////////////

// common helper procs for all power machines
/obj/machinery/power/proc/add_avail(var/amount)
	var/datum/net_node/power/machinery/node = get_power_node()
	if(istype(node))
		node.powerNeeded += amount

/obj/machinery/power/proc/add_load(var/amount)
	var/datum/net_node/power/machinery/node = get_power_node()
	if(istype(node))
		node.powerNeeded -= amount

/obj/machinery/power/proc/surplus()
	var/datum/net/power/net = get_powernet()
	if(!istype(net))
		return 0
	
	return net.excess

/obj/machinery/power/proc/avail()
	var/datum/net/power/net = get_powernet()
	if(!istype(net))
		return 0
	
	return net.avail

/obj/machinery/power/proc/load()
	var/datum/net/power/net = get_powernet()
	if(!istype(net))
		return 0
	
	return net.load

/obj/machinery/power/proc/disconnect_terminal() // machines without a terminal will just return, no harm no fowl.
	return

/obj/machinery/power/proc/get_powernet()
	var/datum/net_node/power/machinery/node = get_power_node()
	if(!istype(node))
		return 0

	return node.net

// returns true if the area has power on given channel (or doesn't require power)
// defaults to power_channel
/obj/machinery/proc/powered(chan = power_channel)
	if(!src.loc)
		return 0

	if(!use_power)
		return 1
	var/area/this_area = get_area(src)
	if(!this_area)
		return 0						// if not, then not powered.

	if((machine_flags & FIXED2WORK) && !anchored)
		return 0

	return this_area.powered(chan)		// return power status of the area.

// increment the power usage stats for an area
// defaults to power_channel
/obj/machinery/proc/use_power(amount, chan = power_channel)
	var/area/this_area = get_area(src)
	if(!this_area)
		return 0						// if not, then not powered.

	if(!powered(chan)) //no point in trying if we don't have power
		return 0

	this_area.use_power(amount, chan)


// called whenever the power settings of the containing area change
// by default, check equipment channel & set flag
// can override if needed
/obj/machinery/proc/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER

		if(!use_auto_lights)
			return
		set_light(light_range_on, light_power_on)

	else
		stat |= NOPOWER

		if(!use_auto_lights)
			return
		set_light(0)


///////////////////////////////////////////
// Static power
//////////////////////////////////////////

/obj/machinery/proc/addStaticPower(value, powerchannel)
	var/area/this_area = get_area(src)
	if(!this_area)
		return
	this_area.addStaticPower(value, powerchannel)

/obj/machinery/proc/removeStaticPower(value, powerchannel)
	addStaticPower(-value, powerchannel)
