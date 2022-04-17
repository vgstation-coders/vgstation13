///////////////////////////////////////////////////////////////////SAUCER DRONE///////////
// A tiny robotic ranged enemy that fills the same niche for the MDF that the viscerator does for the Syndicate. Very weak and fragile, but can overwhelm even an equipped enemy with sheer volume of tiny laser blasts
/mob/living/simple_animal/hostile/mothership_saucerdrone
	name = "Saucer Drone"
	desc = "A tiny ufo-shaped scout drone. Where's a tiny interceptor when you need one?"
	icon = 'icons/mob/animal.dmi'
	icon_state = "minidrone"
	icon_living = "minidrone"
	pass_flags = PASSTABLE
	see_in_dark = 8 // Drone sensors or some such
	size = SIZE_SMALL

	maxHealth = 20 // Very fragile
	health = 20

	ranged = 1
	projectiletype = /obj/item/projectile/energy/scorchbolt // Shoots a projectile that does 15 damage, not very threatening unless there's multiple
	projectilesound = 'sound/weapons/alien_laser1.ogg'

	melee_damage_type = BURN
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "fires point-blank at"
	attack_sound = 'sound/weapons/alien_laser1.ogg'

	flying = 1
	acidimmune = 1
	mob_property_flags = MOB_ROBOTIC
	blooded = FALSE

	status_flags = UNPACIFIABLE // Not pacifiable due to being a robit
	environment_smash_flags = SMASH_LIGHT_STRUCTURES // Can't smash many things

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

	faction = "mothership"

/mob/living/simple_animal/hostile/mothership_saucerdrone/Process_Spacemove(var/check_drift = 0) // It can follow enemies into space, and won't just drift off
	return 1

/mob/living/simple_animal/hostile/mothership_saucerdrone/emp_act(severity) // Vulnerable to EMP damage, not that you NEED to use EMPs
	if(flags & INVULNERABLE)
		return

	switch (severity)
		if (1)
			adjustBruteLoss(20)

		if (2)
			adjustBruteLoss(10)

/mob/living/simple_animal/hostile/mothership_saucerdrone/bullet_act(var/obj/item/projectile/P) // Has a small chance to "evade" projectiles, but all you have to do is hit it once
	if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam) || istype(P, /obj/item/projectile/forcebolt) || istype(P, /obj/item/projectile/change))
		if(prob(80))
			src.health -= P.damage
			return PROJECTILE_COLLISION_DEFAULT
		else
			visible_message("<span class='danger'>The [src] narrowly evades the [P.name]!</span>")
			return PROJECTILE_COLLISION_MISS

	if(istype(P, /obj/item/projectile/bullet))
		if(prob(80))
			src.health -= P.damage
			return PROJECTILE_COLLISION_DEFAULT
		else
			visible_message("<span class='danger'>The [src] narrowly evades the bullet!</span>")
			return PROJECTILE_COLLISION_MISS
	return (..(P))

/mob/living/simple_animal/hostile/mothership_saucerdrone/death(var/gibbed = FALSE)
	visible_message("<span class='warning'>The [src] loses altitude and crash lands!</span>")
	explosion(get_turf(src), -1, -1, 0, whodunnit = src)
	qdel(src)
	return

///////////////////////////////////////////////////////////////////HOVERDISC DRONE///////////
// A robotic enemy meant to support grey soldiers in combat. It will usually stay back, using its detection range to its advantage while firing high-damage laser blasts from afar
/mob/living/simple_animal/hostile/mothership_hoverdisc
	name = "Hoverdisc Drone"
	desc = "A heavily armored mothership combat drone. It's equipped with an anti-gravity propulsion system and an integrated heavy disintegrator."
	icon = 'icons/mob/animal.dmi'
	icon_state = "hoverdisc_drone"
	icon_living = "hoverdisc_drone"
	pass_flags = PASSTABLE
	turns_per_move = 5 // Not particularly fast
	move_to_delay = 5
	speed = 3
	see_in_dark = 12 // Drone sensors or some such

	maxHealth = 250
	health = 250

	vision_range = 12 // It can detect enemies from a further distance away than most simplemobs
	aggro_vision_range = 12
	idle_vision_range = 12

	ranged = 1
	projectiletype = /obj/item/projectile/beam/immolationray/upgraded // A unique beam that deals more damage than a regular immolation ray
	projectilesound = 'sound/weapons/ray1.ogg'
	retreat_distance = 8 // It will attempt to linger at a distance just outside a player's typical field of view, taking potshots
	minimum_distance = 8
	ranged_cooldown = 3 // Some cooldown to balance the serious punch it packs
	ranged_cooldown_cap = 3

	melee_damage_lower = 5
	melee_damage_upper = 10 // Deals almost no melee damage. It's primarily a ranged support unit

	attacktext = "clumsily bumps"
	attack_sound = 'sound/weapons/smash.ogg'

	flying = 1
	acidimmune = 1
	mob_property_flags = MOB_ROBOTIC
	blooded = FALSE

	status_flags = UNPACIFIABLE // Not pacifiable due to being a robit
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG // Can open doors. Coincidentally this also seems to allow the mob to shoot through them (if they're glass airlocks)? It's weird
	stat_attack = UNCONSCIOUS // DISINTEGRATION PROTOCOLS ACTIVE

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

	faction = "mothership"

/mob/living/simple_animal/hostile/mothership_hoverdisc/Process_Spacemove(var/check_drift = 0) // It can follow enemies into space, and won't just drift off
	return 1

/mob/living/simple_animal/hostile/mothership_hoverdisc/emp_act(severity) // Vulnerable to EMP damage
	if(flags & INVULNERABLE)
		return

	switch (severity)
		if (1)
			adjustBruteLoss(50)

		if (2)
			adjustBruteLoss(30)

/mob/living/simple_animal/hostile/mothership_hoverdisc/bullet_act(var/obj/item/projectile/P) // Tough nut. Energy weapons are almost completely ineffective. Ballistics are better, but ions are best
	if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam) || istype(P, /obj/item/projectile/forcebolt) || istype(P, /obj/item/projectile/change))
		if(prob(35))
			src.health -= P.damage
		else
			visible_message("<span class='danger'>The [P.name] dissipates harmlessly on the [src]'s armor plating!</span>") // Energy weapons have a high chance to "dissipate" and do no damage
		return PROJECTILE_COLLISION_DEFAULT
	if(istype(P, /obj/item/projectile/bullet))
		if(prob(65))
			src.health -= P.damage
		else
			visible_message("<span class='danger'>The bullet glances off the [src]'s armor plating, failing to penetrate!</span>") // Bullets have a lesser chance to "deflect", and do reduced damage
			src.health -= P.damage/3
		return PROJECTILE_COLLISION_DEFAULT
	return (..(P))

/mob/living/simple_animal/hostile/mothership_hoverdisc/death(var/gibbed = FALSE)
	visible_message("<span class='warning'>The [src] shudders and violently explodes!</span>")
	new /obj/effect/gibspawner/robot(src.loc)
	explosion(get_turf(src), -1, 2, 4, whodunnit = src)
	qdel(src)
	return

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

/mob/living/simple_animal/hostile/retaliate/polyp/Process_Spacemove(var/check_drift = 0) // It can follow enemies into space, and won't just drift off
	return 1

/mob/living/simple_animal/hostile/retaliate/polyp/mothership // Mothership faction version, so it doesn't get attacked by the vault dwellers
	faction = "mothership"

/mob/living/simple_animal/hostile/retaliate/polyp/phyl // Unique polyp that has been trained to trade coins when fed NotRaisins, there's no way to know this in-game as of yet. Jellyfish traders when?
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
// Just a silly joke for now, may expand more on it in the future (maybe)
/mob/living/simple_animal/mouse/gym_rat
	name = "gym rat"
	desc = "It's pretty swole."
	_color = "balbc"
	icon_state = "mouse_balbc"
	namenumbers = FALSE
	emote_see = list("flexes", "sweats", "does a rep")
	maxHealth = 25
	health = 25
	universal_speak = 1
	universal_understand = 1
	can_chew_wires = 1

/mob/living/simple_animal/mouse/gym_rat/mothership // Mothership faction version, so it doesn't get attacked by the vault dwellers
	faction = "mothership"

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
		icon_state = icon_dead
		spawn(rand(20,50))
			if(!stat && M)
				icon_state = icon_living
				src.say(pick("Please stop that.","That was cruel.","Oh, come on.","Why are you doing this to me?","Don't you have any moral scruples? That was very unpleasant.","If the shoe was on the other foot, I wouldn't do that to you."))
	else
		..()
