/obj/item/potion
	name = "potion"
	desc = "This doesn't look like it does anything."
	icon = 'icons/obj/potions.dmi'
	icon_state = "red_minibottle"
	w_class = W_CLASS_SMALL
	slot_flags = SLOT_BELT
	var/full = TRUE
	var/fail_message = "<span class='notice'>Nothing happens, though your stomach is a little unsettled. It seems the potion isn't agreeing with you.</span>"

/obj/item/potion/attack_self(mob/user)
	if(full)
		user.visible_message("<span class='danger'>\The [user] drinks \the [src].</span>", "<span class='notice'>You drink \the [src].</span>")
		playsound(get_turf(src),'sound/items/uncorking.ogg', rand(10,50), 1)
		spawn(6)
			playsound(get_turf(src),'sound/items/drink.ogg', rand(10,50), 1)
		imbibe(user)

/obj/item/potion/update_icon()
	if(full)
		icon_state = initial(icon_state)
	else
		icon_state = "[copytext("[initial(icon_state)]",findtext("[initial(icon_state)]","_")+1)]"
		name = "empty bottle"
		desc = "An empty potion bottle."

/obj/item/potion/proc/imbibe(mob/user)
	if(full)
		full = FALSE
		update_icon()
		if(imbibe_check(user))
			imbibe_effect(user)

/obj/item/potion/proc/imbibe_check(mob/user)
	return 1

/obj/item/potion/attack(mob/M, mob/user, def_zone)
	if(full)
		if (user != M && (ishuman(M) || ismonkey(M)))
			user.visible_message("<span class='danger'>\The [user] attempts to feed \the [M] \the [src].</span>", "<span class='danger'>You attempt to feed \the [M] \the [src].</span>")
			if(!do_mob(user, M))
				return
			playsound(get_turf(src),'sound/items/drink.ogg', rand(10,50), 1)
			user.visible_message("<span class='danger'>\The [user] feeds \the [M] \the [src].</span>", "<span class='danger'>You feed \the [M] \the [src].</span>")

			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey])</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [src.name] to [M.name] ([M.ckey])</font>")
			log_attack("<font color='red'>[user.name] ([user.ckey]) fed [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

			imbibe(M)

/obj/item/potion/throw_impact(atom/hit_atom)
	..()
	src.visible_message("<span  class='warning'>\The [src] shatters!</span>","<span  class='warning'>You hear a shatter!</span>")
	var/turf/T = get_turf(src)
	if(T)
		playsound(T, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
	if(prob(33))
		getFromPool(/obj/item/weapon/shard, get_turf(src))
	if(full)
		if(ismob(hit_atom))
			impact_mob(hit_atom)
		else
			impact_atom(hit_atom)

	qdel(src)

/obj/item/potion/proc/imbibe_effect(mob/user)
	return	//code for drinking effect

/obj/item/potion/proc/impact_mob(mob/target)
	if(!issilicon(target))
		imbibe(target)
	else
		impact_atom(target)

/obj/item/potion/proc/impact_atom(atom/target)
	return	//code for when the potion breaks on a non-mob

/obj/item/potion/healing
	name = "potion of healing"
	desc = "Cures all wounds. Doesn't taste great."
	icon_state = "heart_squarebottle"

/obj/item/potion/healing/imbibe_check(mob/user)
	if(isliving(user))
		return 1
	to_chat(user, fail_message)

/obj/item/potion/healing/imbibe_effect(mob/living/user)
	user.rejuvenate(1)
	user.suiciding = 0

/obj/item/potion/invisibility
	name = "potion of invisibility"
	desc = "Become completely invisible for one minute."
	icon_state = "mass_orb"

/obj/item/potion/invisibility/imbibe_effect(mob/user)
	user.make_invisible(INVISIBLEPOTION, 1 MINUTES)

/obj/item/potion/invisibility/impact_atom(atom/target)
	if(istype(target, /atom/movable))
		var/atom/movable/AM = target
		AM.make_invisible(INVISIBLEPOTION, 1 MINUTES)

/obj/item/potion/stoneskin
	name = "potion of stone skin"
	desc = "Harden your skin to resist damage for one minute."
	icon_state = "purple_tallbottle"

/obj/item/potion/stoneskin/imbibe_effect(mob/user)
	animate(user, color = grayscale, 30)
	user.brute_damage_modifier -= 0.75
	user.burn_damage_modifier -= 0.75
	spawn(1 MINUTES)
		animate(user, color = initial(user.color), 30)
		user.brute_damage_modifier += 0.75
		user.burn_damage_modifier += 0.75

/obj/item/potion/light
	name = "potion of light"
	desc = "Give off an intense light for five minutes."
	icon_state = "sun_orb"

/obj/item/potion/light/imbibe_effect(mob/user)
	user.set_light(7,10)
	spawn(5 MINUTES)
		user.set_light(0)

/obj/item/potion/light/impact_atom(atom/target)
	var/list/L = get_all_mobs_in_dview(get_turf(src), ignore_types = list(/mob/living/carbon/brain, /mob/living/silicon/ai))
	for(var/mob/living/M in L)
		if(M.isVentCrawling())
			continue
		if(M.eyecheck() < 1)
			M.flash_eyes(visual = 1, affect_silicon = 1)

/obj/item/potion/speed
	name = "potion of minor speed"
	desc = "Increase your speed for five minutes."
	icon_state = "green_smallbottle"
	var/to_increase = 0.25
	var/time = 5 MINUTES

/obj/item/potion/speed/imbibe_effect(mob/user)
	user.movement_speed_modifier += to_increase
	spawn(time)
		user.movement_speed_modifier -= to_increase

/obj/item/potion/speed/major
	name = "potion of major speed"
	desc = "Greatly increase your speed for one minute."
	icon_state = "green_medbottle"
	to_increase = 1
	time = 1 MINUTES

/obj/item/potion/transform
	name = "potion of transformation"
	desc = "Transform into a fearsome creature for five minutes."
	icon_state = "heart_orb"
	var/list/possible_types = list(
		/mob/living/simple_animal/construct/armoured,
		/mob/living/simple_animal/hostile/gremlin,
		/mob/living/simple_animal/hostile/necromorph,
		/mob/living/simple_animal/hostile/asteroid/goliath,
		/mob/living/simple_animal/hostile/giant_spider/nurse/queen_spider,
		/mob/living/simple_animal/hostile/retaliate/cockatrice,
		/mob/living/simple_animal/hostile/retaliate/malf_drone,
		/mob/living/simple_animal/hostile/gingerbread,
		/mob/living/simple_animal/vox/armalis,
		/mob/living/carbon/alien/humanoid/hunter
		)

/obj/item/potion/transform/imbibe_effect(mob/user)
	var/target_type = pick(possible_types)
	var/mob/new_mob = user.transmogrify(target_type)
	var/turf/T = get_turf(new_mob)
	if(T)
		playsound(T, 'sound/effects/phasein.ogg', 50, 1)
	user.visible_message("<span class='danger'>\The [user] transforms into \a [new_mob]!</span>", "<span class='notice'>You transform into \a [new_mob].</span>")
	spawn(5 MINUTES)
		var/mob/top_level = new_mob
		if(top_level.transmogged_to)
			while(top_level.transmogged_to)
				top_level = top_level.transmogged_to
		var/turf/T2 = get_turf(top_level)
		while(top_level)
			top_level = top_level.transmogrify()
		if(T2)
			playsound(T2, 'sound/effects/phasein.ogg', 50, 1)