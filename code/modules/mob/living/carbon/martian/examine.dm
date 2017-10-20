/mob/living/carbon/martian/examine(mob/user)

	var/msg = "<span class='info'>*---------*\nThis is [bicon(src)] \a <EM>[src]</EM>!\n"

	if (src.handcuffed &&  handcuffed.is_visible())
		msg += "It is [bicon(src.handcuffed)] handcuffed!\n"

	for(var/obj/item/I in held_items)
		if(I.is_visible())
			if(I.blood_DNA && I.blood_DNA.len)
				msg += "<span class='warning'>It has [bicon(I)] [I.gender==PLURAL?"some":"a"] blood-stained [I.name] in its [get_index_limb_name(is_holding_item(I))]!</span>\n"
			else
				msg += "It has [bicon(I)] \a [I] in its [get_index_limb_name(is_holding_item(I))].\n"

	if (isDead())
		msg += "<span class='deadsay'>It is limp and unresponsive, with no signs of life.</span>\n"
	else
		msg += "<span class='warning'>"
		if (src.getBruteLoss())
			if (src.getBruteLoss() < 30)
				msg += "It has minor bruising.\n"
			else
				msg += "<B>It has severe bruising!</B>\n"
		if (src.getFireLoss())
			if (src.getFireLoss() < 30)
				msg += "It has minor burns.\n"
			else
				msg += "<B>It has severe burns!</B>\n"
		if (src.stat == UNCONSCIOUS)
			msg += "It isn't responding to anything around it; it seems to be asleep.\n"
		msg += "</span>"

	var/butchery = "" //More information about butchering status, check out "code/datums/helper_datums/butchering.dm"
	if(butchering_drops && butchering_drops.len)
		for(var/datum/butchering_product/B in butchering_drops)
			butchery = "[butchery][B.desc_modifier(src)]"
	if(butchery)
		msg += "<span class='info'>[butchery]</span>"

	msg += "*---------*</span>"


	to_chat(user, msg)
