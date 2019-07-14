/datum/net_node/power/cable
    var/d1
    var/d2

/datum/net_node/power/cable/New(dir1, dir2) //dir2 is optional
    . = ..()
    setDirs(dir1, dir2)
    cable_nodes += src

/datum/net_node/power/cable/proc/setDirs(dir1, dir2)
    if(dir1 > dir2)
        d1 = dir2
        d2 = dir1
        return 1
    else if(dir1 < dir2)
        d1 = dir1
        d2 = dir2
        return 1
    return 0

/datum/net_node/power/cable/Destroy()
    . = ..()
    cable_nodes -= src

/datum/net_node/power/cable/get_connections()
    . = list()
    
    //d1
    . += get_connections_in_dir(d1)
    
    //d2
    . += get_connections_in_dir(d2)

/datum/net_node/power/cable/proc/get_connections_in_dir(var/dir)
    . = list()
    if(!dir)
        return .
    //on our tile
    . += get_cables_on_turf(get_turf(src), dir)

    //on the adjacent tile
    . += get_cables_on_turf(get_step(src, dir), turn(dir, 180))

/proc/get_cables_on_turf(var/turf/T, var/dir)
    . = list()
    if(!isturf(T) || !isnum(dir))
        return .

    for(var/atom/A in T)
        if(!A.net_nodes)
            continue

        for(var/datum/net_node/node in A.net_nodes)
            var/datum/net_node/power/cable/C = node
            if(!istype(C))
                continue

            if(C.d1 == dir || C.d2 == dir)
                . += node