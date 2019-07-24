/datum/net
    //nodes
    var/list/node_types = list() //node types that we accept
    var/list/nodes = list() //nodes currently connected to the network

/datum/net/Destroy()
    . = ..()
    for(var/datum/net_node/node in nodes)
        node.net = null
    nodes = null

// ******************
// PROCS TO OVERRIDE (and maybe supercall)
// ******************

//adds a node to the net
/datum/net/proc/add_node(var/datum/net_node/node)
    var/correct_type = 0
    for(var/type in node_types)
        if(istype(node, type))
            correct_type = 1
            break
    if(!correct_type)
        return 0

    if(!istype(src, node.netType))
        return 0

    node.net = src
    nodes |= node
    return 1

//merges with another net, but doesn't qdel it
/datum/net/proc/absorb_net(var/datum/net/other_net)
    if(!istype(other_net, src.type))
        return

    if(!other_net)
        return src

    if(src == other_net)
        return src

    for(var/datum/net_node/node in other_net.nodes)
        add_node(node)
    other_net.nodes = list()
    return src

//used in merge_nets proc to determine which network needs to be absorbed (the smaller one)
//this returns a number
/datum/net/proc/get_size()
    return nodes.len

/datum/net/proc/getParents(var/type)
    . = list()
    for(var/datum/net_node/node in nodes)
        if(istype(node.parent, type))
            . += node.parent

//returns one net
/proc/merge_nets(var/datum/net/n1, var/datum/net/n2)
    if(!n1)
        return n2
    if(!n2)
        return n1

    if(n1 == n2)
        return n1

    if(n1.type != n2.type)
        return null

    var/datum/net/rnet
    if(n2.get_size() > n1.get_size())
        rnet = n2.absorb_net(n1)
        qdel(n1)
    else
        rnet = n1.absorb_net(n2)
        qdel(n2)

    return rnet