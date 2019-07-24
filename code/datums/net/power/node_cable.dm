/datum/net_node/power/cable
    var/d1
    var/d2

/datum/net_node/power/cable/New(loc, dir1, dir2) //dir2 is optional
    . = ..()
    setDirs(dir1, dir2)
    cable_nodes += src

/datum/net_node/power/cable/proc/setDirs(dir1, dir2)
    dir1 = text2num(dir1)
    dir2 = text2num(dir2)

    if(dir1 > dir2)
        d1 = dir2
        d2 = dir1
        . = 1
    else if(dir1 < dir2)
        d1 = dir1
        d2 = dir2
        . = 1
    if(.)
        connections_changed()

/datum/net_node/power/cable/Destroy()
    . = ..()
    cable_nodes -= src

/datum/net_node/power/cable/get_connections()
    . = ..()
    if(!.)
        return null
    
    //d1
    . += get_connections_in_dir(d1)
    
    //d2
    . += get_connections_in_dir(d2)

/datum/net_node/power/cable/proc/get_connections_in_dir(var/dir)
    . = list()
    if(!dir)
        return .
    var/turf/T

    //on our tile
    T = get_turf(parent)
    . += T.get_power_nodes(dir)

    if(dir > 0)
        //on the adjacent tile
        T = get_step(T, dir)
        . += T.get_power_nodes(turn(dir, 180))

/datum/net_node/power/cable/connects_to_dir(var/dir)
    return (d1 == dir || d2 == dir)

/turf/proc/get_power_nodes(var/dir)
    . = list()

    for(var/atom/A in src)
        if(!A.net_nodes)
            continue
        for(var/datum/net_node/power/node in A.net_nodes)
            if(!istype(node))
                continue
            if(!node.connects_to_dir(dir))
                continue

            . += node