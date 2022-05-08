/obj/item/projectile/energy/scorchbolt // Has a tendency to runtime and I can't figure out why, aaaaaaaaaaaaaaaa
	name = "scorch bolt"
	icon_state = "scorchbolt"
	damage = 15
	fire_sound = 'sound/weapons/alien_laser1.ogg'

///////////////////////////////////////////////////////////////////SAUCER DRONE///////////
// A tiny robotic ranged enemy that fills the same niche for the MDF that the viscerator does for the Syndicate. Very weak and fragile, but can overwhelm even an equipped enemy with sheer volume of tiny bolts
/mob/living/simple_animal/hostile/mothership_saucerdrone
	name = "Saucer Drone"
	desc = "A tiny ufo-shaped scout drone. Where's a tiny interceptor when you need one?"
	icon = 'icons/mob/animal.dmi'
	icon_state = "minidrone"
	icon_living = "minidrone"
	pass_flags = PASSTABLE
	maxHealth = 30 // Quite fragile
	health = 30
	melee_damage_type = BURN
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "fires point-blank at"
	attack_sound = 'sound/weapons/alien_laser1.ogg'
	faction = "mothership"
	can_butcher = 0
	flying = 1
	acidimmune = 1

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	maxbodytemp = 500

	size = SIZE_SMALL
	meat_type = null
	held_items = list()
	mob_property_flags = MOB_ROBOTIC
	status_flags = UNPACIFIABLE // Not pacifiable due to being a robit

	blooded = FALSE

	see_in_dark = 8 // Drone sensors or some such

	ranged = 1
	projectiletype = /obj/item/projectile/energy/scorchbolt // Shoots a projectile that does 15 damage, not very threatening unless there's multiple
	projectilesound = 'sound/weapons/alien_laser1.ogg'
	retreat_distance = 2
	minimum_distance = 2

	environment_smash_flags = SMASH_LIGHT_STRUCTURES // Can't smash much besides tables, so you can hide in a locker to escape

/mob/living/simple_animal/hostile/mothership_saucerdrone/death(var/gibbed = FALSE)
	..(TRUE)
	playsound(src, "sound/effects/explosion_small1.ogg", 50, 1)
	visible_message("<span class='warning'>The [src] loses altitude and crash lands!</span>")
	qdel(src)

/mob/living/simple_animal/hostile/mothership_saucerdrone/emp_act(severity) // Vulnerable to EMP damage, not that you NEED to use EMPs
	if(flags & INVULNERABLE)
		return

	switch (severity)
		if (1)
			adjustBruteLoss(30)

		if (2)
			adjustBruteLoss(10)

///////////////////////////////////////////////////////////////////HOVERDISC DRONE///////////
// An armored robotic enemy meant to support grey soldiers in combat. It will usually stay back, using its detection range to its advantage while firing high-damage laser blasts from afar
/mob/living/simple_animal/hostile/mothership_hoverdisc
	name = "Hoverdisc Drone"
	desc = "A heavily armored mothership combat drone. It's equipped with an anti-gravity propulsion system and an integrated heavy disintegrator."
	icon = 'icons/mob/animal.dmi'
	icon_state = "hoverdisc_drone"
	icon_living = "hoverdisc_drone"
	pass_flags = PASSTABLE
	maxHealth = 200 // Pretty decent HP, but the armor is the real problem
	health = 200
	melee_damage_type = BURN
	melee_damage_lower = 55 // Fighting it in melee is ballsy, to say the least
	melee_damage_upper = 55
	attacktext = "fires point-blank at"
	attack_sound = 'sound/weapons/ray1.ogg'
	faction = "mothership"
	can_butcher = 0
	flying = 1
	acidimmune = 1

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	maxbodytemp = 1000

	size = SIZE_BIG
	meat_type = null
	held_items = list()
	mob_property_flags = MOB_ROBOTIC
	status_flags = UNPACIFIABLE // Not pacifiable due to being a robit

	blooded = FALSE

	vision_range = 12 // It can detect enemies from a further distance away than most simplemobs
	aggro_vision_range = 12
	idle_vision_range = 12
	see_in_dark = 12 // Drone sensors or some such

	turns_per_move = 5 // Not particularly fast
	move_to_delay = 5
	speed = 3

	ranged = 1
	projectiletype = /obj/item/projectile/beam/immolationray/upgraded // A unique beam that deals more damage than a regular immolation ray
	projectilesound = 'sound/weapons/ray1.ogg'
	retreat_distance = 8 // It will attempt to linger at a distance just outside of a player's typical field of view, firing shots while deflecting return fire off its armor
	minimum_distance = 8
	ranged_cooldown = 4 // Some cooldown to balance the serious punch it packs
	ranged_cooldown_cap = 4

	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG | OPEN_DOOR_SMART // Can open doors. Coincidentally this also seems to allow the mob to shoot through them (if they're glass airlocks)? It's weird
	stat_attack = UNCONSCIOUS // DISINTEGRATION PROTOCOLS ACTIVE

/mob/living/simple_animal/hostile/mothership_hoverdisc/death(var/gibbed = FALSE)
	..(TRUE)
	visible_message("<span class='warning'>The [src] shudders and violently explodes!</span>")
	new /obj/effect/gibspawner/robot(src.loc)
	explosion(get_turf(src), -1, 2, 4, whodunnit = src)
	qdel(src)

/mob/living/simple_animal/hostile/mothership_hoverdisc/emp_act(severity) // Extremely vulnerable to EMP damage, three direct hits with an ion rifle will destroy it, or three to four emp grenades in close proximity
	if(flags & INVULNERABLE)
		return

	switch (severity)
		if (1)
			adjustBruteLoss(70)

		if (2)
			adjustBruteLoss(50)

/mob/living/simple_animal/hostile/mothership_hoverdisc/attackby(var/obj/item/W as obj, var/mob/user as mob) // Melee weapon force has to be quite high to be effective
	if(W.force >= 20)
		var/damage = W.force
		if (W.damtype == HALLOSS)
			damage = 0
		health -= damage
		visible_message("<span class='danger'>[user] damages the [src] with \the [W]! </span>")
		playsound(src, 'sound/effects/sparks1.ogg', 25)
	else
		visible_message("<span class='danger'>\The [W] glances harmlessly off of the [src]'s armor plating! </span>")
		playsound(src, 'sound/items/metal_impact.ogg', 25)

/mob/living/simple_animal/hostile/mothership_hoverdisc/bullet_act(var/obj/item/projectile/P) // Tough nut. Energy weapons are almost completely ineffective, and ballistics do reduced damage. Ions are your best friend here
	if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam) || istype(P, /obj/item/projectile/forcebolt) || istype(P, /obj/item/projectile/change))
		if(prob(35))
			src.health -= P.damage
		else
			visible_message("<span class='danger'>The [P.name] dissipates harmlessly on the [src]'s armor plating!</span>") // Lasers that fail to get through "dissipate" and do no damage
		return PROJECTILE_COLLISION_DEFAULT
	if(istype(P, /obj/item/projectile/bullet))
		if(prob(35))
			src.health -= P.damage
		else
			visible_message("<span class='danger'>The [P.name] glances off the [src]'s armor plating, failing to penetrate!</span>") // Bullets that fail to get through "deflect" and do reduced damage
			src.health -= P.damage/5
		return PROJECTILE_COLLISION_DEFAULT
	return (..(P))

///////////////////////////////////////////////////////////////////POLYP///////////
// A jellyfish-like creature from an alien world, adapted for space travel. It can give a nasty burning sting, but synthesizes an edible gelatin substance
/mob/living/simple_animal/hostile/retaliate/polyp
	name = "space polyp"
	desc = "A bell-topped creature that resembles a large schyphozoan and produces edible gelatin."
	icon = 'icons/mob/animal.dmi'
	icon_state = "giantjelly"
	icon_living = "giantjelly"
	icon_dead = "giantjelly_dead"
	speak = list("blblbb","wrmrmm","glglglg")
	speak_emote = list("burbles", "hums")
	emote_hear = list("gurgles")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	stop_automated_movement_when_pulled = TRUE
	pass_flags = PASSTABLE // Can fly over tables

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	maxHealth = 75 // A pretty sturdy farm animal, and also vacuum resistant
	health = 75
	size = SIZE_BIG

	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/polyp

	melee_damage_lower = 10
	melee_damage_upper = 10
	melee_damage_type = BURN

	attacktext = "stings"
	attack_sound = 'sound/effects/sparks1.ogg'
	environment_smash_flags = SMASH_LIGHT_STRUCTURES

	faction = "polyp"
	flying = 1
	acidimmune = 1

	var/gives_milk = TRUE
	var/datum/reagents/udder = null

/mob/living/simple_animal/hostile/retaliate/polyp/New()
	if(gives_milk)
		udder = new(50)
		udder.my_atom = src
	..()

/mob/living/simple_animal/hostile/retaliate/polyp/Life()
	if(timestopped)
		return 0 //under effects of time magick
	. = ..()
	if(.)
		if(enemies.len && prob(5))
			Calm()

		if(stat == CONSCIOUS)
			if(udder && prob(5))
				udder.add_reagent(POLYPGELATIN, rand(5, 10))

/mob/living/simple_animal/hostile/retaliate/polyp/proc/Calm()
	enemies.Cut()
	LoseTarget()
	src.visible_message("<span class='notice'>[src] burbles and calms down.</span>")

/mob/living/simple_animal/hostile/retaliate/polyp/Retaliate()
	if(!stat)
		..()
		src.visible_message("<span class='warning'>[src] hums irregularly and raises its stingers.</span>")

/mob/living/simple_animal/hostile/retaliate/polyp/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(stat == CONSCIOUS)
		if(istype(O, /obj/item/weapon/reagent_containers/glass))
			user.visible_message("<span class='notice'>[user] collects gelatin from [src]'s tendrils using \the [O].</span>")
			var/obj/item/weapon/reagent_containers/glass/G = O
			var/transfered = udder.trans_id_to(G, POLYPGELATIN, rand(5,10))
			if(G.reagents.total_volume >= G.volume)
				to_chat(user, "<span class='warning'>[O] is full.</span>")
			if(!transfered)
				to_chat(user, "<span class='warning'>[src]'s tendrils are dry. Wait a bit longer...</span>")
		else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/meat))
			Calm()
			health+=15
			playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
			visible_message("<span class='notice'>[user] feeds \the [O] to [src]. It burbles contentedly.</span>")
			var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
			heart.plane = ABOVE_HUMAN_PLANE
			flick_overlay(heart, list(user.client), 20)
			qdel(O)
		else
			..()
	else
		..()

// Mothership faction version, so it doesn't get attacked by the vault dwellers
/mob/living/simple_animal/hostile/retaliate/polyp/mothership
	faction = "mothership"

// Unique polyp that has been trained to trade coins when fed NotRaisins, there's no way to know this in-game as of yet. Jellyfish traders when?
/mob/living/simple_animal/hostile/retaliate/polyp/phyl
	name = "Phyl"
	desc = "This polyp has several coins stuck to its inner tendrils. How odd."

	meat_type = /obj/item/weapon/coin/iron // Instead of meat you get coins, 4 total
	mob_property_flags = MOB_NO_LAZ // So he can't be killed and revived repeatedly to keep butchering coins

	var/last_trade = 0
	var/const/trade_cooldown = 120 SECONDS // Hopefully this is reasonable, considering he is an unlimited source of coins if the player has Zam NotRaisins

/mob/living/simple_animal/hostile/retaliate/polyp/phyl/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(stat == CONSCIOUS)
		if(istype(O, /obj/item/weapon/reagent_containers/glass))
			user.visible_message("<span class='notice'>[user] collects gelatin from [src]'s tendrils using \the [O].</span>")
			var/obj/item/weapon/reagent_containers/glass/G = O
			var/transfered = udder.trans_id_to(G, POLYPGELATIN, rand(5,10))
			if(G.reagents.total_volume >= G.volume)
				to_chat(user, "<span class='warning'>[O] is full.</span>")
			if(!transfered)
				to_chat(user, "<span class='warning'>[src]'s tendrils are dry. Wait a bit longer...</span>")
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/zam_notraisins))
			if((last_trade + trade_cooldown < world.time))
				Calm()
				playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
				visible_message("<span class='notice'>[user] feeds \the [O] to [src]. It burbles contentedly, and drops something in [user]'s hand.</span>")
				var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
				heart.plane = ABOVE_HUMAN_PLANE
				flick_overlay(heart, list(user.client), 20)
				qdel(O)
				user.put_in_hands(new /obj/item/weapon/coin/iron)
				last_trade = world.time
			else
				visible_message("<span class='notice'>[src] doesn't seem interested in \the [O] at the moment.</span>")
		else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/meat))
			Calm()
			health+=15
			playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
			visible_message("<span class='notice'>[user] feeds \the [O] to [src]. It burbles contentedly.</span>")
			var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
			heart.plane = ABOVE_HUMAN_PLANE
			flick_overlay(heart, list(user.client), 20)
			qdel(O)
		else
			..()
	else
		..()

///////////////////////////////////////////////////////////////////GYM RAT///////////
// Can run on a treadmill much like the trader's colossal hamster, but not quite as efficiently. Maybe in the future I can code a unique reaction to creatine or something
#define GYMRAT_MOVEDELAY 1
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

	size = SIZE_SMALL // If they're not at least small it doesn't seem like the treadmill works or makes sound
	can_ventcrawl = TRUE
	pass_flags = PASSTABLE
	stop_automated_movement_when_pulled = TRUE

	density = 0
	min_oxy = 8 //Require atleast 8kPA oxygen
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius

	melee_damage_lower = 1
	melee_damage_upper = 3
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	var/health_cap = 45 // Feeding it protein can pack on a whopping 50% increase in max health. GAINZ
	var/icon_eat = "gymrat-eat"
	var/obj/my_wheel

/mob/living/simple_animal/hostile/retaliate/gym_rat/Life() // Copied from hammy wheel running code
	if(timestopped)
		return 0
	. = ..()
	if(.)
		if(enemies.len && prob(10))
			Calm()
	if(!my_wheel && isturf(loc))
		var/obj/machinery/power/treadmill/T = locate(/obj/machinery/power/treadmill) in loc
		if(T)
			wander = FALSE
			my_wheel = T
		else
			wander = TRUE
	if(my_wheel)
		gymratwheel(20)

/mob/living/simple_animal/hostile/retaliate/gym_rat/proc/gymratwheel(var/repeat)
	if(repeat < 1 || stat)
		return
	if(!my_wheel || my_wheel.loc != loc) //no longer share a tile with our wheel
		wander = TRUE
		my_wheel = null
		return
	step(src,my_wheel.dir)
	delayNextMove(GYMRAT_MOVEDELAY)
	sleep(GYMRAT_MOVEDELAY)
	gymratwheel(repeat-1)

/mob/living/simple_animal/hostile/retaliate/gym_rat/proc/Calm()
	enemies.Cut()
	LoseTarget()
	src.visible_message("<span class='notice'>[src] squeaks softly and calms down.</span>")

/mob/living/simple_animal/hostile/retaliate/gym_rat/Retaliate()
	if(!stat)
		..()
		src.say(pick("You want to go? Let's go!","You can't beat me, nerd!","I'll break you in half!"))

/mob/living/simple_animal/hostile/retaliate/gym_rat/attackby(var/obj/item/O as obj, var/mob/user as mob) // Feed the gym rat some food
	if(stat == CONSCIOUS)
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/cheesewedge)) // Cheese heals it a bit
			Calm()
			health+=5
			playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
			visible_message("<span class='notice'>[user] feeds \the [O] to [src]. It squeaks loudly.</span>")
			var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
			heart.plane = ABOVE_HUMAN_PLANE
			flick_overlay(heart, list(user.client), 20)
			flick(icon_eat, src)
			qdel(O)
		else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/meat)) // Meat heals less, but packs on a bit of extra maximum hp
			Calm()
			health+=1
			maxHealth+=1
			playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
			visible_message("<span class='notice'>[user] feeds \the [O] to [src]. It squeaks loudly.</span>")
			var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
			heart.plane = ABOVE_HUMAN_PLANE
			flick_overlay(heart, list(user.client), 20)
			flick(icon_eat, src)
			qdel(O)
		else
			..()
	else
		..()

/mob/living/simple_animal/hostile/retaliate/gym_rat/New() // speaks mouse
	..()
	languages += all_languages[LANGUAGE_MOUSE]

/mob/living/simple_animal/hostile/retaliate/gym_rat/mothership // Mothership faction version, so it doesn't get attacked by the vault dwellers
	faction = "mothership"

#undef GYMRAT_MOVEDELAY

///////////////////////////////////////////////////////////////////CATTLE SPECIMEN///////////
// A talking cow!
/mob/living/simple_animal/hostile/retaliate/cattle_specimen
	name = "cattle specimen"
	desc = "There's something strange about this cow."
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	speak = list("It could always be worse.","At least those funny grey fellows didn't turn me into burgers.","Grass is good eating, but I wouldn't mind some oats.","Are they looking? Ahem... MOOOOOO!")
	speak_emote = list("moos","moos hauntingly")
	emote_hear = list("brays")
	emote_see = list("shakes its head")
	emote_sound = list("sound/voice/cow.ogg")
	speak_chance = 2
	turns_per_move = 5
	see_in_dark = 6
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 50

	size = SIZE_BIG
	stop_automated_movement_when_pulled = TRUE
	holder_type = /obj/item/weapon/holder/animal/cow

	melee_damage_lower = 1
	melee_damage_upper = 5

	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'

	faction = "mothership"

	var/gives_milk = TRUE
	var/datum/reagents/udder = null

/mob/living/simple_animal/hostile/retaliate/cattle_specimen/New()
	if(gives_milk)
		udder = new(50)
		udder.my_atom = src
	..()

/mob/living/simple_animal/hostile/retaliate/cattle_specimen/Life()
	if(timestopped)
		return 0 //under effects of time magick
	. = ..()
	if(.)
		if(enemies.len && prob(10))
			Calm()

		if(stat == CONSCIOUS)
			if(udder && prob(5))
				udder.add_reagent(MILK, rand(5, 10))

/mob/living/simple_animal/hostile/retaliate/cattle_specimen/proc/Calm()
	enemies.Cut()
	LoseTarget()
	src.visible_message("<span class='notice'>[src] moos softly and calms down.</span>")

/mob/living/simple_animal/hostile/retaliate/cattle_specimen/Retaliate()
	if(!stat)
		..()
		src.say(pick("That's it!","I can only take so much abuse!","MOOOOOOO!"))

/mob/living/simple_animal/hostile/retaliate/cattle_specimen/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(stat == CONSCIOUS && istype(O, /obj/item/weapon/reagent_containers/glass))
		user.visible_message("<span class='notice'>[user] milks [src] using \the [O].</span>")
		var/obj/item/weapon/reagent_containers/glass/G = O
		var/transfered = udder.trans_id_to(G, MILK, rand(5,10))
		if(G.reagents.total_volume >= G.volume)
			to_chat(user, "<span class='warning'>[O] is full.</span>")
		if(!transfered)
			to_chat(user, "<span class='warning'>The udder is dry. Wait a bit longer...</span>")
	else
		..()

/mob/living/simple_animal/hostile/retaliate/cattle_specimen/attack_hand(mob/living/carbon/M as mob)
	if(!stat && M.a_intent == I_DISARM && icon_state != icon_dead)
		M.visible_message("<span class='warning'>[M] tips over [src].</span>","<span class='notice'>You tip over [src].</span>")
		Knockdown(30)
		Calm() // What you've done is so impolite the cow forgets that it's mad at you
		icon_state = icon_dead
		spawn(rand(20,50))
			if(!stat && M)
				icon_state = icon_living
				src.say(pick("Please stop that.","That was cruel.","Oh, come on.","Why are you doing this to me?","Don't you have any moral scruples? That was very unpleasant.","If the shoe was on the other foot, I wouldn't do that to you."))
	else
		..()
