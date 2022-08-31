///////////////////////////////////
//            CULT RITUALS
// 
// 	Flow Overview: 
//      TriggerCultRitual Global Proc =>
//			Trigger() Ritual Proc => Check For Completion
//				Reward() Ritual Proc =>
//					Finish() => Ritual Proc
//
//
//
//		Procs to override:
//		Trigger()  -  Called every time a ritual should be checked for completion
//		extraInfo() - Returns text to be added to objective description on roundend screen
//
// 
///////////////////////////////////

var/global/veil_weakness = 0	            // how weak the veil of reality is. as cultists perform rituals, this increases
var/global/list/unlocked_rituals = list()		// Rituals that the cult can perform, and have yet to do so.
var/global/list/completed_rituals = list()	// Rituals that the cult has completed, and can no longer perform.
var/global/list/locked_rituals = list()		// Rituals that the cult hasn't unlocked yet.
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

/proc/TriggerCultRitual(var/ritualtype, var/mob/cultist, var/list/extrainfo )
	var/datum/bloodcult_ritual/R = locate(ritualtype) in unlocked_rituals
	if(R)
		R.Trigger(cultist, extrainfo)


/datum/faction/bloodcult/proc/GetVeilWeakness()
	return veil_weakness

/datum/faction/bloodcult/proc/GetUnlockedRituals()
	return unlocked_rituals

/datum/faction/bloodcult/proc/GetCultAltars()
	return cult_altars

/datum/faction/bloodcult/proc/initialize_rituals()
	for(var/type in (subtypesof(/datum/bloodcult_ritual) - typesof(/datum/bloodcult_ritual/always_active)))
		locked_rituals += new type
	for(var/i = 1 to 3)
		UnlockRandomRitual()
	for(var/type in subtypesof(/datum/bloodcult_ritual/always_active))
		new type

/datum/faction/bloodcult/proc/UnlockRandomRitual(var/announce)
	if(locked_rituals.len > 0)
		var/datum/bloodcult_ritual/R = pick(locked_rituals)
		R.Unlock(announce)
		return R
	else 
		for(var/datum/role/cultist/C in members)
			to_chat(C.antag.current, "<span class='sinister'>The veil of reality is close to shattering... there are no more rituals to complete.</span>")
		return null


/datum/faction/bloodcult/proc/update_cultist_uis()
	for(var/datum/role/cultist/C in members)
		C.update_cult_hud()


///////////////////////////////////////////


/datum/bloodcult_ritual
	var/name = "Cult Ritual"        
	var/desc = ""
	var/point_limit = 0       // The ritual will stop working after this many points. 0 = infinite
	var/only_once = 0		  // Can only be completed once.
	var/total_points_rewarded = 0
	var/datum/objective/bloodcult_ritual/jectie = null
	var/datum/faction/bloodcult/cult = null 	// Quick reference

	// Flavor
	var/list/completion_text_minor = list(
		"<span class='sinister'>You sense reality shifting around you slightly.</span>",
		"<span class='sinister'>You feel occult energies beginning to chip away at the veil.</span>",
		"<span class='danger'>Nar-Sie</span> murmurs... <span class='sinister'>One step closer to our goal...</span>"
	)

	var/list/completion_text_major = list(
		"<span class='sinister'>The walls twist and turn around you as reality begins to collapse.</span>",
		"<span class='danger'>Nar-Sie</span> murmurs... <span class='sinister'>Remarkable... for a mortal.</span>"
	)

/datum/bloodcult_ritual/New()
	..()
	cult = locate(/datum/faction/bloodcult) in ticker.mode.factions
	if(!cult)
		message_admins("An initialized cult ritual failed to find the bloodcult faction. This shouldn't appear; expect problems.")

/datum/bloodcult_ritual/always_active/New()
	..()
	Unlock()

/datum/bloodcult_ritual/always_active/Unlock()
	unlocked_rituals += src
	locked_rituals -= src

/datum/bloodcult_ritual/proc/Finish(var/worth)
	if(!jectie.complete)
		jectie.complete = TRUE
		for(var/datum/role/cultist/C in cult.members)
			var/completion_text = worth >= 50 ? pick(completion_text_major) : pick(completion_text_minor)
			to_chat(C.antag.current, completion_text)
		cult.UnlockRandomRitual(TRUE)

	if(only_once)
		unlocked_rituals -= src
		completed_rituals += src

/datum/bloodcult_ritual/proc/Trigger()
	return

/datum/bloodcult_ritual/proc/Unlock(var/announce)
	unlocked_rituals += src
	locked_rituals -= src
	jectie = new(src)
	if(announce)
		for(var/datum/role/cultist/C in cult.members)
			to_chat(C.antag.current, "<b>New Objective: </b>[desc]")
	cult.AppendObjective(jectie, 1)

/datum/bloodcult_ritual/proc/extraInfo()
	return ""

/datum/bloodcult_ritual/proc/Reward(var/worth)
	if(point_limit == 0 || (total_points_rewarded + worth <= point_limit))
		total_points_rewarded += worth
		ChangeVeilWeakness(worth)

	Finish(worth)

/datum/bloodcult_ritual/always_active/Reward(var/worth)
	if(point_limit == 0 || (total_points_rewarded + worth <= point_limit))
		total_points_rewarded += worth
		ChangeVeilWeakness(worth)

/datum/bloodcult_ritual/proc/GrantTattoo(var/mob/cultist, var/type)
	if(!ishuman(cultist))
		return
	if(cultist.mind)
		var/datum/role/cultist/C = cultist.mind.GetRole(CULTIST)
		if(!C)
			return
		C.GiveTattoo(type)

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
		else
			awardedpoints = 5
	return awardedpoints * multiplier

///////////////////////////////////

/datum/bloodcult_ritual/always_active/draw_rune
	name = "Draw Rune"
	desc = "Draw a rune."
	point_limit = 100

/datum/bloodcult_ritual/always_active/draw_rune/Trigger(var/mob/cultist, var/list/extrainfo)
	var/erased = extrainfo["erased"]
	erased ? Reward(-1) : Reward(1)


//////////////////////

/datum/bloodcult_ritual/sow_confusion
	name = "Sow Confusion"
	desc = "Corrupt the minds of the unenlightened. Curse at least two people with a single confusion rune."

/datum/bloodcult_ritual/sow_confusion/Trigger(var/mob/cultist, var/list/extrainfo)
	var/people = extrainfo["victimcount"]
	if(people > 1)
		Reward(people * 10)
	

/datum/bloodcult_ritual/animal_sacrifice
	name = "Sacrifice Animal"
	desc = "The Geometer demands blood. Sacrifice an animal at an altar."
	
/datum/bloodcult_ritual/animal_sacrifice/Trigger(var/mob/cultist, var/list/extrainfo)
	var/mobtype = extrainfo["mobtype"]
	var/points = GetMobValue(mobtype,4)
	Reward(points)
	if(points >= 20)
		GrantTattoo(cultist, /datum/cult_tattoo/dagger)
	else
		var/datum/role/cultist/C = cultist.mind.GetRole(CULTIST)
		if(!locate(/datum/cult_tattoo/dagger) in C.tattoos)
			to_chat(cultist, "<span class='warning'>Sacrifice something more valuable to earn your tattoo.</span>")

/datum/bloodcult_ritual/spirited_away
	name = "Spirited Away"
	desc = "Show a nonbeliever life beyond this world. Send them on a trip through a path rune."
	var/list/previous_victims = list()

/datum/bloodcult_ritual/spirited_away/Trigger(var/mob/cultist, var/list/extrainfo)
	var/list/victims = extrainfo["victims"]
	for(var/mob/V in victims)
		if((V in previous_victims) || !V.mind)
			victims -= V
	previous_victims += victims
	if(victims.len > 0)
		Reward(25 * victims.len)
		GrantTattoo(cultist, /datum/cult_tattoo/shortcut)

/datum/bloodcult_ritual/human_sacrifice
	name = "Sacrifice Human"
	desc = "The Geometer demands a meal. Sacrifice a human at an altar with the help of another cultist."
	only_once = TRUE
	var/accept_anyone = FALSE

/datum/bloodcult_ritual/human_sacrifice/New()
	..()
	if(cult.FindSacrificeTarget())
		desc = "The Geometer demands a meal. Sacrifice the flesh of [cult.sacrifice_target][cult.sacrifice_target?.mind?.assigned_role ? ", the [cult.sacrifice_target.mind.assigned_role]," : ""] at an altar with the help of another cultist."
	else
		accept_anyone = TRUE

/datum/bloodcult_ritual/human_sacrifice/Trigger(var/mob/cultist, var/list/extrainfo)
	var/mob/living/carbon/human/victim = extrainfo["victim"]
	if(accept_anyone || (cult.sacrifice_target == victim))	// No target? Oh well, just accept anybody.
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
	desc = "Reveal the truth to the nonbelievers. Reveal hidden runes to nonbelievers and ensnare them in occult energy."

/datum/bloodcult_ritual/reveal_truth/Trigger(var/mob/cultist, var/list/extrainfo)
	var/points = 0
	var/list/shocked = extrainfo["shocked"]
	if(!shocked || shocked.len == 0)
		return
	for(var/mob/living/L in shocked)
		points += 10*(shocked[L])
	if(points > 0)
		Reward(points)

/datum/bloodcult_ritual/silence_lambs
	name = "Silence the Lambs"
	desc = "Silence heretics aboard the station. Use a deaf/mute rune on at least two nonbelievers."

/datum/bloodcult_ritual/silence_lambs/Trigger(var/mob/cultist, var/list/extrainfo)
	var/people = extrainfo["victimcount"]
	if(people > 1)
		Reward(people * 10)
		GrantTattoo(cultist, /datum/cult_tattoo/silent)
	
/datum/bloodcult_ritual/curse_blood
	name = "Spread the Gift"
	desc = "Spread our gift amongst the crew. Create cursed blood by pouring it into a goblet, then have at least 3 nonbelievers ingest that blood."
	point_limit = 100
	var/list/infected = list()

/datum/bloodcult_ritual/curse_blood/Trigger(var/list/extrainfo)
	var/mob/living/victim = extrainfo["victim"]
	if(!victim || !victim.mind || (victim in infected))
		return
	infected += victim

	if(infected.len == 3)
		Reward(100)
		for(var/datum/role/cultist/C in cult.members)
			GrantTattoo(C.antag.current, /datum/cult_tattoo/bloodpool)

/datum/bloodcult_ritual/conversion
	name = "Blood Missionary"
	desc = "Spread our message amongst the crew. Convert a crewmember and have them join our cause."
	var/list/converted = list()

// Only succeeds if the conversion was successful! 
// Be careful about reaching the cult capacity before unlocking this ritual.
// Only works on people who haven't been converted before.
// (Might make it so the ritual is completed if conversion fails ONLY due to cult capacity)
/datum/bloodcult_ritual/conversion/Trigger(var/mob/living/cultist, var/list/extrainfo)
	var/mob/living/victim = extrainfo["victim"]
	if(victim && !(victim in converted))
		converted += victim
		Reward(200)
		GrantTattoo(cultist, /datum/cult_tattoo/rune_store)


/datum/bloodcult_ritual/build_construct
	name = "Forge Construct"
	desc = "Create the perfect servant. Use a captive soul to create a construct."

/datum/bloodcult_ritual/build_construct/Trigger(var/list/extrainfo)
	var/perfect = extrainfo["perfect"]
	perfect ? Reward(150) : Reward(75)


/datum/bloodcult_ritual/spill_blood
	name = "Spill Blood"
	desc = "Prepare this station for the Geometer's arrival. Spill blood across the station's floors."
	only_once = TRUE
	var/percent_bloodspill = 4//percent of all the station's simulated floors, you should keep it under 5.
	var/target_bloodspill = 0//actual amount of bloodied floors to reach
	var/max_bloodspill = 0//max amount of bloodied floors simultanously reached

/datum/bloodcult_ritual/spill_blood/New()
	..()
	var/floor_count = 0
	for(var/i = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
		for(var/r = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
			var/turf/tile = locate(i, r, map.zMainStation)
			if(tile && istype(tile, /turf/simulated/floor) && !isspace(tile.loc) && !istype(tile.loc, /area/asteroid) && !istype(tile.loc, /area/mine) && !istype(tile.loc, /area/vault) && !istype(tile.loc, /area/prison) && !istype(tile.loc, /area/vox_trading_post))
				floor_count++
	target_bloodspill = round(floor_count * percent_bloodspill / 100)
	target_bloodspill += rand(-20,20)
	desc = "Prepare this station for the Geometer's arrival. Spill blood across [target_bloodspill] of the station's floors."

/datum/bloodcult_ritual/spill_blood/extraInfo()
	return " (Highest bloody floor count reached: [max_bloodspill])"

/datum/bloodcult_ritual/spill_blood/Trigger()
	var/count = cult.bloody_floors.len 
	if(count > max_bloodspill)
		max_bloodspill = count
	if(max_bloodspill >= target_bloodspill)
		Reward(500)
