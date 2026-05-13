var/global/datum/shuttle/supply/cargo_shuttle = new(starting_area = /area/shuttle/supply)

/datum/shuttle/supply
	name = "supply shuttle"

	var/obj/docking_port/destination/dock_centcom
	var/obj/docking_port/destination/dock_station

	pre_flight_delay = 0
	destroy_everything = 1 //The cargo shuttle should never be cancelled because of something in the way
	cooldown = 0

	stable = 1 //Don't stun everyone and don't throw anything when moving

	// HIDDEN: ship-mode cargo docks via silent dock-request, but operators shouldn't see the supply shuttle as a manual handshake target.
	dockability = SHUTTLE_DOCKING_HIDDEN

/datum/shuttle/supply/is_special()
	return 1

/datum/shuttle/supply/initialize()
	.=..()
	dock_centcom = add_dock(/obj/docking_port/destination/supply/centcom)
	dock_station = add_dock(/obj/docking_port/destination/supply/station)

/obj/docking_port/destination/supply/centcom
	areaname = "centcom loading bay"

/obj/docking_port/destination/supply/station
	areaname = "cargo bay"
