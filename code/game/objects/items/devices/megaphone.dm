/obj/item/device/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon_state = "megaphone"
	item_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	siemens_coefficient = 1
	var/spamcheck = 0
	var/list/voicespan = list(SPAN_COMMAND)

/obj/item/device/megaphone/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] is uttering [user.p_their()] last words into \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	spamcheck = 0//so they dont have to worry about recharging
	user.say("AAAAAAAAAAAARGHHHHH")//he must have died while coding this
	return OXYLOSS

/obj/item/device/megaphone/get_held_item_speechspans(mob/living/carbon/user)
	if(spamcheck > world.time)
		to_chat(user, "<span class='warning'>\The [src] needs to recharge!</span>")
	else
		playsound(loc, 'sound/items/megaphone.ogg', 100, 0, 1)
		spamcheck = world.time + 50
		return voicespan

/obj/item/device/megaphone/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
	obj_flags |= EMAGGED
	voicespan = list(SPAN_REALLYBIG, "userdanger")

/obj/item/device/megaphone/sec
	name = "security megaphone"
	icon_state = "megaphone-sec"

/obj/item/device/megaphone/command
	name = "command megaphone"
	icon_state = "megaphone-command"

/obj/item/device/megaphone/cargo
	name = "supply megaphone"
	icon_state = "megaphone-cargo"

/obj/item/device/megaphone/clown
	name = "clown's megaphone"
	desc = "Something that should not exist."
	icon_state = "megaphone-clown"
	voicespan = list(SPAN_CLOWN)