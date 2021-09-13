/*CONTAINS
- Docking Port
- Shuttle and Destination subtypes
- Docking Lights */

var/global/list/all_docking_ports = list()

/obj/docking_port
	name = "docking port"
	icon = 'icons/obj/structures.dmi'
	icon_state = "docking_shuttle"
	dir = NORTH
	flags = INVULNERABLE //prevents ZAS airflow and probably 1 or 2 other things
	density = 0
	anchored = 1
	invisibility = 60 //Only ghosts can see

	var/require_admin_permission = 0

	var/areaname = "space"

	var/obj/docking_port/docked_with

/obj/docking_port/New()
	.=..()
	all_docking_ports |= src

/obj/docking_port/Destroy()
	.=..()
	all_docking_ports -= src

	undock()

	for(var/datum/shuttle/S in shuttles) //Go through every existing shuttle and remove references
		if(src == S.current_port)
			S.current_port = null
		if(src == S.transit_port)
			S.transit_port = null
		if(src == S.destination_port)
			S.destination_port = null

//just in case
/obj/docking_port/singularity_pull()
	return //we are eternal

/obj/docking_port/singularity_act()
	return //we are eternal

/obj/docking_port/ex_act()
	return //we are eternal

/obj/docking_port/cultify()
	return //we are eternal

/obj/docking_port/shuttle_act(datum/shuttle/S)
	if(istype(src,/obj/docking_port/shuttle))
		var/obj/docking_port/shuttle/D = src
		message_admins("<span class='notice'>WARNING: A shuttle docking port linked to [D.linked_shuttle ? "[D.linked_shuttle.name] ([D.linked_shuttle.type])" : "nothing"] has been destroyed by [S.name] ([S.type]). The linked shuttle will be broken! [formatJumpTo(get_turf(src))]</span>")
	return ..()

/obj/docking_port/proc/link_to_shuttle(var/datum/shuttle/S)
	return

/obj/docking_port/proc/unlink_from_shuttle(var/datum/shuttle/S)
	return

/obj/docking_port/proc/undock()
	if(docked_with)
		if(docked_with.docked_with == src)
			docked_with.docked_with = null
		docked_with = null
		return 1

/obj/docking_port/proc/docked(obj/docking_port/D)
	return

/obj/docking_port/proc/dock(var/obj/docking_port/D)
	undock()

	D.docked_with = src
	src.docked_with = D

	D.docked(src)

/obj/docking_port/proc/get_docking_turf()
	return get_step(get_turf(src),src.dir)

/obj/docking_port/destination/proc/start_warning_lights()
	for(var/obj/machinery/door/airlock/A in range(1,src))
		if(!A.shuttle_warning_lights)
			A.shuttle_warning_lights = image('icons/obj/doors/Doorint.dmi', src, "warning_lights")
		A.overlays += A.shuttle_warning_lights
	for(var/obj/machinery/docklight/D in dockinglights)
		if(D.id_tag == areaname)
			D.triggered = 1
			D.update_icon()

/obj/docking_port/destination/proc/stop_warning_lights()
	for(var/obj/machinery/door/airlock/A in range(1,src))
		if(A.shuttle_warning_lights)
			A.overlays -= A.shuttle_warning_lights
	for(var/obj/machinery/docklight/D in dockinglights)
		if(D.id_tag == areaname)
			D.triggered = 0
			D.update_icon()

//SHUTTLE PORTS

/obj/docking_port/shuttle //this guy is installed on shuttles and connects to obj/docking_port/destination
	icon_state = "docking_shuttle"
	areaname = "shuttle"

	var/datum/shuttle/linked_shuttle

/obj/docking_port/shuttle/Destroy()
	message_admins("<span class='warning'>WARNING: A shuttle docking port (linked to [linked_shuttle ? (linked_shuttle.name) : "nothing"]) has been deleted.</span>")
	if(linked_shuttle)
		unlink_from_shuttle(linked_shuttle)

	..()

/obj/docking_port/shuttle/link_to_shuttle(var/datum/shuttle/S)
	.=..()
	if(linked_shuttle)
		unlink_from_shuttle(linked_shuttle)

	src.linked_shuttle = S
	src.areaname = S.name
	S.linked_port = src

/obj/docking_port/shuttle/unlink_from_shuttle(var/datum/shuttle/S)
	.=..()
	if(!S)
		S = linked_shuttle

	if(linked_shuttle == S)
		linked_shuttle = null

	if(S.linked_port == src)
		S.linked_port = null

	src.areaname = "unassigned docking port"

/obj/docking_port/shuttle/can_shuttle_move(datum/shuttle/S)
	if(S.linked_port == src)
		return 1
	return 0

//DESTINATION PORTS

/obj/docking_port/destination //this guy is installed on stations and connects to shuttles
	icon_state = "docking_station"
	var/turf/origin_turf = null
	var/list/disk_references = list() //List of shuttle destination disks that know about this docking port

	var/base_turf_type			= /turf/space
	var/base_turf_icon			= null
	var/base_turf_icon_state	= null
	var/base_turf_override		= FALSE

	var/refill_area				= null

/obj/docking_port/destination/New()
	.=..()

	origin_turf = get_turf(src)
	//The following few lines exist to make shuttle corners and the syndicate base Less Shit :*
	if(!refill_area)
		var/turf/T = get_step(src,dir)
		var/area/A = get_area(T)
		if(!istype(A,/area/shuttle))
			refill_area = A.type //look at the area we're pointing at, if it's not a shuttle, make it our refill area
	if(base_turf_override)
		return //Allows mappers to manually set base_turf info
	if(src.z in 1 to map.zLevels.len)
		base_turf_type = get_base_turf(src.z)

	var/datum/zLevel/L = get_z_level(src)
	if(istype(L,/datum/zLevel/centcomm)) //If the docking port is at z-level 2 (the one with the transit areas)
		var/turf/T = get_turf(src)
		if(istype(T, /turf/space))	//Placed on space
			base_turf_type = T.type //This ensures that once a shuttle leaves transit, its turfs are replaced with MOVING SPACE instead of STATIC SPACE
		else			//Not placed on space
			var/area/syndicate_mothership/A = get_area(src)
			if(istype(A))
				base_turf_type			= T.type
				base_turf_icon			= T.icon
				base_turf_icon_state	= T.icon_state

/obj/docking_port/destination/Destroy()
	..()

	for(var/obj/item/weapon/disk/shuttle_coords/C in disk_references)
		C.reset()
	disk_references = list()

/obj/docking_port/destination/link_to_shuttle(var/datum/shuttle/S)
	..()
	S.docking_ports |= src

/obj/docking_port/destination/unlink_from_shuttle(var/datum/shuttle/S)
	..()
	S.docking_ports -= src

/obj/docking_port/destination/can_shuttle_move(datum/shuttle/S)
	if(src in S.docking_ports_aboard)
		return 1
	return 0

/obj/docking_port/destination/shuttle_act() //These guys don't get destroyed
	return 0

/obj/docking_port/destination/transit
	areaname = "transit area"
	var/generate_borders = 0

/obj/docking_port/destination/transit/docked(obj/docking_port/shuttle/D)
	.=..()

	if(!istype(D))
		return //Only deal with shuttle docking ports

	if(generate_borders)
		//Generate teleport triggers around the shuttle that prevent players from simply walking out
		//1) Go through every turf in the newly docked shuttle
		//2) Check all adjacent turfs of every turf (maybe this sucks but I haven't thought of a better way to do it)
		//3) Place teleporters as needed

		var/teleporter_typepath = /obj/effect/step_trigger/teleporter/random/shuttle_transit

		var/area/shuttle_area = D.linked_shuttle.linked_area
		for(var/turf/T in shuttle_area)
			for(var/dir in cardinal)
				var/turf/check = get_step(T, dir)
				if(check.loc != shuttle_area) //Turf doesn't belong to a shuttle
					if(!locate(teleporter_typepath) in check)
						new teleporter_typepath(check)

		generate_borders = 0

//SILLY PROC
/proc/select_port_from_list(var/mob/user, var/message="Select a docking port", var/title="Admin abuse", var/list/list) //like input
	if(!list || !user)
		return

	var/list/choices = list("Cancel")
	for(var/obj/docking_port/destination/D in list)
		var/name = "[D.name] ([D.areaname])"
		choices += name
		choices[name] = D

	var/choice = input(user,message,title) as null|anything in choices

	var/obj/docking_port/destination/D = choices[choice]
	if(istype(D))
		return D
	return 0

var/global/list/dockinglights = list()

/obj/machinery/docklight
	name = "docking light"
	desc = "A light designed to warn of dangerous docking conditions. Exercise caution while flashing."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "docklight"
	light_color = LIGHT_COLOR_ORANGE
	machine_flags = MULTITOOL_MENU
	anchored = 1
	var/triggered = 0
	id_tag = "" //Mappers: This should match the areaname of the target destination port.
	//Examples: "main research department", "research outpost", "deep space", "station auxillary docking", "north of the station", etc.

/obj/machinery/docklight/New()
	..()
	dockinglights += src

/obj/machinery/docklight/Destroy()
	dockinglights -= src
	..()

/obj/machinery/docklight/update_icon()
	if(triggered)
		icon_state = "docklight_triggered"
		set_light(2)
	else
		icon_state = "docklight"
		kill_light()

/obj/machinery/docklight/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
	<b>Main</b>
	<ul>
		<li>[format_tag("ID Tag","id_tag")]</li>
	</ul>"}
