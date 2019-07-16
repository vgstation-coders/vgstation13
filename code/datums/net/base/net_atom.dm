/atom
	var/list/net_nodes = list() //list of nodes

/atom/Destroy()
	. = ..()
	for(var/node in net_nodes)
		qdel(node)

/atom/proc/addNode(var/nodetype, ...) //add any args for new after the first
	if(!ispath(nodetype))
		world.log << "[src.type] called addNode with invalid nodetype: [nodetype]"
		return
	var/list/B = list(src)
	B += (args - type)

	var/datum/net_node/node = new nodetype(arglist(B))
	if(istype(node))
		net_nodes += node

	return node

/atom/proc/getNode(var/nodetype)
	PAULTODO

/atom/proc/getNodes(var/nodetype)
	PAULTODO

//change this to getNode(/datum/net_node/power) (almost) everywhere
//atom/proc/get_power_node()
	
/atom/proc/get_powernet()
	var/datum/net_node/power/node = get_power_node()
	if(!istype(node))
		return 0
	if(istype(node.net, /datum/net/power))
		return node.net

/atom/proc/power_change()