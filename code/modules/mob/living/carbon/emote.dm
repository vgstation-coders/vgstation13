/datum/emote/living/carbon
	mob_type_allowed_typelist = list(/mob/living/carbon)

/datum/emote/living/carbon/airguitar
	key = "airguitar"
	message = "is strumming the air and headbanging like a safari chimp."
	restraint_check = TRUE

/datum/emote/living/carbon/blink
	key = "blink"
	key_third_person = "blinks"
	key_shorthand = "bli"
	message = "blinks."

/datum/emote/living/carbon/blink_r
	key = "blink_r"
	key_shorthand = "blir"
	message = "blinks rapidly."

/datum/emote/living/carbon/clap
	key = "clap"
	key_third_person = "claps"
	message = "claps."
	muzzle_ignore = TRUE
	restraint_check = TRUE
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/snarl
	key = "snarl"
	key_third_person = "snarls"
	key_shorthand = "sna"
	message = "snarls and bares its teeth."
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
	key_shorthand = "scra"
	message = "scratches."
	mob_type_allowed_typelist = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)
	restraint_check = TRUE

/datum/emote/living/carbon/screech
	key = "screech"
	key_third_person = "screeches"
	key_shorthand = "scre"
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
	key_shorthand = "sig"
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
	key_shorthand = "twi"
	message = "twitches violently."

/datum/emote/living/carbon/twitch_s
	key = "twitch_s"
	key_shorthand = "twis"
	message = "twitches."

/datum/emote/living/carbon/wave
	key = "wave"
	key_third_person = "waves"
	message = "waves."

/datum/emote/living/carbon/whimper
	key = "whimper"
	key_third_person = "whimpers"
	key_shorthand = "whim"
	message = "whimpers."
	message_mime = "appears hurt."

/datum/emote/living/carbon/wsmile
	key = "wsmile"
	key_third_person = "wsmiles"
	key_shorthand = "wsmi"
	message = "smiles weakly."

/datum/emote/living/carbon/yawn
	key = "yawn"
	key_third_person = "yawns"
	message = "yawns."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/sniff
	key = "sniff"
	key_third_person = "sniffs"
	key_shorthand = "sni"
	message = "sniffs."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/snore
	key = "snore"
	key_third_person = "snores"
	key_shorthand = "sno"
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
	key_shorthand = "sco"
	message = "scowls."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/shake
	key = "shake"
	key_third_person = "shakes"
	key_shorthand = "sha"
	message = "shakes their head."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/shiver
	key = "shiver"
	key_third_person = "shiver"
	key_shorthand = "shi"
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
	key_shorthand = "lau"
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
	key_shorthand = "gig"
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
	key_shorthand = "gro"
	message = "groans!"
	message_mime = "appears to groan!"

/datum/emote/living/carbon/grimace
	key = "grimace"
	key_third_person = "grimaces"
	key_shorthand = "gri"
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
	key_shorthand = "cho"
	message = "chokes!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/chuckle
	key = "chuckle"
	key_third_person = "chuckles"
	key_shorthand = "chu"
	message = "chuckles."
	message_mime = "imitates a smug chuckle."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/blush
	key = "blush"
	key_third_person = "blushes"
	key_shorthand = "blu"
	message = "blushes."

/datum/emote/living/carbon/smirk
	key = "smirk"
	key_third_person = "smirks"
	key_shorthand = "smir"
	message = "smirks."

/datum/emote/living/carbon/fear
	key = "fear"
	key_third_person = "fears"
	message = "screams in fear!"
	message_mime = "acts out a fearful scream!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/beckon
	key = "beckon"
	key_third_person = "beckons"
	key_shorthand = "bec"
	message_param = "beckons %t closer."

/datum/emote/living/carbon/dismiss
	key = "dismiss"
	key_third_person = "dismisses"
	key_shorthand = "dis"
	message = "waves dimissively."
	message_param = "waves dismissively to %t."

/datum/emote/living/carbon/snap
	key = "snap"
	key_third_person = "snaps"
	message = "snaps their fingers."

/datum/emote/living/carbon/knuckle
	key = "knuckle"
	key_third_person = "knuckles"
	key_shorthand = "knu"
	message = "cracks their knuckles."

/datum/emote/living/carbon/flipoff
	key = "flipoff"
	key_shorthand = "flipo"
	message = "flips the bird."
	message_param = "flips %t off!"

/datum/emote/living/carbon/whistle
	key = "whistle"
	key_third_person = "whistles"
	key_shorthand = "whis"
	message = "whistles."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/wolfwhistle
	key = "wolfwhistle"
	key_third_person = "wolfwhistles"
	key_shorthand = "wwhi"
	message = "wolfwhistles."
	message_param = "wolfwhistles at %t."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/rubhands
	key = "rubhands"
	key_shorthand = "rubh"
	message = "rubs their hands deviously."

/datum/emote/living/carbon/wringhands
	key = "wringhands"
	key_shorthand = "wrih"
	message = "wrings their hands."

/datum/emote/living/carbon/headache
	key = "headache"
	key_shorthand = "hea"
	message = "holds their head in frustration."

/datum/emote/living/carbon/eyerub
	key = "eyerub"
	key_shorthand = "eyer"
	message = "rubs their eyes."

/datum/emote/living/carbon/sound
	var/sound_message = null

//Depending on the sound will run a bunch of arbitrary checks checking for the user's specifications
//Since all audible emotes are currently human-only, this only supports humans (for now)
/datum/emote/living/carbon/sound/proc/choose_sound(var/mob/living/carbon/human/H, var/key)
	return

/datum/emote/living/carbon/sound/scream
	key = "scream"
	key_third_person = "screams"
	key_shorthand = "scr"
	message = "screams!"
	message_mime = "acts out a scream!"
	emote_type = EMOTE_AUDIBLE
	sound_message = "screams in agony!"
	voxemote = FALSE
	insectoidemote = FALSE

/datum/emote/living/carbon/sound/scream/choose_sound(var/mob/living/carbon/human/H, key)
	if(!istype(H))
		return
	if(H.species.name == "Vox")
		return vox_shriek_sound
	if(H.species.name == "Insectoid")
		return insectoid_chitter_sound
	if(H.gender == FEMALE)
		return female_scream_sound
	if(H.species.name == "Tajaran")
		return tajaran_scream_sound
	return male_scream_sound

/datum/emote/living/carbon/sound/shriek
	key = "shriek"
	key_third_person = "shrieks"
	key_shorthand = "shr"
	message = "shrieks!"
	message_mime = "acts out a shriek!"
	emote_type = EMOTE_AUDIBLE
	sound_message = "shrieks in agony!"
	voxemote = TRUE
	voxrestrictedemote = TRUE

/datum/emote/living/carbon/sound/shriek/choose_sound(var/mob/living/carbon/human/H, key)
	if(!istype(H))
		return
	if(H.species.name == "Vox")
		return vox_shriek_sound

/datum/emote/living/carbon/sound/chitter
	key = "chitter"
	key_third_person = "chitters"
	key_shorthand = "chi"
	message = "chitters!"
	message_mime = "chitters silently!"
	emote_type = EMOTE_AUDIBLE
	sound_message = "chitters in agony!"
	insectoidemote = TRUE
	insectoidrestrictedemote = TRUE

/datum/emote/living/carbon/sound/chitter/choose_sound(var/mob/living/carbon/human/H, key)
	if(!istype(H))
		return
	if(H.species.name == "Insectoid")
		return insectoid_chitter_sound

/datum/emote/living/carbon/sound/cough
	key = "cough"
	key_third_person = "coughs"
	key_shorthand = "cou"
	message = "coughs!"
	message_mime = "coughs silently!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/sound/cough/choose_sound(var/mob/living/carbon/human/H, key)
	if(!istype(H))
		return
	if(H.gender == FEMALE)
		return female_cough_sound
	return male_cough_sound

/datum/emote/living/carbon/sound/run_emote(mob/user, params, type_override, ignore_status, arguments)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return ..()
	if(H.stat == DEAD)
		return
	if (!H.is_muzzled() && !issilent(H)) // Silent = mime, mute species.
		if(arguments == "fueltank_crash")
			if(ishuman(H))
				playsound(H, 'sound/misc/crash_scream.ogg', 50, 0)
				H.last_emote_sound = world.time
				return
		if((params == TRUE) || (Holiday == APRIL_FOOLS_DAY) || H.manual_emote_sound_override) // Forced scream or april fools or admin override
			if(world.time-H.last_emote_sound >= 30)//prevent scream spam with things like poly spray
				if(sound_message)
					message = sound_message
				var/obj/item/clothing/C = search_sound_clothing(H, key)
				var/sound
				if(!C)
					sound = pick(choose_sound(H, key))
				else
					sound = pick(C.sound_file)
				if(sound) //Sanity
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
		if(!(user.species.name in C.sound_species_whitelist))
			continue
		if(!(user.gender in C.sound_genders_allowed))
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
