/obj/item/weapon/implant/uplink
	name = "uplink"
	desc = "Summon things."
	var/activation_emote

/obj/item/weapon/implant/uplink/New()
	..()
	var/datum/component/uplink_comp = add_component(/datum/component/uplink)
	uplink_comp.telecrystals = 10

/obj/item/weapon/implant/uplink/implanted(mob/source)
	source.register_event(/event/emote, src, .proc/trigger)
	activation_emote = input("Choose activation emote:") in list("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
	source.mind.store_memory("Uplink implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0, 0)
	to_chat(source, "The implanted uplink implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.")
	return 1

/obj/item/weapon/implant/uplink/handle_removal(var/mob/remover)
	imp_in?.register_event(/event/emote, src, .proc/trigger)
	makeunusable(75)

/obj/item/weapon/implant/uplink/trigger(emote, mob/source)
	if(emote != activation_emote)
		return
	var/datum/component/uplink/uplink_comp = get_component(/datum/component/uplink)
	uplink_comp.locked = FALSE
	uplink_comp.tgui_interact(source)
