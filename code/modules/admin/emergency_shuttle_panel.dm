/datum/admins/proc/emergency_shuttle_panel()
	if(!emergency_shuttle)
		alert("The emergency shuttle subsystem isn't ready yet!")
		return

	var/dat = "<html><head><title>Emergency Shuttle Fuckery Panel</title></head><body><h1>Emergency Shuttle Control</h1>"

	dat += "Current Status:"

	var/area/shuttle_loc = locate(/area/shuttle/escape/centcom)
	var/turf/shuttle_turf = pick(shuttle_loc.area_turfs)
	dat += "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[shuttle_turf.x];Y=[shuttle_turf.y];Z=[shuttle_turf.z]'>"

	switch (emergency_shuttle.location)
		if(0)
			switch (emergency_shuttle.direction)
				if (-1)
					dat += "<b>In transit</b> (Recalled)"
				if(0)
					dat += "<b>At Central Command</b> (on standby)"
				if(1)
					dat += "<b>In transit</b> (To Station)"
				if(2)
					dat += "<b>In transit</b> (To Centcom - Round End)"
		if(1)
			dat += "<b>At the Station</b>"
		if(2)
			dat += "<b>At Central Command</b> (Round Ended)"

	dat += "</a><br>"

	if (!emergency_shuttle.online)
		dat += "<a href='?src=\ref[src];call_shuttle=1'>Call Shuttle</a><br>"
	else
		var/timeleft = emergency_shuttle.timeleft()
		switch(emergency_shuttle.location)
			if(0)

				dat += {"ETA: <a href='?src=\ref[src];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><br>
					<a href='?src=\ref[src];call_shuttle=2'>Send Back</a><br>"}
			if(1)
				dat += "ETA: <a href='?src=\ref[src];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><br>"

	dat += "<BR>"

	if (emergency_shuttle.online)
		dat += "Any of the three following actions will cancel the shuttle timer.<br>"

	dat += "<a href='?src=\ref[src];move_emergency_shuttle=station'>move shuttle to station</a><br>"
	dat += "<a href='?src=\ref[src];move_emergency_shuttle=transit'>move shuttle to transit</a><br>"
	dat += "<a href='?src=\ref[src];move_emergency_shuttle=centcom'>move shuttle to centcom</a><br>"
	dat += "<br>"
	dat += "<a href='?src=\ref[src];move_emergency_dock=station'>move station dock here</a> - <a href='?src=\ref[src];reset_emergency_dock=station'>reset</a><br>"
	dat += "<a href='?src=\ref[src];move_emergency_dock=transit'>move transit dock here</a> - <a href='?src=\ref[src];reset_emergency_dock=transit'>reset</a><br>"
	dat += "<a href='?src=\ref[src];move_emergency_dock=centcom'>move centcom dock here</a> - <a href='?src=\ref[src];reset_emergency_dock=centcom'>reset</a><br>"

	dat += "<h2>Escape Pods Control</h2>"
	for (var/pod in emergency_shuttle.escape_pods)
		var/datum/shuttle/escape/S = pod
		var/turf/T = pick(S.linked_area.area_turfs)
		dat += "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[S.linked_area.name]</a> : [(emergency_shuttle.escape_pods[pod] == "station") ? "<b>station</b>" : "<a href='?src=\ref[src];move_escape_pod=\ref[pod];move_destination=station'>station</a>"] - [(emergency_shuttle.escape_pods[pod] == "transit") ? "<b>transit</b>" : "<a href='?src=\ref[src];move_escape_pod=\ref[pod];move_destination=transit'>transit</a>"] - [(emergency_shuttle.escape_pods[pod] == "centcom") ? "<b>centcom</b>" : "<a href='?src=\ref[src];move_escape_pod=\ref[pod];move_destination=centcom'>centcom</a>"]<br>"

	if (emergency_shuttle.escape_pods.len > 1)
		dat += "Move All Pods : <a href='?src=\ref[src];move_escape_pod=all;move_destination=station'>station</a> - <a href='?src=\ref[src];move_escape_pod=all;move_destination=transit'>transit</a> - <a href='?src=\ref[src];move_escape_pod=all;move_destination=centcom'>centcom</a><br>"

	dat += "</body></html>"
	usr << browse(dat, "window=emergencyshuttle;size=440x500")
