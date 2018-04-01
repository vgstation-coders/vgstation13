
//Ears: currently only used for headsets and earmuffs
/obj/item/clothing/ears
	name = "ears"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	slot_flags = SLOT_EARS
	resistance_flags = NONE

/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	strip_delay = 15
	equip_delay_other = 25
	resistance_flags = FLAMMABLE
	flags_2 = BANG_PROTECT_2|HEALS_EARS_2

/obj/item/clothing/ears/headphones
	name = "headphones"
	desc = "Unce unce unce unce. Boop!"
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "headphones"
	item_state = "headphones"
	slot_flags = SLOT_EARS | SLOT_HEAD | SLOT_NECK		//Fluff item, put it whereever you want!
	actions_types = list(/datum/action/item_action/toggle_headphones)
	var/headphones_on = FALSE

/obj/item/clothing/ears/headphones/Initialize()
	. = ..()
	update_icon()

/obj/item/clothing/ears/headphones/update_icon()
	icon_state = "[initial(icon_state)]_[headphones_on? "on" : "off"]"
	item_state = "[initial(item_state)]_[headphones_on? "on" : "off"]"

/obj/item/clothing/ears/headphones/proc/toggle(owner)
	headphones_on = !headphones_on
	update_icon()
	var/mob/living/carbon/human/H = owner
	if(istype(H))
		H.update_inv_ears()
		H.update_inv_neck()
		H.update_inv_head()
	to_chat(owner, "<span class='notice'>You turn the music [headphones_on? "on. Untz Untz Untz!" : "off."]</span>")
