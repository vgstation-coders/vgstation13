/obj/item/potion
	name = "potion"
	desc = "This doesn't look like it does anything."
	icon = 'icons/obj/potions.dmi'
	w_class = W_CLASS_SMALL
	slot_flags = SLOT_BELT
	var/true_name	//For potions that need to have a different name/desc in the spellbook than in the game.
	var/true_desc
	var/full = TRUE
	var/fail_message = "<span class='notice'>Nothing happens, though your stomach is a little unsettled. It seems the potion isn't agreeing with you.</span>"
	var/imbibe_message = ""

/obj/item/potion/New()
	..()
	if(true_name)
		name = true_name
	if(true_desc)
		desc = true_desc

/obj/item/potion/attack_self(mob/user)
	if(!full)
		return
	user.visible_message("<span class='danger'>\The [user] drinks \the [src].</span>", "<span class='notice'>You drink \the [src].</span>")
	playsound(src,'sound/items/uncorking.ogg', rand(10,50), 1)
	spawn(6)
		playsound(src,'sound/items/drink.ogg', rand(10,50), 1)
	imbibe(user)

/obj/item/potion/update_icon()
	if(full)
		icon_state = initial(icon_state)
	else
		var/empty_state_position = findtext(icon_state,"_")+1	//records the character position starting just after the _ in the icon_state
		var/empty_state = copytext(icon_state,empty_state_position)	//copies the text from the icon_state starting after the _
		icon_state = empty_state
		name = "empty bottle"
		desc = "An empty potion bottle."

/obj/item/potion/proc/imbibe(mob/user)
	if(!full)
		return
	full = FALSE
	update_icon()
	spawn(2 SECONDS)
		if(imbibe_check(user))
			imbibe_effect(user)
			to_chat(user, imbibe_message)
		else
			to_chat(user, fail_message)

/obj/item/potion/proc/imbibe_check(mob/user)
	return TRUE

/obj/item/potion/attack(mob/M, mob/user, def_zone)
	if(full && user != M && (ishuman(M || ismonkey(M))))
		user.visible_message("<span class='danger'>\The [user] attempts to feed \the [M] \the [src].</span>", "<span class='danger'>You attempt to feed \the [M] \the [src].</span>")
		if(!do_mob(user, M))
			return
		playsound(src,'sound/items/drink.ogg', rand(10,50), 1)
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
		new /obj/item/weapon/shard(get_turf(src))
	if(full)
		if(ismob(hit_atom))
			impact_mob(hit_atom)
		else
			impact_atom(hit_atom)
		full = FALSE

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
	return isliving(user)

/obj/item/potion/healing/imbibe_effect(mob/living/user)
	user.rejuvenate(1)
	if(user.mind)
		user.mind.suiciding = 0

/obj/item/potion/mana
	name = "potion of mana"
	desc = "Refresh your spell cooldowns."
	icon_state = "star_roundbottle"

/obj/item/potion/mana/imbibe_effect(mob/user)
	for(var/spell/SP in user.spell_list)
		if(SP.panel == "Spells")
			SP.charge_counter = SP.charge_max

/obj/item/potion/invisibility
	name = "potion of minor invisibility"
	desc = "Become completely invisible for five minutes."
	icon_state = "blue_largebottle"
	var/time = 5 MINUTES
	var/include_clothes = FALSE

/obj/item/potion/invisibility/imbibe_effect(mob/user)
	user.make_invisible(INVISIBLEPOTION, time, include_clothes)

/obj/item/potion/invisibility/impact_atom(atom/target)
	if(ismovable(target))
		var/atom/movable/AM = target
		AM.make_invisible(INVISIBLEPOTION, time)

/obj/item/potion/invisibility/major
	name = "potion of major invisibility"
	desc = "Become completely invisible, along with all your clothing and possessions, for one minute."
	icon_state = "mass_orb"
	time = 1 MINUTES
	include_clothes = TRUE

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
		user.kill_light()

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
	imbibe_message = "<span class='notice'>You feel faster.</span>"
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
	var/static/list/possible_types = list(
		/mob/living/simple_animal/construct/armoured,
		/mob/living/simple_animal/hostile/gremlin,
		/mob/living/simple_animal/hostile/necromorph,
		/mob/living/simple_animal/hostile/asteroid/goliath,
		/mob/living/simple_animal/hostile/giant_spider/nurse/queen_spider,
		/mob/living/simple_animal/hostile/retaliate/cockatrice,
		/mob/living/simple_animal/construct/armoured/perfect,
		/mob/living/simple_animal/hostile/necro/zombie/putrid,
		/mob/living/simple_animal/hostile/humanoid/frostgolem/knight,
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
		var/turf/T2 = get_turf(new_mob.completely_untransmogrify())
		if(T2)
			playsound(T2, 'sound/effects/phasein.ogg', 50, 1)

/obj/item/potion/toxin
	name = "draught of toad"
	desc = "Become immune to toxins."
	imbibe_message = "<span class='notice'>You feel less toxic.</span>"
	icon_state = "green_emflask"

/obj/item/potion/toxin/imbibe_effect(mob/user)
	user.tox_damage_modifier = 0

/obj/item/potion/zombie
	name = "phial of exanimis"
	desc = "Turn the dead into undead."
	icon_state = "necro_flask2"
	imbibe_message = "<span class='notice'>Nothing seems to happen.</span>"

/obj/item/potion/zombie/imbibe_check(mob/user)
	return ishuman(user)

/obj/item/potion/zombie/imbibe_effect(mob/living/carbon/human/user)
	user.become_zombie_after_death = 2

/obj/item/potion/zombie/impact_atom(atom/target)
	var/mob/M = get_last_player_touched()
	var/list/L = get_all_mobs_in_dview(get_turf(src))
	for(var/mob/living/carbon/human/H in L)
		if(H.isDeadorDying())
			if(isjusthuman(H))
				H.make_zombie(M)
			else
				new /mob/living/simple_animal/hostile/necro/skeleton(get_turf(H), M, H.mind)
				H.gib()

/obj/item/potion/fullness
	name = "potion of fullness"
	desc = "Sate your hunger."
	icon_state = "green_minibottle"
	imbibe_message = "<span class='notice'>You feel full.</span>"
	w_class = W_CLASS_TINY

/obj/item/potion/fullness/imbibe_effect(mob/user)
	if(user.nutrition < 400)
		user.nutrition = 400

/obj/item/potion/transparency
	name = "potion of reduced visibility"
	desc = "Become slightly transparent for ten minutes."
	icon_state = "blue_minibottle"

/obj/item/potion/transparency/imbibe_effect(mob/user)
	user.alphas[TRANSPARENCYPOTION] = 125
	spawn(10 MINUTES)
		user.alphas -= TRANSPARENCYPOTION

/obj/item/potion/transparency/impact_atom(atom/target)
	if(!ismovable(target))
		return
	target.alpha = 125
	spawn(10 MINUTES)
		target.alpha = initial(target.alpha)

/obj/item/potion/paralysis
	name = "potion of minor paralysis"
	desc = "Become paralyzed for six seconds."
	icon_state = "yellow_minibottle"

/obj/item/potion/paralysis/imbibe_effect(mob/user)
	user.Stun(3)
	user.Knockdown(3)

/obj/item/potion/sword
	name = "bottled sword"
	desc = "A sword in a bottle."
	icon_state = "yellow_smallbottle"
	imbibe_message = "<span class='danger'>You feel something pierce your insides!</span>"

/obj/item/potion/sword/imbibe_check(mob/user)
	return isliving(user)

/obj/item/potion/sword/imbibe_effect(mob/living/user)
	playsound(user,'sound/weapons/bloodyslice.ogg', 50, 1)
	user.adjustBruteLoss(30)

/obj/item/potion/sword/impact_atom(atom/target)
	new /obj/item/weapon/claymore(get_turf(src))

/obj/item/potion/random
	name = "potion of unpredictability"
	desc = "Cheap and unreliable."
	icon_state = "murky_emflask"
	true_name = "murky potion"
	true_desc = "You can't quite tell what this is supposed to do."
	var/potiontype

/obj/item/potion/random/New()
	..()
	potiontype = pick(existing_typesof(/obj/item/potion))

/obj/item/potion/random/imbibe_effect(mob/user)
	var/obj/item/potion/P = new potiontype()
	P.imbibe_effect(user)
	to_chat(user, P.imbibe_message)
	qdel(P)

/obj/item/potion/random/impact_mob(mob/target)
	var/obj/item/potion/P = new potiontype()
	P.impact_mob(target)
	qdel(P)

/obj/item/potion/random/impact_atom(atom/target)
	var/obj/item/potion/P = new potiontype()
	P.impact_atom(target)
	qdel(P)

/obj/item/potion/deception
	name = "potion of deception"
	desc = "A curse disguised as a boon."
	true_name = "potion of healing"
	true_desc = "Cures all wounds. Doesn't taste great."
	imbibe_message = "<span class='danger'>Something's not right, you're in a lot of pain!</span>"
	icon_state = "heart_squarebottle"

/obj/item/potion/deception/imbibe_check(mob/user)
	return isliving(user)

/obj/item/potion/deception/imbibe_effect(mob/living/user)
	user.adjustBruteLoss(30)

/obj/item/potion/mutation
	var/mut
	var/time	//by default the effect lasts forever

/obj/item/potion/mutation/imbibe_check(mob/user)
	return ishuman(user)

/obj/item/potion/mutation/imbibe_effect(mob/living/carbon/human/user)
	if(!mut)
		return
	if(user.mutations.Find(mut))
		return
	user.mutations.Add(mut)
	if(time)
		spawn(time)
			user.mutations.Remove(mut)

/obj/item/potion/mutation/strength
	name = "potion of minor strength"
	desc = "Gain incredible strength for ten seconds."
	imbibe_message = "<span class='notice'>You feel strong!</span>"
	icon_state = "red_minibottle"
	mut = M_HULK
	time = 10 SECONDS

/obj/item/potion/mutation/strength/major
	name = "potion of major strength"
	desc = "Gain incredible strength for three minutes."
	icon_state = "red_smallbottle"
	time = 3 MINUTES

/obj/item/potion/mutation/truesight
	name = "potion of trueglimpse"
	desc = "For ten seconds, nothing will escape your vision."
	icon_state = "blue_smallbottle"
	mut = M_XRAY
	time = 10 SECONDS

/obj/item/potion/mutation/truesight/major
	name = "potion of truesight"
	desc = "For five minutes, nothing will escape your vision."
	icon_state = "blue_medbottle"
	time = 5 MINUTES

/obj/item/potion/levitation
	name = "potion of levitation"
	desc = "Float above the ground for ten minutes."
	icon_state = "green_smallbottle"

/obj/item/potion/levitation/imbibe_effect(mob/user)
	if(user.flying)
		return
	user.flying = 1
	animate(user, pixel_y = pixel_y + 10 * PIXEL_MULTIPLIER, time = 10, loop = 1, easing = SINE_EASING)
	spawn(10 MINUTES)
		user.stop_flying()
		animate(user, pixel_y = pixel_y + 10 * PIXEL_MULTIPLIER, time = 1, loop = 1)
		animate(user, pixel_y = pixel_y, time = 10, loop = 1, easing = SINE_EASING)
		animate(user)
		if(user.lying)
			user.pixel_y -= 6 * PIXEL_MULTIPLIER

/obj/item/potion/teleport
	name = "potion of transposition"
	desc = "Swap places with the bottle when it breaks."
	icon_state = "space_orb"
	imbibe_message = "<span class='danger'>You feel a sharp pain in your chest!</span>"

/obj/item/potion/teleport/imbibe_check(mob/user)
	return isliving(user)

/obj/item/potion/teleport/imbibe_effect(mob/living/user)
	user.adjustBruteLoss(50)
	playsound(user, 'sound/effects/phasein.ogg', 50, 1)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/datum/organ/internal/organ
		switch(pick(1,2,3,4))
			if(1)
				organ = user.get_lungs()
			if(2)
				organ = user.get_liver()
			if(3)
				organ = user.get_kidneys()
			if(4)
				organ = user.get_appendix()
		if(organ)
			H.remove_internal_organ(H,organ,H.get_organ(LIMB_CHEST))

/obj/item/potion/teleport/impact_atom(atom/target)
	var/mob/M = get_last_player_touched()
	if(!M)
		return
	M.unlock_from()
	var/turf/T = get_turf(src)
	if(T)
		M.forceMove(T)
		playsound(T, 'sound/effects/phasein.ogg', 50, 1)

/obj/item/potion/teleport/impact_mob(mob/target)
	var/mob/M = get_last_player_touched()
	if(!M)
		return
	M.unlock_from()
	target.unlock_from()
	var/turf/T1 = get_turf(M)
	var/turf/T2 = get_turf(target)
	if(T1)
		target.forceMove(T1)
		playsound(T1, 'sound/effects/phasein.ogg', 50, 1)
	if(T2)
		M.forceMove(T2)
		playsound(T2, 'sound/effects/phasein.ogg', 50, 1)

/obj/item/potion/fireball
	name = "bottled fireball"
	desc = "A fireball in a bottle."
	icon_state = "fireball_flask"

/obj/item/potion/fireball/imbibe_effect(mob/living/user)
	explosion(get_turf(user), -1, 1, 2, 5, whodunnit = user)

/obj/item/potion/fireball/impact_atom(atom/target)
	explosion(get_turf(target), -1, 1, 2, 5)
