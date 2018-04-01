/datum/component/ai/melee/inject_reagent
	var/poison_type = "" // STOXIN, etc
	var/poison_per_bite = 0 // Mols to inject
	var/inject_prob = 0 // Chance to inject, -1 = ALWAYS
	var/max_poison = 0 // Maximum mols in target's blood. 0 = INF

/datum/component/ai/melee/inject_reagent/OnAttackingTarget(var/atom/target)
	if(..(target))
		var/mob/living/L = target
		if(L.reagents)
			if(inject_prob == -1 || prob(inject_prob))
				var/curamt = L.reagents.get_reagent_amount(poison_type)
				var/newamt = max_poison - curamt
				if(newamt >= 1)
					// TEXT-FORMATTING FUNCTIONS WHEN BYOND?
					container.holder.visible_message("<span class='warning'>\The [src] injects something into \the [target]!</span>")
					L.reagents.add_reagent(poison_type, poison_per_bite)
					return 1 // Accepted signal
	return 0 // Did not accept signal
