/*	TODO:
	Let them evolve and heal from eating. Should a carbon they eat go over a certain damage threshold and
	the wendigo is at full health. Strip and delete the corpse.
	Human wendigo->1 eat->Wendigo->3 eat->Alpha Wendigo (Can only be ONE at any time)
	They don't like fire. Will stay away from fire (As far as their light radius -1) and won't target anyone
	in vicinity of said fire
	Can mimic voices, steal poly code, and change it (Maybe just keep a log of people consumed,
	and use their name plus shout for help)
	Butcherable for one piece of meat only. When consumed (Don't use reagents) will begin to turn the person
*/
#define HUMEVOLV 1
#define EVOLEVOLV 3


/mob/living/simple_animal/hostile/wendigo
	name = "wendigo"
	desc = "Standing tall, deep sunken eyes, and a voracious appetite. This individual has seen better days."
	icon_state = "wendigo"
	icon_living = "wendigo"
	icon_dead = "wendigo_dead"

	health = 150
	maxHealth = 150
	speed = 1
	stat_attack = DEAD //Gotta chow down somehow
	size = SIZE_BIG
	vision_range = 12 //Slightly larger vision range
	harm_intent_damage = 8
	melee_damage_lower = 15
	melee_damage_upper = 20
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	meat_amount = 1 //Only one piece of meat
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/wendigo
	var/list/names = list() //List of names of the people it's eaten
	var/consumes = 0 //How many people it has eaten
	speak_chance = 15
	speak = list("Help!","Help me!","Somebody help!","Get over here, quickly!")
	status_flags = CANSTUN|CANKNOCKDOWN|CANPARALYSE|CANPUSH|UNPACIFIABLE


/mob/living/simple_animal/hostile/wendigo/CanAttack(var/atom/the_target)
	var/list/target_prox = view(the_target, vision_range)
	for(var/obj/machinery/space_heater/campfire/fire in target_prox)
		var/dist = get_dist(the_target, fire)
		if(dist < (fire.light_range*2))//Just sitting on the edge of the fire
			return

	if(isliving(target) && !ishuman(target))
		var/mob/living/L = target
		if(L.isDead())
			return

	return ..()

/mob/living/simple_animal/hostile/wendigo/AttackingTarget()
	if(!target)
		return

	if(ismob(target))
		var/mob/living/mob_target = target
		if(mob_target.isDead() && !istype(mob_target, /mob/dead/observer) && (health < maxHealth || ishuman(mob_target)))
			set waitfor = 0
			visible_message("<span class = 'notice'>\The [src] starts to take a bite out of \the [target].</span>")
			stop_automated_movement = 1
			if(do_after(src, mob_target, 50, needhand = FALSE))
				playsound(src, 'sound/weapons/bite.ogg', 50, 1)
				var/damage = rand(melee_damage_lower, melee_damage_upper)
				mob_target.adjustBruteLoss(damage)
				if(health < maxHealth)
					health = min(maxHealth,(health+damage))

				if(ishuman(mob_target))
					if(mob_target.health < -400)
						visible_message("<span class = 'warning'>\The [src] is trying to consume \the [mob_target]!</span>","<span class = 'warning'>You hear crunching.</span>")
						if(do_after(src, mob_target, 50, needhand = FALSE))
							consumes += 1
							names |= mob_target.real_name
							mob_target.gib()

			return
	return ..()

/mob/living/simple_animal/hostile/wendigo/Life()
	/*Check evolve like zombies, run away from fire,
	mimic speech if anyone's nearby but just out of eyesight
	*/
	..()
	if(!isDead())
		if(check_evolve())
			return

		var/list/can_see = view(src, vision_range)

		for(var/obj/machinery/space_heater/campfire/fire in can_see)
			var/dist = get_dist(src, fire)
			if(dist < (fire.light_range*2))
				walk_away(src,fire,(fire.light_range*2),move_to_delay)


/mob/living/simple_animal/hostile/wendigo/GetVoice()
	if(names.len)
		return pick(names)
	else
		return "unknown"

/mob/living/simple_animal/hostile/wendigo/proc/check_evolve()
	return 0

/mob/living/simple_animal/hostile/wendigo/human
	icon_state = "wendigo"
	icon_living = "wendigo"
	icon_dead = "wendigo_dead"
	size = SIZE_NORMAL
	speed = 1

/mob/living/simple_animal/hostile/wendigo/human/death(var/gibbed = FALSE)
	flick("wendigo_dying",src)
	..(gibbed)

/mob/living/simple_animal/hostile/wendigo/human/check_evolve()
	if(consumes > HUMEVOLV)
		var/mob/living/simple_animal/hostile/wendigo/evolved/new_wendigo = new /mob/living/simple_animal/hostile/wendigo/evolved(src.loc)
		new_wendigo.names = names
		qdel(src)
		return 1

/mob/living/simple_animal/hostile/wendigo/evolved
	icon = 'icons/48x48/48x48mob.dmi'
	icon_state = "wendigo_med"
	icon_living = "wendigo_med"
	icon_dead = "wendigo_med_dead"
	pixel_x = -8 * PIXEL_MULTIPLIER
	health = 250
	maxHealth = 250
	melee_damage_lower = 20
	melee_damage_upper = 35

/mob/living/simple_animal/hostile/wendigo/evolved/check_evolve()
	if(consumes > EVOLEVOLV && (!animal_count.Find(/mob/living/simple_animal/hostile/wendigo/alpha) || animal_count[/mob/living/simple_animal/hostile/wendigo/alpha] <= 0))
		var/mob/living/simple_animal/hostile/wendigo/alpha/new_wendigo = new /mob/living/simple_animal/hostile/wendigo/alpha(src.loc)
		new_wendigo.names = names
		qdel(src)
		return 1

/mob/living/simple_animal/hostile/wendigo/alpha
	desc = "You can't help but feel that, no matter what, you should have brought a bigger gun."
	icon = 'icons/mob/giantmobs.dmi'
	icon_state = "wendigo_noblood"
	icon_living = "wendigo_noblood"
	icon_dead = "wendigo_dead"
	var/icon_enraged = "wendigo"
	pixel_x = -16 * PIXEL_MULTIPLIER
	health = 600
	maxHealth = 600
	speed = 5
	move_to_delay = 10
	melee_damage_lower = 35
	melee_damage_upper = 50 //Jesus christ

	attacktext = "pulverizes"
	attack_sound = 'sound/weapons/heavysmash.ogg'
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS
	var/enraged = 0
	var/punch_throw_chance = 25
	var/punch_throw_speed = 1
	var/punch_throw_range = 10

/mob/living/simple_animal/hostile/wendigo/alpha/Life()
	..()
	if(isDead())
		return
	if(health < (maxHealth/2) && enraged == 0)
		visible_message("<span class = 'warning'>\The [src] seems to slow down, but looks angrier.</span>","<span class = 'warning'>You're not sure what that sound was, but it didn't sound good at all.</span>")
		enraged = 1
		speed = 7
		melee_damage_lower = 50
		melee_damage_upper = 85
		move_to_delay = 20
		icon_state = icon_enraged
		icon_living = icon_enraged
		environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS | SMASH_RWALLS
		punch_throw_chance = 45
		punch_throw_range = 15
		punch_throw_speed = 3
	if(health > 300 && enraged == 1)
		enraged = 0
		speed = initial(speed)
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)
		move_to_delay = initial(move_to_delay)
		icon_state = initial(icon_state)
		icon_living = initial(icon_living)
		environment_smash_flags = initial(environment_smash_flags)
		punch_throw_chance = initial(punch_throw_chance)
		punch_throw_range = initial(punch_throw_range)
		punch_throw_speed = initial(punch_throw_speed)

/mob/living/simple_animal/hostile/wendigo/alpha/AttackingTarget()
	..()
	if(istype(target, /mob/living))
		var/mob/living/M = target
		if(punch_throw_range && prob(punch_throw_chance))
			visible_message("<span class='danger'>\The [M] is thrown by the force of the assault!</span>")
			var/turf/T = get_turf(src)
			var/turf/target_turf
			if(istype(T, /turf/space)) // if ended in space, then range is unlimited
				target_turf = get_edge_target_turf(T, dir)
			else
				target_turf = get_ranged_target_turf(T, dir, punch_throw_range)
			M.throw_at(target_turf,100,punch_throw_speed)

/mob/living/simple_animal/hostile/wendigo/skifree
	name = "yeti"
	desc = "Holding F might not work this time."
	icon_state = "yeti"
	icon_living = "yeti"
	speed = -1
	move_to_delay = 1 //RUN
	health = 150
	maxHealth = 150
	melee_damage_lower = 20
	melee_damage_upper = 40

/mob/living/simple_animal/hostile/wendigo/skifree/death(var/gibbed = FALSE)
	..(TRUE)
	qdel(src)
