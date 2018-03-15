var/chatResources
var/bicon_cache
var/iconCache

/proc/to_chat(user, msg)
	user << msg

/proc/bicon()
	return

/proc/costly_bicon()
	return

/datum/log
	var/log = ""

/datum/chatOutput/proc/start()
	return

/datum/chatOutput/proc/ehjax_send()
	return
