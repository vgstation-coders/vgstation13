//Dynamically generated transit areas - welcome to the future

//Object used for the dungeons system (see dungeons.dm)
/datum/map_element/transit
	type_abbreviation = "TR"

	file_path = null //No map file is loaded

	width = 0
	height = 0


//generate_transit_area proc
//Arguments: shuttle (/datum/shuttle object), direction (of the transit turfs), create_borders = 1 (if 0, people are not teleported when stepping out)
//Returns: docking port
/proc/generate_transit_area(datum/shuttle/shuttle, direction, create_borders = 1)
	//To do this, we need to find the shuttle's width and height
	//Go through each turf in the shuttle, find the lowest x;y and the highest x;y, subtract them to get the size
	var/low_x = 0
	var/low_y = 0
	var/top_x = world.maxx
	var/top_y = world.maxy

	for(var/turf/T in shuttle.linked_area)
		if(T.x > low_x)
			low_x = T.x
		if(T.x < top_x)
			top_x = T.x

		if(T.y > low_y)
			low_y = T.y
		if(T.y < top_y)
			top_y = T.y

	var/shuttle_width = abs(top_x - low_x)
	var/shuttle_height= abs(top_y - low_y)

	//Extra space in every direction. WIthout this, you'd be able to see z2 out of your shuttle's window
	var/buffer_space = world.view

	var/datum/map_element/transit/new_transit = new()
	new_transit.name = "[shuttle.name] - transit area"
	new_transit.width = shuttle_width + 2*buffer_space
	new_transit.height = shuttle_height + 2*buffer_space

	//Find a suitable location for the map_element object (done automatically)
	load_dungeon(new_transit)

	//Start filling out the area
	var/turf/t_loc = new_transit.location

	if(!istype(t_loc))
		message_admins("<span class='warning'>ERROR: Unable to generate transit area (area placement failed).</span>")
		return

	for(var/turf/T in block(locate(t_loc.x, t_loc.y, t_loc.z), locate(t_loc.x+new_transit.width, t_loc.y+new_transit.height, t_loc.z)))
		T.ChangeTurf(/turf/space/transit)
		var/turf/space/transit/t_turf = T
		t_turf.pushdirection = direction
		t_turf.update_icon()

	//Transit turfs placed - place the docking port!
	//First, find the shuttle docking port's location relative to the shuttle's lower left corner
	var/port_x = shuttle.linked_port.x - top_x
	var/port_y = shuttle.linked_port.y - top_y

	//Now calculate the location of the destination docking port
	//Docking ports dock like this: [  ][->][<-][  ], so the resulting coordinates will have to be shifted 1 turf in the direction of the shuttle docking port
	//Otherwise both arrows will be on the same turf
	var/dest_x = t_loc.x + buffer_space + port_x
	var/dest_y = t_loc.y + buffer_space + port_y
	var/turf/destination_turf = get_step(locate(dest_x, dest_y, t_loc.z), shuttle.linked_port.dir)

	var/obj/docking_port/destination/transit/result = new(destination_turf)
	result.dir = turn(shuttle.linked_port.dir, 180)

	if(create_borders)
		result.generate_borders = TRUE
		//Border generation is done by the docking port

	return result