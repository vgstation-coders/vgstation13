/*
	Halloween related mobs
*/

/mob/living/simple_animal/hostile/humanoid/kitchen
	faction = "kitchen_nightmares"
	icon = 'icons/mob/hostile_humanoid.dmi'

/mob/living/simple_animal/hostile/humanoid/kitchen/poutine
	name = "poutine titan"
	desc = "When hell came to Canada, Canada sent it right back with their own congealed conglomeration."

	icon_state = "cheese_zombie"

	health = 350
	maxHealth = 350

	move_to_delay = 20
	speed = 5

	melee_damage_lower = 20
	melee_damage_upper = 35
	attacktext = "smashes their cheese-covered gauntlets into"
	attack_sound = 'sound/weapons/heavysmash.ogg'
	corpse = null

/mob/living/simple_animal/hostile/humanoid/kitchen/poutine/New()
	..()
	icon_state = pick("cheese_zombie", "poutinegolem_maple", "poutinegolem_gravy", "poutinegolem_jumper")

/mob/living/simple_animal/hostile/humanoid/kitchen/poutine/bullet_act(var/obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/beam))
		P.damage /= (rand(12,30)/10)
		if(prob(45))
			visible_message("<span class = 'warning'>\The [P] has a reduced effect on \the [src]!</span>")

	return ..(P)

/mob/living/simple_animal/hostile/humanoid/kitchen/poutine/death(var/gibbed = FALSE)
	..(TRUE)
	for(var/i=1 to 3)
		var/to_spawn = pick(/obj/item/weapon/reagent_containers/food/snacks/poutine, /obj/item/weapon/reagent_containers/food/snacks/poutinedangerous,\
							/obj/item/weapon/reagent_containers/food/snacks/poutinebarrel)
		new to_spawn (src.loc)

	new /obj/item/weapon/reagent_containers/food/snacks/mapleleaf(src.loc)
	visible_message("<span class='warning'>\The [src] collapses into a formless heap of melted cheese curd.</span>")
	qdel (src)

/mob/living/simple_animal/hostile/humanoid/kitchen/meatballer
	name = "meatbrawler"
	desc = "An enterprising chef once attempted to create a being that would deliver pasta treats directly to their customers.\
	It did not go according to plan."

	icon_state = "flying_pasta"
	health = 175
	maxHealth = 175

	move_to_delay = 3
	speed = 1

	melee_damage_lower = 10
	melee_damage_upper = 15
	attacktext = "slams tendrils of spaghetti into"
	attack_sound = 'sound/weapons/whip.ogg'
	ranged = 1
	rapid = 1
	retreat_distance = 5
	corpse = null
	projectiletype = /obj/item/projectile/bullet/faggot
	ranged_message = "flings a faggot"


/mob/living/simple_animal/hostile/humanoid/kitchen/meatballer/Shoot(var/atom/target, var/atom/start, var/mob/user, var/bullet = 0)
	animate(src, transform = turn(matrix(), 120), time = 2, loop = 5)
	animate(transform = turn(matrix(), 240), time = 1)
	animate(transform = null, time = 2)
	..()

/mob/living/simple_animal/hostile/humanoid/kitchen/meatballer/adjustBruteLoss(var/damage)
	if(prob(damage*(maxHealth/health)))
		fire_everything()
	..()

/mob/living/simple_animal/hostile/humanoid/kitchen/meatballer/proc/fire_everything()
	set waitfor = 0
	visible_message("<span class = 'warning'>\The [src] starts madly flinging faggots in all directions!</span>")
	var/volleys = rand(2,5)
	friendly_fire = 1
	canmove = 0
	for(var/i = 0,i < volleys, i++)
		for(var/direction in alldirs)
			if(gcDestroyed)
				return
			sleep(rand(1,5))
			var/turf/destination = get_ranged_target_turf(get_turf(src), direction, 10)
			TryToShoot(destination)
	friendly_fire = 0
	canmove = 1

/mob/living/simple_animal/hostile/humanoid/kitchen/meatballer/death(var/gibbed = FALSE)
	..(TRUE)
	for(var/i=1 to 3)
		var/to_spawn = pick(/obj/item/weapon/reagent_containers/food/snacks/spaghetti, /obj/item/weapon/reagent_containers/food/snacks/meatballspaghetti,\
							/obj/item/weapon/reagent_containers/food/snacks/copypasta)
		new to_spawn (src.loc)

	new /obj/item/weapon/reagent_containers/food/snacks/faggot(src.loc)
	visible_message("<span class='warning'>\The [src] falls apart, revealing a solitary faggot among the remains.</span>")
	qdel (src)

/*
	Vampire
		Employs use of glare to stun enemies, grabs them, then feeds.
		When harmed by lasers, turns into bats and teleports somewhere close by
		When it dies, lets out one last chyroptic scream before turning to ash
*/

#define GLARE_COOLDOWN 30 SECONDS
#define JAUNT_COOLDOWN 35 SECONDS

/mob/living/simple_animal/hostile/humanoid/vampire
	name = "vampire"
	desc = "The blood is the life!"
	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "vampire"

	health = 150
	maxHealth = 150

	move_to_delay = 3
	speed = 1

	melee_damage_lower = 10
	melee_damage_upper = 15
	attacktext = "slaps"
	attack_sound = 'sound/weapons/punchmiss.ogg'

	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG | OPEN_DOOR_SMART // Vampeers can smash many things and open doors
	stat_attack = UNCONSCIOUS // Even if it's unconscious, it still has blood! Blah blah blah!

	var/last_glare
	var/last_jaunt
	var/retreating = 0
	corpse = null

/mob/living/simple_animal/hostile/humanoid/vampire/AttackingTarget()
	if(!target)
		return

	if(world.time > last_glare + GLARE_COOLDOWN)
		glare()
		last_glare = world.time
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.lying && !H.locked_to)
			spawn(2 SECONDS) // Wait a second, otherwise the transition is too abrupt
				if(H.lying && !H.locked_to)
					visible_message("<span class='danger'>\The [src] bites down into [H]'s neck!</span>")
					lock_atom(H, /datum/locking_category/vampire_latch)
		if(H.locked_to == src)
			if(H.vessel.get_reagent_amount(BLOOD) < 50)
				unlock_atom(H)
			else
				H.vessel.remove_reagent(BLOOD, rand(5,10))
				health = max(maxHealth*2, health+=rand(5,10)) //Can overheal
			return
	..()

/mob/living/simple_animal/hostile/humanoid/vampire/relaymove(mob/user)// Allows a player to resist out of the vampire's grip. Takes strength from mutations and other sources into account (Copied from grey nurse code)
	var/mob/living/carbon/human/H = user
	if(istype(H))
		if(user.incapacitated()) // Can't resist when stunned or unconscious
			return

		if(H.get_strength() > 2) // Are we TOO SWOLE TO CONTROL?! Breaking free is guaranteed!
			to_chat(user, "<span class='warning'>You start to loosen the [src]'s weak grip!</span>")
			if(do_after(user, src, 10)) // 1 second resist time, 100% chance of success
				to_chat(user, "<span class='warning'>You force the [src]'s teeth off your neck with minimal effort, freeing yourself!</span>")
				unlock_atom(H)

		if(H.get_strength() == 2) // Are we stronger than average due to a mutation or other bonus? Boost resistance chance!
			to_chat(user, "<span class='warning'>You struggle furiously against the [src]'s grip!</span>")
			if(do_after(user, src, 10)) // 1 second resist time, 60% chance of success
				if(prob(40))
					to_chat(user, "<span class='warning'>The [src] manages to keep their hold on you! Their teeth are still firmly lodged in your neck!</span>")
				else
					to_chat(user, "<span class='warning'>You yank the [src]'s teeth out of your neck with a mighty effort and shove them away, freeing yourself!</span>")
					unlock_atom(H)

		if(H.get_strength() < 2) // Are we just average strength? We get the lowest chance of successfully escaping
			to_chat(user, "<span class='warning'>You struggle to get free of the [src]'s bloodsucking latch!</span>")
			if(do_after(user, src, 10)) // 1 second resist time, 35% chance of success with no other modifiers
				if(prob(65))
					to_chat(user, "<span class='warning'>You fail to get free of the [src]'s grip, and they only bite down on your neck harder!</span>")
				else
					to_chat(user, "<span class='warning'>You manage to pry the [src]'s teeth off your neck, freeing yourself!</span>")
					unlock_atom(H)

/mob/living/simple_animal/hostile/humanoid/vampire/Life()
	..()
	if(locked_atoms)
		update_latch()


/mob/living/simple_animal/hostile/humanoid/vampire/CanAttack(var/atom/the_target)
	if(retreating)
		return 0
	return ..(the_target)

/mob/living/simple_animal/hostile/humanoid/vampire/proc/update_latch()
	for(var/mob/living/L in locked_atoms)
		if(!istype(L))
			return unlock_atom(L)

		if(incapacitated())
			return unlock_atom(L)

		if(!CanAttack(L))
			return unlock_atom(L)

		if(retreating)
			return unlock_atom(L)

/mob/living/simple_animal/hostile/humanoid/vampire/adjustBruteLoss(var/damage)
	if(!isDead() && prob(damage*(maxHealth/health)) && world.time > last_jaunt + JAUNT_COOLDOWN)
		last_jaunt = world.time
		jaunt_away()
	..()

/datum/locking_category/vampire_latch

/mob/living/simple_animal/hostile/humanoid/vampire/proc/glare()
	visible_message("<span class='danger'>\The [src]'s eyes emit a blinding flash!</span>")
	var/list/close_mobs = list()
	var/list/dist_mobs = list()
	for(var/mob/living/carbon/human/H in view(1, src))
		if((H.vampire_affected() <= 0) || H.is_blind())
			continue
		if(istype(H))
			close_mobs |= H
	for(var/mob/living/carbon/human/H in view(3, src))
		if((H.vampire_affected() <= 0) || H.is_blind())
			continue
		if(istype(H))
			dist_mobs |= H
	dist_mobs -= close_mobs
	for(var/mob/living/carbon/human/H in close_mobs)
		H.Stun(8)
		H.Knockdown(8)
		H.stuttering += 20
		H.flash_eyes()
	for(var/mob/living/carbon/human/H in dist_mobs)
		var/distance_value = max(0, abs((get_dist(H, src)-3)) + 1)
		H.Stun(distance_value)
		if(distance_value > 1)
			H.Knockdown(distance_value)
			H.Stun(distance_value)
		H.stuttering += 5+distance_value *2
		H.flash_eyes()
	to_chat((dist_mobs + close_mobs), "<span class='warning'>You are blinded by \the [src]'s glare!</span>")

/mob/living/simple_animal/hostile/humanoid/vampire/proc/jaunt_away()
	update_latch()
	retreating = 1
	new /mob/living/simple_animal/hostile/scarybat(src.loc, src)
	walk_away(src, get_turf(src), rand(10,15), move_to_delay)
	ethereal_jaunt(src, 5 SECONDS, "batify", "debatify", 0)
	spawn(5 SECONDS)
		retreating = 0

/mob/living/simple_animal/hostile/humanoid/vampire/death(var/gibbed = FALSE)
	visible_message("<span class='warning'>\The [src] lets out one last ear piercing shriek, before collapsing into dust!</span>")
	playsound(src.loc, 'sound/effects/creepyshriek.ogg', 100, 1)
	for(var/mob/living/carbon/human/H in view(7, src))
		if((H.vampire_affected() <= 0) || H.earprot())
			continue
		to_chat(H, "<span class='danger'><font size='3'>You hear an ear piercing shriek and your senses dull!</font></span>")
		H.Knockdown(8)
		H.ear_deaf = 20
		H.stuttering = 20
		H.Stun(8)
		H.Jitter(150)
	for(var/obj/structure/window/W in view(4, src))
		W.shatter()

	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-h", sleeptime = 15)

	new /obj/effect/decal/remains/human(loc)
	qdel(src)

#undef GLARE_COOLDOWN
#undef JAUNT_COOLDOWN


/mob/living/simple_animal/hostile/blood_splot
	name = "giant floating droplet of blood"
	desc = "From countless uncleaned medical bays, this nightmare to janitors was born. Existing only to spread mess."
	icon_state = "blood"
	density = 0
	retreat_distance = 3

/mob/living/simple_animal/hostile/blood_splot/AttackingTarget()
	return

/mob/living/simple_animal/hostile/blood_splot/adjustBruteLoss()
	return

/mob/living/simple_animal/hostile/blood_splot/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	..()
	var/turf/T = get_turf(src)
	var/blood_found
	for(var/obj/effect/decal/cleanable/C in T)
		if(C.counts_as_blood)
			blood_found = 1
			break
	if(!blood_found)
		new /obj/effect/decal/cleanable/blood(T)


/mob/living/simple_animal/hostile/blood_splot/reagent_act(id, method, volume)
	if(isDead())
		return

	switch(id)
		if(WATER, HOLYWATER, CLEANER, BLEACH)
			gib(meat = 0)


/mob/living/simple_animal/hostile/gremlin/greytide
	name = "greymlin"
	desc = "While others saw gremlins as a force of chaos that needed to be annhiliated, others saw gremlins as \
	brothers in arms, and dressed them in similar attire."
	icon_state = "gremtide"
	icon_living = "gremtide"
	icon_dead = "gremtide_dead"
	health = 25
	maxHealth = 25

	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_sound = 'sound/weapons/toolbox.ogg'
	attacktext = "robusts"

	var/annoyed = 0

/mob/living/simple_animal/hostile/gremlin/greytide/attack_icon()
	return image(icon = 'icons/obj/storage/storage.dmi', icon_state = "toolbox_blue")

/mob/living/simple_animal/hostile/gremlin/greytide/electrocute_act()
	return //Gremtide cometh

/mob/living/simple_animal/hostile/gremlin/greytide/adjustBruteLoss()
	..()
	if(!isDead() && prob(30*(maxHealth/health)))
		visible_message("<span class = 'warning'>\The [src] looks to be annoyed!</span>")
		annoyed = 1
		spawn(rand(15 SECONDS, 45 SECONDS))
			annoyed = 0
			LostTarget()

/mob/living/simple_animal/hostile/gremlin/greytide/AttackingTarget()
	if(annoyed && isliving(target))
		UnarmedAttack(target)
	else
		..()

/mob/living/simple_animal/hostile/humanoid/supermatter
	name = "supermatter shade"
	desc = "The end result of carbon-based lifeforms who obsess over the supermatter shard for too long. What was once a Chief Engineer, twisted into something else."

	icon_state = "supermatter_shade"
	icon = 'icons/mob/hostile_humanoid.dmi'

	health = 250
	maxHealth = 250

	move_to_delay = 15
	speed = 3

	light_color = LIGHT_COLOR_YELLOW

	melee_damage_lower = 15
	melee_damage_upper = 25
	attacktext = "focuses themselves at"
	attack_sound = 'sound/effects/glass_step.ogg'
	minbodytemp = 0
	maxbodytemp = 4000
	min_oxy = 0
	max_co2 = 0
	max_tox = 0

	corpse = null

/mob/living/simple_animal/hostile/humanoid/supermatter/New()
	..()
	set_light(2, 1)

/mob/living/simple_animal/hostile/humanoid/supermatter/CanAttack(var/atom/the_target)
	if(isliving(the_target))
		var/mob/living/M = the_target
		M.apply_radiation(rand(melee_damage_lower,melee_damage_upper), RAD_EXTERNAL)
	return ..(the_target)

/mob/living/simple_animal/hostile/humanoid/supermatter/UnarmedAttack(var/atom/the_target)
	if(isliving(the_target))
		var/mob/living/M = the_target
		M.apply_radiation(rand(melee_damage_lower*2,melee_damage_upper*3), RAD_EXTERNAL)
		switch(M.radiation)
			if(0 to 90)
				if(prob(20))
					to_chat(M, pick("<span class='warning'>Something shifts inside you...</span>", "<span class='warning'>You feel different, somehow...</span>"))
			if(91 to 500)
				if(prob(40))
					to_chat(M, pick("<b><span class='warning'>Your body lurches!</b></span>"))
				if(prob(5))
					M.apply_radiation(rand(50,150), RAD_INTERNAL)
			if(500 to INFINITY)
				if(prob(5+(M.radiation/100)))
					to_chat(M, pick("<b><span class='warning'>You feel like your body is breaking itself apart!</b></span>"))
					if(prob(50))
						visible_message("<span class = 'warning'>\The [src] grabs onto \the [M]!</span>")
						spawn(rand(15 SECONDS, 35 SECONDS))
							if(M && !M.gcDestroyed)
								var/turf/T = get_turf(M)
								empulse(T, 2, 4, 1)
								new /turf/unsimulated/wall/supermatter/no_spread/lake(T)
								M.supermatter_act(src, SUPERMATTER_DUST)
	else
		..()


/mob/living/simple_animal/hostile/humanoid/supermatter/to_bump(atom/Obstacle)
	if((istype(Obstacle, /turf/unsimulated/wall/supermatter) || istype(Obstacle, /obj/machinery/power/supermatter)) && !throwing)
		return

	return ..()

/mob/living/simple_animal/hostile/humanoid/supermatter/death(var/gibbed = FALSE)
	set waitfor = 0
	..(TRUE)
	animate(src, alpha = 0, time = 2 SECONDS, easing = SINE_EASING)
	sleep(3 SECONDS)
	empulse(get_turf(src), 6, 12, 1)
	qdel(src)


/mob/living/simple_animal/hostile/syphoner
	name = "syphoner"
	desc = "What happens when a roboticist gets impatient with their cell recharger. This mixture of scrap metal, wires, and light bulbs \
	 latches itself onto any bare cable it can find, and inefficiently syphons from the power grid to charge the cell it carries."

	icon_state = "syphoner"
	icon_living = "syphoner"
	icon_dead = "syphoner_dead"

	health = 30
	maxHealth = 120

	move_to_delay = 15
	speed = 4

	environment_smash_flags = 0

	search_objects = 1
	var/obj/item/weapon/cell/cell = null
	var/datum/power_connection/consumer/cable/power_connection = null
	var/latched = 0
	var/draining = 0 //How much we're attempting to drain from the powernet

/mob/living/simple_animal/hostile/syphoner/New()
	. = ..()
	cell = new /obj/item/weapon/cell/super/empty(src)
	power_connection = new(src)
	power_connection.power_priority = POWER_PRIORITY_BYPASS

/mob/living/simple_animal/hostile/syphoner/Destroy()
	if(power_connection)
		QDEL_NULL(power_connection)
	. = ..()

/mob/living/simple_animal/hostile/syphoner/get_cell()
	return cell

/mob/living/simple_animal/hostile/syphoner/update_icon()
	if(latched)
		icon_living = "syphoner_syphoning"
		icon_state = "syphoner_syphoning"
	else
		icon_living = "syphoner"
		icon_state = "syphoner"

/mob/living/simple_animal/hostile/syphoner/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	..()
	if(prob(30))
		if(istype(src.loc, /turf/simulated/floor))
			var/turf/simulated/floor/F = src.loc
			if(F.is_plating())
				return
			if(prob(15))
				visible_message("<span class = 'warning'>\The [src] pries up \the [F]!</span>")
			F.floor_tile.forceMove(src)
			F.floor_tile = null
			F.make_plating()

/mob/living/simple_animal/hostile/syphoner/CanAttack(var/atom/the_target)
	if(!cell && istype(the_target, /obj/item/weapon/cell))
		var/obj/item/weapon/cell/C = the_target
		if(C.percent() < 100)
			return 1
	if(cell && cell.percent() >= 100)
		visible_message("<span class = 'notice'>\The [src] ejects \the [cell]!</span>")
		cell.forceMove(get_turf(src))
		cell = null
	if(istype(the_target, /obj/structure/cable))
		var/obj/structure/cable/C = the_target
		if(C.powernet && C.powernet.avail > 0)
			if(latched && locked_to && locked_to == C)
				return 1
			if(!latched)
				return 1
		else if((!C.powernet || C.powernet.avail <= 0) && locked_to == C)
			unlatch()

	return 0

/mob/living/simple_animal/hostile/syphoner/AttackingTarget()
	if(istype(target, /obj/structure/cable))
		var/obj/structure/cable/C = target
		if(latched && locked_to && locked_to == C)
			var/datum/powernet/PN = power_connection.get_powernet()
			if(cell && PN && PN.avail > 0 && cell.percent() < 100)
				cell.give(draining * power_connection.get_satisfaction()/10)
				draining = rand(500,1500)
				power_connection.add_load(draining)
			else
				visible_message("<span class = 'notice'>\The [src] detaches from \the [C]</span>")
				unlatch()
		else if(!latched)
			visible_message("<span class = 'warning'>\The [src] attaches itself to \the [C]</span>")
			latch_onto(C)
		else if (latched)
			//How did we get here? Let's just quietly unlock and forget all about this
			unlatch()

	if(istype(target, /obj/item/weapon/cell))
		var/obj/item/weapon/cell/C = target
		if(C.percent() < 100)
			visible_message("<span class = 'notice'>\The [src] scoops up \the [C] into its battery compartment.</span>")
			C.forceMove(src)
			cell = C

/mob/living/simple_animal/hostile/syphoner/proc/unlatch()
	latched = 0
	power_connection.disconnect()
	unlock_from()
	update_icon()

/mob/living/simple_animal/hostile/syphoner/proc/latch_onto(var/atom/movable/A)
	if(!istype(A))
		return
	latched = 1
	A.lock_atom(src, /datum/locking_category/cable_lock)
	if (istype(A, /obj/structure/cable))
		power_connection.connect(A)
	update_icon()

/mob/living/simple_animal/hostile/syphoner/death(var/gibbed = FALSE)
	..(TRUE)
	visible_message("<span class = 'warning'>\The [src] explodes!</span>")
	var/turf/T = get_turf(src)
	new /obj/effect/gibspawner/robot(T)
	if(prob(50))
		cell.forceMove(T)
	else
		qdel(cell)
	cell = null
	qdel(src)


/datum/locking_category/cable_lock




/mob/living/simple_animal/hostile/humanoid/skellington/lich
	name = "lich"
	desc = "A being that has become one with his own art, that of Necromancy. Come to consume the souls of those still living \
	in an effort to preserve itself, lest it be consumed by the magic that binds it."

	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "lich"

	health = 300
	maxHealth = 300

	ranged = 1

	retreat_distance = 3

	faction = "skeleton"
	corpse = null
	items_to_drop = list(/obj/item/clothing/head/wizard/skelelich, /obj/effect/decal/remains/human)

	var/magic_range = 5

/mob/living/simple_animal/hostile/humanoid/skellington/lich/Life()
	..()
	if(!isDead()) //It's a skeleton, how
		for(var/mob/living/simple_animal/hostile/humanoid/skellington/S in view(src, magic_range))
			if(S == src)
				continue
			if(S.health < maxHealth)
				if(prob(10))
					playsound(S, get_sfx("soulstone"), 50,1)
				if(prob(35))
					make_tracker_effects(src, S)
				S.health = max(S.maxHealth, S.health+rand(3,6))

			if(health < maxHealth/2)
				visible_message("<span class = 'warning'>\The [src] makes a fist with its skeletal hands, and [S] turns to dust.</span>")
				health = max(maxHealth, health+S.health)
				make_tracker_effects(S, src)
				playsound(S, get_sfx("soulstone"), 50,1)
				S.dust()

			if(target && S.target != target)
				S.GiveTarget(target)

/mob/living/simple_animal/hostile/humanoid/skellington/lich/Shoot(atom/a, params)
	var/spell = rand(1,4)
	var/diceroll = rand(1,20)
	var/list/victims = list()
	for(var/mob/living/carbon/human/H in view(src, magic_range))
		victims.Add(H)

	if(!victims.len)
		return
	switch(spell)
		if(1) //Mass Hallucination
			for(var/mob/living/carbon/human/H in victims)
				if(H.is_wearing_any(list(/obj/item/clothing/head/tinfoil,/obj/item/clothing/head/helmet/stun), slot_head))
					continue
				if(M_PSY_RESIST in H.mutations)
					continue
				to_chat(H, "<span class = 'warning'>You feel [diceroll>15 ? "incredibly" : ""] disorientated.</span>")
				H.hallucination = clamp(rand(10,20)*diceroll, hallucination, 60) //Maximum of 120 seconds
				if(diceroll > 15)
					H.confused = clamp(rand(15,35)*diceroll, confused, 60) //Maximum of 120 seconds
				if(diceroll >= 20)
					H.dizziness = clamp(rand(5,25), dizziness, 30) //Maximum of 60 seconds
		if(2) //Disarm
			var/number_of_disarmed = min(3, victims.len)
			for(var/i = 0 to number_of_disarmed)
				var/mob/living/carbon/human/H = pick(victims)
				for(var/obj/item/I in held_items)
					H.drop_item(I, force_drop = 1)
					to_chat(H, "<span class = 'warning'>\The [I] is pulled from your grasp!</span>")
					I.throw_at(get_edge_target_turf(target, pick(alldirs)),15,1)
				victims.Remove(H)
				if(!victims.len)
					break
		if(3) //Raise undead
			var/number_of_raised = round(diceroll/3)
			for(var/mob/living/carbon/human/H in victims)
				if(!H.isDead())
					continue
				if(H.blessed)
					continue
				if(number_of_raised <= 0)
					break
				number_of_raised--
				if(!isskellington(H))
					new /obj/effect/gibspawner/generic(get_turf(H))
				H.drop_all()
				visible_message("<span class = 'warning'>\The [src] points towards \the [H].</span>")
				H.visible_message("<span class = 'warning'>\The [H] raises from the dead!</span>")
				new /mob/living/simple_animal/hostile/humanoid/skellington(H.loc)
				qdel(H)
		if(4) //Fall
			flags |= TIMELESS
			var/duration = 8*diceroll
			timestop(src, duration, magic_range, TRUE)
			spawn(duration)
				flags &= ~TIMELESS


/mob/living/simple_animal/dracson
	name = "Young Vampire Bat"
	desc = "Whatever happened to my Transylvania Twist?"
	icon = 'icons/mob/animal.dmi'
	icon_state = "scarybat-dance"
	mob_property_flags = MOB_UNDEAD | MOB_SUPERNATURAL

/mob/living/simple_animal/dracson/death(var/gibbed = FALSE)
	..(TRUE)
	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "batify", sleeptime = 15)
	qdel(src)
