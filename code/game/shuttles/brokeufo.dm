#define BROKE_UFO_MOVE_TIME 300
#define BROKE_UFO_COOLDOWN 800

/datum/map_element/vault/brokeufo
	name = "Broken UFO"
	file_path = "maps/randomvaults/brokeufo.dmm"
	spawn_cost = 3

/datum/map_element/vault/brokeufo/initialize(list/objects)
	..()

/datum/shuttle/brokeufo
	name = "broken ufo"

	cooldown = BROKE_UFO_COOLDOWN

	can_link_to_computer = LINK_PASSWORD_ONLY
	password = TRUE

	transit_delay = BROKE_UFO_MOVE_TIME - 30 //Once somebody sends the shuttle, it waits for 3 seconds before leaving. Transit delay is reduced to compensate for that
	pre_flight_delay = 30

	stable = 1 //Don't stun everyone and don't throw anything when moving
	can_rotate = 0 //Probably just won't work with this shuttle

/datum/shuttle/brokeufo/initialize()
	.=..()
	add_dock(/obj/docking_port/destination/brokeufo/start)
	add_dock(/obj/docking_port/destination/brokeufo/lab)
	add_dock(/obj/docking_port/destination/syndicate/north)
	add_dock(/obj/docking_port/destination/syndicate/northeast)
	add_dock(/obj/docking_port/destination/syndicate/east)
	add_dock(/obj/docking_port/destination/syndicate/southeast)
	add_dock(/obj/docking_port/destination/syndicate/south)
	add_dock(/obj/docking_port/destination/syndicate/southwest)
	add_dock(/obj/docking_port/destination/syndicate/west)
	add_dock(/obj/docking_port/destination/syndicate/northwest)

/obj/machinery/computer/shuttle_control/brokeufo
	icon_state = "syndishuttle"

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/shuttle_control/brokeufo/New() //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm

	var/global/datum/shuttle/brokeufo/brokeufo_shuttle = new(starting_area=/area/shuttle/brokeufo/start)
	brokeufo_shuttle.initialize()
	link_to(brokeufo_shuttle)

	var/obj/item/weapon/paper/manual_ufo = new(get_turf(src))

	manual_ufo.name = "GDR Scout Passcode"
	manual_ufo.info = "Keep this document in a secure location. Your craft's passcode is: \"<b>[brokeufo_shuttle.password]</b>\"."
	.=..()

//code/game/objects/structures/docking_port.dm
/obj/docking_port/destination/brokeufo/start
	areaname = "deep space"

/obj/docking_port/destination/brokeufo/lab
	areaname = "mothership lab z12"


#undef BROKE_UFO_MOVE_TIME
#undef BROKE_UFO_COOLDOWN
