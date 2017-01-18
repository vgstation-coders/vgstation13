/proc/to_utf8(var/message, var/mob_or_client)
	var/encoding = "1252"
	if (isclient(mob_or_client))
		var/client/C = mob_or_client
		encoding = C.encoding

	else if (ismob(mob_or_client))
		var/mob/M = mob_or_client
		if (M.client)
			encoding = M.client.encoding

	LIBVG("to_utf8", encoding, message)
