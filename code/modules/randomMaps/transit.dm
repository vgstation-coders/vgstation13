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

//generate_parking_area proc
//Creates a small virtual z-level with space turfs for a shuttle to park in
//Arguments: shuttle (/datum/shuttle object)
//Returns: docking port
/proc/generate_parking_area(datum/shuttle/shuttle)
	var/buffer = world.view
	var/list/dims = shuttle.get_size()
	if(!dims)
		return null
	var/shuttle_width = dims[1]
	var/shuttle_height = dims[2]
	var/datum/virtual_z/parking_vz = map.addVLevel(shuttle_width + 2*buffer, shuttle_height + 2*buffer)
	parking_vz.name = "[shuttle.name] - parking area"
	parking_vz.level_type = VZ_PARKING
	parking_vz.linked_shuttle = shuttle

	var/list/offsets = shuttle.get_docking_port_offset()
	var/port_x = offsets[1]
	var/port_y = offsets[2]

	var/dest_x = parking_vz.x_min + buffer + port_x
	var/dest_y = parking_vz.y_min + buffer + port_y
	var/turf/destination_turf = get_step(locate(dest_x, dest_y, parking_vz.z()), shuttle.linked_port.dir)

	var/obj/docking_port/destination/result = new(destination_turf)
	result.dir = turn(shuttle.linked_port.dir, 180)
	result.areaname = "[shuttle.name] deep space parking"

	return result
