/client/proc/play_sound(var/sound/S as sound)
	set category = "Fun"
	set name = "Play Global Sound"
	if(!check_rights(R_SOUNDS))
		return

	if (map.nameShort == "lamprey")
		alert("Playing sounds on Lamprey Station is disabled.")
		return FALSE

	var/confirm = alert(src, "Consider using 'Play Local Sound' or using the jukebox 'Custom Songs' feature for a large file.","Confirmation","Confirm","Cancel")
	if(confirm == "Cancel")
		return

	var/sound/uploaded_sound = sound(S, repeat = 0, wait = 1, channel = CHANNEL_ADMINMUSIC)
	uploaded_sound.status = SOUND_STREAM
	uploaded_sound.priority = 250

	var/prompt = alert(src, "Do you want to announce the filename to everyone?","Announce?","Yes","No","Cancel")
	if(prompt == "Cancel")
		return
	if(prompt == "Yes")
		to_chat(world, "<B>[src.key] played sound [S]</B>")
	log_admin("[key_name(src)] played sound [S]")
	message_admins("[key_name_admin(src)] played sound [S]", 1)
	for(var/mob/M in player_list)
		if(!M.client)
			continue
		if(M.client.prefs.toggles & SOUND_MIDI)
			M << uploaded_sound

	feedback_add_details("admin_verb","PGS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/play_local_sound(var/sound/S as sound)
	set category = "Fun"
	set name = "Play Local Sound"
	if(!check_rights(R_SOUNDS))
		return
	if(!istype(S))
		S = sound(S)

	var/prompt = alert(src, "Are you sure you want to play this sound?","Are you sure?","Yes","Cancel")
	if(prompt == "Cancel")
		return
	log_admin("[key_name(src)] played a local sound [S]")
	message_admins("[key_name_admin(src)] played a local sound [S]", 1)
	S.status = SOUND_STREAM | SOUND_UPDATE
	playsound(source = get_turf(src.mob), soundin = S, vol = 50, vary = 0, falloff = 0)
	feedback_add_details("admin_verb","PLS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/*
/client/proc/cuban_pete()
	set category = "Fun"
	set name = "Cuban Pete Time"

	message_admins("[key_name_admin(usr)] has declared Cuban Pete Time!", 1)
	for(var/mob/M in world)
		if(M.client)
			if(M.client.midis)
				to_chat(M, 'cubanpetetime.ogg')

	for(var/mob/living/carbon/human/CP in world)
		if(CP.real_name=="Cuban Pete" && CP.key!="Rosham")
			to_chat(CP, "Your body can't contain the rhumba beat")
			CP.gib()


/client/proc/bananaphone()
	set category = "Fun"
	set name = "Banana Phone"

	message_admins("[key_name_admin(usr)] has activated Banana Phone!", 1)
	for(var/mob/M in world)
		if(M.client)
			if(M.client.midis)
				to_chat(M, 'bananaphone.ogg')


client/proc/space_asshole()
	set category = "Fun"
	set name = "Space Asshole"

	message_admins("[key_name_admin(usr)] has played the Space Asshole Hymn.", 1)
	for(var/mob/M in world)
		if(M.client)
			if(M.client.midis)
				M << 'sound/music/space_asshole.ogg'


client/proc/honk_theme()
	set category = "Fun"
	set name = "Honk"

	message_admins("[key_name_admin(usr)] has creeped everyone out with Blackest Honks.", 1)
	for(var/mob/M in world)
		if(M.client)
			if(M.client.midis)
				to_chat(M, 'honk_theme.ogg')*/
