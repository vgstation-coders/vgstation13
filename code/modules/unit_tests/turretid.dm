/datum/unit_test/turretid
/datum/unit_test/turretid/start()
    var/turf/centre = locate(/area/shuttle/arrival/station)
    var/obj/machinery/turretid/turret_controller = new(centre)
    ASSERT(isarea(turret_controller.control_area))
    turret_controller.control_area = /area/shuttle/arrival
    turret_controller.New()
    ASSERT(isarea(turret_controller.control_area))
    turret_controller.control_area = "Arrival Shuttle" // the arrival shuttle area should exist on every station
    turret_controller.New()
    ASSERT(isarea(turret_controller.control_area))
    turret_controller.control_area = "/area/shuttle/arrival/station"
    turret_controller.New()
    ASSERT(isarea(turret_controller.control_area))