/obj/item/clothing/ring
	name = "Golden ring"
	desc = "This one is rather plain, round, but it has a strange fascinating quality about it."
	icon = 'icons/obj/clothing/rings.dmi'
	icon_state = "ringgold"
	slot_flags = SLOT_RING
	w_class = W_CLASS_TINY
	var/engraved = FALSE

/obj/item/clothing/ring/gold
	name = "Golden ring"
	desc = "This one is rather plain, round, but it has a strange fascinating quality about it."
	icon_state = "ringgold"

/obj/item/clothing/ring/silver
	name = "Silver ring"
	desc = "A shiny silver ring. Not a single scratch on it."
	icon_state = "ringsilver"

/obj/item/clothing/ring/shiny
	name = "Ruby ring"
	desc = "A gold ring with an ornate ruby gem incrusted."
	icon_state = "ringshiny"

/obj/item/clothing/ring/random_ring

/obj/item/clothing/ring/random_ring/New()
	var/obj/item/clothing/ring/skin = pick(subtypesof(/obj/item/clothing/ring) - /obj/item/clothing/ring/random_ring)
	name = initial(skin.name)
	desc = initial(skin.desc)
	icon_state = initial(skin.icon_state)
	return ..()

/obj/item/clothing/ring/random_ring/wizard
	engraved = TRUE
	var/og_desc
	var/event_mob_rename_key

/obj/item/clothing/ring/random_ring/wizard/New()
	. = ..()
	og_desc = desc

/obj/item/clothing/ring/random_ring/wizard/equipped(var/mob/user, var/slot, hand_index = 0)
	event_mob_rename_key = user.on_renamed.Add(src, "update_desc")

/obj/item/clothing/ring/random_ring/wizard/unequipped(var/mob/user, var/slot, hand_index = 0)
	user.on_renamed.Remove(event_mob_rename_key)

/obj/item/clothing/ring/random_ring/wizard/proc/update_desc(var/list/args)
	var/new_name = args["new_name"]
	desc = og_desc + " In bright red letters, you see engraved: <b>[new_name]</b>."

/obj/item/clothing/ring/proc/do_pyrography(var/mob/user, var/name)
	if (engraved)
		return FALSE
	to_chat(user, "<span class='notice'>You begin to write '[name]' on \the [src]...</span>")
	if (do_after(user, src, 3 SECONDS))
		engraved = TRUE
		desc += " On it is written: <i>[name]</i>."
		to_chat(user, "<span class='notice'>You wrote '[name]' on \the [src].</span>")
		return TRUE
	else
		to_chat(user, "<span class='notice'>You couldn't write on \the [src]!</span>")
		return FALSE

/obj/item/clothing/ring/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/weapon/pyrograph))
		if (engraved)
			return ..()
		var/name = stripped_input(user, "What do you want to engrave on \the [src]?", "", MAX_NAME_LEN)
		if (user.incapacitated())
			return
		do_pyrography(user, name)
	return ..()

/*
 * Pen for pyrography
 */

/obj/item/weapon/pyrograph
	desc = "Not so normal pen. This one writes burning letters on precious metals."
	name = "pyrograph pen"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pyrograph_pen"
	item_state = "pyrograph_pen"
	origin_tech = Tc_MATERIALS + "=1"
	sharpness = 0.5
	sharpness_flags = SHARP_TIP
	flags = FPRINT
	slot_flags = SLOT_BELT | SLOT_EARS
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 7
	throw_range = 15
	starting_materials = list(MAT_IRON = 10)
	w_type = RECYK_MISC
	pressure_resistance = 2
