#define WOLF_AGGNO 0 //won't attack people at random
#define WOLF_AGGYES 1 //Hunting for food
#define WOLF_AGGALL 2 //May attack friends

#define WOLF_ALPHANONE 0 //Do nothing, follow roughly
#define WOLF_ALPHAFOLLOW 1 //Follow close
#define WOLF_ALPHASTAY 2 //Hold
#define WOLF_ALPHAATTACK 3 //Attack thing
#define WOLF_ALPHAMOVE 4 //Move to location

#define WOLF_WELLFED 3
#define WOLF_HUNGRY 2
#define WOLF_VHUNGRY 1
#define WOLF_STARVING 0

#define WOLF_MOVECOST 0.5
#define WOLF_STANDCOST 0.5
#define WOLF_REGENCOST 20

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
	emote_hear = list("growls", "howls")
	turns_per_move = 4
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"

	speed = 1
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
	var/aggressive = WOLF_AGGNO
	var/anger_chance = 30
	var/mob/living/pack_alpha //Who they will never attack, and if human, will listen to commands
	var/alpha_stance = WOLF_ALPHANONE //What the alpha may want them to do
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
		var/dist = get_dist(src, fire)
		if(dist < (fire.light_range*2))//Just sitting on the edge of the fire
			alpha_stance = WOLF_ALPHANONE
			visible_message("<span class = 'notice'>\The [src] whimpers and runs from \the [fire]</span>")
			return
	if(the_target.flags & INVULNERABLE)
		return 0
	if(istype(the_target, /mob/dead/observer))
		return 0 //Stop eating ghosts!
	if((the_target == alpha_target && alpha_stance == WOLF_ALPHAATTACK) || the_target == alpha_challenger)//Who the alpha has specified
		return the_target //RIP sanity, but alpha above all
	if(aggressive == WOLF_AGGNO)
		if(the_target == pack_alpha && alpha_stance == WOLF_ALPHAFOLLOW)
			return the_target
		return 0
	if(isliving(the_target))
		var/mob/living/L = the_target
		if(L == pack_alpha)
			if(alpha_stance == WOLF_ALPHAFOLLOW)
				return the_target //Handled more in AttackingTarget
			else
				return 0
		if(istype(L, /mob/living/simple_animal/hostile/wolf))
			var/mob/living/simple_animal/hostile/wolf/potential_pack = L
			if(potential_pack.pack_alpha == pack_alpha) //Never eat a packmate
				return 0
			if(aggressive != WOLF_AGGALL)//Not unless we're hungry
				return 0
			else
				return the_target
		if(L.faction == src.faction)
			if(aggressive != WOLF_AGGALL)//Not unless we're hungry
				return 0
			else
				return the_target
		if(L.isDead())
			if(hunger_status < WOLF_WELLFED)
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
			if(hunger_status < WOLF_WELLFED)
				visible_message("<span class = 'notice'>\The [src] starts to take a bite out of \the [target].</span>")
				stop_automated_movement = 1
				var/target_loc = mob_target.loc
				var/self_loc = src.loc
				spawn(5 SECONDS)
					if(mob_target.loc == target_loc && self_loc == src.loc) //Not moved
						playsound(src, 'sound/weapons/bite.ogg', 50, 1)
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
			playsound(src,'sound/items/eatfood.ogg', rand(10,50), 1)
			visible_message("<span class='info'>\The [src] gobbles up \the [W]!")
			nutrition += 15
			if(prob(25))
				if(!pack_alpha)
					pack_alpha = user
					to_chat(user, "<span class='info'>You have gained \the [src]'s trust.</span>")
					message_admins("[key_name(user)] has tamed a wolf: @[formatJumpTo(user, "JMP")]")
					log_admin("[key_name(user)] has tamed a wolf:  @([user.x], [user.y], [user.z])")
					name_mob(user)
				else
					if(istype(pack_alpha, /mob/living/simple_animal/hostile/wolf))
						var/mob/living/simple_animal/hostile/wolf/alpha = pack_alpha
						alpha.challenge(user)
			qdel(F)

/mob/living/simple_animal/hostile/wolf/adjustBruteLoss(var/damage)
	if(!isDead())
		if(health <= maxHealth/2 || hunger_status < WOLF_WELLFED)
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
			aggressive = WOLF_AGGYES
			stance = HOSTILE_STANCE_ATTACK


/mob/living/simple_animal/hostile/wolf/proc/challenge(mob/challenger)
	alpha_challenge = 1
	if(!aggressive)
		aggressive = WOLF_AGGYES
	alpha_challenger = challenger
	target = challenger
	stance = HOSTILE_STANCE_ATTACK
	spawn(150) //15 seconds
		if(challenger.isDead())//If he's dead, calm down
			aggressive = WOLF_AGGNO
			alpha_challenger = null
			alpha_challenge = 0
		else //Pack time!
			alpha_challenge = 0 //Else he's likely to get fucked up by the rest of the pack now


//For life, listen for any /obj/effect/decal/point objects in proximity. They have a reference to who pointed, and who's being pointed at.
/mob/living/simple_animal/hostile/wolf/Life()
	..()
	if(!isUnconscious())
		nutrition -= WOLF_STANDCOST
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
					if(alpha_stance == WOLF_ALPHANONE) //Rough following
						var/dist = get_dist(src, pack_alpha)
						if(dist > MAXALPHADIST && (pack_alpha in can_see))
							Goto(pack_alpha, move_to_delay, MAXALPHADIST)

		//Alpha handling
		if(alpha_challenger && alpha_challenger.isDead())//If he's dead, calm down
			aggressive = WOLF_AGGNO
			alpha_challenger = null
		point_listen(can_see)

		if(alpha_stance != WOLF_ALPHANONE)
			switch(alpha_stance)
				if(WOLF_ALPHAATTACK) //This should always be used in turn with alpha_target
					if(!alpha_target)
						alpha_stance = WOLF_ALPHANONE
					else
						if(ismob(alpha_target))
							var/mob/living/L = alpha_target
							if(L.isDead() && hunger_status == WOLF_WELLFED)
								alpha_target = null
								alpha_stance = WOLF_ALPHANONE
						/*if(istype (alpha_target, /obj/structure/window) || istype (alpha_target, /obj/structure/grille))
							var/obj/structure/window/W = alpha_target //They both use the same code anyway
							if(W.health <= 0)
								alpha_target = null
								alpha_stance = WOLF_ALPHANONE*/
						log_admin("A wolf is attacking a target, [key_name(alpha_target)], their alpha is: [key_name(pack_alpha)] @([src.x], [src.y], [src.z])")
				if(WOLF_ALPHAMOVE)
					var/turf/target = alpha_target
					var/dist = get_dist(src, alpha_target)
					if(dist > 1) //Fucking magic numbers
						Goto(target, move_to_delay, 1) //Some leway, so there's a 3x3-ish area around the turf, save a pack fighting over a spot
					else
						alpha_target = null
						visible_message("<span class = 'notice'>\The [src] sits down patiently.</span")
						alpha_stance = WOLF_ALPHASTAY
				if(WOLF_ALPHASTAY)
					stop_automated_movement = 1
		else
			stop_automated_movement = 0


		if((health < (maxHealth/2)) && nutrition >= WOLF_REGENCOST)
			health += rand(1,3)
			nutrition -= WOLF_REGENCOST

/mob/living/simple_animal/hostile/wolf/proc/handle_hunger()
	switch(nutrition)
		if(300 to INFINITY)
			hunger_status = WOLF_WELLFED
			if(stance == HOSTILE_STANCE_IDLE)
				aggressive = WOLF_AGGNO
		if(250 to 300)
			hunger_status = WOLF_HUNGRY
		if(150 to 250)
			hunger_status = WOLF_VHUNGRY
			aggressive = WOLF_AGGYES
		if(0 to 150)
			hunger_status = WOLF_STARVING
			aggressive = WOLF_AGGALL

/mob/living/simple_animal/hostile/wolf/examine(mob/user)
	..()
	if(!isDead())
		switch(hunger_status)
			if(WOLF_WELLFED)
				to_chat(user, "<span class='info'>It seems well fed.</span>")
			if(WOLF_HUNGRY)
				to_chat(user, "<span class='info'>It seems hungry.</span>")
			if(WOLF_VHUNGRY)
				to_chat(user, "<span class='info'>It looks incredibly hungry.</span>")
			if(WOLF_STARVING)
				to_chat(user, "<span class='warning'>It looks starving!</span>")
		if(pack_alpha == user)
			to_chat(user, "<span class='info'>It seems friendly to you.</span>")
		var/remaining_health_percent = round((health/maxHealth)*100)
		switch(remaining_health_percent)
			//if(60 to 100)
				//Do nuthin
			if(30 to 59)
				to_chat(user, "<span class='warning'>It seems quite hurt.</span>")
			if(5 to 29)
				to_chat(user, "<span class='warning'>It seems extremely hurt.</span>")
			if(1 to 5)
				to_chat(user, "<span class='warning'>It seems close to death!</span>")
			if(-INFINITY to 0)
				to_chat(user, "<span class='warning'>It seems, well, dead.</span>")
		switch(alpha_stance)
			//if(WOLF_ALPHANONE)
				//Nuthin, was gonna have barking, but PJB got angry
			if(WOLF_ALPHAFOLLOW)
				to_chat(user, "<span class='info'>They seem to be following someone.</span>")
			if(WOLF_ALPHAATTACK)
				to_chat(user, "<span class='warning'>It seems angry at something.</span>")
			if(WOLF_ALPHAMOVE)
				to_chat(user, "<span class='info'>It seems to be going somewhere.</span>")
			if(WOLF_ALPHASTAY)
				to_chat(user, "<span class='info'>It seems to be sitting down, waiting patiently.</span>")
/mob/living/simple_animal/hostile/wolf/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	..()
	nutrition -= WOLF_MOVECOST

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
			alpha_stance = WOLF_ALPHAATTACK
			alpha_target = target*/
		if(ismob(target))
			var/mob/living/M = target
			if(M == pack_alpha)
				alpha_stance = WOLF_ALPHAFOLLOW
				return
			if(M == src)//That's us
				return //Handled in pointed_at
			if(istype(M, /mob/living/simple_animal/hostile/wolf))
				var/mob/living/simple_animal/hostile/wolf/PP = target
				if(PP.pack_alpha == pack_alpha)//Member of our pack
					return //Probably doing something in regards to pointed_at
			if(M.isDead())
				if(hunger_status == WOLF_WELLFED)
					return

			stance = HOSTILE_STANCE_ATTACK
			alpha_stance = WOLF_ALPHAATTACK
			alpha_target = target
			add_attacklogs(pack_alpha, target, "ordered a wolf a wolf to attack", src, null, TRUE)
			log_admin("[key_name(pack_alpha)] has ordered a wolf to attack [key_name(target)] @([src.x], [src.y], [src.z])")
		if(istype (target, /turf)) //We go!
			alpha_stance = WOLF_ALPHAMOVE
			alpha_target = target

/mob/living/simple_animal/hostile/wolf/pointed_at(mob/pointer)
	if(!isDead() && see_invisible >= pointer.invisibility)
		if(pointer == pack_alpha)
			switch(alpha_stance)
				if(WOLF_ALPHAFOLLOW)
					alpha_stance = WOLF_ALPHANONE
					to_chat(pointer, "<span class ='notice'>\The [src] is no longer following, and looks alert.</span>")
				if(WOLF_ALPHANONE)
					alpha_stance = WOLF_ALPHASTAY
					to_chat(pointer, "<span class='notice'>\The [src] is now staying on location.</span>")
				if(WOLF_ALPHASTAY)
					alpha_stance = WOLF_ALPHANONE
					stop_automated_movement = 0
					to_chat(pointer, "<span class='notice'>\The [src] sits up, no longer waiting.</span>")
		else
			to_chat(pointer, "<span class='warning'>\The [src] growls.</span>")

#undef WOLF_AGGNO
#undef WOLF_AGGYES
#undef WOLF_AGGALL
#undef WOLF_ALPHANONE
#undef WOLF_ALPHAFOLLOW
#undef WOLF_ALPHASTAY
#undef WOLF_ALPHAATTACK
#undef WOLF_WELLFED
#undef WOLF_HUNGRY
#undef WOLF_VHUNGRY
#undef WOLF_STARVING
#undef MAXALPHADIST
#undef WOLF_MOVECOST
#undef WOLF_STANDCOST
#undef WOLF_REGENCOST
