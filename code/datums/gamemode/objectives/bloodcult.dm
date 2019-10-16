
/datum/objective/bloodcult_reunion
	explanation_text = "The Reunion: Meet up with your fellow cultists, and erect an altar aboard the station."
	name = "Blood Cult: Prologue"
	var/altar_built = FALSE

/datum/objective/bloodcult_reunion/PostAppend()
	message_admins("Blood Cult: A cult dedicated to Nar-Sie has formed aboard the station.")
	log_admin("Blood Cult: A cult dedicated to Nar-Sie has formed aboard the station.")
	return TRUE

/datum/objective/bloodcult_reunion/IsFulfilled()
	if (..())
		return TRUE
	return altar_built

//////////////////////

/datum/objective/bloodcult_followers
	explanation_text = "The Followers: Perform the conversion ritual on X crew members."
	name = "Blood Cult: ACT I"
	var/convert_target = 4
	var/conversions = 0

/datum/objective/bloodcult_followers/PostAppend()
	explanation_text = "The Followers: Perform the conversion ritual on [convert_target] crew members."
	message_admins("Blood Cult: ACT I has begun.")
	log_admin("Blood Cult: ACT I has begun.")
	return TRUE

/datum/objective/bloodcult_followers/extraInfo()
	if (!IsFulfilled())
		explanation_text += " (Only [conversions] conversions were performed)"

/datum/objective/bloodcult_followers/IsFulfilled()
	if (..())
		return TRUE
	return (conversions >= convert_target)

//////////////////////

/datum/objective/bloodcult_sacrifice
	explanation_text = "The Sacrifice: Nar-Sie requires the flesh of X to breach reality. Sacrifice them at an altar using a cult blade."
	name = "Blood Cult: ACT II"
	var/mob/living/sacrifice_target = null
	var/datum/mind/sacrifice_mind = null
	var/target_sacrificed = FALSE
	var/list/failed_targets = list()

/datum/objective/bloodcult_sacrifice/PostAppend()
	sacrifice_target = find_target()
	if (sacrifice_target)
		var/target_role = ""
		if (sacrifice_target.mind)
			sacrifice_mind = sacrifice_target.mind
			target_role = (sacrifice_target.mind.assigned_role=="MODE") ? "" : ", the ([sacrifice_target.mind.assigned_role]),"
		if (iscultist(sacrifice_target))
			target_role = ", the cultist,"
		explanation_text = "The Sacrifice: Nar-Sie requires the flesh of [sacrifice_target.real_name][target_role] to breach reality. Sacrifice them at an altar using a cult blade. If you feel merciful for their soul, you may use an empty soul blade."
		message_admins("Blood Cult: ACT II has begun, the sacrifice target is [sacrifice_target.real_name][target_role].")
		log_admin("Blood Cult: ACT II has begun, the sacrifice target is [sacrifice_target.real_name][target_role].")
		//var/datum/faction/bloodcult/cult = faction
		//cult.target_change = TRUE
		return TRUE
//	else
//		sleep(60 SECONDS)//kind of a failsafe should the entire server cooperate to cause this to occur, but that shouldn't logically ever happen anyway.
//		return PostAppend()

/datum/objective/bloodcult_sacrifice/proc/replace_target(var/mob/M)
	sacrifice_target = find_target()
	if (sacrifice_target)
		var/target_role = ""
		if (sacrifice_target.mind)
			sacrifice_mind = sacrifice_target.mind
			target_role = (sacrifice_target.mind.assigned_role=="MODE") ? "" : ", the ([sacrifice_target.mind.assigned_role]),"
		if (iscultist(sacrifice_target))
			target_role = ", the cultist,"
		explanation_text = "The Sacrifice: Nar-Sie requires the flesh of [sacrifice_target.real_name][target_role] to breach reality. Sacrifice them at an altar using a cult blade. If you feel merciful for their soul, you may use an empty soul blade."
		message_admins("Blood Cult: [M ? "[key_name(M)] has communed with Nar-Sie about a missing sacrifice target. " : ""]A new sacrifice target has been assigned: [sacrifice_target.real_name][target_role].")
		log_admin("Blood Cult: [M ? "[key_name(M)] has communed with Nar-Sie about a missing sacrifice target. " : ""]A new sacrifice target has been assigned: [sacrifice_target.real_name][target_role].")
		//var/datum/faction/bloodcult/cult = faction
		//cult.target_change = TRUE
		return TRUE
	return FALSE
//	else
//		sleep(60 SECONDS)//kind of a failsafe should the entire server cooperate to cause this to occur, but that shouldn't logically ever happen anyway.
//		return replace_target()

/datum/objective/bloodcult_sacrifice/proc/find_target()
	var/list/possible_targets = list()
	var/list/backup_targets = list()
	for(var/mob/living/carbon/human/player in player_list)
		//They may be dead, but we only need their flesh
		var/turf/player_turf = get_turf(player)
		if(player_turf.z != STATION_Z)//We only look for people currently aboard the station
			continue
		var/is_implanted = FALSE
		for(var/obj/item/weapon/implant/loyalty/loyalty_implant in player)
			if(loyalty_implant.implanted)
				is_implanted = TRUE
				break
		if(is_implanted || isReligiousLeader(player) || isantagbanned(player) || jobban_isbanned(player, CULTIST))
			possible_targets += player
		else
			backup_targets += player

	if(possible_targets.len <= 0) // If there are only non-implanted players left on the station, we'll have to sacrifice one of them
		if (backup_targets.len <= 0)
			message_admins("Blood Cult: Could not find a suitable sacrifice target. Trying again in a minute.")
			log_admin("Blood Cult: Could not find a suitable sacrifice target. Trying again in a minute.")
			return null
		else
			return pick(backup_targets)

	return pick(possible_targets - failed_targets)

/datum/objective/bloodcult_sacrifice/IsFulfilled()
	if (..())
		return TRUE
	return target_sacrificed

//////////////////////

/datum/objective/bloodcult_bloodbath
	explanation_text = "The Blood Bath: The blood stones have risen. Spill blood accross the station's floors to fill them up before the crew destroys them all."
	name = "Blood Cult: ACT III"
	var/percent_bloodspill = 4//percent of all the station's simulated floors, you should keep it under 5.
	var/target_bloodspill = 0//actual amount of bloodied floors to reach
	var/max_bloodspill = 0//max amount of bloodied floors simultanously reached

/datum/objective/bloodcult_bloodbath/PostAppend()
	var/floor_count = 0
	for(var/i = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
		for(var/r = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
			var/turf/tile = locate(i, r, map.zMainStation)
			if(tile && istype(tile, /turf/simulated/floor) && !isspace(tile.loc) && !istype(tile.loc, /area/asteroid) && !istype(tile.loc, /area/mine) && !istype(tile.loc, /area/vault) && !istype(tile.loc, /area/prison) && !istype(tile.loc, /area/vox_trading_post))
				floor_count++
	target_bloodspill = round(floor_count * percent_bloodspill / 100)
	target_bloodspill += rand(-20,20)
	explanation_text = "The Blood Bath: The blood stones have risen. Spill blood accross [target_bloodspill] of the station's floors to fill them up before the crew destroys them all."
	message_admins("Blood Cult: ACT III has begun. The cult has to spill blood over [target_bloodspill] floor tiles, out of the station's [floor_count] floor tiles.")
	log_admin("Blood Cult: ACT III has begun. The cult has to spill blood over [target_bloodspill] floor tiles, out of the station's [floor_count] floor tiles.")
	return TRUE

/datum/objective/bloodcult_bloodbath/extraInfo()
	explanation_text += " (Highest bloody floor count reached: [max_bloodspill])"

/datum/objective/bloodcult_bloodbath/IsFulfilled()
	if (..())
		return TRUE
	return (max_bloodspill >= target_bloodspill)

//////////////////////

/datum/objective/bloodcult_tearinreality
	explanation_text = "The Tear in Reality: Chant around the anchor blood stone to stretch the breach enough so Nar-Sie may come through."
	name = "Blood Cult: ACT IV"
	var/obj/structure/cult/bloodstone/anchor = null
	var/NARSIE_HAS_RISEN = FALSE

/datum/objective/bloodcult_tearinreality/PostAppend()
	for (var/obj/structure/cult/bloodstone/B in bloodstone_list)//One of healthiest blood stones will become the anchor.
		if (!anchor || B.health > anchor.health)
			anchor = B
		else if (anchor && B.health == anchor.health)
			anchor = pick(list(B,anchor))
	anchor.health = 1200
	anchor.maxHealth = 1200
	anchor.set_animate()
	var/turf/T = get_turf(anchor)
	var/obj/structure/teleportwarp/TW = new (T)
	TW.icon_state = "rune_seer"
	TW.pixel_y = -60
	anchor.anchor = TRUE
	anchor.timeleft = 60
	anchor.timetotal = anchor.timeleft

	//Adding the anchor to the bloodstones holomap, so cultists can quickly go there to perform the final summoning
	var/icon/updated_map = icon(extraMiniMaps[HOLOMAP_EXTRA_CULTMAP])
	var/datum/holomap_marker/holomarker = new()
	holomarker.id = HOLOMAP_MARKER_BLOODSTONE_ANCHOR
	holomarker.filter = HOLOMAP_FILTER_CULT
	holomarker.x = anchor.x
	holomarker.y = anchor.y
	holomarker.z = anchor.z
	holomap_markers[HOLOMAP_MARKER_BLOODSTONE+"_\ref[anchor]"] = holomarker
	if(holomarker.z == map.zMainStation && holomarker.filter & HOLOMAP_FILTER_CULT)
		if(map.holomap_offset_x.len >= map.zMainStation)
			updated_map.Blend(icon(holomarker.icon,holomarker.id), ICON_OVERLAY, holomarker.x-8+map.holomap_offset_x[map.zMainStation]	, holomarker.y-8+map.holomap_offset_y[map.zMainStation])
		else
			updated_map.Blend(icon(holomarker.icon,holomarker.id), ICON_OVERLAY, holomarker.x-8, holomarker.y-8)
	extraMiniMaps[HOLOMAP_EXTRA_CULTMAP] = updated_map
	for(var/obj/structure/cult/bloodstone/B in bloodstone_list)
		if (B.loc)
			B.holomap_datum.initialize_holomap(B.loc)
		else
			message_admins("Blood Cult: A blood stone was somehow spawned in nullspace. It has been destroyed.")
			log_admin("Blood Cult: A blood stone was somehow spawned in nullspace. It has been destroyed.")
			qdel(B)

	spawn()
		anchor.dance_start()//the dance starts once, and only ends for good when Nar-Sie rises or the anchor is destroyed first.

	message_admins("Blood Cult: ACT IV has begun.")
	log_admin("Blood Cult: ACT IV has begun.")
	return TRUE

/datum/objective/bloodcult_tearinreality/extraInfo()
	if (NARSIE_HAS_RISEN && anchor)
		explanation_text += " (The Anchor Blood Stone had [round((anchor.health/anchor.maxHealth)*100)]% health remaining)"

/datum/objective/bloodcult_tearinreality/IsFulfilled()
	if (..())
		return TRUE
	return NARSIE_HAS_RISEN

//////////////////////

/datum/objective/bloodcult_feast
	explanation_text = "The Feast: This is your victory, you may take part in the celebrations of a work well done."
	name = "Blood Cult: Epilogue"
	var/timer = 200 SECONDS

/datum/objective/bloodcult_feast/PostAppend()
	message_admins("Blood Cult: The cult has won.")
	log_admin("Blood Cult: The cult has won.")
	spawn (timer)
		var/datum/faction/bloodcult/cult = faction
		cult.cult_win = TRUE
	return TRUE

/datum/objective/bloodcult_feast/IsFulfilled()
	return TRUE//might expand on that later after release, if I ever get to implement my rework of post-NarSie.
