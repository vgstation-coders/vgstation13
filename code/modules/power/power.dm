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
	var/datum/powernet/powernet = null
	use_power = 0
	idle_power_usage = 0
	active_power_usage = 0

/obj/machinery/power/New()
	. = ..()
	machines -= src
	power_machines += src
	return .

/obj/machinery/power/Destroy()
	disconnect_from_network()
	power_machines -= src
	..()

///////////////////////////////
// General procedures
//////////////////////////////

// common helper procs for all power machines
/obj/machinery/power/proc/add_avail(var/amount)
	if(powernet)
		powernet.newavail += amount

/obj/machinery/power/proc/add_load(var/amount)
	if(powernet)
		powernet.load += amount

/obj/machinery/power/proc/surplus()
	if(powernet)
		return powernet.avail-powernet.load
	else
		return 0

/obj/machinery/power/proc/avail()
	if(powernet)
		return powernet.avail
	else
		return 0

/obj/machinery/power/proc/disconnect_terminal() // machines without a terminal will just return, no harm no fowl.
	return

// returns true if the area has power on given channel (or doesn't require power)
// defaults to power_channel
/obj/machinery/proc/powered(chan = power_channel)
	if(!src.loc)
		return 0

	if(!use_power)
		return 1

	if(isnull(areaMaster))
		return 0						// if not, then not powered.

	return areaMaster.powered(chan)		// return power status of the area.

// increment the power usage stats for an area
// defaults to power_channel
/obj/machinery/proc/use_power(amount, chan = power_channel)
	if(!src.loc)
		return 0

	if(isnull(areaMaster))
		return

	areaMaster.use_power(amount, chan)

// called whenever the power settings of the containing area change
// by default, check equipment channel & set flag
// can override if needed
/obj/machinery/proc/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
	else

		stat |= NOPOWER

// connect the machine to a powernet if a node cable is present on the turf
/obj/machinery/power/proc/connect_to_network()
	var/turf/T = src.loc

	if(!T || !istype(T))
		return 0

	var/obj/structure/cable/C = T.get_cable_node() // check if we have a node cable on the machine turf, the first found is picked

	if(!C || !C.powernet)
		return 0

	C.powernet.add_machine(src)
	return 1

// remove and disconnect the machine from its current powernet
/obj/machinery/power/proc/disconnect_from_network()
	if(!powernet)
		return 0

	powernet.remove_machine(src)
	return 1

///////////////////////////////////////////
// Powernet handling helpers
//////////////////////////////////////////

// returns all the cables WITHOUT a powernet in neighbors turfs,
// pointing towards the turf the machine is located at
/obj/machinery/power/proc/get_connections()
	. = list()

	var/cdir
	var/turf/T

	for(var/card in cardinal)
		T = get_step(loc, card)
		cdir = get_dir(T, loc)

		for(var/obj/structure/cable/C in T)
			if(C.powernet)
				continue

			if(C.d1 == cdir || C.d2 == cdir)
				. += C

// returns all the cables in neighbors turfs,
// pointing towards the turf the machine is located at
/obj/machinery/power/proc/get_marked_connections()
	. = list()

	var/cdir
	var/turf/T

	for(var/card in cardinal)
		T = get_step(loc, card)
		cdir = get_dir(T, loc)

		for(var/obj/structure/cable/C in T)
			if(C.d1 == cdir || C.d2 == cdir)
				. += C

// returns all the NODES (O-X) cables WITHOUT a powernet in the turf the machine is located at
/obj/machinery/power/proc/get_indirect_connections()
	. = list()

	for(var/obj/structure/cable/C in loc)
		if(C.powernet)
			continue

		if(C.d1 == 0) // the cable is a node cable
			. += C

///////////////////////////////////////////
// GLOBAL PROCS for powernets handling
//////////////////////////////////////////

// returns a list of all power-related objects (nodes, cable, junctions) in turf,
// excluding source, that match the direction d
// if unmarked==1, only return those with no powernet
/proc/power_list(var/turf/T, var/source, var/d, var/unmarked=0, var/cable_only = 0)
	. = list()
	//var/fdir = (!d) ? 0 : turn(d, 180)			// the opposite direction to d (or 0 if d==0)

	for(var/AM in T)
		if(AM == source)						// we don't want to return source
			continue

		if(!cable_only && istype(AM, /obj/machinery/power))
			var/obj/machinery/power/P = AM

			if(P.powernet == 0)					// exclude APCs which have powernet = 0
				continue

			if(!unmarked || !P.powernet)		// if unmarked=1 we only return things with no powernet
				if(d == 0)
					. += P
		else if(istype(AM,/obj/structure/cable))
			var/obj/structure/cable/C = AM

			if(!unmarked || !C.powernet)
				if(C.d1 == d || C.d2 == d)
					. += C

// rebuild all power networks from scratch - only called at world creation or by the admin verb
/proc/makepowernets()
	for(var/datum/powernet/PN in powernets)
		del(PN)

	powernets.len = 0

	for(var/obj/structure/cable/PC in cable_list)
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC, PC.powernet)

// remove the old powernet and replace it with a new one throughout the network.
/proc/propagate_network(var/obj/O, var/datum/powernet/PN)
	//world.log << "propagating new network"
	var/list/worklist = list()
	var/list/found_machines = list()
	var/index = 1
	var/obj/P = null

	worklist += O									// start propagating from the passed object

	while(index <= worklist.len)					//until we've exhausted all power objects
		P = worklist[index]							//get the next power object found
		index++

		if(istype(P, /obj/structure/cable))
			var/obj/structure/cable/C = P

			if(C.powernet != PN)					// add it to the powernet, if it isn't already there
				PN.add_cable(C)

			worklist |= C.get_connections()	//get adjacents power objects, with or without a powernet
		else if(P.anchored && istype(P, /obj/machinery/power))
			var/obj/machinery/power/M = P
			found_machines |= M						// we wait until the powernet is fully propagates to connect the machines
		else
			continue

	// now that the powernet is set, connect found machines to it
	for(var/obj/machinery/power/PM in found_machines)
		if(!PM.connect_to_network())				// couldn't find a node on its turf...
			PM.disconnect_from_network()			//... so disconnect if already on a powernet

// merge two powernets, the bigger (in cable length term) absorbing the other
/proc/merge_powernets(datum/powernet/net1, datum/powernet/net2)
	if(!net1 || !net2)									// if one of the powernet doesn't exist, return
		return

	if(net1 == net2)									// don't merge same powernets
		return

	// we assume net1 is larger. If net2 is in fact larger we are just going to make them switch places to reduce on code.
	if(net1.cables.len < net2.cables.len)				//net2 is larger than net1. Let's switch them around
		var/temp = net1
		net1 = net2
		net2 = temp

	// merge net2 into net1
	for(var/obj/structure/cable/Cable in net2.cables) // merge cables
		net1.add_cable(Cable)

	if(net2) // not nulled, there are still nodes need to be merged
		for(var/obj/machinery/power/Node in net2.nodes) // merge power machines
			if(!Node.connect_to_network())
				Node.disconnect_from_network() // if somehow we can't connect the machine to the new powernet, disconnect it from the old nonetheless

	return net1

// determines how strong could be shock, deals damage to mob, uses power.
// M is a mob who touched wire/whatever
// power_source is a source of electricity, can be powercell, area, apc, cable, powernet or null
// source is an object caused electrocuting (airlock, grille, etc)
// no animations will be performed by this proc.
/proc/electrocute_mob(mob/living/carbon/M, power_source, obj/source, siemens_coeff = 1.0)
	if(istype(M.loc, /obj/mecha))											// feckin mechs are dumb
		return 0

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M

		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves

			if(G.siemens_coefficient == 0)									// to avoid spamming with insulated glvoes on
				return 0

	var/area/source_area

	if(isarea(power_source))
		source_area = power_source
		power_source = source_area.get_apc()

	if(istype(power_source, /obj/structure/cable))
		var/obj/structure/cable/Cable = power_source
		power_source = Cable.powernet

	var/datum/powernet/PN
	var/obj/item/weapon/cell/cell

	if(istype(power_source, /datum/powernet))
		PN = power_source
	else if(istype(power_source, /obj/item/weapon/cell))
		cell = power_source
	else if(istype(power_source, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/apc = power_source
		cell = apc.cell

		if(apc.terminal)
			PN = apc.terminal.powernet
	else if(!power_source)
		return 0
	else
		log_admin("ERROR: /proc/electrocute_mob([M], [power_source], [source]): wrong power_source")
		return 0

	if(!cell && !PN)
		return 0

	var/PN_damage = 0
	var/cell_damage = 0

	if(PN)
		PN_damage = PN.get_electrocute_damage()

	if(cell)
		cell_damage = cell.get_electrocute_damage()

	var/shock_damage = 0

	if(PN_damage >= cell_damage)
		power_source = PN
		shock_damage = PN_damage
	else
		power_source = cell
		shock_damage = cell_damage

	var/drained_hp = M.electrocute_act(shock_damage, source, siemens_coeff)	//zzzzzzap!
	var/drained_energy = drained_hp * 20

	if(source_area)
		source_area.use_power(drained_energy / CELLRATE)
	else if(istype(power_source, /datum/powernet))
		var/drained_power = drained_energy / CELLRATE						// convert from "joules" to "watts"
		PN.load += drained_power
	else if(istype(power_source, /obj/item/weapon/cell))
		cell.use(drained_energy)

	return drained_energy

////////////////////////////////////////////
// POWERNET DATUM PROCS
// each contiguous network of cables & nodes
////////////////////////////////////////////

/datum/powernet/New()
	powernets += src

/datum/powernet/Destroy()
	powernets -= src

/datum/powernet/proc/is_empty()
	return !cables.len && !nodes.len

// remove a cable from the current powernet
// if the powernet is then empty, delete it
// warning : this proc DON'T check if the cable exists
/datum/powernet/proc/remove_cable(obj/structure/cable/C)
	cables -= C
	C.powernet = null

	if(is_empty())	// the powernet is now empty...
		del(src)	// ... delete it

// add a cable to the current powernet
// warning : this proc DON'T check if the cable exists
/datum/powernet/proc/add_cable(obj/structure/cable/C)
	if(C.powernet)						// if C already has a powernet...
		if(C.powernet == src)
			return
		else
			C.powernet.remove_cable(C)	// ..remove it

	C.powernet = src
	cables += C

// remove a power machine from the current powernet
// if the powernet is then empty, delete it
// warning : this proc DON'T check if the machine exists
/datum/powernet/proc/remove_machine(obj/machinery/power/M)
	nodes -= M
	M.powernet = null

	if(is_empty())	// the powernet is now empty...
		del(src)	// ... delete it

// add a power machine to the current powernet
// warning : this proc DON'T check if the machine exists
/datum/powernet/proc/add_machine(obj/machinery/power/M)
	if(M.powernet)							// if M already has a powernet...
		if(M.powernet == src)
			return
		else
			M.disconnect_from_network()		// ..remove it

	M.powernet = src
	nodes += M

// handles the power changes in the powernet
// called every ticks by the powernet controller
/datum/powernet/proc/reset()
	// see if there's a surplus of power remaining in the powernet and stores unused power in the SMES
	netexcess = avail - load

	if(netexcess > 100 && nodes && nodes.len) // if there was excess power last cycle
		for(var/obj/machinery/power/smes/S in nodes) // find the SMESes in the network
			S.restore() // and restore some of the power that was used

	// updates the viewed load (as seen on power computers)
	viewload = 0.8 * viewload + 0.2 * load
	viewload = round(viewload)

	// reset the powernet
	load = 0
	avail = newavail
	newavail = 0

/datum/powernet/proc/get_electrocute_damage()
	// cube root of power times 1,5 to 2 in increments of 10^-1
	// for instance, gives an average of 38 damage for 10k W, 81 damage for 100k W and 175 for 1M W
	// best you're getting with BYOND's mathematical funcs. Not even a fucking exponential or neperian logarithm
	return round(avail ** (1 / 3) * (rand(100, 125) / 100))

////////////////////////////////////////////////
// Misc.
///////////////////////////////////////////////

// return a knot cable (O-X) if one is present in the turf
// null if there's none
/turf/proc/get_cable_node()
	if(!istype(src, /turf/simulated/floor))
		return null

	for(var/obj/structure/cable/C in src)
		if(C.d1 == 0)
			return C

/area/proc/get_apc()
	for(var/area/RA in src.related)
		var/obj/machinery/power/apc/FINDME = locate() in RA

		if(FINDME)
			return FINDME

/obj/machinery/proc/addStaticPower(value, powerchannel)
	if(!areaMaster)
		return
	areaMaster.addStaticPower(value, powerchannel)
/obj/machinery/proc/removeStaticPower(value, powerchannel)
	addStaticPower(-value, powerchannel)
