/proc/captain_announce(var/text)
	var/list/send_to_zs = list(map.zCentcomm)

	for(var/obj/machinery/telecomms/relay/R in telecomms_list)
		if(R.on && !(R.z in send_to_zs))
			send_to_zs.Add(R.z)

	for(var/mob/M in player_list)
		if(!istype(M,/mob/new_player) && M.client && (M.z in send_to_zs))
			M << sound('sound/vox/_doop.wav')
			to_chat(M, "<h1 class='alert'>Priority Announcement</h1><span class='alert'>[html_encode(text)]</span><br>")
