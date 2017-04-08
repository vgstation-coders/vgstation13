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
	holder_type = /obj/item/weapon/holder/animal/slime
	var/colour = "grey"
	var/paralyzed = 0
	can_butcher = 0
	meat_type = null

	mob_bump_flag = SLIME
	mob_swap_flags = MONKEY|SLIME|SIMPLE_ANIMAL
	mob_push_flags = MONKEY|SLIME|SIMPLE_ANIMAL
	held_items = list()

/mob/living/simple_animal/slime/attackby(var/obj/item/weapon/slimeparapotion/O as obj, var/mob/user as mob)
	if(istype(O))
		canmove = 0
		icon_state = "[colour] baby slime dead"
		to_chat(user, "<span class='info'>\The [src] stops moving and coalesces.</span>")
		qdel(O)
	else
		return ..()

/mob/living/simple_animal/slime/adult
	health = 200
	maxHealth = 200
	icon_state = "grey adult slime"
	icon_living = "grey adult slime"
	icon_dead = "grey baby slime dead"

	size = SIZE_BIG

/mob/living/simple_animal/slime/adult/New()
	..()
	overlays += image(icon = icon, icon_state = "aslime-:33")


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

/mob/living/simple_animal/slime/attack_hand(mob/living/carbon/human/M as mob)

	//Shamelessly stolen from Dionacode
	if(!canmove && !locked_to && isturf(loc) && !M.get_active_hand())
		scoop_up(M)
	return ..()

/obj/item/weapon/slimeparapotion
	name = "slime paralyzing solution"
	desc = "An exotic chemical which paralyzes a slime, allowing it to be safely picked up and transported."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle9"

/mob/living/simple_animal/slime/Life()
	if(timestopped)
		return 0 //under effects of time magick
	..()

	regular_hud_updates()

/mob/living/simple_animal/slime/regular_hud_updates()
	if(client)
		update_pull_icon()

		var/severity = 0

		var/healthpercent = (health/maxHealth) * 100

		switch(healthpercent)
			if(100 to INFINITY)
				healths.icon_state = "slime_health0"
			if(80 to 100)
				healths.icon_state = "slime_health1"
				severity = 1
			if(60 to 80)
				healths.icon_state = "slime_health2"
				severity = 2
			if(40 to 60)
				healths.icon_state = "slime_health3"
				severity = 3
			if(20 to 40)
				healths.icon_state = "slime_health4"
				severity = 4
			if(0 to 20)
				healths.icon_state = "slime_health5"
				severity = 5
			if(-99 to 0)
				healths.icon_state = "slime_health6"
				severity = 6
			else
				healths.icon_state = "slime_health7"
				severity = 6

		if(severity > 0)
			overlay_fullscreen("brute", /obj/abstract/screen/fullscreen/brute, severity)
		else
			clear_fullscreen("brute")
