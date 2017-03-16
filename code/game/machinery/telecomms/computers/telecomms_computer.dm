/obj/machinery/computer/telecomms
	var/screen = SCREEN_MAIN // The screen being shown
	var/network = "NULL" // The chose network string
	var/list/machines = list() // The machines being worked with
	var/temp = "" // Temporary feedback messages

	light_color = LIGHT_COLOR_GREEN
	req_access = list(access_tcomsat)

/obj/machinery/computer/telecomms/emag(mob/user)
	if(!emagged)
		playsound(get_turf(src), 'sound/effects/sparks4.ogg', 75, 1)
		emagged = TRUE
		req_access.Cut()
		to_chat(user, "<span class='notice'>You you disable the security protocols on \the [src].</span>")
		return TRUE

/obj/machinery/computer/telecomms/proc/set_temp(var/message, var/class = NEUTRAL)
	temp = "<span class='[class] tempmsg'>[message]</span>"

/obj/machinery/computer/telecomms/Destroy()
	machines = null
	return ..()
