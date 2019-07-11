/atom
	var/list/net_nodes = list() //list of nodes

/atom/New(loc)
	. = ..(loc)

/atom/proc/addNode(var/nodetype)
	if(!ispath(nodetype))
		world.log << "[src.type] called addNode with invalid nodetype: [nodetype]"
		return
	
	net_nodes += new nodetype()