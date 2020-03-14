/mob/dead/observer/Login()
	..()

	if(src.check_rights(R_ADMIN|R_FUN))
		to_chat(src, "<span class='warning'>You are now an admin ghost.  Think of yourself as an AI that doesn't show up anywhere and cannot speak.  You can access any console or machine by standing next to it and clicking on it.  Abuse of this privilege may result in hilarity or removal of your flags, so caution is recommended.</span>")

	if(client)
		client.CAN_MOVE_DIAGONALLY = 1

/mob/dead/observer/MouseDrop(atom/over)
	if(!usr || !over)
		return

	if (isobserver(usr) && usr.client.holder && isliving(over))
		if (usr.client.holder.cmd_ghost_drag(src,over))
			return

	return ..()
