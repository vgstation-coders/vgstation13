/mob/living/simple_animal/slime
	name = "pet slime"
	desc = "A lovable, domesticated slime."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime"
	icon_living = "grey baby slime"
	icon_dead = "grey baby slime dead"
	speak_emote = list("chirps")
	health = 100
	maxHealth = 100
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	emote_see = list("jiggles", "bounces in place")
	var/colour = "grey"

	can_butcher = 0
	meat_type = null

	mob_bump_flag = SLIME
	mob_swap_flags = MONKEY|SLIME|SIMPLE_ANIMAL
	mob_push_flags = MONKEY|SLIME|SIMPLE_ANIMAL

/mob/living/simple_animal/slime/attackby(var/obj/item/weapon/slimeparapotion/O as obj, var/mob/user as mob)
	if(istype(O))
		var/obj/item/weapon/paraslime/F = new /obj/item/weapon/paraslime(get_turf(src))
		F.icon_state = icon_dead
		F.name = "paralyzed [colour] slime"
		F.stored = src
		forceMove(F)
		qdel(O)
	else
		..()

/mob/living/simple_animal/slime/adult
	health = 200
	maxHealth = 200
	icon_state = "grey adult slime"
	icon_living = "grey adult slime"
	icon_dead = "grey baby slime dead"

	size = SIZE_BIG

/mob/living/simple_animal/slime/adult/New()
	..()
	overlays += "aslime-:33"


/mob/living/simple_animal/slime/adult/Die()
	var/mob/living/simple_animal/slime/S1 = new /mob/living/simple_animal/slime (src.loc)
	S1.icon_state = "[src.colour] baby slime"
	S1.icon_living = "[src.colour] baby slime"
	S1.icon_dead = "[src.colour] baby slime dead"
	S1.colour = "[src.colour]"
	var/mob/living/simple_animal/slime/S2 = new /mob/living/simple_animal/slime (src.loc)
	S2.icon_state = "[src.colour] baby slime"
	S2.icon_living = "[src.colour] baby slime"
	S2.icon_dead = "[src.colour] baby slime dead"
	S2.colour = "[src.colour]"
	qdel(src)


/mob/living/simple_animal/slime/proc/rabid()
	if(stat)
		return
	if(client)
		return
	var/mob/living/simple_animal/hostile/slime/pet = new /mob/living/simple_animal/hostile/slime(loc)
	pet.icon_state = "[colour] baby slime eat"
	pet.icon_living = "[colour] baby slime eat"
	pet.icon_dead = "[colour] baby slime dead"
	pet.colour = "[colour]"
	qdel (src)


/obj/item/weapon/slimeparapotion
	name = "slime paralyzing solution"
	desc = "An exotic chemical which paralyzes a slime, allowing it to be safely picked up and transported."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle9"

/obj/item/weapon/paraslime
	name = "paralyzed slime"
	desc = "A paralyzed slime that can be revived by throwing or use in hand."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime"
	var/mob/living/carbon/slime/stored

/obj/item/weapon/paraslime/throw_impact(atom/hit_atom)
	..()
	unfreeze()

/obj/item/weapon/paraslime/attack_hand(mob/living/user as mob)
	if(user.get_active_hand() == src)
		unfreeze()
	else return ..()

/obj/item/weapon/paraslime/proc/unfreeze()
	if(!stored) return
	stored.forceMove(get_turf(src))
	qdel(src)
