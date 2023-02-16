///////////////////////////////////////////////////////////////////GYM RAT///////////
// A swole mouse! At the cost of no longer being able to ventcrawl, it has gained the power to increase its mass and striking power with protein. Not quite too swole to control...
/mob/living/simple_animal/hostile/retaliate/gym_rat
	name = "gym rat"
	desc = "It's pretty swole."
	icon_state = "gymrat"
	icon_living = "gymrat"
	icon_dead = "gymrat-dead"
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "stamps on the"
	treadmill_speed = 6
	health = 30
	maxHealth = 30
	speak_chance = 2
	turns_per_move = 5
	see_in_dark = 6
	speak = list("More protein!","No pain, no gain!","I'm the cream of the crop!")
	speak_emote = list("squeaks loudly")
	emote_hear = list("squeaks loudly")
	emote_see = list("flexes", "sweats", "does a rep")
	appearance_flags = PIXEL_SCALE
	size = SIZE_SMALL // If they're not at least small it doesn't seem like the treadmill works or makes sound
	pass_flags = PASSTABLE
	stop_automated_movement_when_pulled = TRUE

	min_oxy = 8 //Require atleast 8kPA oxygen
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius

	attacktext = "headbutts"
	attack_sound = 'sound/weapons/punch1.ogg'

	melee_damage_lower = 1
	melee_damage_upper = 5

	var/health_cap = 100 // Eating protein can pack on a whopping 233% increase in max health. GAINZ
	var/icon_eat = "gymrat-eat"
	var/obj/my_wheel
	var/list/gym_equipments = list(/obj/structure/stacklifter, /obj/structure/punching_bag, /obj/structure/weightlifter, /obj/machinery/power/treadmill)
	var/static/list/edibles = list(/obj/item/weapon/reagent_containers/food/snacks)

	var/scalerate = 1
	var/translaterate = 4.5 //it is multiplied by the current scalerate, and we want a final value of 9
	var/all_fours = TRUE

	var/last_scavenge = 0
	var/const/scavenge_cooldown = 15 SECONDS

	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS

/mob/living/simple_animal/hostile/retaliate/gym_rat/update_icon()
	if(all_fours == TRUE)
		icon_state = "gymrat"
		icon_eat = "gymrat-eat"
		attacktext = "headbutts"
	else
		icon_state = "gymrat_stand"
		icon_eat = null
		attacktext = "punches"

/mob/living/simple_animal/hostile/retaliate/gym_rat/UnarmedAttack(var/atom/A)
	if(istype(A, /obj/machinery/disposal)) // If we click on a disposal unit and 15 seconds have passed, let's look for meat or cheese
		to_chat(src, text("<span class='notice'>You rummage through the [A].</span>"))

		if((last_scavenge + scavenge_cooldown >= world.time))
			to_chat(src, text("<span class='warning'>You just checked a disposal unit! You won't find anything new for now.</span>")) // If we scavenged too recently, we get told to wait

		if((last_scavenge + scavenge_cooldown < world.time))
			last_scavenge = world.time
			if(prob(60))
				to_chat(src, text("<span class='warning'>You don't find anything interesting.</span>"))
			else
				to_chat(src, text("<span class='warning'>You find something!</span>"))
				new /obj/item/weapon/reagent_containers/food/snacks/cheesewedge_scraps(src.loc)

	if(istype(A, /obj/machinery/microwave))
		to_chat(src, text("<span class='notice'>You rummage through the [A].</span>"))

		if((last_scavenge + scavenge_cooldown >= world.time))
			to_chat(src, text("<span class='warning'>You just checked a microwave! You won't find anything new for now.</span>")) // If we scavenged too recently, we get told to wait

		if((last_scavenge + scavenge_cooldown < world.time))
			last_scavenge = world.time
			if(prob(60))
				to_chat(src, text("<span class='warning'>You don't find anything interesting.</span>"))
			else
				to_chat(src, text("<span class='warning'>You find something!</span>"))
				new /obj/item/weapon/reagent_containers/food/snacks/meat/scraps(src.loc)

	if(is_type_in_list(A, edibles)) // If we click on something edible, it's time to chow down!
		delayNextAttack(10)
		chowdown(A)
	if(is_type_in_list(A, gym_equipments)) // If we click on gym equipment, it's time to work out!
		A.attack_hand(src, 0, A.Adjacent(src))
	else return ..()

/mob/living/simple_animal/hostile/retaliate/gym_rat/proc/chowdown(var/obj/item/weapon/reagent_containers/food/snacks/F)
	if(F.food_flags & FOOD_MEAT) // Meat will heal us, and also pack on some max hp!
		visible_message("\The [name] gobbles up \the [F].", "<span class='notice'>You gobble up the [F].</span>")
		playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
		if(maxHealth < health_cap) // Are we below our max gainz level? Add on some max hp!
			adjust_hp(5)
			if(initial(maxHealth) == 30) //regular gym rat
				scalerate += (1/14)
			else						//pompadour
				scalerate += (1/16)
			if(scalerate > 2) //to tame the float point inaccuracies
				scalerate = 2
			var/matrix/M = matrix()
			M.Scale(scalerate,scalerate)
			M.Translate(0, translaterate*scalerate)
			transform = M
		else
			health+=5 // Otherwise we just get a little health back
			to_chat(src, text("<span class='warning'>The meat nourishes you, but your muscles don't grow. You've bulked all you can...</span>"))
		flick(icon_eat, src)
		qdel(F)
	if(istype(F,/obj/item/weapon/reagent_containers/food/snacks/cheesewedge_scraps)) //Half-eaten cheese wedge. Better than nothing
		health+=4
		visible_message("\The [name] gobbles up \the [F].", "<span class='notice'>You gobble up the [F].</span>")
		playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
		flick(icon_eat, src)
		qdel(F)
	if(istype(F,/obj/item/weapon/reagent_containers/food/snacks/cheesewedge)) //Mmm, cheese wedge. Gives back a small amount of health upon consumption
		health+=6
		visible_message("\The [name] gobbles up \the [F].", "<span class='notice'>You gobble up the [F].</span>")
		playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
		flick(icon_eat, src)
		qdel(F)
	if(istype(F,/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel)) //A cheese wheel feast! Gives back a lot more health than just a slice
		health+=30
		visible_message("\The [name] gobbles up \the [F].", "<span class='notice'>You gobble up the [F].</span>")
		playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
		flick(icon_eat, src)
		qdel(F)

/mob/living/simple_animal/hostile/retaliate/gym_rat/proc/adjust_hp(var/amount)
	if(amount > 0 && maxHealth < health_cap) //below health_cap, increase maxHealth but no further than health_cap
		maxHealth += amount
		to_chat(src, text("<span class='warning'>You feel your muscles growing!</span>"))
	health += amount
	if(maxHealth < 60)
		melee_damage_lower = 1
		melee_damage_upper = 5
		environment_smash_flags &= ~OPEN_DOOR_STRONG
	else
		melee_damage_lower = 5
		melee_damage_upper = 10
		environment_smash_flags |= OPEN_DOOR_STRONG

/mob/living/simple_animal/hostile/retaliate/gym_rat/Life() // Copied from hammy wheel running code
	if(timestopped)
		return 0
	. = ..()
	if(.)
		if(enemies.len && prob(5))
			Calm()
	if(!my_wheel && isturf(loc) && !client) // Gym rats with players in them won't be force moved
		for(var/obj/O in view(2, src))
			if(is_type_in_list(O, gym_equipments))
				my_wheel = locate(O) in view(2, src)
				wander = FALSE
				gymratwheel(20)
				break
			else
				wander = TRUE

/mob/living/simple_animal/hostile/retaliate/gym_rat/proc/gymratwheel(var/repeat)
	if(repeat < 1 || stat)
		wander = TRUE
		my_wheel = null
		return
	if(my_wheel)
		if(istype(my_wheel, /obj/structure/stacklifter))
			var/obj/structure/stacklifter/S = my_wheel
			S.attack_hand(src, 0, S.Adjacent(src))
		else if(istype(my_wheel, /obj/structure/punching_bag))
			var/obj/structure/punching_bag/P = my_wheel
			P.attack_hand(src, 0, P.Adjacent(src))
		else if(istype(my_wheel, /obj/structure/weightlifter))
			var/obj/structure/weightlifter/W = my_wheel
			W.attack_hand(src, 0, W.Adjacent(src))
		else if(istype(my_wheel, /obj/machinery/power/treadmill) && my_wheel.loc == loc)
			step(src,my_wheel.dir)
		step_towards(src,my_wheel)
	else
		wander = TRUE

	delayNextMove(speed)
	sleep(speed)
	gymratwheel(repeat-1)

/mob/living/simple_animal/hostile/retaliate/gym_rat/proc/Calm()
	enemies.Cut()
	LoseTarget()

/mob/living/simple_animal/hostile/retaliate/gym_rat/Retaliate()
	if(!stat)
		..()

/mob/living/simple_animal/hostile/retaliate/gym_rat/attackby(var/obj/item/weapon/reagent_containers/food/snacks/F as obj, var/mob/user as mob) // Feed the gym rat some food
	if(stat == CONSCIOUS)
		if(is_type_in_list(F, edibles)) // If it's something edible, chow down!
			chowdown(F)
		else
			..()
	else
		..()

/mob/living/simple_animal/hostile/retaliate/gym_rat/verb/stand_up() // Allows the gym rat to toggle poses. They can stand upright, or walk around like a typical mouse
	set name = "Stand Up / Lie Down"
	set desc = "Stand up and show off your guns, or walk on all fours to not embarrass the nerds."
	set category = "GymRat"

	if(all_fours == TRUE)
		all_fours = FALSE
		to_chat(src, text("<span class='notice'>You are now standing upright.</span>"))
		update_icon()

	else
		all_fours = TRUE
		to_chat(src, text("<span class='notice'>You are now moving on all fours.</span>"))
		update_icon()

/mob/living/simple_animal/hostile/retaliate/gym_rat/verb/info() // Tells the gym rat how to gym rat
	set name = "How 2 Gainz"
	set desc = "How do become swole?"
	set category = "GymRat"

	to_chat(src, text("<span class='warning'>You are a gym rat, a much larger and stronger cousin of a normal mouse.</span>"))
	to_chat(src, text("<span class='warning'>You need cheese and meaty foods. Cheese will heal you, and meat will increase your attack damage and maximum health.</span>"))
	to_chat(src, text("<span class='warning'>If you're desperate, you can scavenge for meat or cheese from disposal units or microwaves.</span>"))
	to_chat(src, text("<span class='warning'>Protect your gains, and avoid soy milk at all costs. If you lose your gains, there's no going back.</span>"))

/mob/living/simple_animal/hostile/retaliate/gym_rat/reagent_act(id, method, volume) // Gym rats have to keep away from soymilk... it's bad for their gainz
	if(isDead())
		return

	.=..()

	switch(id)
		if(SOYMILK)
			if(maxHealth >= 20)
				visible_message("<span class='warning'>[src] seems to shrink as the soymilk washes over them! Its muscles look less visible...</span>")
				maxHealth-=10
				if(initial(maxHealth) == 30) //regular gym rat
					scalerate -= (1/7)
				else if(initial(maxHealth) == 40) //pompadour
					scalerate -= (1/8)
				else //roidrat
					scalerate -= (1/10)
				if(scalerate < 1) //to tame the float point inaccuracies 
					scalerate = 1
				var/matrix/M = matrix()
				M.Scale(scalerate,scalerate)
				M.Translate(0, -translaterate*scalerate)
				transform = M
				adjustBruteLoss(1) // Here so that the mouse aggros. It won't be happy that you're cutting into its gainz!
			if(maxHealth < 20)
				visible_message("<span class='warning'>[src] shrinks back into a more appropriate size for a mouse.</span>")
				transmogrify()

/mob/living/simple_animal/hostile/retaliate/gym_rat/New() // speaks mouse
	..()
	languages += all_languages[LANGUAGE_MOUSE]

/mob/living/simple_animal/hostile/retaliate/gym_rat/mothership // Mothership faction version, so it doesn't get attacked by the vault dwellers
	faction = "mothership"

///////////////////////////////////////////////////////////////////POMPADOUR RAT///////////
// Who's that handsome rat? 911 emergency, there's a handsome rat in my house!
/mob/living/simple_animal/hostile/retaliate/gym_rat/pompadour_rat
	name = "pomdadour rat"
	desc = "Dang! That's a pretty hunky mouse, let me tell ya."
	icon_state = "gymrat_pompadour"
	icon_living = "gymrat_pompadour"
	icon_dead = "gymrat_pompadour-dead"
	health = 40 // A pompadour rat has a little more health that a regular gym rat
	maxHealth = 40
	speak = list("I'm a rat burger, with extra beef.","Hoo-ha hooah!","Damn, I'm pretty.")
	emote_see = list("flexes", "admires itself", "does a rep", "poses", "brushes its pompadour")

	melee_damage_lower = 1
	melee_damage_upper = 6
	health_cap = 120 // Eating protein can pack on a whopping 200% increase in max health. GAINZ
	icon_eat = "gymrat_pompadour-eat"

/mob/living/simple_animal/hostile/retaliate/gym_rat/pompadour_rat/update_icon()
	if(all_fours == TRUE)
		icon_state = "gymrat_pompadour"
		icon_eat = "gymrat_pompadour-eat"
		attacktext = "headbutts"
	else
		icon_state = "gymrat_pompadour_stand"
		icon_eat = null
		attacktext = "punches"

/mob/living/simple_animal/hostile/retaliate/gym_rat/pompadour_rat/adjust_hp(var/amount)
	if(amount > 0 && maxHealth < health_cap) //below health_cap, increase maxHealth but no further than health_cap
		maxHealth += amount
		to_chat(src, text("<span class='warning'>You feel your muscles growing!</span>"))
	health += amount
	if(maxHealth < 80)
		melee_damage_lower = 1
		melee_damage_upper = 6
		environment_smash_flags &= ~OPEN_DOOR_STRONG
	else
		melee_damage_lower = 6
		melee_damage_upper = 12
		environment_smash_flags |= OPEN_DOOR_STRONG

/mob/living/simple_animal/hostile/retaliate/gym_rat/pompadour_rat/Life()
	if(timestopped)
		return 0
	. = ..()
	if(.)
		if(enemies.len && prob(5))
			Calm()
	if(!my_wheel && isturf(loc) && !client) // Pompadour rats with players in them won't be force moved
		for(var/obj/O in view(2, src))
			if(is_type_in_list(O, gym_equipments))
				my_wheel = locate(O) in view(2, src)
				wander = FALSE
				gymratwheel(20)
				break
			else
				wander = TRUE

///////////////////////////////////////////////////////////////////ROID RAT///////////
// That mouse is shredded! Has the science of bodybuilding gone too far? Possibly too swole to control!
/mob/living/simple_animal/hostile/retaliate/gym_rat/roid_rat
	name = "roid rat"
	desc = "It's yoked! Holy shit!"
	icon_state = "roidrat"
	icon_living = "roidrat"
	response_help  = "massages the"
	response_disarm = "stares jealously at the"
	response_harm   = "angrily kicks the"
	treadmill_speed = 3 // CARDIO IS FOR DWEEBS
	health = 150 // Damn, brother
	maxHealth = 150
	speak = list("I'M A LEAN, MEAN, WEIGHT PUMPIN'MACHINE.","I BEEN TO THE TOP OF THE MOUNTAIN!","NOTHING MEANS NOTHING!","MAX YOUR PUMP.","OH YEAAAAAH.","CHECK OUT MY PECS, LITTLE MAN.")
	speak_emote = list("squeaks thunderously")
	emote_hear = list("squeaks thunderously")

	melee_damage_lower = 10
	melee_damage_upper = 20

	health_cap = 250 // Eating protein can pack on a 66% increase in max health. Less percentage-wise than gym rats who are working out the "natural" way, but the raw numbers are still pretty scary
	icon_eat = "roidrat-eat"
	var/punch_throw_chance = 20 // Chance of sending a target flying a short distance with a punch
	var/punch_throw_speed = 3
	var/punch_throw_range = 6

	var/damageblock = 10

	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG
	status_flags = UNPACIFIABLE // Can't pacify muscles like these with hippy shit

/mob/living/simple_animal/hostile/retaliate/gym_rat/roid_rat/update_icon()
	if(all_fours == TRUE)
		icon_state = "roidrat"
		icon_eat = "roidrat-eat"
		attacktext = "headbutts"
	else
		icon_state = "roidrat_dudestop"
		icon_eat = null
		attacktext = "punches"

/mob/living/simple_animal/hostile/retaliate/gym_rat/roid_rat/proc/bulkblock(var/damage, var/atom/A)// roid rats are unaffected by brute damage of 10 or lower
	if (!damage || damage <= damageblock)
		if (A)
			visible_message("<span class='danger'>\The [A] bounces ineffectually off \the [src]'s bulk! </span>")
			playsound(src, 'sound/weapons/genhit1.ogg', 50, 1)
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/retaliate/gym_rat/roid_rat/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(bulkblock(O.force, O))
		user.delayNextAttack(8)
	else
		..()

/mob/living/simple_animal/hostile/retaliate/gym_rat/roid_rat/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, sharp, edge, var/used_weapon = null, ignore_events = 0)
	if (bulkblock(damage))
		return 0
	return ..()

/mob/living/simple_animal/hostile/retaliate/gym_rat/roid_rat/AttackingTarget() // FLY SON
	..()
	if(istype(target, /mob/living))
		var/mob/living/M = target
		if(punch_throw_range && prob(punch_throw_chance))
			visible_message("<span class='danger'>\The [M] is flung away by the [src]'s attack!</span>")
			M.Knockdown(4)
			var/turf/T = get_turf(src)
			var/turf/target_turf
			if(istype(T, /turf/space)) // if ended in space, then range is unlimited
				target_turf = get_edge_target_turf(T, dir)
			else
				target_turf = get_ranged_target_turf(T, dir, punch_throw_range)
			M.throw_at(target_turf,100,punch_throw_speed)

/mob/living/simple_animal/hostile/retaliate/gym_rat/roid_rat/chowdown(var/obj/item/weapon/reagent_containers/food/snacks/F)
	if(F.food_flags & FOOD_MEAT) // Meat will heal us, and also pack on some max hp!
		visible_message("\The [name] gobbles up \the [F].", "<span class='notice'>You gobble up the [F].</span>")
		playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
		if(maxHealth < health_cap) // Are we below our max gainz level? Add on some max hp!
			adjust_hp(5)
			scalerate += (1/20)
			if(scalerate > 2) //to tame the float point inaccuracies
				scalerate = 2
			var/matrix/M = matrix()
			M.Scale(scalerate,scalerate)
			M.Translate(0, translaterate*scalerate)
			transform = M
		else
			health+=5 // Otherwise we just get a little health back
			to_chat(src, text("<span class='warning'>The meat nourishes you, but your muscles don't grow. You've bulked all you can...</span>"))
		flick(icon_eat, src)
		qdel(F)
	if(istype(F,/obj/item/weapon/reagent_containers/food/snacks/cheesewedge_scraps)) //Half-eaten cheese wedge. Better than nothing
		health+=10
		visible_message("\The [name] gobbles up \the [F].", "<span class='notice'>You gobble up the [F].</span>")
		playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
		flick(icon_eat, src)
		qdel(F)
	if(istype(F,/obj/item/weapon/reagent_containers/food/snacks/cheesewedge)) //Mmm, cheese wedge. Gives back a small amount of health upon consumption
		health+=15
		visible_message("\The [name] gobbles up \the [F].", "<span class='notice'>You gobble up the [F].</span>")
		playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
		flick(icon_eat, src)
		qdel(F)
	if(istype(F,/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel)) //A cheese wheel feast! Gives back a lot more health than just a slice
		health+=75
		visible_message("\The [name] gobbles up \the [F].", "<span class='notice'>You gobble up the [F].</span>")
		playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
		flick(icon_eat, src)
		qdel(F)

/mob/living/simple_animal/hostile/retaliate/gym_rat/roid_rat/adjust_hp(var/amount) // Maximized gainz will grant roid rats incredible punching power, and the ability to smash through normal walls! Oh YEAAAAAAAAAAAAAAH
	if(amount > 0 && maxHealth < health_cap) //below health_cap, increase maxHealth but no further than health_cap
		maxHealth += amount
		to_chat(src, text("<span class='warning'>You feel your muscles growing!</span>"))
	health += amount
	if(maxHealth < 200)
		melee_damage_lower = 10
		melee_damage_upper = 20
		environment_smash_flags &= ~SMASH_WALLS
	else
		melee_damage_lower = 20
		melee_damage_upper = 30
		environment_smash_flags |= SMASH_WALLS

/mob/living/simple_animal/hostile/retaliate/gym_rat/roid_rat/Life() // Copied from hammy wheel running code
	if(timestopped)
		return 0
	. = ..()
	if(.)
		if(enemies.len && prob(1)) // Roid rats take much longer to calm down compared to gym rats. Roid rage!
			Calm()
	if(!my_wheel && isturf(loc) && !client) // Roid rats with players in them won't be force moved
		for(var/obj/O in view(2, src))
			if(is_type_in_list(O, gym_equipments))
				my_wheel = locate(O) in view(2, src)
				wander = FALSE
				gymratwheel(20)
				break
			else
				wander = TRUE
				speed = 2

/mob/living/simple_animal/hostile/retaliate/gym_rat/roid_rat/New() // speaks mouse, and gets their punch spell added
	..()
	add_spell(new /spell/targeted/punch/roidrat, "genetic_spell_ready", /obj/abstract/screen/movable/spell_master/genetic)

/mob/living/simple_animal/hostile/retaliate/gym_rat/roid_rat/death(var/gibbed = FALSE)
	visible_message("The <b>[src]</b> is torn apart by its own oversized muscles!")
	gibs(get_turf(src))
	..()
	qdel(src)
