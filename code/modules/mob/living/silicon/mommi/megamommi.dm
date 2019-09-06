/mob/living/silicon/robot/mommi/fabricator
	name = "MoMMI-C"
	namepick_uses = 0
	desc = "What appears to be an automated robotics fabricator, with legs and arms grafted onto itself."
	icon = 'icons/mob/giantmobs.dmi'
	icon_state = "fabricator"
	maxHealth = 400
	health = 400
	cell_type = /obj/item/weapon/cell/rad
	size = SIZE_HUGE

/mob/living/silicon/robot/mommi/fabricator/updatename()
	name = "MoMMI-C [num2text(ident)]"

/mob/living/silicon/robot/mommi/fabricator/identification_string()
	return "MoMMI reconstruction drone unit A"

/mob/living/silicon/robot/mommi/fabricator/New()
	pick_module("Fabricator")
	..()

/mob/living/silicon/robot/mommi/fabricator/can_ventcrawl()
	return FALSE