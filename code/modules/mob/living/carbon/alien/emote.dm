/datum/emote/living/alien
	mob_type_allowed_typelist = list(/mob/living/carbon/alien)

/datum/emote/living/alien/snarl
	key = "snarl"
	key_third_person = "snarls"
	key_shorthand = "sna"
	message = "snarls and bares its teeth."

/datum/emote/living/alien/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "hisses."
	message_mobtype = list(/mob/living/carbon/alien/larva = "hisses softly.")

/datum/emote/living/alien/hiss/run_emote(mob/user, params)
	. = ..()
	if(. && isalienadult(user))
		playsound(user.loc, "hiss", 40, 1, 1)

/datum/emote/living/alien/roar
	key = "roar"
	key_third_person = "roars"
	message = "roars."
	message_mobtype = list(/mob/living/carbon/alien/larva = "softly roars.")
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/alien/roar/run_emote(mob/user, params)
	. = ..()
	if(. && isalienadult(user))
		playsound(user.loc, 'sound/voice/hiss5.ogg', 40, 1, 1)
