/mob/living/silicon/ai/Logout()
	..()
	for(var/obj/machinery/ai_status_display/O in machines) //change status
		O.mode = 0
	client?.show_popup_menus = TRUE
	if(!isturf(loc))
		if (client)
			client.eye = loc
			client.perspective = EYE_PERSPECTIVE
	view_core()
	return