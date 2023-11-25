/mob/new_player/Logout()
	if(client) client.lastproc += "Start new_player/Logout([list2params(args)]), "
	ready = 0
	..()
	if(!spawning)//Here so that if they are spawning and log out, the other procs can play out and they will have a mob to come back to.
		key = null//We null their key before deleting the mob, so they are properly kicked out.
		qdel(src)
	if(client) client.lastproc += "End new_player/Logout([list2params(args)]), "
	return
