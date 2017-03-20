//Mobs for the Hive away mission. See maps/randomZlevels/hive.dm for more
//They don't have anything to do with the classic xenomorphs

//Basic alien
/mob/living/simple_animal/hostile/hive_alien
	name = "hive denizen"
	desc = "A crab-like creature with a large growth on its shell. Many short, thin tentacles emanate from it."

	icon = 'icons/mob/critter.dmi'
	icon_state = "hive_denizen"
	icon_living = "hive_denizen"
	icon_dead = "hive_denizen_dead"

	health = 100
	maxHealth = 100

	move_to_delay = 5

	//Not affected by atmos - the hive is a near vacuum
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/hive

	melee_damage_lower = 15
	melee_damage_upper = 20

	//Don't wander around
	wander = FALSE
	intent = I_HURT

	//Attack unconscious
	stat_attack = 1

	var/stun_attack = 15 //15% chance to stun per attack

/mob/living/simple_animal/hostile/hive_alien/Bump(atom/Obstacle)
	//I haven't found any other way to make aliens NOT kill themselves on supermatter when pathfinding.
	//This hack makes them invulnerable to supermatter unless they're getting thrown
	if(istype(Obstacle, /turf/unsimulated/wall/supermatter) && !throwing)
		return

	return ..()

/mob/living/simple_animal/hostile/hive_alien/can_be_grabbed()
	return FALSE

/mob/living/simple_animal/hostile/hive_alien/AttackingTarget()
	.=..()

	if(stun_attack && isliving(target))
		var/mob/living/L = target

		if(prob(stun_attack))
			to_chat(L, "<span class='userdanger'>You are briefly stunned by \the [src]'s violent onslaught!</span>")
			L.Stun(rand(1,2))

//Shoots napalm bombs. Very slow practically a turret.
/mob/living/simple_animal/hostile/hive_alien/arsonist
	name = "hive turret"
	desc = "This twisted creation looks like a large cannon with a small body attached to it. It can barely move itself, and mostly only uses its many legs to adjust its aim."

	icon_state = "hive_arsonist"
	icon_living = "hive_arsonist"
	icon_dead = "hive_arsonist_dead"

	health = 180
	maxHealth = 180

	melee_damage_lower = 5
	melee_damage_upper = 10

	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/hive/turret

	ranged = 1
	projectiletype = /obj/item/projectile/napalm_bomb
	projectilesound = 'sound/weapons/rocket.ogg'
	ranged_cooldown_cap = 3

	speed = 100
	move_to_delay = 150

	stun_attack = FALSE

//Turns alien floors into breathing floors.
/mob/living/simple_animal/hostile/hive_alien/artificer
	name = "hive artificer"
	desc = "An alien with an egg-shaped body that uses tentacles to move around and interact with its surroundings. Such constructs are usually tasked with repairing and improving the Hive."

	icon_state = "hive_artificer"
	icon_living = "hive_artificer"
	icon_dead = "hive_artificer_dead"

	size = SIZE_NORMAL
	health = 80
	maxHealth = 80

	harm_intent_damage = 8
	melee_damage_lower = 18
	melee_damage_upper = 23
	attacktext = "burns"
	attack_sound = 'sound/weapons/welderattack.ogg'

	move_to_delay = 3
	speed = 4

	wander = FALSE

	stun_attack = FALSE

/mob/living/simple_animal/hostile/hive_alien/artificer/Die()
	..()

	flick("hive_artificer_dying", src)

/mob/living/simple_animal/hostile/hive_alien/artificer/Move()
	.=..()

	if(istype(loc, /turf/unsimulated/floor/evil))
		//Turn into breathing floor (that slows people down) permanently
		var/turf/T = loc
		T.ChangeTurf(/turf/unsimulated/floor/evil/breathing)

//Has 2 modes: movement mode and attack mode. When in movement mode, fast but can't attack. When in attack mode, immobile but dangerous
//Switching between modes takes 0.4-.8 seconds
/mob/living/simple_animal/hostile/hive_alien/executioner
	name = "hive defender"
	desc = "A terrifying monster resembling a massive tick in shape. Hundreds of blades are hidden underneath its shell."

	icon_state = "hive_executioner_move"
	icon_living = "hive_executioner_move"
	icon_dead = "hive_executioner_dead"

	move_to_delay = 5
	speed = -1

	size = SIZE_BIG
	health = 280
	maxHealth = 280

	harm_intent_damage = 8
	melee_damage_lower = 45
	melee_damage_upper = 55
	attacktext = "eviscerates"
	attack_sound = 'sound/weapons/slash.ogg'

	stat_attack = UNCONSCIOUS //attack living and unconscious

	stun_attack = 30 //30% chance of stun

	var/attack_mode = FALSE

	var/transformation_delay_min = 4
	var/transformation_delay_max = 8

/mob/living/simple_animal/hostile/hive_alien/executioner/proc/mode_movement()
	icon_state = "hive_executioner_move"
	flick("hive_executioner_movemode", src)

	sleep(rand(transformation_delay_min, transformation_delay_max))

	anchored = FALSE
	speed = -1
	move_to_delay = 8
	attack_mode = FALSE

	aggro_vision_range = initial(aggro_vision_range)
	idle_vision_range = initial(aggro_vision_range)
	vision_range = initial(aggro_vision_range)

	//Immediately find a target so that we're not useless for 1 Life() tick!
	FindTarget()

/mob/living/simple_animal/hostile/hive_alien/executioner/proc/mode_attack()
	icon_state = "hive_executioner_attack"
	flick("hive_executioner_attackmode", src)

	sleep(rand(transformation_delay_min, transformation_delay_max))

	anchored = TRUE
	speed = 0
	attack_mode = TRUE

	aggro_vision_range = 1
	idle_vision_range = 1
	vision_range = 1

	walk(src, 0)

/mob/living/simple_animal/hostile/hive_alien/executioner/LostTarget()
	if(attack_mode && !FindTarget()) //If we don't immediately find another target, switch to movement mode
		mode_movement()

	return ..()

/mob/living/simple_animal/hostile/hive_alien/executioner/LoseTarget()
	if(attack_mode && !FindTarget()) //If we don't immediately find another target, switch to movement mode
		mode_movement()

	return ..()

/mob/living/simple_animal/hostile/hive_alien/executioner/Goto()
	if(attack_mode) //Can't move in attack mode
		return

	return ..()

/mob/living/simple_animal/hostile/hive_alien/executioner/AttackingTarget()
	if(!attack_mode)
		return mode_attack()

	flick("hive_executioner_attacking", src)

	return ..()

/mob/living/simple_animal/hostile/hive_alien/executioner/wounded
	name = "wounded alien executioner"
	health = 80
