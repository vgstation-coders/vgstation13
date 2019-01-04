/**
	Necrophage
		Cloning-gone-wrong. This creatures objective is to absorb biomass to either upgrade itself, or split off more copies of itself
		Doesn't move via WASD, but rather you click to create a grappling fleshvine to move around.
**/

/mob/living/carbon/complex/necrophage
	name = "bioblob"
	icon = 'icons/mob/necrophage.dmi'
	icon_state = "necrophage"
	icon_state_standing = "necrophage"
	canmove = FALSE
	var/obj/item/weapon/gun/hookshot/flesh/extend_o_arm = null

/mob/living/carbon/complex/necrophage/New()
	..()
	extend_o_arm = new /obj/item/weapon/gun/hookshot/flesh(src)

/mob/living/carbon/complex/necrophage/update_canmove()
	if(istype(loc, /obj/machinery/atmospherics) && ..())
		canmove = TRUE
		return
	canmove = FALSE

/mob/living/carbon/complex/necrophage/can_ventcrawl()
	return TRUE

/mob/living/carbon/complex/necrophage/ventcrawl_carry()
	return TRUE

/mob/living/carbon/complex/necrophage/verb/ventcrawl()
	set name = "Dive into Vent"
	set desc = "Enter an air vent and move through the pipe system."
	set category = "Object"
	var/pipe = start_ventcrawl()
	if(pipe)
		extend_o_arm.rewind_chain()
		if(handle_ventcrawl(pipe))
			update_canmove()

/mob/living/carbon/complex/necrophage/add_ventcrawl()
	.=..()
	update_canmove()

/mob/living/carbon/complex/necrophage/remove_ventcrawl()
	.=..()
	update_canmove()


/mob/living/carbon/complex/necrophage/RangedAttack(var/atom/A, params, held_item)
	if(params2list(params)["shift"] || params2list(params)["alt"])
		return
	if(extend_o_arm)
		extend_o_arm.afterattack(A, src)

/mob/living/carbon/complex/necrophage/UnarmedAttack(var/atom/A)
	if(ismob(A))
		delayNextAttack(10)
	A.attack_slime(src)

