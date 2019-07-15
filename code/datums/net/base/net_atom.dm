/atom
	var/list/net_nodes = list() //list of nodes

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
	TODO

/atom/proc/getNodes(var/nodetype)
	TODO

/atom/proc/get_power_node()
	var/list/nodes = getNode(/datum/net_node/power/machinery)
	if(!nodes.len)
		return addNode(/datum/net_node/power/machinery)
	else
		return nodes[1]