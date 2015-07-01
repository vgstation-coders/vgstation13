/obj/machinery/computer/shuttle_controller
	name = "shuttle console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	req_access = null
	circuit = "/obj/item/weapon/circuitboard/mining_shuttle"

	machine_flags = EMAGGABLE | SCREWTOGGLE
	light_color = LIGHT_COLOR_CYAN

	var/datum/shuttle/shuttle

	var/area/selected_area

/obj/machinery/computer/shuttle_controller/New()
	if(shuttle)
		name = "[shuttle.name] console"

	.=..()

/obj/machinery/computer/shuttle_controller/mining/New()
	shuttle = mining_shuttle
	.=..()

/obj/machinery/computer/shuttle_controller/research/New()
	shuttle = research_shuttle
	.=..()

/obj/machinery/computer/shuttle_controller/salvage/New()
	shuttle = salvage_shuttle
	.=..()

/obj/machinery/computer/shuttle_controller/attack_hand(user as mob)
	if(..(user))
		return
	src.add_fingerprint(usr)
	var/shuttle_name = "Unknown shuttle"
	if(shuttle) shuttle_name = shuttle.name

	var/dat
	if(shuttle.moving)
		dat += "Currently moving"
	else
		dat += "Location: <b>[shuttle.current_area]</b><br>"
		dat += "Ready to move[max(shuttle.last_moved + shuttle.cooldown - world.time, 0) ? " in [max(round((shuttle.last_moved + shuttle.cooldown - world.time) * 0.1), 0)] seconds" : ": now"]<br>"

	//Write a list of all possible areas
	var/text
	for(var/area/A in shuttle.areas)
		var/name = A.name
		var/span_s = "<a href='?src=\ref[src];select=\ref[A]'>"
		var/span_e = "</a>"
		if(A == shuttle.current_area)
			continue
		else if(A == selected_area)
			text = "[span_s]<font color='red'>[name]</font>[span_e]"
		else
			text = "[span_s]<font color='green'>[name]</font>[span_e]"

		dat += " | [text]"

	dat += " |<BR>"
	dat += "<center>[shuttle_name]:<br> <b><A href='?src=\ref[src];move=[1]'>Send[selected_area ? " to [selected_area]" : ""]</A></b></center><BR>"
	user << browse("[dat]", "window=shuttle_control;size=575x450")

/obj/machinery/computer/shuttle_controller/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["move"])
		if(shuttle)
			if(shuttle.current_area == selected_area)
				usr << "<span class='notice'>The shuttle is already there!</span>"
			if(shuttle.last_moved + shuttle.cooldown > world.time)
				world << "<span class='notice'>The shuttle isn't ready yet!</span>"
			shuttle.start_movement(selected_area)

			selected_area = null

			src.updateUsrDialog()
	if(href_list["select"])
		var/area/A = locate(href_list["select"])
		if(!A)
			return

		selected_area = A
		src.updateUsrDialog()
