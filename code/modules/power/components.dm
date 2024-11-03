/**
 * A desperate attempt at component-izing power transmission shit.
 *
 * The idea being that objects that aren't /obj/machinery/power can hook into power systems.
 */

/datum/power_connection
	var/obj/parent=null

	//For powernet rebuilding
	var/channel = EQUIP // EQUIP, ENVIRON or LIGHT.
	var/build_status = 0 //1 means it needs rebuilding during the next tick or on usage
	var/connected = FALSE
	var/datum/powernet/powernet = null

	var/power_priority = POWER_PRIORITY_NORMAL
	var/is_priority_locked = FALSE // If true, do not allow priority to be changed

	var/machine_flags = 0 // Emulate machinery flags.
	var/inMachineList = 0

	var/turf/turf = null // Updated in addToTurf()/removeFromTurf()

	//for the power monitor
	var/monitoring_enabled = FALSE // Whether to show up on the monitor at all
	var/monitor_demand = 0 // How much power is being requested

	var/monitor_isbattery = FALSE // If true, a charge meter will be displayed
	var/monitor_charging = MONITOR_STATUS_BATTERY_STEADY
	var/monitor_charge = 100

/datum/power_connection/New(var/obj/parent)
	src.parent = parent
	power_machines |= src

	// Used for updating turf power_connection lists when moved.
	parent.register_event(/event/moved, src, nameof(src::parent_moved()))
	addToTurf()

/datum/power_connection/Destroy()
	disconnect()
	power_machines -= parent

	// Remember to tell our turf that we're gone.
	removeFromTurf()
	parent.unregister_event(/event/moved, src, nameof(src::parent_moved()))
	..()

// CALLBACK from /event/moved.
// This should never happen, except when Singuloth is doing its shenanigans, as rebuilding
//  powernets is extremely slow.
/datum/power_connection/proc/parent_moved(atom/movable/mover)
	removeFromTurf() // Removes old ref
	addToTurf() // Adds new one

// Powernets need to know what power equipment is on a turf when adding a cable to it.
// So, we tell the turf to tell the powernet about us, since we don't have a loc.
/datum/power_connection/proc/addToTurf()
	// Get AND REMEMBER the turf that's going to hold the ref.
	turf = get_turf(parent)
	if(!turf)
		// We've been sucked into a black hole, god help us
		return
	if(turf.power_connections == null)
		turf.power_connections = list(src)
	else
		turf.power_connections += src

/datum/power_connection/proc/removeFromTurf()
	if(!turf || !turf.power_connections)
		return
	// We don't grab the current turf here because we're removing the reference from the turf that has it.
	turf.power_connections -= src

	// Clean up after ourselves.
	if(turf.power_connections.len == 0)
		turf.power_connections = null

	// Tell the rest of the code that we're turfless.
	// EVEN THOUGH THE REST OF THE CODE SHOULDN'T CARE.
	turf=null

// Called when powernet reports excess watts.
/datum/power_connection/proc/excess(var/netexcess)
	return

/datum/power_connection/proc/process()
	return // auto_use_power() :^)

// common helper procs for all power machines
/datum/power_connection/proc/add_avail(var/amount)
	if(get_powernet())
		powernet.newavail += amount

/datum/power_connection/proc/add_load(var/amount, var/priority = power_priority)
	if(get_powernet())
		powernet.add_load(amount, priority)

/datum/power_connection/proc/get_surplus()
	if(get_powernet())
		return powernet.avail-powernet.get_load()
	else
		return 0

/datum/power_connection/proc/get_avail()
	if(get_powernet())
		return powernet.avail
	else
		return 0

/datum/power_connection/proc/get_satisfaction(var/priority = power_priority)
	if (get_powernet())
		return powernet.get_satisfaction(priority)
	else
		return 0

/datum/power_connection/proc/get_powernet()
	check_rebuild()
	return powernet

/datum/power_connection/proc/check_rebuild()
	if(!build_status)
		return 0
	for(var/obj/structure/cable/C in parent.loc)
		if(C.check_rebuild())
			return 1

/datum/power_connection/proc/getPowernetNodes()
	if(!get_powernet())
		return list()
	return powernet.nodes


// returns true if the area has power on given channel (or doesn't require power)
// defaults to power_channel
/datum/power_connection/proc/powered(chan = channel)
	if(!parent || !parent.loc)
		return 0

	// If you're using a consumer, you need power.
	//if(use_power == MACHINE_POWER_USE_NONE)
	//	return 1
	var/area/parent_area = get_area(parent)
	if(!parent_area)
		return 0						// if not, then not powered.

	if((machine_flags & FIXED2WORK) && !parent.anchored)
		return 0

	return parent_area.powered(chan)		// return power status of the area.

// increment the power usage stats for an area
// defaults to power_channel
/datum/power_connection/proc/use_power(amount, chan = channel)
	var/area/parent_area = get_area(parent)
	if(!parent_area)
		return 0						// if not, then not powered.

	if(!powered(chan)) //no point in trying if we don't have power
		return 0

	parent_area.use_power(amount, chan)

// connect the machine to a powernet if a node cable is present on the turf
/datum/power_connection/proc/connect(var/obj/structure/cable/C)
	var/turf/T = get_turf(parent)

	if (!T)
		return FALSE

	if (!C)
		C = T.get_cable_node() // check if we have a node cable on the machine turf, the first found is picked

	if(!C || !C.get_powernet())
		return FALSE

	C.powernet.add_connection(src)
	connected = TRUE
	return TRUE

// remove and disconnect the machine from its current powernet
/datum/power_connection/proc/disconnect()
	connected = FALSE
	if(!get_powernet())
		build_status = 0
		return FALSE

	powernet.remove_component(src)
	return TRUE

// returns all the cables WITHOUT a powernet in neighbors turfs,
// pointing towards the turf the machine is located at
/datum/power_connection/proc/get_connections()
	. = list()

	var/cdir
	var/turf/T

	for(var/card in cardinal)
		T = get_step(parent.loc, card)
		cdir = get_dir(T, parent.loc)

		for(var/obj/structure/cable/C in T)
			if(C.get_powernet())
				continue

			if(C.d1 == cdir || C.d2 == cdir)
				. += C

// returns all the cables in neighbors turfs,
// pointing towards the turf the machine is located at
/datum/power_connection/proc/get_marked_connections()
	. = list()

	var/cdir
	var/turf/T

	for(var/card in cardinal)
		T = get_step(parent.loc, card)
		cdir = get_dir(T, parent.loc)

		for(var/obj/structure/cable/C in T)
			if(C.d1 == cdir || C.d2 == cdir)
				. += C

// returns all the NODES (O-X) cables WITHOUT a powernet in the turf the machine is located at
/datum/power_connection/proc/get_indirect_connections()
	. = list()

	for(var/obj/structure/cable/C in parent.loc)
		if(C.get_powernet())
			continue

		if(C.d1 == 0) // the cable is a node cable
			. += C

////////////////////////////////////////////////
// Misc.
///////////////////////////////////////////////

/datum/power_connection/proc/addStaticPower(value, powerchannel)
	var/area/parent_area = get_area(parent)
	if(!parent_area)
		return
	parent_area.addStaticPower(value, powerchannel)

/datum/power_connection/proc/removeStaticPower(value, powerchannel)
	addStaticPower(-value, powerchannel)

/datum/power_connection/proc/get_monitor_status_template()
	return list(
		"ref" = "\ref[src]",
		"name" = parent.name,

		"priority" = power_priority,
		"priority_locked" = is_priority_locked,
		"demand" = monitor_demand,

		"isbattery" = monitor_isbattery,
		"charging" = monitor_charging,
		"charge" = monitor_charge
	)

/datum/power_connection/proc/get_monitor_status()
	if (!monitoring_enabled)
		return null
	return list("\ref[src]" = get_monitor_status_template())

/datum/power_connection/proc/change_priority(value, id)
	if(!is_priority_locked && id == "\ref[src]")
		power_priority = value
		return TRUE

///////////////////////////
// POWER CONSUMERS
///////////////////////////

/datum/power_connection/consumer
	var/enabled = 0

	var/use_power = MACHINE_POWER_USE_NONE // 1=idle, 2=active
	var/idle_usage = 0 // watts
	var/active_usage = 0

/datum/power_connection/consumer/New(var/obj/parent)
	..(parent)

/datum/power_connection/consumer/process()
	if(use_power != MACHINE_POWER_USE_NONE)
		auto_use_power()

/datum/power_connection/consumer/proc/auto_use_power()
	if(!powered(channel))
		return 0

	switch (use_power)
		if (MACHINE_POWER_USE_IDLE)
			use_power(idle_usage, channel)
		if (MACHINE_POWER_USE_ACTIVE)
			use_power(active_usage, channel)
	return 1

/datum/power_connection/consumer/get_monitor_status_template()
	var/template = ..()
	if (template)
		switch (use_power)
			if (MACHINE_POWER_USE_IDLE)
				template["demand"] = idle_usage
			if (MACHINE_POWER_USE_ACTIVE)
				template["demand"] = active_usage
	return template

//////////////////////
/// TERMINAL RECEIVER
//////////////////////
/datum/power_connection/consumer/terminal
	var/obj/machinery/power/terminal/terminal=null

/datum/power_connection/consumer/terminal/use_power(var/watts, var/_channel_NOT_USED)
	add_load(watts)

/datum/power_connection/consumer/terminal/connect()
	..()

	for(var/d in cardinal)
		var/turf/T = get_step(parent, d)
		for(var/obj/machinery/power/terminal/term in T)
			if(term && term.dir == turn(d, 180))
				terminal = term
				break
		if(terminal)
			break
	if(terminal)
		terminal.master = parent
		//parent.update_icon()

/datum/power_connection/consumer/terminal/Destroy()
	if (terminal)
		terminal.master = null
		terminal = null

	..()
////////////////////////////////
/// DIRECT CONNECTION RECEIVER
////////////////////////////////
/datum/power_connection/consumer/cable
	var/obj/structure/cable/cable=null

/datum/power_connection/consumer/cable/use_power(var/watts, var/_channel_NOT_USED)
	add_load(watts)

// connect the machine to a powernet if a node cable is present on the turf
/datum/power_connection/consumer/cable/connect(var/obj/structure/cable/C)
	// OVERRIDES!
	var/turf/T = get_turf(parent)

	if (!T)
		return FALSE

	if (!C)
		C = T.get_cable_node() // check if we have a node cable on the machine turf, the first found is picked

	if(!C || !C.get_powernet())
		return FALSE

	cable = C
	cable.powernet.add_connection(src)
	connected = TRUE
	return TRUE


// returns true if a machine can be powered through this cable
/datum/power_connection/consumer/cable/powered(chan = channel)
	if(!parent || !parent.loc)
		return FALSE

	// If you're using a consumer, you need power.
	//if(use_power == MACHINE_POWER_USE_NONE)
	//	return 1

	if(isnull(powernet) || !powernet || !cable)
		return FALSE					// if not, then not powered.

	if((machine_flags & FIXED2WORK) && !parent.anchored)
		return FALSE

	return TRUE // We have a powernet and a cable, so we're okay.
