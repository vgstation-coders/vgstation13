/mob/living/silicon/robot/dummy
	name = "cybernetic target dummy"
	desc = "Great for practicing on."
	cell_type = /obj/item/weapon/cell/crap
	anchored = TRUE
	scrambledcodes = TRUE
	AIlink = FALSE
	lawupdate = FALSE
	lockcharge = TRUE
	canmove = FALSE
	
/mob/living/silicon/robot/dummy/New()
	..()
	UnlinkSelf()
	