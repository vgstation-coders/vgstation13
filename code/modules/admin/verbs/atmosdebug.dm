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
		if ((!pipe.node1 || !pipe.node2 || !pipe.node3) && !(pipe in AL))
			AL += pipe

	//4-way Manifolds
	for (var/obj/machinery/atmospherics/pipe/manifold4w/pipe in atmos_machines)
		if ((!pipe.node1 || !pipe.node2 || !pipe.node3 || !pipe.node4) && !(pipe in AL))
			AL += pipe

	//Pipes
	for (var/obj/machinery/atmospherics/pipe/simple/pipe in atmos_machines)
		if ((!pipe.node1 || !pipe.node2) && !(pipe in AL))
			AL += pipe

	var/output = {"<B>PLUMBING ANOMALIES REPORT</B><HR>
		<B>The following anomalies have been detected.</B><BR><ul>"}

	for (var/obj/machinery/atmospherics/plumbing in AL)
		output += "<li>Unconnected [plumbing.name] located at [formatJumpTo(plumbing.loc)]</li>"

	output += "</ul>"
	usr << browse(output,"window=pipereport;size=1000x500")
/client/proc/powerdebug()
	set category = "Mapping"
	set name = "Check Power"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	feedback_add_details("admin_verb","CPOW") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	var/output = {"<B>POWERNET ANOMALIES REPORT</B><HR>
		<B>The following anomalies have been detected. The ones in red need immediate attention: Some of those in black may be intentional.</B><BR><ul>"}
	var/empty_nets = 0
	var/low_nets = 0

	for (var/datum/powernet/PN in powernets)
		if (!PN.nodes || !PN.nodes.len)
			if(PN.cables && (PN.cables.len > 1))
				var/obj/structure/cable/C = PN.cables[1]
				output += "<font color='red'><li>Powernet with no nodes! (number [PN.number]) - example cable at [C.x], [C.y], [C.z] in area [get_area(C.loc)]</font></li>"
				empty_nets++

		if (!PN.cables || (PN.cables.len < 10))
			if(PN.cables && (PN.cables.len > 1))
				var/obj/structure/cable/C = PN.cables[1]
				output += "<li>Powernet with fewer than 10 cables! (number [PN.number]) - example cable at [C.x], [C.y], [C.z] in area [get_area(C.loc)]</li>"
				low_nets++

	output += "</ul><br>[empty_nets] powernets without nodes detected, [low_nets] with less than 10 cables."
	usr << browse(output,"window=pipereport;size=1000x500")
