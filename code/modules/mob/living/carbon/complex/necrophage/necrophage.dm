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
	return FALSE

/mob/living/carbon/complex/necrophage/ClickOn(var/atom/A, var/params)
	.=..()
	if(params2list(params)["shift"])
		return
	if(extend_o_arm)
		extend_o_arm.afterattack(A, src)

/mob/living/carbon/complex/necrophage/UnarmedAttack(var/atom/A)
	if(ismob(A))
		delayNextAttack(10)
	A.attack_slime(src)