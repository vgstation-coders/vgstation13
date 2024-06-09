//Other shuttles which are less-used or not used at all go here

//ARRIVALS SHUTTLE
/datum/shuttle/arrival
	name = "arrival shuttle"

	cant_leave_zlevel = list() //It's only adminbusable anyways

	cooldown = 0
	linked_area = /area/shuttle/arrival/station
	stable = 1

/datum/shuttle/arrival/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/arrival/station)

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/arrival/station
	areaname = "station arrivals"
	shuttle_type = /datum/shuttle/arrival

//CENTCOM FERRY
var/global/datum/shuttle/transport/transport_shuttle

/datum/shuttle/transport
	name = "centcom ferry"

	cant_leave_zlevel = list() //Bus

	cooldown = 0
	pre_flight_delay = 10
	transit_delay = 0

	stable = 1
	linked_area = /area/shuttle/transport1/centcom
	req_access = list(access_cent_captain)

/datum/shuttle/transport/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/transport/station)
	add_dock(/obj/docking_port/destination/transport/centcom)
	transport_shuttle = src

/obj/machinery/computer/shuttle_control/transport
	machine_flags = 0 //No screwtoggle / emaggable to prevent mortals from fucking with shit
	allow_silicons = 0
	shuttle = /datum/shuttle/transport
	emag_disables_access = FALSE //Can't be emagged to hijack the centcom ferry

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/transport/station
	areaname = "station arrivals (docking port 1)"

/obj/docking_port/destination/transport/centcom
	areaname = "central command"
	require_admin_permission = 1
	shuttle_type = /datum/shuttle/transport

//ERT SHUTTLE
/datum/shuttle/ert
	name = "ert shuttle"

	cant_leave_zlevel = list() //Striketeam

	cooldown = 0
	pre_flight_delay = 10
	transit_delay = 0

	stable = 0
	linked_area = /area/shuttle/ert/centcom
	req_access = list(access_cent_ert)

/datum/shuttle/ert/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/ert/station)
	add_dock(/obj/docking_port/destination/ert/centcom)

/obj/machinery/computer/shuttle_control/ert
	machine_flags = 0 //No screwtoggle / emaggable to prevent mortals from fucking with shit
	allow_silicons = 0
	shuttle = /datum/shuttle/ert
	emag_disables_access = FALSE //Can't be emagged to hijack the ert shuttle

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/ert/station
	areaname = "station arrivals (docking port 2)"

/obj/docking_port/destination/ert/centcom
	areaname = "central command"
	require_admin_permission = 1
	shuttle_type = /datum/shuttle/ert

//DEATHSQUAD SHUTTLE
/datum/shuttle/deathsquad
	name = "deathsquad shuttle"

	cant_leave_zlevel = list() //Striketeam

	cooldown = 0
	pre_flight_delay = 10
	transit_delay = 0
	destroy_everything = 1
	stable = 0
	linked_area = /area/shuttle/specops/centcom
	req_access = list(access_cent_specops)

/datum/shuttle/deathsquad/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/deathsquad/near_station)
	add_dock(/obj/docking_port/destination/deathsquad/in_station)
	add_dock(/obj/docking_port/destination/deathsquad/centcom)

/obj/machinery/computer/shuttle_control/deathsquad
	machine_flags = 0 //No screwtoggle / emaggable to prevent mortals from fucking with shit
	allow_silicons = 0
	shuttle = /datum/shuttle/deathsquad
	emag_disables_access = FALSE //Can't be emagged to hijack the deathsquad shuttle

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/deathsquad/near_station
	areaname = "near the station"

/obj/docking_port/destination/deathsquad/in_station
	areaname = "station arrivals (crashing through)"

/obj/docking_port/destination/deathsquad/centcom
	areaname = "central command"
	require_admin_permission = 1
	shuttle_type = /datum/shuttle/deathsquad

//ELITE SYNDIE SHUTTLE
/datum/shuttle/elite_syndie
	name = "elite syndie shuttle"

	cant_leave_zlevel = list() //Striketeam

	cooldown = 0
	pre_flight_delay = 10
	transit_delay = 0
	destroy_everything = 1
	stable = 0
	linked_area = /area/shuttle/syndicate_elite/mothership
	req_access = list(access_syndicate)

/datum/shuttle/elite_syndie/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/elite_syndie/near_station)
	add_dock(/obj/docking_port/destination/elite_syndie/in_station)
	add_dock(/obj/docking_port/destination/elite_syndie/motherbase)

/obj/machinery/computer/shuttle_control/elite_syndie
	machine_flags = 0 //No screwtoggle / emaggable to prevent mortals from fucking with shit
	allow_silicons = 0
	icon_state = "syndishuttle"
	light_color = LIGHT_COLOR_RED
	shuttle = /datum/shuttle/elite_syndie
	emag_disables_access = FALSE //Can't be emagged to hijack the elite syndie shuttle

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/elite_syndie/near_station
	areaname = "near the station"

/obj/docking_port/destination/elite_syndie/in_station
	areaname = "station arrivals (crashing through)"

/obj/docking_port/destination/elite_syndie/motherbase
	areaname = "syndicate motherbase"
	require_admin_permission = 1
	shuttle_type = /datum/shuttle/elite_syndie

//CUSTOM STRIKE TEAM SHUTTLE
/datum/shuttle/striketeam
	name = "strike team shuttle"

	cant_leave_zlevel = list() //Striketeam

	cooldown = 0
	pre_flight_delay = 10
	transit_delay = 0
	destroy_everything = 1
	stable = 0
	linked_area = /area/shuttle/striketeam/centcom
	req_access = list(access_cent_captain)

/datum/shuttle/striketeam/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/striketeam/destination1)
	add_dock(/obj/docking_port/destination/striketeam/destination2)
	add_dock(/obj/docking_port/destination/striketeam/base)

/obj/machinery/computer/shuttle_control/striketeam
	machine_flags = 0 //No screwtoggle / emaggable to prevent mortals from fucking with shit
	allow_silicons = 0
	icon_state = "syndishuttle"
	light_color = LIGHT_COLOR_RED
	shuttle = /datum/shuttle/striketeam
	emag_disables_access = FALSE //Can't be emagged to hijack the strike team shuttle

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/striketeam/destination1
	areaname = "destination 1"

/obj/docking_port/destination/striketeam/destination2
	areaname = "destination 2"

/obj/docking_port/destination/striketeam/base
	areaname = "base"
	require_admin_permission = 1
	shuttle_type = /datum/shuttle/striketeam

//ADMIN SHUTTLE
var/global/datum/shuttle/admin/admin_shuttle
/datum/shuttle/admin
	name = "admin shuttle"

	cant_leave_zlevel = list() //Bus

	cooldown = 0
	pre_flight_delay = 10
	transit_delay = 0

	stable = 1
	linked_area = /area/shuttle/administration/centcom
	req_access = list(access_cent_captain)

/datum/shuttle/admin/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/admin/centcom)
	add_dock(/obj/docking_port/destination/salvage/arrivals) //We share a docking port with the salvage shuttle - this should turn out fine
	admin_shuttle = src

/obj/docking_port/destination/admin/centcom
	areaname = "centcom hangar bay"
	require_admin_permission = 1
	shuttle_type = /datum/shuttle/admin

/obj/machinery/computer/shuttle_control/admin_shuttle
	machine_flags = 0 //No screwtoggle / emaggable to prevent mortals from fucking with shit
	allow_silicons = 0
	shuttle = /datum/shuttle/admin
	emag_disables_access = FALSE //Can't be emagged to hijack the centcom ferry
