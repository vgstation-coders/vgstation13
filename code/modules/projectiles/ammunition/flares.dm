/* Basic ammo for the flare gun. Does a nice amount of burn damage (15), and if it's shot from the syndicate flare gun will set people on fire
   Can also be fired from shotguns, but only to the same effect as being fired from a regular flare gun */

/obj/item/ammo_casing/shotgun/flare
	name = "flare shell"
	desc = "Flare shell, shot by flare guns. Contains a flare and little else."
	icon_state = "flareshell"
	caliber = GAUGEFLARE
	projectile_type = "/obj/item/projectile/flare"
	starting_materials = list(MAT_IRON = 1000)
	w_type = RECYK_METAL
	w_class = W_CLASS_TINY
	var/obj/item/device/flashlight/flare/stored_flare = null

/obj/item/ammo_casing/shotgun/flare/New()
	..()
	stored_flare = new(src)

/obj/item/ammo_casing/shotgun/flare/attack_self()
	if(stored_flare)
		to_chat(usr, "You disassemble the flare shell.")
		stored_flare.forceMove(usr.loc)
		stored_flare = null
		BB = null
		icon_state = "flareshell-empty"
		update_icon()
	else
		to_chat(usr, "This flare is empty.")
