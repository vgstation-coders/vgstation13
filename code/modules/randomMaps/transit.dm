//Dynamically generated transit areas - welcome to the future
//Now with 100% less map elements due to virtual z-levels


//generate_transit_area proc
//Arguments: shuttle (/datum/shuttle object), direction (of the transit turfs), create_borders = 1 (if 0, people are not teleported when stepping out)
//Returns: docking port
/proc/generate_transit_area(datum/shuttle/shuttle)
	var/datum/virtual_z/transit_vz = map.addTransitVLevel(shuttle)

	//Transit turfs placed - place the docking port!
	//First, find the shuttle docking port's location relative to the shuttle's lower left corner
	var/list/offsets = shuttle.get_docking_port_offset()
	var/port_x = offsets[1]
	var/port_y = offsets[2]

	//Now calculate the location of the destination docking port
	//Docking ports dock like this: [  ][->][<-][  ], so the resulting coordinates will have to be shifted 1 turf in the direction of the shuttle docking port
	//Otherwise both arrows will be on the same turf
	var/dest_x = transit_vz.x_min + world.view + port_x
	var/dest_y = transit_vz.y_min + world.view + port_y
	var/turf/destination_turf = get_step(locate(dest_x, dest_y, transit_vz.z()), shuttle.linked_port.dir)

	var/obj/docking_port/destination/transit/result = new(destination_turf)
	result.dir = turn(shuttle.linked_port.dir, 180)

	return result
