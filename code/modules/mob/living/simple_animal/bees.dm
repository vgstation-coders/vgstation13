//Beekeeping 3.0 on 07/20/2017 by Deity Link

#define TIME_TO_POLLINATE	4//how long (in seconds) will a bee remain on a plant before moving to the next one
#define DURATION_OF_POLLINATION	8//how long (in seconds) will the plant be enhanced by the bees (starts as soon as the bees begin pollination)
#define FATIGUE_PER_POLLINATIONS	4//how much extra fatigue does the bee receive from performing a successful pollination (if set to 0, the bee won't stop until there are no more flowers in range)
#define FATIGUE_TO_RETURN	20//once reached, the bee will head back to its hive

#define BOREDOM_TO_RETURN	30//once reached, the bee will head back to its hive

#define MAX_BEES_PER_SWARM	20//explicit

/*

> bee datums
> bee corpses
> bee mob
> bee presets

*/
//////////////////////BEE DATUMS///////////////////////////////////////

/datum/bee
	var/mob/living/simple_animal/bee/mob = null
	var/obj/machinery/apiary/home = null
	var/damage = 1//the brute damage dealt by a sting. Set when leaving the hive (spawning).
	var/toxic = 0//the extra toxic damage dealt by a sting. Set when leaving the hive (spawning).
	var/health = 10
	var/maxHealth = 10
	var/list/pollens = list()//flowers (seed_datums) that were pollinated by that bee
	var/state = BEE_ROAMING
	var/fatigue = 0//increases after a successful pollination or when searching for flowers in vain
	var/bored = 0//increases when searching for enemies in vain
	var/corpse = /obj/effect/decal/cleanable/bee
	var/toxins = 0

//When a bee leaves the hive, it takes on the hive's damage and toxic values
/datum/bee/New(var/obj/machinery/apiary/spawner = null)
	..()
	if (spawner)
		home = spawner
		damage = spawner.damage
		toxic = spawner.toxic

//call to make bees go look out for plants
/datum/bee/proc/goPollinate()
	state = BEE_OUT_FOR_PLANTS
	mob.updateState = 1

//call to make bees go look out for kills. angry bees are red-eyed.
/datum/bee/proc/angerAt(var/mob/M = null)
	if (state == BEE_SWARM)
		return
	state = BEE_OUT_FOR_ENEMIES
	mob.target = M
	mob.updateState = 1

//call to make bees go home. Hive-less bees never calm down
/datum/bee/proc/homeCall()
	if (home)
		state = BEE_HEADING_HOME
		mob.updateState = 1

/datum/bee/proc/Die()
	if (mob)
		new corpse(get_turf(mob))
		mob.bees.Remove(src)
		mob = null
	if (home)
		home.bees_outside_hive -= src
		home = null
	qdel(src)

/datum/bee/queen_bee
	health = 15
	maxHealth = 15
	corpse = /obj/effect/decal/cleanable/bee/queen_bee
	var/colonizing = 0


/datum/bee/queen_bee/proc/setHome(var/obj/machinery/apiary/A)
	state = BEE_SWARM
	colonizing = 1
	mob.destination = A
	mob.updateState = 1


//////////////////////BEE CORPSES///////////////////////////////////////

/obj/effect/decal/cleanable/bee
	name = "dead bee"
	desc = "This one stung for the last time."
	gender = PLURAL
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "bee_dead"
	anchored = 0
	mouse_opacity = 1
	plane = LYING_MOB_PLANE

/obj/effect/decal/cleanable/bee/New()
	..()
	dir = pick(cardinal)
	pixel_x = rand(-10,10)
	pixel_y = rand(-4,4)

/obj/effect/decal/cleanable/bee/queen_bee
	name = "dead queen bee"
	icon_state = "queen_bee_dead"



//////////////////////BEE MOB///////////////////////////////////////

/mob/living/simple_animal/bee
	name = "swarm of bees"
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "bees1"
	icon_dead = "bee_dead"

	mob_property_flags = MOB_SWARM
	size = SIZE_TINY
	can_butcher = 0

	var/updateState = 0//if set to 1, the bee mob will check if it should split based on its bee datums' intents
	var/state = BEE_ROAMING
	var/atom/destination = null
	var/list/bees = list()
	var/mob/target = null
	var/current_physical_damage = 0
	var/current_poison_damage = 0
	var/obj/machinery/apiary/home = null
	var/calmed = 0
	var/pollinating = 0
	var/obj/machinery/portable_atmospherics/hydroponics/target_plant = null
	var/list/visited_plants = list()
	pass_flags = PASSTABLE
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

/mob/living/simple_animal/bee/New(loc, var/obj/machinery/apiary/new_home)
	..()
	home = new_home


/mob/living/simple_animal/bee/Destroy()
	..()
	if(home)
		for (var/datum/bee/B in bees)
			home.bees_outside_hive -= B

/mob/living/simple_animal/bee/Die()
	returnToPool(src)

/mob/living/simple_animal/bee/gib()
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
	..()
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
			B.Die()

	if (bees.len <= 0)
		qdel(src)
	updateDamage()
	update_icon()


//CUSTOM PROCS
/mob/living/simple_animal/bee/proc/addBee(var/datum/bee/B)
	bees.Add(B)
	B.mob = src
	home = B.home
	updateDamage()

/mob/living/simple_animal/bee/proc/updateDamage()
	if (bees.len <= 0)
		return

	var/total_brute = 0
	var/total_toxic = 0
	for (var/datum/bee/BEE in bees)
		total_brute += BEE.damage
		total_toxic += BEE.toxic
	current_physical_damage = total_brute/2//1 regular bee = 0.5 brute; 20 regular bees = 10 brute; 20 mutated(2 damage) bees = 20 brute;
	current_poison_damage = bees.len + (total_toxic/bees.len)/100//1 regular bee = 1 tox; 20 regular bees = 20 tox; 20 intoxicated(100 toxic) bees = 40 tox;
	update_icon()

/mob/living/simple_animal/bee/proc/panic_attack(mob/damagesource)
	for(var/mob/living/simple_animal/bee/B in range(src,3))
		if (B.state == BEE_SWARM || calmed > 0)
			return

		//only their friends from the same apiary will answer their call. homeless bees will also help each others.
		if (B.home == home)
			B.state = BEE_OUT_FOR_ENEMIES
			B.target = damagesource

/mob/living/simple_animal/bee/proc/add_plants(var/list/new_plants)
	if(!new_plants || new_plants.len <= 0) return

	for (var/obj/machinery/portable_atmospherics/hydroponics/new_plant in new_plants)
		if (!visited_plants.Find(new_plant))
			visited_plants.Add(new_plant)

////////////////////////////////LIFE////////////////////////////////////////

/mob/living/simple_animal/bee/Life()
	if(timestopped)
		return 0

	..()

	if (!bees || bees.len <= 0)
		qdel(src)
		return

	if(stat != DEAD)
		//SUFFERING FROM HIGH TOXICITY
		if (((current_poison_damage - bees.len)/bees.len*100) > 50)
			if (prob((((current_poison_damage - bees.len)/bees.len*100)-50)*2))
				adjustBruteLoss(3)
			if (bees.len <= 0)
				return

		//SPLITTING THE SWARM DEPENDING ON THEIR INTENT
		if (updateState)
			updateState = 0
			var/list/swarmers = list()
			var/list/home_goers = list()
			var/list/pollinaters = list()
			var/list/fighters = list()
			var/turf/T = get_turf(src)

			for (var/datum/bee/B in bees)
				if (B.state == BEE_SWARM)
					swarmers.Add(B)
				if (B.state == BEE_HEADING_HOME)
					home_goers.Add(B)
				if (B.state == BEE_OUT_FOR_PLANTS)
					pollinaters.Add(B)
				if (B.state == BEE_OUT_FOR_ENEMIES)
					fighters.Add(B)

			if (swarmers.len > 0) // this intent comes from a queen, and thus overrides the intents of every other bee in the swarm
				for (var/datum/bee/B in bees)
					B.state = BEE_SWARM
					B.home = destination
				home = destination
				state = BEE_SWARM

			if (home_goers.len > 0)
				if (home_goers.len == bees.len)
					state = BEE_HEADING_HOME

				else
					var/mob/living/simple_animal/bee/B_mob = getFromPool(/mob/living/simple_animal/bee,T)
					for (var/datum/bee/B in home_goers)
						B_mob.addBee(B)
						bees.Remove(B)
						B_mob.home = home
						B_mob.updateState = 1

			if (pollinaters.len > 0)
				if (pollinaters.len == bees.len)
					state = BEE_OUT_FOR_PLANTS

				else
					var/mob/living/simple_animal/bee/B_mob = getFromPool(/mob/living/simple_animal/bee,T)
					for (var/datum/bee/B in pollinaters)
						B_mob.addBee(B)
						bees.Remove(B)
						B_mob.home = home
						B_mob.updateState = 1

			if (fighters.len > 0)
				state = BEE_OUT_FOR_ENEMIES


		//CALMING BEES
		var/list/calmers = list(
			/obj/effect/decal/chemical_puff,
			/obj/effect/effect/smoke/chem,
			/obj/effect/effect/water,
			/obj/effect/effect/foam,
			/obj/effect/effect/steam,
			/obj/effect/mist,
			)

		if (calmed > 0)
			calmed--

		for(var/this_type in calmers)
			var/obj/effect/check_effect = locate(this_type) in src.loc
			if(check_effect && (check_effect.reagents.has_reagent(WATER) || check_effect.reagents.has_reagent(HOLYWATER)))
				calmed = 6
				if (state == BEE_OUT_FOR_ENEMIES)
					src.visible_message("<span class='notice'>The bees calm down!</span>")
					for (var/datum/bee/B)
						B.state = BEE_HEADING_HOME
					state = BEE_HEADING_HOME
				break


	if(stat == CONSCIOUS)

		var/mob/living/carbon/human/M = target

		//CALMED BEES WON'T REMAIN GROUPED
		if(calmed > 0)
			if(target)
				target = null
			if(bees.len > 5)
				//calm down and spread out a little
				var/mob/living/simple_animal/bee/B_mob = getFromPool(/mob/living/simple_animal/bee,get_turf(src))
				for (var/i = 1 to rand(1,5))
					var/datum/bee/B = pick(bees)
					B_mob.addBee(B)
					bees.Remove(B)
					B_mob.calmed = calmed
					B_mob.state = state
					B_mob.home = home
				B_mob.Move(get_turf(pick(orange(src,1))))

		//ATTACKING TARGET
		else if(state == BEE_OUT_FOR_ENEMIES && M in view(src,1))
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
			if(prob(sting_prob))
				M.apply_damage(current_physical_damage, BRUTE)
				M.apply_damage(current_poison_damage, TOX)
				M.visible_message("<span class='warning'>\The [src] are stinging \the [M]!</span>", "<span class='warning'>You have been stung by \the [src]!</span>")
				M.flash_pain()

		//MAKING NOISE
		if(prob(1))
			if(prob(50))
				src.visible_message("<span class='notice'>[pick("Buzzzz.","Hmmmmm.","Bzzz.")]</span>")
			playsound(get_turf(src), 'sound/effects/bees.ogg', min(20 * bees.len, 100), 1)


		//GROUPING WITH OTHER BEES
		for(var/mob/living/simple_animal/bee/B_mob in src.loc)
			//sanity check
			if(B_mob == src)
				continue

			//bees don't mix with bees from other hives
			if(B_mob.home != home)
				continue

			//no more than 20 bees per swarm to avoid people abusing their damage
			if(bees.len + B_mob.bees.len > MAX_BEES_PER_SWARM)
				continue

			//angry bees will drag other bees along with them
			if(state == BEE_OUT_FOR_ENEMIES)
				if((prob(10) && B_mob.state == BEE_OUT_FOR_PLANTS) || (prob(60) && B_mob.state == BEE_OUT_FOR_ENEMIES))
					for (var/datum/bee/B in B_mob.bees)
						addBee(B)
					B_mob.bees = list()
					add_plants(B_mob.visited_plants)
					if(!target)
						target = B_mob.target
					qdel(B_mob)
					updateDamage()

			else if(prob(30) && state != BEE_OUT_FOR_ENEMIES && pollinating <= 0  && B_mob.pollinating <= 0 && state == B_mob.state)
				for (var/datum/bee/B in B_mob.bees)
					addBee(B)
				B_mob.bees = list()
				add_plants(B_mob.visited_plants)
				qdel(B_mob)
				updateDamage()

		//SPREADING OUT
		if(bees.len > 1 && pollinating <= 0 && prob(bees.len*2) && state != BEE_SWARM && state != BEE_HEADING_HOME)
			var/mob/living/simple_animal/bee/B_mob = getFromPool(/mob/living/simple_animal/bee,get_turf(src))
			var/datum/bee/B = pick(bees)
			B_mob.addBee(B)
			bees.Remove(B)
			B_mob.calmed = calmed
			B_mob.state = state
			B_mob.target = target
			B_mob.update_icon()
			B_mob.home = home
			B_mob.add_plants(visited_plants)
			B_mob.Move(get_turf(pick(orange(src,1))))
			updateDamage()

		//REACHING FOR MOBS
		if(state == BEE_OUT_FOR_ENEMIES)
			var/turf/target_turf = null
			if(target && (target in view(src,7)) && target.stat != DEAD)
				target_turf = get_turf(target)
				wander = 0
			else
				target = null
				var/list/nearbyMobs = list()
				for(var/mob/living/G in view(src,7))
					if (G == src) continue
					if (G.flags & INVULNERABLE) continue
					//Bees will only attack other bees if they're crazy from high toxicity
					if (istype(G,/mob/living/simple_animal/bee) && (((current_poison_damage - bees.len)/bees.len*100) > 51))
						var/mob/living/simple_animal/bee/B = G
						//even then, they won't attack bees from their own hives.
						if (B.home == home || (home && B.home && B.home.wild && home.wild))
							continue
					if (G.stat != DEAD)
						nearbyMobs += G
				if (nearbyMobs.len > 0)
					target = pick(nearbyMobs)
					if (target)
						src.visible_message("<span class='warning'>The bees swarm after [target]!</span>")
				else
					for (var/datum/bee/B in bees)
						B.bored++
						if (B.bored > BOREDOM_TO_RETURN && B.home && !B.home.wild)
							B.homeCall()

			if(target_turf)
				var/tdir = get_dir(src,target_turf)
				var/turf/move_to = get_step(src, tdir)
				walk_to(src,move_to)

				if(src.loc == target_turf)
					wander = 1

		//REACHING FOR FLOWERS
		if(state == BEE_OUT_FOR_PLANTS && pollinating <= 0)
			var/turf/target_turf = null
			if(target_plant && target_plant in view(src,7))
				target_turf = get_turf(target_plant)
				wander = 0
			else
				var/list/nearbyPlants = list()
				for(var/obj/machinery/portable_atmospherics/hydroponics/H in view(src,2))
					if (!H.dead && H.seed)
						nearbyPlants += H
				nearbyPlants.Remove(visited_plants)
				if (nearbyPlants.len > 0)
					target_plant = pick(nearbyPlants)
				else
					for (var/datum/bee/B in bees)
						B.fatigue++
						if (B.fatigue > FATIGUE_TO_RETURN)
							B.homeCall()
			if(target_turf)
				var/tdir = get_dir(src,target_turf)
				var/turf/move_to = get_step(src, tdir)
				if (calmed <= 0)
					walk_to(src,move_to)

				if(src.loc == target_turf)
					visited_plants.Add(target_plant)
					pollinating = TIME_TO_POLLINATE
					target_plant.pollination = DURATION_OF_POLLINATION
		else if (pollinating > 0)
			pollinating--
			if (pollinating == 0)
				for (var/datum/bee/B in bees)
					B.pollens += target_plant.seed
					B.toxins += target_plant.toxins
					B.fatigue += FATIGUE_PER_POLLINATIONS
					if (B.fatigue > FATIGUE_TO_RETURN)
						B.homeCall()
				target_plant = null
				wander = 1


		//REACHING FOR HOME
		if(state == BEE_HEADING_HOME || state == BEE_SWARM)
			wander = 0
			var/turf/target_turf = get_turf(home)
			if(target_turf)
				var/tdir = get_dir(src,target_turf)
				var/turf/move_to = get_step(src, tdir)
				if (calmed <= 0)
					walk_to(src,move_to)

				if(src.loc == target_turf)
					for(var/datum/bee/B in bees)
						home.enterHive(B)
					qdel(src)
			else
				state = BEE_ROAMING


		//BEING LOST
		if(state == BEE_ROAMING)
			wander = 1
			if (home && home.loc)
				state = BEE_HEADING_HOME

	update_icon()


////////////////////////////////UPDATE ICON/////////////////////////////////

/mob/living/simple_animal/bee/update_icon()
	overlays.len = 0

	if(bees.len <= 0)
		return

	var/queen = 0
	for (var/D in bees)
		if (istype(D,/datum/bee/queen_bee))
			queen = 1
	if (bees.len >= 15)
		icon_state = "bees-swarm"
	else
		icon_state = "bees[min(bees.len-queen,10)]"


	if (state == BEE_OUT_FOR_ENEMIES)
		icon_state += "-feral"
		if (queen)
			overlays += image('icons/obj/apiary_bees_etc.dmi', icon_state="queen_bee-feral")
	else if (queen)
		overlays += image('icons/obj/apiary_bees_etc.dmi', icon_state="queen_bee")


	animate(src, pixel_x = rand(-12,12) * PIXEL_MULTIPLIER, pixel_y = rand(-12,12) * PIXEL_MULTIPLIER, time = 10, easing = SINE_EASING)

	//updating name
	var/prefix = ""

	switch (state)
		if (BEE_ROAMING)
			prefix = "homeless "
		if (BEE_OUT_FOR_ENEMIES)
			if (((current_poison_damage - bees.len)/bees.len*100) > 51)
				prefix = "crazy "
			else
				prefix = "angry "


	if(bees.len <= 1)
		gender = NEUTER
		name = "[prefix]bee"
		for (var/D in bees)
			if (istype(D,/datum/bee/queen_bee))
				name = "[prefix] queen bee"

	else
		gender = PLURAL
		name = "swarm of [prefix]bees"


////////////////////////////BEE PRESETS/////////////////////////////////////

/mob/living/simple_animal/bee/adminSpawned/New(loc, var/obj/machinery/apiary/new_home)
	..()
	var/datum/bee/B = new()
	addBee(B)
	update_icon()

/mob/living/simple_animal/bee/adminSpawnedQueen/New(loc, var/obj/machinery/apiary/new_home)
	..()
	var/datum/bee/queen_bee/B = new()
	B.colonizing = 1//so it can start a colony if someone places it in an empty hive
	addBee(B)
	update_icon()

//BEE-NADE & BEE-ULLET
/mob/living/simple_animal/bee/angry/New(loc, var/obj/machinery/apiary/new_home)
	..()
	var/datum/bee/B = new()
	B.toxic = 50
	B.damage = 2
	B.state = BEE_OUT_FOR_ENEMIES
	state = BEE_OUT_FOR_ENEMIES
	addBee(B)
	update_icon()

//BEE-IEFCASE
/mob/living/simple_animal/bee/swarm/New(loc, var/obj/machinery/apiary/new_home)
	..()
	for (var/i = 1 to MAX_BEES_PER_SWARM)
		var/datum/bee/B = new()
		B.toxic = 50
		B.damage = 2
		B.state = BEE_OUT_FOR_ENEMIES
		addBee(B)
	state = BEE_OUT_FOR_ENEMIES
	update_icon()

#undef TIME_TO_POLLINATE
#undef DURATION_OF_POLLINATION
#undef FATIGUE_PER_POLLINATIONS
#undef FATIGUE_TO_RETURN

#undef BOREDOM_TO_RETURN

#undef MAX_BEES_PER_SWARM
