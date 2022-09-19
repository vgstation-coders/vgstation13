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
	emote_see = list("wiggles its bell", "probes around with its tendrils", "expands and contracts rhythmically")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	response_help  = "pokes"
	response_disarm = "gently pushes aside"
	response_harm   = "punches"
	stop_automated_movement_when_pulled = TRUE
	pass_flags = PASSTABLE // Can fly over tables
	speak_override = TRUE

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

	var/trades_coins = 0 // Check that allows Phyl to give coins for Zam Raisins, but not a regular polyp
	var/last_trade = 0
	var/const/trade_cooldown = 120 SECONDS // Specifically here for the subtype that trades coins for Zam Raisins
	var/gives_milk = TRUE
	var/datum/reagents/udder = null

/mob/living/simple_animal/hostile/retaliate/polyp/splashable()
	return FALSE

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
		if(trades_coins == 1 && istype(O, /obj/item/weapon/reagent_containers/food/snacks/zam_notraisins))
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

// Mothership faction version, so it doesn't get attacked by the vault dwellers
/mob/living/simple_animal/hostile/retaliate/polyp/mothership
	faction = "mothership"

// Unique polyp that has been trained to trade coins when fed NotRaisins, there's no way to know this in-game as of yet. Jellyfish traders when?
/mob/living/simple_animal/hostile/retaliate/polyp/phyl
	name = "Phyl"
	desc = "This polyp has several coins stuck to its inner tendrils. How odd."

	meat_type = /obj/item/weapon/coin/iron // Instead of meat you get coins, 4 total
	mob_property_flags = MOB_NO_LAZ // So he can't be killed and revived repeatedly to keep butchering coins

	trades_coins = 1 // This one will trade coins occasionally if fed Zam NotRaisins

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

	size = SIZE_SMALL // If they're not at least small it doesn't seem like the treadmill works or makes sound
	pass_flags = PASSTABLE
	stop_automated_movement_when_pulled = TRUE

	min_oxy = 8 //Require atleast 8kPA oxygen
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius

	attacktext = "headbutts"
	attack_sound = 'sound/weapons/punch1.ogg'

	var/health_cap = 75 // Eating protein can pack on a whopping 150% increase in max health. GAINZ
	var/icon_eat = "gymrat-eat"
	var/obj/my_wheel
	var/list/gym_equipments = list(/obj/structure/stacklifter, /obj/structure/punching_bag, /obj/structure/weightlifter, /obj/machinery/power/treadmill)

	var/static/list/edibles = list(/obj/item/weapon/reagent_containers/food/snacks/cheesewedge, /obj/item/weapon/reagent_containers/food/snacks/meat, /obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel) // Gym rats are pickier than normal mice. Cheese and raw meat only

/mob/living/simple_animal/hostile/retaliate/gym_rat/UnarmedAttack(var/atom/A)
	if(is_type_in_list(A, edibles)) // If we click on something edible, it's time to chow down!
		delayNextAttack(10)
		chowdown(A)
	if(is_type_in_list(A, gym_equipments)) // If we click on gym equipment, it's time to work out!
		A.attack_hand(src, 0, A.Adjacent(src))
	else return ..()

/mob/living/simple_animal/hostile/retaliate/gym_rat/proc/chowdown(var/atom/eat_this)
	if(istype(eat_this,/obj/item/weapon/reagent_containers/food/snacks/cheesewedge)) //Mmm, cheese wedge. Gives back a small amount of health upon consumption
		health+=5
		visible_message("\The [name] gobbles up \the [eat_this].", "<span class='notice'>You gobble up the [eat_this].</span>")
		playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
		flick(icon_eat, src)
		qdel(eat_this)
	if(istype(eat_this,/obj/item/weapon/reagent_containers/food/snacks/meat)) //Protein! Gives back a smaller amount of health, but also packs on some extra max hp
		health+=1
		maxHealth+=1
		visible_message("\The [name] gobbles up \the [eat_this].", "<span class='notice'>You gobble up the [eat_this].</span>")
		playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
		flick(icon_eat, src)
		qdel(eat_this)
	if(istype(eat_this,/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel)) //A cheese wheel feast! Gives back a lot more health than just a slice
		health+=25
		visible_message("\The [name] gobbles up \the [eat_this].", "<span class='notice'>You gobble up the [eat_this].</span>")
		playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
		flick(icon_eat, src)
		qdel(eat_this)

/mob/living/simple_animal/hostile/retaliate/gym_rat/Life() // Copied from hammy wheel running code
	if(timestopped)
		return 0
	. = ..()
	if(.)
		if(enemies.len && prob(5))
			Calm()
	if(maxHealth < 60)
		melee_damage_lower = 1
		melee_damage_upper = 5
	if(maxHealth >= 60) // Gainz makes for stronger melee attack damage!
		melee_damage_lower = 5
		melee_damage_upper = 10
	if(!my_wheel && isturf(loc) && !client) // Gym rats with players in them won't be force moved
		for(var/obj/O in view(2, src))
			if(is_type_in_list(O, gym_equipments))
				my_wheel = locate(O) in view(2, src)
				wander = FALSE
				gymratwheel(20)
				break
			else
				wander = TRUE
				speed = 1

/mob/living/simple_animal/hostile/retaliate/gym_rat/proc/gymratwheel(var/repeat)
	if(repeat < 1 || stat)
		wander = TRUE
		my_wheel = null
		speed = 10
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
			speed = 1
			step(src,my_wheel.dir)
		step_towards(src,my_wheel)
	else
		wander = TRUE
		speed = 1

	delayNextMove(speed)
	sleep(speed)
	gymratwheel(repeat-1)

/mob/living/simple_animal/hostile/retaliate/gym_rat/proc/Calm()
	enemies.Cut()
	LoseTarget()
	src.say(pick("Yeah, you better run.","Not worth my time, anyways."))
	src.visible_message("<span class='notice'>[src] squeaks softly and calms down.</span>")

/mob/living/simple_animal/hostile/retaliate/gym_rat/Retaliate()
	if(!stat)
		..()
		src.say(pick("You want to go? Let's go!","You can't beat me, nerd!","I'll break you in half!"))

/mob/living/simple_animal/hostile/retaliate/gym_rat/attackby(var/obj/item/O as obj, var/mob/user as mob) // Feed the gym rat some food
	if(stat == CONSCIOUS)
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/cheesewedge)) // Cheesewedges heal it a bit
			Calm()
			health+=5
			playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
			visible_message("<span class='notice'>[user] feeds \the [O] to [src]. It squeaks loudly.</span>")
			var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
			heart.plane = ABOVE_HUMAN_PLANE
			flick_overlay(heart, list(user.client), 20)
			flick(icon_eat, src)
			qdel(O)
		else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel))
			Calm()
			health+=25
			playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
			visible_message("<span class='notice'>[user] feeds \the [O] to [src]. It squeaks loudly.</span>")
			var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
			heart.plane = ABOVE_HUMAN_PLANE
			flick_overlay(heart, list(user.client), 20)
			flick(icon_eat, src)
			qdel(O)
		else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/meat)) // Meat heals less, but packs on some extra maximum hp
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

/mob/living/simple_animal/hostile/retaliate/gym_rat/reagent_act(id, method, volume) // Gym rats have to keep away from soymilk... it's bad for their gainz
	if(isDead())
		return

	.=..()

	switch(id)
		if(SOYMILK)
			if(maxHealth >= 20)
				visible_message("<span class='warning'>[src] seems to shrink as the soymilk washes over them! Its muscles look less visible...</span>")
				maxHealth-=5
				adjustBruteLoss(1) // Here so that the mouse aggros. It won't be happy that you're cutting into its gainz!
			if(maxHealth < 20)
				visible_message("<span class='warning'>[src] shrinks back into a more appropriate size for a mouse.</span>")
				transmogrify()

/mob/living/simple_animal/hostile/retaliate/gym_rat/New() // speaks mouse
	..()
	languages += all_languages[LANGUAGE_MOUSE]

/mob/living/simple_animal/hostile/retaliate/gym_rat/mothership // Mothership faction version, so it doesn't get attacked by the vault dwellers
	faction = "mothership"

/mob/living/simple_animal/hostile/retaliate/gym_rat/pompadour // Gym rat with a fancy hairstyle
	name = "pomdadour rat"
	desc = "Dang! That's a pretty hunky mouse, let me tell ya."
	icon_state = "gymrat_pompadour"
	icon_living = "gymrat_pompadour"
	icon_dead = "gymrat_pompadour-dead"

	icon_eat = "gymrat_pompadour-eat"

///////////////////////////////////////////////////////////////////ROID RAT///////////
// That mouse is shredded! Has the science of bodybuilding gone too far? Possibly too swole to control!
/mob/living/simple_animal/hostile/retaliate/roid_rat
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
	speak_chance = 2
	turns_per_move = 5
	see_in_dark = 6
	speak = list("I'M A LEAN, MEAN, WEIGHT PUMPIN'MACHINE.","I BEEN TO THE TOP OF THE MOUNTAIN!","NOTHING MEANS NOTHING!","MAX YOUR PUMP.","OH YEAAAAAH.","CHECK OUT MY PECS, LITTLE MAN.")
	speak_emote = list("squeaks thunderously")
	emote_hear = list("squeaks thunderously")
	emote_see = list("flexes", "sweats", "does a rep")

	pass_flags = PASSTABLE
	stop_automated_movement_when_pulled = TRUE

	min_oxy = 8 //Require atleast 8kPA oxygen
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius

	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'

	var/health_cap = 225 // Eating protein can pack on a 50% increase in max health. Less percentage-wise than gym rats who are working out the "natural" way, but the raw numbers are still pretty scary
	var/icon_eat = "roidrat-eat"
	var/obj/my_wheel
	var/list/gym_equipments = list(/obj/structure/stacklifter, /obj/structure/punching_bag, /obj/structure/weightlifter, /obj/machinery/power/treadmill)

	var/static/list/edibles = list(/obj/item/weapon/reagent_containers/food/snacks/cheesewedge, /obj/item/weapon/reagent_containers/food/snacks/meat, /obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel) // Roid rats are pickier than normal mice. Cheese and raw meat only

	var/punch_throw_chance = 20 // Chance of sending a target flying a short distance with a punch
	var/punch_throw_speed = 3
	var/punch_throw_range = 6

	var/damageblock = 10

	var/all_fours = 1

	status_flags = UNPACIFIABLE // Can't pacify muscles like these with hippy shit

/mob/living/simple_animal/hostile/retaliate/roid_rat/update_icon()
	if(all_fours == 1)
		icon_state = "roidrat"
		icon_eat = "roidrat-eat"
	else
		icon_state = "roidrat_dudestop"
		icon_eat = null

/mob/living/simple_animal/hostile/retaliate/roid_rat/proc/bulkblock(var/damage, var/atom/A)// roid rats are unaffected by brute damage of 10 or lower
	if (!damage || damage <= damageblock)
		if (A)
			visible_message("<span class='danger'>\The [A] bounces ineffectually off \the [src]'s bulk! </span>")
			playsound(src, 'sound/weapons/genhit1.ogg', 50, 1)
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/retaliate/roid_rat/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(bulkblock(O.force, O))
		user.delayNextAttack(8)
	else
		..()

/mob/living/simple_animal/hostile/retaliate/roid_rat/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, sharp, edge, var/used_weapon = null, ignore_events = 0)
	if (bulkblock(damage))
		return 0
	return ..()

/mob/living/simple_animal/hostile/retaliate/roid_rat/AttackingTarget() // FLY SON
	..()
	if(istype(target, /mob/living))
		var/mob/living/M = target
		if(punch_throw_range && prob(punch_throw_chance))
			visible_message("<span class='danger'>\The [M] is flung away by the [src]'s powerful punch!</span>")
			M.Knockdown(4)
			var/turf/T = get_turf(src)
			var/turf/target_turf
			if(istype(T, /turf/space)) // if ended in space, then range is unlimited
				target_turf = get_edge_target_turf(T, dir)
			else
				target_turf = get_ranged_target_turf(T, dir, punch_throw_range)
			M.throw_at(target_turf,100,punch_throw_speed)

/mob/living/simple_animal/hostile/retaliate/roid_rat/UnarmedAttack(var/atom/A)
	if(is_type_in_list(A, edibles)) // If we click on something edible, it's time to chow down!
		delayNextAttack(10)
		chowdown(A)
	if(is_type_in_list(A, gym_equipments)) // If we click on gym equipment, it's time to work out!
		A.attack_hand(src, 0, A.Adjacent(src))
	else return ..()

/mob/living/simple_animal/hostile/retaliate/roid_rat/proc/chowdown(var/atom/eat_this)
	if(istype(eat_this,/obj/item/weapon/reagent_containers/food/snacks/cheesewedge)) //Mmm, cheese wedge. Gives back a small amount of health upon consumption
		health+=10
		visible_message("\The [name] gobbles up \the [eat_this].", "<span class='notice'>You gobble up the [eat_this].</span>")
		playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
		flick(icon_eat, src)
		qdel(eat_this)
	if(istype(eat_this,/obj/item/weapon/reagent_containers/food/snacks/meat)) //Protein! Gives back a smaller amount of health, but also packs on some extra max hp
		health+=1
		maxHealth+=1
		visible_message("\The [name] gobbles up \the [eat_this].", "<span class='notice'>You gobble up the [eat_this].</span>")
		playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
		flick(icon_eat, src)
		qdel(eat_this)
	if(istype(eat_this,/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel)) //A cheese wheel feast! Gives back a lot more health than just a slice
		health+=50
		visible_message("\The [name] gobbles up \the [eat_this].", "<span class='notice'>You gobble up the [eat_this].</span>")
		playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
		flick(icon_eat, src)
		qdel(eat_this)

/mob/living/simple_animal/hostile/retaliate/roid_rat/Life() // Copied from hammy wheel running code
	if(timestopped)
		return 0
	. = ..()
	if(.)
		if(enemies.len && prob(1)) // Roid rats take much longer to calm down compared to gym rats. Roid rage!
			Calm()
	if(maxHealth < 200)
		melee_damage_lower = 10
		melee_damage_upper = 20
		environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG
	if(maxHealth >= 200)
		melee_damage_lower = 20
		melee_damage_upper = 30
		environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS | OPEN_DOOR_STRONG // Maximized gainz will grant roid rats incredible punching power, and the ability to smash through normal walls! Oh YEAAAAAAAAAAAAAAH
	if(!my_wheel && isturf(loc) && !client) // Roid rats with players in them won't be force moved
		for(var/obj/O in view(2, src))
			if(is_type_in_list(O, gym_equipments))
				my_wheel = locate(O) in view(2, src)
				wander = FALSE
				roidratwheel(20)
				break
			else
				wander = TRUE
				speed = 2

/mob/living/simple_animal/hostile/retaliate/roid_rat/proc/roidratwheel(var/repeat)
	if(repeat < 1 || stat)
		wander = TRUE
		my_wheel = null
		speed = 10
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
			speed = 1
			step(src,my_wheel.dir)
		step_towards(src,my_wheel)
	else
		wander = TRUE
		speed = 2

	delayNextMove(speed)
	sleep(speed)
	roidratwheel(repeat-1)

/mob/living/simple_animal/hostile/retaliate/roid_rat/proc/Calm()
	enemies.Cut()
	LoseTarget()
	src.say(pick("YOU AIN'T NUTHING.","BETTER RUN, TINY MAN."))
	src.visible_message("<span class='notice'>[src] squeaks softly and calms down.</span>")

/mob/living/simple_animal/hostile/retaliate/roid_rat/Retaliate()
	if(!stat)
		..()
		src.say(pick("TIME TO STEP INTO THE SQUARE CIRCLE, SON.","YOU CALLED DOWN THE THUNDER.","GET READY FOR THE BIG GUNS.","YOU EYEBALLING ME?"))

/mob/living/simple_animal/hostile/retaliate/roid_rat/attackby(var/obj/item/O as obj, var/mob/user as mob) // Feed the gym rat some food
	if(stat == CONSCIOUS)
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/cheesewedge)) // Cheesewedges heal it a bit
			Calm()
			health+=10
			playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
			visible_message("<span class='notice'>[user] feeds \the [O] to [src]. It squeaks loudly.</span>")
			var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
			heart.plane = ABOVE_HUMAN_PLANE
			flick_overlay(heart, list(user.client), 20)
			flick(icon_eat, src)
			qdel(O)
		else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel))
			Calm()
			health+=50
			playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
			visible_message("<span class='notice'>[user] feeds \the [O] to [src]. It squeaks loudly.</span>")
			var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
			heart.plane = ABOVE_HUMAN_PLANE
			flick_overlay(heart, list(user.client), 20)
			flick(icon_eat, src)
			qdel(O)
		else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/meat)) // Meat heals less, but packs on some extra maximum hp
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

/mob/living/simple_animal/hostile/retaliate/roid_rat/New() // speaks mouse, and gets their punch spell added
	..()
	add_spell(new /spell/targeted/roidrat_punch, "genetic_spell_ready", /obj/abstract/screen/movable/spell_master/genetic)
	languages += all_languages[LANGUAGE_MOUSE]

/mob/living/simple_animal/hostile/retaliate/roid_rat/verb/stand_up() // Allows the roid rat to toggle poses. They can stand upright, or walk around like a typical mouse
	set name = "Stand Up / Lie Down"
	set desc = "Stand up and show off your guns, or walk on all fours to not embarrass the nerds."
	set category = "Roid_Rat"

	if(all_fours == 1)
		all_fours = 0
		to_chat(src, text("<span class='notice'>You are now standing upright.</span>"))
		update_icon()

	else
		all_fours = 1
		to_chat(src, text("<span class='notice'>You are now moving on all fours.</span>"))
		update_icon()

/mob/living/simple_animal/hostile/retaliate/roid_rat/reagent_act(id, method, volume) // Roid rats have to keep away from soymilk... it's bad for their gainz
	if(isDead())
		return

	.=..()

	switch(id)
		if(SOYMILK)
			if(maxHealth >= 80)
				visible_message("<span class='warning'>[src] seems to shrink as the soymilk washes over them! Its muscles look less visible...</span>")
				maxHealth-=10
				adjustBruteLoss(1) // Here so that the mouse aggros. It won't be happy that you're cutting into its gainz!
			if(maxHealth < 80)
				visible_message("<span class='warning'>[src] shrinks back into a more appropriate size for a mouse.</span>")
				transmogrify()

/mob/living/simple_animal/hostile/retaliate/roid_rat/death(var/gibbed = FALSE)
	visible_message("The <b>[src]</b> is torn apart by its own oversized muscles!")
	gibs(get_turf(src))
	..()
	qdel(src)

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

/mob/living/simple_animal/hostile/retaliate/cattle_specimen/splashable()
	return FALSE

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
