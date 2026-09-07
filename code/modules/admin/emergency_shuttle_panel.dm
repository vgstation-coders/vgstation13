/datum/admins/proc/emergency_shuttle_panel()
	if(!emergency_shuttle)
		alert("The emergency shuttle subsystem isn't ready yet!")
		return

	var/title = emergency_shuttle.panel_title()
	var/dat = "<html><head><title>Emergency Shuttle Fuckery Panel</title></head><body><h1>[title]</h1>"

	dat += "Current Status: "

	var/turf/jump_turf = emergency_shuttle.get_panel_jump_turf()
	if(jump_turf)
		dat += "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[jump_turf.x];Y=[jump_turf.y];Z=[jump_turf.z]'>[emergency_shuttle.get_status_label()]</a><br>"
	else
		dat += "[emergency_shuttle.get_status_label()]<br>"

	if (!emergency_shuttle.online)
		dat += "<a href='?src=\ref[src];call_shuttle=1'>Call Shuttle</a><br>"
	else
		var/timeleft = emergency_shuttle.timeleft()
		switch(emergency_shuttle.location)
			if(SHUTTLE_ON_STANDBY)
				dat += {"ETA: <a href='?src=\ref[src];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><br>
					<a href='?src=\ref[src];call_shuttle=2'>Send Back</a><br>"}
			if(SHUTTLE_ON_STATION)
				dat += "ETA: <a href='?src=\ref[src];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><br>"

	dat += "<BR>"

	if (emergency_shuttle.online)
		dat += "Any of the three following actions will cancel the shuttle timer.<br>"

	if(emergency_shuttle.supports_phase("station"))
		dat += "<a href='?src=\ref[src];move_emergency_shuttle=station'>move shuttle to station</a><br>"
	if(emergency_shuttle.supports_phase("transit"))
		dat += "<a href='?src=\ref[src];move_emergency_shuttle=transit'>move shuttle to transit</a><br>"
	if(emergency_shuttle.supports_phase("centcom"))
		dat += "<a href='?src=\ref[src];move_emergency_shuttle=centcom'>move shuttle to centcom</a><br>"
	if(emergency_shuttle.manages_shuttle_docks())
		dat += "<br>"
		dat += "<a href='?src=\ref[src];move_emergency_dock=station'>move station dock here</a> - <a href='?src=\ref[src];reset_emergency_dock=station'>reset</a><br>"
		dat += "<a href='?src=\ref[src];move_emergency_dock=transit'>move transit dock here</a> - <a href='?src=\ref[src];reset_emergency_dock=transit'>reset</a><br>"
		dat += "<a href='?src=\ref[src];move_emergency_dock=centcom'>move centcom dock here</a> - <a href='?src=\ref[src];reset_emergency_dock=centcom'>reset</a><br>"

	if(emergency_shuttle.uses_escape_pods())
		dat += "<h2>Escape Pods Control</h2>"
		if(!emergency_shuttle.escape_pods.len)
			dat += "<i>No escape pods registered on this map.</i><br>"
		else
			for(var/datum/shuttle/escape/pod/S in emergency_shuttle.escape_pods)
				var/list/all_turfs = list()
				for(var/area/shuttle_area in S.linked_areas)
					all_turfs += shuttle_area.area_turfs
				var/pod_label = S.linked_area ? S.linked_area.name : S.name
				if(all_turfs.len)
					var/turf/T = pick(all_turfs)
					dat += "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[pod_label]</a> : [(emergency_shuttle.escape_pods[S] == "station") ? "<b>station</b>" : "<a href='?src=\ref[src];move_escape_pod=\ref[S];move_destination=station'>station</a>"] - [(emergency_shuttle.escape_pods[S] == "transit") ? "<b>transit</b>" : "<a href='?src=\ref[src];move_escape_pod=\ref[S];move_destination=transit'>transit</a>"] - [(emergency_shuttle.escape_pods[S] == "centcom") ? "<b>centcom</b>" : "<a href='?src=\ref[src];move_escape_pod=\ref[S];move_destination=centcom'>centcom</a>"] - <a href='?src=\ref[src];move_escape_pod=\ref[S];move_destination=shuttle'>crash into shuttle</a><br>"
				else
					dat += "<i>[pod_label] : missing on current map</i><br>"
			if(emergency_shuttle.escape_pods.len > 1)
				dat += "Move All Pods : <a href='?src=\ref[src];move_escape_pod=all;move_destination=station'>station</a> - <a href='?src=\ref[src];move_escape_pod=all;move_destination=transit'>transit</a> - <a href='?src=\ref[src];move_escape_pod=all;move_destination=centcom'>centcom</a> - <a href='?src=\ref[src];move_escape_pod=all;move_destination=shuttle'>crash into shuttle</a><br>"

	dat += "</body></html>"
	usr << browse(HTML_SKELETON(dat), "window=emergencyshuttle;size=440x500")
