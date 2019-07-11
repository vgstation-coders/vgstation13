/datum/net_node/power
    netType = /datum/net/power

/datum/net_node/power/proc/get_connections()
    . = list()
    for(var/atom/A in get_turf(src))
        if(!A.net_nodes)
            continue

        for(var/datum/net_node/node in A.net_nodes)
            if(!istype(node, src.type))
                continue
            
            . += node

