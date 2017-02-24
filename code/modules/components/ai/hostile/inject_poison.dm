/datum/component/ai/inject_poison
	var/poison_type = "" // STOXIN, etc
	var/poison_per_bite = 0 // Mols to inject
	var/inject_prob = 0 // Chance to inject, -1 = ALWAYS
	var/max_poison = 0 // Maximum mols in target's blood. 0 = INF

/datum/component/ai/inject_poison/RecieveSignal(var/message_type, var/list/args)
	switch(message_type)
		if(COMSIG_ATTACKING) // list("target"=A)
			OnAttackingTarget(args["target"])
		else
			..(message_type, args)

/datum/component/ai/inject_poison/proc/OnAttackingTarget(var/atom/target)
	if(isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			if(inject_prob == -1 || prob(inject_prob))
				var/curamt = L.reagents.get_reagent_amount(poison_type)
				var/newamt = max_poison - curamt
				if(newamt >= 1)
					container.holder.visible_message("<span class='warning'>\The [src] injects something into \the [target]!</span>")
					L.reagents.add_reagent(poison_type, poison_per_bite)
