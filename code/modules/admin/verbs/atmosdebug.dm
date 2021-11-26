/client/proc/atmosscan()
	set category = "Mapping"
	set name = "Check Plumbing"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	feedback_add_details("admin_verb","CP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	var/list/obj/machinery/atmospherics/AL = list()

	//all plumbing - yes, some things might get stated twice, doesn't matter.
	for (var/obj/machinery/atmospherics/plumbing in atmos_machines)
		if (plumbing.nodealert)
			AL += plumbing

	//Manifolds
	for (var/obj/machinery/atmospherics/pipe/manifold/pipe in atmos_machines)
		if ((!pipe.node1 || !pipe.node2 || !pipe.node3) && (!pipe in AL))
			AL += pipe

	//4-way Manifolds
	for (var/obj/machinery/atmospherics/pipe/manifold4w/pipe in atmos_machines)
		if ((!pipe.node1 || !pipe.node2 || !pipe.node3 || !pipe.node4) && (!pipe in AL))
			AL += pipe

	//Pipes
	for (var/obj/machinery/atmospherics/pipe/simple/pipe in atmos_machines)
		if ((!pipe.node1 || !pipe.node2) && (!pipe in AL))
			AL += pipe

	var/output = {"<B>PLUMBING ANOMALIES REPORT</B><HR>
		<B>The following anomalies have been detected.</B><BR><ul>"}

	for (var/obj/machinery/atmospherics/plumbing in AL)
		output += "<li>Unconnected [pipe.name] located at [formatJumpTo(pipe.loc)]</li>"

	output += "</ul>"
	usr << browse(output,"window=pipereport;size=1000x500")
/client/proc/powerdebug()
	set category = "Mapping"
	set name = "Check Power"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	feedback_add_details("admin_verb","CPOW") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	for (var/datum/powernet/PN in powernets)
		if (!PN.nodes || !PN.nodes.len)
			if(PN.cables && (PN.cables.len > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(usr, "Powernet with no nodes! (number [PN.number]) - example cable at [C.x], [C.y], [C.z] in area [get_area(C.loc)]")

		if (!PN.cables || (PN.cables.len < 10))
			if(PN.cables && (PN.cables.len > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(usr, "Powernet with fewer than 10 cables! (number [PN.number]) - example cable at [C.x], [C.y], [C.z] in area [get_area(C.loc)]")
