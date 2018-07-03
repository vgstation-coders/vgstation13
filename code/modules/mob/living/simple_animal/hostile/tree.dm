/mob/living/simple_animal/hostile/tree
	name = "pine tree"
	desc = "A pissed off tree-like alien. It seems annoyed with the festivities..."
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_1"
	icon_living = "pine_1"
	icon_dead = "pine_1"
	icon_gib = "pine_1"

	size = SIZE_HUGE
	speak_chance = 0
	turns_per_move = 5
	response_help = "brushes"
	response_disarm = "pushes"
	response_harm = "hits"
	speed = 1
	maxHealth = 250
	health = 250

	pixel_x = -16 * PIXEL_MULTIPLIER

	harm_intent_damage = 5
	melee_damage_lower = 8
	melee_damage_upper = 12
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	//Space carp aren't affected by atmos.
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	faction = "forest"
	held_items = list()

/mob/living/simple_animal/hostile/tree/FindTarget()
	. = ..()
	if(.)
		emote("me",, "growls at [.]!")

/mob/living/simple_animal/hostile/tree/AttackingTarget()
	. =..()
	var/mob/living/L = .
	if(istype(L))
		if(prob(15))
			L.Knockdown(3)
			L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")

/mob/living/simple_animal/hostile/tree/death(var/gibbed = FALSE)
	..(gibbed)
	spawn_reward()
	qdel(src)

/mob/living/simple_animal/hostile/tree/proc/spawn_reward()
	visible_message("<span class='warning'><b>[src]</b> is hacked into pieces!</span>")
	playsound(loc, 'sound/effects/woodcutting.ogg', 100, 1)
	new /obj/item/stack/sheet/wood(loc)

/mob/living/simple_animal/hostile/tree/festivus
	name = "festivus pole"
	desc = "serenity now... SERENITY NOW!"
	icon_state = "festivus_pole"
	icon_living = "festivus_pole"
	icon_dead = "festivus_pole"
	icon_gib = "festivus_pole"

/mob/living/simple_animal/hostile/tree/festivus/spawn_reward()
	visible_message("<span class='warning'><b>[src]</b> is hacked into pieces!</span>")
	new /obj/item/weapon/nullrod(loc)
