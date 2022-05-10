///////////////////////////////////////////////////////////////////NURSE?///////////

/mob/living/simple_animal/hostile/humanoid/greynurse
	name = "Grey Nurse"
	desc = "A thin alien humanoid in a nurse uniform. She is holding a disintegrator and a paralytic autoinjector."
	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "grey_nurse"
	icon_living = "grey_nurse"
	see_in_dark = 10 // superior ayy darkvision
	maxHealth = 150
	health = 150

	vision_range = 12
	aggro_vision_range = 12
	idle_vision_range = 12 // Can see a bit further due to being a "special" mob

	melee_damage_lower = 15
	melee_damage_upper = 25

	attacktext = "bashes"
	attack_sound = 'sound/weapons/smash.ogg'

	mob_property_flags = MOB_ROBOTIC
	blooded = FALSE

	status_flags = UNPACIFIABLE // Not pacifiable due to being a "special" mob
	environment_smash_flags = 0 // Won't smash stuff. Smashing would scare the greylings
	stat_attack = UNCONSCIOUS // Help nurse, I've fallen and can't get up

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	maxbodytemp = 1000 // There's a reason for this

	corpse = null
	faction = "mothership"
	var/suxameth_chance = 25 // In this state she won't be trying to get close anyways, but this makes trying to take her down with melee very dangerous
	acidimmune = 1

	projectiletype = /obj/item/projectile/beam/scorchray
	projectilesound = 'sound/weapons/ray1.ogg'
	retreat_distance = 7
	minimum_distance = 7
	ranged = 1

	items_to_drop = list(/obj/item/weapon/gun/energy/smalldisintegrator, /obj/item/weapon/reagent_containers/hypospray/autoinjector/paralytic_injector)

	speak = list("My work is never done.","No vulgar language around the greylings.","A well-cared for greyling today is a productive member of the mothership tomorrow.")
	speak_chance = 5

/mob/living/simple_animal/hostile/humanoid/greynurse/Aggro()
	..()
	say(pick("Visitation hours for the greylings are over. Your breach of protocol will see you disintegrated.","You are making the greylings nervous, and you are not authorized to be here. The penalty is immediate disintegration."), all_languages[LANGUAGE_GREY])

/mob/living/simple_animal/hostile/humanoid/greynurse/AttackingTarget()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(prob(suxameth_chance))
			if(H.reagents)
				visible_message("<b><span class='warning'>[src] injects [H] with a paralytic autoinjector!</span>")
				playsound(src, 'sound/items/hypospray.ogg', 50, 1)
				H.reagents.add_reagent(SUX, 10)
		else
			..()

/mob/living/simple_animal/hostile/humanoid/greynurse/emp_act(severity) // Vulnerable to emps due to the truth beneath
	if(flags & INVULNERABLE)
		return

	switch (severity)
		if (1)
			adjustBruteLoss(30)

		if (2)
			adjustBruteLoss(10)

/mob/living/simple_animal/hostile/humanoid/greynurse/death(var/gibbed = FALSE) // The truth revealed
	visible_message("<span class=danger><B>The Nurse's flesh sloughs off in several places, revealing metal parts underneath! </span></B>")
	playsound(src, 'sound/effects/flesh_squelch.ogg', 50, 1)
	playsound(src, 'sound/misc/grue_screech.ogg', 50, 1)
	new /obj/effect/gibspawner/genericmothership(src.loc)
	new /mob/living/simple_animal/hostile/humanoid/nurseunit(get_turf(src))
	..(gibbed)

/mob/living/simple_animal/hostile/humanoid/greynurse/New() // she can also speak quack
	..()
	languages += all_languages[LANGUAGE_GREY]

///////////////////////////////////////////////////////////////////ANGRY NURSE///////////

/mob/living/simple_animal/hostile/humanoid/nurseunit
	name = "Nurse Unit"
	desc = "A twisted creature of grey flesh and metal. It has four upper limbs, one pair tipped with syringes, and the other pair with broad claws."
	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "grey_nurseunit"
	icon_living = "grey_nurseunit"
	see_in_dark = 10 // superior ayy darkvision
	move_to_delay = 1.8 // She faster now. Can just about keep pace with someone in a hardsuit
	maxHealth = 300
	health = 300

	vision_range = 12
	aggro_vision_range = 12
	idle_vision_range = 12 // Can see a bit further due to being a "boss" mob

	melee_damage_lower = 30
	melee_damage_upper = 50 // No longer ranged, but very deadly in melee combat

	attacktext = "wildly claws"
	attack_sound = 'sound/weapons/bloodyslice.ogg'

	mob_property_flags = MOB_ROBOTIC
	blooded = FALSE

	status_flags = UNPACIFIABLE // Not pacifiable due to being a "boss" mob
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG | OPEN_DOOR_SMART // Now angered, so will smash things in addition to forcing doors open
	stat_attack = UNCONSCIOUS // Help nurse, I've fallen and can't get up

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	maxbodytemp = 1000

	corpse = null
	faction = "mothership"
	var/knockdown_chance = 25
	acidimmune = 1

	items_to_drop = list(/obj/item/device/mmi/posibrain, /obj/item/weapon/cell/ultra, /obj/item/clothing/head/nursehat) // Imagine the fun story this could make if a ghost jumps into the posibrain. "I pulled you out of a murderous cyborg wearing the skin of a grey nurse."

	speak = list("Repairs required, synthetic dermal layer has sustained significant damage.","Scanning for a repair station.","Unit's current appearance may cause greylings distress, please contact a service technician.")
	speak_chance = 5

/mob/living/simple_animal/hostile/humanoid/nurseunit/Aggro()
	..()
	say(pick("Unauthorized personnel detected, neutralizing.","Unit can no longer interface with disintegrator, proceeding with manual termination.","Source of greyling distress detected. Erasing."), all_languages[LANGUAGE_GREY])

/mob/living/simple_animal/hostile/humanoid/nurseunit/AttackingTarget()
	var/mob/living/carbon/human/H = target

	if(!H.lying && !H.locked_to && ishuman(H) && prob(knockdown_chance)) // Knockdown attack
		H.visible_message("<span class='danger'>[src] slams into [H], knocking them down!</span>")
		playsound(src, 'sound/weapons/smash.ogg', 50, 1)
		H.adjustBruteLoss(10)
		H.Knockdown(3)

	if(!H.lying && !H.locked_to && !prob(knockdown_chance)) // Normal attack
		..()

	if(H.lying && !H.locked_to) // Grapple attack
		spawn(2 SECONDS) // Nurse waits a moment before grabbing a prone victim, so the transition doesn't look so abrupt
			if(H.lying && !H.locked_to)
				H.visible_message("<b><span class='warning'>[src] grabs [H] by the neck with its claws, and raises its injector-tipped limbs!</span>")
				say("[pick("Please hold still for your termination.", "I promise this won't hurt a bit.", "Neutralization in progress.")]")
				lock_atom(H, /datum/locking_category/nurseunit_latch)

	if(H.locked_to == src) // Grapple follow-up
		spawn(5 SECONDS) // Probably not the best way to write it, but this allows a player about five seconds to attempt an escape before getting injected
			if(H.locked_to == src && H.isDead()) // If the humanoid in its grip is dead, just drop it
				say("[pick("It was for the good of the mothership.", "Neutralization protocol complete.", "Subject terminated.")]")
				unlock_atom(H)

			if(H.locked_to == src && !H.isDead() && H.incapacitated()) // If the humanoid in its grip is not dead but incapable of struggling, proceed with the killing
				if(ishuman(H))
					visible_message("<b><span class='warning'>[src] grabs [H]'s head with its claws and starts to squeeze!</span>")
					var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
					if(head_organ)
						head_organ.take_damage(40) // Ouch, head is being crushed
				if(ismonkey(H))
					visible_message("<b><span class='warning'>[src] starts to tighten its grip on [H]'s body, crushing them!</span>") // Needs a special check for monkeys, otherwise it doesn't damage them
					H.adjustBruteLoss(50) // Monkeys are smaller, so more damage
				if(isalien(H))
					visible_message("<b><span class='warning'>[src] starts to tighten its grip on [H]'s body, crushing them!</span>") // Needs a check for aliens too, it seems
					H.adjustBruteLoss(30) // Xenos are tougher nuts to crack, so a bit less damage

			if(H.locked_to == src && !H.isDead() && !H.incapacitated()) // If the humanoid in its grip is not dead and capable of struggling, pacify it with an injection
				visible_message("<b><span class='warning'>[src] injects [H] with its syringes!</span>")
				playsound(src, 'sound/items/hypospray.ogg', 50, 1)
				H.reagents.add_reagent(OXYCODONE, 5)
				H.reagents.add_reagent(NEUROTOXIN, 25)

/mob/living/simple_animal/hostile/humanoid/nurseunit/relaymove(mob/user)// Resisting out of the bot's grip takes strength level from mutations or other sources into account
	var/mob/living/carbon/human/H = user
	if(istype(H))
		if(user.incapacitated()) // Can't resist when stunned or unconscious
			return

		if(H.get_strength() > 2) // Are we TOO SWOLE TO CONTROL?! Breaking free is guaranteed!
			to_chat(user, "<span class='warning'>You start to loosen the [src]'s weak grip!</span>")
			if(do_after(user, src, 10)) // 1 second resist time, 100% chance of success
				to_chat(user, "<span class='warning'>You pull the [src]'s claws off your neck with minimal effort, freeing yourself!</span>")
				unlock_atom(H)

		if(H.get_strength() == 2) // Are we stronger than average due to a mutation or other bonus? Boost resistance chance!
			to_chat(user, "<span class='warning'>You wrestle furiously against the [src]'s grip!</span>")
			if(do_after(user, src, 10)) // 1 second resist time, 50% chance of success
				if(prob(50))
					to_chat(user, "<span class='warning'>The [src] barely manages to keep its hold on you! It tightens its claws around your neck desperately!</span>")
					H.adjustOxyLoss(5)
				else
					to_chat(user, "<span class='warning'>You yank the [src]'s claws off your neck with a mighty effort, freeing yourself!</span>")
					unlock_atom(H)

		if(H.get_strength() < 2) // Are we just average strength? We get the lowest chance of successfully escaping
			to_chat(user, "<span class='warning'>You struggle to get free of the [src]'s grip!</span>")
			if(do_after(user, src, 10)) // 1 second resist time, 25% chance of success with no other modifiers
				if(prob(75))
					to_chat(user, "<span class='warning'>You fail to get free of the [src]'s grip, and it tightens its claws around your neck mercilessly!</span>")
					H.adjustOxyLoss(10)
				else
					to_chat(user, "<span class='warning'>You manage to pry the [src]'s claws off your neck, freeing yourself!</span>")
					unlock_atom(H)

/mob/living/simple_animal/hostile/humanoid/nurseunit/attackby(obj/item/W, mob/user) // A strong melee attack can cause the nurse to lose its grip, and has a better chance than resisting without mutations
	var/list/atom/movable/locked = get_locked(/datum/locking_category/nurseunit_latch)
	if (locked.len && (W.force >= 15))
		if(prob(40))
			for(var/atom/H in locked)
				unlock_atom(H)
				visible_message("<span class='warning'>The [src]'s grip on [H] falters, and it drops them!</span>")
		else
			for(var/atom/H in locked)
				visible_message("<span class='warning'>The [src]'s grip on [H] falters for a moment, but it quickly recovers!</span>")
	..()

/datum/locking_category/nurseunit_latch

/mob/living/simple_animal/hostile/humanoid/nurseunit/emp_act(severity) // Even more vulnerable to emps now
	if(flags & INVULNERABLE)
		return

	switch (severity)
		if (1)
			adjustBruteLoss(50)

		if (2)
			adjustBruteLoss(30)

/mob/living/simple_animal/hostile/humanoid/nurseunit/death(var/gibbed = FALSE)
	visible_message("The <b>[src]</b> blows apart into chunks of flesh and circuitry!")
	playsound(src, 'sound/effects/flesh_squelch.ogg', 50, 1)
	new /obj/effect/gibspawner/genericmothership(src.loc)
	new /obj/effect/gibspawner/robot(src.loc)
	..(gibbed)

/mob/living/simple_animal/hostile/humanoid/nurseunit/New()
	..()
	languages += all_languages[LANGUAGE_GREY]
