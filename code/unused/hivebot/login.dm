/mob/living/silicon/hivebot/Login()
	..()

	update_clothing()

	if (!isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE
	if (stat == 2)
		verbs += /client/proc/ghost
	if(real_name == "Hiveborg")
		real_name += " "
		real_name += "-[rand(1, 999)]"
		name = real_name
	return