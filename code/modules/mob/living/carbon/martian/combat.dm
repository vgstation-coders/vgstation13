/mob/living/carbon/martian/get_unarmed_damage_zone(mob/living/victim)
	return zone_sel.selecting

/mob/living/carbon/martian/knockout_chance_modifier()
	return 0 //Punches don't stun

/mob/living/carbon/martian/getarmor(var/def_zone, var/type)

	var/armorscore = 0
	if((def_zone == "head") || (def_zone == "eyes") || (def_zone == "mouth"))
		if(head)
			armorscore = head.armor[type]

	return armorscore
