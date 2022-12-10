#define HOG_MAX 450
#define HOG_FED 300
#define HOG_HUNGRY 250
#define HOG_VHUNGRY 150

#define HOG_CURIOUS 0
#define HOG_SKITTISH 1
#define HOG_HIT_AND_RUN 2
#define HOG_ASSAULT 3

/********************************************************
*                                                       *
*       At the top level, this is abstract.			    *
*       Use piglets or grown hog types                  *
*                                                       *
*********************************************************/

/mob/living/simple_animal/hostile/spacehog
	name = "abstract space hog"
	desc = "This one is missing behaviors."
	icon = 'icons/mob/hog.dmi'
	icon_state = "hog_clean"
	icon_living = "hog_clean"
	icon_dead = "hog_clean_dead"
	speak_chance = 1
	turns_per_move = 5
	must_wander = TRUE
	speak = list("Oink!","Squee!","Sqwaa!","Ounch!", "SQUEEEEE!","Oink...","Oink, oink", "Oink, oink, oink", "Oink!", "Oiiink.")
	emote_hear = list("squeals hauntingly")
	emote_see = list("roots about","squeals hauntingly")
	emote_sound = list("sound/voice/pigsnort.ogg","sound/voice/pigsqueal.ogg")
	response_help = "pats"
	response_disarm = "shoves"
	response_harm = "hits"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/box/pig
	speed = 1
	maxHealth = 80
	health = 80
	can_butcher = TRUE
	size = SIZE_BIG

	status_flags = CANSTUN

	harm_intent_damage = 10
	melee_damage_lower = 4
	melee_damage_upper = 8
	attacktext = "gores"
	attack_sound = 'sound/weapons/bite.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	faction = "HOG"

	nutrition = HOG_FED
	var/food_search_radius = 7
	var/food_target = null //A secondary target only used when we are not aggroing for a target we attack
	var/mood = HOG_SKITTISH
	var/panic = 0 //Ticks down, when positive cause aggro

/mob/living/simple_animal/hostile/spacehog/death(var/gibbed = FALSE)
	..(gibbed)
	playsound(src, 'sound/effects/box_scream.ogg', 100, 1)

/mob/living/simple_animal/hostile/spacehog/Process_Spacemove(var/check_drift = 0)
	return 1 //All spacehogs are proficient in space navigation

/mob/living/simple_animal/hostile/spacehog/before_retreat() //Before we take a step away, if the most direct route is blocked and the enemy is near, panic
	var/target_distance = get_dist(src,target)
	if(target_distance <= 2)
		var/turf/T = get_step(src, get_dir(target,src)) //calculate the next space
		if(T.density)
			panic += 2
			return
		for(var/atom/movable/AM in T)
			if(AM.density)
				panic += 2
				return

/mob/living/simple_animal/hostile/spacehog/proc/set_mood(var/mood)
	switch(mood)
		if(HOG_CURIOUS)
			idle_vision_range = 4
			retreat_distance = 4
			minimum_distance = 4
			turns_per_move = 1
		if(HOG_SKITTISH)
			idle_vision_range = 8
			retreat_distance = 8
			minimum_distance = 8
			turns_per_move = 5
		if(HOG_HIT_AND_RUN)
			idle_vision_range = 8
			retreat_distance = 2
			minimum_distance = 1
			turns_per_move = 5
		if(HOG_ASSAULT)
			idle_vision_range = 8
			retreat_distance = null
			minimum_distance = 1
			turns_per_move = 5

/mob/living/simple_animal/hostile/spacehog/Life()
	..()
	nutrition--

	if(stance == HOSTILE_STANCE_IDLE && (!food_target || get_dist(food_target, src) > 7) && !ckey)
		if(mood == HOG_CURIOUS)
			var/odds_of_new_food_search = max(300 - nutrition, 0)
			//every nutrition under HOG_FED increases odds of a new search by 1%
			if(prob(odds_of_new_food_search))
				mood = HOG_SKITTISH
			return
		food_target = idle_search()
		if(!food_target)
			set_mood(HOG_CURIOUS)

/* Priorities:
planted seeds with ligneous = FALSE
fresh meat on ground or fish
cabbage on ground
other loose veggies on ground or eggs, fish eggs, borer eggs
other snacks
passive animals, preferring smaller ones
carrion
if ungreased adult: l containers
*/
//share info across all hogs?

/mob/living/simple_animal/hostile/spacehog/proc/idle_search()
	var/tree_tray = null
	for(var/obj/machinery/portable_atmospherics/hydroponics/H in view(food_search_radius,src))
		if(H.seed)
			if(H.seed.ligneous)
				tree_tray = H
			else
				return H
	for(var/obj/item/weapon/reagent_containers/food/snacks/meat/M in view(food_search_radius,src))
		return M
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage/C in view(food_search_radius,src))
		return C
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in view(food_search_radius,src))
		return G
	var/lesser_snack = null
	for(var/obj/item/weapon/reagent_containers/food/snacks/S in view(food_search_radius,src))
		if(istype(S, /obj/item/weapon/reagent_containers/food/snacks/grown) || istype(S, /obj/item/weapon/reagent_containers/food/snacks/egg) || istype(S, /obj/item/weapon/reagent_containers/food/snacks/borer_egg))
			return S //priority snacks
		lesser_snack = S
	if(lesser_snack)
		return lesser_snack
	for(var/obj/item/fish_eggs/F in view(food_search_radius,src))
		return F
	if(nutrition >= HOG_FED)
		return null //Give up, nothing down here is worth eating unless we're reasonably hungry
	var/carrion = null
	for(var/mob/living/simple_animal/L in view(food_search_radius,src))
		if(L.size > size)
			continue //It's bigger than we are!
		if(!L.meat_type)
			continue //No meat? Not interested
		if(L.stat)
			carrion = L
		else
			GiveTarget(L)
			return L
	if(carrion)
		return carrion
	if(tree_tray)
		return tree_tray
	return wallow_search()

/mob/living/simple_animal/hostile/spacehog/proc/wallow_search()


/mob/living/simple_animal/hostile/spacehog/proc/eat(atom/movable/AM)
	playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
	if(istype(AM, /obj/item/weapon/reagent_containers/food/snacks/grown/cabbage))
		var/mob/living/simple_animal/hostile/retaliate/box/pig/newpig = new(loc)
		newpig.size = size
		newpig.meat_amount = size
		newpig.update_icon()
		qdel(src)
		return
	if(isitem(AM))
		if(AM.reagents)
			AM.reagents.trans_to(src, 100)
		else
			reagents.add_reagent(NUTRIMENT, 4) //covers stuff like fish eggs
		qdel(AM)
	if(ismob(AM))
		var/mob/living/simple_animal/SA = AM
		if(SA.stat) //it's dead so let's eat butching products
			var/obj/item/I = SA.drop_meat(src) //Try to drop some meat straight into our body
			if(I) //Consume the reagents and destroy it
				I.reagents.trans_to(src,100)
				qdel(I)
			else //It failed, let's eat the body itself.
				SA.gib()
				reagents.add_reagent(NUTRIMENT, 4)
		else
			UnarmedAttack(SA)
	if(istype(AM,/obj/machinery/portable_atmospherics/hydroponics))
		AM.shake(1,3)
		var/obj/machinery/portable_atmospherics/hydroponics/H = AM
		H.remove_plant()


/********************************************************
*                                                       *
*       Behaviors specific to Adults only			    *
*       				                                *
*                                                       *
*********************************************************/

/mob/living/simple_animal/hostile/spacehog/adult/Life()
	..()
	panic--
	if(stance == HOSTILE_STANCE_ATTACK) //If currently agitated by nearby humans, gain panic if piglets are nearby
		for(var/mob/living/simple_animal/hostile/spacehog/piglet in view(7,src))
			panic += 2
	if(locked_to)
		panic += 2 //Gain panic when locked, such as in a beartrap or cage
		food_search_radius = 1 //don't bother looking farther if we can't reach it
	else
		food_search_radius = 7
	if(panic) //or failed retreat
		set_mood(HOG_ASSAULT)
	else  //If no panic, set mood based on hunger
		handle_hunger()

/mob/living/simple_animal/hostile/spacehog/adult/proc/handle_hunger()
	switch(nutrition)
		if(HOG_FED to INFINITY)
			set_mood(HOG_SKITTISH)
		if(HOG_HUNGRY to HOG_FED-1)
			set_mood(HOG_HIT_AND_RUN)
		if(0 to HOG_HUNGRY-1)
			set_mood(HOG_ASSAULT)

/mob/living/simple_animal/hostile/spacehog/adult/UnarmedAttack(atom/target, prox)
	if(!target || !prox)
		return

	if(!client && isliving(target)) //automated headbutting if no client
		for(var/spell/headbutt/M in spell_list)
			if(M.charge_counter == M.charge_max)
				M.cast(list(target),src)
				M.charge_counter = 0
				M.process()
				return
	else
		if(istype(target,/obj/item/weapon/reagent_containers/food))
			eat(target)
	..() //if no headbutt available, just normal attack

/spell/headbutt
	name = "Headbutt"
	desc = "Knocks the target down."
	charge_max = 10 SECONDS
	spell_flags = WAIT_FOR_CLICK
	range = 1
	hud_state = "wiz_fist"
	spell_flags = IS_HARMFUL

/spell/headbutt/cast(var/list/targets, var/mob/user)
	..()
	for(var/mob/living/target in targets)
		if (user.is_pacified(1,target))
			return
		playsound(user, "trayhit", 75, 1)
		target.Knockdown(5)
		user.visible_message("<span class='danger'>\The [user] headbutts \the [target]!</span>")


/********************************************************
*                                                       *
*       Subtypes - Adult: Mama, Greased, Overgreased    *
*        Not adult: Piglet                              *
*                                                       *
*********************************************************/

/mob/living/simple_animal/hostile/spacehog/adult
	name = "feral space hog"
	desc = "This one isn't greased up."

/mob/living/simple_animal/hostile/spacehog/adult/New()
	..()
	add_spell(new /spell/headbutt, "wiz_fist")

/mob/living/simple_animal/hostile/spacehog/adult/mama
	name = "mama hog"
	desc = "The ultimate hog. It's huge!"
	icon_state = "sow"
	icon_living = "sow"
	icon_dead = "sow_dead"
	speed = 2.5
	maxHealth = 450
	health = 450
	size = SIZE_HUGE
	nutrition = HOG_MAX

/mob/living/simple_animal/hostile/spacehog/adult/mama/Life()
	..()
	if((nutrition > HOG_HUNGRY) && prob(10))
		nutrition -= 15
		new /mob/living/simple_animal/hostile/spacehog/piglet(loc)

/mob/living/simple_animal/hostile/spacehog/adult/greased
	name = "greased up feral space hog"
	desc = "Oh no, it's greased."
	speed = 0.8 //faster due to grease
	pass_flags = PASSMOB|PASSDOOR //greased hogs can move through doors
	melee_damage_lower = 8
	melee_damage_upper = 12
	icon_state = "hog_greased"
	icon_living = "hog_greased"
	icon_dead = "hog_greased_dead"

/mob/living/simple_animal/hostile/spacehog/adult/greased/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	..()
	for(var/obj/machinery/door/D in loc)
		if(D?.density)
			SetStunned(1)
			visible_message("<span class='danger'>\The [src] squeezes through with its slippery grease!</span>")

/mob/living/simple_animal/hostile/spacehog/adult/greased/drop_meat(location)
	var/obj/item/I = ..()
	I.throw_at(pick(orange(7,src)), 7, 2)

/mob/living/simple_animal/hostile/spacehog/adult/greased/over
	name = "overgreased feral space hog"
	desc = "It leaves a sickly trail of grease, like a particularly slimy slug."
	speed = 0.7
	melee_damage_lower = 12
	melee_damage_upper = 15
	icon_state = "hog_overgreased"
	icon_living = "hog_overgreased"
	icon_dead = "hog_overgreased_dead"

/mob/living/simple_animal/hostile/spacehog/adult/greased/over/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	//Before departing
	var/turf/simulated/T = loc
	if(istype(loc) && !T.is_wet())
		new /obj/effect/overlay/puddle(loc, TURF_WET_LUBE, 5 SECONDS) //leave 5 seconds of lube behind
	..() //move on

/mob/living/simple_animal/hostile/spacehog/piglet
	name = "feral space piglet"
	desc = "This one isn't old enough for grease."
	icon_state = "hoglet"
	icon_living = "hoglet"
	icon_dead = "hoglet_dead"
	maxHealth = 40
	health = 40
	size = SIZE_SMALL
	retreat_distance = 8 //Retreats and does not approach when it sees a hostile
	minimum_distance = 8

/mob/living/simple_animal/hostile/spacehog/piglet/set_mood(var/mood)
	..(HOG_SKITTISH)
