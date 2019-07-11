/datum/net
    //nodes
    var/list/node_types = list() //node types that we accept
    var/list/nodes = list() //nodes currently connected to the network

// ******************
// PROCS TO OVERRIDE (and maybe supercall)
// ******************

//adds a node to the net
/datum/net/proc/add_node(var/datum/net_node/node)
    if(!is_type_in_list(node, node_types))
        return 0

    if(!istype(src, node.netType))
        return 0

    node.net = src
    nodes |= node
    return 1

//merges with another net
/datum/net/proc/absorb_net(var/datum/net/other_net)
    if(!istype(other_net, src.type))
        return 0

    if(!other_net)
        return 0

    if(src == other_net)
        return 1

    for(var/datum/net_node/node in other_net.nodes)
        add_node(node)

//used in merge_nets proc to determine which network needs to be absorbed (the smaller one)
//this returns a number
/datum/net/proc/get_size()
    return nodes.len

//returns one net
/proc/merge_nets(var/datum/net/n1, var/datum/net/n2)
    if(!n1)
        return n2 ? n2 : null
    if(!n2)
        return n1

    if(n1 == n2)
        return n1

    if(n2.get_size() > n1.get_size())
        return n2.absorb_net(n1)

    return n1.absorb_net(n2)