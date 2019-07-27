//the """physical""" part of the nets

/datum/net_node
    var/datum/net/net //our net
    var/active = 1
    var/netType = /datum/net //our nettype, needed for the propagation in Destroy
    var/atom/parent //our parent

/datum/net_node/New(var/atom/loc)
    . = ..()
    parent = loc
    connections_changed()

/datum/net_node/proc/connections_changed()
    net = new netType()
    for(var/datum/net_node/neighbour in get_connections())
        net = merge_nets(net, neighbour.net)

//we tell our connected things to propagate new nets
/datum/net_node/Destroy()
    . = ..()
    active = FALSE //so we don't get propagated over
    rebuild_connections()

/datum/net_node/proc/rebuild_connections()
    var/list/new_nets = list()
    for(var/datum/net_node/neighbour in get_connections())
        if(!(neighbour.net in new_nets)) //have we already propagated over this node?
            var/datum/net/new_net = new netType()
            neighbour.propagate(new_net)
            new_nets += new_net

//propagate to create a new net
// === DONT OVERRIDE, OVERRIDE GET_CONNECTIONS INSTEAD ===
/datum/net_node/proc/propagate(var/datum/net/new_net = new netType())
    var/list/worklist = list()

    if(new_net.add_node(src))
        worklist += src

    var/index = 1
    while(index <= worklist.len)
        var/datum/net_node/current_node = worklist[index]

        if(!istype(current_node))
            index++
            continue

        for(var/datum/net_node/child_node in current_node.get_connections())
            if(!istype(child_node))
                continue

            if(!child_node.active)
                continue
            
            if(child_node.net != new_net)
                if(new_net.add_node(child_node))
                    worklist |= child_node
        index++

/datum/net_node/proc/set_active(var/bool)
    active = bool
    connections_changed()

// ******************
// PROCS TO OVERRIDE
// ******************

//returns a list of net_nodes this will connect to
// make sure this does not returns itself
/datum/net_node/proc/get_connections()

/datum/net_node/proc/connects_to_dir(var/dir)
    return FALSE

// ******************
//  DEBUG PROCS
// ******************

/datum/net_node/proc/print_connections()
    message_admins("getting connections for \ref[src]")
    var/list/cons = get_connections()
    message_admins("length: [cons.len]")
    if(!cons.len)
        return

    message_admins("items:")
    for(var/datum/c in cons)
        message_admins("[c.type] - [c] - \ref[c]")