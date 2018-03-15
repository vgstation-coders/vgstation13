/proc/random_hair_style(gender, species = "Human")
	var/h_style = "Bald"

	var/list/valid_hairstyles = valid_sprite_accessories(hair_styles_list, gender, species, HAIRSTYLE_CANTRIP)

	if(valid_hairstyles.len)
		h_style = pick(valid_hairstyles)

	return h_style

/proc/GetOppositeDir(var/dir)
	switch(dir)
		if(NORTH)
			return SOUTH
		if(SOUTH)
			return NORTH
		if(EAST)
			return WEST
		if(WEST)
			return EAST
		if(SOUTHWEST)
			return NORTHEAST
		if(NORTHWEST)
			return SOUTHEAST
		if(NORTHEAST)
			return SOUTHWEST
		if(SOUTHEAST)
			return NORTHWEST
	return 0

/proc/random_facial_hair_style(gender, species = "Human")
	var/f_style = "Shaved"

	var/list/valid_facialhairstyles = valid_sprite_accessories(facial_hair_styles_list, gender, species)

	if(valid_facialhairstyles.len)
		f_style = pick(valid_facialhairstyles)

		return f_style

proc/random_name(gender, speciesName = "Human")
	var/datum/species/S = all_species[speciesName]
	if(S)
		return S.makeName(gender)
	else
		var/datum/species/human/H = new
		return H.makeName(gender)



proc/random_skin_tone(species = "Human")
	if(species == "Human")
		switch(pick(60;"caucasian", 15;"afroamerican", 10;"african", 10;"latino", 5;"albino"))
			if("caucasian")
				. = -10
			if("afroamerican")
				. = -115
			if("african")
				. = -165
			if("latino")
				. = -55
			if("albino")
				. = 34
			else
				. = rand(-185,34)
		return min(max( .+rand(-25, 25), -185),34)
	else if(species == "Vox")
		. = rand(1,6)
		return .
	else
		return 0

proc/skintone2racedescription(tone, species = "Human")
	if(species == "Human")
		switch (tone)
			if(30 to INFINITY)
				return "albino"
			if(20 to 30)
				return "pale"
			if(5 to 15)
				return "light skinned"
			if(-10 to 5)
				return "white"
			if(-25 to -10)
				return "tan"
			if(-45 to -25)
				return "darker skinned"
			if(-65 to -45)
				return "brown"
			if(-INFINITY to -65)
				return "black"
			else
				return "unknown"
	else if(species == "Vox")
		switch(tone)
			if(6)
				return "emerald"
			if(5)
				return "azure"
			if(4)
				return "light green"
			if(2)
				return "brown"
			if(3)
				return "gray"
			else
				return "green"
	else
		return "unknown"

proc/age2agedescription(age)
	switch(age)
		if(0 to 1)
			return "infant"
		if(1 to 3)
			return "toddler"
		if(3 to 13)
			return "child"
		if(13 to 19)
			return "teenager"
		if(19 to 30)
			return "young adult"
		if(30 to 45)
			return "adult"
		if(45 to 60)
			return "middle-aged"
		if(60 to 70)
			return "aging"
		if(70 to INFINITY)
			return "elderly"
		else
			return "unknown"

proc/RoundHealth(health)
	switch(health)
		if(100 to INFINITY)
			return "health100"
		if(70 to 100)
			return "health80"
		if(50 to 70)
			return "health60"
		if(30 to 50)
			return "health40"
		if(18 to 30)
			return "health25"
		if(5 to 18)
			return "health10"
		if(1 to 5)
			return "health1"
		if(-99 to 0)
			return "health0"
		else
			return "health-100"
	return "0"

/proc/cyborg_health_to_icon_state(var/health_ratio)
	switch(health_ratio)
		if(1.00 to INFINITY)
			return "huddiagmax"
		if(0.80 to 1.00)
			return "huddiaggood"
		if(0.60 to 0.80)
			return "huddiaghigh"
		if(0.40 to 0.60)
			return "huddiagmed"
		if(0.20 to 0.40)
			return "huddiaglow"
		if(0.00 to 0.20)
			return "huddiagcrit"
		if(-100.0 to 0.00)
			return "huddiagdead"
	return "huddiagmax"

/proc/power_cell_charge_to_icon_state(var/charge_ratio)
	switch(charge_ratio)
		if(0.95 to INFINITY)
			return "hudbattmax"
		if(0.80 to 0.95)
			return "hudbattgood"
		if(0.60 to 0.80)
			return "hudbatthigh"
		if(0.40 to 0.60)
			return "hudbattmed"
		if(0.20 to 0.40)
			return "hudbattlow"
		if(0.10 to 0.20)
			return "hudbattcrit"
	return "hudbattdead"

/*
Proc for attack log creation, because really why not
1 argument is the actor
2 argument is the target of action
3 is the description of action(like punched, throwed, or any other verb)
4 should it make adminlog note or not
5 is the tool with which the action was made(usually item)					5 and 6 are very similar(5 have "by " before it, that it) and are separated just to keep things in a bit more in order
6 is additional information, anything that needs to be added
*/

proc/add_logs(mob/user, mob/target, what_done, var/admin=1, var/object=null, var/addition=null)
	if(user && ismob(user))
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has [what_done] [target ? "[target.name][(ismob(target) && target.ckey) ? "([target.ckey])" : ""]" : "NON-EXISTANT SUBJECT"][object ? " with [object]" : " "]. [addition]</font>")
	if(target && ismob(target))
		target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been [what_done] by [user ? "[user.name][(ismob(user) && user.ckey) ? "([user.ckey])" : ""]" : "NON-EXISTANT SUBJECT"][object ? " with [object]" : " "]. [addition]</font>")
		if(!iscarbon(user))
			target.LAssailant = null
		else
			target.LAssailant = user
	if(admin)
		log_attack("<font color='red'>[user ? "[user.name][(ismob(user) && user.ckey) ? "([user.ckey])" : ""]" : "NON-EXISTANT SUBJECT"] [what_done] [target ? "[target.name][(ismob(target) && target.ckey)? "([target.ckey])" : ""]" : "NON-EXISTANT SUBJECT"][object ? " with [object]" : " "]. [addition]</font>")

proc/add_ghostlogs(var/mob/user, var/obj/target, var/what_done, var/admin=1, var/addition=null)
	var/target_text = "NON-EXISTENT TARGET"
	var/subject_text = "NON-EXISTENT SUBJECT"
	if(target)
		target_text=target.name
		if(ismob(target))
			var/mob/M=target
			if(M.ckey)
				target_text += "([M.ckey])"
	if(user)
		subject_text=user.name
		if(ismob(user))
			var/mob/M=user
			if(M.ckey)
				subject_text += "([M.ckey])"
	if(user && ismob(user))
		user.attack_log += "\[[time_stamp()]\] GHOST: <font color='red'>Has [what_done] [target_text] [addition]</font>"
	if(target && ismob(target))
		var/mob/M=target
		M.attack_log += "\[[time_stamp()]\] GHOST: <font color='orange'>Has been [what_done] by [subject_text] [addition]</font>"
	if(admin)
		//message_admins("GHOST: [subject_text] [what_done] [target_text] [addition]")
		if(isAdminGhost(user))
			log_adminghost("[subject_text] [what_done] [target_text] [addition]")
		else
			log_ghost("[subject_text] [what_done] [target_text] [addition]")

/mob/proc/isVentCrawling()
	return (istype(loc, /obj/machinery/atmospherics)) // Crude but no other situation would put them inside of this

/proc/random_blood_type()
	return pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")
	//https://en.wikipedia.org/wiki/Blood_type_distribution_by_country
	/*return pick(\
		41.9; "O+",\
		31.2; "A+",\
		15.4; "B+",\
		4.8; "AB+",\
		2.9; "O-",\
		2.7; "A-",\
		0.8; "B-",\
		0.3; "AB-")*/

//Returns list of organs that are affected by items worn in the slot. For example, calling get_organ_by_slot(slot_belt) will return list(groin)
//If H is null, a list of organ names is returned: list(LIMB_LEFT_ARM, LIMB_LEFT_HAND)
//If H isn't null, a list of organ objects from H is returned: list(H.get_organ(LIMB_LEFT_ARM), H.get_organ(LIMB_LEFT_HAND))

/proc/get_organs_by_slot(input_slot, mob/living/carbon/human/H = null)
	var/list/L

	switch(input_slot)
		if(slot_wear_suit) //Exosuit
			L = list(LIMB_CHEST, LIMB_GROIN, LIMB_LEFT_ARM, LIMB_LEFT_HAND, LIMB_RIGHT_ARM, LIMB_RIGHT_HAND, LIMB_LEFT_LEG, LIMB_LEFT_FOOT, LIMB_RIGHT_LEG, LIMB_RIGHT_FOOT)
		if(slot_w_uniform) //Uniform
			L = list(LIMB_CHEST, LIMB_GROIN, LIMB_LEFT_ARM, LIMB_RIGHT_ARM, LIMB_LEFT_LEG, LIMB_RIGHT_LEG)
		if(slot_gloves, slot_handcuffed) //Gloves
			L = list(LIMB_LEFT_HAND, LIMB_RIGHT_HAND)
		if(slot_wear_mask, slot_ears, slot_glasses, slot_head)
			L = list(LIMB_HEAD)
		if(slot_shoes)
			L = list(LIMB_LEFT_FOOT, LIMB_RIGHT_FOOT)
		if(slot_belt)
			L = list(LIMB_GROIN)
		if(slot_back, slot_wear_id)
			L = list(LIMB_CHEST)
		if(slot_legs, slot_legcuffed)
			L = list(LIMB_LEFT_LEG, LIMB_RIGHT_LEG)

	if(H)
		for(var/organ in L)
			L |= (H.get_organ(organ))
			L.Remove(organ)

	return L

/proc/adjacent_atoms(atom/center)
	var/list/L = list()

	for(var/atom/A in range(1, center))
		if(center.Adjacent(A))
			L.Add(A)

	return L
