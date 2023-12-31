//Space bears!
/mob/living/simple_animal/hostile/bear
	name = "space bear"
	desc = "RawrRawr!!"
	icon_state = "bear"
	icon_living = "bear"
	icon_dead = "bear_dead"
	icon_gib = "bear_gib"
	speak = list("RAWR!","Rawr!","GRR!","Growl!")
	speak_emote = list("growls", "roars")
	emote_hear = list("rawrs","grumbles","grawls")
	emote_see = list("stares ferociously", "stomps")
	var/default_icon_space = "bear"
	var/default_icon_floor = "bearfloor"
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/bearmeat
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	stop_automated_movement_when_pulled = 0
	maxHealth = 60
	health = 60
	attacktext = "mauls"
	melee_damage_lower = 20
	melee_damage_upper = 30
	size = SIZE_BIG
	speak_override = TRUE
	treadmill_speed = 2
	var/obj/item/weapon/reagent_containers/food/snacks/burger = null

	//Space bears aren't affected by atmos.
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	var/stance_step = 0

	faction = "russian"

/mob/living/simple_animal/hostile/bear/Destroy()
	if(burger)
		var/turf/T = get_turf(src)
		if (T)
			burger.forceMove(T)
		else
			qdel(burger)
		burger = null
	..()

//SPACE BEARS! SQUEEEEEEEE~     OW! FUCK! IT BIT MY HAND OFF!!
/mob/living/simple_animal/hostile/bear/Hudson
	name = "Hudson"
	desc = ""
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"

/mob/living/simple_animal/hostile/bear/panda
	name = "space panda"
	desc = "Endangered even in space. A lack of bamboo has driven them somewhat mad."
	icon_state = "panda"
	icon_living = "panda"
	icon_dead = "panda_dead"
	default_icon_floor = "panda"
	default_icon_space = "panda"
	maxHealth = 50
	health = 50
	melee_damage_lower=10
	melee_damage_upper=35

/mob/living/simple_animal/hostile/bear/panda/get_butchering_products()
	return list(/datum/butchering_product/skin/bear/panda, /datum/butchering_product/teeth/lots)

/mob/living/simple_animal/hostile/bear/brownbear
	name = "brown bear"
	desc = "Does it shit in the woods?"
	icon_state = "brownbear"
	icon_living = "brownbear"
	icon_dead = "brownbear_dead"
	default_icon_floor = "brownbear"
	default_icon_space = "brownbear"

	faction = "forest"

/mob/living/simple_animal/hostile/bear/brownbear/get_butchering_products()
	return list(/datum/butchering_product/skin/bear/brownbear, /datum/butchering_product/teeth/lots)

/mob/living/simple_animal/hostile/bear/polarbear
	name = "space polar bear"
	desc = "You'd think that space would be considered cold enough for regular space bears, well these are adapted for even colder climates!"
	icon_state = "polarbear"
	icon_living = "polarbear"
	icon_dead = "polarbear_dead"
	default_icon_floor = "polarbear"
	default_icon_space = "polarbear"
	maxHealth = 75
	health = 75
	melee_damage_lower=10
	melee_damage_upper=40
	faction = "mining"

/mob/living/simple_animal/hostile/bear/polarbear/get_butchering_products()
	return list(/datum/butchering_product/skin/bear/polarbear, /datum/butchering_product/teeth/lots)

/mob/living/simple_animal/hostile/bear/spare
	name = "spare bear"
	desc = "This bear has adapted a form of camouflage from generations of natural selection in which the omnivores scavenge from space stations and their dumpsters. Its golden skin fools card scanners into opening the door."
	health = 300
	maxHealth = 300
	melee_damage_lower = 15
	melee_damage_upper = 35
	icon_state = "sparebear"
	icon_dead = "sparebear_dead"
	default_icon_floor = "sparebear"
	default_icon_space = "sparebear"

/mob/living/simple_animal/hostile/bear/spare/getarmor(var/def_zone, var/type)
	if(type == "laser")
		return 80
	return 10

/mob/living/simple_animal/hostile/bear/spare/getarmorabsorb()
	return 25

/mob/living/simple_animal/hostile/bear/spare/GetAccess()
	return get_all_accesses()

/mob/living/simple_animal/hostile/bear/spare/get_butchering_products()
	return list(/datum/butchering_product/skin/bear/spare, /datum/butchering_product/teeth/lots)

/mob/living/simple_animal/hostile/bear/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	..()
	if(stat != DEAD)
		if(loc && istype(loc,/turf/space))
			icon_state = default_icon_space
		else
			icon_state = default_icon_floor

/mob/living/simple_animal/hostile/bear/get_butchering_products()
	return list(/datum/butchering_product/skin/bear, /datum/butchering_product/teeth/lots)

/mob/living/simple_animal/hostile/bear/Life()
	if(timestopped)
		return 0 //under effects of time magick
	. =..()
	if(!.)
		return

	switch(stance)

		if(HOSTILE_STANCE_TIRED)
			stop_automated_movement = 1
			stance_step++
			if(stance_step >= 10) //rests for 10 ticks
				if(target && (target in ListTargets()))
					stance = HOSTILE_STANCE_ATTACK //If the mob he was chasing is still nearby, resume the attack, otherwise go idle.
				else
					stance = HOSTILE_STANCE_IDLE

		if(HOSTILE_STANCE_ALERT)
			stop_automated_movement = 1
			var/found_mob = 0
			if(target && (target in ListTargets()))
				if(CanAttack(target))
					stance_step = max(0, stance_step) //If we have not seen a mob in a while, the stance_step will be negative, we need to reset it to 0 as soon as we see a mob again.
					stance_step++
					found_mob = 1
					src.dir = get_dir(src,target)	//Keep staring at the mob

					if(stance_step in list(1,4,7)) //every 3 ticks
						var/action = pick( list( "growls at [target]", "stares angrily at [target]", "prepares to attack [target]", "closely watches [target]" ) )
						if(action)
							emote("me",, action)
			if(!found_mob)
				stance_step--

			if(stance_step <= -20) //If we have not found a mob for 20-ish ticks, revert to idle mode
				stance = HOSTILE_STANCE_IDLE
			if(stance_step >= 7)   //If we have been staring at a mob for 7 ticks,
				stance = HOSTILE_STANCE_ATTACK

		if(HOSTILE_STANCE_ATTACKING)
			if(stance_step >= 20)	//attacks for 20 ticks, then it gets tired and needs to rest
				emote("me",,"is worn out and needs to rest" )
				stance = HOSTILE_STANCE_TIRED
				stance_step = 0
				walk(src, 0) //This stops the bear's walking
				return



/mob/living/simple_animal/hostile/bear/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(stance != HOSTILE_STANCE_ATTACK && stance != HOSTILE_STANCE_ATTACKING)
		stance = HOSTILE_STANCE_ALERT
		stance_step = 6
		target = user
	..()

/mob/living/simple_animal/hostile/bear/attack_hand(mob/living/carbon/human/M as mob)
	if(stance != HOSTILE_STANCE_ATTACK && stance != HOSTILE_STANCE_ATTACKING)
		stance = HOSTILE_STANCE_ALERT
		stance_step = 6
		target = M
	..()

/mob/living/simple_animal/hostile/bear/Process_Spacemove(var/check_drift = 0)
	return 1	//No drifting in space for space bears!

/mob/living/simple_animal/hostile/bear/CanAttack(var/atom/the_target)
	. = ..()
	for(var/obj/effect/decal/cleanable/crayon/C in get_turf(the_target))
		if(!C.on_wall && C.name == "o") //drawing a circle around yourself is the only way to ward off space bears!
			return 0

/mob/living/simple_animal/hostile/bear/FindTarget()
	. = ..()
	if(.)
		emote("me",,"stares alertly at [.].")
		stance = HOSTILE_STANCE_ALERT

/mob/living/simple_animal/hostile/bear/LoseTarget()
	..(5)

/mob/living/simple_animal/hostile/bear/attack_icon()
	return image(icon = 'icons/mob/attackanims.dmi', icon_state = "bear")

/mob/living/simple_animal/hostile/bear/hitby(var/atom/movable/AM)
	. = ..()
	if(.)
		return
	if(istype(AM,/obj/item/weapon/reagent_containers/food/snacks) && AM.icon_state == "hburger")
		if (burger)
			burger.forceMove(get_turf(src))
		visible_message("<span class='danger'>\The [src] catches \the [AM] mid-flight, a jovial look on its face.</span>")
		burger = AM
		burger.forceMove(src)
		update_icon()
		LostTarget()
	else if (prob(50))
		dropBurger()

/mob/living/simple_animal/hostile/bear/adjustBruteLoss(damage)
	if (damage>0 && prob(50))
		dropBurger()
	..()

/mob/living/simple_animal/hostile/bear/proc/dropBurger(var/alive = TRUE)
	if (burger)
		burger.forceMove(get_turf(src))
		visible_message("<span class='danger'>\The [src] loses hold of \the [burger][alive ? ", a mean look on its face" : "as it breaths its last."].</span>")
		burger = null
		update_icon()

/mob/living/simple_animal/hostile/bear/update_icon()
	overlays.len = 0
	if(stat == DEAD)
		icon_state = icon_dead
		return
	if (burger)
		overlays += image(icon, "bearburger")
	if (istype(locked_to,/obj/item/weapon/beartrap))
		overlays += image(icon, "beartrapped")

/mob/living/simple_animal/hostile/bear/death()
	dropBurger(FALSE)
	update_icon()
	..()

/mob/living/simple_animal/hostile/bear/is_pacified()
	if (burger)
		return TRUE
	if (istype(locked_to,/obj/item/weapon/beartrap))
		return TRUE
	return ..()
