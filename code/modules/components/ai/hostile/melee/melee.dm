/datum/component/ai/melee
	var/def_zone = LIMB_CHEST

/datum/component/ai/melee/RecieveSignal(var/message_type, var/list/args)
	switch(message_type)
		if(COMSIG_ATTACKING) // list("target"=A)
			return OnAttackingTarget(args["target"])
		if(COMSIG_SETDEFZONE)
			def_zone = args["def_zone"]
		else
			return ..(message_type, args)

/datum/component/ai/melee/proc/OnAttackingTarget(var/atom/target)
	if(!isliving(target))
		return 0
	var/mob/living/L = target
	return L.Adjacent(container.holder)
