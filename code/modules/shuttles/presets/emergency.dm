var/global/datum/shuttle/escape/escape_shuttle = new(starting_area=/area/shuttle/escape/centcom)

/datum/shuttle/escape
	name = "emergency shuttle"

	cant_leave_zlevel = list()

	cooldown = 0 //It's handled by the emergency shuttle controller and doesn't need a cooldown
	transit_delay = 100 //This has NO effect outside of adminbus
	pre_flight_delay = 30 //This has NO effect outside of adminbus

	stable = 0
	can_rotate = 0 //Sleepers, body scanners and multi-tile airlocks aren't rotated properly

	destroy_everything = 1 //Can't stop us

	var/obj/docking_port/destination/dock_centcom
	var/obj/docking_port/destination/dock_station

/datum/shuttle/escape/is_special()
	return 1

/datum/shuttle/escape/initialize()
	.=..()
	dock_station = add_dock(/obj/docking_port/destination/escape/shuttle/station)
	dock_centcom = add_dock(/obj/docking_port/destination/escape/shuttle/centcom)

	set_transit_dock(/obj/docking_port/destination/escape/shuttle/transit)

//code/game/objects/structures/docking_port.dm

/obj/docking_port/destination/escape/shuttle/station
	areaname = "escape shuttle docking"

/obj/docking_port/destination/escape/shuttle/centcom
	areaname = "central command"

/obj/docking_port/destination/escape/shuttle/transit
	areaname = "hyperspace (emergency shuttle)"

//pods later
/* why tho
/obj/docking_port/destination/escape/pod1/station
	areaname = "escape shuttle docking"

/obj/docking_port/destination/escape/pod1/centcom
	areaname = "central command"
*/

/datum/shuttle/escape/pod
	name = "Escape pod"

	can_rotate = 1

/datum/shuttle/escape/pod/initialize()
	.=..()
	emergency_shuttle.escape_pods.Add(src)


var/global/datum/shuttle/escape/pod/one/EP1 = new(starting_area=/area/shuttle/escape_pod1)

var/global/datum/shuttle/escape/pod/two/EP2 = new(starting_area=/area/shuttle/escape_pod2)

var/global/datum/shuttle/escape/pod/three/EP3 = new(starting_area=/area/shuttle/escape_pod3)

var/global/datum/shuttle/escape/pod/four/EP4 = new(starting_area=/area/shuttle/escape_pod4)

var/global/datum/shuttle/escape/pod/five/EP5 = new(starting_area=/area/shuttle/escape_pod5)

/datum/shuttle/escape/pod/one/name = "Escape pod 1"

/datum/shuttle/escape/pod/one/initialize()
	.=..()
	dock_centcom = add_dock(/obj/docking_port/destination/pod1/centcom)
	dock_station = add_dock(/obj/docking_port/destination/pod1/station)

	set_transit_dock(/obj/docking_port/destination/pod1/transit)

/obj/docking_port/destination/pod1/centcom
	areaname = "central command"

/obj/docking_port/destination/pod1/station
	areaname = "station dock"

/obj/docking_port/destination/pod1/transit
	areaname = "hyperspace (pod 1)"

/datum/shuttle/escape/pod/two/name = "Escape pod 2"

/datum/shuttle/escape/pod/two/initialize()
	.=..()
	dock_centcom = add_dock(/obj/docking_port/destination/pod2/centcom)
	dock_station = add_dock(/obj/docking_port/destination/pod2/station)

	set_transit_dock(/obj/docking_port/destination/pod2/transit)

/obj/docking_port/destination/pod2/centcom
	areaname = "central command"

/obj/docking_port/destination/pod2/station
	areaname = "station dock"

/obj/docking_port/destination/pod2/transit
	areaname = "hyperspace (pod 2)"


/datum/shuttle/escape/pod/three/name = "Escape pod 3"

/datum/shuttle/escape/pod/three/initialize()
	.=..()
	dock_centcom = add_dock(/obj/docking_port/destination/pod3/centcom)
	dock_station = add_dock(/obj/docking_port/destination/pod3/station)

	set_transit_dock(/obj/docking_port/destination/pod3/transit)

/obj/docking_port/destination/pod3/centcom
	areaname = "central command"

/obj/docking_port/destination/pod3/station
	areaname = "station dock"

/obj/docking_port/destination/pod3/transit
	areaname = "hyperspace (pod 3)"

/datum/shuttle/escape/pod/four/name = "Escape pod 4"

/datum/shuttle/escape/pod/four/initialize()
	.=..()
	dock_centcom = add_dock(/obj/docking_port/destination/pod4/centcom)
	dock_station = add_dock(/obj/docking_port/destination/pod4/station)

	set_transit_dock(/obj/docking_port/destination/pod4/transit)

/obj/docking_port/destination/pod4/centcom
	areaname = "central command"

/obj/docking_port/destination/pod4/station
	areaname = "station dock"

/obj/docking_port/destination/pod4/transit
	areaname = "hyperspace (pod 4)"

/datum/shuttle/escape/pod/five/name = "Escape pod 5"

/datum/shuttle/escape/pod/five/initialize()
	.=..()
	dock_centcom = add_dock(/obj/docking_port/destination/pod5/centcom)
	dock_station = add_dock(/obj/docking_port/destination/pod5/station)

	set_transit_dock(/obj/docking_port/destination/pod5/transit)

/obj/docking_port/destination/pod5/centcom
	areaname = "central command"

/obj/docking_port/destination/pod5/station
	areaname = "station dock"

/obj/docking_port/destination/pod5/transit
	areaname = "hyperspace (pod 5)"
