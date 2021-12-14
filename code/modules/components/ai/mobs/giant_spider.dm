/mob/living/component/giant_spider
	name="component giant spider"

	icon_state = "guard"
	icon = 'icons/mob/animal.dmi'

/mob/living/component/giant_spider/InitializeComponents()
	BrainContainer.AddComponent(/datum/component/controller/mob)
	BrainContainer.AddComponent(/datum/component/ai/escape_confinement)
	BrainContainer.AddComponent(/datum/component/ai/hunt)
	BrainContainer.AddComponent(/datum/component/ai/melee/attack_animal)
	var/datum/component/ai/melee/inject_reagent/injector = BrainContainer.AddComponent(/datum/component/ai/melee/inject_reagent)
	injector.poison_type = STOXIN
	injector.poison_per_bite = 5
	var/datum/component/ai/target_finder/simple_view/sv = BrainContainer.AddComponent(/datum/component/ai/target_finder/simple_view)
	sv.range = 5
	// These two should probably be done on New() based on container.holder.
	sv.exclude_types += src.type
	sv.exclude_types += /mob/living/silicon/robot/mommi // Because we wuv dem
	var/datum/component/ai/target_holder/prioritizing/th = BrainContainer.AddComponent(/datum/component/ai/target_holder/prioritizing)
	th.type_priorities[src.type]=0
	BrainContainer.AddComponent(/datum/component/ai/door_opener)
