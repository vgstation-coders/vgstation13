/datum/component/ai/crowd_attack
	var/datum/component/ai/human_brain/B

/datum/component/ai/crowd_attack/RecieveSignal(var/message_type, var/list/args)
	if(!B)
		B = owner.TryGetComponent(/datum/component/ai/human_brain)
	if(B && message_type == COMSIG_ATTACKEDBY)
		var/assailant = args["assailant"]
		var/damage_done = args["damage"]
		for(var/mob/living/M in oview(7, owner))
			if(!M.isUnconscious() || !(M in B.friends)) //THEY'RE ATTACKING OUR BOY, GET HIM!
				continue
			M.SignalComponents(COMSIG_ATTACKEDBY, list("assailant"=assailant,"damage"=damage_done))