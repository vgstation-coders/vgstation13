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

	var/obj/docking_port/destination/dock_shuttle
	var/obj/machinery/podcomputer/podcomputer
	var/crashing_this_pod = 0

/datum/shuttle/escape/pod/initialize()
	.=..()
	emergency_shuttle.escape_pods.Add(src)
	podcomputer = locate(/obj/machinery/podcomputer) in linked_area
	if(podcomputer)
		podcomputer.linked_pod = src

	// I fucking hate shuttle wall smoothing it is such an annoying feature that only causes problems


/datum/shuttle/escape/pod/Destroy()
	podcomputer.linked_pod = null
	emergency_shuttle.escape_pods -= src
	..()

/datum/shuttle/escape/pod/proc/crash_into_shuttle()
	if(!crashing_this_pod)
		return

	crashing_this_pod = 0

	if(!dock_shuttle)
		return

	playsound(linked_port, 'sound/misc/weather_warning.ogg', 80, 0, 7, 0, 0)

	if(podcomputer)
		podcomputer.say("Warning! Destination controller is offline. Rerouting to nearest suitable location...")
		spark(get_turf(podcomputer))

	var/random_delay = pick(5 SECONDS, 15 SECONDS)

	spawn(15 SECONDS + random_delay)

		playsound(linked_port, 'sound/machines/hyperspace_begin.ogg', 70, 0, 0, 0, 0)
		playsound(dock_shuttle, 'sound/machines/hyperspace_begin.ogg', 60, 0, 0, 0, 0)

		spawn(5 SECONDS)

		if(!move_to_dock(dock_shuttle, 0, 180))
			message_admins("Warning: [src] failed to crash into shuttle.")
		else
			explosion(get_turf(dock_shuttle), 2, 3, 4, 6)

			for(var/mob/living/M in emergency_shuttle.shuttle.linked_area)
				shake_camera(M, 10, 1)
				if(iscarbon(M) || !M.anchored)
					M.Knockdown(3)


			// The pod crashed into the shuttle. Make it part of the shuttle
			// Automatic wall smoothing is gay and causes the pod to 'merge' with the shuttle visually
			// instead of wasting time solving an issue caused by a worthless feature im going to cheat

			spawn(2 SECONDS)
				for(var/turf/T in linked_area)
					T.set_area(emergency_shuttle.shuttle.linked_area)
				qdel(linked_area)
				qdel(src)


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
	dock_shuttle = add_dock(/obj/docking_port/destination/pod1/shuttle)

	set_transit_dock(/obj/docking_port/destination/pod1/transit)

/obj/docking_port/destination/pod1/centcom
	areaname = "central command"

/obj/docking_port/destination/pod1/station
	areaname = "station dock"

/obj/docking_port/destination/pod1/transit
	areaname = "hyperspace (pod 1)"

/obj/docking_port/destination/pod1/shuttle
	areaname = "emergency shuttle"

/datum/shuttle/escape/pod/two/name = "Escape pod 2"

/datum/shuttle/escape/pod/two/initialize()
	.=..()
	dock_centcom = add_dock(/obj/docking_port/destination/pod2/centcom)
	dock_station = add_dock(/obj/docking_port/destination/pod2/station)
	dock_shuttle = add_dock(/obj/docking_port/destination/pod2/shuttle)

	set_transit_dock(/obj/docking_port/destination/pod2/transit)

/obj/docking_port/destination/pod2/centcom
	areaname = "central command"

/obj/docking_port/destination/pod2/station
	areaname = "station dock"

/obj/docking_port/destination/pod2/transit
	areaname = "hyperspace (pod 2)"

/obj/docking_port/destination/pod2/shuttle
	areaname = "emergency shuttle"


/datum/shuttle/escape/pod/three/name = "Escape pod 3"

/datum/shuttle/escape/pod/three/initialize()
	.=..()
	dock_centcom = add_dock(/obj/docking_port/destination/pod3/centcom)
	dock_station = add_dock(/obj/docking_port/destination/pod3/station)
	dock_shuttle = add_dock(/obj/docking_port/destination/pod3/shuttle)

	set_transit_dock(/obj/docking_port/destination/pod3/transit)

/obj/docking_port/destination/pod3/centcom
	areaname = "central command"

/obj/docking_port/destination/pod3/station
	areaname = "station dock"

/obj/docking_port/destination/pod3/transit
	areaname = "hyperspace (pod 3)"

/obj/docking_port/destination/pod3/shuttle
	areaname = "emergency shuttle"

/datum/shuttle/escape/pod/four/name = "Escape pod 4"

/datum/shuttle/escape/pod/four/initialize()
	.=..()
	dock_centcom = add_dock(/obj/docking_port/destination/pod4/centcom)
	dock_station = add_dock(/obj/docking_port/destination/pod4/station)
	dock_shuttle = add_dock(/obj/docking_port/destination/pod4/shuttle)

	set_transit_dock(/obj/docking_port/destination/pod4/transit)

/obj/docking_port/destination/pod4/centcom
	areaname = "central command"

/obj/docking_port/destination/pod4/station
	areaname = "station dock"

/obj/docking_port/destination/pod4/transit
	areaname = "hyperspace (pod 4)"

/obj/docking_port/destination/pod4/shuttle
	areaname = "emergency shuttle"

/datum/shuttle/escape/pod/five/name = "Escape pod 5"

/datum/shuttle/escape/pod/five/initialize()
	.=..()
	dock_centcom = add_dock(/obj/docking_port/destination/pod5/centcom)
	dock_station = add_dock(/obj/docking_port/destination/pod5/station)
	dock_shuttle = add_dock(/obj/docking_port/destination/pod5/shuttle)

	set_transit_dock(/obj/docking_port/destination/pod5/transit)

/obj/docking_port/destination/pod5/centcom
	areaname = "central command"

/obj/docking_port/destination/pod5/station
	areaname = "station dock"

/obj/docking_port/destination/pod5/transit
	areaname = "hyperspace (pod 5)"

/obj/docking_port/destination/pod5/shuttle
	areaname = "emergency shuttle"

