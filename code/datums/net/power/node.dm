/datum/net_node/power
    netType = /datum/net/power
    var/powerNeeded //positive for production, negative for consumption
    var/powered = FALSE
    var/last_powered = FALSE //for post_tick

/datum/net_node/power/get_connections()
    . = list()
    for(var/atom/A in get_turf(src))
        if(!A.net_nodes)
            continue

        for(var/datum/net_node/power/cable/node in A.net_nodes)
            if(!istype(node))
                continue

            if(node.d2 == 0)
                continue

            . += node

//called every powertick
//this is because of how old powernets worked
//static power is can be achieved by overriding this
/datum/net_node/power/proc/reset()
    powerNeeded = 0

/datum/net_node/power/proc/post_tick()
    if(powered != last_powered)
        parent.power_change()
        last_powered = powered

/datum/net_node/power/proc/is_powered()
    if(!active)
        return 0
    return powered