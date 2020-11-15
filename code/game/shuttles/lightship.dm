#define LIGHT_SHIP_MOVE_TIME 300
#define LIGHT_SHIP_COOLDOWN 800

/datum/map_element/vault/lightship
	name = "Light Speed Ship"
	file_path = "maps/randomvaults/lightspeedship.dmm"

/datum/map_element/vault/lightship/initialize(list/objects)
	..()
		
/datum/shuttle/lightship
	name = "light speed ship"

	cooldown = LIGHT_SHIP_COOLDOWN

	can_link_to_computer = LINK_PASSWORD_ONLY
	password = TRUE

	transit_delay = LIGHT_SHIP_MOVE_TIME - 30 //Once somebody sends the shuttle, it waits for 3 seconds before leaving. Transit delay is reduced to compensate for that
	pre_flight_delay = 30

	stable = 1 //Don't stun everyone and don't throw anything when moving
	can_rotate = 0 //Sleepers, body scanners and multi-tile airlocks aren't rotated properly

/datum/shuttle/lightship/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/lightship/start)
	add_dock(/obj/docking_port/destination/syndicate/north)
	add_dock(/obj/docking_port/destination/syndicate/northeast)
	add_dock(/obj/docking_port/destination/syndicate/east)
	add_dock(/obj/docking_port/destination/syndicate/southeast)
	add_dock(/obj/docking_port/destination/syndicate/south)
	add_dock(/obj/docking_port/destination/syndicate/southwest)
	add_dock(/obj/docking_port/destination/syndicate/west)
	add_dock(/obj/docking_port/destination/syndicate/northwest)

	

/obj/machinery/computer/shuttle_control/lightship
	icon_state = "syndishuttle"

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/shuttle_control/lightship/New() //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	
	var/global/datum/shuttle/lightship/lightship_shuttle = new(starting_area=/area/shuttle/lightship/start)
	lightship_shuttle.initialize()
	link_to(lightship_shuttle)
	.=..()

/obj/docking_port/destination/lightship/start
	areaname = "deep space"



#undef LIGHT_SHIP_MOVE_TIME
#undef LIGHT_SHIP_COOLDOWN