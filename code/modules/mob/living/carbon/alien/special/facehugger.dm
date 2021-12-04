//TODO: Make these simple_animals

#define MIN_IMPREGNATION_TIME 10 SECONDS //time it takes to impregnate someone
#define MAX_IMPREGNATION_TIME 15 SECONDS

#define MIN_ACTIVE_TIME 20 SECONDS //time between being dropped and going idle
#define MAX_ACTIVE_TIME 40 SECONDS

#define CHANCE_TO_REMOVE_HEADWEAR 50
#define CHANCE_TO_REMOVE_SPECIAL_HEADWEAR 15
#define CHANCE_TO_DIE_AFTER_HEAD_DENIED 75
#define CHANCE_TO_NOT_REMOVE_MASKS 20
#define TIME_IDLE_AFTER_HEAD_DENIED 5 SECONDS
#define TIME_IDLE_AFTER_ATTACH_DENIED 15 SECONDS

/obj/item/clothing/mask/facehugger
	name = "facehugger" //Let's call this 'alien' what it is. Come on Bay
	desc = "It has some sort of a tube at the end of its tail."
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	w_class = W_CLASS_TINY //note: can be picked up by aliens unlike most other items of w_class below 4
	flags = FPRINT | PROXMOVE
	clothing_flags = MASKINTERNALS
	throw_range = 5
	health = 5
	plane = ABOVE_OBJ_PLANE
	layer = FACEHUGGER_LAYER
	var/real = TRUE //Facehuggers are real, toys are not.

	var/stat = CONSCIOUS //UNCONSCIOUS is the idle state in this case

	var/sterile = FALSE
	var/sterile_message = "had its proboscis removed."

	var/strength = 5

	var/attached = FALSE
	var/target_time = 0.5 // seconds
	var/walk_speed = 1
	var/nextwalk = FALSE
	var/mob/living/target = null



/obj/item/clothing/mask/facehugger/can_contaminate()
	return FALSE

/obj/item/clothing/mask/facehugger/Destroy()
	processing_objects.Remove(src)
	target = null
	..()


/obj/item/clothing/mask/facehugger/process()
	healthcheck()
	followtarget()
	spreadout()

/obj/item/clothing/mask/facehugger/proc/findtarget()
	if(!real)
		return
	target = null
	for(var/mob/living/T in hearers(src,4))
		if(!CanHug(T, src))
			continue
		if(T && (!T.isUnconscious() ) )
			target = T


/obj/item/clothing/mask/facehugger/proc/followtarget()
	if(!real)
		return // Why are you trying to path stupid toy
	if(!target || target.isUnconscious() || target.status_flags & XENO_HOST)
		findtarget()
		return
	if(loc && isturf(loc) && !attached && !stat && nextwalk <= world.time)
		nextwalk = world.time + walk_speed
		var/dist = get_dist(loc, target.loc)
		if(dist > 4)
			target = null
			return //We'll let the facehugger do nothing for a bit, since it's fucking up.

		var/obj/item/clothing/mask/facehugger/F = target.is_wearing_item(/obj/item/clothing/mask/facehugger, slot_wear_mask)
		if(F && !F.sterile) // Toys won't prevent real huggers
			findtarget()
			return
		else
			step_towards(src, target, 0)
			if(dist <= 1)
				if(CanHug(target, src) && isturf(target.loc)) //Fix for hugging through mechs and closets
					Attach(target)
					return
				else
					walk(src,0)
					findtarget()
					return

/obj/item/clothing/mask/facehugger/proc/spreadout()
	if(!target && isturf(loc) && stat == CONSCIOUS)
		for(var/obj/item/clothing/mask/facehugger/F in loc)
			if(F != src && F.stat != DEAD)
				step(src, pick(alldirs), 0)
				break

//END HUGGER MOVEMENT AI


/obj/item/clothing/mask/facehugger/attack_paw(user as mob) //can be picked up by aliens
	if(isalien(user))
		attack_hand(user)
		return
	else
		..()
		return

/obj/item/clothing/mask/facehugger/attack_hand(user as mob)
	if((stat == CONSCIOUS && !sterile) && !isalien(user))
		Attach(user)
		return

	// Colonial Marines code related to alien carriers
	// else
	// 	var/mob/living/carbon/alien/humanoid/carrier/carr = user
	//
	// 	if(carr && istype(carr, /mob/living/carbon/alien/humanoid/carrier))
	// 		if(carr.facehuggers >= 6)
	// 			carr << "You can't hold anymore facehuggers. You pick it up"
	// 			..()
	// 			return
	// 		if(stat != DEAD)
	// 			carr << "You pick up a facehugger"
	// 			carr.facehuggers += 1
	// 			qdel(src)
	//
	// 		else
	// 			user << "This facehugger is dead."
	// 			..()
	else
		..()
		return

/obj/item/clothing/mask/facehugger/proc/healthcheck()
	if(health <= 0)
		icon_state = "[initial(icon_state)]_dead"
		death()

/obj/item/clothing/mask/facehugger/attack(mob/living/M as mob, mob/user as mob)
	..()
	user.drop_from_inventory(src)
	Attach(M)

/obj/item/clothing/mask/facehugger/New()
	if(aliens_allowed)
		..()
		if(real) // Lamarr still tries to couple with heads, but toys won't
			processing_objects.Add(src)

	else if(!sterile)
		qdel(src)

/obj/item/clothing/mask/facehugger/examine(mob/user)
	..()
	if(!real) //Toy facehuggers are a child, avoid confusing examine text.
		return
	switch(stat)
		if(DEAD,UNCONSCIOUS)
			to_chat(user, "<span class='deadsay'>\The [src] is not moving.</span>")
		if(CONSCIOUS)
			to_chat(user, "<span class='danger'>\The [src] seems active.</span>")
	if (sterile)
		to_chat(user, "<span class='danger'>It looks like \the [src] [sterile_message]</span>")
	return

/obj/item/clothing/mask/facehugger/attackby(obj/item/weapon/W)
	if(W.force)
		health -= W.force
		healthcheck()

/obj/item/clothing/mask/facehugger/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.damage)
		health -= Proj.damage
		healthcheck()
	return PROJECTILE_COLLISION_DEFAULT

/obj/item/clothing/mask/facehugger/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		death()
	return

/obj/item/clothing/mask/facehugger/equipped(mob/M)
	Attach(M)

/obj/item/clothing/mask/facehugger/Crossed(atom/target) // Instead of HasEntered. Probably the right proc, probably.
	HasProximity(target)
	return

/obj/item/clothing/mask/facehugger/on_found(wearer, mob/finder as mob)
	if(stat == CONSCIOUS)
		return HasProximity(finder)
	return FALSE

/obj/item/clothing/mask/facehugger/HasProximity(atom/movable/AM as mob|obj)
	if(ishuman(AM))
		if(CanHug(AM, src))
			var/mob/living/carbon/human/H = AM
			if(!H.isUnconscious())
				return Attach(H)
	return FALSE

/obj/item/clothing/mask/facehugger/throw_at(atom/target, range, speed)
	..()
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]_thrown"
		spawn(15)
			if(icon_state == "[initial(icon_state)]_thrown")
				icon_state = "[initial(icon_state)]"

/obj/item/clothing/mask/facehugger/throw_impact(atom/hit_atom)		//STOP LATCHING ONTO HEADLESS PEOPLE
	..()
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]"
		if(ishuman(hit_atom))
			var/mob/living/carbon/human/H = hit_atom
			if(!H.isUnconscious())
				Attach(H)


/obj/item/clothing/mask/facehugger/proc/Attach(mob/living/L)
	var/preggers = rand(MIN_IMPREGNATION_TIME,MAX_IMPREGNATION_TIME)
	if(isalien(L))
		return FALSE
	if(L.status_flags & XENO_HOST)
		visible_message("<span class='danger'>An alien tries to place a facehugger on [L] but it refuses sloppy seconds!</span>")
		return FALSE
	if(attached)
		return FALSE
	if(!Adjacent(L))
		return FALSE
	else
		attached++
		spawn(MAX_IMPREGNATION_TIME)
			attached = FALSE
	if(loc == L)
		return FALSE
	if(stat != CONSCIOUS)
		return FALSE
	if(!CanHug(L, src))
		return FALSE
	if(!sterile)
		L.take_organ_damage(strength, 0) //done here so that even borgs and humans in helmets take damage

	L.visible_message("<span class='danger'>\The [src] leaps at [L]'s face!</span>")

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/mouth_protection = H.get_body_part_coverage(MOUTH)
		if(!real && mouth_protection)
			return //Toys really shouldn't be forcefully removing gear

		if(mouth_protection && mouth_protection != H.wear_mask) //can't be protected with your own mask, has to be a hat
			var/rng = CHANCE_TO_REMOVE_HEADWEAR
			if(istype(mouth_protection, /obj/item/clothing/head/helmet/space/rig))
				rng = CHANCE_TO_REMOVE_SPECIAL_HEADWEAR
			if(prob(rng)) // Temporary balance change, all mouth-covering hats will be more effective
				H.visible_message("<span class='danger'>\The [src] smashes against [H]'s \the [mouth_protection], and rips it off in the process!</span>")
				H.drop_from_inventory(mouth_protection)
				GoIdle(TIME_IDLE_AFTER_HEAD_DENIED)
				return
			else
				H.visible_message("<span class='danger'>\The [src] bounces off of \the [mouth_protection]!</span>")
				if(prob(CHANCE_TO_DIE_AFTER_HEAD_DENIED) && !sterile)
					death()
					return
				else
					GoIdle(TIME_IDLE_AFTER_HEAD_DENIED)
					return

	if(iscarbon(L))
		var/mob/living/carbon/target = L
		var/obj/item/clothing/W = target.get_item_by_slot(slot_wear_mask)
		var/obj/item/weapon/tank/had_internal = target.internal

		if(W && W != src)
			if(prob(CHANCE_TO_NOT_REMOVE_MASKS))
				return FALSE
			if(!W.canremove)
				return FALSE
			target.drop_from_inventory(W)

			target.visible_message("<span class='danger'>\The [src] tears \the [W] off of [target]'s face!</span>")

		forceMove(target)
		target.equip_to_slot(src, slot_wear_mask)
		target.update_inv_wear_mask()
		target.internal = had_internal //Try to keep the host ALIVE
		target.update_internals()

		if(!sterile && target.hasmouth)
			L.Paralyse((preggers/10)+10) //something like 25 ticks = 20 seconds with the default settings
	else if (iscorgi(L))
		var/mob/living/simple_animal/corgi/C = L
		var/obj/item/clothing/head/headwear = C.inventory_head
		var/rng = 100
		var/obj/item/clothing/mask/facehugger/hugger = C.facehugger

		if(hugger && !hugger.sterile)
			return

		if(headwear)
			if(istype(headwear, /obj/item/clothing/head/cardborg))
				rng = CHANCE_TO_REMOVE_HEADWEAR
			else if(istype(headwear, /obj/item/clothing/head/helmet/space/rig))
				rng = CHANCE_TO_REMOVE_SPECIAL_HEADWEAR

			if(prob(rng))
				C.visible_message("<span class='danger'>\The [src] smashes against [C]'s \the [headwear], and rips it off in the process!</span>")
				C.drop_from_inventory(headwear)
				GoIdle(TIME_IDLE_AFTER_HEAD_DENIED)
			else
				C.visible_message("<span class='danger'>\The [src] bounces off of \the [headwear]!</span>")
				if(prob(CHANCE_TO_DIE_AFTER_HEAD_DENIED) && !sterile)
					death()
				else
					GoIdle(TIME_IDLE_AFTER_HEAD_DENIED)
			return

		forceMove(C)
		C.facehugger = src
		C.wear_mask = src
		C.regenerate_icons()

	GoIdle(TIME_IDLE_AFTER_ATTACH_DENIED) //so it doesn't jump the people that tear it off

	spawn(preggers)
		Impregnate(L)

	return FALSE

/obj/item/clothing/mask/facehugger/proc/Impregnate(mob/living/target as mob)
	if(!target || target.wear_mask != src || target.stat == DEAD) //was taken off or something
		return

	var/mob/living/carbon/CA = target

	if(!sterile && !(istype(CA) && !CA.hasmouth()))
		var/obj/item/alien_embryo/E = new (target)
		target.status_flags |= XENO_HOST
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/T = target
			var/datum/organ/external/chest/affected = T.get_organ(LIMB_CHEST)
			affected.implants += E
		target.visible_message("<span class='danger'>\The [src] falls limp after violating [target]'s face !</span>")

		death()
		//target.drop_from_inventory(src)
		icon_state = "[initial(icon_state)]_impregnated"

		if(iscorgi(target))
			var/mob/living/simple_animal/corgi/C = target
			forceMove(get_turf(C))
			C.facehugger = null
			C.regenerate_icons()
	else
		target.visible_message("<span class='danger'>\The [src] violates [target]'s face !</span>")
	return

/obj/item/clothing/mask/facehugger/proc/GoActive()
	if(stat == DEAD || stat == CONSCIOUS)
		return

	stat = CONSCIOUS
	icon_state = "[initial(icon_state)]"
	return

/obj/item/clothing/mask/facehugger/proc/GoIdle(var/delay)
	if(stat == DEAD || stat == UNCONSCIOUS)
		return

/*		RemoveActiveIndicators()	*/
	target = null
	stat = UNCONSCIOUS
	icon_state = "[initial(icon_state)]_inactive"
	if(!delay)
		delay = rand(MIN_ACTIVE_TIME,MAX_ACTIVE_TIME)
	spawn(delay)
		GoActive()
	return

/obj/item/clothing/mask/facehugger/proc/death()
	if(stat == DEAD || !real)
		return
	target = null
/*		RemoveActiveIndicators()	*/
	processing_objects.Remove(src)
	icon_state = "[initial(icon_state)]_dead"
	stat = DEAD
	sterile = TRUE //Dead huggers can't make people pregnant, duh. This also makes them acidable to avoid acid cheesers AND prevents people from using dead huggers to avoid getting hugged.

	visible_message("<span class='danger'>\The [src] curls up into a ball!</span>")


/proc/CanHug(mob/living/M, obj/item/clothing/mask/facehugger/hugger = null)
	if(isalien(M))
		return FALSE

	if((M.status_flags & XENO_HOST) && !istype(hugger, /obj/item/clothing/mask/facehugger/headcrab))
		return FALSE

	if(iscorgi(M) && !istype(hugger, /obj/item/clothing/mask/facehugger/headcrab))
		var/mob/living/simple_animal/corgi/corgi = M
		if(corgi.facehugger && !corgi.facehugger.sterile)
			return FALSE

		return TRUE

	if(!ishuman(M) && !ismonkey(M))
		return FALSE

	var/mob/living/carbon/C = M
	var/obj/item/clothing/mask/facehugger/F = C.is_wearing_item(/obj/item/clothing/mask/facehugger, slot_wear_mask)
	var/obj/item/clothing/mask/facehugger/F2 = C.is_wearing_item(/obj/item/clothing/mask/facehugger, slot_head)

	if(F && (!F.sterile || hugger.sterile) && F != hugger) // Lamarr won't fight over faces and neither will normal huggers.
		return FALSE
	if(F2 && (!F2.sterile || hugger.sterile) && F2 != hugger)
		return FALSE

	return TRUE

/obj/item/clothing/mask/facehugger/acidable()
	return sterile




////////////////////////////////////////////////////
////////////////  HEADCRABS  ///////////////////////
////////////////////////////////////////////////////

/obj/item/clothing/mask/facehugger/headcrab
	name = "headcrab" //womp womp
	desc = "Get that thing away from me!"  //TODO: think of a better quote
	icon = 'icons/mob/alien.dmi'
	icon_state = "headcrab"
	item_state = "headcrab"
	body_parts_covered = HEAD
	slot_flags = SLOT_HEAD
	clothing_flags = null
	canremove = 0  //You need to resist out of it.
	cant_remove_msg = " is latched on tight!"
	sterile_message = "has been de-beaked."
	var/is_being_resisted = 0
	var/escaping = 0 	//If enabled the crab will try to escape.

/obj/item/clothing/mask/facehugger/headcrab/New()
	..()
	if(!real)	//Toys shouldn't be difficult to remove
		canremove = 1


/obj/item/clothing/mask/facehugger/headcrab/equipped(mob/living/carbon/human/H)
	if(stat == CONSCIOUS)
		Assimilate(H)
	else if(stat == UNCONSCIOUS)
		GoActive()
		Assimilate(H)

/obj/item/clothing/mask/facehugger/headcrab/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/target = user
		if(target && target.head == src && stat != DEAD && real)
			target.resist()
		else
			..()


/obj/item/clothing/mask/facehugger/headcrab/death()
	if(stat == DEAD || !real)
		return
	target = null
	processing_objects.Remove(src)
	icon_state = "[initial(icon_state)]_dead"
	stat = DEAD
	sterile = TRUE
	canremove = 1

	visible_message("<span class='danger'>\The [src] curls up into a ball!</span>")


/obj/item/clothing/mask/facehugger/headcrab/findtarget()
	if(!real)
		return
	target = null
	for(var/mob/living/carbon/human/T in hearers(src,6))
		if(!CanHug(T, src))
			continue
		if(!T.isUnconscious())
			target = T



/obj/item/clothing/mask/facehugger/headcrab/attackby(obj/item/weapon/W, mob/user)
	if(ishuman(user) && stat != DEAD)
		var/mob/living/carbon/human/U = user
		var/obj/item/clothing/mask/facehugger/headcrab/H = U.is_wearing_item(/obj/item/clothing/mask/facehugger/headcrab, slot_head)
		if(H == src)
			U.resist()
			return
	if(W.force)
		health -= W.force
		healthcheck()


/obj/item/clothing/mask/facehugger/headcrab/followtarget()
	if(!real)
		return // Why are you trying to path stupid toy
	if(!target)
		findtarget()
		return
	if(isturf(loc) && !attached && !stat && nextwalk <= world.time)
		nextwalk = world.time + walk_speed
		var/dist = get_dist(loc, target.loc)
		if(dist > 6)
			target = null
			return //We'll let the facehugger do nothing for a bit, since it's fucking up.

		var/obj/item/clothing/mask/facehugger/headcrab/F = target.is_wearing_item(/obj/item/clothing/mask/facehugger/headcrab, slot_head)
		if(F && !F.sterile) // Toys won't prevent real huggers
			findtarget()
			return
		else
			playsound(src, pick('sound/items/headcrab_attack1.ogg', 'sound/items/headcrab_attack2.ogg', 'sound/items/headcrab_attack3.ogg'), 50, 0)
			if(escaping)		//If escaping, jump away from the nearest guy.
				if(src.loc == target.loc)	//If the target is on the same tile just jump a random direction away
					var/turf/escape_tile = locate(src.x + rand(3,6)*(-1**rand(1,2)), src.y + rand(3,6)*(-1**rand(1,2)), src.z)	//This is messy. For x and y coordinates, pick a random number between 3 and 6, then randomly make that number positive or negative.
					throw_at(escape_tile, 4, 1)
				else
					var/turf/escape_tile = locate(src.x-(target.x-src.x)*2, src.y-(target.y-src.y)*2, target.z)
					throw_at(escape_tile, 4, 1)
				escaping = 0
				sleep(50)
				GoActive()
			else
				throw_at(target, 3, 1)
				if(dist == 0)
					if(CanHug(target, src) && isturf(target.loc)) //Fix for hugging through mechs and closets
						Attach(target)
						return

/obj/item/clothing/mask/facehugger/headcrab/Attach(mob/living/L)
	if(escaping)
		return FALSE
	if(isalien(L))
		return FALSE
	if(attached)
		return FALSE
	if(!Adjacent(L))
		return FALSE
	if(loc == L)
		return FALSE
	if(stat != CONSCIOUS)
		return FALSE
	if(!CanHug(L, src))
		return FALSE
	if(!sterile)
		L.take_organ_damage(strength, 0) //done here so that even borgs and humans in helmets take damage

	L.visible_message("<span class='danger'>\The [src] leaps at [L]'s face!</span>")


	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/head_protection = H.get_body_part_coverage(HEAD)
		if(!real && head_protection)
			return FALSE//Toys really shouldn't be forcefully removing gear

		if(head_protection)
			var/rng = 80	//80% chance to remove the hat if it isn't a rig
			if(istype(head_protection, /obj/item/clothing/head/helmet/space/rig))
				rng = CHANCE_TO_REMOVE_SPECIAL_HEADWEAR
			if(prob(rng)) // Temporary balance change, all mouth-covering hats will be more effective
				H.visible_message("<span class='danger'>\The [src] smashes against [H]'s \the [head_protection], and rips it off in the process!</span>")
				H.drop_from_inventory(head_protection)
				GoIdle(TIME_IDLE_AFTER_HEAD_DENIED)
				return FALSE
			else
				H.visible_message("<span class='danger'>\The [src] bounces off of \the [head_protection]!</span>")
				if(prob(CHANCE_TO_DIE_AFTER_HEAD_DENIED) && !sterile)
					death()
					return FALSE
				else
					GoIdle(TIME_IDLE_AFTER_HEAD_DENIED)
					return FALSE

		var/mob/living/carbon/target = L
		var/obj/item/clothing/W = target.get_item_by_slot(slot_head)

		if(W && W != src)
			if(!W.canremove)
				return FALSE
			target.drop_from_inventory(W)

			target.visible_message("<span class='danger'>\The [src] tears \the [W] off of [target]'s head!</span>")

		forceMove(target)
		target.equip_to_slot(src, slot_head)
		target.update_inv_head()
		if(real)
			target.audible_scream()
			target.movement_speed_modifier -= 0.75			//Slow them down like a taser
			spawn(30)
				target.movement_speed_modifier += 0.75
		target.update_inv_head()			//Sometimes it doesnt work the first time
		Assimilate(target)
		return TRUE


	GoIdle(TIME_IDLE_AFTER_ATTACH_DENIED)


	return FALSE

/obj/item/clothing/mask/facehugger/headcrab/proc/Assimilate(mob/living/L)
	if(!ishuman(L))
		return
	if(sterile || !real)
		return
	var/mob/living/carbon/human/target = L
	if(target.head != src) //was taken off or something
		return

	while(target && target.head == src && !target.isDead() && !target.isInCrit())	//If they're still alive chew at their fuggin skull
		playsound(src, 'sound/weapons/bite.ogg', 50, 1)
		target.apply_damage(10, BRUTE, LIMB_HEAD)
		target.update_inv_head()
		sleep(30)

	if(target && target.head == src && (target.isDead() || target.isInCrit()))	//Once they die, start the zombification.
		visible_message("<span class='danger'>[target.real_name] begins to shake and convulse violently!</span>")
		to_chat(target, "<span class='sinister'>You feel your consciousness slipping away...</span>")
		target.Jitter(500)
		sleep(150)
		target.remove_jitter()
		if(target && target.head == src)
			if(!target.isDead() && !target.isInCrit())	//something healed them, start over
				Assimilate()
				return
			target.death(0)
			visible_message("<span class='danger'>[target.real_name]'s flesh is violently torn apart!</span>")
			hgibs(target.loc, target.virus2, target.dna)
			var/mob/living/simple_animal/hostile/necro/zombie/headcrab/Z = target.make_zombie(retain_mind = 1, crabzombie = 1)
			Z.crab = src




