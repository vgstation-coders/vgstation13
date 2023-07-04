//First argument can be a /datum/command_alert object or path. See "code/datums/helper_datums/command_alerts.dm" for more info

/proc/command_alert(var/text, var/title = "",var/force_report = 0,var/alert,var/noalert = 0,var/small = 0)
	if(ispath(text, /datum/command_alert))
		var/datum/command_alert/CA = new text
		return CA.announce()
	else if(istype(text, /datum/command_alert))
		var/datum/command_alert/CA = text
		return CA.announce()

	if(!alert && !noalert)
		alert = 'sound/AI/commandreport.ogg'
	var/gibberish = map.linked_to_centcomm ? 0 : 1
	var/gibberish_main = (map.linked_to_centcomm || force_report) ? 0 : 1
	var/command

	if (small)
		command = "<br><b><font size = 3><font color = red>[gibberish ? Gibberish(html_encode(title),70) : html_encode(title)]:</font color> [gibberish_main ? Gibberish(html_encode(text),70) : html_encode(text)]</font size></b><br>"
	else
		command += "<h1 class='alert'>[gibberish ? Gibberish(command_name(),70): command_name()] Update</h1>"
		if (title && length(title) > 0)
			command += "<br><h2 class='alert'>[gibberish ? Gibberish(html_encode(title),70) : html_encode(title)]</h2>"


		command += {"<br><span class='alert'>[gibberish_main ? Gibberish(html_encode(text),70) : html_encode(text)]</span><br>
			<br>"}

	for(var/mob/M in player_list)
		if(!istype(M,/mob/new_player) && M.client)
			to_chat(M, command)
			if(!map.linked_to_centcomm)
				M << sound(pick(static_list), volume = 60)
			else if(!noalert)
				M << sound(alert, volume = 60)
