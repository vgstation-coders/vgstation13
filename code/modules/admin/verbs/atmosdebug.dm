/client/proc/atmosscan()
	set category = "Mapping"
	set name = "Check Plumbing"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	feedback_add_details("admin_verb","CP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	//all plumbing - yes, some things might get stated twice, doesn't matter.
	for (var/obj/machinery/atmospherics/plumbing in atmos_machines)
		if (plumbing.nodealert)
			to_chat(usr, "Unconnected [plumbing.name] located at [formatJumpTo(plumbing.loc)]")

	//Manifolds
	for (var/obj/machinery/atmospherics/pipe/manifold/pipe in atmos_machines)
		if (!pipe.node1 || !pipe.node2 || !pipe.node3)
			to_chat(usr, "Unconnected [pipe.name] located at [formatJumpTo(pipe.loc)]")

	//4-way Manifolds
	for (var/obj/machinery/atmospherics/pipe/manifold4w/pipe in atmos_machines)
		if (!pipe.node1 || !pipe.node2 || !pipe.node3 || !pipe.node4)
			to_chat(usr, "Unconnected [pipe.name] located at [formatJumpTo(pipe.loc)]")

	//Pipes
	for (var/obj/machinery/atmospherics/pipe/simple/pipe in atmos_machines)
		if (!pipe.node1 || !pipe.node2)
			to_chat(usr, "Unconnected [pipe.name] located at [formatJumpTo(pipe.loc)]")

/client/proc/powerdebug()
	set category = "Mapping"
	set name = "Check Power"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	feedback_add_details("admin_verb","CPOW") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	for (var/datum/net/power/net in powernets)
		if (!net.nodes || !net.nodes.len)
			to_chat(usr, "Powernet with no nodes! Need to add a way to inspect it")
			PAULTODO
