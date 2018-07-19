/datum/component/ai/crowd_attack
	var/datum/component/ai/human_brain/brain

/datum/component/ai/crowd_attack/Initialize()
	..()
	RegisterSignal(parent, COMSIG_ATTACKEDBY, .proc/on_attackedby)

/datum/component/ai/crowd_attack/proc/on_attackedby(var/mob/assailant, var/damage_done)
	if(!brain)
		brain = parent.GetComponent(/datum/component/ai/human_brain)
	if(!brain)
		return
	for(var/mob/living/M in oview(7, parent))
		if(!M.isUnconscious() || !(M in brain.friends)) //THEY'RE ATTACKING OUR BOY, GET HIM!
			continue
		SEND_SIGNAL(M, COMSIG_ATTACKEDBY, assailant, damage_done)
