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
	minimum_distance = 3
	ranged_message = null
	faction = "skeleton"
	corpse = null
	items_to_drop = list(/obj/item/clothing/head/wizard/skelelich, /obj/effect/decal/remains/human)

	var/magic_range = 5
	var/firing = FALSE

/mob/living/simple_animal/hostile/humanoid/skellington/lich/getarmor(var/def_zone, var/type)
	var/list/armor = list(melee = 30, bullet = 20, laser = 20,energy = 20, bomb = 20, bio = 20, rad = 20)
	return armor[type]

/mob/living/simple_animal/hostile/humanoid/skellington/lich/getarmorabsorb()
	return 15

/mob/living/simple_animal/hostile/humanoid/skellington/lich/electrocute_act()
	return 0

/mob/living/simple_animal/hostile/humanoid/skellington/lich/Life()
	..()
	if(!isDead()) //It's a skeleton, how
		for(var/mob/living/simple_animal/hostile/humanoid/skellington/S in view(src, magic_range))
			if(S == src || S.type == type) //No eating other liches
				continue
			if(S.health < S.maxHealth)
				if(prob(10))
					playsound(S, get_sfx("soulstone"), 50,1)
				if(prob(35))
					make_tracker_effects(src, S)
				S.health = min(S.maxHealth, S.health+rand(S.maxHealth/6,S.maxHealth/3))

			if(health < maxHealth/2)
				visible_message("<span class = 'warning'>\The [src] makes a fist with its skeletal hands, and \the [S] turns to dust.</span>")
				health = min(maxHealth, health+S.health)
				make_tracker_effects(S, src)
				playsound(S, get_sfx("soulstone"), 50,1)
				S.dust()

			if(target && S.target != target)
				S.GiveTarget(target)

/mob/living/simple_animal/hostile/humanoid/skellington/lich/Shoot(atom/a, params)
	if(firing)
		return 0 //We're already doing something
	var/spell = rand(1,5)
	var/diceroll = rand(1,20)
	var/list/victims = list()
	for(var/mob/living/H in view(src, magic_range))
		victims.Add(H)

	if(!victims.len)
		return 0
	switch(spell)
		if(1) //Mass Hallucination
			for(var/mob/living/L in victims)
				if(L.isDead())
					continue
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					if(H.head && istype(H.head,/obj/item/clothing/head/tinfoil))
						continue
				if(M_PSY_RESIST in L.mutations)
					continue
				to_chat(L, "<span class = 'warning'>You feel [diceroll>10 ? "incredibly" : ""] disorientated.</span>")
				L.hallucination += rand(5,10)*diceroll
				if(diceroll > 10)
					L.confused += (rand(5,10)/10)*diceroll
				if(diceroll >= 20)
					L.dizziness += rand(5,10)
				L.flash_pain() //Little more user feedback
		if(2) //Disarm
			var/number_of_disarmed = min(3, victims.len)
			var/success = FALSE
			for(var/mob/living/L in victims)
				if(number_of_disarmed <= 0)
					break
				if(L.isDead())
					continue
				if(L.held_items)
					for(var/obj/item/I in held_items)
						if(L.drop_item(I, force_drop = 1))
							success = TRUE
							to_chat(L, "<span class = 'warning'>\The [I] is pulled from your grasp!</span>")
							I.throw_at(get_edge_target_turf(target, pick(alldirs)),15,1)
					number_of_disarmed--
			if(!success)
				return 0
		if(3) //Soul Swarm
			firing = TRUE
			visible_message("<span class = 'warning'>\The [src] starts to float above the ground!</span>")
			animate(src, pixel_y = 8, time = 1 SECONDS, easing = ELASTIC_EASING)
			animate(pixel_y = rand(8,19), pixel_x = rand(-8,8), time = 3 SECONDS, easing = SINE_EASING, loop = 5)
			for(var/i = 0 to round(diceroll/2,4))
				if(isDead() || gcDestroyed)
					break
				var/mob/living/carbon/human/mtarget = pick(victims)
				if(mtarget.isDead())
					continue
				to_chat(mtarget, "<span class = 'warning'>\The [src] summons a soul swarm at you!</span>")
				generic_projectile_fire(mtarget, src, /obj/item/projectile/soul_swarm, null)
				sleep(5)
			firing = FALSE
			animate(src, pixel_y = 0, pixel_x = 0, time = 3 SECONDS, easing = SINE_EASING)
		if(4) //Raise undead
			var/number_of_raised = round(diceroll/3)
			var/success
			for(var/mob/living/carbon/human/H in victims)
				if(number_of_raised <= 0)
					break
				if(!H.isDead())
					continue
				if(H.blessed)
					continue
				number_of_raised--
				if(!isskellington(H))
					new /obj/effect/gibspawner/generic(get_turf(H))
				H.drop_all()
				make_tracker_effects(H, src)
				visible_message("<span class = 'warning'>\The [src] points towards \the [H].</span>")
				H.visible_message("<span class = 'warning'>\The [H] raises from the dead!</span>")
				new /mob/living/simple_animal/hostile/humanoid/skellington(H.loc)
				success = TRUE
				qdel(H)
			if(!success) //Nobody was resurrected, so let's just summon a skeleton
				visible_message("<span class = 'warning'>\The [src] raises its arms, and summons undead from the aether!</span>")
				new /mob/living/simple_animal/hostile/humanoid/skellington(get_step(src, pick(cardinal)))
		if(5) //Fall
			flags |= TIMELESS
			var/duration = min(1 SECONDS, 2*diceroll)
			firing = TRUE
			switch(diceroll)
				if(1 to 10)
					generic_projectile_fire(pick(victims), src, /obj/item/projectile/simple_fireball)
				if(11 to 20)
					for(var/i = 0 to round(diceroll/5))
						var/knifetype = pick(typesof(/obj/item/weapon/kitchen/utensil/knife))
						var/obj/item/knife = new knifetype(get_turf(src))
						knife.throw_at(pick(victims), 15, 3)
			timestop(src, duration, magic_range, FALSE)
			spawn(duration)
				firing = FALSE
				flags &= ~TIMELESS
	playsound(src, 'sound/misc/lich_cast.ogg', 100, 1)
	return 1

/obj/item/projectile/soul_swarm
	name = "soul swarm"
	desc = "It flickers with some rudimentary form of intelligence, but conversation doesn't seem to be the strong point of a magical projectile."
	icon_state = "soul"
	damage = 5
	travel_range = 30
	projectile_speed = 0.5 SECONDS
	fire_sound = 'sound/weapons/magic_blast.ogg'

/obj/item/projectile/soul_swarm/New()
	..()
	irradiate = rand(0,25)
	stutter = rand(0,25)
	eyeblur = rand(0,25)
	drowsy = rand(0,25)
	agony = rand(0,25)
	jittery = rand(0,25)

/obj/item/projectile/soul_swarm/process_step()
	.=..()
	starting = get_turf(src)
	OnFired() //So it reorients itself