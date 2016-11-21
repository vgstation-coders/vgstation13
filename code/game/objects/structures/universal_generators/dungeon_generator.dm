/*taken shamelessly from:
http://www.roguebasin.com/index.php?title=Dungeon_builder_written_in_Python
adapted in dreammaker for /vg/ snowmap
here is an example of what it may look like:
key: # - wall,
	 . - floor,
	 ~ - hidden door,
	 = - closed door,
	 O - open door

   ###   ###################                                                  ###
 ###.#   #............~....#        ###     #####    ##########################.#
 #.#.#####~######=#=#=######        #.#     #...#    #....=...................#.#
 #.#.#..........#.....#   ######### #.#######~#=######~##O#~###################.###
 #.#=#O##############=##  #.#.....# #.#...........O............#   #########  #.=.#
 #.#.......O...........#  #.O.....# #.#O##=##=#####=############   #.......#  #.#.########
 #.#O#####O###########=#  #.#.....# #.=...........=.O...############O#####O####.#.##.....#
 #.#.=.#....# #........#  #.#.....# #.#=#######~###.#=####....O...............=.#.##O#####
 #.#.=.#....# ########=####.#.....# #.O.#   ###.###.~.#  #######=#####=########.####.#
 #.#.#.#....#      #......=.#.....# #.#.#   #.#.#.=.#.#      ###.....=.#      #.O.##.#
 #=#.~.~....###### ##~###O######### #.#.#   #.#.#.#O#.########.#######.#      #.#.##.########
 #.O.#.#....=....#  #.##.......###  #.#.#   #.#.#.O.#.=.....##.#     #.#      #.#.##.=......####
 #.=.#~##############.##.......O.#  #.#.#   #.#.=.#.=.#.....##.#     #.#      #.#.##.#~#######.#
 #.#.~.............##.##.......~.#  #.~.#   #.=.###.O.#.....##.#     ###      #.#.##.#.....# #.#
 #.###OO####~#####~##=#####=O=~#.#  #.#O#####.#####.###.....##.################.#.##.#.....# #.#
 #.##.....##.~.................=.#  #.#....##.##.##=##########.O..............O.#.##.O.....# #.#
 #.##.....##.##=#===#O####~#####.#  #.#######.##.#.....#######O#O#~####~###=#=###.##.#.....# #.#
 #.##.....##.##.O...O.......##.~.#  #.#     #.##.#.....~...........~..........# #.##.#########.#
 #.##=#=####.##.###=#.......##.#.#  #.#     #.##.=.....##############O=######## ####.###.###.#.#
 #.##.#.#  #.##.# #.=.......##.#.####O#######O##.#.....#        #......##########  #.~.O.=.#.#.#
 #.##.#.#  #.##.###.O.......##.~.#........O....O.=.....#  ##### #O####=##.......####.#.#.#.#.=.###
 #.##.#.####.##.#.O.##########.#.#........######.#######  #...# #...O...#.......O.##.#.#.#.#.#.O.#
 #.##.#.##.~.##.#.#O##########.#.#........#    #.~.#   ####~#~###==##...=.......#.##.#~#.#.#.#.#.#
 #.##.#.##.#.##.=.#.#........#.#.#........######.#.#   #.......=...##...#.......#.##.#.O.~.#.#.#.#
 ####.#.##.#.##.#.#.O........#.#.#........O...##.#.#   #########~#O##...#.......#.##.O.#.###.#.#.#
    #.#.##.#.##.~.#.#........#.#.#........######O#O#############....=...O.......#.##.#.#.# #.#.=.#
    #.#.##.#.##.#.O.#........#.#.=........O....................O....##O##.......#.##.#.#.# #.#.#.#
    #.#.##.O.##.#.#.=........#.#######=~==##############==######....##.##.......#.##.#.~.# #.~.#.#
    #.#.##.#.##.#.#.#........#.#   ###.........#  #........#   #=#####.##########=##~#~#####.#.#.#
    #.~.##.=.####.#.##########=##  #.~.........#  #........### #.### #.### ###  #..........#.#.#.#
    ###.####.####.#.##..........####.#.........####........=.# #.O.# #.#.# #.#  ##########~#.#.#.#
      #~####.=.##.#.##..........#.##.#.........##.O........#.###.#.###.#.# #.#    ####.# #.=.=.#.#
      #...##.#.##.#.##..........#.##.#.........##.##########.#.O.#.#.#.O.###.#    #.##.###.#.#####
   ####O#~##~#.##.#.##..........=.##.#.........##.# ########.#.#.#.#.#.#.=.#.#    #.##.#.~.~.#
   #.=.......~.##.####..........####.#.........##.# #......O.#.O.#.#.#.#.#.#.#    #.##=#.#.#=#
   #.###~#####.##.#  #..........####.#=######O###.# ########.O.#.#=#.#.~.#.#.# ####.##.O.#.#.#
   #.##....# #.##.#  #..........O.##.#.# ###...##.#        #.#.#.O.~.#.###.O.# #.##.##.#.#.#.#
   #.##....# #.##.####..........#.##.=.###.#...##.#        #.#.#.#.=.#.# #.### #.##.##.#.#.#.######
   #.##....# #.##.O.##..........#.##.#.=.#.#...##~##########.#.#.#.#.#O# #.#   #.##.##.~.#.O.#....#
   #.##....# #.####.#########=###.##.=.~.#.#...##.........##.#.#.#=#.O.######  #.##.##.#.#.#.#....#
   #.##....# #.#  #.#  ### #...##.##.~.#.#.#...#############.~.#.O.~.=.O....#  #.##.##.#.#.#.#....#
   #.##....# #.####.#  #.# #...##.####.=.~.#...#           #.O.#.=.#~#.####~####.##.##.#.#.#.#....#
   ####....# #.##.~.#  #.# #...##.#  #.#=#.#...#           ###.#.#.#.#.O.......O.##.##.#.=.=.#....#
      ###### #.##.#.#  #.# #...####  #.#.#.###~#             #.#=#.#.#~#####===#O##O##.~.#.O.O....#
             #.##.=.#  #.# #...#######~#.#.###.###############~#.O.#.#..............##O#.###.#....#
 #############.####.#  #.###...#.......=.O.#.O.O...............#.#.~.########=##=#####.#.# #.#....#
 #...........O.#  #.#  #.#.~...#.......###.#.~.#=#~####=########.#.~.#      #.#......#.#.# #.#....#
##############.#  #.#  #.#.#####.......# #.O.#.#.#..........#  #.#.#.#      #.#......#.#.# #.#~#~##
#.#          #.#  #.#  #.#.#####.......# ###.#.#.#..........#  #.#.O.#      #.#......#.#.# #.O...#
#.#       ####=####.#  #.#.#...~.......#####.#.#.O..........#  #.#.###      #.#......#.#.# #.##O##
#.#       #.......#.#  #.#.#####.......#...###.#.#..........#  #.O.#  #######.#......#.### #.##.#
#.#########.......#.#  #.#.#   #.......~...# ###.#..........#  ###.#  #.....~.#......#.#   #.##.#
#.#.......=.......=.####.#.#   #.......O...#   #.#..........# ####=##########.=......#######~##.#
#.#~#######.......#=##.#.O.### #.......O...#   #.#..........# #..........#  #.#~#O####  #.....#.#
#.#.###  ###O##~###.##.#.#=#.# #########...#   #.#..........# #..........#  #.#.#.#     #.....#.#
#.#.#.#  #....=.###.##.#~#.#.########  #...#   #.#..........###..........#  #.=.#.#     #.....O.#
#.#.#.#  #....#.=.#.##.=.=.=.O......####=#######.#..........#.=..........#  #.O.#.#     #.....###
#.#.#.#  #....O.#.#.####.~.#O#O######..........#.##O###O#####.~..........#  #.O.###     #.....#
#.=.=.#  #....#.#.~.#  #.#.O......# #..........#.##.....#   #.##=######=#####~#~#########.....#
#O#.#O####=####.O.###  #.O.O......# #..........#.###O##=#####.##....# #.................~.....#
#.#.O.........O.########~#.=......# #..........#.# #.......##.#####=########=############.....#
#.#.#############........~.#......# #######~####.# #.......##.# #.=...............#     #.....#
#.#.#############~OO###OO#.O......#    #.....# ### #.......##.# #.#####=#=#########    ###~#O#####
#.=.O....................~.########    #.....#     #.......##.# #.#   #.......#        #...#.....#
#.#O############=#####=###O#####       #.....#  ######~######.# #.# ###.......#    #######~#######
#.#....................##......######  #.....#  #......#    #.# #.# #.O.......#    #.....O......#
#.######=######O#########......##...# ####~######O##O#=######O###O###.#.......###############~###
####.....# #.........#  #......##O#=# #........~...O................O.#.......#......O........#
   #.....# #.........#  #......~....###........##=~###O##############.#.......######~#=#########
   #.....# #.........####......=....#.O........##......#     ########.#.......#    #...........#
   #.....# #.........O.##......O....#.#........#########     #......~.#.......#    #############
   #.....##########~##.####O####....#.#........#             ########.O.......#
   #.....=...........#.O....#  ####~#.####~#####                  #####=#####################
   ##########################   #...~.~....#                      #.....~...................#
                                ############                      ###########################
*/

#define DG_NOTHING 		0
#define DG_FLOOR		1
#define DG_WALL			2
#define DG_CLOSEDDOOR	3
#define DG_OPENDOOR		4
#define DG_HIDDENDOOR	5

#define DG_CANTPLACE		0
#define DG_CANPLACE			1
#define DG_CANPLACEANDLINK	2

#define DG_CORRIDOR 1
#define DG_ROOM 	0
/datum/dungeon
	var/name = "dungeon"
	var/turf/wall_type
	var/turf/floor_type
	var/obj/machinery/door/closeddoor_type
	var/obj/machinery/door/opendoor_type
	var/obj/machinery/door/hiddendoor_type
	var/list/room_list = list()
	var/list/corridor_list = list()
	var/closedoor_chance		// integer out of one hundred - make sure all three add up to 100
	var/opendoor_chance			// integer out of one hundred - make sure all three add up to 100
	var/hiddendoor_chance		// integer out of one hundred - make sure all three add up to 100
	var/maxx
	var/maxy
	var/maxfails = 110 // don't set this too high this is in a fucken while loop and those are unreliable as heck pls no infinite loops thanks
	var/corridor_chance
	var/max_rooms = 0 // set to zero to be unlimted
	var/list/mapgrid = list()
	var/list/room_types = list()


/datum/dungeon/proc/make_mapgrid(var/turf/topleft)
	var/x_size = min(world.maxx - topleft.x,maxx)
	var/y_size = min(world.maxy - topleft.y,maxy)
	mapgrid[][] = var/list(x_size,y_size)
	place_room()
	var/failed = 0
	while(failed < maxfails)
		var/room_type = DG_ROOM
		if(rand(1,100) < corridor_chance)
			room_type = DG_CORRIDOR
		place_room()
	final_joins()

/datum/dungeon/proc/place_room()
	return DG_CANPLACE

/datum/dungeon/proc/make_exit()
	// pick a random wall and random point along that wall

/datum/dungeon/proc/make_door(var/x,var/y)
	var/door_type = rand(1,100)
	switch(door_type)
		if(1 to closeddoor_chance)
			mapgrid[x][y] = DG_CLOSEDDOOR		// place a closed door here
		if(closeddoor_chance to opendoor_chance)
			mapgrid[x][y] = DG_OPENDOOR			// place an open door here
		else
			mapgrid[x][y] = DG_HIDDENDOOR		// otherwise, place a hidden door here

/datum/dungeon/proc/join_corridor()

/datum/dungeon/proc/final_joins()

/datum/dungeon/proc/fill_room(var/startx,var/endx,var/starty,var/endy)
	return

/datum/dungeon/proc/apply_mapgrid_to_turfs(var/turf/topleft)
	for(var/row = 1 to maxx)
		for(var/column = 1 to maxy)
			var/turf/T = locate((topleft.x-1)-column,(topleft.y-1)-row,topleft.z)
			switch(mapgrid[column][row])
				if(DG_NOTHING)
					continue
				if(DG_FLOOR)
					T.changeTurf(floor_type)
				if(DG_WALL)
					T.changeTurf(wall_type)
				if(DG_CLOSEDDOOR)
					new closeddoor_type(T)
				if(DG_OPENDOOR)
					new opendoor_type(T)
				if(DG_HIDDENDOOR)
					new hiddendoor_type(T)

/datum/dungeon/proc/deploy_generator(var/turf/topleft)
	mapgrid.Cut()
	make_mapgrid()
	apply_mapgrid_to_turfs(topleft)


/datum/dungeon/rafid_style // absolutely stolen from the temple of rafid away mission
	maxx = 100
	maxy = 75
	corridor_chance = 30