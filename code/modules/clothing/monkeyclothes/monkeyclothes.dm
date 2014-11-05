/obj/item/clothing/monkeyclothes
	name = "monkey-sized waiter suit"
	desc = "Adorable."
	icon = 'icons/mob/monkey.dmi'
	icon_state = "punpunsuit_icon"
	item_state = "punpunsuit_item"
	force = 0
	throwforce = 0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	flags = FPRINT | TABLEPASS

/obj/item/clothing/monkeyclothes/attack(mob/living/carbon/C as mob, mob/user as mob)	//I thought I'd give people a fast way to put clothes on monkey.
	if(ismonkey(C))																	//They can do it by opening the monkey's "show inventory" like you'd do for an human as well.
		var/mob/living/carbon/monkey/M = C
		if(M.canWearClothes)
			M.wearclothes(src)
			return
		else
			user << "Those clothes won't fit."
			return
	..()

/obj/item/clothing/monkeyclothes/cultrobes
	name = "size S cult robes"
	desc = "Adorably crazy."
	icon_state = "cult_icon"
	item_state = "cult_item"