/mob/living/simple_animal/hostile/alien
	name = "alien hunter"
	desc = "Hiss!"
	icon = 'icons/mob/alien.dmi'
	icon_state = "alienh_running"
	icon_living = "alienh_running"
	icon_dead = "alienh_dead"
	icon_gib = "syndicate_gib"
	response_help = "pokes the"
	response_disarm = "shoves the"
	response_harm = "hits the"
	speed = -1
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat
	species_type = /mob/living/simple_animal/hostile/alien
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "slashes"
	a_intent = I_HURT
	attack_sound = 'sound/weapons/bladeslice.ogg'
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15
	faction = "alien"
	environment_smash = 2
	status_flags = CANPUSH
	minbodytemp = 0
	heat_damage_per_tick = 20
	treadmill_speed = 4 //Not as insane as it seems, because of their slow default move rate, this is more like a functional 2x human


/mob/living/simple_animal/hostile/alien/drone
	name = "alien drone"
	icon_state = "aliend_running"
	icon_living = "aliend_running"
	icon_dead = "aliend_dead"
	health = 60
	melee_damage_lower = 15
	melee_damage_upper = 15

/mob/living/simple_animal/hostile/alien/sentinel
	name = "alien sentinel"
	icon_state = "aliens_running"
	icon_living = "aliens_running"
	icon_dead = "aliens_dead"
	health = 120
	melee_damage_lower = 15
	melee_damage_upper = 15
	ranged = 1
	projectiletype = /obj/item/projectile/neurotox
	projectilesound = 'sound/weapons/pierce.ogg'


/mob/living/simple_animal/hostile/alien/queen
	name = "alien queen"
	icon_state = "alienq_running"
	icon_living = "alienq_running"
	icon_dead = "alienq_dead"
	health = 250
	maxHealth = 250
	melee_damage_lower = 15
	melee_damage_upper = 15
	ranged = 1
	move_to_delay = 3
	projectiletype = /obj/item/projectile/neurotox
	projectilesound = 'sound/weapons/pierce.ogg'
	rapid = 1
	status_flags = 0

/mob/living/simple_animal/hostile/alien/queen/large
	name = "alien empress"
	icon = 'icons/mob/alienqueen.dmi'
	icon_state = "queen_s"
	icon_living = "queen_s"
	icon_dead = "queen_dead"
	move_to_delay = 4
	maxHealth = 400
	health = 400
	pixel_x = -16

/obj/item/projectile/neurotox
	damage = 30
	icon_state = "toxin"

/mob/living/simple_animal/hostile/alien/Die()
	..()
	visible_message("[src] lets out a waning guttural screech, green blood bubbling from its maw...")
	playsound(src, 'sound/voice/hiss6.ogg', 100, 1)

/mob/living/simple_animal/hostile/alien/gib()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "gibbed-a", sleeptime = 15)
	xgibs(loc, viruses)
	dead_mob_list -= src

	qdel(src)

/mob/living/simple_animal/hostile/alien/CanAttack(var/atom/the_target)
	if(isalien(the_target))
		return 0
	return ..(the_target)

/mob/living/simple_animal/hostile/alien/adjustBruteLoss(amount,var/damage_type) // Weak to Fire
	if(damage_type == BURN)
		..(amount * 2)
	else
		..(amount)
