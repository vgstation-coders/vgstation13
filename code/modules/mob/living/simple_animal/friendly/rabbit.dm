/mob/living/simple_animal/rabbit
	name = "rabbit"
	desc = "Considered a pet by some, a rodent by others."
	icon_state = "rabbit"
	icon_living = "rabbit"
	icon_dead = "rabbit_dead"
	turns_per_move = 1
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/rabbit
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 10
	var/body_color
	pass_flags = PASSTABLE
	size = SIZE_SMALL

	species_type = /mob/living/simple_animal/rabbit
	can_breed = 1
	childtype = /mob/living/simple_animal/rabbit/bunny
	child_amount = 1
	holder_type = /obj/item/weapon/holder/animal


/mob/living/simple_animal/rabbit/New()
	if(prob(1))
		new /mob/living/simple_animal/hostile/monster/rabbit(src.loc)
		message_admins("Killer rabbit manifested, time to have fun!([formatJumpTo(src)])")
		qdel(src)

	if(!body_color)
		body_color = pick( list("brown","grey","white"))
	icon_state = "rabbit_[body_color]"
	icon_living = "rabbit_[body_color]"
	icon_dead = "rabbit_[body_color]_dead"
	gender = pick( list(FEMALE, MALE))
	..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)



/mob/living/simple_animal/rabbit/bunny
	name = "bunny"
	desc = "A tiny bundle of fluff"
	health = 3
	size = SIZE_TINY

/mob/living/simple_animal/rabbit/bunny/New()
	if(!body_color)
		body_color = pick( list("brown","grey","white"))
	icon_state = "bunny_[body_color]"
	icon_living = "bunny_[body_color]"
	icon_dead = "bunny_[body_color]_dead"