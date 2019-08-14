/datum/net_node/power
    netType = /datum/net/power
    var/powerNeeded //positive for production, negative for consumption
    var/powered = FALSE
    var/last_powered = FALSE //for post_tick
    var/process = TRUE

/datum/net_node/power/get_connections()
    . = list()
    if(!active)
        return .

    for(var/atom/A in get_turf(parent))
        if(!A.net_nodes)
            continue

        for(var/datum/net_node/power/cable/node in A.net_nodes)
            if(!istype(node))
                continue

            if(node == src)
                continue

            if(!node.connects_to_dir(0)) //we want a stump
                continue

            . |= node

//called every powertick
//this is because of how old powernets worked
//static power is can be achieved by overriding this
/datum/net_node/power/proc/pre_tick()
    if(!process)
        return
    if(istype(parent, /obj))
        var/obj/O = parent
        O.process()

/datum/net_node/power/proc/post_tick()
    if(powered != last_powered)
        parent.power_change()
        last_powered = powered
    
    //if(powered) //prevent machine flicking on and off
    powerNeeded = 0
/datum/net_node/power/proc/is_powered()
    if(!active)
        return 0
    return powered

/datum/net_node/power/connects_to_dir(var/dir)
    if(!active)
        return FALSE
    return (dir == 0)