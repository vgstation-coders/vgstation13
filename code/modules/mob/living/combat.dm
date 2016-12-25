/mob/living/proc/grab_mob(mob/living/target)
	if(grab_check(target))
		return
	if(target.locked_to)
		to_chat(src, "<span class='notice'>You cannot grab \the [target], \he is buckled in!</span>")
		return

	var/obj/item/weapon/grab/G = getFromPool(/obj/item/weapon/grab, src, target)
	if(!G)	//the grab will delete itself in New if affecting is anchored
		return

	put_in_active_hand(G)
	target.grabbed_by += G

	G.synch()
	target.LAssailant = src
	target.grabbed_by(src)

	playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	visible_message("<span class='warning'>[src] grabs [target] passively!</span>")
	return 1

/mob/living/proc/grabbed_by(mob/living/grabber)
	return

/mob/living/proc/disarm_mob(mob/living/target)
	src.attack_log += "\[[time_stamp()]\] <font color='red'>Disarmed [target.name] ([target.ckey])</font>"
	target.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been disarmed by [src.name] ([src.ckey])</font>"

	log_attack("[src.name] ([src.ckey]) disarmed [target.name] ([target.ckey])")

/mob/living/proc/disarmed_by(mob/living/disarmer)
	return

/mob/living/proc/break_grabs(mob/living/target)
	for(var/obj/item/weapon/grab/G in target.held_items)
		if(G.affecting)
			visible_message("<span class='danger'>[src] has broken [target]'s grip on [G.affecting]!</span>")
		spawn(1)
			qdel(G)
			G = null

		. = TRUE

/mob/living/proc/break_pulls(mob/living/target)
	if(target.pulling)
		visible_message("<span class='danger'>[src] has broken [target]'s grip on [target.pulling]!</span>")
		target.stop_pulling()
		return TRUE
