/obj/structure/losetta_stone
	name = "strange stone"
	desc = "You feel a strange sense of emptiness, as if missing something, from looking upon this stone."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "loss"
	var/chosen_language

/obj/structure/losetta_stone/New()
	..()
	chosen_language = pick(
		LANGUAGE_HUMAN,
		LANGUAGE_UNATHI,
		LANGUAGE_CATBEAST,
		LANGUAGE_SKRELLIAN,
		LANGUAGE_ROOTSPEAK,
		LANGUAGE_TRADEBAND,
		LANGUAGE_GUTTER,
		LANGUAGE_GREY,
		LANGUAGE_XENO,
		LANGUAGE_CLATTER,
		LANGUAGE_MONKEY,
		LANGUAGE_VOX,
		LANGUAGE_MOUSE,
		LANGUAGE_GOLEM,
		LANGUAGE_SLIME)

/obj/structure/losetta_stone/examine(mob/user)
	var/datum/language/picked_language = all_languages[chosen_language]
	if(user.can_speak_lang(picked_language))
		to_chat(user, "<span class = 'notice'>You see nothing strange about this dull rock.</span>")
	else
		..()

/obj/structure/losetta_stone/attack_hand(mob/user)
	..()
	var/datum/language/picked_language = all_languages[chosen_language]
	if(user.can_speak_lang(picked_language))
		to_chat(user, "<span class = 'notice'>You touch \the [src], but nothing notable happens.</span>")
	else
		if(user.add_language(chosen_language))
			to_chat(user, "<span class = 'notice'>As you touch \the [src], you find yourself able to speak [chosen_language]!</span>")
		else
			to_chat(user, "<span class = 'notice'>You touch \the [src], but nothing much happens.</span>")
