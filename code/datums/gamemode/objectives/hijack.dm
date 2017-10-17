/datum/objective/hijack
	explanation_text = "Hijack the emergency shuttle by escaping without any organic life-forms other than yourself."

/datum/objective/hijack/IsFulfilled()
	..()
	if(!owner.current || owner.current.stat)
		return FALSE
	if(emergency_shuttle.location != CENTCOMM_Z)
		return FALSE
	if(issilicon(owner.current))
		return FALSE
	var/area/shuttle = locate(/area/shuttle/escape/centcom)
	var/list/protected_mobs = list(/mob/living/silicon/ai, /mob/living/silicon/pai, /mob/living/simple_animal/borer)
	// Implemented in response to 21/12/2013 player vote,  .
	// Comment this if you want Borgs and MoMMIs counted.
	// TODO: Check if borgs are subverted. Best I can think of is a fuzzy check for strings used in syndie laws. BYOND can't do regex, sadly. - N3X
	protected_mobs += list(/mob/living/silicon/robot, /mob/living/silicon/robot/mommi)
	for(var/mob/living/player in player_list)
		if(player.type in protected_mobs)
			continue
		if (player.mind && (player.mind != owner))
			if(!player.isDead())			//they're not dead!
				if(get_turf(player) in shuttle)
					return FALSE
	return TRUE
