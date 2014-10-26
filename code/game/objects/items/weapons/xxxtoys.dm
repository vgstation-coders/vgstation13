/obj/item/weapon/dildo
	name = "dildo"
	desc = "For girls and some kind of boys."
	icon = 'icons/obj/dildosaber.dmi'
	icon_state = "metal_dildo"
	item_state = "metal_dildo"
	var/matter = 0
	w_class = 2.0
	force = 1
	attack_verb = list("disciplined", "plops")
	flags = FPRINT | TABLEPASS | CONDUCT | BLOOD

	matter = list("metal" = 500,"glass" = 500)

/*/obj/item/weapon/dildo/attack_self(mob/user)
	user << "You insert dildo into your ass."
	sleep 60
	user << "You feel coming orgasm from anus."
	sleep 60
	user << "UH, FUCK!"
	sleep 10
	user << "BOOM!"
	return 0*/

/obj/item/weapon/fleshlight
	name = "fleshlight"
	desc = "For mens and traps"
	icon = 'icons/obj/dildosaber.dmi'
	icon_state = "fleshlight"
	item_state = "fleshlight"
	var/matter = 0
	w_class = 2.0
	force = 1
	attack_verb = list("disciplined", "plops")
	flags = FPRINT | TABLEPASS | CONDUCT | BLOOD

	matter = list("metal" = 500,"glass" = 500)

/*/obj/item/weapon/fleshlight/attack_self(mob/user)
	user << "You insert your dick into the fleshlight."
	sleep 60
	user << "You cumed in fleshlight."
	sleep 60
	user << "UH, FUCK!"
	sleep 10
	user << "BOOM!"
	return 0*/