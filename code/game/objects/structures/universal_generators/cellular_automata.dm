/*taken shamelessly from:
http://www.roguebasin.com/index.php?title=Cellular_Automata_Method_for_Generating_Random_Cave-Like_Levels#C.23_Code
adapted in dreammaker for /vg/ snowmap
how it works: it performs it on a list five times and then applies the list to the surroundings - setbaseturf isn't cheap enough to call five times to do this the "proper" way
the wall is the turf you want to start with (#)
the floor is the turf you want to have generate in (.)

Procedurally generated so no two levels are (likely) exactly the same.
Relatively simple concept, and implementation.
A natural, cave-like map to add variety, uniqueness or an alternative to room-based dungeons.
(we're using it for lakes now though, seems to transfer fairly fluidly (ha puns) to that.)

here is an example of what it might look like:

############################################################
###....####################################.....############
##......######################..#########.........##########
##......#####################....#######...........####.####
##......###################.........................##...###
##......##################..........................###...##
#........##############.............................###...##
#........#############...............................#....##
##.......##############..................................###
##.......###..############..............................####
##.......##....############.............................####
#..............############...###........................###
#...............###########..#####...............##.......##
#................#################...............##.......##
##.....#####..........###########....#..........###.......##
##....#######...........########....###.........####......##
##....#######............######....####........#####......##
##....#######.............####....#####.......#####......###
#......######..............###....####........####......####
#.......######.............###...####.........###.......####
#........#####.............###..####.....................###
##........####..............#...####.....................###
#####......##...................####.....................###
######...........................##.....................####
######..................................................####
######.........###.....................####.............####
######......#########.................######............####
#######....#############.......##############.....###..#####
##############################################..############
############################################################
*/

#define CA_PERMAWALL 2
#define CA_WALL 1
#define CA_FLOOR 0

/obj/procedural_generator/cellular_automata
	name = "cellular automata"
	var/turf/ca_wall
	var/turf/ca_floor
	var/mapgrid_width = 40
	var/mapgrid_height = 21
	var/percent_area_walls = 40
	var/iterations = 5
	var/watch

/obj/procedural_generator/cellular_automata/deploy_generator(var/turf/bottomleft)
	var/mapgrid = init_mapgrid() // first generates a random map
	for(var/i = 1 to iterations)
		make_caverns(mapgrid)
	apply_mapgrid_to_turfs(mapgrid,bottomleft)

/obj/procedural_generator/cellular_automata/proc/init_mapgrid()
	// New empty map
	var/list/mapgrid[][] = new/list(mapgrid_width,mapgrid_height)
	for(var/row = 1 to mapgrid_height)
		for(var/column = 1 to mapgrid_width)
//			if(!((column + row*column) % 50000))
//				sleep(world.tick_lag)
			// If coordinants lie on the the edge of the map (creates a border)
			if(column == 1)
				mapgrid[column][row] = CA_PERMAWALL
			else if(row == 1)
				mapgrid[column][row] = CA_PERMAWALL
			else if(column == mapgrid_width)
				mapgrid[column][row] = CA_PERMAWALL
			else if(row == mapgrid_height)
				mapgrid[column][row] = CA_PERMAWALL
			else // otherwise, fill the walls a random percent of the time
				var/random_number = rand(1,100)
				if(random_number < percent_area_walls)
					mapgrid[column][row] = CA_WALL
				else
					mapgrid[column][row] = CA_FLOOR
	return mapgrid

/obj/procedural_generator/cellular_automata/proc/make_caverns(var/list/mapgrid)
	for(var/row = 1 to mapgrid_height)
		for(var/column = 1 to mapgrid_width)
//			if(!((column + row*column) % 50000))
//				sleep(world.tick_lag)
			mapgrid[column][row] = place_wall_logic(mapgrid,column,row)

/obj/procedural_generator/cellular_automata/proc/place_wall_logic(var/list/mapgrid,var/column,var/row)
	var/num_walls = get_adjacent_walls(mapgrid,column,row)
	switch(mapgrid[column][row])
		if(CA_PERMAWALL)
			return CA_PERMAWALL
		if(CA_WALL)
			if(num_walls >= 4)
				return CA_WALL
		if(CA_FLOOR)
			if(num_walls >= 5)
				return CA_WALL
	return CA_FLOOR

/obj/procedural_generator/cellular_automata/proc/get_adjacent_walls(var/list/mapgrid,var/column,var/row)

	if(mapgrid[column][row] == CA_PERMAWALL)
		return

	var/wallcounter = 0

	for(var/iy = (row-1) to (row+1))
		for(var/ix = (column-1) to (column+1))
			if(!(ix == column && iy == row)) // ie it's not the starting point
				if(mapgrid[ix][iy])
					wallcounter++
	return wallcounter


/obj/procedural_generator/cellular_automata/proc/apply_mapgrid_to_turfs(var/list/mapgrid,var/turf/bottomleft)
//	var/number_of_turfs_changed
	for(var/row = 1 to mapgrid_height)
		for(var/column = 1 to mapgrid_width)
//			if(!((column + row*column) % 50000))
//				sleep(world.tick_lag)
			if(!(mapgrid[column][row])) // it's a floor
				var/turf/T = locate((bottomleft.x-1)+column,(bottomleft.y-1)+row,bottomleft.z)
				if(T && istype(T,ca_wall))
					makefloor(T)
//	var/datum/zLevel/zlevesoninquiry = map.zLevels[bottomleft.z]
//	log_startup_progress("Finished cellular automata generaton on z:[bottomleft.z]([zlevesoninquiry.name]) with [number_of_turfs_changed] new [name]s in [stop_watch(watch)]s")

/obj/procedural_generator/cellular_automata/proc/makefloor(var/turf/T)
	T.clear_contents(list(type))
	T.ChangeTurf(ca_floor)

/obj/procedural_generator/cellular_automata/ice
	name = "glacier lake"
	ca_wall = /turf/snow
	iterations = 6

/obj/procedural_generator/cellular_automata/ice/large/New()
	mapgrid_width  = world.maxx
	mapgrid_height = world.maxy
	percent_area_walls = 70
	..()

/obj/procedural_generator/cellular_automata/ice/makefloor(var/turf/snow/T)
	if(T.snowballs)
		T.clear_contents(list(type))
		new /obj/glacier(T)