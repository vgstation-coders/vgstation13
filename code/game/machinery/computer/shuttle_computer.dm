#define MAX_SHUTTLE_NAME_LEN

/obj/machinery/computer/shuttle_control
	name = "shuttle console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	req_access = null
	circuit = "/obj/item/weapon/circuitboard/mining_shuttle"

	machine_flags = EMAGGABLE | SCREWTOGGLE

	var/datum/shuttle/shuttle

	var/area/selected_area

/obj/machinery/computer/shuttle_control/New()
	if(shuttle)
		name = "[shuttle.name] console"

	.=..()

//Returns a link referring to the area for use in computers
//Example bonus_parameters var: ";unauthorized=1"
//This results in <a href='?src=\ref[src];select=\ref[A];unauthorized=1'> instead of <a href='?src=\ref[src];select=\ref[A]'>
/obj/machinery/computer/shuttle_control/proc/get_area_href(var/area/A, var/bonus_parameters=null)
	if(!A) return "ERROR"
	var/name = capitalize(A.name)
	var/span_s = "<a href='?src=\ref[src];select=\ref[A][bonus_parameters]'>"
	var/span_e = "</a>"
	if(A == selected_area)
		span_s += "<font color='red'>"
		span_e += "</font>"
	else
		span_s += "<font color='green'>"
		span_e += "</font>"
	return "[span_s][name][span_e]"

/obj/machinery/computer/shuttle_control/attack_hand(user as mob)
	if(..(user))
		return
	src.add_fingerprint(usr)
	var/shuttle_name = "Unknown shuttle"
	var/dat

	if(shuttle)
		shuttle_name = shuttle.name
		if(shuttle.lockdown)
			dat += "<h2><font color='red'>THIS SHUTTLE IS LOCKED DOWN</font></h2><br>"
			if(istext(shuttle.lockdown))
				dat += shuttle.lockdown
			else
				dat += "Additional information has not been provided."
		else
			if(shuttle.moving)
				if(shuttle.moving_to)
					dat += "<h3>Currently moving to [shuttle.moving_to.name]</h3>"
				else
					dat += "<h3>Currently moving</h3>"
			else
				dat += "Location: <b>[shuttle.current_area]</b><br>"
				dat += "Ready to move[max(shuttle.last_moved + shuttle.cooldown - world.time, 0) ? " in [max(round((shuttle.last_moved + shuttle.cooldown - world.time) * 0.1), 0)] seconds" : ": now"]<br>"

				//Write a list of all possible areas
				var/text
				for(var/area/A in shuttle.areas)
					if(A == shuttle.current_area)
						continue
					else
						text = get_area_href(A)

					dat += " | [text]"

				dat += " |<BR>"
				dat += "<center>[shuttle_name]:<br> <b><A href='?src=\ref[src];move=[1]'>Send[selected_area ? " to [selected_area]" : ""]</A></b></center><BR>"
	else //No shuttle
		dat = "<h1>NO SHUTTLE LINKED</h1><br>"
		dat += "<a href='?src=\ref[src];link_to_shuttle=1'>Link to a shuttle</a>"

	if(isAdminGhost(user))
		dat += "<br><hr><br>"
		dat += "<b><font color='red'>SPECIAL OPTIONS</font></h1></b>"
		dat += "<i>These are only available to administrators. Abuse may result in fun.</i><br><br>"
		dat += "<a href='?src=\ref[src];admin_link_to_shuttle=1'>Link to a shuttle</a><br><i>This allows you to link this computer to any existing shuttle, even if it's normally impossible to do so.</i><br>"
		if(shuttle)
			dat += "<a href='?src=\ref[src];admin_unlink_shuttle=1'>Unlink current shuttle</a><br><i>Unlink this computer from [shuttle.name]</i><br>"
			dat += "<a href='?src=\ref[src];admin_toggle_lockdown=1'>Toggle lockdown</a><br>"

	user << browse("[dat]", "window=shuttle_control;size=575x450")

/obj/machinery/computer/shuttle_control/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["move"])
		if(shuttle)
			var/error = shuttle.travel_to(selected_area, usr)
			if(error)
				src.say("ERROR: [error]")
			else
				src.say("[capitalize(shuttle.name)] recieved message and will be sent shortly.")

			selected_area = null

			src.updateUsrDialog()
	if(href_list["select"])
		var/area/A = locate(href_list["select"])
		if(!A)
			return

		selected_area = A
		src.updateUsrDialog()
	if(href_list["link_to_shuttle"])
		var/list/L = list()
		for(var/datum/shuttle/S in shuttles)
			var/name = S.name
			switch(S.can_link_to_computer)
				if(LINK_PASSWORD_ONLY)
					name = "[name] (requires password)"
				if(LINK_FORBIDDEN)
					continue

			L += name
			L[name] = S

		var/choice = input(usr,"Select a shuttle to link this computer to", "Shuttle control console") in L as text|null
		if(!Adjacent(usr)) return
		if(L[choice] && istype(L[choice],/datum/shuttle))
			shuttle = L[choice]


	if(href_list["admin_link_to_shuttle"])
		if(!isAdminGhost(usr))
			usr << "You must be an admin for this"
			return

		var/list/L = list()
		for(var/datum/shuttle/S in shuttles)
			var/name = S.name
			switch(S.can_link_to_computer)
				if(LINK_PASSWORD_ONLY)
					name = "[name] (password)"
				if(LINK_FORBIDDEN)
					name = "[name] (private)"

			L += name
			L[name] = S

		var/choice = input(usr,"Select a shuttle to link this computer to", "Admin abuse") in L as text|null
		if(L[choice] && istype(L[choice],/datum/shuttle))
			shuttle = L[choice]

	if(href_list["admin_unlink_shuttle"])
		if(!isAdminGhost(usr))
			usr << "You must be an admin for this"
			return

		shuttle = null

	if(href_list["admin_toggle_lockdown"])
		if(!isAdminGhost(usr))
			usr << "You must be an admin for this"
			return

		if(!shuttle.lockdown)
			var/choice = input(usr,"Would you like to specify a reason?", "Admin abuse") in list("Yes","No","Cancel")

			if(choice == "Cancel")
				return

			shuttle.lockdown = 1
			if(choice == "Yes")
				shuttle.lockdown = input(usr,"Please write a reason for locking the [capitalize(shuttle.name)] down.", "Admin abuse")
		else
			shuttle.lockdown = 0

/obj/machinery/computer/shuttle_control/bullet_act(var/obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")

/obj/machinery/computer/shuttle_control/proc/link_to(var/datum/shuttle/S, var/add_to_list = 1)
	if(shuttle)
		if(src in shuttle.control_consoles)
			shuttle.control_consoles -= src

	shuttle = S
	if(add_to_list)
		shuttle.control_consoles |= src
	src.updateUsrDialog()
//Custom shuttles below

/obj/machinery/computer/shuttle_core
	name = "shuttle core computer"
	desc = ""
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttlecore"
	req_access = null
	circuit = "/obj/item/weapon/circuitboard/mining_shuttle"

	machine_flags = EMAGGABLE | SCREWTOGGLE
	light_color = LIGHT_COLOR_GREEN

	var/list/pending_areas = list()
	var/datum/shuttle/shuttle

/obj/machinery/computer/shuttle_core/attack_hand(user as mob)
	if(..(user))
		return
	src.add_fingerprint(usr)

	var/dat

	if(!shuttle)
		dat = "There is no shuttle linked to this computer.<br>"
		dat +={"To create a shuttle, first thing you'll need to do is to define the starting area. Use a handheld bluespace beacon dispenser (sold separately) to designate an
		area using bluespace beacons. Install flooring and walls if required. Then, move this computer inside the area.<br><br>"}
		dat +="<a href='?src=\ref[src];create_shuttle=1'><font color='green'><b>Done! This console is now inside the designated area.</b></font></a><br>"
		dat +="<a href='?src=\ref[src];link_to_shuttle=1'><font color='blue'><b>Link this computer to an existing shuttle.</b></font></a>"
	else if(!areas || !areas.len)
		dat = "The shuttle has no areas in its memory!<br>"
		dat +={"Create more areas using your handheld bluespace beacon dispenser. Keep in mind that they must have the exact same shape and size as the first area!
			This is required to make everything as safe as possible.<br>
			To add an area to the shuttle's memory, hit the screen of this console with your handheld bluespace beacon dispenser and select the area you wish to add. Keep in mind
			that the starting area isn't automatically added to the memory, and if you don't add it manually you won't be able to return to it.<br>"}
		if(pending_areas.len)
			dat += "<b>Areas stored in memory:</b>"
			for(var/area/A in pending_areas)
				if(shuttle.current_area == A)
					dat += "<font color='blue'><b>[A.name] (current)</b></font><br>"
				else
					dat += "<font color='blue'>[A.name]</font><br>"
			dat += "<br>"
		dat +="<a href='?src=\ref[src];finish_areas=1'><font color='green'><b>Done!</b></font></a>"
	else
		dat = "<b>[shuttle.name] core computer</b><br><br>"
		dat +={"<hr><b>Basic information:</b><br>
			Name: [shuttle.name] (<a href='?src=\ref[src];edit_name=1'>change</a>)<br>
			Saved areas: [shuttle.areas.len] (<a href='?src=\ref[src];edit_areas=1'>reset</a>)<br>
			Linked computers: [0] (<a href='?src=\ref[src];edit_computers=1'>remove</a>)<br><br>

			<a href='?src=\ref[src];change_password=1'>Change password</a>"}
			/*
		dat +={"<hr><b>Technical information:</b><br>
			Propulsion systems: [(!shuttle.propulsions ? "<font color='red'>" : "<font color='green'>")][shuttle.propulsions]</font> (<a href='?src=\ref[src];scan_propulsion=1'>scan</a>)<br>
			Heaters: [(!shuttle.heaters ? "<font color='red'>" : "<font color='green'>")][shuttle.heaters]</font> (<a href='?src=\ref[src];scan_heater=1'>scan</a>)<br>
			"}
			 */

		//This could be coded better but whatever as long as it workd
		if(shuttle.has_defined_areas())
			dat += "<hr><b>Defined areas</b><br>"
			if(istype(shuttle,/datum/shuttle/emergency))
				var/datum/shuttle/emergency/E = shuttle
				dat += "Central Command: <a href='?src=\ref[src];change_escape_centcomm=1'>[(E.area_centcomm ? E.area_centcomm.name : "undefined")]</a><br>"
				dat += "Station: <a href='?src=\ref[src];change_escape_station=1'>[(E.area_station ? E.area_station.name : "undefined")]</a><br>"
			if(istype(shuttle,/datum/shuttle/cargo))
				var/datum/shuttle/cargo/C = shuttle
				dat += "Central Command: <a href='?src=\ref[src];change_cargo_centcomm=1'>[(C.area_centcomm ? C.area_centcomm.name : "undefined")]</a><br>"
				dat += "Cargo Bay: <a href='?src=\ref[src];change_cargo_station=1'>[(C.area_station ? C.area_station.name : "undefined")]</a><br>"
			if(istype(shuttle,/datum/shuttle/vox))
				var/datum/shuttle/vox/V = shuttle
				dat += "Home: <a href='?src=\ref[src];change_vox_home=1'>[(V.area_home ? V.area_home.name : "undefined")]</a><br>"

	if(isAdminGhost(user))
		dat += "<hr><br><b><font color='red'>SPECIAL</font></b>"
		dat += "<i>This section only available to administrators. Abuse may result in fun.</i><hr><br>"

		dat += "The shuttle's authentication password is: [shuttle.password]<br>"
		if(shuttle)
			dat += "<a href='?src=\ref[src];admin_change_cooldown=1'>Set cooldown (current: [shuttle.cooldown])</a><br>"
			dat += "<a href='?src=\ref[src];admin_change_delay=1'>Set delay (current: [shuttle.movement_delay])</a><br>"

		dat += "<a href='?src=\ref[src];admin_link_to_shuttle=1'>Link to a a shuttle</a>"

	user << browse("[dat]", "window=shuttle_build;size=575x450")

/obj/machinery/computer/shuttle_core/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["create_shuttle"])
		if(shuttle)
			return src.updateUsrDialog()
		var/area/my_area = get_area(src)

		if(!my_area)
			src.say("Unable to detect any areas here. Please consult the manual.")
			return

		if(istype(my_area,/area/shuttle))
			if(my_area.used_by_shuttles())
				src.say("This area is already being used by another shuttle.")
				return
			var/datum/shuttle/custom/new_shuttle = new
			new_shuttle.name = "shuttle"
			new_shuttle.current_area = my_area
			new_shuttle.areas = list()
			message_admins("<span class='notice'>[usr.ckey] has created a new shuttle - [formatJumpTo( get_turf(src) )]</span>")

			shuttle = new_shuttle
		else
			src.say("WARNING: Outdated area format. Shuttle Core Computers are only compactible with digital blueprints defined by bluespace beacons.")
			return

		src.updateUsrDialog()
	if(href_list["link_to_shuttle"])
		var/list/possible_shuttles = list()

		for(var/datum/shuttle/S in shuttles)
			if(S.core_computer) continue
			if(S.can_link_to_computer == LINK_FORBIDDEN) continue

			var/name = S.name
			if(S.can_link_to_computer == LINK_PASSWORD_ONLY)
				name = "[name] (requires password)"

			possible_shuttles += name
			possible_shuttles[name] = S

		var/choice = input(usr, "Select a shuttle to link this computer to", "Shuttle Core") in possible_shuttles
		if(!Adjacent(usr)) return

		var/datum/shuttle/shuttle_to_link = choice
		if(!shuttle_to_link) return

		if(shuttle_to_link.can_link_to_computer == LINK_PASSWORD_ONLY)
			var/password_attempt = input(usr, "Please type the shuttle's authentication password.", "Shuttle core") as text|num
			if(password_attempt != shuttle_to_link.password)
				usr << "<span class='warning'>Wrong password.</span>"
				return

		link_to(shuttle_to_link, make_primary = 1)
		message_admins("<span class='notice'>[key_name_admin(usr)] has linked [capitalize(shuttle_to_link.name)] to a core computer - [formatJumpTo( get_turf(src) )]</span>")

	if(href_list["finish_areas"])
		if(!shuttle) return
		shuttle.areas = pending_areas
		src.updateUsrDialog()
	if(href_list["edit_areas"])
		if(!shuttle) return
		shuttle.areas = null
		src.updateUsrDialog()
	if(href_list["edit_name"])
		if(!shuttle) return

		var/old_name = shuttle.name
		shuttle.name = sanitize(stripped_input(usr,"Write a new name for the shuttle.", "Shuttle Core", MAX_SHUTTLE_NAME_LEN))
		if(!Adjacent(usr))
			return

		if(!shuttle.name)
			shuttle.name = "shuttle"
			return

		usr << "The shuttle has been renamed successfully."
		message_admins("[key_name_admin(usr)] has changed [old_name]'s name to [shuttle.name] - [formatJumpTo( get_turf(src) )]")
		src.updateUsrDialog()
	if(href_list["admin_change_password"])
		if(!shuttle) return

		var/password_check = input(usr,"Please write the current password.", "[capitalize(shuttle.name)]")
		if(!Adjacent(usr))
			return
		if(password_check != shuttle.password)
			usr << "<span class='warning'>Wrong password.</span>"
			return

		var/new_password = stripped_input(usr,"Please write a new password. 8 symbols maximum.","[capitalize(shuttle.name)]",8)
		if(!Adjacent(usr))
			return

		shuttle.password = new_password
		usr << "The new password is [shuttle.password]."

	if(href_list["admin_change_cooldown"])
		if(!isAdminGhost(usr))
			usr << "You must be an admin to do this"
			return
		if(!shuttle) return

		var/old_cooldown = shuttle.cooldown
		shuttle.cooldown = input( usr, "Set the cooldown for [shuttle.name]:","Admin abuse",shuttle.cooldown) as num
		if(!isnum(shuttle.cooldown)) shuttle.cooldown = 1

		message_admins("<span class='notice'>[key_name_admin(usr)] has changed [capitalize(shuttle.name)]'s cooldown from [old_cooldown] to [shuttle.cooldown].</span>")
		log_admin("[key_name(usr)] has changed [capitalize(shuttle.name)]'s cooldown from [old_cooldown] to [shuttle.cooldown].")

		src.updateUsrDialog()
	if(href_list["admin_change_delay"])
		if(!isAdminGhost(usr))
			usr << "You must be an admin to do this"
			return
		if(!shuttle) return

		var/old_delay = shuttle.movement_delay
		shuttle.movement_delay = input(usr, "Set the movement delay for [shuttle.name]:","Admin abuse",shuttle.movement_delay) as num
		if(!isnum(shuttle.movement_delay)) shuttle.movement_delay = 1

		message_admins("<span class='notice'>[key_name_admin(usr)] has changed [capitalize(shuttle.name)]'s movement delay from [old_delay] to [shuttle.movement_delay].</span>")
		log_admin("[key_name(usr)] has changed [capitalize(shuttle.name)]'s cooldown from [old_delay] to [shuttle.movement_delay].")

		src.updateUsrDialog()
	if(href_list["admin_link_to_shuttle"])
		if(!isAdminGhost(usr))
			usr << "You must be an admin to do this"
			return
		var/datum/shuttle/S = select_shuttle_from_all(usr, "Select a shuttle to link this core computer to","Admin abuse")
		if( !S || !istype(S, /datum/shuttle) ) return

		link_to(S, make_primary = 0)

		if( (input(usr,"Set [capitalize(S.name)]'s primary core computer to be this one?") in list("Yes","No") ) == "Yes")
			S.core_computer = src

		src.updateUsrDialog()

		message_admins("<span class='notice'>[key_name_admin(usr)] has ADMIN-linked [capitalize(S.name)] to a core computer - [formatJumpTo( get_turf(src) )]</span>")
		log_admin("[key_name(usr)] has ADMIN-linked [capitalize(S.name)] to a core computer.")

	//Horrible code ahead

	if(href_list["change_escape_centcomm"])
		var/datum/shuttle/emergency/E = shuttle
		if(!E) return

		E.area_centcomm = select_area_from_list(usr,areas_list=E.areas,message="Select the Centcomm area",title="[capitalize(E.name)]")
		if(!Adjacent(usr)) return

		if(!E.area_centcomm)
			usr << "The area isn't valid. [capitalize(E)]'s areas will be reset."
			E.initialize()

		src.updateUsrDialog()

		message_admins("<span class='notice'>[key_name_admin(usr)] has changed emergency shuttle's CENTRAL COMMAND area to [E.area_centcomm.name] - [formatJumpTo( get_turf(src) )]</span>")
	if(href_list["change_escape_station"])
		var/datum/shuttle/emergency/E = shuttle
		if(!E) return

		E.area_station = select_area_from_list(usr,areas_list=E.areas,message="Select the Station area",title="[capitalize(E.name)]")
		if(!Adjacent(usr)) return

		if(!E.area_station)
			usr << "The area isn't valid. [capitalize(E)]'s areas will be reset."
			E.initialize()

		src.updateUsrDialog()

		message_admins("<span class='notice'>[key_name_admin(usr)] has changed emergency shuttle's STATION area to [E.area_station.name] - [formatJumpTo( get_turf(src) )]</span>")
	if(href_list["change_cargo_centcomm"])
		var/datum/shuttle/cargo/C = shuttle
		if(!C) return

		C.area_centcomm = select_area_from_list(usr,areas_list=C.areas,message="Select the Centcomm area",title="[capitalize(C.name)]")
		if(!Adjacent(usr)) return

		if(!C.area_centcomm)
			usr << "The area isn't valid. [capitalize(C)]'s areas will be reset."
			C.initialize()

		src.updateUsrDialog()

		message_admins("<span class='notice'>[key_name_admin(usr)] has changed cargo shuttle's CENTRAL COMMAND area to [C.area_centcomm.name] - [formatJumpTo( get_turf(src) )]</span>")
	if(href_list["change_cargo_station"])
		var/datum/shuttle/cargo/C = shuttle
		if(!C) return

		C.area_station = select_area_from_list(usr,areas_list=C.areas,message="Select the Station area",title="[capitalize(C.name)]")
		if(!Adjacent(usr)) return

		if(!C.area_station)
			usr << "The area isn't valid. [capitalize(C)]'s areas will be reset."
			C.initialize()

		src.updateUsrDialog()

		message_admins("<span class='notice'>[key_name_admin(usr)] has changed cargo shuttle's STATION area to [C.area_station.name] - [formatJumpTo( get_turf(src) )]</span>")
	if(href_list["change_vox_home"])
		var/datum/shuttle/vox/V = shuttle
		if(!V) return

		V.area_home = select_area_from_list(usr,areas_list=V.areas,message="Select the Home area",title="[capitalize(V.name)]")
		if(!Adjacent(usr)) return

		if(!V.area_home)
			usr << "The area isn't valid. [capitalize(V)]'s areas will be reset."
			V.initialize()

		src.updateUsrDialog()

		message_admins("<span class='notice'>[key_name_admin(usr)] has changed vox shuttle's HOME area to [V.area_home.name] - [formatJumpTo( get_turf(src) )]</span>")

/obj/machinery/computer/shuttle_core/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/weapon/beacon_dispenser))
		var/obj/item/weapon/beacon_dispenser/B = W
		if( shuttle && (!shuttle.areas || !shuttle.areas.len) )
			var/list/L = (B.areas - pending_areas)
			if(!L)
				user << "No new digital blueprints detected."
				return
			var/A = input(user,"Select an area to add", "Shuttle Core") in (B.areas - shuttle.areas) as area|null

			if(istype(A,/area/shuttle))
				pending_areas |= A
	..()

/obj/machinery/computer/shuttle_core/proc/link_to(var/datum/shuttle/S, var/make_primary = 1)
	if(shuttle)
		if(shuttle.core_computer == src)
			shuttle.core_computer = null

	shuttle = S
	if(make_primary)
		shuttle.core_computer = src
	src.updateUsrDialog()
#undef MAX_SHUTTLE_NAME_LEN
