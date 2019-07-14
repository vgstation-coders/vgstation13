/datum/net_node/power
    netType = /datum/net/power
    var/powerNeeded //positive for production, negative for consumption
    var/powered = TRUE //maybe flags

/datum/net_node/power/get_connections()
    . = list()
    for(var/atom/A in get_turf(src))
        if(!A.net_nodes)
            continue

        for(var/datum/net_node/node in A.net_nodes)
            if(!istype(node, src.type))
                continue
            
            . += node

//called every powertick, should be used to reset stuff like NOPOWER flags
/datum/net_node/power/proc/reset()
    powered = TRUE

//called every powertick when this node isn't receiving power
/datum/net_node/power/proc/power_off()
    powered = FALSE
