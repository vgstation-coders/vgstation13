/**
	A shard of supermatter
	Touch it - You lose the hand
	It hit you - You lose the limb it hit
	It hit a supermatter shard - It increases its mass
		3 splinters collide with a supermatter shard - It's now a crystal. DON'T FUCK IT UP
	It gets hit with an explosion - EMP and more explosion

**/

/obj/item/supermatter_splinter
	name = "supermatter splinter"
	desc = "A superdense chunk of supermatter. It hums ever so slightly, with swirls of semi-absorbed matter orbiting it. <b>It doesn't look very safe to touch.</b>"
	icon = 'icons/obj/shards.dmi'

/obj/item/supermatter_splinter/New()
	..()
	name = "supermatter [pick("splinter","chunk","core")]"
	icon_state = pick("medium","small","large")
	var/icon/original = icon(icon, icon_state)
	original.ColorTone("#f1e44d")
	icon = original

/obj/item/supermatter_splinter/prepickup(mob/living/user)
	var/datum/organ/external/external = user.get_active_hand_organ()
	if(external)
		user.visible_message("<span class = 'warning>As \the [user] grasps onto \the [src], their [external.display_name] begins rapidly combusting!</span>", "<span class = 'warning'>As you try to get a grip onto \the [src], you feel your [external.display_name] tingle and glow, before it rapidly dissipates into ash.</span>")
		playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
		external.dust()
	return 1

/obj/item/supermatter_splinter/kick_act(mob/living/carbon/human/user)
	var/obj/shoes = user.shoes
	if(shoes)
		user.visible_message("<span class = 'warning'>As \the [user] goes to kick \the [src], their [shoes] collide with \the [src] and rapidly flash into ash.</span>")
		user.u_equip(shoes, 1)
		var/obj/O = shoes.ashtype()
		new O(user.loc)
		qdel(shoes)
	else //Oh nooo
		var/datum/organ/external/external = user.get_organ(pick(LIMB_RIGHT_LEG, LIMB_LEFT_LEG, LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT))
		user.visible_message("<span class = 'warning>As \the [user] goes to punt \the [src], their [external.display_name] begins rapidly combusting!</span>", "<span class = 'warning'>As you try to kick \the [src], you feel your [external.display_name] tingle and glow, before it rapidly dissipates into ash.</span>")
		playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
		external.dust()
	return 0

/obj/item/supermatter_splinter/bite_act(mob/living/carbon/human/user)
	var/datum/organ/external/head = user.get_organ(LIMB_HEAD)
	if(head)
		user.visible_message("<span class = 'warning'>As \the [user] bites down into \the [src], their [head.display_name] begins glowing a deep crimson before turning to dust.","<span class = 'warning'>As you bite down onto \the [src], you realize that supermatter tastes oddly like cheese and pickles before your tastebuds, then your tongue, and finally your entire head ceases to be.</span>")
		playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
		head.dust()
	return 0

/obj/item/supermatter_splinter/can_be_stored(var/obj/item/weapon/storage/S)
	if(istype(S, /obj/item/weapon/storage/backpack/holding))
		return TRUE
	return FALSE
