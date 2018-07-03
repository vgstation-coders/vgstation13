#define VOX_SHUTTLE_MOVE_TIME 260
#define VOX_SHUTTLE_COOLDOWN 460

//Copied from Syndicate shuttle.
var/global/vox_shuttle_location

/obj/machinery/computer/vox_station
	name = "vox skipjack terminal"
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	req_access = list(access_syndicate)
	var/moving = FALSE
	var/lastMove = 0

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/vox_station/proc/vox_move_to(var/destination)
	if(moving)
		return

	if(lastMove + VOX_SHUTTLE_COOLDOWN > world.time)
		return

	var/area/dest_location = locate(destination)
	var/area/this_area = get_area(src)
	if(this_area == dest_location)
		return

	moving = TRUE
	lastMove = world.time

	if(this_area.z != dest_location.z)
		var/area/transit_location = locate(/area/vox_station/transit)
		this_area.move_contents_to(transit_location)
		this_area = transit_location // let do this while move_contents_to proc is not using Move()
		sleep(VOX_SHUTTLE_MOVE_TIME)

	this_area.move_contents_to(dest_location)
	this_area = dest_location
	moving = FALSE

	return 1

/obj/machinery/computer/vox_station/attackby(obj/item/I as obj, mob/user as mob)
	if(!..())
		return attack_hand(user)

/obj/machinery/computer/vox_station/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/vox_station/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/vox_station/attack_hand(mob/user as mob)
	if(!allowed(user) || issilicon(user))
		to_chat(user, "<span class=\"warning\">Access Denied.</span>")
		return

	user.set_machine(src)
	var/area/this_area = get_area(src)
	var/dat = {"
		Location: [this_area]<br>
		Ready to move[max(lastMove + VOX_SHUTTLE_COOLDOWN - world.time, 0) ? " in [max(round((lastMove + VOX_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br>
		<a href='?src=\ref[src];move=start'>Return to dark space</a><br>
		<a href='?src=\ref[src];move=solars_fore_port'>Fore port solar</a> |
		<a href='?src=\ref[src];move=solars_aft_port'>Aft port solar</a> |
		<a href='?src=\ref[src];move=solars_fore_starboard'>Fore starboard solar</a><br>
		<a href='?src=\ref[src];move=solars_aft_starboard'>Aft starboard solar</a> |
		<a href='?src=\ref[src];move=mining'>Mining Asteroid</a><br>
		<a href='?src=\ref[user];mach_close=computer'>Close</a>
	"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")

/obj/machinery/computer/vox_station/power_change()
	return

/obj/machinery/computer/vox_station/Topic(href, href_list)
	if(..())
		return 1

	var/mob/user = usr

	user.set_machine(src)

	vox_shuttle_location = "station"

	switch(href_list["move"])
		if("start")
			if(ticker && istype(ticker.mode, /datum/game_mode/heist))
				switch(alert("OOC INFO: Returning to dark space will end your raid and report your success or failure.", "Confirmation", "Yes", "No"))
					if("Yes")
						var/location = get_turf(user)
						message_admins("[key_name_admin(user)] attempts to end the raid - [formatJumpTo(location)]")
						log_admin("[key_name(user)] attempts to end the raid - [formatLocation(location)]")
					if("No")
						return

			if(vox_move_to(/area/shuttle/vox/station) == 1)
				vox_shuttle_location = "start"
		if("solars_fore_starboard")
			vox_move_to(/area/vox_station/northeast_solars)
		if("solars_fore_port")
			vox_move_to(/area/vox_station/northwest_solars)
		if("solars_aft_starboard")
			vox_move_to(/area/vox_station/southeast_solars)
		if("solars_aft_port")
			vox_move_to(/area/vox_station/southwest_solars)
		if("mining")
			vox_move_to(/area/vox_station/mining)

	add_fingerprint(user)
	updateUsrDialog()
	return

/obj/machinery/computer/vox_station/bullet_act(var/obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")
