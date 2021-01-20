/obj/item/weapon/implant/faux //this implant is supposed to broadcast that green square that sechud's see without the loyalty effect
	name = "loyalty implant" //its supposed to have been a regular loyalty implant that was modified and had its internal components gutted
	desc = "On closer inspection, something looks off about this loyalty implant."
	_color = "r"
	var/activation_emote = "chuckle"
	var/inactive = 0




/obj/item/weapon/implant/faux/New()
	src.activation_emote = pick("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
	..()
	return


/obj/item/weapon/implant/faux/trigger(emote, mob/living/carbon/source as mob)
	to_chat(source, "You feel a click")
	if(inactive == 0)
		inactive = 1
	else
		inactive = 0
	return
/obj/item/weapon/implant/faux/implanted(mob/living/carbon/source)
	source.mind.store_memory("The false loyalty implant signal broadcast can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to to activate or deactivate.", 0, 0)
	to_chat(source, "The false loyalty implant signal broadcast can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to to activate or deactivate.")
	return 1

/obj/item/weapon/implant/faux/attackby(var/obj/item/device/multitool, mob/user as mob)
	to_chat(user, "A simple check of the internal circuitry of the implant indicates that almost none of the internal mechanisms of a loyalty implant are present")