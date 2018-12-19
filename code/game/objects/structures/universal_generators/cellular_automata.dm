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

/obj/structure/radial_gen/cellular_automata
	name = "cellular automata"
	var/turf/ca_wall
	var/turf/ca_floor
	var/mapgrid_width = 40
	var/mapgrid_height = 21
	var/percent_area_walls = 45
	var/iterations = 5
	var/watch
	var/mapgrid_scale = 1
	var/list/list_of_turfs = list()
	var/list/mapgrid
	var/could_not_place = 0

/obj/structure/radial_gen/cellular_automata/Destroy()
	..()
	mapgrid.Cut()
	list_of_turfs.Cut()

/obj/structure/radial_gen/cellular_automata/deploy_generator(var/turf/bottomleft)
	init_mapgrid() // first generates a random map
	for(var/i = 1 to iterations)
		make_caverns(i)
	could_not_place = check_mapgrid(bottomleft)
	if(!could_not_place)
		apply_mapgrid_to_turfs(bottomleft)

/obj/structure/radial_gen/cellular_automata/proc/init_mapgrid()
	if(!mapgrid)
		mapgrid = new/list(mapgrid_width,mapgrid_height)
	else if(could_not_place)
		could_not_place = 0
		return
	for(var/row = 1 to mapgrid_height)
		for(var/column = 1 to mapgrid_width)
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

/obj/structure/radial_gen/cellular_automata/proc/make_caverns(var/iteration)
	for(var/row = 1 to mapgrid_height)
		for(var/column = 1 to mapgrid_width)
			mapgrid[column][row] = place_wall_logic(column,row,iteration)

/obj/structure/radial_gen/cellular_automata/proc/place_wall_logic(var/column,var/row,var/iteration)
	var/num_walls = get_adjacent_walls(column,row)
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

/obj/structure/radial_gen/cellular_automata/proc/get_adjacent_walls(var/column,var/row,var/n = 1)

	if(mapgrid[column][row] == CA_PERMAWALL)
		return

	var/wallcounter = 0

	for(var/iy = max(1,row-n) to (row+n))
		for(var/ix = (column-n) to (column+n))
			if(ix > 0 && ix < mapgrid_width)
				if(!(ix == column && iy == row) && iy > 0 && iy < mapgrid_height)
					if(mapgrid[ix][iy])
						wallcounter++
	return wallcounter


/obj/structure/radial_gen/cellular_automata/proc/check_mapgrid(var/turf/bottomleft)
	for(var/row = 1 to mapgrid_height)
		for(var/column = 1 to mapgrid_width)
			if(!(mapgrid[column][row])) // it's a floor
				for(var/scale_row = 1 to mapgrid_scale)
					for(var/scale_column = 1 to mapgrid_scale)
						var/turf/T = locate((bottomleft.x-1)+(column * mapgrid_scale)+scale_column,(bottomleft.y-1)+(row * mapgrid_scale) + scale_row,bottomleft.z)
						if(!istype(T,ca_wall))
							return TRUE

/obj/structure/radial_gen/cellular_automata/proc/apply_mapgrid_to_turfs(var/turf/bottomleft)

	for(var/row = 1 to mapgrid_height)
		for(var/column = 1 to mapgrid_width)
			if(!(mapgrid[column][row])) // it's a floor
				for(var/scale_row = 1 to mapgrid_scale)
					for(var/scale_column = 1 to mapgrid_scale)
						var/turf/T = locate((bottomleft.x-1)+(column * mapgrid_scale)+scale_column,(bottomleft.y-1)+(row * mapgrid_scale) + scale_row,bottomleft.z)
						makefloor(T)

/obj/structure/radial_gen/cellular_automata/proc/makefloor(var/turf/T)
	T.clear_contents(list(type))
	return T.ChangeTurf(ca_floor)

/obj/structure/radial_gen/cellular_automata/ice
	name = "glacier lake"
	ca_wall = /turf/unsimulated/floor/snow
	mapgrid_width = 10
	mapgrid_height = 5
	mapgrid_scale = 2

/obj/structure/radial_gen/cellular_automata/ice/makefloor(var/turf/unsimulated/floor/snow/T)
	if(T && T.snowballs)
		T.clear_contents(list(type))
		var/obj/glacier/G = new /obj/glacier(T,icon_update_later = 1)
		list_of_turfs += G

/obj/structure/radial_gen/cellular_automata/ice/apply_mapgrid_to_turfs(var/turf/bottomleft)
	..()
	for(var/obj/glacier/G in list_of_turfs)
		G.relativewall()
/*
/obj/structure/radial_gen/cellular_automata/spider_cave
	name = "spider cave"
	ca_wall = /turf/unsimulated/mineral/random/underground
	ca_floor = /turf/unsimulated/floor/asteroid/underground
	percent_area_walls = 40
	iterations = 5

/obj/structure/radial_gen/cellular_automata/spider_cave/makefloor(var/turf/T)
	T.clear_contents(list(type))
	T.ChangeTurf(ca_floor)
	var/random = rand(1,1000)
	switch(random)
		if(1 to 4)
			var/spider = pick(/mob/living/simple_animal/hostile/giant_spider, /mob/living/simple_animal/hostile/giant_spider/hunter, /mob/living/simple_animal/hostile/giant_spider/nurse)
			new spider(T)
		if(5)
			new /mob/living/simple_animal/hostile/giant_spider/nurse/queen_spider(T)
		if(6 to 9)
			new /obj/effect/landmark/corpse/miner/rig(T)
		if(10 to 12)
			new /obj/effect/landmark/corpse/civilian(T)
		if(13)
			new /obj/effect/landmark/corpse/syndicatecommando(T) // if you add loot to it, they will come.

/obj/structure/radial_gen/cellular_automata/spider_cave/place_wall_logic(var/column,var/row,var/iteration)
	if(iteration == 3)
		var/num_walls = get_adjacent_walls(mapgrid,column,row,n = 2)
		if(num_walls <= 2)
			return CA_WALL
	return ..()

/obj/structure/radial_gen/cellular_automata/spider_cave/apply_mapgrid_to_turfs(var/turf/bottomleft)
	..()
	for(var/turf/T in list_of_turfs)
		T.update_icon()
*/