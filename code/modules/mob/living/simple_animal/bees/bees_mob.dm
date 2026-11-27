//Beekeeping 3.0 on 07/20/2017 by Deity Link

#define TIME_TO_POLLINATE	4//how long (in seconds) will a bee remain on a plant before moving to the next one
#define DURATION_OF_POLLINATION	8//how long (in seconds) will the plant be enhanced by the bees (starts as soon as the bees begin pollination)
#define FATIGUE_PER_POLLINATIONS	4//how much extra fatigue does the bee receive from performing a successful pollination (if set to 0, the bee won't stop until there are no more flowers in range)
#define FATIGUE_TO_RETURN	20//once reached, the bee will head back to its hive

#define BOREDOM_TO_RETURN	30//once reached, the bee will head back to its hive

#define EXHAUSTION_TO_DIE	300//once reached, the bee will begin to die

var/bee_mobs_count = 0

//Lingering effects that keep bees calm while they carry water or holy water.
//Direct splashes are handled by /datum/reagent/water/reaction_animal
var/list/bee_calmers = list(
	/obj/effect/decal/chemical_puff,
	/obj/effect/smoke/chem,
	/obj/effect/water,
	/obj/effect/foam,
	)

/mob/living/simple_animal/bee
	name = "swarm of bees"
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "bees1"
	icon_dead = "bee_dead"

	mob_property_flags = MOB_SWARM
	size = SIZE_TINY
	can_butcher = 0

	var/intent_change = 0//if set to 1, the bee mob will check if it should split based on its bee datums' intents
	var/intent = BEE_ROAMING//this controls the bee's current behaviour
	var/atom/destination = null
	var/list/bees = list()
	var/mob/target = null
	var/turf/target_turf = null
	var/current_physical_damage = 0
	var/current_poison_damage = 0
	var/obj/machinery/apiary/home = null
	var/calmed = 0
	var/pollinating = 0
	var/obj/machinery/portable_atmospherics/hydroponics/target_plant = null
	var/list/visited_plants = list()
	var/datum/bee_species/bee_species = null
	var/turf/building = null
	pass_flags = PASSTABLE | PASSRAILING
	turns_per_move = 6
	density = 0
	gender = PLURAL

	// Allow final solutions.
	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	maxbodytemp = 360

	holder_type = null //Can't pick BEES up!
	flying = 1
	meat_type = 0

	held_items = list()

	blooded = FALSE // certainly not enough blood there to matter

	var/single_direction = TRUE

/mob/living/simple_animal/bee/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	..()
	if (single_direction)
		dir = SOUTH

///////////////////////////////Basic Procs//////////////////////////////////

/mob/living/simple_animal/bee/New(loc, var/obj/machinery/apiary/new_home)
	..()
	bee_mobs_count++
	home = new_home
	// WIP: the behavior tree controller drives the swarm AI (bt_bee_tree()).
	use_idle_tree(bt_bee_tree())


/mob/living/simple_animal/bee/Destroy()
	walk(src, 0) //walk_to holds a ref even after the function returns so it needs to be canceled manually
	apiary_reservation -= src //we may have been added by reserve_apiary() and not yet removed by its spawn(300) (lmao)
	bee_mobs_count--
	if(home)
		for (var/datum/bee/B in bees)
			home.bees_outside_hive -= B
		home = null
	destination = null
	target = null
	target_turf = null
	target_plant = null
	building = null
	for (var/datum/bee/B in bees)
		qdel(B)//it'll get removed from the bees list in the datum's Destroy() proc.
	bees.len = 0
	visited_plants.len = 0
	..()

/mob/living/simple_animal/bee/death(var/gibbed = FALSE)
	..(gibbed)
	qdel(src)

/mob/living/simple_animal/bee/gib(var/animation = 0, var/meat = 1)
	if(status_flags & BUDDHAMODE)
		adjustBruteLoss(200)
		return
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	dead_mob_list -= src

	qdel(src)

/mob/living/simple_animal/bee/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover, /obj/item/projectile) && !istype(mover, /obj/item/projectile/bullet/beegun))

		//Projectiles are more likely to hit if there are many bees in the swarm
		if (prob(min(100,bees.len * 4)))
			return 0
	return 1

//DEALING WITH DAMAGE
/mob/living/simple_animal/bee/attackby(var/obj/item/O as obj, var/mob/user as mob)
	user.delayNextAttack(8)
	if (istype(O,/obj/item/weapon/bee_net)) return
	if (user.is_pacified(VIOLENCE_DEFAULT,src)) return
	if(O.force)
		var/damage = O.force
		if (O.damtype == HALLOSS)
			damage = 0
		adjustBruteLoss(damage)
		user.visible_message("<span class='danger'>[src] has been attacked with [O] by [user]. </span>")
		panic_attack(user)

/mob/living/simple_animal/bee/hitby(AM as mob|obj)
	. = ..()
	if(.)
		return
	visible_message("<span class='warning'>\The [src] was hit by \the [AM].</span>", 1)
	var/mob/M = null
	if (ismob(AM))
		M = AM
	panic_attack(M)

/mob/living/simple_animal/bee/bullet_act(var/obj/item/projectile/P)
	. = ..()
	if(P && P.firer)
		panic_attack(P.firer)

/mob/living/simple_animal/bee/ex_act(severity)
	switch(severity)
		if (1)
			qdel(src)
		if (2)
			adjustBruteLoss(100)
		if (3)
			adjustBruteLoss(20)

/mob/living/simple_animal/bee/nuke_act()
	//first of all, we don't want more bees to come out of a hive that got nuked (for now at least)
	if (home && home.z == z)
		home.queen_bees_inside = 0
		home.worker_bees_inside = 0

	//this may or may not kill them all, but it'll at least spawn a good amount of bee corpses
	adjustBruteLoss(100)

	//cleanup
	if (src)
		qdel(src)

/mob/living/simple_animal/bee/reagent_act(id, method, volume)
	if(isDead())
		return

	.=..()

	switch(id)
		if(TOXIN)
			visible_message("<span class='danger'>The bees stop moving...</span>")
			adjustBruteLoss(rand(40,110)) //Kills 4-11 bees. Maximum bees per swarm 20.
			panic_attack() //Bees don't know who is responsible, but they'll get mad at everyone!
		if(INSECTICIDE)
			visible_message("<span class='danger'>The bees writhe in agony before falling to the floor, dead.</span>")
			adjustBruteLoss(rand(90,180)) //Since insecticide is designed to kill insects rather than just being generally poisonous, kills from 9 to 18.
			panic_attack()

/mob/living/simple_animal/bee/unarmed_attacked(mob/living/attacker, damage, damage_type, zone)
	..()
	panic_attack(attacker)

/mob/living/simple_animal/bee/attack_paw(var/mob/M)
	..()
	panic_attack(M)

/mob/living/simple_animal/bee/attack_alien(var/mob/M)
	..()
	panic_attack(M)

/mob/living/simple_animal/bee/kick_act(mob/living/carbon/human/H)
	if(prob(10))
		..()

	panic_attack(H)

/mob/living/simple_animal/bee/bite_act(mob/living/carbon/human/H)
	if(prob(10))
		..()

	panic_attack(H)

/mob/living/simple_animal/bee/adjustBruteLoss(var/amount)
	if(status_flags & GODMODE)
		return 0

	while (amount > 0 && bees.len)
		var/datum/bee/B = pick(bees)
		if (B.health > amount)
			B.health -= amount
			amount = 0
		else
			amount -= B.health
			B.death()

	if (bees.len <= 0)
		qdel(src)
	updateDamage()


////////////////////////////////LIFE////////////////////////////////////////

/mob/living/simple_animal/bee/Life()
	if(timestopped)
		return 0
	..()

/*
 * Behavior tree leaves. The swarm intent (intent) is still set by the bee datum
 * mood changes; the leaves gate on it and run the same steps the legacy Life()
 * state machine did. A sequence runs upkeep before the intent action each tick.
 */

/datum/bt_node/ai_behavior/bee_action
/datum/bt_node/ai_behavior/bee_action/proc/get_bee(datum/ai_controller/controller)
	var/mob/living/simple_animal/bee/bee = controller.pawn
	if(!istype(bee, /mob/living/simple_animal/bee) || QDELETED(bee))
		return null
	return bee

/// Shared swarm upkeep: poison, calming, merging/splitting, noise and intent.
/datum/bt_node/ai_behavior/bee_action/bee_upkeep
/datum/bt_node/ai_behavior/bee_action/bee_upkeep/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/simple_animal/bee/bee = get_bee(controller)
	if(!bee)
		return AI_BEHAVIOR_FAILED
	if(!bee.bees || bee.bees.len <= 0)
		qdel(bee)
		return AI_BEHAVIOR_SUCCEEDED
	if(!bee.bee_species)
		qdel(bee)
		return AI_BEHAVIOR_SUCCEEDED
	if(!bee.bee_species.slow && !bee.target)
		walk(bee, 0)
	if(bee.stat == DEAD)
		bee.death()
		return AI_BEHAVIOR_SUCCEEDED

	//Taking damage from high toxicity
	if(((bee.current_poison_damage - bee.bees.len) / bee.bees.len * 100) > bee.bee_species.toxic_threshold_death)
		if(prob((((bee.current_poison_damage - bee.bees.len) / bee.bees.len * 100) - 50) * 2))
			bee.adjustBruteLoss(3)
		if(bee.bees.len <= 0)
			return AI_BEHAVIOR_SUCCEEDED

	//Calming bees
	for(var/obj/effect/check_effect in bee.loc)
		if(check_effect.reagents && is_type_in_list(check_effect, bee_calmers) && \
			(check_effect.reagents.has_reagent(WATER) || check_effect.reagents.has_reagent(HOLYWATER)))
			bee.calming()
			break

	if(bee.calmed > 0)
		bee.calmed--
		//Calmed bees will split apart until there's no more than 5 bee per swarm.
		if(bee.target)
			bee.target = null
		if(bee.bees.len > 5)
			//calm down and spread out a little
			var/list/bees_to_split = list()
			for(var/datum/bee/B in bee.bees)
				if(bees_to_split.len == 0 || prob(33))
					bees_to_split += B
					if(bees_to_split.len >= 5)
						break
			step_rand(bee.SplitSwarm(bees_to_split, bee.intent))

		if(!bee.calmed)//wild bees will re-become angry right away
			for(var/datum/bee/B in bee.bees)
				if(B.wild)
					B.intent = BEE_OUT_FOR_ENEMIES
					bee.intent_change = 1

	//A change of intent has been detected among the swarm so we'll split up if needed and re-assess our current main intent
	if(bee.intent_change)
		bee.UpdateIntent()

	//Making noise
	if(prob(1))
		if(prob(50))
			bee.visible_message("<span class='notice'>[pick("Buzzzz.","Hmmmmm.","Bzzz.")]</span>")
		playsound(bee, 'sound/effects/bees.ogg', min(20 * bee.bees.len, 100), 1)

	//If there are other bee mobs on our tile we might group up with them
	for(var/mob/living/simple_animal/bee/B_mob in bee.loc)
		if(B_mob == bee)
			continue
		//bees don't mix with bees from other hives
		if(B_mob.home != bee.home)
			continue
		//or other species
		if(B_mob.bee_species != bee.bee_species)
			continue
		//no more than 20 bees per swarm to avoid people abusing their damage
		if(bee.bees.len + B_mob.bees.len > MAX_BEES_PER_SWARM)
			continue
		//angry bees will drag other bees along with them
		if(bee.intent == BEE_OUT_FOR_ENEMIES)
			if((prob(10) && B_mob.intent == BEE_OUT_FOR_PLANTS) || (prob(60) && B_mob.intent == BEE_OUT_FOR_ENEMIES))
				bee.MergeSwarms(B_mob)
		else if((bee.intent == BEE_BUILDING) || (prob(30) && bee.intent != BEE_OUT_FOR_ENEMIES && bee.pollinating <= 0 && B_mob.pollinating <= 0 && bee.intent == B_mob.intent))
			bee.MergeSwarms(B_mob)

	//We might also randomly split up, with increased chance the more bees in the swarm
	if(bee.bees.len > 1 && bee.pollinating <= 0 && prob(bee.bees.len * 2) && bee.intent != BEE_SWARM && bee.intent != BEE_BUILDING && bee.intent != BEE_HEADING_HOME)
		var/queen = 0
		for(var/single_B in bee.bees)
			if(istype(single_B, /datum/bee/queen_bee))
				queen = 1
				break
		if(bee.intent != BEE_ROAMING || !queen)//homeless bees spread out if there's no queen among them
			step_rand(bee.SplitSwarm(list(pick(bee.bees)), bee.intent))

	return AI_BEHAVIOR_SUCCEEDED

/// Out for enemies: chase and sting, then get bored and go home.
/datum/bt_node/ai_behavior/bee_action/bee_combat
/datum/bt_node/ai_behavior/bee_action/bee_combat/setup(datum/ai_controller/controller)
	var/mob/living/simple_animal/bee/bee = get_bee(controller)
	return bee && bee.intent == BEE_OUT_FOR_ENEMIES

/datum/bt_node/ai_behavior/bee_action/bee_combat/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/simple_animal/bee/bee = get_bee(controller)
	if(!bee)
		return AI_BEHAVIOR_FAILED
	bee.target_turf = null
	if(bee.target && (bee.target in view(bee, 7)) && bee.target.stat != DEAD)
		bee.target_turf = get_turf(bee.target)
		bee.wander = 0
	else
		bee.FindTarget()

	if(bee.target_turf)
		bee.MoveToTarget()
		if(bee.loc == bee.target_turf)
			bee.wander = 1

	if(bee.target in view(bee, 1))
		bee.AttackTarget()

	//bees out for enemies eventually get bored and go back home
	for(var/datum/bee/B in bee.bees)
		if(!B.wild)//unless they're "wild"!
			B.bored++
			if(B.bored > BOREDOM_TO_RETURN)
				if(B.home)
					B.homeCall()
	return AI_BEHAVIOR_SUCCEEDED

/// Out for plants: fly to a hydroponics tray and pollinate it.
/datum/bt_node/ai_behavior/bee_action/bee_pollinate
/datum/bt_node/ai_behavior/bee_action/bee_pollinate/setup(datum/ai_controller/controller)
	var/mob/living/simple_animal/bee/bee = get_bee(controller)
	return bee && bee.intent == BEE_OUT_FOR_PLANTS

/datum/bt_node/ai_behavior/bee_action/bee_pollinate/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/simple_animal/bee/bee = get_bee(controller)
	if(!bee)
		return AI_BEHAVIOR_FAILED
	if(bee.pollinating <= 0)
		bee.target_turf = null
		if(bee.target_plant && (bee.target_plant in view(bee, 7)))
			bee.target_turf = get_turf(bee.target_plant)
			bee.wander = 0
		else
			var/list/nearbyPlants = list()
			for(var/obj/machinery/portable_atmospherics/hydroponics/H in view(bee, 2))
				if(!H.dead && H.seed && !H.closed_system)
					nearbyPlants += H
			nearbyPlants -= bee.visited_plants
			if(nearbyPlants.len > 0)
				bee.target_plant = pick(nearbyPlants)
			else
				for(var/datum/bee/B in bee.bees)
					B.fatigue++
					if(B.fatigue > FATIGUE_TO_RETURN)
						B.homeCall()
		if(bee.target_turf)
			if(bee.calmed <= 0)
				var/turf/loc_old = bee.loc
				step_to(bee, bee.target_turf)
				if(bee.loc == loc_old)//our path is blocked for whatever reason
					for(var/datum/bee/B in bee.bees)
						B.fatigue++
						if(B.fatigue > FATIGUE_TO_RETURN)
							B.homeCall()
			if(bee.loc == bee.target_turf)
				bee.add_plants(list(bee.target_plant))
				bee.pollinating = TIME_TO_POLLINATE
				bee.target_plant.pollination = DURATION_OF_POLLINATION//technically the plant gets the benefits immediately
	else if(bee.pollinating > 0)
		bee.pollinating--
		if(bee.pollinating == 0)
			for(var/datum/bee/B in bee.bees)
				B.pollens += bee.target_plant.seed
				B.toxins += bee.target_plant.get_toxinlevel()
				B.fatigue += FATIGUE_PER_POLLINATIONS
				if(B.fatigue > FATIGUE_TO_RETURN)
					B.homeCall()
			bee.target_plant = null
			bee.wander = 1
	return AI_BEHAVIOR_SUCCEEDED

/// Heading home (or the swarm call): return to the apiary and enter it.
/datum/bt_node/ai_behavior/bee_action/bee_go_home
/datum/bt_node/ai_behavior/bee_action/bee_go_home/setup(datum/ai_controller/controller)
	var/mob/living/simple_animal/bee/bee = get_bee(controller)
	return bee && (bee.intent == BEE_HEADING_HOME || bee.intent == BEE_SWARM)

/datum/bt_node/ai_behavior/bee_action/bee_go_home/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/simple_animal/bee/bee = get_bee(controller)
	if(!bee)
		return AI_BEHAVIOR_FAILED
	bee.wander = 0
	bee.target_turf = bee.home ? get_turf(bee.home) : null
	if(bee.target_turf)
		if(bee.loc == bee.target_turf)
			if(!bee.home.species || bee.bee_species == bee.home.species)
				for(var/datum/bee/B in bee.bees)
					bee.home.enterHive(B)
				qdel(bee)
				return AI_BEHAVIOR_SUCCEEDED
			else
				bee.visible_message("<span class='notice'>A swarm has lost its way.</span>")
				bee.home = null
				bee.mood_change(BEE_ROAMING)
		if(bee.calmed <= 0)
			step_to(bee, bee.target_turf)
	else
		bee.visible_message("<span class='notice'>A swarm has lost its way.</span>")
		bee.home = null
		bee.mood_change(BEE_ROAMING)
	return AI_BEHAVIOR_SUCCEEDED

/// Homeless swarm: group with nearby bees, find a new home or die out.
/datum/bt_node/ai_behavior/bee_action/bee_roam
/datum/bt_node/ai_behavior/bee_action/bee_roam/setup(datum/ai_controller/controller)
	var/mob/living/simple_animal/bee/bee = get_bee(controller)
	return bee && bee.intent == BEE_ROAMING

/datum/bt_node/ai_behavior/bee_action/bee_roam/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/simple_animal/bee/bee = get_bee(controller)
	if(!bee)
		return AI_BEHAVIOR_FAILED
	bee.wander = 1
	for(var/datum/bee/B in bee.bees)
		B.home = null
	bee.home = null
	//if there's a queen among us, let's gather a following
	var/datum/bee/queen_bee/queen = null
	var/list/queen_list = list()
	for(var/D in bee.bees)
		if(istype(D, /datum/bee/queen_bee))
			queen_list.Add(D)
			queen = D
	if(queen)//a queen being part of the swarm will keep it alive indefinitely
		if(bee.bees.len < MAX_BEES_PER_SWARM)
			var/turf/T = get_turf(bee.loc)
			for(var/mob/living/simple_animal/bee/B in range(bee, 3))
				if(bee.bee_species == B.bee_species && B.intent == BEE_ROAMING && B.loc != T)
					step_to(B, T)//come closer, the GROUPING segment above should take care of the merging after a moment.

		if(bee.bees.len >= 11)
			//once there's enough of us, let's find a new home
			for(var/obj/machinery/apiary/A in range(bee, 3))
				if(bee.exile_swarm(A))
					bee.mood_change(BEE_SWARM, null, A)
					A.reserve_apiary(bee)
					queen.colonizing = 1
					bee.update_icon()
					return AI_BEHAVIOR_SUCCEEDED

			for(var/datum/bee/queen_bee/QB in queen_list)
				QB.searching++
				if(QB.searching > 60)
					//and if there isn't any decent home nearby (after searching for a while)...let's build one!
					var/list/available_turfs = list()
					for(var/turf/simulated/floor/T in range(bee, 2))
						if(!T.has_dense_content() && !(locate(/obj/structure/wild_apiary) in T))
							available_turfs.Add(T)
					if(available_turfs.len > 0)
						bee.building = pick(available_turfs)
						if(bee.building)
							bee.mood_change(BEE_BUILDING)
					break
	else//swarms without a queen will eventually die of exhaustion, unless they're hornets or the produce of infestations
		for(var/datum/bee/B in bee.bees)
			if(!B.wild)
				B.exhaustion++
				if(B.exhaustion > EXHAUSTION_TO_DIE)
					bee.adjustBruteLoss(1)

	if(bee.intent == BEE_ROAMING && bee.home && bee.home.loc)
		bee.mood_change(BEE_HEADING_HOME)
	return AI_BEHAVIOR_SUCCEEDED

/// Building a wild apiary for a homeless queen-led swarm.
/datum/bt_node/ai_behavior/bee_action/bee_build
/datum/bt_node/ai_behavior/bee_action/bee_build/setup(datum/ai_controller/controller)
	var/mob/living/simple_animal/bee/bee = get_bee(controller)
	return bee && bee.intent == BEE_BUILDING

/datum/bt_node/ai_behavior/bee_action/bee_build/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/simple_animal/bee/bee = get_bee(controller)
	if(!bee)
		return AI_BEHAVIOR_FAILED
	bee.wander = 0
	var/datum/bee/queen_bee/queen = null
	for(var/D in bee.bees)
		if(istype(D, /datum/bee/queen_bee))
			queen = D
	if(queen && bee.building)
		if(bee.bees.len < MAX_BEES_PER_SWARM)//Gathering some more volunteers.
			var/turf/T = get_turf(bee.loc)
			for(var/mob/living/simple_animal/bee/B in range(bee, 3))
				if(bee.bee_species == B.bee_species && B.intent == BEE_ROAMING && B.loc != T)
					step_to(B, T)

		if(bee.building != bee.loc)
			step_to(bee, bee.building)
		else
			var/obj/structure/wild_apiary/W = locate() in bee.building
			if(W)
				W.work()
			else
				new /obj/structure/wild_apiary(bee.loc, bee.bee_species.prefix)
	else
		bee.mood_change(BEE_ROAMING)
	return AI_BEHAVIOR_SUCCEEDED

/// Refresh the swarm icon at the end of the tick.
/datum/bt_node/ai_behavior/bee_action/bee_finish
/datum/bt_node/ai_behavior/bee_action/bee_finish/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/simple_animal/bee/bee = get_bee(controller)
	if(bee)
		bee.update_icon()
	return AI_BEHAVIOR_SUCCEEDED

/// Bee tree: upkeep, then the current swarm intent, then the icon refresh.
/proc/bt_bee_tree()
	return list(
		BT_DESC_TYPE = /datum/bt_node/composite/sequence,
		BT_DESC_CHILDREN = list(
			list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/bee_action/bee_upkeep),
			list(
				BT_DESC_TYPE = /datum/bt_node/composite/selector,
				BT_DESC_CHILDREN = list(
					list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/bee_action/bee_combat),
					list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/bee_action/bee_pollinate),
					list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/bee_action/bee_go_home),
					list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/bee_action/bee_roam),
					list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/bee_action/bee_build),
				),
			),
			list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/bee_action/bee_finish),
		),
	)

///////////////////////////Custom Procs//////////////////////////////////

//Adds a previously created bee datum to our swarm
/mob/living/simple_animal/bee/proc/addBee(var/datum/bee/B,var/update = TRUE)
	bees.Add(B)
	B.mob = src
	home = B.home
	if (!bee_species)
		bee_species = B.species
		min_oxy = bee_species.min_oxy
		max_oxy = bee_species.max_oxy
		min_tox = bee_species.min_tox
		max_tox = bee_species.max_tox
		min_co2 = bee_species.min_co2
		max_co2 = bee_species.max_co2
		min_n2 = bee_species.min_n2
		max_n2 = bee_species.max_n2
		minbodytemp = bee_species.minbodytemp
		maxbodytemp = bee_species.maxbodytemp
	if (update)
		updateDamage()

//updates our damage values and our appearance
/mob/living/simple_animal/bee/proc/updateDamage()
	if (bees.len <= 0)
		return

	var/total_brute = 0
	var/total_toxic = 0
	for (var/datum/bee/BEE in bees)
		total_brute += BEE.damage
		total_toxic += BEE.toxic
	current_physical_damage = (total_brute/2)*bee_species.damage_coef//1 regular bee = 0.5 brute; 20 regular bees = 10 brute; 20 mutated(2 damage) bees = 20 brute;
	current_poison_damage = (bees.len + (total_toxic/bees.len)/100)*bee_species.toxic_coef//1 regular bee = 1 tox; 20 regular bees = 20 tox; 20 intoxicated(100 toxic) bees = 40 tox;
	update_icon()

//sends all nearby bees too attack an aggressor
/mob/living/simple_animal/bee/proc/panic_attack(mob/damagesource)
	if (!bee_species.angery)
		return

	for(var/mob/living/simple_animal/bee/B in range(src,3))
		if (B.intent == BEE_SWARM || B.intent == BEE_BUILDING || B.calmed > 0)
			continue
		//only their friends from the same apiary will answer their call. homeless bees will also help each others.
		if (B.home == home)//incidentally this also means ourselves
			B.mood_change(BEE_OUT_FOR_ENEMIES,damagesource)

//adding a plant to the list of already-pollinated plants so we don't go there again
/mob/living/simple_animal/bee/proc/add_plants(var/list/new_plants)
	if(!new_plants || new_plants.len <= 0)
		return
	for (var/obj/machinery/portable_atmospherics/hydroponics/new_plant in new_plants)
		if (!(new_plant in visited_plants))
			visited_plants += new_plant

//merges the other swarm's bees into ours
/mob/living/simple_animal/bee/proc/MergeSwarms(var/mob/living/simple_animal/bee/other_swarm)
	for (var/datum/bee/B in other_swarm.bees)
		addBee(B)
	other_swarm.bees = list()
	add_plants(other_swarm.visited_plants)
	if(!target)
		target = other_swarm.target
	if(!faction)
		faction = other_swarm.faction
	qdel(other_swarm)
	updateDamage()

//create a new swarm from some of our bees (that were previously selected)
/mob/living/simple_animal/bee/proc/SplitSwarm(var/list/bees_to_split = list(), var/new_intent = BEE_ROAMING)
	if (bees_to_split.len <= 0)
		return
	var/mob/living/simple_animal/bee/new_swarm = new /mob/living/simple_animal/bee(get_turf(src))
	for (var/datum/bee/B in bees_to_split)
		new_swarm.addBee(B)
		bees.Remove(B)
		new_swarm.calmed = calmed
		new_swarm.home = home
		new_swarm.intent = new_intent
		new_swarm.target = target
		new_swarm.add_plants(visited_plants)
		new_swarm.faction = faction
		new_swarm.updateDamage()
	updateDamage()
	return new_swarm

//forget our previous target and try to find a new one
/mob/living/simple_animal/bee/proc/FindTarget()
	target = null
	var/list/nearbyMobs = list()
	for(var/mob/living/L in view(src,7))
		if (L == src)
			continue
		if (L.flags & INVULNERABLE)
			continue
		if(istype(L, /mob/living/simple_animal/bee))
			continue
		if(istype(L, /mob/living/silicon/robot/mommi)) //Do not bully the crab
			continue
		if(istype(L, /mob/living/simple_animal/hostile/lizard) && !bee_species.wild) //natural predator, need to be pretty aggressive to fight them
			continue
		if(faction == "\ref[L]")
			continue
		if (L.stat != DEAD)
			nearbyMobs += L
	if (nearbyMobs.len > 0)
		target = pick(nearbyMobs)
		target_turf = get_turf(target)
		if (target)
			var common = BEESPECIES_NORMAL
			if (bee_species)
				common = bee_species.common_name
			if(bees.len <= 1)
				for (var/D in bees)
					if (istype(D,/datum/bee/queen_bee))
						common = "queen [common]"
				visible_message("<span class='warning'>The [common] flies after [target]!</span>")

			else
				visible_message("<span class='warning'>The [common]s swarm after [target]!</span>")

/mob/living/simple_animal/bee/proc/MoveToTarget()
	if (!target_turf)
		return
	if (bee_species.slow)
		step_to(src, target_turf)//1 step per Life()
	else
		start_walk_to(target, 0, 2)//fast bees however never stop chasing until their target is either dead or out of sight.

/mob/living/simple_animal/bee/proc/AttackTarget(var/force_pierce = FALSE)
	if (!target)
		return
	if (!Adjacent(target))
		return
	if(isliving(target))
		var/mob/living/L = target
		if(!L.tangibility)
			return
	var/mob/living/carbon/human/M = target
	var/sting_prob = 100
	if(istype(M))
		var/obj/item/clothing/worn_suit = M.wear_suit
		var/obj/item/clothing/worn_helmet = M.head
		if(worn_suit)
			var/bio_block = min(worn_suit.armor["bio"],70)
			var/perm_block = 70-70*worn_suit.permeability_coefficient
			sting_prob -= max(bio_block,perm_block) // Is your suit sealed? I can't get to 70% of your body.
		if(worn_helmet)
			var/bio_block = min(worn_helmet.armor["bio"],30)
			var/perm_block = 30-30*worn_helmet.permeability_coefficient
			sting_prob -= max(bio_block,perm_block) // Is your helmet sealed? I can't get to 30% of your body.
	var/brute_damage = current_physical_damage
	var/tox_damage = current_poison_damage
	var/sting_quality = BEE_STING_NORMAL
	if (!prob(sting_prob))
		if (prob(bee_species.pierce_chance) || force_pierce)
			sting_quality = BEE_STING_PIERCE
			brute_damage = brute_damage*bee_species.pierce_damage/100
			tox_damage = tox_damage*bee_species.pierce_damage/100
		else
			sting_quality = BEE_STING_BLOCK
	switch(sting_quality)
		if (BEE_STING_BLOCK)
			M.visible_message("<span class='notice'>\The [M]'s protection shields them from \the [src]!</span>", "<span class='warning'>Your protection shields you from \the [src]!</span>")
			bee_species.after_sting(sting_quality)
			return
		if (BEE_STING_PIERCE)
			M.visible_message("<span class='warning'>\The [src] [gender == PLURAL ? "are" : "is"] stinging \the [M] through their protection!</span>", "<span class='warning'>You have been stung by \the [src] through your protection!</span>")
		if (BEE_STING_NORMAL)
			M.visible_message("<span class='warning'>\The [src] [gender == PLURAL ? "are" : "is"] stinging \the [M]!</span>", "<span class='warning'>You have been stung by \the [src]!</span>")
	M.apply_damage(current_physical_damage, BRUTE)
	M.apply_damage(current_poison_damage, TOX)
	M.flash_pain()
	bee_species.after_sting(M,sting_quality)//allows species to do extra stuff when a successful sting

//the swarm will navigate to an empty apiary to inhabit (the swarm must include a queen)
/mob/living/simple_animal/bee/proc/exile_swarm(var/obj/machinery/apiary/A)
	if (A in apiary_reservation)//another queen has marked this one for herself
		return 0
	if (A.queen_bees_inside > 0 || locate(/datum/bee/queen_bee) in A.bees_outside_hive)//another queen made her way there somehow
		return 0
	return 1

//overriding the mood of every bee inside our swarm
/mob/living/simple_animal/bee/proc/mood_change(var/new_mood,var/new_target=null,var/new_home=null)
	for(var/datum/bee/B in bees)
		B.intent = new_mood
		if (new_home)
			B.home = new_home
	intent = new_mood
	if (new_target)
		target = new_target
	if (new_home)
		home = new_home

//will split the swarm, grouping bees depending on what they want to do
/mob/living/simple_animal/bee/proc/UpdateIntent()
	intent_change = 0
	var/list/swarmers = list()
	var/list/home_goers = list()
	var/list/pollinaters = list()
	var/list/fighters = list()
	var/list/roamers = list()
	//first let's check what each bee wants to do
	for (var/datum/bee/B in bees)
		if (B.intent == BEE_SWARM)
			swarmers.Add(B)
		if (B.intent == BEE_HEADING_HOME)
			home_goers.Add(B)
		if (B.intent == BEE_OUT_FOR_PLANTS)
			pollinaters.Add(B)
		if (B.intent == BEE_OUT_FOR_ENEMIES)
			fighters.Add(B)
		if (B.intent == BEE_ROAMING)
			roamers.Add(B)
	if (swarmers.len > 0) // this intent comes from a queen, and thus overrides the intents of every other bee in the swarm
		mood_change(BEE_SWARM,null,destination)
	else
		if (home_goers.len > 0)//who wants to go home? obviously only bees that DO have a home can have this intent
			if (home_goers.len == bees.len)
				mood_change(BEE_HEADING_HOME)
			else
				step_rand(SplitSwarm(home_goers,BEE_HEADING_HOME))

		if (pollinaters.len > 0)//I don't think that can actually happen since they only get that intent when leaving the hive but this might be useful in some edge cases
			if (pollinaters.len == bees.len)
				mood_change(BEE_OUT_FOR_PLANTS)
			else
				step_rand(SplitSwarm(pollinaters,BEE_OUT_FOR_PLANTS))

		if (fighters.len > 0)//if even one bee wants to fight, the homeless roamers will keep fighting
			mood_change(BEE_OUT_FOR_ENEMIES)

		else if (roamers.len > 0)//if all the fighters are bored AND homeless we'll calm down and go back to roaming until provoked again
			mood_change(BEE_ROAMING)

/mob/living/simple_animal/bee/proc/calming()
	calmed = 7
	if (intent == BEE_OUT_FOR_ENEMIES)
		src.visible_message("<span class='notice'>The bees calm down!</span>")
		mood_change(BEE_HEADING_HOME)

////////////////////////////////UPDATE ICON/////////////////////////////////

/mob/living/simple_animal/bee/update_icon()
	overlays.len = 0

	if(bees.len <= 0)
		return

	var common = BEESPECIES_NORMAL
	icon_state = ""
	if (bee_species)
		icon_state += bee_species.prefix
		common = bee_species.common_name

	var/queen = 0
	for (var/D in bees)
		if (istype(D,/datum/bee/queen_bee))
			queen = 1
	if (bees.len >= 15)
		icon_state += "bees-swarm"
	else
		icon_state += "bees[min(bees.len-queen,10)]"


	if (intent == BEE_OUT_FOR_ENEMIES)
		icon_state += "-feral"
		if (queen)
			overlays += image('icons/obj/apiary_bees_etc.dmi', icon_state="[bee_species.prefix]queen_bee-feral")
	else if (queen)
		overlays += image('icons/obj/apiary_bees_etc.dmi', icon_state="[bee_species.prefix]queen_bee")


	animate(src, pixel_x = rand(-12,12) * PIXEL_MULTIPLIER, pixel_y = rand(-12,12) * PIXEL_MULTIPLIER, time = 10, easing = SINE_EASING)

	//updating name
	var/prefix = ""

	switch (intent)
		if (BEE_ROAMING)
			prefix = "homeless "
		if (BEE_OUT_FOR_ENEMIES)
			if (((current_poison_damage - bees.len)/bees.len*100) > 51)
				prefix = "crazy "
			else
				prefix = "angry "


	if(bees.len <= 1)
		gender = NEUTER
		name = "[prefix][common]"
		for (var/D in bees)
			if (istype(D,/datum/bee/queen_bee))
				name = "[prefix] queen [common]"

	else
		gender = PLURAL
		name = "swarm of [prefix][common]s"



#undef TIME_TO_POLLINATE
#undef DURATION_OF_POLLINATION
#undef FATIGUE_PER_POLLINATIONS
#undef FATIGUE_TO_RETURN

#undef BOREDOM_TO_RETURN
