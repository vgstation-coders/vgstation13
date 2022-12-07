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
	unsuitable_atmos_damage = 15
	faction = "mining"
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS
	minbodytemp = 0
	heat_damage_per_tick = 20
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "strikes"
	size = SIZE_BIG
	a_intent = I_HURT
	var/throw_message = "bounces off of"
	var/icon_aggro = null // for swapping to when we get aggressive
	held_items = list()
	status_flags = CANSTUN|CANKNOCKDOWN|CANPARALYSE|CANPUSH

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
		visible_message("<span class='danger'>\The [P] has a reduced effect on \the [src]!</span>")
	return ..()

/mob/living/simple_animal/hostile/asteroid/hitby(atom/movable/AM, speed)//No floor tiling them to death, wiseguy
	. = ..()
	if(.)
		return
	if(istype(AM, /obj/item))
		var/obj/item/T = AM
		if(!stat)
			Aggro()
		if(T.throwforce <= 15 && speed < 10)
			visible_message("<span class='notice'>\The [T] [src.throw_message] \the [src]!</span>")
			return

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

/mob/living/simple_animal/hostile/asteroid/basilisk/gorgon
	name = "gorgon"
	desc = "Looking at this one doesn't seen to turn the beholder into stone."
	icon_state = "gorgon"
	icon_living = "gorgon"
	icon_aggro = "gorgon_alert"
	icon_dead = "gorgon_dead"
	move_to_delay = 10
	ranged = FALSE
	speed = 2
	maxHealth = 80
	health = 80
	harm_intent_damage = 2
	melee_damage_lower = 7
	melee_damage_upper = 7
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS
	size = SIZE_SMALL

/obj/item/projectile/temp/basilisk
	name = "freezing blast"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	temperature = 50

/mob/living/simple_animal/hostile/asteroid/basilisk/get_butchering_products()
	return list(/datum/butchering_product/skin/basilisk)

/mob/living/simple_animal/hostile/asteroid/basilisk/GiveTarget(var/new_target)
	target = new_target
	if(target != null)
		Aggro()
		stance = HOSTILE_STANCE_ATTACK
		if(isliving(target))
			var/mob/living/L = target
			L.bodytemperature = max(L.bodytemperature-1,T0C+25)
			L.apply_damage(5, BURN, null, used_weapon = "Excessive Cold")
			visible_message("<span class='danger'>\The [src]'s stare chills \the [L] to the bone!</span>")

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

/mob/living/simple_animal/hostile/asteroid/basilisk/death(var/gibbed = FALSE)
	visible_message("<span class='danger'>\The [src] shatters before dying, leaving some diamond ore.</span>")
	drop_stack(/obj/item/stack/ore/diamond, loc, 2)
	..(gibbed)

/obj/item/asteroid/basilisk_hide
	name = "basilisk hide"
	desc = "Diamond-studded hide."
	icon = 'icons/obj/items.dmi'
	icon_state = "basilisk_hide"

/obj/item/asteroid/basilisk_hide/afterattack(atom/target, mob/user, proximity_flag)
	if(!(proximity_flag && istype(target, /obj/item/clothing)))
		return
	var/obj/item/clothing/C = target
	if(!(C.clothing_flags & BASILISK_REINFORCEABLE))
		return

	C.clothing_flags &= ~HIVELORD_REINFORCEABLE
	C.clothing_flags &= ~GOLIATH_REINFORCEABLE

	var/current_armor = C.armor
	C.hidecount++
	if(current_armor["laser"] < 30)
		current_armor["laser"] = min(current_armor["laser"] + 5, 30)
		to_chat(user, "<span class='info'>You strengthen [target], improving its dissipation of lasers.</span>")
		qdel(src)
	else
		to_chat(user, "<span class='info'>You can't improve [C] any further.</span>")
	if(has_icon(C.icon, "[initial(C.item_state)]_basilisk[C.hidecount]"))
		C.name = "reinforced [initial(C.name)]"
		C.item_state = "[initial(C.item_state)]_basilisk[C.hidecount]"
		C.icon_state = "[initial(C.icon_state)]_basilisk[C.hidecount]"
		C._color = "mining_basilisk[C.hidecount]"
	if(user.is_wearing_item(C))
		user.regenerate_icons()

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
	wanted_objects = list(/obj/item/stack/ore/diamond, /obj/item/stack/ore/gold, /obj/item/stack/ore/silver,
						  /obj/item/stack/ore/uranium)

	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS | SMASH_ASTEROID
	var/list/ore_types_eaten = list()
	var/alerted = 0
	var/ore_eaten = 1
	var/chase_time = 100

/mob/living/simple_animal/hostile/asteroid/goldgrub/GiveTarget(var/new_target)
	target = new_target
	if(target != null)
		if(istype(target, /obj/item/stack/ore))
			visible_message("<span class='notice'>\The [src] looks at \the [target] with hungry eyes.</span>")
			stance = HOSTILE_STANCE_ATTACK
			return
		if(isliving(target))
			Aggro()
			stance = HOSTILE_STANCE_ATTACK
			visible_message("<span class='danger'>\The [src] tries to flee from \the [target]!</span>")
			retreat_distance = 10
			minimum_distance = 10
			Burrow()

/mob/living/simple_animal/hostile/asteroid/goldgrub/AttackingTarget()
	if(istype(target, /obj/item/stack/ore))
		EatOre(target)
		return
	..()

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/EatOre(var/atom/targeted_ore)
	for(var/obj/item/stack/ore/O in targeted_ore.loc)
		ore_eaten++
		ore_types_eaten[O.type]++
		O.use(1)
	if(ore_eaten > 5)//Limit the scope of the reward you can get, or else things might get silly
		ore_eaten = 5
	visible_message("<span class='notice'>\The [targeted_ore] was swallowed whole!</span>")

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/Burrow()//Begin the chase to kill the goldgrub in time
	if(!alerted)
		alerted = TRUE
		spawn(chase_time)
			if(alerted)
				var/turf/T = get_turf(src)
				if (istype(T, /turf/space))
					alerted = FALSE
					return
				visible_message("<span class='danger'>\The [src] burrows into the ground, vanishing from sight!</span>")
				forceMove(null)
				T.ex_act(2)
				spawn(rand(30 SECONDS,90 SECONDS))
					var/turf/new_turf
					for(var/turf/TT in orange(T, 12)-orange(T,4))
						if(prob(70))
							continue
						if(isspace(TT))
							continue
						new_turf = TT
						break
					new_turf.visible_message("<span class = 'warning'>A rumbling noise eminates from \the [new_turf].</span>")
					spawn(5 SECONDS)
						explosion(new_turf,-1,1,3)
						spawn(1 SECONDS)
							forceMove(new_turf)
							LoseAggro()
							alerted = FALSE

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/Reward()
	if(!ore_eaten || ore_types_eaten.len == 0)
		return
	visible_message("<span class='danger'>\The [src] spits up the contents of its stomach before dying!</span>")
	for(var/R in ore_types_eaten)
		drop_stack(R, loc, ore_types_eaten[R])
	ore_types_eaten.len = 0
	ore_eaten = 0


/mob/living/simple_animal/hostile/asteroid/goldgrub/bullet_act(var/obj/item/projectile/P)
	visible_message("<span class='danger'>\The [P] was repelled by \the [src]'s girth!</span>")
	return PROJECTILE_COLLISION_DEFAULT

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
	hostile_interest = 15 //Very persistent
	var/open_fire_type = /mob/living/simple_animal/hostile/asteroid/hivelordbrood
	var/list/mob/living/simple_animal/hostile/broods = list()
	var/brood_limit = 0

/mob/living/simple_animal/hostile/asteroid/hivelord/get_butchering_products()
	return list(/datum/butchering_product/hivelord_core)

/mob/living/simple_animal/hostile/asteroid/hivelord/OpenFire(var/the_target)
	if(!brood_limit || broods.len < brood_limit)
		var/mob/living/simple_animal/hostile/A = new open_fire_type(src.loc)
		if(istype(A))
			A.GiveTarget(target)
			A.friends = friends
			A.faction = faction
			A.hivelord = src
			broods.Add(A)

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

/mob/living/simple_animal/hostile/asteroid/hivelord/guardian
	name = "Hivelord Guardian"
	maxHealth = 100 //slighly tougher than regular hivelords
	health = 100
	treadmill_speed = 5
	desc = "A special breed of hivelord, this one will give its life to defend the queen and hive."
	open_fire_type = /mob/living/simple_animal/hostile/asteroid/hivelordbrood/guardian

/mob/living/simple_animal/hostile/asteroid/hivelord/guardian/New()
	..()
	appearance_flags |= PIXEL_SCALE
	var/matrix/M = matrix()
	M.Scale(1.5,1.5) //halfway between regular hivelords and the queen
	transform = M

/mob/living/simple_animal/hostile/asteroid/hivelord/guardian/get_butchering_products()
	return list(/datum/butchering_product/hivelord_core/guardian)

/mob/living/simple_animal/hostile/asteroid/hivelord/boss
	name = "Maria"
	desc = "A hulking Hivelord Queen. When attacking, will create more hivelords to ensure the safety of her hive. Her core beats and glows with an eerie light."
	size = SIZE_HUGE
	maxHealth = 300
	health = 300
	pixel_y = 16 * PIXEL_MULTIPLIER
	status_flags = UNPACIFIABLE
	move_to_delay = 30
	harm_intent_damage = 10
	hostile_interest = 5 //Less persistent
	open_fire_type = /mob/living/simple_animal/hostile/asteroid/hivelord
	brood_limit = 5
	treadmill_speed = 6

/mob/living/simple_animal/hostile/asteroid/hivelord/boss/New()
	..()
	appearance_flags |= PIXEL_SCALE
	var/matrix/M = matrix()
	M.Scale(2,2)
	transform = M

/mob/living/simple_animal/hostile/asteroid/hivelord/boss/get_butchering_products()
	return list(/datum/butchering_product/hivelord_core/heart)

/obj/item/asteroid/hivelord_core
	name = "hivelord remains"
	desc = "All that remains of a hivelord, it seems to be what allows it to break pieces of itself off without being hurt... its healing properties will soon become inert if not used quickly. Try not to think about what you're eating."
	icon = 'icons/obj/food.dmi'
	icon_state = "boiledrorocore"
	var/inert = 0
	var/time_left = 1200 //deciseconds
	var/last_process

/obj/item/asteroid/hivelord_core/guardian
	name = "hivelord guardian remains"
	desc = "All that remains of a hivelord guardian, it seems to be what allows it to break pieces of itself off without being hurt... its healing properties will soon become inert if not used quickly. This one seems to last longer than usual."
	time_left = 3000 //5 minutes

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

/obj/item/asteroid/hivelord_core/afterattack(atom/target, mob/user, proximity_flag)
	if(!(proximity_flag && istype(target, /obj/item/clothing)))
		return
	var/obj/item/clothing/C = target
	if(!(C.clothing_flags & HIVELORD_REINFORCEABLE))
		return

	C.clothing_flags &= ~GOLIATH_REINFORCEABLE
	C.clothing_flags &= ~BASILISK_REINFORCEABLE

	var/current_armor = C.armor
	C.hidecount++
	if(current_armor["bio"] < 100 || current_armor["rad"] < 50)
		current_armor["bio"] = min(current_armor["bio"] + 10, 100)
		current_armor["rad"] = min(current_armor["rad"] + 10, 50)
		to_chat(user, "<span class='info'>You strengthen [target], improving its resistance against biological and radiological attacks.</span>")
		qdel(src)
	else
		to_chat(user, "<span class='info'>You can't improve [C] any further.</span>")
	if(has_icon(C.icon, "[initial(C.item_state)]_hivelord[C.hidecount]"))
		C.name = "reinforced [initial(C.name)]"
		C.item_state = "[initial(C.item_state)]_hivelord[C.hidecount]"
		C.icon_state = "[initial(C.icon_state)]_hivelord[C.hidecount]"
		C._color = "mining_hivelord[C.hidecount]"
	if(user.is_wearing_item(C))
		user.regenerate_icons()

/obj/item/asteroid/hivelord_core/attack_self(mob/user as mob)
	if (iscarbon(user))
		return consume(user, user)

/obj/item/asteroid/hivelord_core/proc/consume(var/mob/living/user, var/mob/living/carbon/target)
	if (inert)
		to_chat(user, "<span class='notice'>\The [src] have become inert, its healing properties are no more.</span>")
		return TRUE

	if (target.stat == DEAD)
		to_chat(user, "<span class='notice'>\The [src] are useless on the dead.</span>")
		return

	// revive() requires a check for suiciding
	if (target.mind && target.mind.suiciding)
		to_chat(user, "<span class='notice'>\The [target] refuses \the [src].</span>")
		return

	if (!target.hasmouth())
		if (target != user)
			to_chat(user, "<span class='warning'>You attempt to feed \the [src] to \the [target], but you realize they don't have a mouth. How dumb!</span>")
		else
			to_chat(user, "<span class='warning'>You don't have a mouth to eat \the [src] with.</span>")
		return

	// Delay feeding to others, just like in regular food
	if (target != user)
		user.visible_message("<span class='danger'>\The [user] attempts to feed \the [target] \the [src].</span>", "<span class='danger'>You attempt to feed \the [target] \the [src].</span>")
		if (!do_mob(user, target))
			return
		user.visible_message("<span class='notice'>\The [user] feeds \the [target] \the [src]... They look better!</span>")
	else
		to_chat(user, "<span class='notice'>You chomp into \the [src], barely managing to hold it down, but feel amazingly refreshed in mere moments.</span>")

	playsound(src, 'sound/items/eatfood.ogg', rand(10, 50), 1)
	target.revive()

	user.drop_from_inventory(src)
	qdel(src)
	return TRUE

/obj/item/organ/internal/heart/hivelord
	name = "hivelord heart"
	desc = "All that remains of a greater hivelord, works as a drop-in replacement for any species heart, granting protection from bone damage or internal bleeding, as well as boosting any healing processes. Try not to think about what's beating inside you."
	icon = 'icons/obj/food.dmi'
	icon_state = "boiledrorocore"
	organ_tag = "heart"
	prosthetic_name = null
	prosthetic_icon = null
	dead_icon = null
	fresh = 6 // Juicy.
	organ_type = /datum/organ/internal/heart/hivelord

/obj/item/organ/internal/heart/hivelord/die()
	..()
	desc = "The remains of a greater hivelord that have become useless, having been left alone too long after being out of a body. Perhaps injecting it with something might help?"

/obj/item/organ/internal/heart/hivelord/revive()
	..()
	desc = initial(desc)

/datum/organ/internal/heart/hivelord
	name = "hivelord heart"
	removed_type = /obj/item/organ/internal/heart/hivelord
	min_bruised_damage = 15
	min_broken_damage = 30

/datum/organ/internal/heart/hivelord/Life()
	for(var/datum/organ/external/E in owner.organs)
		if(prob(10))
			E.status &= ~ORGAN_BROKEN
			E.status &= ~ORGAN_SPLINTED
		for(var/datum/wound/W in E.wounds)
			if(W.internal && prob(10))
				E.wounds -= W
				E.update_damages()

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
		qdel(src)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/death(var/gibbed = FALSE)
	..(TRUE)
	qdel(src)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/guardian
	name = "hivelord guardian brood"
	desc = "A fragment of a Hivelord Guardian. It isn't much of a threat despite being stronger than a regular brood. Pretty weak by itself, but..."
	melee_damage_lower = 4
	melee_damage_upper = 4

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/guardian/New()
	..()
	appearance_flags |= PIXEL_SCALE
	var/matrix/M = matrix()
	M.Scale(1.5,1.5) //halfway between regular hivelords and the queen
	transform = M

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

/mob/living/simple_animal/hostile/asteroid/goliath/snow
	name = "white goliath"
	desc = "Tentacled, space-faring beasts that prey upon fauna in mineral-rich areas. The white subspecies has adapted to camouflage on a snowy world."
	icon_state = "Goliathwhite"
	icon_living = "Goliathwhite"
	icon_aggro = "Goliathwhite_alert"
	icon_dead = "Goliathwhite_dead"

/mob/living/simple_animal/hostile/asteroid/goliath/OpenFire(atom/ttarget)
	var/tturf = get_turf(ttarget)
	if(!istype(tturf, /turf/space) && istype(ttarget))
		visible_message("<span class='warning'>\The [src] digs its tentacles under \the [ttarget]!</span>")
		playsound(loc, 'sound/weapons/whip.ogg', 50, 1, -1)
		new /obj/effect/goliath_tentacle/original(tturf)
		ranged_cooldown = ranged_cooldown_cap
	return

/mob/living/simple_animal/hostile/asteroid/goliath/get_butchering_products()
	return list(/datum/butchering_product/skin/goliath, /datum/butchering_product/teeth/lots)

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
		if(M.mining_difficulty < MINE_DIFFICULTY_TOUGH)
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
		M.Stun(5)
		visible_message("<span class='warning'>\The [src] knocks \the [M] down!</span>")
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
	if(!(proximity_flag && istype(target, /obj/item/clothing)))
		return
	var/obj/item/clothing/C = target
	if(!(C.clothing_flags & GOLIATH_REINFORCEABLE))
		return

	C.clothing_flags &= ~HIVELORD_REINFORCEABLE
	C.clothing_flags &= ~BASILISK_REINFORCEABLE

	var/current_armor = C.armor
	C.hidecount++
	if(current_armor["melee"] < 90)
		current_armor["melee"] = min(current_armor["melee"] + 10, 90)
		to_chat(user, "<span class='info'>You strengthen [target], improving its resistance against melee attacks.</span>")
		qdel(src)
	else
		to_chat(user, "<span class='info'>You can't improve [C] any further.</span>")
	if(has_icon(C.icon, "[initial(C.item_state)]_goliath[C.hidecount]"))
		C.name = "reinforced [initial(C.name)]"
		C.item_state = "[initial(C.item_state)]_goliath[C.hidecount]"
		C.icon_state = "[initial(C.icon_state)]_goliath[C.hidecount]"
		C._color = "mining_goliath[C.hidecount]"
	if(user.is_wearing_item(C))
		user.regenerate_icons()

/mob/living/simple_animal/hostile/asteroid/goliath/david
	name = "david"
	desc = "I don't think this one can use a slingshot very well."
	icon = 'icons/mob/animal.dmi'
	icon_state = "david"
	icon_living = "david"
	icon_aggro = "david_alert"
	icon_dead = "david_dead"
	attack_sound = 'sound/weapons/heavysmash.ogg'
	move_to_delay = 20
	speed = 3
	maxHealth = 120
	health = 120
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 15
	ranged = FALSE
	attacktext = "smashes"
	throw_message = "does little to the sturdy hide of the"
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS
	size = SIZE_NORMAL

/mob/living/simple_animal/hostile/asteroid/goliath/david/dave
	name = "Dave"
	desc = "As the engineering crew decided where in the asteroid to build the station, they followed a small crevice where he was eventually found. Nobody knows how this little guy got separated from his family or why he became so attached to the crew that found him."
	response_help  = "pets"
	response_disarm = "pokes"
	response_harm   = "kicks"
	gender = MALE
	faction = "neutral"
	maxHealth = 100
	health = 100
	melee_damage_lower = 5
	melee_damage_upper = 7
	environment_smash_flags = null
	stop_automated_movement_when_pulled = TRUE
	move_to_delay = 10
	can_butcher = FALSE
	ranged = TRUE
	retreat_distance = 1 //Unlike normal davids, dave will kite its foes, or at least try to. REMEMBER THE BASICS OF CQC

//Stolen from corgi code
/mob/living/simple_animal/hostile/asteroid/goliath/david/dave/attack_hand(mob/living/carbon/human/M)
	. = ..()
	react_to_touch(M)

/mob/living/simple_animal/hostile/asteroid/goliath/david/dave/proc/react_to_touch(mob/M)
	var/list/responses_good = list("bleats happily.", "rumbles affectionately.", "emits a content crackle.")
	var/list/responses_bad = list("whimpers.", "lets out an upset gurgle.")

	if(M && !isUnconscious())
		switch(M.a_intent)
			if(I_HELP)
				var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
				heart.plane = ABOVE_HUMAN_PLANE
				flick_overlay(heart, list(M.client), 2 SECONDS)
				emote("me", EMOTE_AUDIBLE, pick(responses_good))
				//calm down when petted.
				LoseAggro()
			if(I_HURT)
				emote("me", EMOTE_AUDIBLE, pick(responses_bad))

/mob/living/simple_animal/hostile/asteroid/magmaw
	name = "magmaw"
	desc = "A living furnace. These things are drawn to crystallized plasma, which they feast upon to stoke their internal fires."
	icon_state = "lavagoop"
	icon_living = "lavagoop"
	icon_aggro = "lavagoop"
	icon_attack = "lavagoop_attack"
	icon_attack_time = 7
	icon_dying = "lavagoop_dying"
	icon_dying_time = 19
	icon_dead = "lavagoop_dead"
	attack_sound = 'sound/weapons/bite.ogg'
	search_objects = 3
	health = 125
	maxHealth = 125
	melee_damage_lower = 10
	melee_damage_upper = 25
	meat_amount = 0
	vision_range = 4
	faction = "neutral"
	maxbodytemp = ARBITRARILY_PLANCK_NUMBER
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS | SMASH_ASTEROID
	var/fire_time
	var/fire_extremity

/mob/living/simple_animal/hostile/asteroid/magmaw/fire_act(var/datum/gas_mixture/air, var/exposed_temperature, var/exposed_volume)
	fire_resurrect(exposed_temperature)

/mob/living/simple_animal/hostile/asteroid/magmaw/IgniteMob()
	fire_resurrect(PLASMA_MINIMUM_BURN_TEMPERATURE)

/mob/living/simple_animal/hostile/asteroid/magmaw/FireBurn(var/firelevel, var/last_temperature, var/pressure)
	fire_resurrect(last_temperature)

/mob/living/simple_animal/hostile/asteroid/magmaw/proc/fire_resurrect(var/temperature)
	if(isDead() && temperature > PLASMA_MINIMUM_BURN_TEMPERATURE)
		resurrect()
		revive()
		visible_message("<span class = 'warning'>\The [src] reignites!</span>")


/mob/living/simple_animal/hostile/asteroid/magmaw/adjustFireLoss()
	return //We're a magma slime. We ARE FIRE.


/mob/living/simple_animal/hostile/asteroid/magmaw/Life()
	if(!..())
		return
	var/datum/gas_mixture/environment

	if(isturf(loc))
		var/turf/T = loc
		environment = T.return_air()

	if(environment)
		environment.add_thermal_energy(50000)

	if(world.time > fire_time)
		return

	switch(fire_extremity)
		if(1) // Fire spout
			generic_projectile_fire(get_ranged_target_turf(src, dir, 10), src, /obj/item/projectile/fire_breath, 'sound/weapons/flamethrower.ogg', src)
			if(environment)
				environment.add_thermal_energy(350000)
		if(2) //Fire blast
			new /obj/effect/ring_of_fire(get_turf(src), range(src,4)-range(src,3), 3 SECONDS)
			if(environment)
				environment.add_thermal_energy(700000)

/mob/living/simple_animal/hostile/asteroid/magmaw/CanAttack(var/atom/the_target)
	if(world.time < fire_time)
		return
	if(istype(the_target, /obj/item/stack/ore/plasma) || istype(the_target, /obj/item/stack/sheet/mineral/plasma))
		return 1
	if(istype(the_target, /turf/unsimulated/mineral))
		var/turf/unsimulated/mineral/M = the_target
		if(M.mineral && istype(M.mineral.ore, /obj/item/stack/ore/plasma))
			return 1
	return 0

/mob/living/simple_animal/hostile/asteroid/magmaw/EscapeConfinement()
	if(world.time < fire_time) //Not hungry enough to go smashing up asteroids yet
		return
	..()

/mob/living/simple_animal/hostile/asteroid/magmaw/UnarmedAttack(var/atom/A, var/proximity, var/params)
	if(proximity == 0)
		return
	var/is_ore = istype(A, /obj/item/stack/ore/plasma)
	var/is_sheet = istype(A, /obj/item/stack/sheet/mineral/plasma)
	if(is_ore || is_sheet)
		visible_message("<span class = 'warning'>\The [src] eats \the [A]!</span>")
		if(is_ore)
			fire_time = world.time + 25 SECONDS
			fire_extremity = 1
		else if(is_sheet)
			fire_time = world.time + 90 SECONDS
			fire_extremity = 2
		var/obj/item/stack/sheet/S = A
		S.use(1)
		return
	return ..()

/mob/living/simple_animal/hostile/asteroid/rockernaut
	name = "rockernaut"
	desc = "While a rolling stone may gather no moss, a spinning asteroid may gather semi-sentient moss in the form of a Rockernaut infestation."
	icon_state = "rocknormal"
	icon_living = "rocknormal"
	icon_aggro = "rockcrikey"
	icon_attack = "rocknormal_to_crikey"
	icon_attack_time = 5
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS
	attack_sound = 'sound/weapons/heavysmash.ogg'
	move_to_delay = 20
	melee_damage_lower = 30
	melee_damage_upper = 30
	maxHealth = 350
	health = 350
	vision_range = 7
	speed = 4
	var/possessed_ore

/mob/living/simple_animal/hostile/asteroid/rockernaut/Life()
	.=..()
	if(!.)
		return 0

	if(stance == HOSTILE_STANCE_IDLE && !client)
		var/list/can_see = view(get_turf(src), vision_range/2)

		for(var/turf/unsimulated/mineral/M in can_see)
			if(!M.mineral)
				continue
			if(M.rockernaut)
				continue
			if(Adjacent(M))
				//Climb in
				visible_message("<span class = 'warning'>\The [src] burrows itself into \the [M]!</span>")
				M.rockernaut = istype(src, /mob/living/simple_animal/hostile/asteroid/rockernaut/boss) ? TURF_CONTAINS_BOSS : TURF_CONTAINS_ROCKERNAUT
				qdel(src)
				return
			else
				if(prob(30))
					step_towards(src, M)//Step towards it
					if(environment_smash_flags & SMASH_LIGHT_STRUCTURES)
						EscapeConfinement()
				break


/mob/living/simple_animal/hostile/asteroid/rockernaut/death()
	..()
	visible_message("<span class = 'warning'>\The [src] collapses into a mound of loose rock[possessed_ore?", revealing glittering ore within!":"."]</span>")
	drop_loot()
	qdel(src)

/mob/living/simple_animal/hostile/asteroid/rockernaut/proc/drop_loot()
	if(possessed_ore)
		for(var/i = 0 to rand(3,9))
			new possessed_ore(src.loc)

	if(prob(1))
		new /obj/item/weapon/vinyl/rock(src.loc) //It is a rock monster after all

	for(var/i = 0 to rand(0,3))
		new /obj/item/weapon/strangerock(src.loc, get_random_find())
	new /obj/structure/boulder(src.loc)

/mob/living/simple_animal/hostile/asteroid/rockernaut/attack_icon()
	return image(icon = 'icons/mob/attackanims.dmi', icon_state = "rockernaut")

/mob/living/simple_animal/hostile/asteroid/rockernaut/boss
	name = "Angie"
	size = SIZE_HUGE
	maxHealth = 900
	move_to_delay = 60
	health = 900
	pixel_y = 16 * PIXEL_MULTIPLIER
	melee_damage_lower = 35
	melee_damage_upper = 50
	ranged = 1
	status_flags = CANSTUN|CANKNOCKDOWN|CANPARALYSE|CANPUSH|UNPACIFIABLE
	var/charging = 0

/mob/living/simple_animal/hostile/asteroid/rockernaut/boss/New()
	..()
	appearance_flags |= PIXEL_SCALE
	var/matrix/M = matrix()
	M.Scale(2,2)
	transform = M

/mob/living/simple_animal/hostile/asteroid/rockernaut/boss/drop_loot()
	if(possessed_ore)
		for(var/i = 0 to rand(24,46))
			new possessed_ore(src.loc)

	new /obj/item/weapon/vinyl/filk(src.loc) //The music of the asteroid~

	for(var/i = 0 to rand(5,13))
		new /obj/item/weapon/strangerock(src.loc, get_random_find())
	new /obj/item/clothing/gloves/mining(src.loc)
	new /obj/structure/boulder(src.loc)

/mob/living/simple_animal/hostile/asteroid/rockernaut/boss/MoveToTarget()
	if(charging)
		return
	..()

/mob/living/simple_animal/hostile/asteroid/rockernaut/boss/Goto(var/target, var/delay, var/minimum_distance)
	if(charging && !isturf(target))
		return
	..()

/mob/living/simple_animal/hostile/asteroid/rockernaut/boss/OpenFire(target)
	set waitfor = FALSE
	if(charging)
		return
	walk(src, 0)
	var/distance = get_dist(src, target)+rand(1,4)
	var/turf/T = get_ranged_target_turf(target, get_dir(src, target), distance)
	var/frustration = 0
	ranged_cooldown = ranged_cooldown_cap
	visible_message("<span class = 'warning'>\The [src] charges at \the [target]!</span>")
	charging = TRUE
	move_to_delay = 3
	set_glide_size(DELAY2GLIDESIZE(move_to_delay))
	while(get_turf(src) != T && frustration < distance)
		for(var/mob/living/M in view(src))
			if(!M.client)
				continue
			var/int_distance = get_dist(M, src)
			shake_camera(M, 5, 2/int_distance)
		step_towards(src, T, 3)
		frustration++
		sleep(move_to_delay)

	charging = FALSE
	move_to_delay = initial(move_to_delay)
	set_glide_size(DELAY2GLIDESIZE(move_to_delay))

/mob/living/simple_animal/hostile/asteroid/rockernaut/boss/to_bump(atom/A)
	..()
	if(charging && istype(A, /mob/living))
		var/mob/living/M = A
		UnarmedAttack(M)
		visible_message("<span class = 'warning'>\The [src] swats [M] aside!</span>")
		var/turf/T = get_ranged_target_turf(M, get_dir(src,M), size)
		if(istype(T, /turf/space)) // if ended in space, then range is unlimited
			T = get_edge_target_turf(M, dir)
		M.throw_at(T,100,move_to_delay)


/mob/living/simple_animal/hostile/asteroid/pillow
	name = "pillow bug"
	desc = "An odd creature, bearing a resemblance to the common earth tick, but with flicks of light blue fur."
	health = 20
	maxHealth = 20
	melee_damage_lower = 0
	melee_damage_upper = 0
	icon_state = "pillow"
	icon_aggro = "pillow"
	icon_living = "pillow"
	icon_dead = "pillow_dead"
	holder_type = /obj/item/weapon/holder/animal/pillow
	size = SIZE_SMALL
	pacify_aura = TRUE
	environment_smash_flags = 0
	var/image/eyes

/mob/living/simple_animal/hostile/asteroid/pillow/no_pacify
	pacify_aura = FALSE
	response_help = "pets"

/mob/living/simple_animal/hostile/asteroid/pillow/examine(mob/user)
	..()
	if(!isDead() && pacify_aura)
		to_chat(user, "<span class = 'notice'>It looks so comforting, you feel like the world, at least in the general vicinity, is at peace.</span>")

/mob/living/simple_animal/hostile/asteroid/pillow/New()
	..()
	eyes = image(icon,"pillow_eyes", ABOVE_LIGHTING_LAYER)
	eyes.plane = ABOVE_LIGHTING_PLANE
	overlays += eyes

/mob/living/simple_animal/hostile/asteroid/pillow/death()
	overlays.Cut()
	..()

/mob/living/simple_animal/hostile/retaliate/goat/wooly
	name = "wooly goat"
	desc = "An absolutely fierce-tempered beast that prefers cold climates. It has a very tough hide."
	icon_state = "woolygoat"
	icon_living = "woolygoat"
	icon_dead = "woolygoat_dead"
	gives_milk = FALSE
	health = 120
	maxHealth = 120
	anger_chance = 4 //4% per tick to get angry
	faction = "mining"

/mob/living/simple_animal/hostile/retaliate/goat/wooly/New()
	..()
	gender = pick(MALE,FEMALE)
	gives_milk = (FEMALE ? TRUE : FALSE)

/mob/living/simple_animal/hostile/scarybat/cave
	name = "cave bats"
	desc = "A nasty horde of bloodsuckers. They're extra tough."
	faction = "mining"
	health = 60
	maxHealth = 60
