/mob/living/component/giant_spider
	name = "component giant spider"
	icon_state = "guard"
	icon = 'icons/mob/animal.dmi'

/mob/living/component/giant_spider/New()
	..()
	add_component(/datum/component/controller)
	add_component(/datum/component/ai/escape_confinement)
	add_component(/datum/component/ai/hunt)
	add_component(/datum/component/ai/melee/attack_animal)
	var/datum/component/ai/melee/inject_reagent/injector = add_component(/datum/component/ai/melee/inject_reagent)
	injector.poison_type = STOXIN
	injector.poison_per_bite = 5
	var/datum/component/ai/target_finder/simple_view/sv = add_component(/datum/component/ai/target_finder/simple_view)
	sv.range = 5
	// These two should probably be done on New() based on container.holder.
	sv.exclude_types += src.type
	sv.exclude_types += /mob/living/silicon/robot/mommi // Because we wuv dem
	var/datum/component/ai/target_holder/prioritizing/th = add_component(/datum/component/ai/target_holder/prioritizing)
	th.type_priorities[src.type]=0
	add_component(/datum/component/ai/door_opener)
