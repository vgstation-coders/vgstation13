//ANTAG SEED
//It runs a tally and based on the tally it returns the candidates that many times
//Currently only built for roundstart antags

proc/roundstart_generate_antag_seed(var/list/candidates)
	var/list/placeholder_list //This is where we will store all the candidates
	for(var/mob/new_player/user in candidates)
		var/tally = 1
		if(!user.client) //There is no player for it to be an antag
			continue
		if(!user.mind) //User has no mind for them to become antag
			continue
		var/client/C = user.client
//Let's start the tallying
		if(C.prefs.s_tone <= 130)
			tally += 1
		if(C.prefs.species == "Vox") //Vox commit more crime
			tally += 1
		if(C.prefs.age >= 56)
			tally += 1
		if((C.prefs.h_style == "Bald") || (C.prefs.h_style == "Floorlength Braid"))
			tally += 1
		if(C.prefs.r_eyes >= 180 && C.prefs.g_eyes <= 20 && C.prefs.b_eyes <= 20) //Red eyes, caution!
			tally += 1
		if(C.prefs.r_hair <= 20 && C.prefs.g_hair >= 180 && C.prefs.b_hair <= 20) //Green hair are up to no good
			tally += 1
		if(C.prefs.language == LANGUAGE_GUTTER)
			tally += 1
		for(var/i = 0, i < tally, i++)
			placeholder_list += user
	return placeholder_list
