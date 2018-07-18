/datum/emote/silicon
	mob_type_allowed_typelist = list(/mob/living/silicon)
	emote_type = EMOTE_AUDIBLE
	var/module_quirk_required

/datum/emote/sound/silicon
	mob_type_allowed_typelist = list(/mob/living/silicon)
	emote_type = EMOTE_AUDIBLE
	var/module_quirk_required

/datum/emote/sound/silicon/can_run_emote(var/mob/user, var/status_check = TRUE)
	. = ..()
	var/mob/living/silicon/robot/R = user
	if (!istype(R))
		return FALSE
	if (module_quirk_required && !(R.module && (R.module.quirk_flags & module_quirk_required)))
		return FALSE

/datum/emote/silicon/can_run_emote(var/mob/user, var/status_check = TRUE)
	. = ..()
	var/mob/living/silicon/robot/R = user
	if (!istype(R))
		return FALSE
	if (module_quirk_required && !(R.module && (R.module.quirk_flags & module_quirk_required)))
		return FALSE

/datum/emote/silicon/boop
	key = "boop"
	key_third_person = "boops"
	message = "boops."

/datum/emote/sound/silicon/buzz
	key = "buzz"
	key_third_person = "buzzes"
	message = "buzzes."
	message_param = "buzzes at %t."
	sound = 'sound/machines/buzz-sigh.ogg'

/datum/emote/sound/silicon/buzz2
	key = "buzz2"
	message = "buzzes twice."
	sound = 'sound/machines/buzz-two.ogg'

/datum/emote/sound/silicon/chime
	key = "chime"
	key_third_person = "chimes"
	message = "chimes."
	sound = 'sound/machines/chime.ogg'

/datum/emote/sound/silicon/honk
	key = "honk"
	key_third_person = "honks"
	message = "honks."
	vary = TRUE
	sound = 'sound/items/bikehorn.ogg'
	module_quirk_required = MODULE_IS_A_CLOWN 

/datum/emote/sound/silicon/ping
	key = "ping"
	key_third_person = "pings"
	message = "pings."
	message_param = "pings at %t."
	sound = 'sound/machines/ping.ogg'

/datum/emote/sound/silicon/chime
	key = "chime"
	key_third_person = "chimes"
	message = "chimes."
	sound = 'sound/machines/chime.ogg'

/datum/emote/sound/silicon/sad
	key = "sad"
	message = "plays a sad trombone..."
	sound = 'sound/misc/sadtrombone.ogg'
	module_quirk_required = MODULE_IS_A_CLOWN 

/datum/emote/sound/silicon/warn
	key = "warn"
	message = "blares an alarm!"
	sound = 'sound/machines/warning-buzzer.ogg'

/datum/emote/sound/silicon/law
	key = "law"
	message = "shows its legal authorization barcode."
	sound = 'sound/voice/biamthelaw.ogg'
	module_quirk_required = MODULE_IS_THE_LAW

/mob/living/silicon/robot/verb/powerwarn()
	set category = "Robot Commands"
	set name = "Power Warning"

	if(stat == CONSCIOUS)
		if(!cell || !cell.charge)
			visible_message("The power warning light on <span class='name'>[src]</span> flashes urgently.",\
							"You announce you are operating in low power mode.")
			playsound(loc, 'sound/machines/buzz-two.ogg', 50, 0)
		else
			to_chat(src, "<span class='warning'>You can only use this emote when you're out of charge.</span>")
