/mob/living/silicon/pai/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "[speakQuery], [text]";
	else if (ending == "!")
		return "[speakExclamation], [text]";

	return "[speakStatement], [text]";

/mob/living/silicon/pai/say(var/msg)
	if(silence_time)
		to_chat(src, "<font color=green>Communication circuits remain unitialized.</font>")
	else
		..(msg)

/mob/living/silicon/pai/binarycheck()
	return 0