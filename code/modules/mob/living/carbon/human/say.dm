///mob/living/carbon/human/say(var/message)
//	..(message)

/mob/living/carbon/human/say_quote(text)
	if(!text)
		return "says, \"...\"";	//not the best solution, but it will stop a large number of runtimes. The cause is somewhere in the Tcomms code
	var/ending = copytext(text, length(text))
	if (src.stuttering)
		return "stammers, \"[text]\"";
	if(isliving(src))
		var/mob/living/L = src
		if (L.getBrainLoss() >= 60)
			return "gibbers, \"[text]\"";
	if (ending == "?")
		return "asks, \"[text]\"";
	if (ending == "!")
		return "exclaims, \"[text]\"";

//	if(dna)
//		return "[dna.species.say_mod], \"[text]\"";

	return "says, \"[text]\"";

/mob/living/carbon/human/treat_message(message)
	if(wear_mask && istype(wear_mask))
		if(!(copytext(message, 1, 2) == "*" || (mind && mind.changeling && department_radio_keys[copytext(message, 1, 3)] != "changeling")))
			message = wear_mask.treat_mask_message(message)

	if ((M_HULK in mutations) && health >= 25 && length(message))
		message = "[uppertext(replacetext(message, ".", "!"))]!!" //because I don't know how to code properly in getting vars from other files -Bro
	if (src.slurring)
		message = slur(message)

	if(viruses)
		for(var/datum/disease/pierrot_throat/D in viruses)
			var/list/temp_message = text2list(message, " ") //List each word in the message
			var/list/pick_list = list()
			for(var/i = 1, i <= temp_message.len, i++) //Create a second list for excluding words down the line
				pick_list += i
			for(var/i=1, ((i <= D.stage) && (i <= temp_message.len)), i++) //Loop for each stage of the disease or until we run out of words
				if(prob(3 * D.stage)) //Stage 1: 3% Stage 2: 6% Stage 3: 9% Stage 4: 12%
					var/H = pick(pick_list)
					if(findtext(temp_message[H], "*") || findtext(temp_message[H], ";") || findtext(temp_message[H], ":")) continue
					temp_message[H] = "HONK"
					pick_list -= H //Make sure that you dont HONK the same word twice
				message = list2text(temp_message, " ")

	message = ..(message)
	if(dna)
		message = species.handle_speech(message,src)
	return message


/mob/living/carbon/human/GetVoice()
	if(istype(wear_mask, /obj/item/clothing/mask/gas/voice))
		var/obj/item/clothing/mask/gas/voice/V = wear_mask
		if(V.vchange && wear_id && V.is_flipped == 1) //the mask works, we have an id, and we are wearing it on the face instead of on the head
			var/obj/item/weapon/card/id/idcard = wear_id.GetID()
			if(istype(idcard))
				return idcard.registered_name
			else
				return real_name
		else
			return real_name
	if(mind && mind.changeling && mind.changeling.mimicing)
		return mind.changeling.mimicing
	if(GetSpecialVoice())
		return GetSpecialVoice()
	return real_name

/mob/living/carbon/human/IsVocal()
	if(mind)
		return !miming
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
		if(!istype(dongle)) return 0
		if(dongle.translate_binary) return 1

/mob/living/carbon/human/radio(message, message_mode)
	. = ..()
	if(. != 0)
		return .

	switch(message_mode)
		if(MODE_HEADSET)
			if (ears)
				ears.talk_into(src, message)
			return ITALICS | REDUCE_RANGE

		if(MODE_SECURE_HEADSET)
			if (ears)
				ears.talk_into(src, message, 1)
			return ITALICS | REDUCE_RANGE

		if(MODE_DEPARTMENT)
			if (ears)
				ears.talk_into(src, message, message_mode)
			return ITALICS | REDUCE_RANGE

	if(message_mode in radiochannels)
		if(ears)
			ears.talk_into(src, message, message_mode)
			return ITALICS | REDUCE_RANGE

	return 0

/mob/living/carbon/human/get_alt_name()
	if(name != GetVoice())
		return " (as [get_id_name("Unknown")])"

/mob/living/carbon/human/proc/forcesay(list/append)
	if(stat == CONSCIOUS)
		if(client)
			var/virgin = 1	//has the text been modified yet?
			var/temp = winget(client, "input", "text")
			if(findtextEx(temp, "Say \"", 1, 7) && length(temp) > 5)	//case sensitive means

				temp = replacetext(temp, ";", "")	//general radio

				if(findtext(trim_left(temp), ":", 6, 7))	//dept radio
					temp = copytext(trim_left(temp), 8)
					virgin = 0

				if(virgin)
					temp = copytext(trim_left(temp), 6)	//normal speech
					virgin = 0

				while(findtext(trim_left(temp), ":", 1, 2))	//dept radio again (necessary)
					temp = copytext(trim_left(temp), 3)

				if(findtext(temp, "*", 1, 2))	//emotes
					return

				var/trimmed = trim_left(temp)
				if(length(trimmed))
					if(append)
						temp += pick(append)

					say(temp)
				winset(client, "input", "text=[null]")
