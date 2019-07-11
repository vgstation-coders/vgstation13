/datum/net_node/power/cable
    var/d1
    var/d2

/datum/net_node/power/cable/New(dir1, dir2) //dir2 is optional
    d1 = dir1
    d2 = dir2

/datum/net_node/power/cable/get_connections()
    . = list()
    
    //d1
    for(var/atom/A in get_step(src, d1))
        if(!A.net_nodes)
            continue

        for(var/datum/net_node/node in A.net_nodes)
            var/datum/net_node/power/cable/C = node
            if(!istype(node))
                continue
            
            var/inv_d1 = turn(d1, 180)
            if(C.d1 == inv_d1 || C.d2 == inv_d1)
                . += node
    
    //d2
    for(var/atom/A in get_step(src, d2))
        if(!A.net_nodes)
            continue

        for(var/datum/net_node/node in A.net_nodes)
            var/datum/net_node/power/cable/C = node
            if(!istype(node))
                continue
            
            var/inv_d2 = turn(d2, 180)
            if(C.d1 == inv_d2 || C.d2 == inv_d2)
                . += node
