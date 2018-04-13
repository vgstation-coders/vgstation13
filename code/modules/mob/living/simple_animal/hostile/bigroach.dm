/mob/living/simple_animal/hostile/bigroach
	name = "mutated roach"
	desc = "A cockroach mutated not only to be several times the size of an ordinary one, but also to be much more bloodthirsty. The genetic changes have rendered it sterile and unable to fly."

	icon_state = "bigroach"
	icon_living = "bigroach"
	icon_dead = "bigroach_dead"

	emote_hear = list("hisses")

	pass_flags = PASSTABLE | PASSGRILLE | PASSMACHINE

	speak_chance = 1

	move_to_delay = 4

	maxHealth = 35
	health = 35

	size = SIZE_SMALL

	minbodytemp = 273.15		//Can't survive at below 0 C
	maxbodytemp = INFINITY
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0

	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/roach/big

	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	faction = "roach"

/mob/living/simple_animal/hostile/bigroach/New()
	..()

	pixel_x = rand(-5, 5) * PIXEL_MULTIPLIER
	pixel_y = rand(-5, 5) * PIXEL_MULTIPLIER

/mob/living/simple_animal/hostile/bigroach/Die()
	..()

	playsound(src, pick('sound/effects/gib1.ogg','sound/effects/gib2.ogg','sound/effects/gib3.ogg'), 40, 1) //Splat

/mob/living/simple_animal/hostile/bigroach/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/newspaper))
		to_chat(user, "<span class='notice'>You're gonna need a bigger newspaper.</span>")
	else if(istype(W, /obj/item/weapon/plantspray/pests))
		var/obj/item/weapon/plantspray/pests/P = W
		if(P.use(1))
			to_chat(user, "<span class='notice'>\The [P] doesn't seem to be very effective.</span>")
			playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
	else
		return ..()


/mob/living/simple_animal/hostile/bigroach/Aggro()
	..()

	icon_living = "bigroach_angry"
	icon_state = icon_living

	spawn(rand(1,14))
		playsound(src, 'sound/effects/bug_hiss.ogg', 50, 1)

/mob/living/simple_animal/hostile/bigroach/LoseAggro()
	..()

	icon_living = "bigroach"
	icon_state = icon_living

/mob/living/simple_animal/hostile/bigroach/ex_act()
	return //Survive bombs

/mob/living/simple_animal/hostile/bigroach/nuke_act()
	return //Survive nuclear blasts
