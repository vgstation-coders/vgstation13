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


#define SPIRE_STAGE_2 	30
#define SPIRE_STAGE_3 	60

/proc/ChangeVeilWeakness(var/add, var/set_to)
	if(set_to)
		veil_weakness = set_to
	else 
		veil_weakness += add
	var/datum/faction/bloodcult/B = locate(/datum/faction/bloodcult) in ticker.mode.factions
	if(B)
		B.update_cultist_uis()
	if(veil_weakness >= SPIRE_STAGE_3)	
		for(var/obj/structure/cult/spire/S in cult_spires)
			S.upgrade(3)
	else if(veil_weakness >= SPIRE_STAGE_2)
		for(var/obj/structure/cult/spire/S in cult_spires)
			S.upgrade(2)

/datum/faction/bloodcult/proc/GetVeilWeakness()
	return veil_weakness

/datum/faction/bloodcult/proc/GetUnlockedRituals()
	return unlocked_rituals

/datum/faction/bloodcult/proc/GetCultAltars()
	return cult_altars

/datum/faction/bloodcult/proc/initialize_rituals()
	for(var/type in (subtypesof(/datum/bloodcult_ritual) - /datum/bloodcult_ritual/continuous))
		unlocked_rituals += new type

/datum/faction/bloodcult/proc/update_cultist_uis()
	for(var/datum/role/cultist/C in members)
		C.update_cult_hud()

/proc/CompleteCultRitual(var/ritualtype, var/mob/cultist, var/list/extrainfo )
	var/datum/bloodcult_ritual/R = locate(ritualtype) in unlocked_rituals
	if(R)
		R.Complete(cultist, extrainfo)

/datum/bloodcult_ritual
	var/name = "Cult Ritual"        
	var/desc = ""
	var/point_limit = 0       // The ritual will stop working after this many points. 0 = infinite
	var/points_rewarded = 0

/datum/bloodcult_ritual/proc/CheckCompletion()
	return

/datum/bloodcult_ritual/proc/Complete()
	Reward()

/datum/bloodcult_ritual/proc/Reward(var/worth)
	points_rewarded += worth
	ChangeVeilWeakness(worth)
	if(point_limit != 0 && points_rewarded >= point_limit)
		unlocked_rituals -= src
		completed_rituals += src


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

/datum/bloodcult_ritual/continuous/CheckCompletion()  
	if(world.time < next_reward)
		return FALSE
	next_reward = world.time + rate
	return TRUE

/datum/bloodcult_ritual/proc/GetMobValue(var/type, var/multiplier)
	var/awardedpoints = 0
	switch(type)
		if(/mob/living/simple_animal/cat/salem)
			awardedpoints = 16
		if(/mob/living/simple_animal/cat/Runtime)
			awardedpoints = 16
		if(/mob/living/simple_animal/cat)
			awardedpoints = 8
		if(/mob/living/simple_animal/corgi/Ian)
			awardedpoints = 30
		if(/mob/living/simple_animal/corgi/sasha)
			awardedpoints = 25
		if(/mob/living/simple_animal/corgi/Lisa)
			awardedpoints = 30
		if(/mob/living/simple_animal/corgi)
			awardedpoints = 15
		if(/mob/living/simple_animal/parrot/Poly)
			awardedpoints = 10
		if(/mob/living/simple_animal/mouse)
			awardedpoints = 2
		if(/mob/living/simple_animal/cockroach)
			awardedpoints = 1
		else
			awardedpoints = 5
	return awardedpoints * multiplier

/////////////////////////////////////

/datum/bloodcult_ritual/continuous/offerings
	name = "Offerings"
	desc = "Place cult objects on top of an altar to weaken the veil."

//		OFFERINGS BONUS CALCULATION: (once per area)
//		(items must be placed on top of altar)
//	
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
				C.vis_contents = list()
				continue
			if(isspace(A))
				C.vis_contents = list()
				continue
			if(locate(A) in ritual_areas)
				C.vis_contents = list()
				continue
		
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
			for(var/obj/structure/cult/pylon/P in range(1,T))
				if(P.health > 20)
					pyloncount++
			if(pyloncount >= 2)
				awardedpoints += 6

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

			if(awardedpoints > 0)
				if(!locate(/obj/effect/cult_offerings) in C.vis_contents)
					C.vis_contents += new /obj/effect/cult_offerings
				ritual_areas += A
			else 
				C.vis_contents = list()

		Reward(awardedpoints)
	else


/datum/bloodcult_ritual/draw_rune
	name = "Draw Rune"
	desc = "Draw a rune."

/datum/bloodcult_ritual/draw_rune/Complete()
	Reward(1)

/datum/bloodcult_ritual/sow_confusion
	name = "Sow Confusion"
	desc = "Use confusion talismans on non-cultists."

/datum/bloodcult_ritual/sow_confusion/Complete(var/mob/cultist, var/list/extrainfo)
	var/people = extrainfo["victimcount"]
	Reward(people * 10)
	

/datum/bloodcult_ritual/animal_sacrifice
	name = "Small sacrifice"
	desc = "Impale a creature on an altar."
	
/datum/bloodcult_ritual/animal_sacrifice/Complete(var/mob/cultist, var/list/extrainfo)
	var/mobtype = extrainfo["mobtype"]
	var/points = GetMobValue(mobtype,4)
	Reward(points)
	if(points >= 20)
		GrantTattoo(cultist, /datum/cult_tattoo/dagger)


/datum/bloodcult_ritual/spirited_away
	name = "Spirited Away"
	desc = "Send a non-cultist through a path rune."
	var/list/previous_victims = list()

/datum/bloodcult_ritual/spirited_away/Complete(var/mob/cultist, var/list/extrainfo)
	var/list/victims = extrainfo["victims"]
	for(var/mob/V in victims)
		if(V in previous_victims)
			victims -= V
	previous_victims += victims
	if(victims.len > 0)
		Reward(25 * victims.len)
		GrantTattoo(cultist, /datum/cult_tattoo/shortcut)

/datum/bloodcult_ritual/human_sacrifice
	name = "Sacrifice"
	desc = "Impale a human at an altar and sacrifice them."

/datum/bloodcult_ritual/human_sacrifice/Complete(var/mob/cultist, var/list/extrainfo)
	Reward(500)
	var/datum/role/cultist/C = cultist.mind.GetRole(CULTIST)
	if(!C)
		return  // huh?
	if(!cultist.mind)
		return  // HUH?
	GrantTattoo(cultist, /datum/cult_tattoo/manifest)
	playsound(cultist, 'sound/effects/fervor.ogg', 50, 0, -2)
	anim(target = cultist, a_icon = 'icons/effects/effects.dmi', flick_anim = "rune_fervor", lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE, direction = cultist.dir)
	C.MakeArchCultist()



/datum/bloodcult_ritual/reveal_truth 
	name = "Reveal the Truth"
	desc = "Ensnare victims in the veil by revealing runes next to them."

/datum/bloodcult_ritual/reveal_truth/Complete(var/mob/cultist, var/list/extrainfo)
	var/points = 0
	var/list/shocked = extrainfo["shocked"]
	if(!shocked || shocked.len == 0)
		return
	for(var/mob/living/L in shocked)
		points += 10*(shocked[L])
	if(points > 0)
		Reward(points)
