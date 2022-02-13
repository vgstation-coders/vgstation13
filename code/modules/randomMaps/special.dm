//Simple and crappy but working maze generator
//Spawning it asks you for its size and wall/floor types
//Set its width and height to something else than 0 before calling load() to make it more automated

/datum/map_element/customizable/maze
	file_path = null

	width  = 0
	height = 0
	var/wall_type = /turf/unsimulated/wall/rock
	var/floor_type = /turf/unsimulated/floor/asteroid/air
	var/area_type = null

/datum/map_element/customizable/maze/pre_load()
	.=..()

	if(usr && (!width || !height))
		width  = input(usr, "Enter the maze's width (4-200). The starting point is the lower left corner. Enter an invalid value to cancel.", "Maze Generator") as num
		if(width < 4 || width > 200)
			width = 0
			return

		height = input(usr, "Enter the maze's height (4-200). The starting point is the lower left corner. Enter an invalid value to cancel.", "Maze Generator") as num
		if(height < 4 || height > 200)
			height = 0
			return

		//Convert width and height to even numbers (19 turns into 20, 20 stays a 20)
		width  = ((width % 2) ? width + 1 : width)
		height = ((height% 2) ? height + 1: height)

		if(alert(usr, "Would you like to set the maze's wall and floor types?", "Maze Generator", "No", "Yes") == "Yes")
			wall_type = input(usr, "Select wall type.", "Maze Generator", wall_type) as null|anything in typesof(/turf)
			if(!wall_type)
				wall_type = initial(wall_type)
				to_chat(usr, "Wall type reset to [wall_type]")

			floor_type = input(usr, "Select floor type.", "Maze Generator", floor_type) as null|anything in typesof(/turf)
			if(!floor_type)
				floor_type = initial(floor_type)
				to_chat(usr, "Floor type reset to [floor_type]")

		if(alert(usr, "Would you like the maze to have dynamic lightning and darkness?", "Maze Generator", "No", "Yes") == "Yes")
			area_type = /area/vault

/datum/map_element/customizable/maze/initialize()
	if(!location)
		return
	if(!width || !height)
		return

	var/location_x = location.x
	var/location_y = location.y
	var/location_z = location.z
	var/area/area_object = null
	var/area/old_area = get_space_area()

	for(var/turf/T in block(locate(location_x, location_y, location_z), locate(location_x + width, location_y + height, location_z)))
		if(T.x == location_x || T.y == location_y || T.x == location_x + width || T.y == location_y + height) //Border walls
			T.ChangeTurf(wall_type)
		else
			T.ChangeTurf(floor_type)

		if(area_type != null)
			if(!area_object)
				area_object = new area_type
				area_object.tag = "[area_type]/\ref[src]"
				area_object.addSorted()

			area_object.contents.Add(T)
			T.change_area(old_area, area_object)

		CHECK_TICK

	//Use the recursive division method: https://en.wikipedia.org/wiki/Maze_generation_algorithm#Recursive_division_method
	//Start with a single chamber and divide it into two chambers with a wall (which has an opening somewhere)
	//Continue dividing the chambers until they can no longer be divided
	//Each chamber is represented by a list. First two elements are the chamber's starting X and Y, the next two are the chamber's ending X and Y
	//list(1,1,20,20) is a chamber from [1;1] to [20;20]
	//The chambers list contains all currently processed chambers
	var/list/chambers = list(list(location_x + 1, location_y + 1, location_x + width - 1, location_y + height - 1))

	while(chambers.len)
		for(var/list/chamber in chambers)
			var/c_start_x = chamber[1]
			var/c_start_y = chamber[2]
			var/c_end_x = chamber[3]
			var/c_end_y = chamber[4]

			var/c_width = c_end_x - c_start_x
			var/c_height= c_end_y - c_start_y
			//place a wall that divides the chamber

			var/horizontal_wall_chance_modifier = (c_height > c_width ? 20 : -20)
			if(prob(50 + horizontal_wall_chance_modifier))
				if(c_height < 2)
					chambers.Remove(list(chamber))
					continue

				//The wall's coodrinate must be an even number, to prevent conflicts with openings
				var/new_wall_y = round((rand()+rand()+rand())/3 * (c_height-2)) + c_start_y
				if((new_wall_y - location_y) % 2) //odd
					new_wall_y++

				//New opening's coordinate must be an odd number, to prevent conflicts with walls
				var/new_opening_x = rand(c_start_x, c_end_x-2)
				if((new_opening_x - location_x) % 2 == 0) //even
					new_opening_x++

				var/list/new_chamber_1 = list(c_start_x, c_start_y, c_end_x, new_wall_y - 1)
				var/list/new_chamber_2 = list(c_start_x, new_wall_y + 1, c_end_x, c_end_y)

				//To add/remove lists to/from a list, you have to do this: Add(list([your list object])), Remove(list([your list object]))
				//Otherwise it performs the Add/Remove operation on every object in your list object, instead of the list itself
				chambers.Remove(list(chamber))
				chambers.Add(list(new_chamber_1, new_chamber_2))

				//Build the wall
				for(var/dx = c_start_x to c_end_x)
					if(dx == new_opening_x)
						continue

					var/turf/T = locate(dx, new_wall_y, location_z)
					T.ChangeTurf(wall_type)
			else //Same as above but x and y are switched around
				if(c_width < 2)
					chambers.Remove(list(chamber))
					continue

				var/new_wall_x = round((rand()+rand()+rand())/3 * (c_width-2)) + c_start_x
				if((new_wall_x - location_x) % 2) //odd
					new_wall_x++

				var/new_opening_y = rand(c_start_y, c_end_y-1)
				if((new_opening_y - location_y) % 2 == 0) //even
					new_opening_y++

				var/list/new_chamber_1 = list(c_start_x, c_start_y, new_wall_x - 1, c_end_y)
				var/list/new_chamber_2 = list(new_wall_x + 1, c_start_y, c_end_x, c_end_y)

				//To add/remove lists to/from a list, you have to do this: Add(list([your list object])), Remove(list([your list object]))
				//Otherwise it performs the Add/Remove operation on every object in your list object, instead of the list itself
				chambers.Remove(list(chamber))
				chambers.Add(list(new_chamber_1, new_chamber_2))

				//Build the wall
				for(var/dy = c_start_y to c_end_y)
					if(dy == new_opening_y)
						continue

					var/turf/T = locate(new_wall_x, dy, location_z)
					T.ChangeTurf(wall_type)

		sleep(1)


//
/datum/map_element/customizable/vault_placement
	file_path = null

	width  = 0
	height = 0

/datum/map_element/customizable/vault_placement/pre_load()
	if(usr && (!width || !height))
		width  = input(usr, "Enter the area's width (4-400). The starting point is the lower left corner. Enter an invalid value to cancel.", "Vault Generator", 100) as num
		if(width < 4 || width > 400)
			width = 0
			return

		height = input(usr, "Enter the area's height (4-400). The starting point is the lower left corner. Enter an invalid value to cancel.", "Vault Generator", 100) as num
		if(height < 4 || height > 400)
			height = 0
			return

/datum/map_element/customizable/vault_placement/initialize()
	if(!location)
		return
	if(!width || !height)
		return

	populate_area_with_vaults(block(location, locate(location.x + width, location.y + height, location.z)))
