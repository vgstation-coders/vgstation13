/datum/net/power
    node_types = list(/datum/net_node/power)
    var/load = 0				// the current load on the powernet, updated in powertick
    var/avail = 0				// the current produced power in the powernet, updated in powertick
    var/excess = 0			// excess power on the powernet, updated in powertick

/datum/net/power/New()
    . = ..()
    powernets += src

/datum/net/power/Destroy()
    . = ..()
    powernets -= src

//merges with another net
/datum/net/power/absorb_net(var/datum/net/power/other_net)
    if(!..())
        return 0
    
    load += other_net.load
    avail += other_net.avail
    excess += other_net.excess

/datum/net/power/proc/powertick()
    var/list/battery_nodes = list() //saving batteries for last to either gather up the excess or fill the missing power

    var/power = 0
    load = 0
    avail = 0
    excess = 0
    for(var/datum/net_node/power/node in nodes)
        if(istype(node, /datum/net_node/power/storage))
            battery_nodes += node
            continue

        power += node.powerNeeded

        //for readouts
        if(node.powerNeeded > 0)
            avail += node.powerNeeded
        else if(node.powerNeeded < 0)
            load += node.powerNeeded

    //a little copy pasta ish but it gets the job done
    if(power > 0) //we got excess, lets store it
        while(battery_nodes.len && power > 0)
            var/datum/net_node/power/storage/S = battery_nodes[battery_nodes.len]
            battery_nodes.len--

            power = S.try_add_power(power)
    else if(power < 0) //oh god oh fuck we dont have enough, better hope we can even it out
        while(battery_nodes.len && power < 0)
            var/datum/net_node/power/storage/S = battery_nodes[battery_nodes.len]
            battery_nodes.len--

            power -= S.try_remove_power(power)

    for(var/datum/net_node/power/node in nodes)
        node.reset()
        node.powered = (power >= 0)
        node.post_tick()
    
    //excess can be negative, this could also be in an else to the if above, but i dunno, why make it hard for the guys
    excess = power

/datum/net/power/proc/get_electrocute_damage()
    // cube root of power times 1,5 to 2 in increments of 10^-1
    // for instance, gives an average of 38 damage for 10k W, 81 damage for 100k W and 175 for 1M W
    // best you're getting with BYOND's mathematical funcs. Not even a fucking exponential or neperian logarithm
    return round(avail ** (1 / 3) * (rand(100, 125) / 100))

// *************
// GLOBAL PROCS
// *************

// rebuild all power networks from scratch - only called at world creation or by the admin verb
/proc/makepowernets()
    var/list/new_nets = list()
    for(var/datum/net_node/power/cable/cable in cable_nodes)
        if(!istype(cable))
            continue
        if(!(cable.net in new_nets)) //have we already propagated over this node?
            var/datum/net/power/new_net = new /datum/net/power()
            cable.propagate(new_net)
            new_nets += new_net

// determines how strong could be shock, deals damage to mob, uses power.
// M is a mob who touched wire/whatever
// power_source is a source of electricity, can be powercell, area, apc, cable, powernet or null
// source is an object caused electrocuting (airlock, grille, etc)
// no animations will be performed by this proc.
/proc/electrocute_mob(mob/living/M, power_source, obj/source, siemens_coeff = 1.0)
    //insulation
    if(istype(M.loc, /obj/mecha))											// feckin mechs are dumb
        return 0
    if(istype(M, /mob/living/carbon/human))
        var/mob/living/carbon/human/H = M
        if(H.gloves)
            var/obj/item/clothing/gloves/G = H.gloves
            if(G.siemens_coefficient == 0)									// to avoid spamming with insulated glvoes on
                return 0

    //getting net or cell
    var/datum/net/power/net
    var/obj/item/weapon/cell/cell
    if(isarea(power_source))
        var/area/source_area = power_source
        var/obj/machinery/power/apc/apc = source_area.areaapc
        cell = apc.get_cell()
        if(apc.terminal)
            net = apc.terminal.get_powernet()
    else if(istype(power_source, /datum/net/power))
        net = power_source
    else if(istype(power_source, /obj/item/weapon/cell))
        cell = power_source
    else if(!power_source)
        return 0
    else if(istype(power_source, /atom))
        var/atom/A = power_source
        net = A.get_powernet()

    if(!istype(net) && !istype(cell))
        log_admin("ERROR: /proc/electrocute_mob([M], [power_source], [source]): wrong power_source, couldn't find cell or net")
        return 0

    //calculating the damage
    var/net_damage
    var/cell_damage
    if(net)
        net_damage = net.get_electrocute_damage()
    if(cell)
        cell_damage = cell.get_electrocute_damage()

    //deciding which damage to apply
    var/shock_damage
    if(net_damage >= cell_damage)
        shock_damage = net_damage
    else
        shock_damage = cell_damage

    //zap
    M.electrocute_act(shock_damage, source, siemens_coeff)	//zzzzzzap!