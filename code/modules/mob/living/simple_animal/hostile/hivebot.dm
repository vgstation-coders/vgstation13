/obj/item/projectile/hivebotbullet
	damage = 10
	damage_type = BRUTE

/mob/living/simple_animal/hostile/hivebot
	name = "Hivebot"
	desc = "A big robot."
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	health = 15
	maxHealth = 15
	melee_damage_lower = 2
	melee_damage_upper = 3
	attacktext = "claws"
	projectilesound = 'sound/weapons/Gunshot.ogg'
	projectiletype = /obj/item/projectile/hivebotbullet
	can_butcher = 0
	faction = "hivebot"
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	speed = 4
	size = SIZE_BIG
	meat_type = null

	mob_property_flags = MOB_ROBOTIC

/mob/living/simple_animal/hostile/hivebot/range
	name = "Ranged Hivebot"
	desc = "A biggish robot. This one has a gun!"
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/rapid
	name = "Rapidfire Hivebot"
	desc = "A biggish robot. This one has an automatic submachine gun!"
	ranged = 1
	rapid = 1
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/strong
	name = "Strong Hivebot"
	desc = "A robot, this one is armed and looks tough!"
	health = 80
	ranged = 1

/mob/living/simple_animal/hostile/hivebot/emp_act(severity)
	if(flags & INVULNERABLE)
		return

	switch (severity)
		if (1)
			adjustBruteLoss(30)

		if (2)
			adjustBruteLoss(10)

/mob/living/simple_animal/hostile/hivebot/death(var/gibbed = FALSE)
	..(TRUE)
	visible_message("<b>[src]</b> blows apart!")
	new /obj/effect/gibspawner/robot(src.loc)
	qdel(src)
	return

/mob/living/simple_animal/hostile/hivebot/tele//this still needs work
	name = "Beacon"
	desc = "Some odd beacon thing"
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "def_radar-off"
	icon_living = "def_radar-off"
	health = 200
	maxHealth = 200
	status_flags = UNPACIFIABLE
	anchored = 1
	stop_automated_movement = 1
	var/bot_type = "norm"
	var/bot_amt = 10
	var/spawn_delay = 600
	var/turn_on = 0
	var/auto_spawn = 1


/mob/living/simple_animal/hostile/hivebot/tele/New()
	..()
	var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
	smoke.set_up(5, 0, src.loc)
	smoke.start()
	visible_message("<span class='danger'>The [src] warps in!</span>")
	playsound(src, 'sound/effects/EMPulse.ogg', 25, 1)

/mob/living/simple_animal/hostile/hivebot/tele/proc/warpbots()
	icon_state = "def_radar"
	visible_message("<span class='warning'>The [src] turns on!</span>")
	while(bot_amt > 0)
		bot_amt--
		switch(bot_type)
			if("norm")
				new /mob/living/simple_animal/hostile/hivebot(get_turf(src))
			if("range")
				new /mob/living/simple_animal/hostile/hivebot/range(get_turf(src))
			if("rapid")
				new /mob/living/simple_animal/hostile/hivebot/rapid(get_turf(src))
	spawn(100)
		qdel(src)
	return


/mob/living/simple_animal/hostile/hivebot/tele/Life()
	..()
	if(stat == 0)
		if(prob(2))//Might be a bit low, will mess with it likely
			warpbots()
