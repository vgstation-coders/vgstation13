#define AGGNO 0 //won't attack people at random
#define AGGYES 1 //Hunting for food
#define AGGALL 2 //May attack friends

#define ALPHANONE 0 //Do nothing, follow roughly
#define ALPHAFOLLOW 1 //Follow close
#define ALPHASTAY 2 //Hold
#define ALPHAATTACK 3 //Attack thing
#define ALPHAMOVE 4 //Move to location

#define WELLFED 3
#define HUNGRY 2
#define VHUNGRY 1
#define STARVING 0

#define MOVECOST 0.5
#define STANDCOST 0.5
#define REGENCOST 20

#define MAXALPHADIST 7
/* TODONE: Pack mentality - Wolves will generally stick around the 'alpha', at least within 6 tiles, unless hunting [x]
		Have a hunger level that ticks down, similar to carbon mobs. If it gets too low, they'll try to hunt for food. [x]
			If it gets increasingly low, they'll start attacking each other except the alpha [x]
		Can feed them like space carp to 'tame' them [x]
		Be able to point at them and then to elsewhere to 'instruct' them on where to go (To a turf, they go to that turf. To an animal, they attack that animal) [x]
*/
/mob/living/simple_animal/hostile/wolf
	name = "wolf"
	desc = "Not quite as cuddly as a corgi."
	icon_state = "wolf"
	icon_living = "wolf"
	icon_dead = "wolf_dead"
	speak_chance = 5
	turns_per_move = 4
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"

	speed = -1
	health = 75
	maxHealth = 75
	size = SIZE_SMALL

	stat_attack = DEAD //Gotta chow down somehow
	vision_range = 12 //Slightly larger vision range
	harm_intent_damage = 8
	melee_damage_lower = 15
	melee_damage_upper = 20
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	faction = "wolf"
	attack_same = 1 //Handled more in CanAttack
	minbodytemp = 200

	var/alert = 0 //Listening out for pointings from the pack alpha
	var/aggressive = AGGNO
	var/anger_chance = 30
	var/mob/living/pack_alpha //Who they will never attack, and if human, will listen to commands
	var/alpha_stance = ALPHANONE //What the alpha may want them to do
	var/atom/alpha_target //whomever the alpha has specified to attack
	var/mob/alpha_challenger //Whomever is challenging the alpha
	var/hunger_status //Scales off nutrition. 400+ = well fed, 300 hungry, 200 vhungry, 100 starving
	var/alpha_challenge //Used only by pack alphas, used for duels
	var/obj/effect/decal/point/point_last //Stores the last point we saw

/mob/living/simple_animal/hostile/wolf/alpha
	name = "wolf alpha"

/mob/living/simple_animal/hostile/wolf/alpha/New()
	..()
	pack_alpha = src
	name += " ([rand(0,999)])"
	spawn(5)
		var/list/can_see = view(src, vision_range)
		for(var/mob/living/simple_animal/hostile/wolf/potential_pack in can_see)
			if(potential_pack.isDead())
				continue //He ded
			if(potential_pack == src)
				continue //That's us
			if(!potential_pack.pack_alpha)
				potential_pack.pack_alpha = src
			else
				if(istype(potential_pack.pack_alpha, /mob/living/simple_animal/hostile/wolf))
					var/mob/living/simple_animal/hostile/wolf/alpha_challenger = potential_pack.pack_alpha
					alpha_challenger.challenge(src)
					challenge(alpha_challenger)

/mob/living/simple_animal/hostile/wolf/CanAttack(var/atom/the_target)
	//WE DON'T ATTACK INVULNERABLE MOBS (such as etheral jaunting mobs, or passengers of the adminbus)
	var/list/target_prox = view(the_target, vision_range)
	for(var/obj/machinery/space_heater/campfire/fire in target_prox)
		var/dist = get_dist(the_target, fire)
		if(dist < (fire.light_range*2))//Just sitting on the edge of the fire
			alpha_stance = ALPHANONE
			visible_message("<span class = 'notice'>\The [src] whimpers and runs from \the [fire]</span>")
			return
	if(the_target.flags & INVULNERABLE)
		return 0
	if(istype(the_target, /mob/dead/observer))
		return 0 //Stop eating ghosts!
	if((the_target == alpha_target && alpha_stance == ALPHAATTACK) || the_target == alpha_challenger)//Who the alpha has specified
		return the_target //RIP sanity, but alpha above all
	if(aggressive == AGGNO)
		if(the_target == pack_alpha && alpha_stance == ALPHAFOLLOW)
			return the_target
		return 0
	if(isliving(the_target))
		var/mob/living/L = the_target
		if(L == pack_alpha)
			if(alpha_stance == ALPHAFOLLOW)
				return the_target //Handled more in AttackingTarget
			else
				return 0
		if(istype(L, /mob/living/simple_animal/hostile/wolf))
			var/mob/living/simple_animal/hostile/wolf/potential_pack = L
			if(potential_pack.pack_alpha == pack_alpha) //Never eat a packmate
				return 0
			if(aggressive != AGGALL)//Not unless we're hungry
				return 0
			else
				return the_target
		if(L.faction == src.faction)
			if(aggressive != AGGALL)//Not unless we're hungry
				return 0
			else
				return the_target
		if(L.isDead())
			if(hunger_status < WELLFED)
				return the_target
			else
				return 0
	return ..(the_target)

/mob/living/simple_animal/hostile/wolf/AttackingTarget()
	if(!target)
		return

	if(target == pack_alpha)
		return	//As is said in carp.dm, a bit of a hacky way of making something follow somebody
	var/list/can_see = view(src, vision_range)
	for(var/mob/living/simple_animal/hostile/wolf/potential_pack in can_see)
		if(potential_pack.pack_alpha == src) //Source is alpha
			if(!alpha_challenge)//If we're not in a duel
				alpha_target = target

		if(potential_pack.pack_alpha == pack_alpha) //Part of the same pack
			potential_pack.target = target
	if(isliving(target))
		var/mob/living/mob_target = target
		if(mob_target.isDead() && !istype(mob_target, /mob/dead/observer))
			if(hunger_status < WELLFED)
				visible_message("<span class = 'notice'>\The [src] starts to take a bite out of \the [target].</span>")
				stop_automated_movement = 1
				var/target_loc = mob_target.loc
				var/self_loc = src.loc
				spawn(5 SECONDS)
					if(mob_target.loc == target_loc && self_loc == src.loc) //Not moved
						playsound(get_turf(src), 'sound/weapons/bite.ogg', 50, 1)
						var/damage = rand(melee_damage_lower, melee_damage_upper)
						mob_target.adjustBruteLoss(damage)
						nutrition += damage*3
			return
	return ..()

/mob/living/simple_animal/hostile/wolf/attackby(obj/W, mob/user)
	..()

	if(!isDead() && istype(W, /obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/F = W

		if(F.food_flags & FOOD_MEAT) //Any meaty dish goes!
			playsound(get_turf(src),'sound/items/eatfood.ogg', rand(10,50), 1)
			visible_message("<span class='info'>\The [src] gobbles up \the [W]!")
			nutrition += 15
			if(prob(25))
				if(!pack_alpha)
					pack_alpha = user
					to_chat(user, "<span class='info'>You have gained \the [src]'s trust.</span>")
					var/n_name = copytext(sanitize(input(user, "What would you like to name your new friend?", "Wolf Name", null) as text|null), 1, MAX_NAME_LEN)
					if(n_name && !user.incapacitated())
						name = n_name
					var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
					heart.plane = ABOVE_HUMAN_PLANE
					flick_overlay(heart, list(user.client), 20)
				else
					if(istype(pack_alpha, /mob/living/simple_animal/hostile/wolf))
						var/mob/living/simple_animal/hostile/wolf/alpha = pack_alpha
						alpha.challenge(user)
			qdel(F)

/mob/living/simple_animal/hostile/wolf/adjustBruteLoss(var/damage)
	if(!isDead())
		if(health <= maxHealth/2 || hunger_status < WELLFED)
			anger(1)
		else
			anger()
		if(pack_alpha == src && alpha_challenge == 0)//We are the alpha and not challenging others
			var/list/can_see = view(src, vision_range)
			for(var/mob/living/simple_animal/hostile/wolf/potential_pack in can_see)
				if(potential_pack.pack_alpha == src) //Part of our pack
					potential_pack.anger(1) //RIP
	..()

/mob/living/simple_animal/hostile/wolf/proc/anger(var/anger_override = 0)
	if(!aggressive)
		if(prob(anger_chance) || anger_override)
			aggressive = AGGYES
			stance = HOSTILE_STANCE_ATTACK


/mob/living/simple_animal/hostile/wolf/proc/challenge(mob/challenger)
	alpha_challenge = 1
	if(!aggressive)
		aggressive = AGGYES
	alpha_challenger = challenger
	target = challenger
	stance = HOSTILE_STANCE_ATTACK
	spawn(150) //15 seconds
		if(challenger.isDead())//If he's dead, calm down
			aggressive = AGGNO
			alpha_challenger = null
			alpha_challenge = 0
		else //Pack time!
			alpha_challenge = 0 //Else he's likely to get fucked up by the rest of the pack now


//For life, listen for any /obj/effect/decal/point objects in proximity. They have a reference to who pointed, and who's being pointed at.
/mob/living/simple_animal/hostile/wolf/Life()
	..()
	if(!isUnconscious())
		nutrition -= STANDCOST
		handle_hunger() //Handle hunger
		var/list/can_see = view(src, vision_range)

		for(var/obj/machinery/space_heater/campfire/fire in can_see)
			var/dist = get_dist(src, fire)
			if(dist < fire.light_range*2)
				walk_away(src,fire,(fire.light_range*2),move_to_delay)

		if(stance == HOSTILE_STANCE_IDLE && !client)
			//Check if the alpha is still alive
			if(pack_alpha)
				if(pack_alpha.isDead())
					visible_message("<span class = 'notice'>\The [src] lets out a mournful howl. </span>")
					//Howl noise?
					pack_alpha = null
				else
					if(alpha_stance == ALPHANONE) //Rough following
						var/dist = get_dist(src, pack_alpha)
						if(dist > MAXALPHADIST && (pack_alpha in can_see))
							Goto(pack_alpha, move_to_delay, MAXALPHADIST)

		//Alpha handling
		if(alpha_challenger && alpha_challenger.isDead())//If he's dead, calm down
			aggressive = AGGNO
			alpha_challenger = null
		point_listen(can_see)

		if(alpha_stance != ALPHANONE)
			switch(alpha_stance)
				if(ALPHAATTACK) //This should always be used in turn with alpha_target
					if(!alpha_target)
						alpha_stance = ALPHANONE
					else
						if(ismob(alpha_target))
							var/mob/living/L = alpha_target
							if(L.isDead() && hunger_status == WELLFED)
								alpha_target = null
								alpha_stance = ALPHANONE
						/*if(istype (alpha_target, /obj/structure/window) || istype (alpha_target, /obj/structure/grille))
							var/obj/structure/window/W = alpha_target //They both use the same code anyway
							if(W.health <= 0)
								alpha_target = null
								alpha_stance = ALPHANONE*/
				if(ALPHAMOVE)
					var/turf/target = alpha_target
					var/dist = get_dist(src, alpha_target)
					if(dist > 1) //Fucking magic numbers
						Goto(target, move_to_delay, 1) //Some leway, so there's a 3x3-ish area around the turf, save a pack fighting over a spot
					else
						alpha_target = null
						visible_message("<span class = 'notice'>\The [src] sits down patiently.</span")
						alpha_stance = ALPHASTAY
				if(ALPHASTAY)
					stop_automated_movement = 1
		else
			stop_automated_movement = 0


		if((health < (maxHealth/2)) && nutrition >= REGENCOST)
			health += rand(1,3)
			nutrition -= REGENCOST

/mob/living/simple_animal/hostile/wolf/proc/handle_hunger()
	switch(nutrition)
		if(300 to INFINITY)
			hunger_status = WELLFED
			if(stance == HOSTILE_STANCE_IDLE)
				aggressive = AGGNO
		if(250 to 300)
			hunger_status = HUNGRY
		if(150 to 250)
			hunger_status = VHUNGRY
			aggressive = AGGYES
		if(0 to 150)
			hunger_status = STARVING
			aggressive = AGGALL

/mob/living/simple_animal/hostile/wolf/examine(mob/user)
	..()
	if(!isDead())
		switch(hunger_status)
			if(WELLFED)
				to_chat(user, "<span class='info'>It seems well fed.</span>")
			if(HUNGRY)
				to_chat(user, "<span class='info'>It seems hungry.</span>")
			if(VHUNGRY)
				to_chat(user, "<span class='info'>It looks incredibly hungry.</span>")
			if(STARVING)
				to_chat(user, "<span class='warning'>It looks starving!</span>")
		if(pack_alpha == user)
			to_chat(user, "<span class='info'>It seems friendly to you.</span>")
		var/remaining_health_percent = round((health/maxHealth)*100)
		switch(remaining_health_percent)
			if(100 to 60)
				//Do nuthin
			if(59 to 30)
				to_chat(user, "<span class='warning'>It seems quite hurt.</span>")
			if(29 to 5)
				to_chat(user, "<span class='warning'>It seems extremely hurt.</span>")
			if(5 to 1)
				to_chat(user, "<span class='warning'>It seems close to death!</span>")
			if(0 to -INFINITY)
				to_chat(user, "<span class='warning'>It seems, well, dead.</span>")
		switch(alpha_stance)
			//if(ALPHANONE)
				//Nuthin, was gonna have barking, but PJB got angry
			if(ALPHAFOLLOW)
				to_chat(user, "<span class='info'>They seem to be following someone.</span>")
			if(ALPHAATTACK)
				to_chat(user, "<span class='warning'>It seems angry at something.</span>")
			if(ALPHAMOVE)
				to_chat(user, "<span class='info'>It seems to be going somewhere.</span>")
			if(ALPHASTAY)
				to_chat(user, "<span class='info'>It seems to be sitting down, waiting patiently.</span>")
/mob/living/simple_animal/hostile/wolf/Move()
	..()
	nutrition -= MOVECOST

/mob/living/simple_animal/hostile/wolf/proc/point_listen(var/list/can_see)
	if(pack_alpha == src)
		return //Stop us from getting caught in our own pointings

	for(var/obj/effect/decal/point/pointer in can_see)
		if(pointer == point_last)
			return

		point_last = pointer
		if(pointer.pointer != pack_alpha) //Not our alpha, not our problem
			return

		var/atom/target = pointer.target

		//If window or grille, break window or grille IT DON'T FUKKEN WORK
		//If mob, check if it's self or a pack member, then attack if not
		//If it's a turf, go to turf and wait
/*		if(istype (target, /obj/structure/window) || istype (target, /obj/structure/grille))
			alpha_stance = ALPHAATTACK
			alpha_target = target*/
		if(ismob(target))
			var/mob/living/M = target
			if(M == pack_alpha)
				alpha_stance = ALPHAFOLLOW
				return
			if(M == src)//That's us
				return //Handled in pointed_at
			if(istype(M, /mob/living/simple_animal/hostile/wolf))
				var/mob/living/simple_animal/hostile/wolf/PP = target
				if(PP.pack_alpha == pack_alpha)//Member of our pack
					return //Probably doing something in regards to pointed_at
			if(M.isDead())
				if(hunger_status == WELLFED)
					return

			stance = HOSTILE_STANCE_ATTACK
			alpha_stance = ALPHAATTACK
			alpha_target = target
		if(istype (target, /turf)) //We go!
			alpha_stance = ALPHAMOVE
			alpha_target = target

/mob/living/simple_animal/hostile/wolf/pointed_at(mob/pointer)
	if(!isDead())
		if(pointer == pack_alpha)
			switch(alpha_stance)
				if(ALPHAFOLLOW)
					alpha_stance = ALPHANONE
					to_chat(pointer, "<span class ='notice'>\The [src] is no longer following, and looks alert.</span>")
				if(ALPHANONE)
					alpha_stance = ALPHASTAY
					to_chat(pointer, "<span class='notice'>\The [src] is now staying on location.</span>")
				if(ALPHASTAY)
					alpha_stance = ALPHANONE
					stop_automated_movement = 0
					to_chat(pointer, "<span class='notice'>\The [src] sits up, no longer waiting.</span>")
		else
			to_chat(pointer, "<span class='warning'>\The [src] growls.</span>")

#undef AGGNO
#undef AGGYES
#undef AGGALL
#undef ALPHANONE
#undef ALPHAFOLLOW
#undef ALPHASTAY
#undef ALPHAATTACK
#undef WELLFED
#undef HUNGRY
#undef VHUNGRY
#undef STARVING
#undef MAXALPHADIST
#undef MOVECOST
#undef STANDCOST
#undef REGENCOST
