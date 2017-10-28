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

/mob/living/simple_animal/hostile/humanoid/kitchen/poutine/bullet_act(var/obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/beam))
		P.damage /= rand(1.2,3)
		if(prob(45))
			visible_message("<span class = 'warning'>\The [P] has a reduced effect on \the [src]!</span>")

	return (..(P))

/mob/living/simple_animal/hostile/humanoid/kitchen/poutine/Die()
	for(var/i=0;i<3;i++)
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
	stat_attack = 1
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
			visible_message("<span class='danger'>\The [src] bites down into [H]'s neck!</span>")
			lock_atom(H, /datum/locking_category/vampire_latch)
		if(H.locked_to == src)
			if(H.vessel.get_reagent_amount(BLOOD) < 50)
				unlock_from()
			else
				H.vessel.remove_reagent(BLOOD, rand(5,10))
				health = max(maxHealth*2, health+=rand(5,10)) //Can overheal
			return
	..()

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
	for(var/mob/living/carbon/C in oview(1, src))
		if(!C.vampire_affected())
			continue
		if(istype(C))
			close_mobs |= C
	for(var/mob/living/carbon/C in oview(3, src))
		if(!C.vampire_affected())
			continue
		if(istype(C))
			dist_mobs |= C
	dist_mobs -= close_mobs
	for(var/mob/living/carbon/C in close_mobs)
		C.Stun(8)
		C.Knockdown(8)
		C.stuttering += 20
		if(!C.blinded)
			C.blinded = 1
		C.blinded += 5
	for(var/mob/living/carbon/C in dist_mobs)
		var/distance_value = max(0, abs((get_dist(C, src)-3)) + 1)
		C.Stun(distance_value)
		if(distance_value > 1)
			C.Knockdown(distance_value)
		C.stuttering += 5+distance_value *2
		if(!C.blinded)
			C.blinded = 1
		C.blinded += max(1, distance_value)
	to_chat((dist_mobs + close_mobs), "<span class='warning'>You are blinded by \the [src]'s glare</span>")


/mob/living/simple_animal/hostile/humanoid/vampire/proc/jaunt_away()
	update_latch()
	retreating = 1
	new /mob/living/simple_animal/hostile/scarybat(src.loc, src)
	walk_away(src, get_turf(src), rand(10,15), move_to_delay)
	ethereal_jaunt(src, 5 SECONDS, "batify", "debatify", 0)
	spawn(5 SECONDS)
		retreating = 0

/mob/living/simple_animal/hostile/humanoid/vampire/Die()
	visible_message("<span class='warning'>\The [src] lets out one last ear piercing shriek, before collapsing into dust!</span>")
	for(var/mob/living/carbon/C in hearers(4, src))
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(H.earprot())
				continue
		if(!C.vampire_affected())
			continue
		to_chat(C, "<span class='danger'><font size='3'>You hear a ear piercing shriek and your senses dull!</font></span>")
		C.Knockdown(8)
		C.ear_deaf = 20
		C.stuttering = 20
		C.Stun(8)
		C.Jitter(150)
	for(var/obj/structure/window/W in view(4, src))
		W.Destroy(brokenup = 1)
	playsound(src.loc, 'sound/effects/creepyshriek.ogg', 100, 1)

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

/mob/living/simple_animal/hostile/blood_splot/Move()
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

/mob/living/simple_animal/hostile/gremlin/greytide/electrocute_act()
	return //Gremtide cometh

/mob/living/simple_animal/hostile/gremlin/greytide/adjustBruteLoss()
	..()
	if(prob(30*(maxHealth/health)))
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
	..()

/mob/living/simple_animal/hostile/humanoid/supermatter/UnarmedAttack(atom/A)
	if(isliving(A))
		var/mob/living/M = A
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
							if(!M.gcDestroyed)
								M.supermatter_act(src, SUPERMATTER_DUST)
								empulse(get_turf(M), 2, 4, 1)
								new /turf/unsimulated/wall/supermatter/no_spread/lake(get_turf(M))

/mob/living/simple_animal/hostile/humanoid/supermatter/to_bump(atom/Obstacle)
	if((istype(Obstacle, /turf/unsimulated/wall/supermatter) || istype(Obstacle, /obj/machinery/power/supermatter)) && !throwing)
		return

	return ..()

/mob/living/simple_animal/hostile/humanoid/supermatter/Die()
	animate(src, alpha = 0, time = 2 SECONDS, easing = SINE_EASING)
	spawn(2 SECONDS)
		empulse(get_turf(src), 6, 12, 1)
		qdel(src)


