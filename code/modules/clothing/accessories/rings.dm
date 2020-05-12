/obj/item/clothing/accessory/ring
	name = "Golden ring"
	desc = "This one is rather plain, round, but it has a strange fascinating quality about it."
	icon_state = "ringgold"
	var/engraved = FALSE
	var/image/worn_overlay = 'icons/obj/clothing/ring_overlays.dmi'

/obj/item/clothing/accessory/ring/can_attach_to(var/obj/item/clothing/C)
	return istype(C, /obj/item/clothing/gloves) //You can equip them over your gloves, or hide them under.

/obj/item/clothing/accessory/ring/attack_self(var/mob/living/carbon/human/H)
	if (!istype(H))
		return ..()
	if (H.gloves)
		return on_attached(H.gloves)
	if (!H.has_organ("l_hand") || !H.has_organ("r_hand"))
		to_chat(H, "<span class='warning'>Cannot equip a ring with no hand!</span>")
		return FALSE

	to_chat(H, "<span class='notice'>You equip \the [src].</span>")
	H.equip_ring(src)

/obj/item/clothing/accessory/ring/attack(var/mob/living/carbon/human/H, var/mob/living/user, var/def_zone, var/originator)
	if (!istype(H))
		return ..()
	if (!H.has_organ("l_hand") || !H.has_organ("r_hand"))
		to_chat(user, "<span class='warning'>Cannot equip a ring with no hand!</span>")
		return FALSE
	if (do_mob(user , H, 3 SECONDS, needs_item = TRUE))
		visible_message("<span class='notice'>\The [user] puts \a [src] to \the [H]'s finger!</span>", "<span class='notice'>\The [user] puts \a [src] to \the [H]'s finger!</span>")
		log_attack("[key_name(user)] put a [src] on [key_name(H)].")
		H.equip_ring(src)

/obj/item/clothing/accessory/ring/silver
	name = "Silver ring"
	desc = "A shiny silver ring. Not a single scratch on it."
	icon_state = "ringsilver"

/obj/item/clothing/accessory/ring/shiny
	name = "Ruby ring"
	desc = "A gold ring with an ornate ruby gem incrusted."
	icon_state = "ringshiny"

/mob/living/carbon/human/proc/equip_ring(var/obj/item/clothing/accessory/ring/R)
	R.forceMove(src)
	hidden_ring = R
	update_inv_gloves(TRUE)
