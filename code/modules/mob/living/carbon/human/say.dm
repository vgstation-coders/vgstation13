///mob/living/carbon/human/say(var/message)
//	..(message)

/mob/living/carbon/human/say_quote(text)
	if(!text)
		return "says, \"...\"";	//not the best solution, but it will stop a large number of runtimes. The cause is somewhere in the Tcomms code
	if (src.stuttering)
		return "stammers, [text]";
	if(isliving(src))
		var/mob/living/L = src
		if (L.getBrainLoss() >= 60)
			return "gibbers, [text]";
	var/ending = copytext(text, length(text))
	if (ending == "?")
		return "asks, [text]";
	if (ending == "!")
		return "exclaims, [text]";

//	if(dna)
//		return "[dna.species.say_mod], \"[text]\"";

	return "says, [text]";

/mob/living/carbon/human/treat_speech(var/datum/speech/speech, var/genesay=0)
	if(!(copytext(speech.message, 1, 2) == "*"/* || (mind && mind.changeling && department_radio_keys[copytext(speech.message, 1, 3)] != "changeling")*/))
		for(var/obj/item/I in get_all_slots() + held_items)
			I.affect_speech(speech, src)

	if ((M_HULK in mutations) && health >= 25 && length(speech.message))
		speech.message = "[uppertext(replacetext(speech.message, ".", "!"))]!!" //because I don't know how to code properly in getting vars from other files -Bro
	if (src.slurring || (undergoing_hypothermia() == MODERATE_HYPOTHERMIA && prob(25)))
		speech.message = slur(speech.message)

	// Should be handled via a virus-specific proc.
	if(viruses)
		for(var/datum/disease/pierrot_throat/D in viruses)
			var/list/temp_message = splittext(speech.message, " ") //List each word in the message
			var/list/pick_list = list()
			for(var/i = 1, i <= temp_message.len, i++) //Create a second list for excluding words down the line
				pick_list += i
			for(var/i=1, ((i <= D.stage) && (i <= temp_message.len)), i++) //Loop for each stage of the disease or until we run out of words
				if(prob(3 * D.stage)) //Stage 1: 3% Stage 2: 6% Stage 3: 9% Stage 4: 12%
					var/H = pick(pick_list)
					if(findtext(temp_message[H], "*") || findtext(temp_message[H], ";") || findtext(temp_message[H], ":"))
						continue
					temp_message[H] = "HONK"
					pick_list -= H //Make sure that you dont HONK the same word twice
				speech.message = jointext(temp_message, " ")
	if(isanycultist(src))
		var/obj/effect/cult_ritual/cult_communication/comms = locate() in loc
		if (comms && comms.caster == src)
			speech.language = all_languages[LANGUAGE_CULT]
	if(virus2.len)
		for(var/ID in virus2)
			var/datum/disease2/disease/V = virus2[ID]
			for(var/datum/disease2/effect/e in V.effects)
				if(e.affect_voice && e.affect_voice_active)
					e.affect_mob_voice(speech)
	..(speech)
	if(dna)
		species.handle_speech(speech,src)
	if(config.voice_noises && world.time>time_last_speech+5 SECONDS)
		time_last_speech = world.time
		for(var/mob/O in hearers())
			if(!O.is_deaf() && O.client)
				O.client.handle_hear_voice(src)


/mob/living/carbon/human/GetVoice()
	if(find_held_item_by_type(/obj/item/device/megaphone))
		var/obj/item/device/megaphone/M = locate() in held_items
		if(istype(M) && M.mask_voice)
			return "Unknown"

	if(istype(wear_mask, /obj/item/clothing/mask/gas/voice))
		var/obj/item/clothing/mask/gas/voice/V = wear_mask
		if(V.vchange && V.is_flipped == 1) //the mask works and we are wearing it on the face instead of on the head
			if(wear_id)
				var/obj/item/weapon/card/id/idcard = wear_id.GetID()
				return idcard.registered_name
			else
				return "Unknown"
		else
			return real_name

	if(mind) // monkeyhumans exist, don't descriminate
		var/datum/role/changeling/changeling = mind.GetRole(CHANGELING)
		if(changeling && changeling.mimicing)
			return changeling.mimicing
	if(GetSpecialVoice())
		return GetSpecialVoice()
	return real_name

/mob/living/carbon/human/IsVocal()
	if(mind)
		return !(issilent(src))
	return 1

/mob/living/carbon/human/proc/SetSpecialVoice(var/new_voice)
	if(new_voice)
		special_voice = new_voice
	return

/mob/living/carbon/human/proc/UnsetSpecialVoice()
	special_voice = ""
	return

/mob/living/carbon/human/proc/GetSpecialVoice()
	return special_voice

/mob/living/carbon/human/binarycheck()
	if(ears)
		var/obj/item/device/radio/headset/dongle = ears
		if(!istype(dongle))
			return 0
		if(dongle.translate_binary)
			return 1

/mob/living/carbon/human/radio(var/datum/speech/speech, var/message_mode)
	. = ..()
	if(. != 0)
		return .

	switch(message_mode)
		if(MODE_HEADSET)
			if (ears)
				say_testing(src, "Talking into our headset (MODE_HEADSET)")
				ears.talk_into(speech, message_mode)
			return ITALICS | REDUCE_RANGE

		if(MODE_SECURE_HEADSET)
			if (ears)
				say_testing(src, "Talking into our headset (MODE_SECURE_HEADSET)")
				ears.talk_into(speech, message_mode)
			return ITALICS | REDUCE_RANGE

		if(MODE_DEPARTMENT)
			if (ears)
				say_testing(src, "Talking into our dept headset")
				ears.talk_into(speech, message_mode)
			return ITALICS | REDUCE_RANGE

	if(message_mode in radiochannels)
		if(ears)
			say_testing(src, "Talking through a radio channel")
			ears.talk_into(speech, message_mode)
			return ITALICS | REDUCE_RANGE

	return 0

/mob/living/carbon/human/get_alt_name()
	if(name != GetVoice())
		return get_id_name("Unknown")
	return null

/mob/living/carbon/human/say_understands(var/mob/other,var/datum/language/speaking = null)
	if(other)
		other = other.GetSource()
	if(has_brain_worms()) //Brain worms translate everything. Even mice and alien speak.
		return 1

	//These only pertain to common. Languages are handled by mob/say_understands()
	if (!speaking)
		if (istype(other, /mob/living/carbon/monkey/diona))
			var/mob/living/carbon/monkey/diona/D = other
			if(D.donors.len >= 4) //They've sucked down some blood and can speak common now.
				return 1
		if (istype(other, /mob/living/silicon))
			return 1
		if (istype(other, /mob/living/carbon/brain))
			return 1
		if (istype(other, /mob/living/carbon/slime))
			return 1
		if (istype(other, /mob/living/carbon/complex/gondola))
			return 1


	//This is already covered by mob/say_understands()
	//if (istype(other, /mob/living/simple_animal))
	//	if((other.universal_speak && !speaking) || src.universal_speak || src.universal_understand)
	//		return 1
	//	return 0
	return ..()

/mob/living/carbon/human/can_read()
	return TRUE //no brain damage checks for now
