/mob/living/component/giant_spider
	name="component giant spider"

	icon_state = "guard"
	icon = 'icons/mob/animal.dmi'

/mob/living/component/giant_spider/InitializeComponents()
	TryAttachComponent(/datum/component/controller/mob)
	TryAttachComponent(/datum/component/ai/escape_confinement)
	TryAttachComponent(/datum/component/ai/hunt)
	TryAttachComponent(/datum/component/ai/target_holder)
	TryAttachComponent(/datum/component/ai/melee/attack_animal)
	TryAttachComponent(/datum/component/ai/door_opener)
	TryAttachComponent(/datum/component/ai/melee/inject_reagent, list("type" = "STOXIN", "amount" = 5))