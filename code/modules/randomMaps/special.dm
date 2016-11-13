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

		tcheck(80,1)

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

			//In order to always get an even number, divide the upper and lower limits by 2, then multiply result by 2 (rand(2-16) -> rand(1-8)*2 -> (2,4,6,...,16))
			if(prob(50)) //50% chance to make a horizontal wall
				if(c_height < 2)
					chambers.Remove(list(chamber))
					continue

				var/new_wall_y = rand((c_start_y+1)*0.5, (c_end_y-1)*0.5)*2

				//New opening's coordinate must be an odd number, to prevent conflicts with walls (do same thing that we did to get an even number and subtract 1): rand(1,19) -> rand(1, 10)*2 - 1 -> (1,3,...,19))
				var/new_opening_x = rand((c_start_x+1)*0.5, (c_end_x+1)*0.5)*2 - 1
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
			else
				if(c_width < 2)
					chambers.Remove(list(chamber))
					continue

				var/new_wall_x = rand((c_start_x+1)*0.5, (c_end_x-1)*0.5)*2

				//New opening's coordinate must be an odd number, to prevent conflicts with walls (do same thing that we did to get an even number and subtract 1): rand(1,19) -> rand(1, 10)*2 - 1 -> (1,3,...,19))
				var/new_opening_y = rand((c_start_y+1)*0.5, (c_end_y+1)*0.5)*2 - 1
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
