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
	response_harm   = "harmlessly punches"
	harm_intent_damage = 0
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
	projectiletype = /obj/item/projectile/beam/immolationray/upgraded // A unique beam that deals more damage than a regular immolation ray and can destroy walls
	projectilesound = 'sound/weapons/ray1.ogg'
	retreat_distance = 8 // It will attempt to linger at a distance just outside of a player's typical field of view, firing shots while deflecting return fire off its armor
	minimum_distance = 8
	ranged_cooldown = 4 // Some cooldown to balance the serious punch it packs
	ranged_cooldown_cap = 4

	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS | OPEN_DOOR_STRONG | OPEN_DOOR_SMART // Can open doors and smash walls. Coincidentally this also seems to allow the mob to shoot through them (if they're glass airlocks)? It's weird
	stat_attack = UNCONSCIOUS // DISINTEGRATION PROTOCOLS ACTIVE

	var/damageblock = 15 // Most common melee weapons will do nothing against its thick armor

	var/last_ufosound = 0
	var/const/ufosound_cooldown = 30 SECONDS // After making a sound effect, needs to wait thirty seconds before having a chance to make one again. Prevents spam

/mob/living/simple_animal/hostile/mothership_hoverdisc/Life()
	..()
	if((last_ufosound + ufosound_cooldown < world.time) && prob(5)) // Will occasionally play a spoopy ufo sound
		visible_message("<span class='notice'>The [src] emits a rhythmic hum.</span>")
		playsound(src, 'sound/effects/ufo_appear.ogg', 50, 0)
		last_ufosound = world.time
	if(health >= (maxHealth/2)) // We've got a good bit of health, let's stay back and snipe
		retreat_distance = 8
		minimum_distance = 8
	if(health < (maxHealth/2)) // We've taken a lot of damage, let's get up close and personal
		retreat_distance = 2
		minimum_distance = 2

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
			spark(src)

		if (2)
			adjustBruteLoss(50)
			spark(src)

/mob/living/simple_animal/hostile/mothership_hoverdisc/proc/discblock(var/damage, var/atom/A) // Hoverdiscs have thick armor, and are unaffected by low force melee weapons
	if (!damage || damage <= damageblock)
		if (A)
			visible_message("<span class='danger'>\The [A] glances harmlessly off of the [src]'s armor plating! </span>")
			anim(target = src, a_icon = 'icons/effects/64x64.dmi', flick_anim = "juggernaut_armor", lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE/2, offY = -WORLD_ICON_SIZE/2 + 4, plane = ABOVE_LIGHTING_PLANE) // Copied from juggernauts so players get visual feedback when their attacks aren't doing damage
			playsound(src, 'sound/items/metal_impact.ogg', 25)
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/mothership_hoverdisc/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(discblock(O.force, O))
		user.delayNextAttack(8)
	else
		..()

/mob/living/simple_animal/hostile/mothership_hoverdisc/thrown_defense(var/obj/O)
	if(discblock(O.throwforce,O))
		return FALSE
	return TRUE

/mob/living/simple_animal/hostile/mothership_hoverdisc/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, sharp, edge, var/used_weapon = null, ignore_events = 0)
	if (discblock(damage))
		return 0
	return ..()

/mob/living/simple_animal/hostile/mothership_hoverdisc/bullet_act(var/obj/item/projectile/P) // Tough nut. Energy weapons are almost completely ineffective, and ballistics do reduced damage. Ions are your best friend here
	if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam) || istype(P, /obj/item/projectile/forcebolt) || istype(P, /obj/item/projectile/change))
		if(prob(35))
			src.health -= P.damage
			spark(src)
		else
			visible_message("<span class='danger'>The [P.name] dissipates harmlessly on the [src]'s armor plating!</span>") // Lasers that fail to get through "dissipate" and do no damage
			anim(target = src, a_icon = 'icons/effects/64x64.dmi', flick_anim = "juggernaut_armor", lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE/2, offY = -WORLD_ICON_SIZE/2 + 4, plane = ABOVE_LIGHTING_PLANE)
			playsound(src, 'sound/items/metal_impact.ogg', 25)
		return PROJECTILE_COLLISION_DEFAULT
	if(istype(P, /obj/item/projectile/bullet))
		if(prob(35))
			src.health -= P.damage
			spark(src)
		else
			visible_message("<span class='danger'>The [P.name] glances off the [src]'s armor plating, failing to penetrate!</span>") // Bullets that fail to get through "deflect" and do greatly reduced damage
			anim(target = src, a_icon = 'icons/effects/64x64.dmi', flick_anim = "juggernaut_armor", lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE/2, offY = -WORLD_ICON_SIZE/2 + 4, plane = ABOVE_LIGHTING_PLANE)
			playsound(src, 'sound/effects/bullet_ricocchet.ogg', 25, 0)
			src.health -= P.damage/10
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
