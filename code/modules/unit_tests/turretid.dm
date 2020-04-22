#define RESULT_RUN      1
#define RESULT_WALK     2
#define RESULT_NOSLIP   3
#define RESULT_MAGBOOTS 4

#define TURF_WET_WATER_STR "1" // Byond doesn't like integers in assoc list :-(
#define TURF_WET_LUBE_STR "2"

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