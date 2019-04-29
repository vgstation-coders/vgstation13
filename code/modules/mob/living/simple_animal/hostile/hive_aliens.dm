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

/mob/living/simple_animal/hostile/hive_alien/to_bump(atom/Obstacle)
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

			//Animation
			#define ANIM_PIXEL_OFFSET (16*PIXEL_MULTIPLIER)
			var/cur_px = pixel_x
			var/cur_py = pixel_y
			animate(src, pixel_x = cos(dir2angle_t(get_dir(src, L)))*ANIM_PIXEL_OFFSET, pixel_y = sin(dir2angle_t(get_dir(src, L)))*ANIM_PIXEL_OFFSET, time = 5)
			animate(pixel_x = cur_px, pixel_y = cur_py, time = 5)
			#undef ANIM_PIXEL_OFFSET

			L.Stun(rand(1,2))

//Shoots napalm bombs. Very slow practically a turret.
/mob/living/simple_animal/hostile/hive_alien/turret
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

//Turns hive floors into living floors.
//Can summon dense spikes adjacent to hive walls, preventing escape
//To summon spikes, the target must have at least 1 hive alien adjacent (the builder doesn't count)

//After summoning spikes, constructors are immobile until they're destroyed (spikes OR the constructor)

/mob/living/simple_animal/hostile/hive_alien/constructor
	name = "hive constructor"
	desc = "An alien with an egg-shaped body that uses tentacles to move around and interact with its surroundings. These creatures are created to maintain and improve the Hive."

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

	ranged = TRUE

	stun_attack = FALSE

	var/obj/structure/hive/spikes/summoned_spikes

/mob/living/simple_animal/hostile/hive_alien/constructor/death(var/gibbed = FALSE)
	..(gibbed)

	flick("hive_artificer_dying", src)
	if(summoned_spikes)
		qdel(summoned_spikes)
		summoned_spikes = null

/mob/living/simple_animal/hostile/hive_alien/constructor/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	.=..()

	if(istype(loc, /turf/unsimulated/floor/evil))
		//Turn into living floor (that slows enemies down and speeds allies up) permanently
		var/turf/T = loc
		T.ChangeTurf(/turf/unsimulated/floor/evil/breathing)

/mob/living/simple_animal/hostile/hive_alien/constructor/proc/block_escape(mob/living/target)
	if(summoned_spikes)
		return

	var/target_surrounded = FALSE
	for(var/mob/living/simple_animal/hostile/hive_alien/H in orange(1, target))
		if(H == src)
			continue
		if(H.isDead())
			continue
		target_surrounded = TRUE
		break

	if(!target_surrounded)
		return

	var/list/valid_dirs = list() //List of valid directions in which spikes can appear.

	var/turf/target_turf = get_turf(target)
	for(var/D in alldirs) //Go through every turf in every direction. If the turf contains a living mob or a spike, it's invalid. If the turf doesn't have an alien wall adjacent, it's invalid
		var/turf/check = get_step(target_turf, D)

		if(check.density)
			continue

		var/mob/obstacle
		for(var/mob/living/L in check) //Living mob check
			if(L.isDead())
				continue
			obstacle = L
			break
		if(obstacle)
			continue

		if(locate(/obj/structure/hive/spikes) in check) //Spike check
			break

		//Check that this new turf is adjacent to a hive wall! Store the hive wall's direction for a pretty animation
		var/evil_wall_dir = 0 //Direction of the evil wall from which the spikes appear
		for(var/wall_dir_check in cardinal)
			var/turf/unsimulated/wall/evil/wall_check = get_step(check, wall_dir_check)
			if(istype(wall_check))
				evil_wall_dir = wall_dir_check
				break
		if(!evil_wall_dir)
			continue

		valid_dirs["[D]"] = evil_wall_dir

	if(!valid_dirs.len)
		return

	visible_message("<span class='notice'>\The [src] digs its tentacles into the floor.</span>")
	start_channeling()

	var/new_dir = text2num(pick(valid_dirs))
	summoned_spikes = new(get_step(target_turf, new_dir))
	summoned_spikes.owner = src
	summoned_spikes.dir = turn(valid_dirs["[new_dir]"], 180)

/mob/living/simple_animal/hostile/hive_alien/constructor/OpenFire(atom/target)
	block_escape(target)

/mob/living/simple_animal/hostile/hive_alien/constructor/proc/start_channeling()
	icon_state = "hive_artificer_channeling"
	ranged = 0
	anchored = 1
	aggro_vision_range = 1
	idle_vision_range = 1
	vision_range = 1
	canmove = 0
	walk(src, 0)

	update_icon()

/mob/living/simple_animal/hostile/hive_alien/constructor/proc/stop_channeling()
	icon_state = icon_living
	ranged = initial(ranged)
	anchored = FALSE
	aggro_vision_range = initial(aggro_vision_range)
	idle_vision_range = initial(idle_vision_range)
	vision_range = initial(vision_range)
	canmove = 1

	update_icon()

/obj/structure/hive/spikes
	name = "spikes"
	icon_state = "hive_spikes"

	health = 40

	var/mob/living/simple_animal/hostile/hive_alien/constructor/owner

/obj/structure/hive/spikes/death()
	..()

	if(owner)
		owner.stop_channeling()
		owner = null

//Has 2 modes: movement mode and attack mode. When in movement mode, fast but can't attack. When in attack mode, immobile but dangerous
//Switching between modes takes 0.4-.8 seconds
/mob/living/simple_animal/hostile/hive_alien/defender
	name = "hive defender"
	desc = "A terrifying monster resembling a massive, bloated tick in shape. Hundreds of blades are hidden underneath its rough shell."

	icon_state = "hive_executioner_move"
	icon_living = "hive_executioner_move"
	icon_dead = "hive_executioner_dead"

	move_to_delay = 5
	speed = 1

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

/mob/living/simple_animal/hostile/hive_alien/defender/proc/mode_movement()
	icon_state = "hive_executioner_move"
	flick("hive_executioner_movemode", src)

	sleep(rand(transformation_delay_min, transformation_delay_max))

	anchored = FALSE
	speed = 1
	move_to_delay = 8
	attack_mode = FALSE

	aggro_vision_range = initial(aggro_vision_range)
	idle_vision_range = initial(aggro_vision_range)
	vision_range = initial(aggro_vision_range)
	brute_damage_modifier = initial(brute_damage_modifier)

	//Immediately find a target so that we're not useless for 1 Life() tick!
	FindTarget()

/mob/living/simple_animal/hostile/hive_alien/defender/proc/mode_attack()
	icon_state = "hive_executioner_attack"
	flick("hive_executioner_attackmode", src)

	sleep(rand(transformation_delay_min, transformation_delay_max))

	anchored = TRUE
	speed = 0
	attack_mode = TRUE

	aggro_vision_range = 1
	idle_vision_range = 1
	vision_range = 1
	brute_damage_modifier = 3 * initial(brute_damage_modifier)

	walk(src, 0)

/mob/living/simple_animal/hostile/hive_alien/defender/LostTarget()
	if(attack_mode && !FindTarget()) //If we don't immediately find another target, switch to movement mode
		mode_movement()

	return ..()

/mob/living/simple_animal/hostile/hive_alien/defender/LoseTarget()
	if(attack_mode && !FindTarget()) //If we don't immediately find another target, switch to movement mode
		mode_movement()

	return ..()

/mob/living/simple_animal/hostile/hive_alien/defender/Goto()
	if(attack_mode) //Can't move in attack mode
		return

	return ..()

/mob/living/simple_animal/hostile/hive_alien/defender/AttackingTarget()
	if(!attack_mode)
		return mode_attack()

	flick("hive_executioner_attacking", src)

	return ..()

/mob/living/simple_animal/hostile/hive_alien/defender/wounded
	name = "wounded hive defender"
	health = 80
