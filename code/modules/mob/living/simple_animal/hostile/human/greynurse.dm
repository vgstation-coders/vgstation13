///////////////////////////////////////////////////////////////////NURSE?///////////

/mob/living/simple_animal/hostile/humanoid/greynurse
	name = "Grey Nurse"
	desc = "A thin alien humanoid in a nurse uniform. She is holding a disintegrator and a paralytic autoinjector."
	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "grey_nurse"
	icon_living = "grey_nurse"
	see_in_dark = 12 // superior ayy darkvision
	maxHealth = 200
	health = 200

	vision_range = 12
	aggro_vision_range = 12
	idle_vision_range = 12 // Can see a bit further due to being a "special" mob

	melee_damage_lower = 20
	melee_damage_upper = 30

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
	acidimmune = 1

	projectiletype = /obj/item/projectile/beam/scorchray
	projectilesound = 'sound/weapons/ray1.ogg'
	retreat_distance = 2
	minimum_distance = 1
	ranged = 1

	items_to_drop = list(/obj/item/weapon/gun/energy/smalldisintegrator, /obj/item/weapon/reagent_containers/hypospray/autoinjector/paralytic_injector)

	speak = list("My work is never done.","No vulgar language around the greylings.","A well-cared for greyling today is a productive member of the mothership tomorrow.")
	speak_chance = 5

	var/last_suxameth = 0
	var/const/suxameth_cooldown = 20 SECONDS

	var/melee_throw_chance = 65 // Values for flinging a target away with a melee attack
	var/melee_throw_speed = 2
	var/melee_throw_range = 4

/mob/living/simple_animal/hostile/humanoid/greynurse/Life() // If we've got a paralytic shot ready, run in. If not, stay further back. Sprite will also update to show if she has a paralytic injector ready or not
	..()
	if(last_suxameth + suxameth_cooldown < world.time)
		icon_state = "grey_nurse"
		icon_living = "grey_nurse"
		retreat_distance = 2
		minimum_distance = 1
	if(last_suxameth + suxameth_cooldown > world.time)
		icon_state = "grey_nurse1"
		icon_living = "grey_nurse1"
		retreat_distance = 2
		minimum_distance = 2

/mob/living/simple_animal/hostile/humanoid/greynurse/Aggro()
	..()
	say(pick("Visitation hours for the greylings are over. Your breach of protocol will see you disintegrated.","You are making the greylings nervous, and you are not authorized to be here. The penalty is immediate disintegration."), all_languages[LANGUAGE_GREY])

/mob/living/simple_animal/hostile/humanoid/greynurse/AttackingTarget()
	var/mob/living/carbon/human/H = target
	if((last_suxameth + suxameth_cooldown < world.time) && ishuman(H))
		visible_message("<b><span class='warning'>[src] injects [H] with a paralytic autoinjector!</span>")
		say(pick("This will help you relax.","Now count backwards from ten."), all_languages[LANGUAGE_GREY])
		playsound(src, 'sound/items/hypospray.ogg', 50, 1)
		H.reagents.add_reagent(SUX, 10)
		last_suxameth = world.time
	else if((last_suxameth + suxameth_cooldown > world.time) && istype(target, /mob/living))
		var/mob/living/M = target
		if(melee_throw_range && prob(melee_throw_chance))
			visible_message("<span class='danger'>The force of the blow sends [M] flying!</span>")
			if(ishuman(M))
				M.Knockdown(2)
			var/turf/T = get_turf(src)
			var/turf/target_turf
			if(istype(T, /turf/space)) // if ended in space, then range is unlimited
				target_turf = get_edge_target_turf(T, dir)
			else
				target_turf = get_ranged_target_turf(T, dir, melee_throw_range)
			M.throw_at(target_turf,100,melee_throw_speed)
		..()

/mob/living/simple_animal/hostile/humanoid/greynurse/emp_act(severity) // Vulnerable to emps due to the truth beneath
	if(flags & INVULNERABLE)
		return

	switch (severity)
		if (1)
			adjustBruteLoss(30)
			spark(src)

		if (2)
			adjustBruteLoss(10)
			spark(src)

/mob/living/simple_animal/hostile/humanoid/greynurse/death(var/gibbed = FALSE) // The truth revealed
	visible_message("<span class=danger><B>The Nurse's flesh sloughs off in several places, revealing metal parts underneath! </span></B>")
	playsound(src, 'sound/effects/flesh_squelch.ogg', 50, 1)
	playsound(src, 'sound/misc/grue_screech.ogg', 50, 1)
	new /obj/effect/gibspawner/genericmothership(src.loc)
	new /mob/living/simple_animal/hostile/humanoid/nurseunit(get_turf(src))
	..(gibbed)

/mob/living/simple_animal/hostile/humanoid/greynurse/GetAccess()
	return list(access_mothership_general, access_mothership_maintenance, access_mothership_military, access_mothership_research, access_mothership_leader)

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
	see_in_dark = 12 // superior ayy darkvision
	move_to_delay = 1.8 // She faster now. Can just about keep pace with someone in a hardsuit
	maxHealth = 350
	health = 350

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
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS | OPEN_DOOR_STRONG | OPEN_DOOR_SMART // Now angered, so will smash things in addition to forcing doors open
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
	acidimmune = 1

	items_to_drop = list(/obj/item/device/mmi/posibrain, /obj/item/weapon/cell/ultra, /obj/item/clothing/head/nursehat) // Imagine the fun story this could make if a ghost jumps into the posibrain. "I pulled you out of a murderous cyborg wearing the skin of a grey nurse."

	speak = list("Repairs required, synthetic dermal layer has sustained significant damage.","Scanning for a repair station.","Unit's current appearance may cause greylings distress, please contact a service technician.")
	speak_chance = 5

	ranged_message = "charges"
	ranged_cooldown = 6
	ranged_cooldown_cap = 6
	ranged = 1

	var/dash_dir = null
	var/turf/crashing = null

/mob/living/simple_animal/hostile/humanoid/nurseunit/Aggro()
	..()
	say(pick("Unauthorized personnel detected, neutralizing.","Unit can no longer interface with disintegrator, proceeding with manual termination.","Source of greyling distress detected. Erasing."), all_languages[LANGUAGE_GREY])

/mob/living/simple_animal/hostile/humanoid/nurseunit/AttackingTarget()
	var/mob/living/carbon/human/H = target

	if(H.lying && !H.locked_to) // Grapple attack
		spawn(2 SECONDS) // Nurse waits a moment before grabbing a prone victim, so the transition doesn't look so abrupt
			if(H.lying && !H.locked_to)
				visible_message("<b><span class='warning'>[src] grabs [H] by the neck with its claws, and raises its injector-tipped limbs!</span>")
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

	if(!H.lying && !H.locked_to) // Normal attack, chance of brief stun
		if(ishuman(H) && prob(25))
			visible_message("<span class='danger'>[src]'s vicious assault knocks [H] down!</span>")
			H.Knockdown(3)
			H.Stun(3)

		..()

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

/mob/living/simple_animal/hostile/humanoid/nurseunit/Shoot(var/atom/target, var/atom/start, var/mob/user, var/bullet = 0)
	var/list/atom/movable/locked = get_locked(/datum/locking_category/nurseunit_latch)
	if(locked.len)
		return 0
	else
		src.throw_at(target,4,1)
		return 1

/datum/locking_category/nurseunit_latch

/mob/living/simple_animal/hostile/humanoid/nurseunit/emp_act(severity) // Even more vulnerable to emps now
	if(flags & INVULNERABLE)
		return

	switch (severity)
		if (1)
			adjustBruteLoss(70)
			spark(src)

		if (2)
			adjustBruteLoss(50)
			spark(src)

/mob/living/simple_animal/hostile/humanoid/nurseunit/death(var/gibbed = FALSE)
	visible_message("<span class='warning'>The <b>[src]</b> blows apart into chunks of flesh and circuitry!")
	playsound(src, 'sound/effects/flesh_squelch.ogg', 50, 1)
	new /obj/effect/gibspawner/genericmothership(src.loc)
	new /obj/effect/gibspawner/robot(src.loc)
	..(gibbed)

/mob/living/simple_animal/hostile/humanoid/nurseunit/to_bump(var/atom/obstacle) // Borrowed from armored constructs. Allows the nurse to use a charge attack that can shatter most simple obstacles and briefly stun any unfortunate targets in the way
	if(src.throwing)
		var/breakthrough = 0
		if(istype(obstacle, /obj/structure/window/))
			var/obj/structure/window/W = obstacle
			W.shatter()
			breakthrough = 1

		else if(istype(obstacle, /obj/machinery/)) // The Nurse can smash most machines apart while charging, but it will then also need to smash the machine frame with a second charge
			var/obj/machinery/M = obstacle
			if(istype(M, /obj/machinery/door/airlock))
				var/obj/machinery/door/airlock/A = obstacle
				A.bashed_in(src)
				breakthrough = 1
			if(istype(M, /obj/machinery/constructable_frame/machine_frame))
				var/obj/machinery/constructable_frame/machine_frame/F = obstacle
				visible_message("<span class='warning'>The [src] smashes \the [F] apart!")
				drop_stack(/obj/item/stack/sheet/metal, get_turf(F), 5)
				qdel(F)
				breakthrough = 1
			else
				MachineCrash(M)
				src.throwing = 0
				src.crashing = null

		else if(istype(obstacle, /obj/structure/filingcabinet))
			var/obj/structure/filingcabinet/F = obstacle
			new /obj/item/stack/sheet/metal(loc, 2)
			qdel(F)
			breakthrough = 1

		else if(istype(obstacle, /obj/structure/grille/))
			var/obj/structure/grille/G = obstacle
			G.health = (0.25*initial(G.health))
			G.healthcheck()
			breakthrough = 1

		else if(istype(obstacle, /obj/structure/table))
			var/obj/structure/table/T = obstacle
			T.destroy()
			breakthrough = 1

		else if(istype(obstacle, /obj/structure/rack))
			new /obj/item/weapon/rack_parts(obstacle.loc)
			qdel(obstacle)
			breakthrough = 1

		else if(istype(obstacle, /turf/simulated/wall))
			var/turf/simulated/wall/W = obstacle
			if (W.hardness <= 60)
				playsound(W, 'sound/weapons/heavysmash.ogg', 75, 1)
				W.dismantle_wall(1)
				breakthrough = 1
			else
				src.throwing = 0
				src.crashing = null

		else if(istype(obstacle, /obj/structure/reagent_dispensers))
			var/obj/structure/reagent_dispensers/R = obstacle
			R.explode(src)

		else if(istype(obstacle, /mob/living))
			var/mob/living/L = obstacle
			if (L.flags & INVULNERABLE)
				src.throwing = 0
				src.crashing = null
			else if (!(L.status_flags & CANKNOCKDOWN) || (M_HULK in L.mutations) || istype(L,/mob/living/silicon))
				//can't be knocked down? you'll still take the damage.
				src.throwing = 0
				src.crashing = null
				L.take_overall_damage(5,0)
				if(L.locked_to)
					L.locked_to.unlock_atom(L)
			else
				L.take_overall_damage(5,0)
				if(L.locked_to)
					L.locked_to.unlock_atom(L)
				L.Stun(3)
				L.Knockdown(3)
				playsound(src, 'sound/weapons/heavysmash.ogg', 50, 0, 0)
				breakthrough = 1
		else
			src.throwing = 0
			src.crashing = null

		if(breakthrough)
			if(crashing && !istype(crashing,/turf/space))
				spawn(1)
					src.throw_at(crashing, 50, src.throw_speed)
			else
				spawn(1)
					crashing = get_distant_turf(get_turf(src), dash_dir, 2)
					src.throw_at(crashing, 50, src.throw_speed)

	if(istype(obstacle, /obj))
		var/obj/O = obstacle
		if(!O.anchored)
			step(obstacle,src.dir)
		else
			obstacle.Bumped(src)
	else if(istype(obstacle, /mob))
		step(obstacle,src.dir)
	else
		obstacle.Bumped(src)

/mob/living/simple_animal/hostile/humanoid/nurseunit/proc/MachineCrash(var/obj/machinery/M) // Borrowed from gourmonger code, necessary step for allowing the mob to shatter machinery
	for(var/mob/living/L in M.contents)
		L.forceMove(M.loc)

	if(M.machine_flags & CROWDESTROY)
		visible_message("<span class='warning'>The [src] smashes \the [M] apart!")
		M.dropFrame()
		M.spillContents()
		qdel(M)

	if(M.wrenchable())
		M.state = 0
		M.anchored = FALSE
		M.power_change()

	M.ex_act(1)

/mob/living/simple_animal/hostile/humanoid/nurseunit/GetAccess()
	return list(access_mothership_general, access_mothership_maintenance, access_mothership_military, access_mothership_research, access_mothership_leader)

/mob/living/simple_animal/hostile/humanoid/nurseunit/New()
	..()
	languages += all_languages[LANGUAGE_GREY]
