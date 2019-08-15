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

			if(get_dist(loc, T.loc) <= 4)
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
		to_chat(user, "<span class='danger'>It looks like \the [src]'s proboscis has been removed.</span>")
	return

/obj/item/clothing/mask/facehugger/attackby(obj/item/weapon/W)
	if(W.force)
		health -= W.force
		healthcheck()

/obj/item/clothing/mask/facehugger/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.damage)
		health -= Proj.damage
		healthcheck()

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
	if(isliving(AM))
		if(CanHug(AM, src))
			return Attach(AM)
	return FALSE

/obj/item/clothing/mask/facehugger/throw_at(atom/target, range, speed)
	..()
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]_thrown"
		spawn(15)
			if(icon_state == "[initial(icon_state)]_thrown")
				icon_state = "[initial(icon_state)]"

/obj/item/clothing/mask/facehugger/throw_impact(atom/hit_atom)
	..()
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]"
		if(isliving(hit_atom))
			Attach(hit_atom)

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
	if(!sterile)
		L.take_organ_damage(strength, 0) //done here so that even borgs and humans in helmets take damage

	L.visible_message("<span class='danger'>\The [src] leaps at [L]'s face!</span>")

	if(!CanHug(L, src))
		return FALSE

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
				return
			else
				C.visible_message("<span class='danger'>\The [src] bounces off of \the [headwear]!</span>")
				if(prob(CHANCE_TO_DIE_AFTER_HEAD_DENIED) && !sterile)
					death()
					return
				else
					GoIdle(TIME_IDLE_AFTER_HEAD_DENIED)
					return
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

	if(!sterile && !(istype(CA) && !CA.hasmouth))
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

	if(M.status_flags & XENO_HOST)
		return FALSE

	if(iscorgi(M))
		var/mob/living/simple_animal/corgi/corgi = M
		if(corgi.facehugger && !corgi.facehugger.sterile)
			return FALSE

		return TRUE

	if(!ishuman(M) && !ismonkey(M))
		return FALSE

	var/mob/living/carbon/C = M
	var/obj/item/clothing/mask/facehugger/F = C.is_wearing_item(/obj/item/clothing/mask/facehugger, slot_wear_mask)

	if(F && (!F.sterile || hugger.sterile) && F != hugger) // Lamarr won't fight over faces and neither will normal huggers.
		return FALSE

	return TRUE

/obj/item/clothing/mask/facehugger/acidable()
	return sterile
