/mob/living/carbon/not_human/martian/getarmor(var/def_zone, var/type)

	var/armorscore = 0
	if((def_zone == "head") || (def_zone == "eyes") || (def_zone == "mouth"))
		if(head)
			armorscore = head.armor[type]

	return armorscore