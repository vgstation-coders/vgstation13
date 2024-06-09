/datum/shuttle/bagel
	name = "bagel ferry"
	can_link_to_computer = LINK_FREE
	destroy_everything = TRUE // So that it can replace part of maintenance. Possibly a terrible idea?
	linked_area = /area/shuttle/bagel

/datum/shuttle/bagel/initialize()
	. = ..()
	add_dock(/obj/docking_port/destination/bagel_aftstarboard)
	add_dock(/obj/docking_port/destination/bagel_foreport)

/obj/machinery/computer/shuttle_control/bagel
	shuttle = /area/shuttle/bagel

/obj/docking_port/destination/bagel_aftstarboard
	areaname = "aft starboard"
	base_turf_override = TRUE
	base_turf_type = /turf/simulated/floor/plating
	refill_area = /area/maintenance/asmaint

/obj/docking_port/destination/bagel_foreport
	areaname = "fore port"
	base_turf_override = TRUE
	base_turf_type = /turf/simulated/floor/plating
	refill_area = /area/maintenance/fpmaint
