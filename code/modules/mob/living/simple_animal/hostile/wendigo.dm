/*	TODONE:
	Let them evolve and heal from eating. Should a carbon they eat go over a certain damage threshold and
	the wendigo is at full health. Strip and delete the corpse. [x]
	Human wendigo->1 eat->Wendigo->3 eat->Alpha Wendigo (Can only be ONE at any time) [x]
	They don't like fire. Will stay away from fire (As far as their light radius -1) and won't target anyone
	in vicinity of said fire [x]
	Can mimic voices, steal poly code, and change it (Maybe just keep a log of people consumed,
	and use their name plus shout for help) [x]
	Butcherable for one piece of meat only. When consumed (Don't use reagents) will begin to turn the person [x]
*/
#define HUMEVOLV 1
#define EVOLEVOLV 3

/mob/living/simple_animal/hostile/wendigo
	name = "wendigo"
	desc = "Thought to be just a cautionary tale, now moreso than ever."
	icon_state = "wendigo"
	icon_living = "wendigo"
	icon_dead = "wendigo_dead"

	health = 150
	maxHealth = 150
	speed = 1
	stat_attack = DEAD //Gotta chow down somehow
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
	environment_smash = 1
	speak = list("Help!","Help me!","Somebody help!","Get over here, quickly!")


/mob/living/simple_animal/hostile/wendigo/CanAttack(var/atom/the_target)
	var/list/target_prox = view(the_target, vision_range)
	for(var/obj/machinery/space_heater/campfire/fire in target_prox)
		var/dist = get_dist(the_target, fire)
		if(dist < (fire.light_range*2))//Just sitting on the edge of the fire
			return

	return ..(the_target)

/mob/living/simple_animal/hostile/wendigo/AttackingTarget()
	if(!target)
		return

	if(ismob(target))
		var/mob/living/mob_target = target
		if(mob_target.isDead() && !istype(mob_target, /mob/dead/observer))
			visible_message("<span class = 'notice'>\The [src] starts to take a bite out of \the [target].</span>")
			stop_automated_movement = 1
			var/target_loc = mob_target.loc
			var/self_loc = src.loc
			spawn(50)
				if(mob_target.loc == target_loc && self_loc == src.loc) //Not moved
					playsound(get_turf(src), 'sound/weapons/bite.ogg', 50, 1)
					var/damage = rand(melee_damage_lower, melee_damage_upper)
					mob_target.adjustBruteLoss(damage)
					if(health < maxHealth)
						health = min(maxHealth,(health+damage))
					if((ishuman(mob_target) && mob_target.health < -400) || (istype(mob_target,/mob/living/simple_animal) && mob_target.health <= 0))
						visible_message("<span class = 'warning'>\The [src] is trying to eat \The [mob_target]!</span>","<span class = 'warning'>You hear crunching.</span>")
						spawn(50)
							if(mob_target.loc == target_loc && self_loc == src.loc)
								if(ishuman(mob_target))
									consumes += 1
									names += mob_target.real_name
								health = max(maxHealth, health + mob_target.maxHealth)
								qdel(mob_target)


			return
	return ..()

/mob/living/simple_animal/hostile/wendigo/Life()
	/*Check evolve like zombies, run away from fire,
	mimic speech if anyone's nearby but just out of eyesight
	*/
	..()
	if(!isDead())
		check_evolve()

		var/list/can_see = view(src, vision_range)

		for(var/obj/machinery/space_heater/campfire/fire in can_see)
			var/dist = get_dist(src, fire)
			if(dist < fire.light_range*2)
				walk_away(src,fire,(fire.light_range*2),move_to_delay)


		if(names.len)
			speak_chance = 15


/mob/living/simple_animal/hostile/wendigo/GetVoice()
	if(names.len)
		return pick(names)
	else
		speak_chance = 0
		return name
/mob/living/simple_animal/hostile/wendigo/proc/check_evolve()
	return

/mob/living/simple_animal/hostile/wendigo/human
	icon_state = "wendigo"
	icon_living = "wendigo"
	icon_dead = "wendigo_dead"

	speed = 1

/mob/living/simple_animal/hostile/wendigo/human/Die()
	flick("wendigo_dying",src)
	..()

/mob/living/simple_animal/hostile/wendigo/human/check_evolve()
	if(consumes > HUMEVOLV)
		var/mob/living/simple_animal/hostile/wendigo/evolved/new_wendigo = new /mob/living/simple_animal/hostile/wendigo/evolved(src.loc)
		new_wendigo.names = names
		qdel(src)

/mob/living/simple_animal/hostile/wendigo/evolved
	icon = 'icons/mob/48x48.dmi'
	icon_state = "wendigo_med"
	icon_living = "wendigo_med"
	icon_dead = "wendigo_med_dead"
	pixel_x = -8 * PIXEL_MULTIPLIER
	health = 250
	maxHealth = 250

	melee_damage_lower = 25
	melee_damage_upper = 45

/mob/living/simple_animal/hostile/wendigo/evolved/check_evolve()
	if(consumes > EVOLEVOLV)
		if(wendigo_alpha)
			for(var/mob/living/simple_animal/hostile/wendigo/alpha/A in wendigo_alpha)
				var/datum/zLevel/L = get_z_level(A)
				if(istype(L,/datum/zLevel/centcomm))
					continue
				else
					if(A.isDead())
						continue
					return //One exists, abort!

			var/mob/living/simple_animal/hostile/wendigo/alpha/new_wendigo = new /mob/living/simple_animal/hostile/wendigo/alpha(src.loc)
			new_wendigo.names = names.Copy()
			qdel(src)

var/list/wendigo_alpha = list()

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
	melee_damage_lower = 35
	melee_damage_upper = 50 //Jesus christ

	attacktext = "pulverizes"
	attack_sound = 'sound/weapons/heavysmash.ogg'
	environment_smash = 2
	var/enraged = 0
	var/punch_throw_chance = 25
	var/punch_throw_speed = 1
	var/punch_throw_range = 10

/mob/living/simple_animal/hostile/wendigo/alpha/New()
	..()
	wendigo_alpha += src

/mob/living/simple_animal/hostile/wendigo/alpha/Die()
	..()
	wendigo_alpha -= src

/mob/living/simple_animal/hostile/wendigo/alpha/Life()
	..()
	if(health < 300 && enraged == 0)
		visible_message("<span class = 'warning'>\The [src] seems to slow down, but looks angrier</span>","You're not sure what that sound was, but it didn't sound good at all")
		enraged = 1
		speed = 7
		melee_damage_lower = 50
		melee_damage_upper = 85
		icon_state = icon_enraged
		icon_living = icon_enraged
		environment_smash = 3
		punch_throw_chance = 45
		punch_throw_range = 15
		punch_throw_speed = 3
	if(health > 300 && enraged == 1)
		enraged = 0
		speed = initial(speed)
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)
		icon_state = initial(icon_state)
		icon_living = initial(icon_living)
		environment_smash = initial(environment_smash)
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
	desc = "holding F might not work this time"
	icon_state = "yeti"
	icon_living = "yeti"
	speed = -1
	health = 150
	maxHealth = 150
	melee_damage_lower = 20
	melee_damage_upper = 40

/mob/living/simple_animal/hostile/wendigo/skifree/death()
	..()
	qdel(src)