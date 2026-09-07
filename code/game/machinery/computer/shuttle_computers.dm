//Docking port disks
//Insert into a shuttle computer to unlock a new destination
/obj/item/weapon/disk/shuttle_coords
	name = "shuttle destination disk"
	desc = "A small disk containing encrypted coordinates and tracking data."
	icon = 'icons/obj/datadisks.dmi'
	icon_state = "disk_shuttle"

	var/obj/docking_port/destination/destination //Docking port linked to this disk.
	//If this variable contains a path like (/obj/structure/docking_port/destination/my_dungeon), the disk will find a destination docking port of that type and automatically link to it
	//See example below

	var/header = "SDC Data Disk" //Name of the disk, shown on the console. SDC stands Shuttle Destination Coordinates

	var/list/allowed_shuttles = list() //List of allowed shuttles. Accepts paths (for example /datum/shuttle/arrival). If empty, all shuttles are allowed
	starting_materials = list(MAT_GLASS = 1250)

//Example:
/obj/item/weapon/disk/shuttle_coords/station_arrivals
	destination = /obj/docking_port/destination/transport/station
	header = "station arrivals"

/obj/item/weapon/disk/shuttle_coords/station_auxillary
	name = "auxillary docking disk"
	header = "station auxillary docking"
	destination = /obj/docking_port/destination/salvage/arrivals
	allowed_shuttles = list(/datum/shuttle/custom)

/obj/item/weapon/disk/shuttle_coords/disk_jockey
	name = "Russian propaganda station destination disk"
	header = "DJ station"
	destination = /obj/docking_port/destination/salvage/dj
	starting_materials = list(MAT_GLASS = 1250, MAT_GOLD = 1250)

/obj/item/weapon/disk/shuttle_coords/vault
	allowed_shuttles = list(/datum/shuttle/mining, /datum/shuttle/research, /datum/shuttle/security)

///obj/item/weapon/disk/shuttle_coords/vault/random -> leads to a random vault with a docking port!
/obj/item/weapon/disk/shuttle_coords/vault/random/initialize()
	var/list/L = list()
	for(var/obj/docking_port/destination/vault/V in all_docking_ports)
		if(!V.valid_random_destination)
			continue
		L.Add(V)

	if(L.len)
		destination = pick(L)

	..()

	if(!destination)
		name = "blank shuttle destination disk"
		desc = "A small disk containing nothing."

//This disk will link to station's arrivals when spawned

/obj/item/weapon/disk/shuttle_coords/New()
	..()

	if(ticker)
		initialize()

/obj/item/weapon/disk/shuttle_coords/initialize()
	if(ispath(destination))
		spawn()
			destination = locate(destination) in all_docking_ports
			if(destination)
				destination.disk_references.Add(src)
	else
		header = "ERROR"

/obj/item/weapon/disk/shuttle_coords/Destroy()
	// If a disk is destroyed before initialize() runs, `destination` could
	// be a type path instead of an instance.
	if(istype(destination))
		destination.disk_references.Remove(src)
		destination = null

	..()

/obj/item/weapon/disk/shuttle_coords/proc/compatible(datum/shuttle/S)
	if(!allowed_shuttles.len)
		return TRUE

	return is_type_in_list(S, allowed_shuttles)

/obj/item/weapon/disk/shuttle_coords/proc/reset()
	destination = null
	header = "ERROR"

/obj/item/weapon/disk/shuttle_coords/free_move
	name = "shuttle free-movement driver"
	desc = "This disk contains a piece of software which converts coordinates into subspace trajectories, which shuttle computers are able to use."
	header = "FREE-MOVE DRIVER"

/obj/item/weapon/disk/shuttle_coords/free_move/initialize()
	..()
	header = initial(header)

/obj/item/weapon/disk/shuttle_coords/procedural
	name = "planetary destination disk"
	desc = "A disk containing coordinates to a recently discovered planet."
	header = "PLANETARY LANDING"
	var/datum/planet_type/planet_ref
	var/datum/encounter/encounter_ref

/obj/docking_port/destination/coord //Specific subtype to hunt for when doing cleanup

/obj/item/weapon/card/shuttle_pass
	name = "shuttle pass"
	desc = "A one-use shuttle activation pass, for limited access to high-security transportation."
	icon_state = "data"
	item_state = "card-id"
	var/obj/docking_port/destination/destination
	var/allowed_shuttle

/obj/item/weapon/card/shuttle_pass/New()
	..()
	if(ticker)
		initialize()

/obj/item/weapon/card/shuttle_pass/initialize()
	if(ispath(destination))
		spawn()
			destination = locate(destination) in all_docking_ports

/obj/item/weapon/card/shuttle_pass/Destroy()
	destination = null
	..()

/obj/item/weapon/card/shuttle_pass/ert
	name = "\improper ERT shuttle pass"
	destination = /obj/docking_port/destination/transport/station
	allowed_shuttle = /datum/shuttle/transport

#define MAX_SHUTTLE_NAME_LEN

var/list/shuttle_control_themes = list(
	"retro_green",
	"retro",
	"ntos",
	"ntos_darkmode",
	"ntos_lightmode",
	"ntos_terminal",
	"ntos_synth",
	"ntos_cat",
	"ntos_spooky",
	"ntOS95",
	"neutral",
	"admin",
	"syndicate",
	"abductor",
	"hackerman",
	"malfunction",
	"paper",
	"cardtable",
	"spookyconsole",
	"wizard",
)

/obj/machinery/computer/shuttle_control
	name = "shuttle console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	req_access = null
	circuit = "/obj/item/weapon/circuitboard/shuttle_control"

	machine_flags = EMAGGABLE | SCREWTOGGLE | WRENCHMOVE

	light_color = LIGHT_COLOR_BLUE

	var/theme = "retro_green"

	var/datum/shuttle/shuttle

	var/obj/docking_port/selected_port

	var/allow_selecting_all = 0 //if 1, allow selecting ALL ports, not only those of linked shuttle
								//only abusable by admins

	var/allow_silicons = 1		//If 0, AIs and cyborgs can't use this computer
								//used for admin-only shuttles so that borgs cant hijack 'em

	var/obj/item/weapon/disk/shuttle_coords/disk

	//Variables used for custom destinations
	var/custom_x = 0
	var/custom_y = 0
	var/custom_z = 0
	var/custom_rot = 0

	// For landing on procgen planets
	var/procgen_target

/obj/machinery/computer/shuttle_control/New()
	if(shuttle)
		name = "[shuttle.name] console"

	.=..()

/obj/machinery/computer/shuttle_control/Destroy()
	if(disk)
		QDEL_NULL(disk)

	..()

/obj/machinery/computer/shuttle_control/proc/announce(var/message)
	return say(message)

/obj/machinery/computer/shuttle_control/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/disk/shuttle_coords))
		insert_disk(O, user)

	if(istype(O, /obj/item/weapon/card/shuttle_pass))
		use_pass(O, user)

	if(istype(O,/obj/item/device/shuttle_holopainter))
		if(do_after(user, src, 1 SECONDS, needhand = TRUE))
			shuttle.update_appearance(O, user)
			if(O.emagged)
				playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
				visible_message("<span class='notice'>\The [O] honks pensively.</span>", user)
	..()

/obj/machinery/computer/shuttle_control/attack_hand(mob/user as mob)
	if(..(user))
		return
	if(issilicon(user) && !allow_silicons)
		to_chat(user, "<span class='notice'>There seems to be a firewall preventing you from accessing this device.</span>")
		return
	user.set_machine(src)
	add_fingerprint(user)
	tgui_interact(user)

/obj/machinery/computer/shuttle_control/tgui_interact(mob/user, datum/tgui/ui)
	if(selected_port && !selected_port.loc)
		selected_port = null
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ShuttleControl", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/shuttle_control/ui_state(mob/user)
	return default_state

/obj/machinery/computer/shuttle_control/ui_data(mob/user)
	var/list/data = list()
	data["theme"] = theme
	data["themes"] = shuttle_control_themes
	data["can_change_theme"] = has_theme_access(user)
	data["admin"] = list(
		"visible" = isAdminGhost(user),
		"allow_selecting_all" = allow_selecting_all,
		"allow_silicons" = allow_silicons,
	)

	if(!shuttle)
		data["no_shuttle"] = TRUE
		data["shuttle_name"] = null
		data["status"] = "no_shuttle"
		data["lockdown"] = list("active" = FALSE, "reason" = null)
		data["in_transit"] = list("active" = FALSE, "dest_name" = null)
		data["progress"] = list("phase" = "no_shuttle", "label" = "No Shuttle", "value" = 0, "remaining_s" = null)
		data["destinations"] = list()
		data["selected_ref"] = null
		data["procgen_selected"] = null
		data["disk"] = disk_payload()
		return data

	data["no_shuttle"] = FALSE
	data["shuttle_name"] = shuttle.name

	if(selected_port && !selected_port.loc)
		selected_port = null

	var/status
	if(shuttle.lockdown)
		status = "lockdown"
		data["lockdown"] = list(
			"active" = TRUE,
			"reason" = istext(shuttle.lockdown) ? shuttle.lockdown : null,
		)
	else
		data["lockdown"] = list("active" = FALSE, "reason" = null)
		if(!shuttle.linked_area)
			status = "unlinked"
		else if(shuttle.moving)
			var/pre_flight = shuttle.pre_flight_delay
			var/elapsed = world.time - shuttle.last_moved
			if(pre_flight > 0 && elapsed < pre_flight)
				status = "warmup"
			else
				status = "transit"
		else if(max(shuttle.last_moved + shuttle.cooldown - world.time, 0))
			status = "cooldown"
		else
			status = "ready"

	data["status"] = status
	data["in_transit"] = list(
		"active" = !!shuttle.moving,
		"dest_name" = shuttle.destination_port ? shuttle.destination_port.areaname : null,
	)
	data["progress"] = progress_payload(status)
	data["destinations"] = destinations_payload()
	data["selected_ref"] = selected_port ? "\ref[selected_port]" : null
	data["procgen_selected"] = procgen_target
	data["disk"] = disk_payload()

	return data

/obj/machinery/computer/shuttle_control/proc/progress_payload(status)
	var/list/p = list(
		"phase" = status,
		"label" = "",
		"value" = 0,
		"remaining_s" = null,
	)
	if(!shuttle)
		p["label"] = "No Shuttle"
		return p

	switch(status)
		if("ready")
			p["label"] = "Ready"
			p["value"] = 1
		if("lockdown")
			p["label"] = "Lockdown"
		if("unlinked")
			p["label"] = "Unlinked Area"
		if("warmup")
			var/pre_flight = shuttle.pre_flight_delay
			var/elapsed = world.time - shuttle.last_moved
			var/dest = shuttle.destination_port ? shuttle.destination_port.areaname : "destination"
			p["label"] = "Warming Up for [dest]"
			p["value"] = pre_flight ? min(elapsed / pre_flight, 1) : 1
			p["remaining_s"] = round(max(pre_flight - elapsed, 0) / 10)
		if("transit")
			var/pre_flight = shuttle.pre_flight_delay
			var/transit_total = shuttle.transit_delay
			var/elapsed_transit = max(world.time - shuttle.last_moved - pre_flight, 0)
			var/dest = shuttle.destination_port ? shuttle.destination_port.areaname : "destination"
			p["label"] = "In Transit to [dest]"
			p["value"] = transit_total ? min(elapsed_transit / transit_total, 1) : 1
			p["remaining_s"] = round(max(transit_total - elapsed_transit, 0) / 10)
		if("cooldown")
			var/cd_remaining = max(shuttle.last_moved + shuttle.cooldown - world.time, 0)
			p["label"] = "Engines Cooling Down"
			p["value"] = shuttle.cooldown ? 1 - (cd_remaining / shuttle.cooldown) : 1
			p["remaining_s"] = round(cd_remaining / 10)
	return p

/obj/machinery/computer/shuttle_control/proc/destinations_payload()
	var/list/out = list()
	if(!shuttle)
		return out

	var/list/seen = list()
	var/list/ports
	if(allow_selecting_all)
		ports = all_docking_ports
	else
		ports = shuttle.docking_ports

	// Track which procedural disk targets already have a persisted port, to avoid duplicate listings
	var/datum/virtual_z/disk_target_vz = null
	if(istype(disk, /obj/item/weapon/disk/shuttle_coords/procedural))
		var/obj/item/weapon/disk/shuttle_coords/procedural/proc_disk = disk
		if(proc_disk.planet_ref)
			disk_target_vz = proc_disk.planet_ref.v
		else if(proc_disk.encounter_ref)
			disk_target_vz = proc_disk.encounter_ref.v

	var/persisted_disk_target = FALSE
	for(var/obj/docking_port/destination/D in ports)
		if(disk_target_vz && D.get_virtual_z() == disk_target_vz)
			persisted_disk_target = TRUE
		out += list(list(
			"ref" = "\ref[D]",
			"name" = capitalize(D.areaname),
			"in_use" = !!D.docked_with,
			"kind" = allow_selecting_all ? "all" : "shuttle",
			"category" = port_category(D),
		))
		seen[D] = TRUE

	if(disk && disk.destination && !seen[disk.destination])
		if(disk.compatible(shuttle))
			out += list(list(
				"ref" = "\ref[disk.destination]",
				"name" = capitalize(disk.destination.areaname),
				"in_use" = !!disk.destination.docked_with,
				"kind" = "disk",
				"category" = port_category(disk.destination),
			))

	// Only surface the procedural disk's virtual destination if we don't already have a persisted port for it
	if(istype(disk, /obj/item/weapon/disk/shuttle_coords/procedural) && !persisted_disk_target)
		var/obj/item/weapon/disk/shuttle_coords/procedural/proc_disk = disk
		if(proc_disk.compatible(shuttle))
			if(proc_disk.planet_ref)
				out += list(list(
					"ref" = "procgen_planet",
					"name" = "[proc_disk.planet_ref.planet_name] Landing",
					"in_use" = FALSE,
					"kind" = "procedural",
					"procgen_key" = proc_disk.planet_ref.planet_name,
					"category" = "Planets",
				))
			else if(proc_disk.encounter_ref)
				out += list(list(
					"ref" = "procgen_encounter",
					"name" = proc_disk.encounter_ref.encounter_name,
					"in_use" = FALSE,
					"kind" = "procedural",
					"procgen_key" = proc_disk.encounter_ref.encounter_name,
					"category" = "Space",
				))

	return out

/obj/machinery/computer/shuttle_control/proc/has_theme_access(mob/user)
	if(isAdminGhost(user))
		return TRUE
	var/obj/item/weapon/card/id/card = user.get_id_card()
	if(card && (access_captain in card.access))
		return TRUE
	return FALSE

/obj/machinery/computer/shuttle_control/proc/port_category(obj/docking_port/destination/D)
	if(!D)
		return "Other"
	var/datum/virtual_z/vz = D.get_virtual_z()
	if(!vz)
		return "Other"
	switch(vz.level_type)
		if(VZ_PLANET)
			return "Planets"
		if(VZ_SPACE)
			return "Space"
		if(VZ_PARKING)
			return "Parking"
		if(VZ_PROTECTED)
			return "Restricted"
		if(VZ_TRANSIT)
			return "Transit"
	return "Other"

/obj/machinery/computer/shuttle_control/proc/disk_payload()
	var/list/d = list(
		"present" = FALSE,
		"header" = "",
		"kind" = "none",
		"destination_name" = null,
		"compatible" = TRUE,
		"freemove" = null,
		"procedural" = null,
		"procedural_error" = FALSE,
	)

	if(!disk)
		return d

	d["present"] = TRUE
	d["header"] = disk.header
	d["compatible"] = shuttle ? disk.compatible(shuttle) : TRUE
	d["destination_name"] = disk.destination ? capitalize(disk.destination.areaname) : null

	if(istype(disk, /obj/item/weapon/disk/shuttle_coords/free_move))
		d["kind"] = "freemove"
		d["freemove"] = list(
			"x" = custom_x,
			"y" = custom_y,
			"z" = custom_z,
			"rot" = custom_rot,
		)
	else if(istype(disk, /obj/item/weapon/disk/shuttle_coords/procedural))
		d["kind"] = "procedural"
		var/obj/item/weapon/disk/shuttle_coords/procedural/proc_disk = disk
		if(proc_disk.planet_ref)
			d["procedural"] = list("name" = proc_disk.planet_ref.planet_name, "kind" = "planet")
		else if(proc_disk.encounter_ref)
			d["procedural"] = list("name" = proc_disk.encounter_ref.encounter_name, "kind" = "encounter")
		else
			d["procedural_error"] = TRUE
	else
		d["kind"] = "standard"

	return d

/obj/machinery/computer/shuttle_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(issilicon(usr) && !allow_silicons)
		to_chat(usr, "<span class='notice'>There seems to be a firewall preventing you from accessing this device.</span>")
		return TRUE

	add_fingerprint(usr)

	switch(action)
		if("select")
			if(!allowed(usr))
				to_chat(usr, "<span class='red'>Access denied.</span>")
				return TRUE
			var/obj/docking_port/A = locate(params["ref"]) in all_docking_ports
			if(!A)
				return TRUE
			selected_port = A
			procgen_target = null
			return TRUE
		if("select_procedural")
			if(!allowed(usr))
				to_chat(usr, "<span class='red'>Access denied.</span>")
				return TRUE
			if(istype(disk, /obj/item/weapon/disk/shuttle_coords/procedural))
				var/obj/item/weapon/disk/shuttle_coords/procedural/proc_disk = disk
				if(proc_disk.planet_ref)
					procgen_target = proc_disk.planet_ref.planet_name
				else if(proc_disk.encounter_ref)
					procgen_target = proc_disk.encounter_ref.encounter_name
				selected_port = null
			return TRUE
		if("send")
			if(!allowed(usr))
				to_chat(usr, "<span class='red'>Access denied.</span>")
				return TRUE
			try_move(usr)
			return TRUE
		if("scan")
			handle_scan(usr)
			return TRUE
		if("insert_disk")
			var/obj/item/weapon/disk/shuttle_coords/D = usr.get_active_hand()
			insert_disk(D, usr)
			return TRUE
		if("eject_disk")
			if(!disk)
				return TRUE
			disk.forceMove(get_turf(src))
			usr.put_in_hands(disk)
			to_chat(usr, "<span class='info'>You eject \the [disk] from \the [src].</span>")
			if(disk.destination == selected_port)
				selected_port = null
			procgen_target = null
			disk = null
			return TRUE
		if("set_coord")
			var/value = text2num(params["value"])
			if(isnull(value))
				return TRUE
			switch(params["axis"])
				if("x")
					custom_x = value
				if("y")
					custom_y = value
				if("z")
					custom_z = value
				if("a")
					custom_rot = value
			return TRUE
		if("calculate_course")
			calculate_freemove_course(usr)
			return TRUE
		if("link_shuttle")
			handle_link_shuttle(usr, FALSE)
			return TRUE
		if("link_shuttle_admin")
			if(!isAdminGhost(usr))
				return TRUE
			handle_link_shuttle(usr, TRUE)
			return TRUE
		if("unlink_shuttle_admin")
			if(!isAdminGhost(usr))
				return TRUE
			shuttle = null
			return TRUE
		if("toggle_lockdown")
			if(!isAdminGhost(usr) || !shuttle)
				return TRUE
			handle_toggle_lockdown(usr)
			return TRUE
		if("toggle_select_all")
			if(!isAdminGhost(usr))
				return TRUE
			allow_selecting_all = !allow_selecting_all
			return TRUE
		if("toggle_silicons")
			if(!isAdminGhost(usr))
				return TRUE
			allow_silicons = !allow_silicons
			return TRUE
		if("reset_shuttle")
			if(!isAdminGhost(usr) || !shuttle)
				return TRUE
			shuttle.initialize()
			to_chat(usr, "Shuttle's list of travel destinations has been reset")
			return TRUE
		if("set_theme")
			if(!has_theme_access(usr))
				return TRUE
			var/new_theme = params["theme"]
			if(new_theme in shuttle_control_themes)
				theme = new_theme
			return TRUE

/obj/machinery/computer/shuttle_control/proc/handle_scan(mob/user)
	if(!shuttle || !shuttle.linked_area)
		return
	if(!allowed(user))
		to_chat(user, "<span class='red'>Access denied.</span>")
		return

	var/list/ports = list()
	for(var/obj/docking_port/shuttle/S in shuttle.shuttle_contents())
		var/portname = capitalize(S.areaname)
		ports += portname
		ports[portname] = S

	if(!ports.len)
		to_chat(user, "No docking ports found.")
		return

	var/choice = input("Select a docking port to link this shuttle to","Shuttle maintenance") in ports
	if(!Adjacent(user) && !isAdminGhost(user) && !isAI(user))
		return
	var/obj/docking_port/shuttle/S = ports[choice]
	if(S)
		S.link_to_shuttle(shuttle)
		to_chat(user, "Successfully linked [capitalize(shuttle.name)] to the port.")
		SStgui.update_uis(src)

/obj/machinery/computer/shuttle_control/proc/calculate_freemove_course(mob/user)
	if(!istype(disk, /obj/item/weapon/disk/shuttle_coords/free_move))
		return
	if(!shuttle || !shuttle.linked_port)
		return
	var/turf/dest = locate(\
		shuttle.linked_port.x + custom_x,\
		shuttle.linked_port.y + custom_y,\
		shuttle.linked_port.z + custom_z\
	)
	if(!dest || dest.z == map.zCentcomm || (!istype(dest, /turf/space) && !shuttle.destroy_everything))
		to_chat(user, "Error! Bad coordinates.")
		return
	if(istype(disk.destination, /obj/docking_port/destination/coord))
		if(shuttle.current_port == disk.destination)
			shuttle.current_port = null
		QDEL_NULL(disk.destination)
	disk.destination = new /obj/docking_port/destination/coord(dest)
	disk.destination.dir = angle2dir( dir2angle(shuttle.linked_port.dir) + custom_rot + 180)
	disk.destination.areaname = "COURSE:[time2text(world.timeofday, "MM:DD")]:[game_year]:[worldtime2text()]"
	to_chat(user, "Destination calculated!")

/obj/machinery/computer/shuttle_control/proc/handle_link_shuttle(mob/user, admin_mode)
	if(!admin_mode && !allowed(user))
		to_chat(user, "<span class='red'>Access denied.</span>")
		return
	var/list/L = list()
	var/area/this_area = get_area(src)
	for(var/datum/shuttle/S in shuttles)
		var/sname
		if(S.can_link_to_computer == LINK_FORBIDDEN)
			continue
		else if(S.can_link_to_computer == LINK_FREE || this_area.get_shuttle() == S)
			sname = S.name
		else if(S.password)
			sname = "[S.name] (requires password)"
		else
			continue
		L += sname
		L[sname] = S

	var/choice = input(user, "Select a shuttle to link this computer to", admin_mode ? "Admin abuse" : "Shuttle control console") as null|anything in L
	if(!admin_mode && !Adjacent(user) && !isAdminGhost(user) && !isAI(user))
		return
	if(!(L[choice] && istype(L[choice], /datum/shuttle)))
		return

	var/datum/shuttle/S = L[choice]

	if(admin_mode)
		shuttle = S
		SStgui.update_uis(src)
		return

	if(S.password)
		var/password_attempt = input(user, "Please input [capitalize(S.name)]'s interface password:", "Shuttle control console", 00000) as num
		if(!Adjacent(user) && !isAdminGhost(user) && !isAI(user))
			return
		if(S.password != password_attempt)
			return
		shuttle = S
	else if(S.can_link_to_computer == LINK_FORBIDDEN)
		return
	else
		link_to(S)
	to_chat(user, "Successfully linked [src] to [capitalize(S.name)]!")
	SStgui.update_uis(src)

/obj/machinery/computer/shuttle_control/proc/handle_toggle_lockdown(mob/user)
	if(!shuttle.lockdown)
		var/choice = input(user, "Would you like to specify a reason?", "Admin abuse") in list("Yes", "No", "Cancel")
		if(choice == "Cancel")
			return
		shuttle.lockdown = 1
		if(choice == "Yes")
			shuttle.lockdown = input(user, "Please write a reason for locking the [capitalize(shuttle.name)] down.", "Admin abuse")
	else
		shuttle.lockdown = 0
	SStgui.update_uis(src)

/// Only pass `user` if the mob is directly interacting through the UI.
/obj/machinery/computer/shuttle_control/proc/try_move(mob/user)
	if(!shuttle)
		if(user)
			to_chat(user, "<span class='warning'>No shuttle detected.</span>")
		return

	// Land on a planet or travel to an encounter
	if(procgen_target && istype(disk, /obj/item/weapon/disk/shuttle_coords/procedural))
		var/obj/item/weapon/disk/shuttle_coords/procedural/proc_disk = disk
		if(proc_disk.planet_ref)
			travel_to_planet(proc_disk.planet_ref, user)
			return
		else if(proc_disk.encounter_ref)
			travel_to_encounter(proc_disk.encounter_ref, user)
			return

	if(!selected_port && shuttle.docking_ports.len >= 2)
		selected_port = pick(shuttle.docking_ports - shuttle.current_port)

	if(istype(selected_port, /obj/docking_port/destination/planet_surface))
		var/obj/docking_port/destination/planet_surface/surface_port = selected_port
		var/datum/virtual_z/vz = surface_port.get_virtual_z()

		// Reuse existing transit port if valid, otherwise create a new one
		var/obj/docking_port/destination/transit/transit_port = shuttle.transit_port
		if(!transit_port)
			transit_port = generate_transit_area(shuttle)
			shuttle.set_transit_dock(transit_port)
		if(transit_port)
			transit_port.areaname = "transit to [vz?.planet?.planet_name]" || "planet surface"
			transit_port.generate_borders = 1

	//Send a message to the shuttle to move
	shuttle.travel_to(selected_port, src, user)

	selected_port = null
	procgen_target = null
	updateUsrDialog()

/obj/machinery/computer/shuttle_control/proc/travel_to_planet(datum/planet_type/planet, mob/user)
	if(!(planet?.v))
		to_chat(user, "<span class='warning'>Planet data unavailable.</span>")
		return

	var/list/shuttle_size = shuttle.get_size()
	if(!shuttle_size)
		to_chat(user, "<span class='warning'>Unable to determine shuttle dimensions.</span>")
		return

	if(istype(shuttle.current_port, /obj/docking_port/destination/planet_surface))
		var/datum/virtual_z/vz = shuttle.current_port.get_virtual_z()
		if(vz == planet.v)
			to_chat(user, "<span class='warning'>The shuttle is already on [planet.planet_name].</span>")
			return

	// Get or create a landing zone for this shuttle
	var/obj/docking_port/destination/planet_surface/surface_port = planet.v.get_shuttle_landing_zone(shuttle, shuttle_size)
	if(!surface_port)
		to_chat(user, "<span class='warning'>No suitable landing zone found on [planet.planet_name].</span>")
		return

	// Persist the landing zone on the shuttle so it remains selectable after the disk is removed
	surface_port.link_to_shuttle(shuttle)

	// Set the disk's destination to the surface port for validation purposes
	if(istype(disk, /obj/item/weapon/disk/shuttle_coords/procedural))
		var/obj/item/weapon/disk/shuttle_coords/procedural/proc_disk = disk
		proc_disk.destination = surface_port

	// Reuse existing transit port if valid, otherwise create a new one
	var/obj/docking_port/destination/transit/transit_port = shuttle.transit_port
	if(!transit_port)
		transit_port = generate_transit_area(shuttle)
		if(!transit_port)
			to_chat(user, "<span class='warning'>Failed to create transit area.</span>")
			return
		shuttle.set_transit_dock(transit_port)
	transit_port.areaname = "transit to [planet.planet_name]"
	transit_port.generate_borders = 1

	shuttle.travel_to(surface_port, src, user)

/obj/machinery/computer/shuttle_control/proc/travel_to_encounter(datum/encounter/encounter, mob/user)
	if(!(encounter?.v))
		to_chat(user, "<span class='warning'>Encounter data unavailable.</span>")
		return

	var/obj/docking_port/destination/dock = encounter.get_shuttle_docking_port(shuttle)
	if(!dock)
		to_chat(user, "<span class='warning'>Unable to find a safe approach vector for this shuttle.</span>")
		return

	// Persist the encounter dock on the shuttle so it remains selectable after the disk is removed
	dock.link_to_shuttle(shuttle)

	if(istype(disk, /obj/item/weapon/disk/shuttle_coords/procedural))
		var/obj/item/weapon/disk/shuttle_coords/procedural/proc_disk = disk
		proc_disk.destination = dock

	var/obj/docking_port/destination/transit/transit_port = shuttle.transit_port
	if(!transit_port)
		transit_port = generate_transit_area(shuttle)
		if(!transit_port)
			to_chat(user, "<span class='warning'>Failed to create transit area.</span>")
			return
		shuttle.set_transit_dock(transit_port)
	transit_port.areaname = "transit to [encounter.encounter_name]"
	transit_port.generate_borders = 1

	shuttle.travel_to(dock, src, user)

/obj/machinery/computer/shuttle_control/proc/insert_disk(obj/item/weapon/disk/shuttle_coords/SC, mob/user)
	if(!shuttle)
		to_chat(user, "<span class='info'>\The [src] is unresponsive.</span>")
		return

	if(!istype(SC))
		if(istype(SC, /obj/item/weapon/disk)) //It's a disk, but not a compactible one
			to_chat(user, "<span class='info'>The disk is rejected by \the [src].</span>")

		return

	if(disk)
		//An old disk is already inserted.
		to_chat(user, "<span class='warning'>The old [disk.name] pops out of the disk slot!</span>")
		disk.forceMove(loc)
		procgen_target = null
		disk = null

	if(user.drop_item(SC, src))
		disk = SC
		to_chat(user, "<span class='info'>You insert \the [SC] into \the [src].</span>")
		updateUsrDialog()

/obj/machinery/computer/shuttle_control/proc/use_pass(obj/item/weapon/card/shuttle_pass/P, mob/user)
	if(!istype(P))
		return

	if(user.drop_item(P, src))
		if(shuttle && shuttle.type == P.allowed_shuttle)
			if(shuttle.travel_to(P.destination, src, user))
				to_chat(user, "<span class='info'>You insert \the [P] into \the [src].</span>")
				qdel(P)
				return
		to_chat(user, "<span class='info'>You insert \the [P] into \the [src], but it is rejected.</span>")
		user.put_in_hands(P)

/obj/machinery/computer/shuttle_control/kick_act(mob/user)
	..()
	if(is_operational() && (user ? user.lucky_prob(5, luckfactor = 1/5) : prob(5)))
		try_move()

/obj/machinery/computer/shuttle_control/emp_act(severity)
	if(is_operational() && prob(50))
		try_move()

/obj/machinery/computer/shuttle_control/bullet_act(var/obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")
	return ..() // Nothing happens (?)

/obj/machinery/computer/shuttle_control/proc/link_to(var/datum/shuttle/S, var/add_to_list = 1)
	if(shuttle)
		if(src in shuttle.control_consoles)
			shuttle.control_consoles -= src

	shuttle = S
	if(add_to_list)
		shuttle.control_consoles |= src
	req_access = shuttle.req_access
	updateUsrDialog()

/obj/machinery/computer/shuttle_control/emag_act(mob/user as mob)
	..()
	req_access = list()
	if(user)
		to_chat(user, "You disable the console's access requirement.")

#undef MAX_SHUTTLE_NAME_LEN
