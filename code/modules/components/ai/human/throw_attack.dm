/datum/component/ai/melee/throw_attack

/datum/component/ai/melee/throw_attack/OnAttackingTarget(var/atom/target)
	if(!isliving(target))
		return 0
	var/mob/M = container.holder
	if(!istype(M))
		return 0
	var/obj/item/I = M.get_active_hand()
	if(I && I.throwforce > I.force && get_dist(M,target) > 2) //Better to throw it at the fucker
		SendSignal(COMSIG_THROWAT, list("target" = target))
		return 1