var/datum/shuttle/medical/medical_shuttle = new(starting_area = /area/shuttle/medical)

/datum/shuttle/medical
	name = "medical shuttle"
	can_link_to_computer = LINK_FREE

/datum/shuttle/medical/initialize()
	. = ..()
	add_dock(/obj/docking_port/destination/medical_station)
	add_dock(/obj/docking_port/destination/medical_outpost)
	add_dock(/obj/docking_port/destination/medical_escape)

/obj/machinery/computer/shuttle_control/medical/New()
	link_to(medical_shuttle)
	..()

/obj/docking_port/destination/medical_station
	areaname = "medbay dock"

/obj/docking_port/destination/medical_outpost
	areaname = "outpost medical dock"

/obj/docking_port/destination/medical_escape
	areaname = "escape hallway"

// ---

var/datum/shuttle/engineering/engineering_shuttle = new(starting_area = /area/shuttle/engineering)

/datum/shuttle/engineering
	name = "engineering shuttle"
	can_link_to_computer = LINK_FREE

/datum/shuttle/engineering/initialize()
	. = ..()
	add_dock(/obj/docking_port/destination/engineering_station)
	add_dock(/obj/docking_port/destination/engineering_outpost)

/obj/machinery/computer/shuttle_control/engineering/New()
	link_to(engineering_shuttle)
	..()

/obj/docking_port/destination/engineering_station
	areaname = "engineering dock"

/obj/docking_port/destination/engineering_outpost
	areaname = "outpost engineering dock"

// ---

var/datum/shuttle/damage_control/damage_control_shuttle = new(starting_area = /area/shuttle/damage_control)

/datum/shuttle/damage_control
	name = "damage control shuttle"
	can_link_to_computer = LINK_FREE

/datum/shuttle/damage_control/initialize()
	. = ..()
	add_dock(/obj/docking_port/destination/damage_control_station)
	add_dock(/obj/docking_port/destination/damage_control_outpost)
	add_dock(/obj/docking_port/destination/damage_control_station_secondary)

/obj/machinery/computer/shuttle_control/damage_control/New()
	link_to(damage_control_shuttle)
	..()

/obj/docking_port/destination/damage_control_station
	areaname = "damage control dock"

/obj/docking_port/destination/damage_control_station_secondary
	areaname = "damage control dock secondary"

/obj/docking_port/destination/damage_control_outpost
	areaname = "outpost damage control dock"
