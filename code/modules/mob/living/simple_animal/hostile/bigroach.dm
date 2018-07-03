/mob/living/simple_animal/hostile/bigroach
	name = "mutated cockroach"
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
	attacktext = "gnaws"
	attack_sound = 'sound/weapons/bite.ogg'

	faction = "roach"

	var/icon_aggro = "bigroach_angry"

/mob/living/simple_animal/hostile/bigroach/queen
	name = "cockroach matriarch"
	desc = "A cockroach, twisted and deformed by mutagenic chemicals nearly to the point of unrecognition, reaching nearly the size of an adult human. By an odd twist of fate, is not only alive and functioning - it is also able to lay eggs."

	icon_state = "hugeroach"
	icon_living = "hugeroach"
	icon_dead = "hugeroach_dead"

	maxHealth = 150
	health = 150

	size = SIZE_NORMAL

	melee_damage_lower = 10
	melee_damage_upper = 25

	move_to_delay = 10
	turns_per_move = 3

	icon_aggro = "hugeroach"

	stat_attack = UNCONSCIOUS //Attack unconscious mobs to lay eggs

	var/egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg/bigroach

/mob/living/simple_animal/hostile/bigroach/queen/AttackingTarget()
	if(isliving(target))
		var/mob/living/L = target

		//Only lay eggs into unconscious dudes
		if(L.isUnconscious())
			visible_message("<span class='notice'>\The [src] lays some eggs on top of \the [L]!</span>")
			playsound(src, 'sound/effects/bug_hiss.ogg', 50, 1)
			var/obj/item/egg = new egg_type(get_turf(target))

			//40% chance for the egg to be fertile
			if(prob(40) && (animal_count[/mob/living/simple_animal/hostile/bigroach] < ANIMAL_CHILD_CAP))
				processing_objects.Add(egg)

	return ..()

/mob/living/simple_animal/hostile/bigroach/New()
	..()

	pixel_x = rand(-5, 5) * PIXEL_MULTIPLIER
	pixel_y = rand(-5, 5) * PIXEL_MULTIPLIER

/mob/living/simple_animal/hostile/bigroach/death(var/gibbed = FALSE)
	..(gibbed)
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

	icon_living = icon_aggro
	icon_state = icon_living

	spawn(rand(1,14))
		playsound(src, 'sound/effects/bug_hiss.ogg', 50, 1)

/mob/living/simple_animal/hostile/bigroach/LoseAggro()
	..()

	icon_living = initial(icon_living)
	icon_state = icon_living

/mob/living/simple_animal/hostile/bigroach/ex_act()
	return //Survive bombs

/mob/living/simple_animal/hostile/bigroach/nuke_act()
	return //Survive nuclear blasts
