/datum/emote/brain
	mob_type_allowed_typelist = list(/mob/living/carbon/brain)
	mob_type_blacklist_typelist = list()

/datum/emote/brain/can_run_emote(mob/user, var/status_check = TRUE)
	. = ..()
	var/mob/living/carbon/brain/B = user
	if(!istype(B) || (!(B.container && istype(B.container, /obj/item/device/mmi))))
		return FALSE

/datum/emote/brain/run_emote(mob/user, params, type_override, ignore_status = FALSE)
	var/mob/living/carbon/brain/B = user
	if (istype(B) && isrobot(B.container.loc))
		var/mob/living/silicon/robot/R = B.container.loc
		return run_emote(R, params, TRUE, ignore_status)
	return ..()

/datum/emote/brain/alarm
	key = "alarm"
	message = "sounds an alarm."
	emote_type = EMOTE_AUDIBLE

/datum/emote/brain/alert
	key = "alert"
	message = "lets out a distressed noise."
	emote_type = EMOTE_AUDIBLE

/datum/emote/brain/flash
	key = "flash"
	message = "blinks their lights."

/datum/emote/brain/notice
	key = "notice"
	message = "plays a loud tone."
	emote_type = EMOTE_AUDIBLE

/datum/emote/brain/whistle
	key = "whistle"
	key_third_person = "whistles"
	message = "whistles."
	emote_type = EMOTE_AUDIBLE