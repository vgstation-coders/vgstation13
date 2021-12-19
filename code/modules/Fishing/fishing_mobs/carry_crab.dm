/mob/living/simple_animal/hostile/fishing/carry_crab
	name = "carry crab"
	desc = ""
	icon_state = "carry_crab"
	icon_living = "carry_crab"
	icon_dead = "carry_crab_dead"
	melee_damage_type = BRUTE
	size = SIZE_NORMAL
	attacktext = list("snips", "snaps", "claws", "pinches")
	faction = "neutral"
	melee_damage_lower = 20
	melee_damage_upper = 25 //Snibbity snab, hits harder when it doesn't have a crate.
	search_objects = 1
	minCatchSize = 30
	maxCatchSize = 60
	tameItem = list()
	tameEase = 10
	var/obj/structure/reagent_dispensers/cauldron/barrel/crabCauldron = null
	var/obj/structure/closet/crate/crabCrate = null
	var/crabHome = FALSE

	wanted_objects = list(/obj/structure/closet/crate, /obj/structure/reagent_dispensers/cauldron)
	var/list/badCrateForCrab = list()

/datum/locking_category/carry_crab

/mob/living/simple_animal/hostile/fishing/carry_crab/New()
	..()
	if(prob(10))
		crabToWinLootCrate()

/mob/living/simple_animal/hostile/fishing/carry_crab/proc/crabToWinLootCrate()
	var/obj/structure/closet/crate/sunkenChest/sC = new /obj/structure/closet/crate/sunkenChest(loc)
	crabHome = TRUE
	crabCrate =
	//Add things from the salvage loot table, maybe item fish too

/mob/living/simple_animal/hostile/fishing/carry_crab/attack_hand(mob/user)
	..()
	if(crabCrate)
		if((beenTamed) && (is_type_in_list(user, friends))
			if(!crabCrate.opened)
				crabCrate.open()
			else
				crabCrate.close()
		else
			UnarmedAttack(user)
			to_chat(user, "<span class ='warning'>The [src] snaps its claw at you. It doesn't want you touching its home!</span>")


/mob/living/simple_animal/hostile/fishing/carry_crab/attackby(obj/item/R, mob/user)
	..()
	if(crabCrate)
		crabCrate.attackby(R, user)
	else if(crabCauldron)
		crabCauldron.attackby(R, user)


/mob/living/simple_animal/hostile/fishing/carry_crab/AttackingTarget()
	if(is_type_in_list(target, wanted_objects))
		if(is_type_in_list(target, badCrateForCrab) || !isturf(target.loc))	//to-do: check if it's locked as well
			loseTarget()	//Just make it not search for things while it has a home
			return
		visible_message("The [src] scuttles excitedly and snips its claws at \the [target]!")
		crabNewHome(target)
	..()

/mob/living/simple_animal/hostile/fishing/proc/crabNewHome(target)
	if(target.anchored)
		visible_message("The [src] cannot move \the [target] and snaps its claws in frustration!")
		loseTarget()
		return
	if(istype(target, /obj/structure/closet/crate))
		if(istype(target, /obj/structure/closet/crate/secure))
			var/obj/structure/closet/crate/secure/L = target
			if(L.locked)
				visible_message("The [src], unable to pry open \the [L] begins snapping its claws in disappointment!")
				loseTarget()
				return
		crabCrate = target
		crabClaimCrate()
	if(istype(target, /obj/structure/reagent_dispensers/cauldron))
		crabCauldron = target
		crabClaimCauldron()

/mob/living/simple_animal/hostile/fishing/proc/crabClaimCrate()
	crabCrate.open(src)
	crabCrate.storage_capacity -= catchSize/3	//Bigger crab takes up more space
	lock_atom(C, /datum/locking_category/carry_crab)
	crabUpdate()

/mob/living/simple_animal/hostile/fishing/proc/crabClaimCauldron()
	for(var/atom/movable/A in crabCauldron)
		if(ismob(A))
			UnarmedAttack(A)
		A.forcemove(loc)
		visible_message("The [src] yanks \the [A] out of the [crabCauldron]!")
	lock_atom(C, /datum/locking_category/carry_crab)
	crabUpdate()


/mob/living/simple_animal/hostile/fishing/proc/crabUpdate
	if(crabHome)
		melee_damage_lower = 5
		melee_damage_upper = 10 //The crab has been calmed by his cozy house
		maxHealth = 100	//Crates have 100 health
		health = 100
		search_objects = 0
		faction = "neutral"
	if(!crabHome)
		melee_damage_lower = 20
		melee_damage_upper = 25
		health = 25
		maxhealth = 25
		search_objects = 1
		faction = "hostile"


///mob/living/simple_animal/hostile/fishing/carry_crab/proc/openCrab()
//	for(var/obj/O in src)
//		O.forceMove(src.loc)

///mob/living/simple_animal/hostile/fishing/carry_crab/proc/closeCrab()
//	var/turf/T = get_turf(src)
//	for(var/obj/item/i in T)
//		if(contents.len >= crabPacity)
//			break
//		if((i.anchored) || (i.density))
//			return
//		i.forceMove(src)

/mob/living/simple_animal/hostile/fishing/carry_crab/death(var/gibbed = FALSE)
	if(crabHome)
		if(crabCrate)
			crabCrate.dump_contents()
			qdel(crabCrate)
			crabCrate = null
		if(crabCauldron)
			if(crabCauldron.reagents)
				var/cDivide = 0
				for(var/atom/A in range(1))
					cDivide += 1
				var/C = (crabCauldron.reagents.total_volume/cDivide, 1)
				for(var/atom/S in range(1))
					if(crabCauldron.reagents.total_volume < 1)
						break
					splash_sub(crabCauldron.reagents, S, C)
			crabCauldron = null
		crabHome = null
		crabUpdate()
	else
		..()
