/mob/living/carbon/human/grabbed_by(mob/living/grabber)
	if(ishuman(grabber) && w_uniform)
		w_uniform.add_fingerprint(grabber)
	return ..()

/mob/living/carbon/human/disarmed_by(mob/living/disarmer)
	if(ishuman(disarmer) && w_uniform)
		w_uniform.add_fingerprint(grabber)

	for(var/obj/item/weapon/gun/G in held_items)
		var/index = is_holding_item(G)
		var/chance = (index == active_hand ? 40 : 20)

		if(prob(chance))
			visible_message("<spawn class=danger>[G], held by [src], goes off during struggle!")
			var/list/turfs = list()
			for(var/turf/T in view())
				turfs += T
			var/turf/target = pick(turfs)
			return G.afterattack(target, src, "struggle" = 1)


/mob/living/carbon/human/disarm_mob(mob/living/target)
	src.attack_log += text("\[[time_stamp()]\] <font color='red'>Disarmed [target.name] ([target.ckey])</font>")
	target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been disarmed by [src.name] ([src.ckey])</font>")

	log_attack("[src.name] ([src.ckey]) disarmed [target.name] ([target.ckey])")

	var/datum/organ/external/affecting = get_organ(ran_zone(zone_sel.selecting))
	if(target.disarmed_by(src))
		return

	var/randn = rand(1, 100)
	if(randn <= 25)
		target.apply_effect(4, WEAKEN, run_armor_check(affecting, "melee"))
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		visible_message("<span class='danger'>[src] has pushed [target]!</span>")
		src.attack_log += text("\[[time_stamp()]\] <font color='red'>Pushed [target.name] ([target.ckey])</font>")
		target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been pushed by [src.name] ([src.ckey])</font>")

		target.LAssailant = src

		log_attack("[src.name] ([src.ckey]) pushed [target.name] ([target.ckey])")
		return

	var/talked = 0

	if(randn <= 60)
		//Disarming breaks pulls
		talked |= target.break_pulls()

		//Disarming also breaks a grab - this will also stop someone being choked, won't it?
		talked |= target.break_grabs()

		if(!talked)
			target.drop_item()
			visible_message("<span class='danger'>[src] has disarmed [target]!</span>")
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		return


	playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
	visible_message("<span class='danger'>[src] attempted to disarm [target]!</span>")