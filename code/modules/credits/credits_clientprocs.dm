/client/proc/clear_credits()
	winset(src, end_credits.control, "is-visible=false")
	//The following line resets the credit's browser back to the pre-script-populated credits.html file, which still has for example the javascript loaded.
	//This technically does cause a mysterious overhead of having a 5kb html file in an invisible browser for your entire play session.
	//Will it cause problems? Probably not, but this is BYOND, so if any mysterious invisible HTML browser problem starts to happen down the line... remember this comment.
	src << output(end_credits.file, end_credits.control)

/client/proc/download_credits()
	if(prefs.credits == CREDITS_NEVER)
		return

	if(!end_credits.finalized)
		log_debug("[src] tried to download credits before the credits were ever finalized! Credits preference: [prefs.credits]")
		return
	src << output(list2params(end_credits.js_args), "[end_credits.control]:setupCredits")
	received_credits = TRUE

/client/proc/play_downloaded_credits()
	if(prefs.credits == CREDITS_NEVER)
		return
	if(prefs.credits == CREDITS_NO_RERUNS && end_credits.is_rerun())
		return

	if(!received_credits)
		log_debug("[src] tried to play credits without having ever received them! Credits preference: [prefs.credits]")
		return
	src << output("", "[end_credits.control]:startCredits") //Execute the startCredits() function in credits.html with no parameters.

/client/proc/credits_audio(var/preload_only = FALSE)
	if(prefs.credits == CREDITS_NEVER)
		return

	if(preload_only)
		src << output(list2params(list(end_credits.audio_link, FALSE)), "[end_credits.control]:setAudio")
		received_roundend_audio = TRUE
	else
		if(prefs.credits == CREDITS_NO_RERUNS && end_credits.is_rerun())
			return
		if(received_roundend_audio)
			src << output("", "[end_credits.control]:startAudio") //Execute the playAudio() function in credits.html with no parameters.
		else
			src << output(list2params(list(end_credits.audio_link, TRUE)), "[end_credits.control]:setAudio")
		src << output(list2params(list(prefs.credits_volume)), "[end_credits.control]:setVolume")


/client/proc/jingle_audio(var/preload_only = FALSE)
	if(prefs.credits == CREDITS_ALWAYS)
		return
	var/datum/credits/C = end_credits
	var/link = ""
	var/selected_jingle
	var/selected_folder
	var/classic_folder = C.roundend_file_path + C.classic_roundend_jingles_folder
	var/list/classic_jingles = flist(classic_folder)
	var/new_folder = C.roundend_file_path + C.new_roundend_jingles_folder
	var/list/new_jingles = flist(new_folder)
	switch(prefs.jingle)
		if(JINGLE_NEVER)
			return
		if(JINGLE_CLASSIC)
			selected_jingle = pick(classic_jingles)
		if(JINGLE_ALL)
			selected_jingle = pick(classic_jingles, new_jingles)

	if(selected_jingle in classic_jingles)
		selected_folder = C.classic_roundend_jingles_folder
	if(selected_jingle in new_jingles)
		selected_folder = C.new_roundend_jingles_folder

	link = C.roundend_file_path + selected_folder + selected_jingle
	if(!link)
		log_debug("[src] somehow had a null jingle link! Jingle preference: [prefs.jingle]")

	if(preload_only)
		src << output(list2params(list(link, FALSE)), "[end_credits.control]:setAudio")
		received_roundend_audio = TRUE
	else
		if(prefs.credits == CREDITS_NO_RERUNS && !end_credits.is_rerun())
			return
		if(received_roundend_audio)
			src << output("", "[end_credits.control]:startAudio") //Execute the playAudio() function in credits.html with no parameters.
		else
			src << output(list2params(list(link, TRUE)), "[end_credits.control]:setAudio")
		src << output(list2params(list(prefs.credits_volume)), "[end_credits.control]:setVolume")

/*
/client/verb/credits_debug()
	set name = "Debug Credits"
	set category = "OOC"
	src << output("", "[end_credits.control]:debugMe")
	winset(src, end_credits.control, "is-visible=true")
*/
