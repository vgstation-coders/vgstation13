/datum/component/ai/crowd_attack

/datum/component/ai/crowd_attack/initialize()
	parent.register_event(/event/attackby, src, nameof(src::on_attackby()))
	return TRUE

/datum/component/ai/crowd_attack/Destroy()
	parent.unregister_event(/event/attackby, src, nameof(src::on_attackby()))
	..()

/datum/component/ai/crowd_attack/proc/on_attackby(mob/attacker, obj/item/item)
	var/datum/component/ai/human_brain/brain = parent.get_component(/datum/component/ai/human_brain)
	if(!brain)
		return
	for(var/mob/living/M in oview(7, parent))
		if(!(M in brain.friends)) //THEY'RE ATTACKING OUR BOY, GET HIM!
			continue
		INVOKE_EVENT(M, /event/comp_ai_friend_attacked, "attacker"=attacker)
