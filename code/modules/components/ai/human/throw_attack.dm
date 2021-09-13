/datum/component/ai/melee/throw_attack

/datum/component/ai/melee/throw_attack/cmd_attack(atom/target)
	if(!isliving(target))
		return 0
	var/mob/living/M = parent
	if(!istype(M))
		return 0
	var/obj/item/I = M.get_active_hand()
	if(I && I.throwforce > I.force && get_dist(M,target) > 2) //Better to throw it at the fucker
		M.throw_mode_on()
		M.ClickOn(target)
		M.throw_mode_off()
		return 1
