var/global/list/docking_ports = list()

/obj/structure/docking_port
	name = "docking port"
	icon = 'icons/obj/structures.dmi'
	icon_state = "docking_shuttle"
	dir = NORTH

	var/areaname = "space"

/obj/structure/docking_port/New()
	.=..()
	docking_ports |= src

/obj/structure/docking_port/Destroy()
	.=..()
	docking_ports -= src

/obj/structure/docking_port/shuttle //this guy is installed on shuttles and connects to obj/structure/docking_port/destination
	icon_state = "docking_shuttle"

/obj/structure/docking_port/destination //this guy is installed on stations and connects to shuttles
	icon_state = "docking_station"

/obj/structure/docking_port/destination/invisible //this guy is installed in transit areas
	name = "invisible docking port"
