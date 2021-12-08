///////////////////////////////////
//            CULT RITUALS
// 
// 
// 
///////////////////////////////////

var/global/veil_weakness = 0	            // how weak the veil of reality is. as cultists perform rituals, this increases
var/global/list/unlocked_rituals = list()		// Rituals that the cult can perform, and have yet to do so.
var/global/list/completed_rituals = list()	// Rituals that the cult has completed, and can no longer perform.
var/global/list/locked_rituals = list()		// Rituals that the cult haven't unlocked yet.
var/global/list/cult_altars = list()       // List of cult altars in the world.

/datum/faction/bloodcult/proc/GetVeilWeakness()
	return veil_weakness

/datum/faction/bloodcult/proc/GetUnlockedRituals()
	return unlocked_rituals

/datum/faction/bloodcult/proc/GetCultAltars()
	return cult_altars

/datum/faction/bloodcult/proc/initialize_rituals()
	unlocked_rituals += new /datum/bloodcult_ritual/continuous/offerings
	unlocked_rituals += new /datum/bloodcult_ritual/draw_rune
	unlocked_rituals += new /datum/bloodcult_ritual/sow_confusion

/datum/faction/bloodcult/proc/update_cultist_uis()
	for(var/datum/role/cultist/C in members)
		C.update_cult_hud()

/proc/CompleteCultRitual(var/ritualtype, var/mob/cultist, var/list/extrainfo )
	var/datum/bloodcult_ritual/R = locate(ritualtype) in unlocked_rituals
	if(R)
		R.Complete(cultist, extrainfo)

/datum/bloodcult_ritual
	var/name = "Cult Ritual"        
	var/desc = "Do something culty!"
	var/worth = 0
	var/max_times = 0       // The ritual will stop working after this many times. 0 = infinite
	var/times_completed = 0

/datum/bloodcult_ritual/proc/CheckCompletion()
	return

/datum/bloodcult_ritual/proc/Complete()
	return

/datum/bloodcult_ritual/proc/Reward(var/worth_override)
	if(!worth_override)
		worth_override = worth
	veil_weakness += worth_override
	times_completed += 1
	if(max_times != 0 && times_completed >= max_times)
		unlocked_rituals -= src
		completed_rituals += src
	var/datum/faction/bloodcult/B = locate(/datum/faction/bloodcult) in ticker.mode.factions
	if(B)
		B.update_cultist_uis()

/datum/bloodcult_ritual/proc/GrantTattoo(var/mob/cultist, var/type)
	if(!ishuman(cultist))
		return
	if(cultist.mind)
		var/datum/role/cultist/C = cultist.mind.GetRole(CULTIST)
		if(!C)
			return
		C.GiveTattoo(type)



/datum/bloodcult_ritual/continuous 
	var/rate = 5 SECONDS   		// The rate at which the ritual weakens the veil.
	var/next_reward
	var/points_rewarded = 0
	var/point_limit = 0    			// The ritual will stop weakening the veil after this limit is reached. Set to zero to disable.

/datum/bloodcult_ritual/continuous/CheckCompletion()  
	if(world.time < next_reward)
		return FALSE
	next_reward = world.time + rate
	return TRUE

/datum/bloodcult_ritual/continuous/Reward(var/worth_override)
	if(!worth_override)
		worth_override = worth
	points_rewarded += worth_override
	veil_weakness += worth_override
	if(point_limit != 0 && points_rewarded >= point_limit)
		unlocked_rituals -= src
		completed_rituals += src
	var/datum/faction/bloodcult/B = locate(/datum/faction/bloodcult) in ticker.mode.factions
	if(B)
		B.update_cultist_uis()

/////////////////////////////////////

/datum/bloodcult_ritual/continuous/offerings
	name = "Offerings"
	desc = "Place cult objects on top of an altar to weaken the veil."

//		OFFERINGS BONUS CALCULATION: (once per area)
//		(items must be placed on top of altar)
//	
//		Altar Exists 				(1 point)
//		Talisman 					(1 point)
// 		Skull 						(3 points)
// 		Meat 						(2 points)
// 		Blood in a container 		(1 point per 25 units, 1 container max, 1 bonus point for cult goblet)
//		Candles						(1 point per candle, 5 max)
// 		Soul Gem					(8 points)
// 		Tome						(2 points)
//   	Dead animals 				(varies, command staff pets are worth a lot more)


/datum/bloodcult_ritual/continuous/offerings/CheckCompletion()
	if(..())
		var/list/ritual_areas = list()
		var/awardedpoints = 0
		for(var/obj/structure/cult/altar/C in cult_altars)
			var/turf/T = get_turf(C)
			var/area/A = T.loc
			if(!T || !A)
				continue
			if(isspace(A))
				continue
			if(locate(A) in ritual_areas)
				continue
			ritual_areas += A

			awardedpoints += 1			
			if(locate(/obj/item/weapon/talisman) in T.contents)
				awardedpoints += 1
			if(locate(/obj/item/weapon/skull) in T.contents)
				awardedpoints += 3
			if(locate(/obj/item/weapon/reagent_containers/food/snacks/meat) in T.contents)
				awardedpoints += 2
			if(locate(/obj/item/soulstone/gem/) in T.contents)
				awardedpoints += 8
			if(locate(/obj/item/weapon/tome) in T.contents)
				awardedpoints += 1

			var/pyloncount = 0
			for(var/obj/structure/cult_legacy/pylon/P in range(1,T))
				if(!P.isbroken)
					pyloncount++
			if(pyloncount >= 2)
				awardedpoints += 5

			var/obj/item/weapon/reagent_containers/container = locate(/obj/item/weapon/reagent_containers) in T.contents
			if(container)
				if(istype(container, /obj/item/weapon/reagent_containers/food/drinks/cult))
					awardedpoints += 1
				for(var/datum/reagent/R in container.reagents.reagent_list)
					if(R.id == BLOOD)
						awardedpoints += round(R.volume / 25)

			var/candles = 0
			for(var/obj/item/candle/blood/BC in T.contents)
				awardedpoints += 1
				candles += 1
				if(candles >= 5)
					break

			var/mob/living/simple_animal/animal = locate(/mob/living/simple_animal) in T.contents
			if(animal && animal.stat == DEAD)	
				if(istype(animal, /mob/living/simple_animal/cat))
					awardedpoints += 8
					if(istype(animal, /mob/living/simple_animal/cat/salem) || istype(animal, /mob/living/simple_animal/cat/Runtime))
						awardedpoints += 10
				else if(istype(animal, /mob/living/simple_animal/corgi))
					awardedpoints += 8
					if(istype(animal, /mob/living/simple_animal/corgi/Ian) || istype(animal, /mob/living/simple_animal/corgi/sasha)) 
						awardedpoints += 17	
				else if(istype(animal, /mob/living/simple_animal/parrot/Poly))
					awardedpoints += 12
				else if(istype(animal, /mob/living/simple_animal/mouse))
					awardedpoints += 2
				else 
					awardedpoints += 5

			if(!locate(/obj/effect/cult_offerings) in C.vis_contents)
				C.vis_contents += new /obj/effect/cult_offerings

		Reward(awardedpoints)
	else




/datum/bloodcult_ritual/draw_rune
	name = "Draw Rune"
	desc = "Draw a rune."
	worth = 1

/datum/bloodcult_ritual/sow_confusion
	name = "Sow Confusion"
	desc = "Use confusion talismans on non-cultists."

/datum/bloodcult_ritual/sow_confusion/Complete(var/mob/cultist, var/list/extrainfo)
	var/people = extrainfo["victimcount"]
	Reward(people * 10)
	GrantTattoo(cultist, /datum/cult_tattoo/dagger)