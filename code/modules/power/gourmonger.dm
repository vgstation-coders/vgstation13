#define GOURMONGER_STARVING 50
#define GOURMONGER_SATISFIED 500
#define TOO_MANY_GOURS 30

var/global/gourmonger_saturation = 0

/mob/living/simple_animal/hostile/gourmonger
	name = "Gourmonger"
	desc = "A bio-engineered lifeform designed to recycle excess organic matter into fuel."
	icon = 'icons/mob/gourmonger.dmi'
	icon_state = "gourmonger"
	icon_living = "gourmonger"
	icon_dead = "gourmonger"	//This shouldn't happen
	faction = "gourmonger"
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
	var/kcalPower = 100	//Banked nutrition
	var/growToSplit = 20	//How many meals (not nutrition, instances of eating) it takes to split into another gour
	var/mealCount = 0	//How close to splitting we are
	var/fastingTime = 0	//Goes up every tick. Decides how much kcal we lose and how close to losing a mealCount we are.
	var/currentlyMunching = FALSE	//If it's currently eating so it doesn't keep trying.
	var/mob/living/sniffTarget = null	//The target we're hunting while loose.


/mob/living/simple_animal/hostile/gourmonger/New()
	..()
	gourmonger_saturation++
	growToSplit += gourmonger_saturation	//Adding on spawn so one doesn't die and cause an unexpected chain reaction
	kcalPower += rand(0, 50)	//For funsies

/mob/living/simple_animal/hostile/gourmonger/Life()
	if(!..())
		return
	metabolizeTick()	//Process kcal/meal loss over time
	radBurst(kcalPower/3)	//Generate power every tick
	hungerCheck()	//Are we loose?
	if(hangry && !target)
		if(sniffTarget)
			chargeToPrey()	//Hunt man down
		else
			findPrey()	//Find man to hunt

/mob/living/simple_animal/hostile/gourmonger/death()
	gourmonger_saturation--
	divideMeat()	//Just an easier way to do it than tinkering with dropMeat().
	gibs(get_turf(src))
	..()
	qdel(src)

/mob/living/simple_animal/hostile/gourmonger/examine(mob/user)
	..()
	if(kcalPower < 150)
		to_chat(user, "<span class='warning'>The [src] looks absolutely famished. It is drooling slightly.</span>")
	else if(kcalPower > 1000)
		to_chat(user, "<span class='notice'>The [src] is even fatter than usual.</span>")

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
		if(friends.Find(L))
			return 0
		if(!L.stat && !hangry)	//So we attack corpses but not living creatures unless we're starving
			return 0
		if(sniffTarget)	//Why are we running across the station if there's food right in front of us?
			sniffTarget = null
		return 1
	if(isobj(the_target))
		if(is_type_in_list(the_target, wanted_objects))
			if(sniffTarget)
				sniffTarget = null
			return 1
	return 0

/mob/living/simple_animal/hostile/gourmonger/PickTarget(var/list/Targets)	//Removed fuzzyrules eval as it was hindering their targeting priority
	if(target)
		for(var/atom/A in Targets)
			var/target_dist = get_dist(src, target)
			var/possible_target_distance = get_dist(src, A)
			if(target_dist < possible_target_distance)
				Targets -= A
	if(!Targets.len)
		return
	var/chosen_target = pick(Targets)	//Gours pick a random target rather than the top priority target. The latter had them all starve trying to eat the same pumpkin.
	return chosen_target



/mob/living/simple_animal/hostile/gourmonger/Goto(var/target, var/delay, var/minimum_distance)
	if(hangry)
		chargeToPrey(target)	//Chases people at normal speed + 1 tile a tick. Call it a runner's kick. If they put a window between them and it it will still break it.
	..()

/mob/living/simple_animal/hostile/gourmonger/proc/metabolizeTick()
	if(kcalPower > 0)
		kcalPower -= fastingTime/5	//Longer without a meal, hungrier they get
	if(mealCount && prob((fastingTime + mealCount)/10))	//Higher chance based on time and how full they are.
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

/mob/living/simple_animal/hostile/gourmonger/proc/radBurst(var/radVal)
	emitted_harvestable_radiation(get_turf(src), radVal, 8)
	for(var/mob/living/L in view(get_turf(src), 5))
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
	spawn()
		if(istype(target, /obj/item/weapon/reagent_containers/food/snacks))
			eatFood(target)
		if(isliving(target))
			var/mob/living/M = target
			if(M.isDeadorDying())
				eatCorpse(M)
			else if(hangry)
				radBurst(kcalPower*2)	//Inherently limited by GOURMONGER_SATISFIED
				..()

/mob/living/simple_animal/hostile/gourmonger/proc/munchOn(var/atom/T, var/munchTime = 3)
	flick("gourmonger_eat", src)	//This is a 2.8 second animation
	currentlyMunching = TRUE
	canmove = 0
	for(var/i = 0, i<munchTime, i++)
		if(T.gcDestroyed)
			target = null
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

/mob/living/simple_animal/hostile/gourmonger/proc/sniffForPrey()
	var/sniffMeal = null
	var/sniffDist = 50	//Easy way to make 50 the max range and avoids needing to use get_dist twice per loop
	for(var/client/C in clients)
		if(isliving(C.mob) && !issilicon(C.mob))
			var/mob/living/L = C.mob
			if(get_dist(src, L) < sniffDist && z == L.z)
				sniffMeal = L
				sniffDist = get_dist(src, L)
	if(sniffMeal)
		sniffTarget = sniffMeal
		return TRUE
	if(istype(loc, /obj/structure))	//Really? No players in 50 tiles? Maybe our z is 0, let's check
		gourEscape()

/mob/living/simple_animal/hostile/gourmonger/proc/findPrey()
	flick("gourmonger_sniff", src)
	visible_message("<span class='warning'>\The [src] is tasting for a scent.</span>")
	if(sniffForPrey())
		spawn(1 SECONDS)
			chargeToPrey()

/mob/living/simple_animal/hostile/gourmonger/proc/chargeToPrey(var/mob/living/cTarg = sniffTarget)
	if(currentlyMunching)
		return
	if(!cTarg || cTarg.gcDestroyed)
		sniffTarget = null
		return
	if(cTarg.loc == loc)
		return
	if(istype(loc, /obj/structure))
		gourEscape()
	var/chargeDir = get_dir_cardinal(src, cTarg)
	if(!step(src, chargeDir))
		var/turf/T = get_step(src, chargeDir)
		chargeThrough(T)
		if(Adjacent(T))
			forceMove(T)

/mob/living/simple_animal/hostile/gourmonger/proc/chargeThrough(var/turf/cT)
	if(istype(cT, /turf/simulated/wall))
		cT.dismantle_wall(1)
	for(var/obj/machinery/M in cT.contents)	//All these just mimic what machinery does on tool use
		if(!M.density)
			continue
		if(istype(M, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/A = M
			A.bashed_in(src)
		gourThroughMachine(M)
	for(var/obj/structure/S in cT.contents)
		if(S.density)
			S.ex_act(1)	//Safest way to do this, probably
	for(var/mob/living/L in cT.contents)
		if(L == src)
			continue
		gourThroughMob(L)

/mob/living/simple_animal/hostile/gourmonger/proc/gourThroughMachine(var/obj/machinery/M)
	for(var/mob/living/L in M.contents)
		L.forceMove(M.loc)
	if(M.machine_flags & CROWDESTROY)
		M.dropFrame()
		M.spillContents()
		qdel(M)
	else if(M.wrenchable())
		M.state = 0
		M.anchored = FALSE
		M.power_change()

/mob/living/simple_animal/hostile/gourmonger/proc/gourThroughMob(var/mob/living/L)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.Knockdown(2)
	L.adjustBruteLoss(20)
	if(!issilicon(L))
		target = L	//Oh hey meat. Also lets them eat each other if they're too hungry, but not specifically seek to.

/mob/living/simple_animal/hostile/gourmonger/proc/gourEscape()
	var/obj/structure/S = loc
	var/turf/T = get_turf(S)
	forceMove(T)
	S.ex_act(1)

//His cube////////

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/gourmonger
	name = "gourmonger cube"
	contained_mob = /mob/living/simple_animal/hostile/gourmonger
