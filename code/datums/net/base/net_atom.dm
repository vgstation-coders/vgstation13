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
	var/list/nodes = getNodes(nodetype)
	while(nodes.len)
		var/node = nodes[nodes.len]
		nodes.len--
		if(istype(node, nodetype))
			return node
	return null

/atom/proc/getNodes(var/nodetype)
	. = list()
	for(var/node in net_nodes)
		if(istype(node, nodetype))
			. += node
	
/atom/proc/get_powernet()
	var/datum/net_node/power/node = getNode(/datum/net_node/power)
	if(!istype(node))
		return null
	if(istype(node.net, /datum/net/power))
		return node.net

/atom/proc/power_change()