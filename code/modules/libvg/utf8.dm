/proc/_determine_encoding(var/mob_or_client)
	. = "1252"
	if (isclient(mob_or_client))
		var/client/C = mob_or_client
		. = C.encoding

	else if (ismob(mob_or_client))
		var/mob/M = mob_or_client
		if (M.client)
			. = M.client.encoding


/proc/to_utf8(var/message, var/mob_or_client)
	return LIBVG("to_utf8", _determine_encoding(mob_or_client), message)

// Converts a byte string to a UTF-8 string, sanitizes it and caps the length.
/proc/utf8_sanitize(var/message, var/mob_or_client, var/length)
	return LIBVG("utf8_sanitize", _determine_encoding(mob_or_client), message, num2text(length))

// Get the length (Unicode Scalars) of a UTF-8 string.
/proc/utf8_len(var/message)
	return text2num(LIBVG("utf8_len", message))

#define utf8_byte_len(a) (length(a))

/proc/utf8_find(var/haystack, var/needle, var/start=1, var/end=0)
	return text2num(LIBVG("utf8_find", haystack, needle, "[start]", "[end]"))

/proc/utf8_copy(var/text, var/start=1, var/end=0)
	return LIBVG("utf8_copy", text, "[start]", "[end]")

/proc/utf8_replace(var/text, var/to, var/from, var/start=1, var/end=0)
	return LIBVG("utf8_replace", text, to, from, "[start]", "[end]")

/proc/utf8_index(var/text, var/index)
	return LIBVG("utf8_index", text, "[index]")
