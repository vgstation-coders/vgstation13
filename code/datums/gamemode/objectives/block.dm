/datum/objective/block
	explanation_text = "Do not allow any organic lifeforms to escape on the shuttle alive."
	name = "Block the shuttle"

/datum/objective/block/IsFulfilled()
	if (..())
		return TRUE
	if(!istype(owner.current, /mob/living/silicon))
		return FALSE
	if(emergency_shuttle.location != CENTCOMM_Z)
		return FALSE
	if(!owner.current)
		return FALSE
	var/area/shuttle = locate(/area/shuttle/escape/centcom)
	var/protected_mobs[] = list(/mob/living/silicon/ai, /mob/living/silicon/pai, /mob/living/silicon/robot, /mob/living/silicon/robot/mommi, /mob/living/simple_animal/borer)
	for(var/mob/living/player in player_list)
		if(player.type in protected_mobs)
			continue
		if (player.mind)
			if (player.stat != DEAD)
				if (get_turf(player) in shuttle)
					return FALSE
	return TRUE
