/datum/automation/set_passive_gate_state
	name = "Passive Gate: Set Open/Closed"
	var/gate=null
	var/state=0

	Export()
		var/list/json = ..()
		json["gate"]=gate
		json["state"]=state
		return json

	Import(var/list/json)
		..(json)
		gate = json["gate"]
		state = text2num(json["state"])

	process()
		if(gate)
			parent.send_signal(list ("tag" = gate, "command"="gate_set","state"=state))
		return 0

	GetText()
		return "Set passive gate <a href=\"?src=\ref[src];set_subject=1\">[fmtString(gate)]</a> to <a href=\"?src=\ref[src];set_state=1\">[state?"open":"closed"]</a>."

	Topic(href,href_list)
		if(href_list["set_state"])
			state=!state
			parent.updateUsrDialog()
			return 1
		if(href_list["set_subject"])
			var/list/gates=list()
			for(var/obj/machinery/atmospherics/binary/passive_gate/G in atmos_machines)
				if(!isnull(G.id_tag) && G.frequency == parent.frequency)
					gates|=G.id_tag
			if(gates.len==0)
				to_chat(usr, "<span class='warning'>Unable to find any passive gates on this frequency.</span>")
				return
			gate = input("Select a gate:", "Sensor Data", gate) as null|anything in gates
			parent.updateUsrDialog()
			return 1