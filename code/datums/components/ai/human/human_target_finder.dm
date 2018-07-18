/datum/component/ai/target_finder/human
	range = 7
	var/datum/component/ai/human_brain/brain

/datum/component/ai/target_finder/human/GetTargets()
	ASSERT(parent!=null)
	if(!brain)
		brain = parent.GetComponent(/datum/component/ai/human_brain)
	var/list/o = list()
	for(var/mob/M in view(range, parent))
		if(is_type_in_list(M, exclude_types))
			continue
		if(M.isUnconscious())
			continue
		if((M in brain.enemies) || (M.faction && M.faction in brain.enemy_factions) || (M.type in brain.enemy_types))
			o += M
		else if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species && H.species.name in brain.enemy_species)
				o += M
	return o

/datum/component/ai/target_finder/human/Initialize()
	..()
	RegisterSignal(parent, COMSIG_ATTACKEDBY, .proc/on_attackedby)

/datum/component/ai/target_finder/human/proc/on_attackedby(var/mob/assailant, var/damage_done)
	if(damage_done > 15) //Intent to kill!
		brain.friends.Remove(assailant)
	if(damage_done > 2)
		brain.enemies |= assailant
