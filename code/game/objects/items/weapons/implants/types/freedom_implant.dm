/obj/item/weapon/implant/freedom
	name = "freedom"
	desc = "Use this to escape from those evil Red Shirts."
	_color = "r"
	var/activation_emote = "chuckle"
	var/uses = 5

/obj/item/weapon/implant/freedom/New()
	activation_emote = pick("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
	..()

/obj/item/weapon/implant/freedom/trigger(emote, mob/living/carbon/source)
	if (uses < 1)
		return 0
	if (emote == activation_emote)
		uses--
		to_chat(source, "You feel a faint click.")
		if (source.handcuffed)
			source.drop_from_inventory(source.handcuffed)
		if (source.legcuffed)
			source.drop_from_inventory(source.legcuffed)
		var/mob/living/carbon/human/dude = source
		if(istype(dude))
			var/jacket = dude.is_wearing_item(/obj/item/clothing/suit/strait_jacket, slot_wear_suit)
			if(jacket)
				source.u_equip(jacket, TRUE)

/obj/item/weapon/implant/freedom/implanted(mob/implanter)
	imp_in.register_event(/event/emote, src, nameof(src::trigger()))
	imp_in.mind.store_memory("Freedom implant can be activated by using the [activation_emote] emote, <B>say *[activation_emote]</B> to attempt to activate.", 0, 0)
	to_chat(imp_in, "The implanted freedom implant can be activated by using the [activation_emote] emote, <B>say *[activation_emote]</B> to attempt to activate.")

/obj/item/weapon/implant/freedom/handle_removal(mob/remover)
	imp_in?.unregister_event(/event/emote, src, nameof(src::trigger()))
	makeunusable(75)

/obj/item/weapon/implant/freedom/get_data()
	return {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Freedom Beacon<BR>
<b>Life:</b> optimum 5 uses<BR>
<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Transmits a specialized cluster of signals to override handcuff locking
mechanisms<BR>
<b>Special Features:</b><BR>
<i>Neuro-Scan</i>- Analyzes certain shadow signals in the nervous system<BR>
<b>Integrity:</b> The battery is extremely weak and commonly after injection its
life can drive down to only 1 use.<HR>
No Implant Specifics"}
