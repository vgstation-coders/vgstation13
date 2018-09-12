

/datum/component/ai/melee/RecieveSignal(var/message_type, var/list/args)
	switch(message_type)
		if(COMSIG_ATTACKING) // list("target"=A)
			return OnAttackingTarget(args["target"])
		else
			return ..(message_type, args)

/datum/component/ai/melee/proc/OnAttackingTarget(var/atom/target)
	if(!isliving(target))
		return 0
	var/mob/living/L = target
	return L.Adjacent(container.holder)
