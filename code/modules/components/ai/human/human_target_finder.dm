/datum/component/ai/target_finder/human
	range = 7

/datum/component/ai/target_finder/human/initialize()
	parent.register_event(/event/attackby, src, nameof(src::on_attackby()))
	parent.register_event(/event/comp_ai_cmd_find_targets, src, nameof(src::cmd_find_targets()))
	return TRUE

/datum/component/ai/target_finder/human/Destroy()
	parent.unregister_event(/event/attackby, src, nameof(src::on_attackby()))
	parent.unregister_event(/event/comp_ai_cmd_find_targets, src, nameof(src::cmd_find_targets()))
	..()

/datum/component/ai/target_finder/human/cmd_find_targets()
	var/datum/component/ai/human_brain/brain = parent.get_component(/datum/component/ai/human_brain)
	var/list/o = list()
	for(var/mob/M in view(range, parent))
		if(is_type_in_list(M, exclude_types))
			continue
		if(M.isUnconscious())
			continue
		if((M in brain.enemies) || (M.faction && (M.faction in brain.enemy_factions)) || (M.type in brain.enemy_types))
			o += M
		else if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species && (H.species.name in brain.enemy_species))
				o += M
	return o

// YOU HAVE JUST MADE AN ENEMY FOR LIFE
/datum/component/ai/target_finder/human/proc/on_attackby(mob/attacker, obj/item/item)
	var/datum/component/ai/human_brain/brain = parent.get_component(/datum/component/ai/human_brain)
	if(item.force > 15) //Intent to kill!
		brain.friends.Remove(attacker)
	if(item.force > 2)
		brain.enemies |= attacker
