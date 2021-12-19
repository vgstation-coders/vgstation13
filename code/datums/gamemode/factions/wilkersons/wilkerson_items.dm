//Equipment and such////////

/obj/item/weapon/gun/hookshot/whip/wilkerson
	name = "Wilkerson themed bullwhip"
	maxlength = 6


/obj/item/weapon/gun/hookshot/whip/wilkerson/hal
	name = "Father's Dicipline"
	icon_state = "fathers_dicipline"
	hooktype = /obj/item/projectile/hookshot/whip/wilkerson/hal

/obj/item/weapon/gun/hookshot/whip/wilkerson/lois
	name = "Mother's Love"
	icon_state = "mothers_love"
	hooktype = /obj/item/projectile/hookshot/whip/wilkerson/lois


/obj/item/projectile/hookshot/whip/wilkerson
	whipitgood_bonus = 0
	fire_delay = 3
	cant_drop = TRUE

/obj/item/projectile/hookshot/whip/wilkerson/to_bump(atom/A as mob)
	if(isliving(A))
		var/mob/living/L = A
		if(!A.stat)
			var/obj/item/projectile/hookshot/whip/wilkerson/ourWilk = shot_from
			ourWilk.firer.adjustBruteLoss(-5)
			ourWilk.firer.adjustFireLoss(-5)
	..(A)

/obj/item/projectile/hookshot/whip/wilkerson/hal
	name = "Father's Dicipline"
	icon_state = "fathers_dicipline"
	icon_name = "fathers_dicipline"

/obj/item/projectile/hookshot/whip/wilkerson/lois
	name = "Mother's Love"
	icon_state = "mothers_love"
	icon_name = "mothers_love"


/obj/item/weapon/storage/pill_bottle/wilkerson
	name = "Wilkerson Prescription"
	desc = "A variety of medications found in the wilkerson medical shelf. You aren't sure which belong to who but you know that's never steared you wrong."

/obj/item/weapon/storage/pill_bottle/wilkerson/New()
	..()
	for(var/i=1 to 14)
		new /obj/item/weapon/reagent_containers/pill/random/wilkerson(src)

/obj/item/weapon/reagent_containers/pill/random/wilkerson
	name = "Medicine"
	desc = "Maybe it's Reese's? Hal's?"
	possible_combinations = list(
		list(DOCTORSDELIGHT = 5, KELOTANE = 5, DERMALINE = 5, BICARIDINE = 5, METHYLIN = 10),
		list(DOCTORSDELIGHT = 5, KELOTANE = 5, DERMALINE = 5, BICARIDINE = 5, OXYCODONE = 5),
		list(DOCTORSDELIGHT = 5, KELOTANE = 5, DERMALINE = 5, BICARIDINE = 5, SPORTDRINK = 25),
		list(DOCTORSDELIGHT = 5, KELOTANE = 5, DERMALINE = 5, BICARIDINE = 5, SYNAPTIZINE = 1),
		list(DOCTORSDELIGHT = 5, KELOTANE = 5, DERMALINE = 5, BICARIDINE = 5, HYPERZINE = 7),
		list(DOCTORSDELIGHT = 5, KELOTANE = 5, DERMALINE = 5, BICARIDINE = 5, NOTHING = 50)
	)


//Effects/////////

/obj/effect/theMiddle
	name = "The Middle"
	icon_state = "theMiddle"
	anchored = TRUE
	var/lightType = "#8C489F"

/obj/effect/theMiddle/New()
	..()
	set_light(5, 3, lightType)

/obj/effect/theMiddle/hal
	name = "Hal Fragment"
	icon_state = "halFrag"
	lightType = "#990033"

/obj/effect/theMiddle/lois
	name = "Lois Fragment"
	icon_state = "loisFrag"
	lightType = "#003366"

/obj/effect/wilkersonEgg
	name = "Pulsating egg"
	icon = 'icons/obj/food.dmi'
	icon_state = "egg"
