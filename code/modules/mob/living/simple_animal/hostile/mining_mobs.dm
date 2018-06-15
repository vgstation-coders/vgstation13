/mob/living/simple_animal/hostile/asteroid
	vision_range = 2
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15
	faction = "mining"
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS
	minbodytemp = 0
	heat_damage_per_tick = 20
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "strikes"
	status_flags = 0
	size = SIZE_BIG
	a_intent = I_HURT
	var/throw_message = "bounces off of"
	var/icon_aggro = null // for swapping to when we get aggressive
	held_items = list()

/mob/living/simple_animal/hostile/asteroid/Aggro()
	..()
	icon_state = icon_aggro

/mob/living/simple_animal/hostile/asteroid/LoseAggro()
	..()
	icon_state = icon_living

/mob/living/simple_animal/hostile/asteroid/bullet_act(var/obj/item/projectile/P)//Reduces damage from most projectiles to curb off-screen kills
	if(!stat)
		Aggro()
	if(P.damage < 30)
		P.damage = (P.damage / 2)
		visible_message("<span class='danger'>The [P] has a reduced effect on [src]!</span>")
	..()

/mob/living/simple_animal/hostile/asteroid/hitby(atom/movable/AM, speed)//No floor tiling them to death, wiseguy
	. = ..()
	if(.)
		return
	if(istype(AM, /obj/item))
		var/obj/item/T = AM
		if(!stat)
			Aggro()
		if(T.throwforce <= 15 && speed < 10)
			visible_message("<span class='notice'>The [T.name] [src.throw_message] [src.name]!</span>")
			return
	..()

/mob/living/simple_animal/hostile/asteroid/basilisk
	name = "basilisk"
	desc = "A territorial beast, covered in a thick shell that absorbs energy. Its stare causes victims to freeze from the inside."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Basilisk"
	icon_living = "Basilisk"
	icon_aggro = "Basilisk_alert"
	icon_dead = "Basilisk_dead"
	icon_gib = "syndicate_gib"
	move_to_delay = 20
	projectiletype = /obj/item/projectile/temp/basilisk
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	ranged_message = "stares"
	ranged_cooldown_cap = 20
	throw_message = "does nothing against the hard shell of"
	vision_range = 2
	speed = 4
	maxHealth = 200
	health = 200
	harm_intent_damage = 5
	melee_damage_lower = 12
	melee_damage_upper = 12
	attacktext = "bites into"
	a_intent = I_HURT
	attack_sound = 'sound/weapons/spiderlunge.ogg'
	ranged_cooldown_cap = 4
	aggro_vision_range = 9
	idle_vision_range = 2

/obj/item/projectile/temp/basilisk
	name = "freezing blast"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	temperature = 50

/mob/living/simple_animal/hostile/asteroid/basilisk/GiveTarget(var/new_target)
	target = new_target
	if(target != null)
		Aggro()
		stance = HOSTILE_STANCE_ATTACK
		if(isliving(target))
			var/mob/living/L = target
			L.bodytemperature = max(L.bodytemperature-1,T0C+25)
			L.apply_damage(5, BURN, null, used_weapon = "Excessive Cold")
			visible_message("<span class='danger'>The [src.name]'s stare chills [L.name] to the bone!</span>")
	return

/mob/living/simple_animal/hostile/asteroid/basilisk/ex_act(severity)
	if(flags & INVULNERABLE)
		return

	switch(severity)
		if(1.0)
			gib()
		if(2.0)
			adjustBruteLoss(140)
		if(3.0)
			adjustBruteLoss(110)

obj/item/asteroid/basilisk_hide
	name = "basilisk crystals"
	desc = "You shouldn't ever see this."
	icon = 'icons/obj/mining.dmi'
	icon_state = "Diamond ore"

obj/item/asteroid/basilisk_hide/New()
	var/counter
	for(counter=0, counter<2, counter++)
		var/obj/item/weapon/ore/diamond/D = new /obj/item/weapon/ore/diamond(src.loc)
		D.plane = MOB_PLANE
		D.layer = MOB_LAYER + 0.001
	..()
	qdel(src)

/mob/living/simple_animal/hostile/asteroid/goldgrub
	name = "goldgrub"
	desc = "A worm that grows fat from eating everything in its sight. Seems to enjoy precious metals and other shiny things, hence the name."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Goldgrub"
	icon_living = "Goldgrub"
	icon_aggro = "Goldgrub_alert"
	icon_dead = "Goldgrub_dead"
	icon_gib = "syndicate_gib"
	vision_range = 3
	aggro_vision_range = 9
	idle_vision_range = 3
	move_to_delay = 3
	friendly = "harmlessly rolls into"
	maxHealth = 60
	health = 60
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "barrels into"
	a_intent = I_HELP
	throw_message = "sinks in slowly, before being pushed out of "
	status_flags = CANPUSH
	search_objects = 1
	wanted_objects = list(/obj/item/weapon/ore/diamond, /obj/item/weapon/ore/gold, /obj/item/weapon/ore/silver,
						  /obj/item/weapon/ore/uranium)

	var/list/ore_types_eaten = list()
	var/alerted = 0
	var/ore_eaten = 1
	var/chase_time = 100

/mob/living/simple_animal/hostile/asteroid/goldgrub/GiveTarget(var/new_target)
	target = new_target
	if(target != null)
		if(istype(target, /obj/item/weapon/ore))
			visible_message("<span class='notice'>The [src.name] looks at [target.name] with hungry eyes.</span>")
			stance = HOSTILE_STANCE_ATTACK
			return
		if(isliving(target))
			Aggro()
			stance = HOSTILE_STANCE_ATTACK
			visible_message("<span class='danger'>The [src.name] tries to flee from [target.name]!</span>")
			retreat_distance = 10
			minimum_distance = 10
			Burrow()
			return
	return

/mob/living/simple_animal/hostile/asteroid/goldgrub/AttackingTarget()
	if(istype(target, /obj/item/weapon/ore))
		EatOre(target)
		return
	..()

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/EatOre(var/atom/targeted_ore)
	for(var/obj/item/weapon/ore/O in targeted_ore.loc)
		ore_eaten++
		if(!(O.type in ore_types_eaten))
			ore_types_eaten += O.type
		qdel(O)
		O = null
	if(ore_eaten > 5)//Limit the scope of the reward you can get, or else things might get silly
		ore_eaten = 5
	visible_message("<span class='notice'>The ore was swallowed whole!</span>")

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/Burrow()//Begin the chase to kill the goldgrub in time
	if(!alerted)
		alerted = 1
		spawn(chase_time)
		if(alerted)
			visible_message("<span class='danger'>The [src.name] buries into the ground, vanishing from sight!</span>")
			qdel(src)

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/Reward()
	if(!ore_eaten || ore_types_eaten.len == 0)
		return
	visible_message("<span class='danger'>[src] spits up the contents of its stomach before dying!</span>")
	var/counter
	for(var/R in ore_types_eaten)
		for(counter=0, counter < ore_eaten, counter++)
			new R(src.loc)
	ore_types_eaten.len = 0
	ore_eaten = 0


/mob/living/simple_animal/hostile/asteroid/goldgrub/bullet_act(var/obj/item/projectile/P)
	visible_message("<span class='danger'>The [P.name] was repelled by [src.name]'s girth!</span>")
	return

/mob/living/simple_animal/hostile/asteroid/goldgrub/death(var/gibbed = FALSE)
	alerted = 0
	Reward()
	..(gibbed)

/mob/living/simple_animal/hostile/asteroid/hivelord
	name = "hivelord"
	desc = "A truly alien creature, it is a mass of unknown organic material, constantly fluctuating. When attacking, pieces of it split off and attack in tandem with the original."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Hivelord"
	icon_living = "Hivelord"
	icon_aggro = "Hivelord_alert"
	icon_dead = "Hivelord_dead"
	icon_gib = "syndicate_gib"
	mouse_opacity = 2
	move_to_delay = 14
	ranged = 1
	vision_range = 5
	aggro_vision_range = 9
	idle_vision_range = 5
	speed = 4
	maxHealth = 75
	health = 75
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "lashes out at"
	throw_message = "falls right through the strange body of the"
	ranged_cooldown = 0
	ranged_cooldown_cap = 0
	environment_smash_flags = 0
	retreat_distance = 3
	minimum_distance = 3
	pass_flags = PASSTABLE

/mob/living/simple_animal/hostile/asteroid/hivelord/OpenFire(var/the_target)
	var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/A = getFromPool(/mob/living/simple_animal/hostile/asteroid/hivelordbrood,src.loc)
	A.GiveTarget(target)
	A.friends = friends
	A.faction = faction
	return

/mob/living/simple_animal/hostile/asteroid/hivelord/AttackingTarget()
	OpenFire()

/mob/living/simple_animal/hostile/asteroid/hivelord/death(var/gibbed = FALSE)
	mouse_opacity = 1
	..(gibbed)
	update_icons()

/mob/living/simple_animal/hostile/asteroid/hivelord/update_icons()
	.=..()

	if(stat == DEAD && butchering_drops)
		icon_state = "[icon_dead][has_core() ? "" : "_nocore"]"

/mob/living/simple_animal/hostile/asteroid/hivelord/Aggro()
	..()
	if(butchering_drops)
		icon_state = "[icon_aggro][has_core() ? "" : "_nocore"]"

/mob/living/simple_animal/hostile/asteroid/hivelord/LoseAggro()
	..()
	if(butchering_drops)
		icon_state = "[icon_living][has_core() ? "" : "_nocore"]"

/mob/living/simple_animal/hostile/asteroid/hivelord/proc/has_core()
	if(butchering_drops)
		var/datum/butchering_product/hivelord_core/core = locate(/datum/butchering_product/hivelord_core) in butchering_drops
		if(istype(core))
			return core.amount
	return 1

/obj/item/asteroid/hivelord_core
	name = "hivelord remains"
	desc = "All that remains of a hivelord, it seems to be what allows it to break pieces of itself off without being hurt... its healing properties will soon become inert if not used quickly. Try not to think about what you're eating."
	icon = 'icons/obj/food.dmi'
	icon_state = "boiledrorocore"
	var/inert = 0
	var/time_left = 1200 //deciseconds
	var/last_process

/obj/item/asteroid/hivelord_core/New()
	..()
	create_reagents(5)
	last_process = world.time
	processing_objects.Add(src)

/obj/item/asteroid/hivelord_core/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/asteroid/hivelord_core/process()
	if(reagents && reagents.has_reagent(FROSTOIL, 5))
		playsound(src, 'sound/effects/glass_step.ogg', 50, 1)
		desc = "All that remains of a hivelord, it seems to be what allows it to break pieces of itself off without being hurt. It is covered in a thin coat of frost."
		processing_objects.Remove(src)
		return

	if(time_left <= 0)
		inert = 1
		desc = "The remains of a hivelord that have become useless, having been left alone too long after being harvested."
		processing_objects.Remove(src)
		return

	if(loc && (istype(loc, /obj/structure/closet/crate/freezer) || istype(loc, /obj/structure/closet/secure_closet/freezer)))
		last_process = world.time
		return

	time_left -= world.time - last_process
	last_process = world.time

/obj/item/asteroid/hivelord_core/attack(mob/living/M as mob, mob/living/user as mob)
	if (iscarbon(M) && user.a_intent != I_HURT)
		return consume(user, M)
	else
		return ..()

/obj/item/asteroid/hivelord_core/attack_self(mob/user as mob)
	if (iscarbon(user))
		return consume(user, user)

/obj/item/asteroid/hivelord_core/proc/consume(var/mob/living/user, var/mob/living/carbon/target)
	if (inert)
		to_chat(user, "<span class='notice'>[src] have become inert, its healing properties are no more.</span>")
		return TRUE

	if (target.stat == DEAD)
		to_chat(user, "<span class='notice'>[src] are useless on the dead.</span>")
		return

	// revive() requires a check for suiciding
	if (target.suiciding)
		to_chat(user, "<span class='notice'>It's dead, Jim.</span>")
		return

	if (!target.hasmouth)
		if (target != user)
			to_chat(user, "<span class='warning'>You attempt to feed \the [src] to [target], but you realize they don't have a mouth. How dumb!</span>")
		else
			to_chat(user, "<span class='warning'>You don't have a mouth to eat \the [src] with.</span>")
		return

	// Delay feeding to others, just like in regular food
	if (target != user)
		user.visible_message("<span class='danger'>[user] attempts to feed [target] \the [src].</span>", "<span class='danger'>You attempt to feed [target] \the [src].</span>")
		if (!do_mob(user, target))
			return
		user.visible_message("<span class='notice'>[user] feeds [target] the [src]... They look better!</span>")
	else
		to_chat(user, "<span class='notice'>You chomp into \the [src], barely managing to hold it down, but feel amazingly refreshed in mere moments.</span>")

	playsound(src, 'sound/items/eatfood.ogg', rand(10, 50), 1)
	target.revive()

	user.drop_from_inventory(src)
	qdel(src)
	return TRUE

/mob/living/simple_animal/hostile/asteroid/hivelordbrood
	name = "hivelord brood"
	desc = "A fragment of the original Hivelord, rallying behind its original. One isn't much of a threat, but..."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Hivelordbrood"
	icon_living = "Hivelordbrood"
	icon_aggro = "Hivelordbrood"
	icon_dead = "Hivelordbrood"
	icon_gib = "syndicate_gib"
	mouse_opacity = 2
	move_to_delay = 0
	friendly = "buzzes near"
	vision_range = 10
	speed = 4
	maxHealth = 1
	health = 1
	harm_intent_damage = 5
	melee_damage_lower = 2
	melee_damage_upper = 2
	attacktext = "slashes"
	throw_message = "falls right through the strange body of the"
	environment_smash_flags = 0
	pass_flags = PASSTABLE

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/New()
	..()
	spawn(100)
		returnToPool(src)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/death(var/gibbed = FALSE)
	..(TRUE)
	returnToPool(src)

/mob/living/simple_animal/hostile/asteroid/goliath
	name = "goliath"
	desc = "A massive beast that uses long tentacles to ensare its prey, threatening them is not advised under any conditions."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Goliath"
	icon_living = "Goliath"
	icon_aggro = "Goliath_alert"
	icon_dead = "Goliath_dead"
	icon_gib = "syndicate_gib"
	attack_sound = 'sound/weapons/heavysmash.ogg'
	move_to_delay = 40
	ranged = 1
	ranged_cooldown_cap = 8
	friendly = "wails at"
	vision_range = 5
	speed = 4
	maxHealth = 300
	health = 300
	harm_intent_damage = 0
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "pulverizes"
	throw_message = "does nothing to the rocky hide of the"
	aggro_vision_range = 9
	idle_vision_range = 5

	size = SIZE_BIG

/mob/living/simple_animal/hostile/asteroid/goliath/OpenFire(atom/ttarget)
	var/tturf = get_turf(ttarget)
	if(!istype(tturf, /turf/space) && istype(ttarget))
		visible_message("<span class='warning'>\The [src] digs its tentacles under \the [ttarget]!</span>")
		playsound(loc, 'sound/weapons/whip.ogg', 50, 1, -1)
		new /obj/effect/goliath_tentacle/original(tturf)
		ranged_cooldown = ranged_cooldown_cap
	return

/mob/living/simple_animal/hostile/asteroid/goliath/adjustBruteLoss(var/damage)
	ranged_cooldown--
	..()

/obj/effect/goliath_tentacle/
	name = "Goliath tentacle"
	icon = 'icons/mob/animal.dmi'
	icon_state = "Goliath_tentacle"

/obj/effect/goliath_tentacle/New()
	..()
	var/turftype = get_turf(src)
	if(istype(turftype, /turf/unsimulated/mineral))
		var/turf/unsimulated/mineral/M = turftype
		M.GetDrilled()
	spawn(20)
		Trip()

/obj/effect/goliath_tentacle/original

/obj/effect/goliath_tentacle/original/New()
	var/list/directions = cardinal.Copy()
	var/counter
	for(counter = 1, counter <= 3, counter++)
		var/spawndir = pick(directions)
		directions -= spawndir
		var/turf/T = get_step(src,spawndir)
		if(!istype(T, /turf/space))
			new /obj/effect/goliath_tentacle(T)
	..()

/obj/effect/goliath_tentacle/proc/Trip()
	for(var/mob/living/M in src.loc)
		M.Knockdown(5)
		visible_message("<span class='warning'>The [src.name] knocks [M.name] down!</span>")

	qdel(src)

/obj/effect/goliath_tentacle/Crossed(atom/movable/O)
	..(O)

	if(isliving(O))
		Trip()

/obj/item/asteroid/goliath_hide
	name = "goliath hide plates"
	desc = "Pieces of a goliath's rocky hide, these might be able to make your suit a bit more durable to attack from the local fauna."
	icon = 'icons/obj/items.dmi'
	icon_state = "goliath_hide"
	w_class = W_CLASS_MEDIUM

/obj/item/asteroid/goliath_hide/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag && istype(target, /obj/item/clothing))
		var/obj/item/clothing/C = target
		var/current_armor = C.armor
		if(C.goliath_reinforce)
			if(current_armor.["melee"] < 90)
				current_armor.["melee"] = min(current_armor.["melee"] + 10, 90)
				to_chat(user, "<span class='info'>You strengthen [target], improving its resistance against melee attacks.</span>")
				qdel(src)
			else
				to_chat(user, "<span class='info'>You can't improve [C] any further.</span>")
	return
