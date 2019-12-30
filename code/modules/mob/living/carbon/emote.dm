/datum/emote/living/carbon
	mob_type_allowed_typelist = list(/mob/living/carbon)

/datum/emote/living/carbon/airguitar
	key = "airguitar"
	message = "is strumming the air and headbanging like a safari chimp."
	restraint_check = TRUE

/datum/emote/living/carbon/blink
	key = "blink"
	key_third_person = "blinks"
	message = "blinks."

/datum/emote/living/carbon/blink_r
	key = "blink_r"
	message = "blinks rapidly."

/datum/emote/living/carbon/clap
	key = "clap"
	key_third_person = "claps"
	message = "claps."
	muzzle_ignore = TRUE
	restraint_check = TRUE
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/gnarl
	key = "gnarl"
	key_third_person = "gnarls"
	message = "gnarls and shows its teeth..."
	mob_type_allowed_typelist = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)

/datum/emote/living/carbon/moan
	key = "moan"
	key_third_person = "moans"
	message = "moans!"
	message_mime = "appears to moan!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/roll
	key = "roll"
	key_third_person = "rolls"
	message = "rolls."
	mob_type_allowed_typelist = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)
	restraint_check = TRUE

/datum/emote/living/carbon/scratch
	key = "scratch"
	key_third_person = "scratches"
	message = "scratches."
	mob_type_allowed_typelist = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)
	restraint_check = TRUE

/datum/emote/living/carbon/screech
	key = "screech"
	key_third_person = "screeches"
	message = "screeches."
	mob_type_allowed_typelist = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)

/datum/emote/living/carbon/sign
	key = "sign"
	key_third_person = "signs"
	message_param = "signs the number %t."
	mob_type_allowed_typelist = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)
	restraint_check = TRUE

/datum/emote/living/carbon/sign/select_param(mob/user, params)
	. = ..()
	if(!isnum(text2num(params)))
		return message

/datum/emote/living/carbon/sign/signal
	key = "signal"
	key_third_person = "signals"
	message_param = "raises %t fingers."
	mob_type_allowed_typelist = list(/mob/living/carbon/human)
	restraint_check = TRUE

/datum/emote/living/carbon/tail
	key = "tail"
	message = "waves their tail."
	mob_type_allowed_typelist = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)

/datum/emote/living/carbon/wink
	key = "wink"
	key_third_person = "winks"
	message = "winks."

/datum/emote/living/carbon/twitch
	key = "twitch"
	key_third_person = "twitches"
	message = "twitches violently."

/datum/emote/living/carbon/twitch_s
	key = "twitch_s"
	message = "twitches."

/datum/emote/living/carbon/wave
	key = "wave"
	key_third_person = "waves"
	message = "waves."

/datum/emote/living/carbon/whimper
	key = "whimper"
	key_third_person = "whimpers"
	message = "whimpers."
	message_mime = "appears hurt."

/datum/emote/living/carbon/wsmile
	key = "wsmile"
	key_third_person = "wsmiles"
	message = "smiles weakly."

/datum/emote/living/carbon/yawn
	key = "yawn"
	key_third_person = "yawns"
	message = "yawns."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/sniff
	key = "sniff"
	key_third_person = "sniffs"
	message = "sniffs."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/snore
	key = "snore"
	key_third_person = "snores"
	message = "snores."
	message_mime = "sleeps soundly."
	emote_type = EMOTE_AUDIBLE
	stat_allowed = UNCONSCIOUS

/datum/emote/living/carbon/pout
	key = "pout"
	key_third_person = "pouts"
	message = "pouts."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/scowl
	key = "scowl"
	key_third_person = "scowls"
	message = "scowls."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/shake
	key = "shake"
	key_third_person = "shakes"
	message = "shakes their head."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/shiver
	key = "shiver"
	key_third_person = "shiver"
	message = "shivers."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/kiss
	key = "kiss"
	key_third_person = "kisses"
	message = "blows a kiss."
	message_param = "blows a kiss to %t."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/laugh
	key = "laugh"
	key_third_person = "laughs"
	message = "laughs."
	message_mime = "laughs silently!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/gag
	key = "gag"
	key_third_person = "gags"
	message = "gags."
	message_mime = "gags silently."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/gasp
	key = "gasp"
	key_third_person = "gasps"
	message = "gasps!"
	message_mime = "gasps silently!"
	emote_type = EMOTE_AUDIBLE
	stat_allowed = UNCONSCIOUS

/datum/emote/living/carbon/giggle
	key = "giggle"
	key_third_person = "giggles"
	message = "giggles."
	message_mime = "giggles silently!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/grin
	key = "grin"
	key_third_person = "grins"
	message = "grins."

/datum/emote/living/carbon/groan
	key = "groan"
	key_third_person = "groans"
	message = "groans!"
	message_mime = "appears to groan!"

/datum/emote/living/carbon/grimace
	key = "grimace"
	key_third_person = "grimaces"
	message = "grimaces."

/datum/emote/living/carbon/burp
	key = "burp"
	key_third_person = "burps"
	message = "burps."
	message_mime = "appears to burp."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/choke
	key = "choke"
	key_third_person = "chokes"
	message = "chokes!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/chuckle
	key = "chuckle"
	key_third_person = "chuckles"
	message = "chuckles."
	message_mime = "imitates a smug chuckle."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/blush
	key = "blush"
	key_third_person = "blushes"
	message = "blushes."
	
/datum/emote/living/carbon/fear
	key = "fear"
	key_third_person = "fears"
	message = "screams in fear!"
	message_mime = "acts out a fearful scream!"
	emote_type = EMOTE_AUDIBLE
	
/datum/emote/living/carbon/sound
	var/list/science_sounds = null
	var/list/male_sounds = null
	var/list/female_sounds = null
	var/list/birb_sounds = null
	var/sound_message = null

/datum/emote/living/carbon/sound/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams!"
	message_mime = "acts out a scream!"
	emote_type = EMOTE_AUDIBLE
	science_sounds = list('sound/misc/science_scream1.ogg', 'sound/misc/science_scream2.ogg', 'sound/misc/science_scream3.ogg', 'sound/misc/science_scream4.ogg', 'sound/misc/science_scream5.ogg', 'sound/misc/science_scream6.ogg')
	male_sounds =  list('sound/misc/malescream1.ogg', 'sound/misc/malescream2.ogg', 'sound/misc/malescream3.ogg', 'sound/misc/malescream4.ogg', 'sound/misc/malescream5.ogg', 'sound/misc/wilhelm.ogg', 'sound/misc/goofy.ogg')
	female_sounds = list('sound/misc/femalescream1.ogg', 'sound/misc/femalescream2.ogg', 'sound/misc/femalescream3.ogg', 'sound/misc/femalescream4.ogg', 'sound/misc/femalescream5.ogg')
	sound_message = "screams in agony!"
	voxemote = FALSE

/datum/emote/living/carbon/sound/shriek
	key = "shriek"
	key_third_person = "shrieks"
	message = "shrieks!"
	message_mime = "acts out a shriek!"
	emote_type = EMOTE_AUDIBLE
	birb_sounds = list('sound/misc/shriek1.ogg')
	sound_message = "shrieks in agony!"
	voxemote = TRUE
	voxrestrictedemote = TRUE

/datum/emote/living/carbon/sound/cough
	key = "cough"
	key_third_person = "coughs"
	message = "coughs!"
	message_mime = "coughs silently!"
	emote_type = EMOTE_AUDIBLE
	male_sounds = list('sound/misc/cough/cough_m1.ogg', 'sound/misc/cough/cough_m2.ogg', 'sound/misc/cough/cough_m3.ogg', 'sound/misc/cough/cough_m4.ogg')
	female_sounds = list('sound/misc/cough/cough_f1.ogg', 'sound/misc/cough/cough_f2.ogg', 'sound/misc/cough/cough_f3.ogg', 'sound/misc/cough/cough_f4.ogg')

/datum/emote/living/carbon/sound/run_emote(mob/user, params)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return ..()
	if(H.stat == DEAD)
		return
	if (!H.is_muzzled() && !issilent(H)) // Silent = mime, mute species.
		if(params == TRUE) // Forced scream
			if(world.time-H.last_emote_sound >= 30)//prevent scream spam with things like poly spray
				if(sound_message)
					message = sound_message
				var/obj/item/clothing/C = search_sound_clothing(H, key)
				var/sound
				if(!C)
					if(isvox(H) || isskelevox(H))
						sound = pick(birb_sounds)
					else
						switch(H.gender)
							if(MALE)
								sound = pick(male_sounds)//AUUUUHHHHHHHHOOOHOOHOOHOOOOIIIIEEEEEE
							if(FEMALE)
								sound = pick(female_sounds)
				else
					sound = pick(C.sound_file)
				playsound(user, sound, 50, 0)
				H.last_emote_sound = world.time

	else
		message = "makes a very loud noise."

	return ..()

//A lengthy checks that returns the clothes to be used by other procs
/datum/emote/living/carbon/sound/proc/search_sound_clothing(mob/living/carbon/human/user, var/sound_key)
	var/selected_clothing //Check the clothing we've selected to be played
	var/list/priority_high = list()
	var/list/priority_med = list()
	var/list/priority_low = list()
	var/list/no_priority = list()
	for(var/obj/item/clothing/C in user.get_equipped_items())
		if(!C.sound_file)
			continue
		if(user.species && (user.species.name in C.sound_respect_species))
			continue
		if(!(sound_key in C.sound_change))
			continue
		switch(C.sound_priority)
			if(CLOTHING_SOUND_HIGH_PRIORITY)
				priority_high += C
			if(CLOTHING_SOUND_MED_PRIORITY)
				priority_med += C
			if(CLOTHING_SOUND_LOW_PRIORITY)
				priority_low += C
			else
				no_priority += C
	if(!priority_high.len && !priority_med.len && !priority_low.len && !no_priority.len) //We didn't grab any clothing, stop the proc
		return 0
	if(priority_high.len)
		selected_clothing = pick(priority_high)
	else if(priority_med.len)
		selected_clothing = pick(priority_med)
	else if(priority_low.len)
		selected_clothing = pick(priority_low)
	else if(no_priority.len)
		selected_clothing = pick(no_priority)
	return selected_clothing