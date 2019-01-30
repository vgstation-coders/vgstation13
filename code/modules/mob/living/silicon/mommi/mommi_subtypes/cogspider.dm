/mob/living/silicon/robot/mommi/cogspider
	prefix = "GraveKEEPER"
	desc = "A clockwork being, of design familiar yet alien."
	damage_control_network = "Gravewatch"
	icon_state = "cogspider"
	namepick_uses = 0
	startup_sound = 'sound/misc/timesuit_activate.ogg'//The clockwork winding up
	cell_type = /obj/item/weapon/cell/potato/soviet

/mob/living/silicon/robot/mommi/cogspider/updatename() // Fuck individualism
	real_name = "[prefix]-[num2text(ident)]"
	name = real_name

/mob/living/silicon/robot/mommi/cogspider/identification_string()
	return real_name

/mob/living/silicon/robot/mommi/cogspider/New()
	pick_module(GRAVEKEEPER_MOMMI)
	..()
