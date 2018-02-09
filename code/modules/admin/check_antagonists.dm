/datum/admins/proc/check_antagonists()
	if (!ticker || ticker.current_state < GAME_STATE_PLAYING)
		alert("The game hasn't started yet!")
		return

	var/dat = list("<h1>Round status</h1>")

	dat += {"Current game mode: <b>[ticker.mode.name]</b><br>
		Round duration: <b>[round(world.time / 36000)]:[add_zero(world.time / 600 % 60, 2)]:[world.time / 100 % 6][world.time / 100 % 10]</b><br>
		<B>Emergency shuttle</B><BR>"}
	if (!emergency_shuttle.online)
		dat += "<a href='?src=\ref[src];call_shuttle=1'>Call shuttle</a><br>"
	else
		var/timeleft = emergency_shuttle.timeleft()
		switch(emergency_shuttle.location)
			if(0)
				dat += {"ETA: <a href='?src=\ref[src];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>
					<a href='?src=\ref[src];call_shuttle=2'>Send Back</a><br>"}
			if(1)
				dat += "ETA: <a href='?src=\ref[src];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"
	dat += "<a href='?src=\ref[src];delay_round_end=1'>[ticker.delay_end ? "End round normally" : "Delay round end"]</a><br>"

	dat += ticker.mode.AdminPanelEntry()

/*

	if(ticker.mode.head_revolutionaries.len || ticker.mode.revolutionaries.len)
		dat += "<br><table cellspacing=5><tr><td><B>Revolutionaries</B></td><td></td></tr>"
		for(var/datum/mind/N in ticker.mode.head_revolutionaries)
			var/mob/M = N.current
			if(!M)
				dat += "<tr><td><i>Head Revolutionary not found!</i></td></tr>"
			else

				dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a> <b>(Leader)</b>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
					<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"}
		for(var/datum/mind/N in ticker.mode.revolutionaries)
			var/mob/M = N.current
			if(M)

				dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
					<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"}
		dat += "</table><table cellspacing=5><tr><td><B>Target(s)</B></td><td></td><td><B>Location</B></td></tr>"
		for(var/datum/mind/N in ticker.mode.get_living_heads())
			var/mob/M = N.current
			if(M)

				dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
					<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>"}
				var/turf/mob_loc = get_turf(M)
				dat += "<td>[mob_loc.loc]</td></tr>"
			else
				dat += "<tr><td><i>Head not found!</i></td></tr>"
		dat += "</table>"

	if(ticker.mode.enthralled.len > 0)
		dat += "<br><table cellspacing=5><tr><td><B>Thralls</B></td><td></td><td></td></tr>"
		for(var/datum/mind/Mind in ticker.mode.enthralled)
			var/mob/M = Mind.current
			if(M)

				dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
					<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
					<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"}
			else
				dat += "<tr><td><i>Enthralled not found!</i></td></tr>"

	if(istype(ticker.mode, /datum/game_mode/blob))
		var/datum/game_mode/blob/mode = ticker.mode

		dat += {"<br><table cellspacing=5><tr><td><B>Blob</B></td><td></td><td></td></tr>
			<tr><td><i>Progress: [blobs.len]/[mode.blobwincount]</i></td></tr>"}
		for(var/datum/mind/blob in mode.infected_crew)
			var/mob/M = blob.current
			if(M)

				dat += {"<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
					<td><A href='?priv_msg=\ref[M]'>PM</A></td>"}
			else
				dat += "<tr><td><i>Blob not found!</i></td></tr>"
		dat += "</table>"
	else if(locate(/mob/camera/blob) in mob_list)
		dat += "<br><table cellspacing=5><tr><td><B>Blob</B></td><td></td><td></td></tr>"
		for(var/mob/M in mob_list)
			if(istype(M, /mob/camera/blob))

				dat += {"<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
					<td><A href='?priv_msg=\ref[M]'>PM</A></td>"}
		dat += "</table>"

*/
	var/datum/browser/popup = new(usr, "\ref[src]-round_status", "Round status", 600, 700, src)
	popup.set_content(jointext(dat, ""))
	popup.open()
