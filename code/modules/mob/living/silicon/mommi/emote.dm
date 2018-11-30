/datum/emote/sound/silicon/mommi
	mob_type_allowed_typelist = list(/mob/living/silicon/robot/mommi)
	emote_type = EMOTE_AUDIBLE

/datum/emote/sound/silicon/mommi/comment
	key = "comment"
	message = "vocalizes."
	message_param = "cheerily vocalizes at %t."

/datum/emote/sound/silicon/mommi/comment/run_emote(mob/user, params, type_override)
	sound = get_sfx("mommicomment")
	. = ..()
