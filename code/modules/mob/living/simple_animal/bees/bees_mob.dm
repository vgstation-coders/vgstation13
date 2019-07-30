//Beekeeping 3.0 on 07/20/2017 by Deity Link

#define TIME_TO_POLLINATE	4//how long (in seconds) will a bee remain on a plant before moving to the next one
#define DURATION_OF_POLLINATION	8//how long (in seconds) will the plant be enhanced by the bees (starts as soon as the bees begin pollination)
#define FATIGUE_PER_POLLINATIONS	4//how much extra fatigue does the bee receive from performing a successful pollination (if set to 0, the bee won't stop until there are no more flowers in range)
#define FATIGUE_TO_RETURN	20//once reached, the bee will head back to its hive

#define BOREDOM_TO_RETURN	30//once reached, the bee will head back to its hive

#define EXHAUSTION_TO_DIE	300//once reached, the bee will begin to die
#define MAX_BEES_PER_SWARM	20//explicit

/*

> bee corpses
> bee mob
> bee presets

*/

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

/obj/effect/decal/cleanable/bee/New(var/loc, var/age, var/icon_state, var/color, var/dir, var/pixel_x, var/pixel_y)
	..()
	if (isnum(color) && color > 0)
		src.icon_state = "bees0"
		var/failsafe = min(color,30)
		for (var/i = 1 to failsafe)
			var/image/I = image(icon,icon_state)
			I.pixel_x = rand(-10,10)
			I.pixel_y = rand(-4,4)
			I.dir = pick(cardinal)
			overlays += I
		color = null
	else
		var/image/I = image(src.icon,src.icon_state)
		I.pixel_x = rand(-10,10)
		I.pixel_y = rand(-4,4)
		I.dir = pick(cardinal)

		for (var/obj/effect/decal/cleanable/bee/corpse in get_turf(src))
			if (corpse != src)
				corpse.overlays += I
				qdel(src)
				return
			else
				icon_state = "bees0"
				overlays += I

/obj/effect/decal/cleanable/bee/queen_bee
	name = "dead queen bee"
	icon_state = "queen_bee_dead"

/obj/effect/decal/cleanable/bee/atom2mapsave()
	icon_state = initial(icon_state)
	if (overlays.len > 0)
		color = overlays.len//a bit hacky but hey
	. = ..()


//////////////////////BEE MOB///////////////////////////////////////


var/bee_mobs_count = 0

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
	var/datum/bee_species/bee_species = null
	var/turf/building = null
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
	bee_mobs_count++
	home = new_home


/mob/living/simple_animal/bee/Destroy()
	bee_mobs_count--
	if(home)
		for (var/datum/bee/B in bees)
			home.bees_outside_hive -= B
		home = null
	destination = null
	target = null
	target_plant = null
	for (var/datum/bee/B in bees)
		qdel(B)//it'll get removed from the bees list in the datum's Destroy() proc.
	bees.len = 0
	visited_plants.len = 0
	..()

/mob/living/simple_animal/bee/death(var/gibbed = FALSE)
	..(gibbed)
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
	update_icon()


//CUSTOM PROCS
/mob/living/simple_animal/bee/proc/addBee(var/datum/bee/B)
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
	updateDamage()

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

/mob/living/simple_animal/bee/proc/panic_attack(mob/damagesource)
	if (!bee_species.angery)
		return

	for(var/mob/living/simple_animal/bee/B in range(src,3))
		if (B.state == BEE_SWARM || B.state == BEE_BUILDING || B.calmed > 0)
			continue

		//only their friends from the same apiary will answer their call. homeless bees will also help each others.
		if (B.home == home)
			B.mood_change(BEE_OUT_FOR_ENEMIES,damagesource)

	if (state == BEE_SWARM || state == BEE_BUILDING || calmed > 0)
		mood_change(BEE_OUT_FOR_ENEMIES,damagesource)

/mob/living/simple_animal/bee/proc/add_plants(var/list/new_plants)
	if(!new_plants || new_plants.len <= 0) return

	for (var/obj/machinery/portable_atmospherics/hydroponics/new_plant in new_plants)
		if (!visited_plants.Find(new_plant))
			visited_plants.Add(new_plant)

/mob/living/simple_animal/bee/resetVariables()
	..("bees", "visited_plants", args)
	bees = list()
	visited_plants = list()

////////////////////////////////LIFE////////////////////////////////////////

/mob/living/simple_animal/bee/Life()
	if(timestopped)
		return 0

	..()

	if (!bees || bees.len <= 0)
		qdel(src)
		return

	if (!bee_species.slow && !target)
		walk(src,0)

	if(stat != DEAD)
		//SUFFERING FROM HIGH TOXICITY
		if (((current_poison_damage - bees.len)/bees.len*100) > bee_species.toxic_threshold_death)
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
				mood_change(BEE_SWARM,null,destination)

			if (home_goers.len > 0)
				if (home_goers.len == bees.len)
					mood_change(BEE_HEADING_HOME)

				else
					var/mob/living/simple_animal/bee/B_mob = getFromPool(/mob/living/simple_animal/bee,T)
					for (var/datum/bee/B in home_goers)
						B_mob.addBee(B)
						bees.Remove(B)
						B_mob.home = home
						B_mob.updateState = 1

			if (pollinaters.len > 0)
				if (pollinaters.len == bees.len)
					mood_change(BEE_OUT_FOR_PLANTS)

				else
					var/mob/living/simple_animal/bee/B_mob = getFromPool(/mob/living/simple_animal/bee,T)
					for (var/datum/bee/B in pollinaters)
						B_mob.addBee(B)
						bees.Remove(B)
						B_mob.home = home
						B_mob.updateState = 1

			if (fighters.len > 0)
				mood_change(BEE_OUT_FOR_ENEMIES)


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
				calming()
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
				step_rand(B_mob)

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
			var/brute_damage = current_physical_damage
			var/tox_damage = current_poison_damage
			var/direct = 1 + prob(sting_prob)
			if (direct < 2)
				if (prob(bee_species.pierce_chance))
					brute_damage = brute_damage*bee_species.pierce_damage/100
					tox_damage = tox_damage*bee_species.pierce_damage/100
				else
					direct = 0
			if (direct)
				M.apply_damage(current_physical_damage, BRUTE)
				M.apply_damage(current_poison_damage, TOX)
				if (direct > 1)
					M.visible_message("<span class='warning'>\The [src] are stinging \the [M]!</span>", "<span class='warning'>You have been stung by \the [src]!</span>")
				else
					M.visible_message("<span class='warning'>\The [src] are stinging \the [M] through their protection!</span>", "<span class='warning'>You have been stung by \the [src] through your protection!</span>")
				M.flash_pain()
			else
				M.visible_message("<span class='notice'>\The [M]'s protection shields them from \the [src]!</span>", "<span class='warning'>Your protection shields you from \the [src]!</span>")

		//MAKING NOISE
		if(prob(1))
			if(prob(50))
				src.visible_message("<span class='notice'>[pick("Buzzzz.","Hmmmmm.","Bzzz.")]</span>")
			playsound(src, 'sound/effects/bees.ogg', min(20 * bees.len, 100), 1)


		//GROUPING WITH OTHER BEES
		for(var/mob/living/simple_animal/bee/B_mob in src.loc)
			//sanity check
			if(B_mob == src)
				continue

			//bees don't mix with bees from other hives
			if(B_mob.home != home)
				continue

			if(B_mob.bee_species != bee_species)
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

			else if((state == BEE_BUILDING) || (prob(30) && state != BEE_OUT_FOR_ENEMIES && pollinating <= 0  && B_mob.pollinating <= 0 && state == B_mob.state))
				for (var/datum/bee/B in B_mob.bees)
					addBee(B)
				B_mob.bees = list()
				add_plants(B_mob.visited_plants)
				qdel(B_mob)
				updateDamage()

		//SPREADING OUT
		if(bees.len > 1 && pollinating <= 0 && prob(bees.len*2) && state != BEE_SWARM && state != BEE_BUILDING && state != BEE_HEADING_HOME)
			var/queen = 0
			for (var/single_B in bees)
				if (istype(single_B,/datum/bee/queen_bee))
					queen = 1
					break
			if (state != BEE_ROAMING || !queen)//homeless bees spread out if there's no queen among them
				var/mob/living/simple_animal/bee/B_mob = getFromPool(/mob/living/simple_animal/bee,get_turf(src))
				var/datum/bee/B = pick(bees)
				B_mob.addBee(B)
				bees.Remove(B)
				B_mob.calmed = calmed
				B_mob.mood_change(state,target,home)
				B_mob.update_icon()
				B_mob.add_plants(visited_plants)
				step_rand(B_mob)
				updateDamage()

		//REACHING FOR MOBS
		if(state == BEE_OUT_FOR_ENEMIES)
			var/turf/target_turf = null//we have a target!
			if(target && (target in view(src,7)) && target.stat != DEAD)
				target_turf = get_turf(target)
				wander = 0
			else//no target? let's find one!
				target = null
				var/list/nearbyMobs = list()
				for(var/mob/living/G in view(src,7))
					if (G == src) continue
					if (G.flags & INVULNERABLE) continue
					/*//Bees will only attack other bees if they're crazy from high toxicity
					//TODO: Remake/rethink this. Currently they just cascade into killing one another from the same
					if (istype(G,/mob/living/simple_animal/bee) && (((current_poison_damage - bees.len)/bees.len*100) > 51))
						var/mob/living/simple_animal/bee/B = G
						//even then, they won't attack bees from their own hives.
						if (B.home == home || (home && B.home && B.home.wild && home.wild))
							continue*/
					if(istype(G, /mob/living/simple_animal/bee))
						continue
					if(istype(G, /mob/living/silicon/robot/mommi)) //Do not bully the crab
						continue
					if(istype(G, /mob/living/simple_animal/hostile/lizard) && bee_species.aggressiveness < 50) //natural predator, need to be pretty aggressive to fight them
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
						if (B.bored > BOREDOM_TO_RETURN)
							if (B.home)
								if (!B.home.wild)
									B.homeCall()
							else
								mood_change(BEE_ROAMING)
								for (var/datum/bee/B_single in bees)
									B_single.bored = 0
								break

			if(target_turf)//got a target? let's move toward them now.
				if (bee_species.slow)
					var/turf/loc_old = loc
					step_to(src, target_turf)//1 step per Life()
					if (loc == loc_old)//our path is blocked for whatever reason
						for (var/datum/bee/B in bees)
							B.bored++
							if (B.bored > BOREDOM_TO_RETURN)
								B.homeCall()
				else
					start_walk_to(target, 0, 2)

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
					if (!H.dead && H.seed && !H.closed_system)
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
				if (calmed <= 0)
					var/turf/loc_old = loc
					step_to(src, target_turf)
					if (loc == loc_old)//our path is blocked for whatever reason
						for (var/datum/bee/B in bees)
							B.fatigue++
							if (B.fatigue > FATIGUE_TO_RETURN)
								B.homeCall()
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
				if (calmed <= 0)
					step_to(src, target_turf)

				if(src.loc == target_turf)
					if (!home.species || bee_species == home.species)
						for(var/datum/bee/B in bees)
							home.enterHive(B)
						qdel(src)
					else
						visible_message("<span class='notice'>A swarm has lost its way.</span>")
						home = null
						mood_change(BEE_ROAMING)
			else
				visible_message("<span class='notice'>A swarm has lost its way.</span>")
				home = null
				mood_change(BEE_ROAMING)


		//BEING LOST
		if(state == BEE_ROAMING)
			wander = 1
			for (var/datum/bee/B in bees)
				B.home = null
			home = null
			//if there's a queen among us, let's gather a following
			var/datum/bee/queen_bee/queen = null
			var/list/queen_list = list()
			for (var/D in bees)
				if (istype(D,/datum/bee/queen_bee))
					queen_list.Add(D)
					queen = D
			if (queen)
				if (bees.len < MAX_BEES_PER_SWARM)
					var/turf/T = get_turf(loc)
					for(var/mob/living/simple_animal/bee/B in range(src,3))
						if (bee_species == B.bee_species && B.state == BEE_ROAMING && B.loc != T)
							step_to(B, T)//come closer, the GROUPING segment above should take care of the merging after a moment.

				if (bees.len >= 11)
				//once there's enough of us, let's find a new home
					for(var/obj/machinery/apiary/A in range(src,3))
						if (exile_swarm(A))
							mood_change(BEE_SWARM,null,A)
							A.reserve_apiary(src)
							queen.colonizing = 1
							update_icon()
							return


					for (var/datum/bee/queen_bee/QB in queen_list)
						QB.searching++
						if (QB.searching>60)
							//and if there isn't any decent home nearby (after searching for a while)...let's build one!
							var/list/available_turfs = list()
							for (var/turf/simulated/floor/T in range(src,2))
								if(!T.has_dense_content() && !(locate(/obj/structure/wild_apiary) in T))
									available_turfs.Add(T)
							if (available_turfs.len>0)
								building = pick(available_turfs)
								if (building)
									mood_change(BEE_BUILDING)
							break


			else
				for (var/datum/bee/B in bees)
					B.exhaustion++
					if (B.exhaustion > EXHAUSTION_TO_DIE)
						adjustBruteLoss(1)

			if (state == BEE_ROAMING && home && home.loc)
				mood_change(BEE_HEADING_HOME)


		//BUILDING A WILD APIARY
		if(state == BEE_BUILDING)
			wander = 0
			var/datum/bee/queen_bee/queen = null
			for (var/D in bees)
				if (istype(D,/datum/bee/queen_bee))
					queen = D
			if(queen && building)
				if (bees.len < MAX_BEES_PER_SWARM)//Gathering some more volunteers.
					var/turf/T = get_turf(loc)
					for(var/mob/living/simple_animal/bee/B in range(src,3))
						if (bee_species == B.bee_species && B.state == BEE_ROAMING && B.loc != T)
							step_to(B, T)

				if (building != loc)
					step_to(src, building)
				else
					var/obj/structure/wild_apiary/W = locate() in building
					if (W)
						W.work()
					else
						new /obj/structure/wild_apiary(loc,bee_species.prefix)
			else
				mood_change(BEE_ROAMING)

	update_icon()


/mob/living/simple_animal/bee/proc/exile_swarm(var/obj/machinery/apiary/A)
	if (A in apiary_reservation)//another queen has marked this one for herself
		return 0
	if (A.queen_bees_inside > 0 || locate(/datum/bee/queen_bee) in A.bees_outside_hive)//another queen made her way there somehow
		return 0
	return 1

/mob/living/simple_animal/bee/proc/mood_change(var/new_mood,var/new_target=null,var/new_home=null)
	for(var/datum/bee/B in bees)
		B.state = new_mood
		if (new_home)
			B.home = new_home
	state = new_mood
	if (new_target)
		target = new_target
	if (new_home)
		home = new_home


/mob/living/simple_animal/bee/proc/calming()
	calmed = 6
	if (state == BEE_OUT_FOR_ENEMIES)
		src.visible_message("<span class='notice'>The bees calm down!</span>")
		mood_change(BEE_HEADING_HOME)

////////////////////////////////UPDATE ICON/////////////////////////////////

/mob/living/simple_animal/bee/update_icon()
	overlays.len = 0

	if(bees.len <= 0)
		return

	var common = "bees"
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


	if (state == BEE_OUT_FOR_ENEMIES)
		icon_state += "-feral"
		if (queen)
			overlays += image('icons/obj/apiary_bees_etc.dmi', icon_state="[bee_species.prefix]queen_bee-feral")
	else if (queen)
		overlays += image('icons/obj/apiary_bees_etc.dmi', icon_state="[bee_species.prefix]queen_bee")


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
		name = "[prefix][common]"
		for (var/D in bees)
			if (istype(D,/datum/bee/queen_bee))
				name = "[prefix] queen [common]"

	else
		gender = PLURAL
		name = "swarm of [prefix][common]"


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
/mob/living/simple_animal/bee/angry/New(loc, var/obj/machinery/apiary/new_home, var/spec=BEESPECIES_NORMAL, var/tox=50,var/dam=2)
	..()
	var/datum/bee/B = new()
	B.species = bees_species[spec]
	B.toxic = tox
	B.damage = dam
	addBee(B)
	mood_change(BEE_OUT_FOR_ENEMIES)
	updateDamage()
	update_icon()

//BEE-IEFCASE
/mob/living/simple_animal/bee/swarm/New(loc, var/obj/machinery/apiary/new_home)
	..()
	for (var/i = 1 to MAX_BEES_PER_SWARM)
		var/datum/bee/B = new()
		B.toxic = 50
		B.damage = 2
		addBee(B)
	mood_change(BEE_OUT_FOR_ENEMIES)
	update_icon()

#undef TIME_TO_POLLINATE
#undef DURATION_OF_POLLINATION
#undef FATIGUE_PER_POLLINATIONS
#undef FATIGUE_TO_RETURN

#undef BOREDOM_TO_RETURN

#undef MAX_BEES_PER_SWARM
