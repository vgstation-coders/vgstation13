
/*
"Rituals" in this context are basically objectives that cultists can accomplish to get rewarded with devotion.
Devotion both serves to unlock some cult powers, quicken the arrival of the Eclipse, and overall bragging rights on the scoreboard.
In essence, these provide cultists with things to work toward to disrupt the crew without necessarily ending the round.
*/

var/list/bloodcult_faction_rituals = list(
	/datum/bloodcult_ritual/reach_cap,
	/datum/bloodcult_ritual/convert_station,
	/datum/bloodcult_ritual/produce_constructs,
	/datum/bloodcult_ritual/blind_cameras_multi,
	/datum/bloodcult_ritual/bloodspill,
	/datum/bloodcult_ritual/sacrifice_captain,
	/datum/bloodcult_ritual/cursed_infection,
	)

var/list/bloodcult_personal_rituals = list(
	/datum/bloodcult_ritual/blind_cameras,
	/datum/bloodcult_ritual/confuse_crew,
	/datum/bloodcult_ritual/harm_crew,
	/datum/bloodcult_ritual/sacrifice_mouse,
	/datum/bloodcult_ritual/sacrifice_monkey,
	/datum/bloodcult_ritual/altar/simple,
	/datum/bloodcult_ritual/altar/elaborate,
	/datum/bloodcult_ritual/altar/excentric,
	/datum/bloodcult_ritual/altar/unholy,
	/datum/bloodcult_ritual/suicide_tome,
	/datum/bloodcult_ritual/suicide_soulblade,
	)

/datum/bloodcult_ritual
	var/name = "Ritual"
	var/desc = "Lorem Ipsum (you shouldn't be reading this!)"

	var/only_once = FALSE //If TRUE the ritual won't return to the pool of possible rituals after completion
	var/ritual_type = "error"//ritual category. the game tries to assign rituals of diverse categories
	var/difficulty = "easy"//"medium", "hard"
	var/personal = FALSE//FALSE = Faction ritual. TRUE = Personal ritual
	var/datum/role/cultist/owner = null//Only really matters if ritual is personal but you can also assign it on key_found on faction ritual to give them extra devotion
	var/reward_achiever = 0//Reward to the cultist who completed the achievement
	var/reward_faction = 0//Reward to every member of the faction

	var/list/keys = list()

//Needs to be TRUE for the Ritual to be assigned
/datum/bloodcult_ritual/proc/pre_conditions(var/datum/role/cultist/potential)
	if (potential)
		owner = potential
	return TRUE

//Perform custom ritual setup here
/datum/bloodcult_ritual/proc/init_ritual()

//Called when a cultist is about to hover the corresponding ritual UI button
/datum/bloodcult_ritual/proc/update_desc()
	return

//Perform custom ritual validation checks here
/datum/bloodcult_ritual/proc/key_found(var/extra)
	return TRUE

/datum/bloodcult_ritual/proc/complete()
	owner?.gain_devotion(reward_achiever, DEVOTION_TIER_4)//no key, duh
	if (reward_faction)
		var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
		for(var/datum/role/cultist/C in cult.members)
			C.gain_devotion(reward_faction, DEVOTION_TIER_4)//yes this means a larger cult gets more total devotion.

	if (personal)
		message_admins("BLOODCULT: [key_name(owner.antag.current)] has completed the [name] ritual.")
		log_admin("BLOODCULT: [key_name(owner.antag.current)] has completed the [name] ritual.")
	else
		message_admins("BLOODCULT: The [name] ritual has been completed.")
		log_admin("BLOODCULT: The [name] ritual has been completed.")

////////////////////////////////////////////////////////////////////
//																  //
//						FACTION RITUALS							  //
//																  //
////////////////////////////////////////////////////////////////////

////////////////////////CONVERSION/////////////////////////////

/datum/bloodcult_ritual/reach_cap
	name = "Reach the cap"
	desc = "the cult must grow...<br>until it cannot..."

	only_once = TRUE
	ritual_type = "conversion"
	difficulty = "medium"
	reward_faction = 400

	keys = list(
		"conversion",
		"converted_prisoner",
		"soulstone",
		"soulstone_prisoner",
		)

/datum/bloodcult_ritual/reach_cap/pre_conditions(var/datum/role/cultist/potential)
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (cult.CanConvert())
		return TRUE
	return FALSE

/datum/bloodcult_ritual/reach_cap/key_found(var/extra)
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (!cult.CanConvert())
		return TRUE
	return FALSE

////////////////////////CONSTRUCT/////////////////////////////

/datum/bloodcult_ritual/convert_station
	name = "Cultify the Station"
	desc = "convert the floors...<br>convert the walls..."

	ritual_type = "constructs"
	difficulty = "easy"
	reward_faction = 200

	keys = list(
		"convert_floor",
		"convert_wall",
		)

	var/target = 30
	var/list/turfs = list()

/datum/bloodcult_ritual/convert_station/init_ritual()
	turfs = list()

/datum/bloodcult_ritual/convert_station/update_desc()
	desc = "convert the floors...<br>convert the walls...<br>need [target - turfs.len] more..."

/datum/bloodcult_ritual/convert_station/key_found(var/turf/T)
	if (T in turfs)
		return FALSE
	turfs += T
	if(turfs.len >= target)
		return TRUE
	return FALSE


///////////////////////////////////////////////////////////////

/datum/bloodcult_ritual/produce_constructs
	name = "One of each"
	desc = "artificer...<br>wraith...<br>juggernaut..."

	ritual_type = "constructs"
	difficulty = "medium"
	reward_faction = 300

	keys = list("build_construct")

	var/list/types_to_build = list("Artificer", "Wraith", "Juggernaut")

/datum/bloodcult_ritual/produce_constructs/init_ritual()
	types_to_build = list("Artificer", "Wraith", "Juggernaut")

/datum/bloodcult_ritual/produce_constructs/key_found(var/extra)
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	for (var/datum/role/R in cult.members)
		var/mob/M = R.antag.current
		if (istype(M, /mob/living/simple_animal/construct))
			var/mob/living/simple_animal/construct/C = M
			types_to_build -= C.construct_type
	if (types_to_build.len <= 0)
		return TRUE
	return FALSE

////////////////////////CONFUSION/////////////////////////////

/datum/bloodcult_ritual/blind_cameras_multi
	name = "Blind Many Cameras"
	desc = "confusion runes and talismans...<br>darken their lenses..."

	ritual_type = "confusion"
	difficulty = "easy"
	reward_faction = 200

	keys = list("confusion_camera")

	var/target_cameras = 20

/datum/bloodcult_ritual/blind_cameras_multi/init_ritual()
	target_cameras = 20

/datum/bloodcult_ritual/blind_cameras_multi/update_desc()
	desc = "confusion runes and talismans...<br>darken their lenses...<br>[target_cameras] to go..."

/datum/bloodcult_ritual/blind_cameras_multi/key_found(var/extra)
	target_cameras--
	if(target_cameras <= 0)
		return TRUE
	return FALSE

////////////////////////BLOODSPILL/////////////////////////////

/datum/bloodcult_ritual/bloodspill
	name = "Spill Blood"
	desc = "more blood...need more...<br>on the floors...on the walls..."

	only_once = TRUE
	ritual_type = "bloodspill"
	difficulty = "hard"
	reward_achiever = 0
	reward_faction = 500

	keys = list("bloodspill")

	var/percent_bloodspill = 4//percent of all the station's simulated floors, you should keep it under 5.
	var/target_bloodspill = 1000//actual amount of bloodied floors to reach
	var/max_bloodspill = 0//max amount of bloodied floors simultanously reached

/datum/bloodcult_ritual/bloodspill/init_ritual()
	var/floor_count = 0
	for(var/i = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
		for(var/r = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
			var/turf/tile = locate(i, r, map.zMainStation)
			if(tile && istype(tile, /turf/simulated/floor) && !isspace(tile.loc) && !istype(tile.loc, /area/asteroid) && !istype(tile.loc, /area/mine) && !istype(tile.loc, /area/vault) && !istype(tile.loc, /area/prison) && !istype(tile.loc, /area/vox_trading_post))
				floor_count++
	target_bloodspill = round(floor_count * percent_bloodspill / 100)
	target_bloodspill += rand(-20,20)

	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	cult.bloodspill_ritual = src

/datum/bloodcult_ritual/bloodspill/update_desc()
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	desc = "more blood...need more...<br>on the floors...on the walls...<br>at least [target_bloodspill - cult.bloody_floors.len] more..."

/datum/bloodcult_ritual/bloodspill/key_found(var/extra)
	if(extra > max_bloodspill)
		max_bloodspill = extra
	if(max_bloodspill >= target_bloodspill)
		return TRUE
	return FALSE

/datum/bloodcult_ritual/bloodspill/complete()
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	cult.bloodspill_ritual = null
	..()


////////////////////////SACRIFICE/////////////////////////////

/datum/bloodcult_ritual/sacrifice_captain
	name = "Sacrifice Captain"
	desc = "a simian...<br>an altar...<br>and a proper blade..."

	only_once = TRUE
	ritual_type = "sacrifice"
	difficulty = "hard"
	reward_faction = 500

	keys = list("altar_sacrifice_human")

/datum/bloodcult_ritual/sacrifice_captain/pre_conditions(var/datum/role/cultist/potential)
	if (potential)
		owner = potential
	for(var/mob/M in player_list)
		if(M.mind && M.mind.assigned_role == "Captain")
			return TRUE
	return FALSE

/datum/bloodcult_ritual/sacrifice_captain/key_found(var/mob/living/O)
	if (istype(O) && O.mind && O.mind.assigned_role == "Captain")
		return TRUE
	return FALSE

////////////////////////INFECTION/////////////////////////////

/datum/bloodcult_ritual/cursed_infection
	name = "Cursed Blood"
	desc = "from a tempting goblet...<br>pours a wicked drink..."

	ritual_type = "infection"
	difficulty = "medium"
	reward_faction = 300

	keys = list("cursed_infection")

	var/targets = 5
	var/list/infected_targets = list()

/datum/bloodcult_ritual/cursed_infection/init_ritual()
	infected_targets = list()

/datum/bloodcult_ritual/cursed_infection/update_desc()
	desc = "from a tempting goblet...<br>pours a wicked drink...<br>have at least [targets - infected_targets.len] more individuals consume it..."

/datum/bloodcult_ritual/cursed_infection/key_found(var/mob/living/L)
	if (!L.mind)
		return FALSE
	if (iscultist(L))
		return FALSE
	if (L.mind in infected_targets)
		return FALSE
	infected_targets += L.mind
	if(infected_targets.len >= targets)
		return TRUE
	return FALSE


////////////////////////////////////////////////////////////////////
//																  //
//						PERSONAL RITUALS						  //
//																  //
////////////////////////////////////////////////////////////////////

////////////////////////CONFUSION/////////////////////////////

/datum/bloodcult_ritual/blind_cameras
	name = "Blind Cameras"
	desc = "confusion runes and talismans...<br>darken their lenses..."

	ritual_type = "confusion"
	difficulty = "easy"
	personal = TRUE
	reward_achiever = 200
	reward_faction = 2

	keys = list("confusion_camera")

	var/target_cameras = 3

/datum/bloodcult_ritual/blind_cameras/init_ritual()
	target_cameras = 3

//Called when a cultist is about to hover the corresponding ritual UI button
/datum/bloodcult_ritual/blind_cameras/update_desc()
	desc = "confusion runes and talismans...<br>darken their lenses...<br>[target_cameras] to go..."

/datum/bloodcult_ritual/blind_cameras/key_found(var/extra)
	target_cameras--
	if(target_cameras <= 0)
		return TRUE
	return FALSE

////////////////////////////////////////////////////////////////

/datum/bloodcult_ritual/confuse_crew
	name = "Confuse Crew"
	desc = "confusion runes and talismans...<br>bring their nightmares to life..."

	ritual_type = "confusion"
	difficulty = "medium"
	personal = TRUE
	reward_achiever = 200
	reward_faction = 2

	keys = list(
		"confusion_carbon",
		"confusion_papered",
		)

/datum/bloodcult_ritual/confuse_crew/key_found(var/mob/living/extra)
	if (!extra.client)
		return FALSE
	return TRUE

////////////////////////HARM CREW MEMBERS/////////////////////////////

/datum/bloodcult_ritual/harm_crew
	name = "Harm Crew"
	desc = "wield cult weaponry...<br>spill their blood...<br>sear their skin..."

	ritual_type = "harm"
	difficulty = "medium"
	personal = TRUE
	reward_achiever = 200
	reward_faction = 2

	keys = list(
		"attack_tome",
		"attack_cultblade",
		"attack_blooddagger",
		"attack_construct",
		"attack_shade",
		"attack_ritualknife",
		)

	var/targets = 3
	var/list/hit_targets = list()

/datum/bloodcult_ritual/harm_crew/init_ritual()
	hit_targets = list()

/datum/bloodcult_ritual/harm_crew/update_desc()
	desc = "wield cult weaponry...<br>spill their blood...<br>sear their skin...<br>at least [targets - hit_targets.len] different individuals..."

/datum/bloodcult_ritual/harm_crew/key_found(var/mob/living/L)
	if (iscultist(L))
		return FALSE
	if (L.mind in hit_targets)
		return FALSE
	hit_targets += L.mind
	if(hit_targets.len >= targets)
		return TRUE
	return FALSE

////////////////////////SACRIFICE/////////////////////////////

/datum/bloodcult_ritual/sacrifice_mouse
	name = "Sacrifice Mouse"
	desc = "a rodent...<br>an altar...<br>and a proper blade..."

	ritual_type = "sacrifice"
	difficulty = "easy"
	personal = TRUE
	reward_achiever = 200
	reward_faction = 2

	keys = list("altar_sacrifice_animal")

/datum/bloodcult_ritual/sacrifice_mouse/key_found(var/mob/living/simple_animal/mouse/extra)
	if(istype(extra))
		return TRUE
	return FALSE


//////////////////////////////////////////////////////////////

/datum/bloodcult_ritual/sacrifice_monkey
	name = "Sacrifice Monkey"
	desc = "a simian...<br>an altar...<br>and a proper blade..."

	ritual_type = "sacrifice"
	difficulty = "easy"
	personal = TRUE
	reward_achiever = 200
	reward_faction = 2

	keys = list("altar_sacrifice_monkey")

/datum/bloodcult_ritual/sacrifice_monkey/key_found(var/extra)
	return TRUE


////////////////////////ALTAR/////////////////////////////////

/datum/bloodcult_ritual/altar
	name = "Prepare Altar"
	desc = "raise an altar...<br>add proper paraphernalia around...<br>then plant a ritual knife on top..."

	ritual_type = "altar"
	difficulty = "easy"
	personal = TRUE
	reward_achiever = 200
	reward_faction = 2

	var/required_candles = 0
	var/required_tomes = 0
	var/required_runes = 0
	var/required_pylons = 0
	var/required_animal = 0
	var/required_humanoid = 0
	var/required_cultblade = 0

	keys = list("altar_plant")

/datum/bloodcult_ritual/altar/key_found(var/obj/structure/cult/altar/altar)
	var/mob/user = owner.antag.current

	var/valid = TRUE
	var/found_candles = 0
	for (var/obj/item/candle/blood/CB in range(1, altar))
		if (CB.lit)
			found_candles++
	if (found_candles < required_candles)
		to_chat(user, "<span class='sinister'>Need more lit blood candles...</span>")
		valid = FALSE

	var/found_tomes = 0
	for (var/obj/item/weapon/tome/T in range(1, altar))
		found_tomes++
	if (found_tomes < required_tomes)
		to_chat(user, "<span class='sinister'>Need more arcane tomes...</span>")
		valid = FALSE

	var/found_runes = 0
	for (var/obj/effect/rune/R in range(1, altar))
		found_runes++
	if (found_runes < required_runes)
		to_chat(user, "<span class='sinister'>Need more runes...</span>")
		valid = FALSE

	var/found_pylons = 0
	for (var/obj/structure/cult/pylon/P in range(1, altar))
		found_pylons++
	if (found_pylons < required_pylons)
		to_chat(user, "<span class='sinister'>You must construct additional pylons...</span>")
		valid = FALSE

	var/found_animal = FALSE
	var/found_humanoid = FALSE
	if(altar.is_locking(altar.lock_type))
		var/mob/M = altar.get_locked(altar.lock_type)[1]
		if (ishuman(M))
			found_humanoid = TRUE
		if (ismonkey(M) || isanimal(M))
			found_animal = TRUE
	if (required_animal && !found_animal)
		to_chat(user, "<span class='sinister'>You must impale an animal on top...</span>")
		valid = FALSE
	if (required_humanoid && !found_humanoid)
		to_chat(user, "<span class='sinister'>You must impale an humanoid on top...</span>")
		valid = FALSE

	var/obj/item/weapon/melee/B = altar.blade
	if (required_cultblade && !istype(B))
		to_chat(user, "<span class='sinister'>Lastly, a mere ritual knife won't do here. Forge a better implement...</span>")

	return valid

/datum/bloodcult_ritual/altar/simple
	name = "Prepare Simple Altar"
	desc = "raise an altar...<br>add some lit blood candles around...<br>then plant a ritual knife on top..."

	difficulty = "easy"
	reward_achiever = 200
	reward_faction = 2

	required_candles = 4
	required_tomes = 0
	required_runes = 0
	required_pylons = 0
	required_animal = 0
	required_humanoid = 0
	required_cultblade = 0

/datum/bloodcult_ritual/altar/elaborate
	name = "Prepare Elaborate Altar"
	desc = "raise an altar...<br>add proper paraphernalia around...<br>then plant a ritual knife on top..."

	difficulty = "easy"
	reward_achiever = 200
	reward_faction = 2

	required_candles = 4
	required_tomes = 1
	required_runes = 4
	required_pylons = 0
	required_animal = 0
	required_humanoid = 0
	required_cultblade = 0

/datum/bloodcult_ritual/altar/excentric
	name = "Prepare Excentric Altar"
	desc = "raise an altar...<br>add proper paraphernalia around...<br>lay an animal on top...<br>then plant a ritual knife into it..."

	difficulty = "medium"
	reward_achiever = 400
	reward_faction = 4

	required_candles = 4
	required_tomes = 0
	required_runes = 4
	required_pylons = 0
	required_animal = 1
	required_humanoid = 0
	required_cultblade = 0

/datum/bloodcult_ritual/altar/unholy
	name = "Prepare Unholy Altar"
	desc = "raise an altar...<br>add proper paraphernalia around...<br>lay a humanoid on top...<br>then plant a cult blade into them..."

	difficulty = "hard"
	reward_achiever = 600
	reward_faction = 6

	required_candles = 2
	required_tomes = 1
	required_runes = 3
	required_pylons = 2
	required_animal = 0
	required_humanoid = 1
	required_cultblade = 1

////////////////////////SUICIDE/////////////////////////////

/datum/bloodcult_ritual/suicide_tome
	name = "An Ending"
	desc = "grab a tome...<br>then think of an ending...<br>preferably one with many witnesses..."

	only_once = TRUE
	ritual_type = "suicide"
	difficulty = "hard"
	personal = TRUE
	reward_achiever = 500
	reward_faction = 100

	keys = list("suicide_tome")

/datum/bloodcult_ritual/suicide_tome/pre_conditions(var/datum/role/cultist/potential)
	if (potential)
		owner = potential
	if (potential.devotion > DEVOTION_TIER_4)
		return TRUE
	return FALSE

/datum/bloodcult_ritual/suicide_tome/key_found(var/mob/living/extra)
	for(var/mob/M in dview(world.view, get_turf(extra), INVISIBILITY_MAXIMUM))
		if (!M.client)
			continue
		if (isobserver(M))
			reward_achiever += 50
			reward_faction += 10
		else if (iscultist(M))
			reward_achiever += 100
			reward_faction += 20
		else
			reward_achiever += 200
			reward_faction += 40
	return TRUE

///////////////////////////////////////////////////////////////////////////

/datum/bloodcult_ritual/suicide_soulblade
	name = "Soul Blade"
	desc = "Become the bone of your own sword..."

	only_once = TRUE
	ritual_type = "suicide"
	difficulty = "hard"
	personal = TRUE
	reward_achiever = 500
	reward_faction = 100

	keys = list("suicide_tome")

/datum/bloodcult_ritual/suicide_soulblade/pre_conditions(var/datum/role/cultist/potential)
	if (potential)
		owner = potential
	if (potential.devotion > DEVOTION_TIER_3)
		return TRUE
	return FALSE

/datum/bloodcult_ritual/suicide_soulblade/key_found(var/mob/living/extra)
	for(var/mob/M in dview(world.view, get_turf(extra), INVISIBILITY_MAXIMUM))
		if (!M.client)
			continue
		if (isobserver(M))
			reward_achiever += 25
			reward_faction += 5
		else if (iscultist(M))
			reward_achiever += 50
			reward_faction += 10
		else
			reward_achiever += 100
			reward_faction += 20
	return TRUE
