/obj/item/clothing/ring
	name = "Golden ring"
	desc = "This one is rather plain, round, but it has a strange fascinating quality about it."
	icon = 'icons/obj/clothing/rings.dmi'
	icon_state = "ringgold"
	slot_flags = SLOT_RING
	var/engraved = FALSE

/obj/item/clothing/ring/mob_can_equip(mob/M, slot, disable_warning = 0, automatic = 0)
	. = ..()
	var/mob/living/carbon/human/H = M
	if (!istype(M))
		return CANNOT_EQUIP
	if (H.gloves)
		to_chat(H, "<span class='notice'>You must remove your gloves first.</span>")
		return CANNOT_EQUIP
	if (!H.get_organ("r_hand"))
		to_chat(H, "<span class='notice'>You have no right hand!</span>")
		return CANNOT_EQUIP

/obj/item/clothing/ring/silver
	name = "Silver ring"
	desc = "A shiny silver ring. Not a single scratch on it."
	icon_state = "ringsilver"

/obj/item/clothing/ring/shiny
	name = "Ruby ring"
	desc = "A gold ring with an ornate ruby gem incrusted."
	icon_state = "ringshiny"
