///////////////////////////////////////////////////////////////////SLAZAAR HUNTER///////////
// By far the most dangerous of the xenoplanet mobs. It's tough and extremely deadly, able to grab and kill an unprepared spaceman in mere moments
/mob/living/simple_animal/hostile/slazaar_hunter
	name = "slazaar"
	desc = "A carnivorous alien apex predator, with large scythe-like pinchers that snap open and shut."
	icon = 'icons/mob/animal.dmi'
	icon_state = "xeno_snake"
	icon_living = "xeno_snake"
	icon_dead = "xeno_snake_dead"

	speak = list("sssSSSssst","sssSSsssr","ssssSSSSssss")
	speak_emote = list("hisses")
	emote_hear = list("hisses")
	emote_see = list("snaps its mandibles", "rattles its spines", "clicks its pinchers")
	speak_chance = 1
	turns_per_move = 5
	speak_override = TRUE

	maxHealth = 180
	health = 180

	faction = "slazaar"
	acidimmune = 1

	size = SIZE_BIG

	melee_damage_lower = 15
	melee_damage_upper = 40
	attacktext = "slices"
	attack_sound = 'sound/weapons/bloodyslice.ogg'

	stat_attack = DEAD	// A corpse means dinner is served

	vision_range = 12 // It can detect enemies from a further distance away than most simplemobs
	aggro_vision_range = 20 // While aggroed, it can see a LONG ways
	idle_vision_range = 12
	see_in_dark = 20 // It has no trouble seeing in its natural habitat

	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG

	var/enraged = FALSE // Uh oh
	var/currentlyMunching = FALSE	//If it's currently eating so it doesn't keep trying.

	var/last_grapple = 0
	var/const/grapple_cooldown = 30 SECONDS // So we don't keep grabbing a creature that's escaped

	minbodytemp = 223 // Fairly acclimated to the cold

/mob/living/simple_animal/hostile/slazaar_hunter/Life()
	if(timestopped)
		return 0 //under effects of time magick
	. = ..()
	if(.)
		if(prob(1) || (!target && enraged == TRUE)) // If no target and we're mad, maybe we calm down.
			enraged = FALSE

		if(!isDead() && enraged == FALSE) // If we're not dead and we're not angry, stay away from fire
			var/list/can_see = view(src, vision_range)

			for(var/obj/machinery/space_heater/campfire/fire in can_see)
				var/dist = get_dist(src, fire)
				if(dist < (fire.light_range*2))
					walk_away(src,fire,(fire.light_range*2),move_to_delay)
					visible_message("<span class = 'notice'>\The [src] looks at the fire warily.</span>")

/mob/living/simple_animal/hostile/slazaar_hunter/hitby() // Throwing something at them will make them mad
	. = ..()
	if(.)
		return

	if(enraged == FALSE)
		enraged = TRUE
		visible_message("<span class='danger'>\The [src] hisses in anger!</span>")

/mob/living/simple_animal/hostile/slazaar_hunter/bullet_act(obj/item/projectile/P, def_zone) // Shooting them with a projectile that does damage will make them mad
	. = ..()

	if(P.damage > 0) //The projectile isn't a dummy
		if(enraged == FALSE)
			enraged = TRUE
			visible_message("<span class='danger'>\The [src] hisses in anger!</span>")

/mob/living/simple_animal/hostile/slazaar_hunter/attackby(var/obj/item/O as obj, var/mob/user as mob) // Hitting one of these guys with something will make them mad
	if(enraged == FALSE)
		enraged = TRUE
		visible_message("<span class='danger'>\The [src] hisses in anger!</span>")
	..()

/mob/living/simple_animal/hostile/slazaar_hunter/attack_hand(mob/living/carbon/human/M as mob) // Touching one of them with an empty hand will also make them mad
	if(enraged == FALSE)
		enraged = TRUE
		visible_message("<span class='danger'>\The [src] hisses in anger!</span>")
	..()

/mob/living/simple_animal/hostile/slazaar_hunter/CanAttack(var/atom/the_target) // We don't attack creatures holding lit flares, welding tools, or near a fire, unless we're mad
	. = ..()
	var/list/target_prox = view(the_target, vision_range)
	for(var/obj/machinery/space_heater/campfire/fire in target_prox)
		var/dist = get_dist(the_target, fire)
		if(dist < (fire.light_range*2) && enraged == FALSE)//Just sitting on the edge of the fire
			return 0
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(isplasmaman(H) && enraged == FALSE) // They don't recognize plasmamen as prey due to their strange biology, but they will still attack them if angered
			visible_message("<span class = 'notice'>\The [src] looks at [H] for a moment, but seems to lose interest.</span>")
			return 0
		if(isplasmaman(H) && H.isDead()) // Won't eat a dead plasmaman. Yuck.
			return 0
		if(istype(H.get_item_by_slot(slot_belt), /obj/item/device/flashlight/flare)) // Wearing the flare or welding tool on the belt works
			var/obj/item/device/flashlight/flare/F
			if(F.on == 1 && enraged == FALSE)
				visible_message("<span class = 'notice'>\The [src] looks at the lit flare warily.</span>")
				return 0
		if(istype(H.get_item_by_slot(slot_belt), /obj/item/tool/weldingtool))
			var/obj/item/tool/weldingtool/W
			if(W.isOn() && enraged == FALSE)
				visible_message("<span class = 'notice'>\The [src] looks at the lit welding tool warily.</span>")
				return 0
		for(var/obj/item/device/flashlight/flare/F in H.held_items) // So does holding it in a hand
			if(F.on == 1 && enraged == FALSE)
				visible_message("<span class = 'notice'>\The [src] looks at the lit flare warily.</span>")
				return 0
		for(var/obj/item/tool/weldingtool/W in H.held_items)
			if(W.isOn() && enraged == FALSE)
				visible_message("<span class = 'notice'>\The [src] looks at the lit welding tool warily.</span>")
				return 0

/mob/living/simple_animal/hostile/slazaar_hunter/FindTarget()
	. = ..()
	if(.)
		emote("me",,"hisses at [.].")
		stance = HOSTILE_STANCE_ALERT
		if(prob(25))
			playsound(src, 'sound/voice/hiss4.ogg', 50, 1)

/mob/living/simple_animal/hostile/slazaar_hunter/AttackingTarget() // Hunters are scary predators. They grab prey, and immediately try to kill them by eating them alive. Think a cross between a praying mantis and a giant snake
	var/mob/living/M = target
	if(currentlyMunching)
		return

	if((last_grapple + grapple_cooldown >= world.time) && !M.locked_to && !M.isDead()) // If we recently used a grapple and it's on cooldown, just slash the target
		..()

	if((last_grapple + grapple_cooldown < world.time) && !M.locked_to && !M.isDead()) // If we're attacking someone and our grapple ability isn't on cooldown, grab them
		M.visible_message("<b><span class='warning'>[src] snaps out with its scythe-like pinchers, and grabs [M]!</span>")
		lock_atom(M, /datum/locking_category/slazaar_latch)
		last_grapple = world.time

	if(M.locked_to == src) // Grapple follow-up
		spawn(4 SECONDS) // Probably not the best way to write it, but this allows a player a few secomds to make some escape attempts before getting munched on
			if(M.locked_to == src && M.isDead()) // If the creature in its grip is dead, just drop it
				unlock_atom(M)

			if(M.locked_to == src && !M.isDead()) // If the creature in its grip is not dead, proceed with the killing
				if(ishuman(M))
					var/mob/living/carbon/human/H = target
					var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
					visible_message("<b><span class='warning'>[src] starts chewing on [H]'s head!</span>")
					if(head_organ)
						head_organ.take_damage(25) // Ouch, head is being fucking EATEN
						health += 5
						if(prob(25))
							H.audible_scream()
							playsound(src, pick('sound/effects/squelch1.ogg', 'sound/effects/flesh_squelch.ogg'), 100, 1)

				if(isalien(M)) // Needs a check for aliens, it seems
					visible_message("<b><span class='warning'>[src] starts chewing on [M]!</span>")
					M.adjustBruteLoss(15)
					health += 5

				if(!ishuman(M)) // Catch-all for other nonhuman creatures that it grabs
					visible_message("<b><span class='warning'>[src] starts chewing on [M]!</span>")
					M.adjustBruteLoss(25)
					health += 5

	if(M.isDead()) // If it's dead, eat the remains
		eatCorpse(M)

/mob/living/simple_animal/hostile/slazaar_hunter/relaymove(mob/user)// Resisting out of the hunter's grip takes strength level from mutations or other sources into account
	var/mob/living/carbon/human/H = user
	if(istype(H))
		if(user.incapacitated()) // Can't resist when stunned or unconscious
			return

		if(H.get_strength() > 2) // Are we TOO SWOLE TO CONTROL?! Breaking free is guaranteed!
			to_chat(user, "<span class='warning'>You start to loosen the [src]'s grip!</span>")
			if(do_after(user, src, 10)) // 1 second resist time, 100% chance of success
				to_chat(user, "<span class='warning'>You pull yourself free of the [src]'s grip!</span>")
				unlock_atom(H)

		if(H.get_strength() == 2) // Are we stronger than average due to a mutation or other bonus? Boost resistance chance!
			to_chat(user, "<span class='warning'>You wrestle furiously against the [src]'s grip!</span>")
			if(do_after(user, src, 10)) // 1 second resist time, 50% chance of success
				if(prob(50))
					to_chat(user, "<span class='warning'>The [src] barely manages to keep its hold on you!</span>")
				else
					to_chat(user, "<span class='warning'>With a mighty effort, you pull free of the [src]'s grip!</span>")
					unlock_atom(H)

		if(H.get_strength() < 2) // Are we just average strength? We get the lowest chance of successfully escaping
			to_chat(user, "<span class='warning'>You struggle to get free of the [src]'s grip!</span>")
			if(do_after(user, src, 10)) // 1 second resist time, 25% chance of success with no other modifiers
				if(prob(75))
					to_chat(user, "<span class='warning'>You fail to get free of the [src]'s grip, and it crushes you painfully!</span>")
					H.adjustBruteLoss(5)
				else
					to_chat(user, "<span class='warning'>You manage to pull free of the [src]'s grip, freeing yourself!</span>")
					unlock_atom(H)

/mob/living/simple_animal/hostile/slazaar_hunter/death(var/gibbed = FALSE) // This is here so creatures don't stay locked to them when they die
	for(var/atom/movable/A in get_locked(/datum/locking_category/slazaar_latch))
		unlock_atom(A)
		visible_message("<span class='warning'>\The [src] lets go of [A]!</span>")
	..(gibbed)

/datum/locking_category/slazaar_latch

/mob/living/simple_animal/hostile/slazaar_hunter/proc/eatCorpse(var/mob/living/L) // Grabbed from gourmonger code, so it eats corpses
	if(ishuman(L))
		eatLimb(L)
	else
		if(!munchOn(L))
			return
		visible_message("<span class='warning'>\The [src] devours [L]!</span>")
		health += 30
		enraged = FALSE // We've had a meal. If we're mad, let's calm down
		L.gib()

/mob/living/simple_animal/hostile/slazaar_hunter/proc/eatLimb(var/mob/living/carbon/human/H) // Grabbed from gourmonger code, so it eats human corpses limb by limb, eventually leaving nothing but gibs
	if(!munchOn(H))
		return
	var/datum/organ/external/toEat = H.pick_usable_organ(LIMB_LEFT_ARM, LIMB_RIGHT_ARM, LIMB_LEFT_LEG, LIMB_RIGHT_LEG)
	if(toEat)
		toEat.droplimb(1, 0, 0)
		visible_message("<span class='warning'>\The [src] is devouring [H]'s [toEat.display_name]!</span>")
		health += 10
	else
		visible_message("<span class='warning'>\The [src] has devoured [H] completely!</span>")
		health += 30
		enraged = FALSE // We've had a meal. If we're mad, let's calm down
		H.gib()

/mob/living/simple_animal/hostile/slazaar_hunter/proc/munchOn(var/atom/T, var/munchTime = 3) // I have no idea if this is needed or not.
	if(currentlyMunching)
		return FALSE
	currentlyMunching = TRUE
	canmove = 0
	for(var/i = 0, i<munchTime, i++)
		if(T.gcDestroyed)
			LoseTarget()
			currentlyMunching = FALSE
			canmove = 1
			return
		sleep(1 SECONDS)
	currentlyMunching = FALSE
	canmove = 1
	if(Adjacent(T) && !stat)
		return TRUE

///////////////////////////////////////////////////////////////////PODPIIDA ROAMER///////////
// Second most dangerous mob on the xenoplanet. It spits paralytic venom at a target before latching onto their head and eventually taking full control of their motor functions
/mob/living/simple_animal/hostile/podapiida
	name = "podapiida"
	desc = "A squid-like creature, possessing bulbous sacs full of an unknown icor."
	icon = 'icons/mob/animal.dmi'
	icon_state = "xenosquid"
	icon_living = "xenosquid"
	icon_dead = "xenosquid_dead"

	speak = list("Hrrrrrrrrm","Frrrrrrm","Krrrrrrm")
	speak_emote = list("thrums")
	emote_hear = list("thrums")
	emote_see = list("wriggles its tendrils", "expands and contracts its sacs", "snaps its mandibles")
	speak_chance = 1
	turns_per_move = 5
	speak_override = TRUE

	maxHealth = 30 // Pretty fragile
	health = 30

	faction = "podapiida"
	acidimmune = 1

	see_in_dark = 8 // It has no trouble seeing in its natural habitat

	ranged = 1
	ranged_cooldown = 30
	ranged_cooldown_cap = 30
	ranged_message = "spits"
	projectiletype = /obj/item/projectile/squidtox
	projectilesound = 'sound/weapons/pierce.ogg'

	melee_damage_lower = 1
	melee_damage_upper = 5
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	move_to_delay = 3 // Not very fast

	stat_attack = UNCONSCIOUS

	var/venom_chance = 33
	var/recover_time = 2 SECONDS
	var/recover_start
	var/recovering = FALSE

	minbodytemp = 223 // Fairly acclimated to the cold

/mob/living/simple_animal/hostile/podapiida/Life()
	if(timestopped)
		return 0 //under effects of time magick
	. = ..()
	if(.)
		if((recover_start + recover_time < world.time) && recovering == TRUE)
			recovering = FALSE
	if(recovering == TRUE)
		stop_automated_movement = 1

/mob/living/simple_animal/hostile/podapiida/CanAttack(var/atom/the_target)
	. = ..()
	if(recovering == TRUE) // Can't attack anything while it's recovering
		return 0
	if(ishuman(the_target))
		var/mob/living/carbon/human/H = the_target
		if(istype(H.get_item_by_slot(slot_head), /obj/item/clothing/mask/podapiida)) // If one of our friends is attached to the head already, don't bother
			return 0

/mob/living/simple_animal/hostile/podapiida/AttackingTarget()
	var/mob/living/M = target
	if(!ishuman(M))
		..()

	if(ishuman(M))
		var/mob/living/carbon/human/H = target
		if(!H.incapacitated() && !prob(venom_chance))
			..()

		if(!H.incapacitated() && prob(venom_chance))
			H.visible_message("<span class='warning'>\The [src] bites [H].</span>")
			playsound(src, 'sound/weapons/bite.ogg', 50, 1)
			to_chat(H, "<span class='userdanger'>\The [src]'s bite barely hurt, but it's becoming incredibly painful to move!</span>")
			H.confused += 5
			H.eye_blurry += 5
			H.pain_shock_stage += 150
			spawn(4 SECONDS)
				H.reagents.add_reagent(NEUROTOXIN, 0.5) // Even half a unit is more than enough

		if(H.incapacitated())
			var/obj/item/head_protection = H.get_body_part_coverage(HEAD) // If they've got a helmet, try to remove it
			if(head_protection)
				var/rng = 60 // 60% chance to remove the hat if it isn't a rig
				if(istype(head_protection, /obj/item/clothing/head/helmet/space/rig))
					rng = 30 // 30% chance to remove the hat if it is a rig
				if(prob(rng))
					H.visible_message("<span class='danger'>\The [src] probes at \the [head_protection] with its tendrils, and manages to remove it!</span>")
					H.drop_from_inventory(head_protection)
					recover_start = world.time
					recovering = TRUE
					return
				else
					H.visible_message("<span class='warning'>\The [src] probes at \the [head_protection] with its tendrils, but fails to remove it!</span>")
					recover_start = world.time
					recovering = TRUE
					return

			var/obj/item/clothing/W = H.get_body_part_coverage(MOUTH) // If they've got a mask, try to remove it
			if(W && W != src)
				if(!W.canremove)
					return FALSE
				H.drop_from_inventory(W)

				H.visible_message("<span class='danger'>\The [src] probes at \the [W] with its tendrils, and rips it off of [H]'s head!</span>")
				recover_start = world.time
				recovering = TRUE
				return

			if(!head_protection && !W) // If they have no helmet or mask, jump on!
				H.visible_message("<span class='danger'>\The [src] attaches itself to [H]'s head!</span>")
				var/obj/item/clothing/mask/podapiida/P = new /obj/item/clothing/mask/podapiida(get_turf(src))
				qdel(src)
				P.forceMove(target)
				H.equip_to_slot(P, slot_head)
				H.update_inv_head()

///////////////// PODPIIDA SPIT ////////////////////
// A ranged attack for incapacitating enemies rather than killing them, deals minor toxin damage
/obj/item/projectile/squidtox
	name = "neurotoxin spit"
	icon_state = "toxin"
	damage = 5
	damage_type = TOXIN

/obj/item/projectile/squidtox/on_hit(var/atom/target, var/blocked = 0)
	if (..(target, blocked))
		var/mob/living/carbon/human/H = target
		to_chat(H, "<span class='userdanger'>It's becoming incredibly painful to move!</span>")
		H.confused += 5
		H.eye_blurry += 5
		H.pain_shock_stage += 150
		spawn(4 SECONDS)
			H.reagents.add_reagent(NEUROTOXIN, 0.5) // Even half a unit is more than enough
	return 0

///////////////////////////////////////////////////////////////////QWARMOK FORAGER///////////
// The least dangerous mob on the xenoplanet. Mostly eats vegetation periodically and quacks. Very good on a treadmill, and tastes a bit like chicken
/mob/living/simple_animal/hostile/quarmok
	name = "quarmok"
	desc = "An ostrich-like alien creature with powerful legs."
	icon = 'icons/mob/animal.dmi'
	icon_state = "xeno_ostrich"
	icon_living = "xeno_ostrich"
	icon_dead = "xeno_ostrich_dead"

	speak = list("Qwuek","Wuek wuek","Huek")
	speak_emote = list("quacks")
	emote_hear = list("quacks")
	emote_see = list("stretches its legs", "wiggles its snout", "stamps its feet")
	emote_sound = list("sound/items/quack.ogg")
	speak_chance = 1
	turns_per_move = 5
	speak_override = TRUE

	maxHealth = 60 // Moderate health
	health = 60

	faction = "quarmok"
	acidimmune = 1

	vision_range = 12 // It can detect enemies from a further distance away than most simplemobs
	aggro_vision_range = 20 // While aggroed, it can see a LONG ways
	idle_vision_range = 12
	see_in_dark = 20 // It has no trouble seeing in its natural habitat

	melee_damage_lower = 5
	melee_damage_upper = 15 // It's got them beefy legs
	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'

	move_to_delay = 1.4 // Holy shit! He fast
	treadmill_speed = 12 // A very good treadmill runner

	minbodytemp = 223 // Fairly acclimated to the cold

	search_objects = 1
	wanted_objects = list(/obj/structure/flora/xeno_flora)

	var/last_meal = 0
	var/const/hunger_cooldown = 360 SECONDS

	var/is_foraging = 0

/mob/living/simple_animal/hostile/quarmok/Found(atom/A)
	if(istype(A,/obj/structure/flora/xeno_flora))
		return TRUE

/mob/living/simple_animal/hostile/quarmok/GiveTarget(var/new_target)
	target = new_target
	if(isDead())
		return
	if(isliving(target))
		if(is_spooked(target))
			var/list/can_see = view(src, vision_range)
			get_spooked(target)
			for(var/mob/living/simple_animal/hostile/quarmok/Q in can_see)
				Q.get_spooked(target)
	if(istype(target, /obj/structure/flora/xeno_flora))
		if(last_meal + hunger_cooldown < world.time)
			visible_message("<span class='notice'>\The [src] looks at \the [target] hungrily.</span>")
			stance = HOSTILE_STANCE_ATTACK
			is_foraging = 1

/mob/living/simple_animal/hostile/quarmok/proc/get_spooked(var/mob/living/T)
	stance = HOSTILE_STANCE_ATTACK
	target = T
	visible_message("<span class='danger'>\The [src] tries to flee from \the [target]!</span>")
	retreat_distance = 25
	minimum_distance = 25

/mob/living/simple_animal/hostile/quarmok/proc/is_spooked(var/mob/living/target)
	for(var/datum/weakref/ref in friends) // Friendship is not yet coded. Sad
		if (ref.get() == target)
			return 0
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/spook_prob = 30

		if(H.m_intent == "run")
			spook_prob = 70
		if(prob(spook_prob))
			return 1
	else
		if(!istype(target, /mob/living/simple_animal/hostile/quarmok))
			return 1

/mob/living/simple_animal/hostile/quarmok/UnarmedAttack(var/atom/A)
	if(istype(A, /obj/structure/flora/xeno_flora))
		visible_message("<span class='notice'>\The [A] is eaten by the quarmok!</span>")
		playsound(src, 'sound/items/eatfood.ogg', rand(10,50), 1)
		qdel(A)
		last_meal = world.time
		is_foraging = 0
	else return ..()

/mob/living/simple_animal/hostile/quarmok/Life()
	..()
	if(isDead())
		return
	var/list/can_see = view(src, vision_range)
	if(stance == HOSTILE_STANCE_ATTACK && is_foraging == 0)
		spawn(15)
			var/is_spooked = 0
			for(var/mob/living/L in can_see)
				if(is_spooked(L))
					is_spooked = 1
			if(!is_spooked)
				calm_down()

/mob/living/simple_animal/hostile/quarmok/proc/calm_down()
	retreat_distance = 0
	minimum_distance = 0
	LoseTarget()
