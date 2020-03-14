#define SYNDICATE_SHUTTLE_TRANSIT_DELAY 240
#define SYNDICATE_SHUTTLE_COOLDOWN 200

var/global/datum/shuttle/syndicate/syndicate_shuttle = new(starting_area = /area/syndicate_station/start)

/datum/shuttle/syndicate
	name = "syndicate shuttle"

	cant_leave_zlevel = list() //Nuke disk is allowed

	cooldown = SYNDICATE_SHUTTLE_COOLDOWN

	transit_delay = SYNDICATE_SHUTTLE_TRANSIT_DELAY - 30 //Once somebody sends the shuttle, it waits for 3 seconds before leaving. Transit delay is reduced to compensate for that
	pre_flight_delay = 30

	cooldown = 200

	stable = 1 //Don't stun everyone and don't throw anything when moving
	can_rotate = 0 //Sleepers, body scanners and multi-tile airlocks aren't rotated properly

	req_access = list(access_syndicate)

/datum/shuttle/syndicate/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/syndicate/start)
	add_dock(/obj/docking_port/destination/syndicate/north)
	add_dock(/obj/docking_port/destination/syndicate/northeast)
	add_dock(/obj/docking_port/destination/syndicate/east)
	add_dock(/obj/docking_port/destination/syndicate/southeast)
	add_dock(/obj/docking_port/destination/syndicate/south)
	add_dock(/obj/docking_port/destination/syndicate/southwest)
	add_dock(/obj/docking_port/destination/syndicate/west)
	add_dock(/obj/docking_port/destination/syndicate/northwest)
	add_dock(/obj/docking_port/destination/syndicate/miningoutpost)
	add_dock(/obj/docking_port/destination/syndicate/researchoutpost)
	add_dock(/obj/docking_port/destination/syndicate/commssat)

	set_transit_dock(/obj/docking_port/destination/syndicate/transit)

/datum/shuttle/syndicate/after_flight()
	..()
	if(HOLOMAP_MARKER_SYNDISHUTTLE in holomap_markers)
		var/datum/holomap_marker/updateMarker = holomap_markers[HOLOMAP_MARKER_SYNDISHUTTLE]
		updateMarker.x = current_port.x
		updateMarker.y = current_port.y
		updateMarker.z = current_port.z
		updateMarker.offset_y = -5

/obj/machinery/computer/shuttle_control/syndicate
	icon_state = "syndishuttle"

	light_color = LIGHT_COLOR_RED
	machine_flags = 0 //No screwtoggle because this computer can't be built
	allow_silicons = 0 //no NT robots allowed

/obj/machinery/computer/shuttle_control/syndicate/emag()
	return

/obj/machinery/computer/shuttle_control/syndicate/New() //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	link_to(syndicate_shuttle)
	.=..()

	var/datum/holomap_marker/newMarker = new()
	newMarker.id = HOLOMAP_MARKER_SYNDISHUTTLE
	newMarker.icon = 'icons/holomap_markers_32x32.dmi'
	newMarker.filter = HOLOMAP_FILTER_NUKEOPS
	newMarker.x = x
	newMarker.y = y
	newMarker.z = z
	newMarker.offset_x = -16
	newMarker.offset_y = -25

	holomap_markers[HOLOMAP_MARKER_SYNDISHUTTLE] = newMarker

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/syndicate/start
	areaname = "syndicate outpost"

/obj/docking_port/destination/syndicate/north
	areaname = "north of the station"

/obj/docking_port/destination/syndicate/northeast
	areaname = "north east of the station"

/obj/docking_port/destination/syndicate/east
	areaname = "east of the station"

/obj/docking_port/destination/syndicate/southeast
	areaname = "south east of the station"

/obj/docking_port/destination/syndicate/south
	areaname = "south of the station"

/obj/docking_port/destination/syndicate/southwest
	areaname = "south west of the station"

/obj/docking_port/destination/syndicate/west
	areaname = "west of the station"

/obj/docking_port/destination/syndicate/northwest
	areaname = "north west of the station"

/obj/docking_port/destination/syndicate/commssat
	areaname = "south of the Communications Satellite"

/obj/docking_port/destination/syndicate/researchoutpost
	areaname = "north east of the research outpost"

/obj/docking_port/destination/syndicate/miningoutpost
	areaname = "south of the mining outpost"

/obj/docking_port/destination/syndicate/transit
	areaname = "hyperspace (syndicate shuttle)"
