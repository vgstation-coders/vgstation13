/datum/shuttle
	var/name = "shuttle"

	var/list/areas = list() //List of ALL areas the shuttle can move to
	var/area/current_area
	var/area/transit_area

	var/dir = NORTH //Direction of the shuttle

	var/movement_delay = 100//If there's no transit area, this is the time it takes for the shuttle to depart
							//If there is a transit area, this is the time the shuttle spends in it

	var/moving = 0 //If the shuttle is currently moving

	var/list/forbidden = list(
		/obj/item/weapon/disk/nuclear = "A nuclear authentication disk can't be transported on a shuttle.",
		)

	var/last_moved = 0
	var/cooldown = 0

var/global/datum/shuttle/mining_shuttle = new(starting_area = /area/shuttle/mining/station, \
	all_areas=list(/area/shuttle/mining/station, /area/shuttle/mining/outpost), \
	name = "mining shuttle")

var/global/datum/shuttle/research_shuttle = new(starting_area = /area/shuttle/research/station, \
	all_areas=list(/area/shuttle/research/station, /area/shuttle/research/station), \
	name = "research shuttle", dir = EAST)

var/global/datum/shuttle/salvage_shuttle = new(starting_area = /area/shuttle/salvage/start, \
	all_areas=list(/area/shuttle/salvage/start,
		/area/shuttle/salvage/arrivals,
		/area/shuttle/salvage/north,
		/area/shuttle/salvage/east,
		/area/shuttle/salvage/south,
		/area/shuttle/salvage/mining,
		/area/shuttle/salvage/trading_post,
		/area/shuttle/salvage/clown_asteroid,
		/area/shuttle/salvage/derelict,
		/area/shuttle/salvage/djstation,
		/area/shuttle/salvage/commssat,
		/area/shuttle/salvage/abandoned_ship), \
	name = "salvage shuttle", transit_area = /area/shuttle/salvage/transit,dir = WEST, cooldown = 800, delay = 300)


/datum/shuttle/proc/get_movement_delay()
	return movement_delay

/datum/shuttle/New(var/starting_area, var/list/all_areas, var/transit_area, var/name = "shuttle", var/dir, var/cooldown = 0, var/delay = 100)
	..()
	current_area = locate(starting_area)
	if(!current_area)
		world << "[starting_area] doesn't exist!"
		return

	if(transit_area)
		src.transit_area = locate(transit_area)
		if(!src.transit_area)
			world << "[transit_area] doesn't exist!"
			return

	for(var/T in all_areas)
		var/area/A = locate(T)
		if(!A)
			world << "Couldn't find [T]!"
		else
			areas |= A

	src.name = name
	src.dir = dir
	src.cooldown = cooldown
	src.movement_delay = delay

/datum/shuttle/proc/forbid_movement() //Return 0 if can move, return 1 or error message otherwise
	for(var/T in forbidden)
		if(current_area.search_contents_for(T))
			if(forbidden[T]) return forbidden[T]

/datum/shuttle/proc/start_movement(var/area/target_area)
	if(!target_area) //If we're not provided an area, select a random one from the list of our areas
		target_area = pick(areas - current_area)

	if(!target_area in areas)
		world << "[target_area] isn't in the shuttle's areas list!"
		return

	if(target_area == current_area)
		return

	if(moving)
		world << "The shuttle is already moving!"
		return

	if(cooldown != 0)
		if(last_moved + cooldown > world.time)
			return

	world << "Starting movement..."
	if(transit_area)
		complete_movement(transit_area)
	moving = 1

	sleep(get_movement_delay())

	complete_movement(target_area)

/datum/shuttle/proc/complete_movement(var/area/target_area)
	if(!target_area)
		world << "Area not specified!"
		return

	for(var/atom/movable/AM in target_area)
		collide(AM)
	for(var/turf/T in target_area)
		if(istype(T, /turf/simulated))
			qdel(T)

	current_area.move_contents_to(target_area)
	current_area = target_area

	for(var/atom/movable/AM in current_area)
		after_movement(AM)

	last_moved = world.time
	moving = 0

/datum/shuttle/proc/after_movement(var/atom/movable/AM as mob|obj)
	if(istype(AM,/mob/living))
		var/mob/living/M = AM

		if(!M.buckled)
			shake_camera(M, 10, 1) // unbuckled, HOLY SHIT SHAKE THE ROOM
			var/turf/T = get_step(get_turf(M), turn(src.dir, 180))

			if(!T) return
			M.throw_at(T, 10, 5)

		else
			shake_camera(M, 3, 1) // buckled, not a lot of shaking
			if(istype(M, /mob/living/carbon))
				M.Weaken(3)

		if(prob(5) || ( !M.buckled && prob(90) ) )
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.vomit()

/datum/shuttle/proc/collide(var/atom/movable/AM as mob|obj)
	world << "Collision with [AM]!"
	if(istype(AM,/mob/living))
		var/mob/living/M = AM

		M.gib()
	else
		qdel(AM)
