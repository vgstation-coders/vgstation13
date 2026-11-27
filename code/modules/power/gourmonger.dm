#define GOURMONGER_STARVING 25
#define GOURMONGER_HUNGRY 150
#define GOURMONGER_SATISFIED 500
#define TOO_MANY_GOURS 30

var/global/gourmonger_saturation = 0

/mob/living/simple_animal/hostile/gourmonger
	name = "\improper Gourmonger"
	desc = "A bio-engineered lifeform designed to recycle excess organic matter into fuel."
	icon = 'icons/mob/gourmonger.dmi'
	icon_state = "gourmonger"
	icon_living = "gourmonger"
	icon_dead = "gourmonger"	//This shouldn't happen
	faction = "gourmonger"
	speak_emote = list("stomach grumbles")
	health = 125
	maxHealth = 125
	melee_damage_lower = 5
	melee_damage_upper = 10	//The rads are the real danger
	stat_attack = DEAD	//So it attacks corpses.
	search_objects = 1	//Searches objects but doesn't ignore people. The ignoring before hanger is in its CanAttack()
	environment_smash_flags = SMASH_CONTAINERS
	wanted_objects = list(/obj/item/weapon/reagent_containers/food/snacks)
	meat_amount = 1
	speed = 1.2	//Able to just barely outrun them
	min_oxy = 0	//I dunno it breathes food or something. Makes the shard room usable.
	max_co2 = 0
	var/hangry = FALSE	//True = loose
	var/kcalPower = 200	//Banked nutrition
	var/growToSplit = 20	//How many meals (not nutrition, instances of eating) it takes to split into another gour
	var/mealCount = 0	//How close to splitting we are
	var/fastingTime = 0	//Goes up every tick. Decides how much kcal we lose and how close to losing a mealCount we are.
	var/currentlyMunching = FALSE	//If it's currently eating so it doesn't keep trying.
	var/beenStuckCount = 0		//Work around for it being stuck on things it can't charge through
	var/turf/stuckTurf = null	//Where we're stuck
	var/list/justBreakIt = list(	//Fuck it and fuck mecha
		/obj/effect/decal/mecha_wreckage,
		/obj/machinery/power/treadmill,
	)

/mob/living/simple_animal/hostile/gourmonger/New()
	..()
	gourmonger_saturation++
	growToSplit += gourmonger_saturation	//Adding on spawn so one doesn't die and cause an unexpected chain reaction

/mob/living/simple_animal/hostile/gourmonger/Life()
	if(!..())
		return
	metabolizeTick()	//Process kcal/meal loss over time
	radBurst(kcalPower/3)	//Generate power every tick
	hungerCheck()	//Are we loose?

/mob/living/simple_animal/hostile/gourmonger/death()
	gourmonger_saturation--
	divideMeat()	//Just an easier way to do it than tinkering with dropMeat().
	gibs(get_turf(src))
	..()
	qdel(src)

/mob/living/simple_animal/hostile/gourmonger/examine(mob/user)
	..()
	if(kcalPower < 150)
		to_chat(user, "<span class='warning'>\The [src] looks absolutely famished. It is drooling slightly.</span>")
	else if(kcalPower > 1000)
		to_chat(user, "<span class='notice'>\The [src] is even fatter than usual.</span>")

/mob/living/simple_animal/hostile/gourmonger/attackby(obj/W, mob/user)
	..()
	if(!hangry && istype(W, /obj/item/weapon/reagent_containers/food/snacks))
		handFeed(W, user)

/mob/living/simple_animal/hostile/gourmonger/proc/handFeed(var/obj/item/weapon/reagent_containers/food/snacks/F, mob/user)
	if(currentlyMunching)
		to_chat(user, "<span class='info'>\The [src] is busy eating something else.</span>")
		return
	eatFood(F)
	if(F.gcDestroyed)
		LoseTarget()	//Functions as a reset too, in case they're fixated on something out of their reach or whatever
		if(prob(5))
			var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
			heart.plane = ABOVE_HUMAN_PLANE
			flick_overlay(heart, list(user.client), 20)

/mob/living/simple_animal/hostile/gourmonger/CanAttack(var/atom/the_target) //My hands are tied. I swear I had a reason for this copy paste. It also trims some weight from targeting.
	if(currentlyMunching)
		return 0
	if(the_target.invisibility)
		return 0
	if(isliving(the_target))
		var/mob/living/L = the_target
		if(L.flags & INVULNERABLE)
			return 0
		if(isMoMMI(L))
			return 0
		if(L.faction == src.faction || faction == "\ref[L]")
			return 0
		if(faction == "slimesummon")
			if(isslime(L))
				return 0
			if(ishuman(L))
				var/mob/living/carbon/human/H = L
				if((isslimeperson(H)) || (isgolem(H)))
					return 0
		if((istype(L,/mob/living/carbon/human/dummy)) && (faction == "adminbus mob"))
			return 0
		for(var/datum/weakref/ref in friends)
			if (ref.get() == L)
				return 0
		if(!L.stat && !hangry)	//So we attack corpses but not living creatures unless we're starving
			return 0
		return 1
	if(isobj(the_target))
		if(is_type_in_list(the_target, wanted_objects))
			return 1
	return 0

/mob/living/simple_animal/hostile/gourmonger/proc/metabolizeTick()
	if(kcalPower > 0)
		kcalPower -= fastingTime/20	//Longer without a meal, hungrier they get
	if(mealCount && prob((fastingTime/50) + mealCount))	//Higher chance based on time and how full they are.
		mealCount--
		fastingTime = 0
		glowCheck()
	else
		fastingTime++

/mob/living/simple_animal/hostile/gourmonger/proc/hungerCheck()
	if(!hangry && kcalPower < GOURMONGER_STARVING)
		hangry = TRUE
	else if(hangry && kcalPower > GOURMONGER_SATISFIED)
		hangry = FALSE
	else if(!hangry && kcalPower < GOURMONGER_HUNGRY)
		if(prob(50))
			say(pick("GrrrGRUhgrr", "BorrrboRRrygMMmmmus", "RrrrmmmRrrggrr"))	//Stomach rumbling. Not an emote so bounce radios can pick it up as a warning

/mob/living/simple_animal/hostile/gourmonger/proc/radBurst(var/radVal)
	emitted_harvestable_radiation(get_turf(src), radVal, 8)
	for(var/mob/living/L in view(get_turf(src), 3))
		L.apply_radiation(radVal/25, RAD_EXTERNAL)

/mob/living/simple_animal/hostile/gourmonger/proc/glowCheck() //Visible indicator of how close to splitting they are
	var/mealPerc = (mealCount / growToSplit) * 100
	switch(mealPerc)
		if(0 to 25)
			set_light(0)
		if(25 to 49)
			set_light(1, 2, "#c0e280")
		if(50 to 69)
			set_light(1, 3, "#86d46e")
		if(70 to 84)
			set_light(1, 4, "#5ad35a")
		if(85 to 94)
			set_light(2, 5, "#1cc446")
		if(95 to 100)
			set_light(2, 6, "#00af2c")



/mob/living/simple_animal/hostile/gourmonger/proc/gourSplit(var/mouthsToFeed = 2)
	if(gourmonger_saturation >= TOO_MANY_GOURS)
		return
	for(var/i in 1 to mouthsToFeed)
		var/mob/living/simple_animal/hostile/gourmonger/gourBaby = new /mob/living/simple_animal/hostile/gourmonger(loc)
		gourBaby.kcalPower += kcalPower*0.1	//Causes splitting to effectively multiply nutrients when combined with divideMeat(). Also prevents babies from starving too fast.
		try_move_adjacent(gourBaby)
	radBurst(kcalPower*3)
	death()

/mob/living/simple_animal/hostile/gourmonger/proc/divideMeat()
	var/nToDiv = kcalPower/15	//1u nutriment is worth about 15kcalPower
	meat_amount += nToDiv/20
	for(var/i=0, i<meat_amount, i++)	//Basically making one piece of meat for every 20u nutriment then making another if we still have some left.
		var/nToAdd = min(20, nToDiv)
		var/obj/item/weapon/reagent_containers/food/snacks/firstMeal = drop_meat(loc)
		firstMeal.reagents.add_reagent(NUTRIMENT, nToAdd)
		nToDiv -= nToAdd
		if(!nToDiv)
			break
	meat_amount = 0

/mob/living/simple_animal/hostile/gourmonger/AttackingTarget()
	if(currentlyMunching)
		return
	// The attack leaf points the legacy target at the blackboard target for this
	// call, but eatFood/eatCorpse sleep, so capture the target in a local before
	// spawning the eating thread.
	var/atom/the_target = target
	if(!the_target && ai_controller)
		the_target = ai_controller.blackboard[BB_TARGET]
	if(!the_target)
		return
	spawn()
		if(istype(the_target, /obj/item/weapon/reagent_containers/food/snacks))
			eatFood(the_target)
		if(isliving(the_target))
			var/mob/living/M = the_target
			if(M.isDeadorDying())
				eatCorpse(M)
			else if(hangry)
				radBurst(kcalPower*2)	//Inherently limited by GOURMONGER_SATISFIED
				..()

/mob/living/simple_animal/hostile/gourmonger/proc/munchOn(var/atom/T, var/munchTime = 3)
	if(currentlyMunching)
		return FALSE
	flick("gourmonger_eat", src)	//This is a 2.8 second animation
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

/mob/living/simple_animal/hostile/gourmonger/proc/eatFood(var/obj/item/weapon/reagent_containers/food/snacks/toEat)
	if(!munchOn(toEat))
		return
	var/nValue = 0
	for(var/datum/reagent/R in toEat.reagents.reagent_list)
		nValue += (R.nutriment_factor / R.custom_metabolism) * R.volume	//Essentially the nutrition a human would get from 1u
	toEat.reagents.clear_reagents()
	eatOutcome(nValue, nValue/2)
	toEat.after_consume(src)
	if(!toEat.gcDestroyed)
		qdel(toEat)

/mob/living/simple_animal/hostile/gourmonger/proc/eatCorpse(var/mob/living/L)
	if(ishuman(L))
		eatLimb(L)
	else
		if(!munchOn(L))
			return
		var/nValue = decideNutrition(L)
		eatOutcome(nValue, nValue, 2)
		L.gib()

/mob/living/simple_animal/hostile/gourmonger/proc/eatLimb(var/mob/living/carbon/human/H)
	if(!munchOn(H))
		return
	var/nValue = decideNutrition(H)
	var/datum/organ/external/toEat = H.pick_usable_organ(LIMB_LEFT_ARM, LIMB_RIGHT_ARM, LIMB_LEFT_LEG, LIMB_RIGHT_LEG)
	if(toEat)
		toEat.droplimb(1, 0, 0)
		visible_message("<span class='warning'>\The [src] is devouring [H]'s [toEat.display_name]!</span>")
	else
		visible_message("<span class='warning'>\The [src] has devoured [H] completely!</span>")
		H.gib()
	eatOutcome(nValue, nValue, 3)

/mob/living/simple_animal/hostile/gourmonger/proc/decideNutrition(var/theMeal)
	var/mealValue = 0
	if(iscarbon(theMeal))
		var/mob/living/carbon/C = theMeal
		mealValue = C.nutrition/3	//5 meals per corpse. So you, probably, get more out of an obese corpse than you would just feeding the food to the gour.
	else if(isanimal(theMeal))
		var/mob/living/simple_animal/A = theMeal
		mealValue = A.maxHealth*2
	return mealValue

/mob/living/simple_animal/hostile/gourmonger/proc/eatOutcome(var/passToRad, var/passToKcal, var/growMod = 1)
	radBurst(passToRad)
	kcalPower += passToKcal
	maxHealth += growMod //Raise your gour with love, tatorman
	health += growMod
	mealCount += growMod
	glowCheck()
	if(mealCount > growToSplit)
		gourSplit()

/mob/living/simple_animal/hostile/gourmonger/proc/chargeToPrey(var/mob/living/cTarg = null)
	if(currentlyMunching)
		return
	if(!cTarg || cTarg.gcDestroyed)
		return
	if(cTarg.loc == loc)
		return
	if(istype(loc, /obj/structure))
		gourEscape()
	for(var/obj/item/weapon/reagent_containers/food/snacks/distractionMeal in get_turf(src))
		eatFood(distractionMeal)
		return
	var/chargeDir = get_dir_cardinal(src, cTarg)
	if(!step(src, chargeDir))
		stuckTurf = get_turf(src)
		var/turf/T = get_step(src, chargeDir)
		chargeThrough(T, chargeDir)
		if(stuckTurf == get_turf(src))
			handleStuck(chargeDir)
		else
			stuckTurf = null

/mob/living/simple_animal/hostile/gourmonger/proc/handleStuck(var/attemptedDir)
	beenStuckCount++
	if(beenStuckCount >= 4)	//4 attempts should give it enough time to deal with things that require multiple charge through attempts
		var/turf/chargeTarg = null
		if(attemptedDir == NORTH || attemptedDir == SOUTH)
			chargeTarg = get_step(src, pick(WEST, EAST))
		else if(attemptedDir == WEST || attemptedDir == EAST)
			chargeTarg = get_step(src, pick(NORTH, SOUTH))
		if(chargeTarg)
			chargeThrough(chargeTarg)
	if(stuckTurf != get_turf(src))
		beenStuckCount = 0
		stuckTurf = null
	else if(beenStuckCount >= 10)	//Aight fuck this we're finding a new target
		LoseTarget()

/mob/living/simple_animal/hostile/gourmonger/proc/chargeThrough(var/turf/cT, var/cDir)
	if(istype(cT, /turf/simulated/wall))
		cT.dismantle_wall(1)
	for(var/atom/blocker in cT.contents)
		if(!blocker.density)
			continue
		if(istype(blocker, /obj/machinery))
			if(istype(blocker, /obj/machinery/door/airlock))
				var/obj/machinery/door/airlock/A = blocker
				A.bashed_in(src)
			gourThroughMachine(blocker)
		else if(istype(blocker, /obj/structure) || istype(blocker, /obj/item) || istype(blocker, /obj/mecha))	//anvils, tape
			blocker.ex_act(1)
		else if(isliving(blocker))
			if(blocker == src)
				continue
			gourThroughMob(blocker)
		else if(is_type_in_list(blocker, justBreakIt))
			blocker.ex_act(1)
	if(Adjacent(cT))
		step(src, cDir)

/mob/living/simple_animal/hostile/gourmonger/proc/gourThroughMachine(var/obj/machinery/M)
	for(var/mob/living/L in M.contents)
		L.forceMove(M.loc)
	if(M.machine_flags & CROWDESTROY)
		M.dropFrame()
		M.spillContents()
		qdel(M)
		return
	if(M.wrenchable())
		M.state = 0
		M.anchored = FALSE
		M.power_change()
		return
	M.ex_act(1) //"Just get out of my waaaaaaay"

/mob/living/simple_animal/hostile/gourmonger/proc/gourThroughMob(var/mob/living/L)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.Knockdown(2)
	L.adjustBruteLoss(20)
	if(!issilicon(L))
		// Oh hey meat. Also lets them eat each other if they're too hungry, but
		// not specifically seek to.
		if(ai_controller)
			ai_controller.blackboard[BB_TARGET] = L
		else
			target = L

/mob/living/simple_animal/hostile/gourmonger/proc/gourEscape()
	var/obj/structure/S = loc
	var/turf/T = get_turf(S)
	forceMove(T)
	S.ex_act(1)

//His cube////////

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/gourmonger
	name = "gourmonger cube"
	contained_mob = /mob/living/simple_animal/hostile/gourmonger

/mob/living/simple_animal/hostile/gourmonger/use_hostile_tree()
	return ..(bt_gourmonger_tree())

/// Gourmongers pick a random target instead of the closest one, so a pack does
/// not all starve staring at the same pumpkin.
/datum/target_source/enemies/gourmonger_prey
/datum/target_source/enemies/gourmonger_prey/pick_target(datum/ai_controller/controller, mob/living/pawn, list/candidates)
	if(!length(candidates))
		return null
	return pick(candidates)

/// While hangry, sniff out client mobs within 50 tiles (the legacy findPrey()
/// range) in addition to the normal local targets.
/datum/target_source/enemies/gourmonger_sniff
/datum/target_source/enemies/gourmonger_sniff/pick_target(datum/ai_controller/controller, mob/living/pawn, list/candidates)
	if(!length(candidates))
		return null
	return pick(candidates)

/datum/target_source/enemies/gourmonger_sniff/find_targets(datum/ai_controller/controller, mob/living/pawn, search_range)
	var/mob/living/simple_animal/hostile/gourmonger/gour = pawn
	if(!istype(gour) || !gour.hangry || gour.currentlyMunching)
		return list()
	// Keep the legacy local vision range for normal targets; sniffed players can
	// be farther away.
	var/list/candidates = ..(controller, pawn, min(search_range, 7))
	for(var/client/C in clients)
		var/mob/living/L = C.mob
		if(!isliving(L) || issilicon(L) || L == gour || L.z != gour.z)
			continue
		if(get_dist(gour, L) > search_range)
			continue
		if(!gour.CanAttack(L))
			continue
		if(L in candidates)
			continue
		candidates += L
	return candidates

/datum/target_source/enemies/gourmonger_sniff/is_valid_target(datum/ai_controller/controller, mob/living/pawn, atom/existing)
	var/mob/living/simple_animal/hostile/gourmonger/gour = pawn
	if(!istype(gour) || !gour.hangry || gour.currentlyMunching)
		return FALSE
	return ..(controller, pawn, existing)

/// Charges at the sniffed target through walls and machinery.
/datum/bt_node/ai_behavior/gourmonger_charge
/datum/bt_node/ai_behavior/gourmonger_charge/setup(datum/ai_controller/controller)
	var/mob/living/simple_animal/hostile/gourmonger/gour = controller.pawn
	var/atom/target = controller.blackboard[BB_TARGET]
	if(!istype(gour) || !target || QDELETED(target))
		return FALSE
	return get_dist(gour, target) > 1

/datum/bt_node/ai_behavior/gourmonger_charge/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/simple_animal/hostile/gourmonger/gour = controller.pawn
	var/atom/target = controller.blackboard[BB_TARGET]
	if(!istype(gour) || !target || QDELETED(target) || get_dist(gour, target) <= 1)
		return AI_BEHAVIOR_FAILED
	gour.chargeToPrey(target)
	return AI_BEHAVIOR_SUCCEEDED

/// Legacy findPrey() escaped a gourmonger that was stuck inside a structure
/// when no player was around.
/datum/bt_node/ai_behavior/gourmonger_escape
/datum/bt_node/ai_behavior/gourmonger_escape/setup(datum/ai_controller/controller)
	var/mob/living/simple_animal/hostile/gourmonger/gour = controller.pawn
	if(!istype(gour) || gour.ai_has_target())
		return FALSE
	return istype(gour.loc, /obj/structure)

/datum/bt_node/ai_behavior/gourmonger_escape/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/simple_animal/hostile/gourmonger/gour = controller.pawn
	if(!istype(gour) || !istype(gour.loc, /obj/structure))
		return AI_BEHAVIOR_FAILED
	gour.gourEscape()
	return AI_BEHAVIOR_SUCCEEDED

/proc/bt_gourmonger_tree()
	return list(
		BT_DESC_TYPE = /datum/bt_node/composite/selector,
		BT_DESC_CHILDREN = list(
			list(
				BT_DESC_TYPE = /datum/bt_node/composite/sequence,
				BT_DESC_CHILDREN = list(
					list(
						BT_DESC_TYPE = /datum/bt_node/ai_behavior/acquire_target,
						target_source_type = /datum/target_source/enemies/gourmonger_sniff,
						search_range = 50,
					),
					list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/gourmonger_charge),
				),
			),
			bt_hostile_combat_tree(/datum/target_source/enemies/gourmonger_prey),
			list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/gourmonger_escape),
		),
	)
