/datum/net_node/power
    netType = /datum/net/power
    var/powerNeeded //positive for production, negative for consumption
    var/powered = FALSE

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

//called every powertick when this node isn't receiving power
/datum/net_node/power/proc/power_change()
    return
