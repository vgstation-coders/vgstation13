/obj/item/weapon/implant/compressed
	name = "compressed matter implant"
	desc = "Based on compressed matter technology, can store a single item."
	icon_state = "implant_evil"
	var/activation_emote = "sigh"
	var/obj/item/scanned

/obj/item/weapon/implant/compressed/get_data()
	return {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Nanotrasen \"Profit Margin\" Class Employee Lifesign Sensor<BR>
<b>Life:</b> Activates upon death.<BR>
<b>Important Notes:</b> Alerts crew to crewmember death.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a compact radio signaler that triggers when the host's lifesigns cease.<BR>
<b>Special Features:</b> Alerts crew to crewmember death.<BR>
<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}

/obj/item/weapon/implant/compressed/trigger(emote, mob/source)
	if(malfunction == IMPLANT_MALFUNCTION_PERMANENT)
		return 0

	if (scanned == null)
		return 0

	if (emote == activation_emote)
		to_chat(source, "The air glows as \the [scanned.name] uncompresses.")
		activate()

/obj/item/weapon/implant/compressed/activate()
	var/turf/t = get_turf(src)
	if (imp_in)
		imp_in.put_in_hands(scanned)
	else
		scanned.forceMove(t)
	qdel(src)

/obj/item/weapon/implant/compressed/implanted(mob/implanter)
	imp_in.register_event(/event/emote, src, nameof(src::trigger()))
	activation_emote = input(implanter, "Choose activation emote:") in list("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
	implanter.mind.store_memory("Compressed matter implant in [implanter == imp_in ? "yourself" : imp_in.name] can be activated by using the [activation_emote] emote, <B>say *[activation_emote]</B> to attempt to activate.", TRUE)
	to_chat(implanter, "The implanted compressed matter implant can be activated by using the [activation_emote] emote, <B>say *[activation_emote]</B> to attempt to activate.")

/obj/item/weapon/implant/compressed/islegal()
	return FALSE

/obj/item/weapon/implant/compressed/handle_removal(mob/remover)
	imp_in?.unregister_event(/event/emote, src, nameof(src::trigger()))
	makeunusable(75)
