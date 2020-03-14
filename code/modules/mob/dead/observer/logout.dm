/mob/dead/observer/Logout()
	..()
	spawn(0)
		if(src && !key && !transmogged_to)	//we've transferred to another mob. This ghost should be deleted.
			qdel(src)
