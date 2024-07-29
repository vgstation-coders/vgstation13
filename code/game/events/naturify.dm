var/list/flora_types = list(
									/obj/structure/flora/ausbushes/lavendergrass = 10,
									/obj/structure/flora/ausbushes/sparsegrass = 30,
	                             	/obj/structure/flora/ausbushes/fullgrass = 20,
									/obj/structure/flora/ausbushes/grassybush = 5,
								  	/obj/structure/flora/rock/pile = 15,
									/obj/structure/flora/rock = 6,
									/obj/structure/flora/ausbushes/leafybush = 4,
									/obj/structure/flora/ausbushes/palebush = 4,
									/obj/structure/flora/ausbushes/stalkybush = 4,
									/obj/structure/flora/ausbushes/grassybush = 4,
									/obj/structure/flora/ausbushes/sunnybush = 4,
									/obj/structure/flora/ausbushes/genericbush = 4,
									/obj/structure/flora/ausbushes/pointybush = 4
							 )

var/list/animal_types = list(
									/mob/living/simple_animal/hostile/retaliate/goat = 5,
									/mob/living/simple_animal/cow = 5,
									/mob/living/simple_animal/hostile/retaliate/box/pig = 7,
									/mob/living/simple_animal/chicken = 10,
									/mob/living/simple_animal/rabbit = 20,
									/mob/living/simple_animal/rabbit/bunny = 20
							 )

var/list/cave_decor_types = list(
								  	/obj/structure/flora/rock/pile = 15,
									/obj/structure/flora/rock = 6,
									/obj/item/device/flashlight/torch = 3,

							 )

var/list/ignored_cave_deletion_types = list(/obj/structure/window, /obj/machinery/door/airlock/external, /obj/structure/grille, /obj/structure/plasticflaps/mining)

var/list/medicine_cow_possible_reagents = list(ALLICIN, TANNIC_ACID, THYMOL, PHYTOCARISOL, PHYTOSINE)

/**
	Return your station to nature.
		All walls become wood. All floors become grass or stone. The station is populated with
		animals, trees, and other nature things, as well as some interesting tidbits.

		All APC's are gone. All batteries are drained. Electricity no longer operates.
*/

/proc/naturify_station()
	var/target_zlevel = map.zMainStation
	for(var/area/target in areas)
		// Note: there should really be a better way to check whether it's the space area...
		if(target.name != "Space" && target.z == target_zlevel)
			if(istype(target, /area/hallway))
				break_room(target)
				grassify_room(target, spawn_flora=TRUE, spawn_trees=TRUE, spawn_animals=TRUE)
			else if(istype(target, /area/crew_quarters/bar))
				break_room(target)
				grassify_room(target, spawn_flora=TRUE, spawn_medicine_cows=TRUE)
			else if(istype(target, /area/security/armory))
				caveify_room(target)
				generate_bear_den(target)
			else
				if(prob(85))
					break_room(target)
					grassify_room(target, spawn_flora=TRUE)
				else
					clear_objects_in_room(target, ignored_cave_deletion_types)
					break_room(target)
					caveify_room(target)
	for(var/area/target in areas)
		if(target.name != "Space" && target.z == target_zlevel)
			for(var/turf/simulated/wall/W in target)
				// Before roundstart, the walls don't visually connect with each other unless we call this.
				W.relativewall()
	to_chat(map.zLevels[target_zlevel], "<span class='sinister'>You blink, and suddenly the smell of grass permeates the air...</span>")

/// Turns a room grassy and makes the walls wooden. Other options are available for other nature-related spawns.
/proc/grassify_room(var/area/target, var/spawn_flora=TRUE, var/spawn_trees=FALSE, var/spawn_animals=FALSE, var/spawn_medicine_cows=FALSE)
	for(var/turf/T in target)
		if(istype(T, /turf/simulated/floor/))
			T.ChangeTurf(/turf/simulated/floor/grass/fireproof)
		else if(istype(T, /turf/simulated/wall) || istype(T, /turf/simulated/wall/r_wall))
			T.ChangeTurf(/turf/simulated/wall/mineral/wood, tell_universe = 0)

	for(var/obj/machinery/light/L in target)
		var/obj/structure/hanging_lantern/HL = new /obj/structure/hanging_lantern(L.loc)
		HL.dir = L.dir
		HL.lantern_can_be_removed = FALSE
		HL.update()
		qdel(L)

	for(var/obj/machinery/door/airlock/AL in target)
		if(!istype(AL, /obj/machinery/door/airlock/external))
			new /obj/machinery/door/mineral/wood/log(AL.loc)
			qdel(AL)
	for(var/obj/machinery/door/poddoor/shutters/S in target)
		new /obj/machinery/door/mineral/wood/log(S.loc)
		qdel(S)

	if(spawn_flora)
		for(var/turf/simulated/floor/F in target)
			if(!F.has_dense_content() && prob(35))
				var/flora_type = pickweight(flora_types)
				new flora_type(F)

	if(spawn_trees)
		for(var/turf/simulated/floor/F in target)
			if(!F.has_dense_content() && prob(5))
				for(var/obj/O in F)
					qdel(O)
				new/obj/structure/snow_flora/tree/pine(F)

	if(spawn_animals)
		for(var/turf/simulated/floor/F in target)
			if(!F.has_dense_content() && prob(10))
				var/animal_type = pickweight(animal_types)
				new animal_type(F)

	if(spawn_medicine_cows)
		for(var/turf/simulated/floor/F in target)
			if(!F.has_dense_content() && prob(8))
				var/mob/living/simple_animal/cow/medical_cow = generate_medicine_cow()
				medical_cow.forceMove(F)


/// Turns a room into a cave with rocks. Perfect for a caveman.
/proc/caveify_room(var/area/target)
	for(var/turf/T in target)
		if(istype(T, /turf/simulated/floor/))
			T.ChangeTurf(/turf/simulated/floor/asteroid/air)
		else if(istype(T, /turf/simulated/wall) || istype(T, /turf/simulated/wall/r_wall))
			T.ChangeTurf(/turf/unsimulated/mineral/random, tell_universe = 1)

	for(var/turf/simulated/floor/F in target)
		if(!F.has_dense_content() && prob(25))
			var/cave_decor_type = pickweight(cave_decor_types)
			new cave_decor_type(F)

	for(var/obj/machinery/light/L in target)
		var/obj/structure/hanging_lantern/HL = new /obj/structure/hanging_lantern/dim(L.loc)
		HL.dir = L.dir
		HL.lantern_can_be_removed = FALSE
		HL.update()
		qdel(L)

/proc/generate_bear_den(var/area/target)
	for(var/turf/simulated/floor/F in target)
		if(!F.has_dense_content() && prob(15))
			new /mob/living/simple_animal/hostile/bear(F)

/// Does various things to make the room look old and run down. For instance, breaks machines, eliminates power, etc.
/proc/break_room(var/area/target)
	for(var/obj/machinery/power/apc in target)
		qdel(apc)

	for(var/obj/machinery/computer/C in target)
		var/obj/structure/computerframe/frame = new /obj/structure/computerframe(C.loc)
		frame.anchored = 1
		frame.state = 4
		frame.icon_state = "4"
		qdel(C)

	for(var/obj/machinery/camera/C in target)
		C.deactivate(null)

	// Recursive check to uncharge all cells. Bit laggy!
	for(var/atom/A in target)
		uncharge_all_cells_recursive(A)

/proc/uncharge_all_cells_recursive(var/atom/A)
	var/obj/item/weapon/cell/C = A
	if(istype(C))
		C.charge = 0
	for(var/atom/content in A.contents)
		uncharge_all_cells_recursive(content)
	A.update_icon()

/proc/clear_objects_in_room(var/area/target, var/list/blacklist)
	for(var/turf/T in target)
		if(istype(T, /turf/simulated/floor/))
			for(var/obj/O in T)
				var/should_be_deleted = TRUE
				for(var/blacklisted_type in blacklist)
					if(istype(O, blacklisted_type))
						should_be_deleted = FALSE
						break
				if(should_be_deleted)
					qdel(O)

/proc/generate_medicine_cow()
	var/mob/living/simple_animal/cow/medicine_cow = new /mob/living/simple_animal/cow
	medicine_cow.name = "medical cow"
	medicine_cow.desc = "The cows will heal him."
	medicine_cow.milktype = pick(medicine_cow_possible_reagents)
	medicine_cow.min_reagent_regen_per_tick = 2
	medicine_cow.max_reagent_regen_per_tick = 3
	medicine_cow.reagent_regen_chance_per_tick = 15
	medicine_cow.milkable_reagents.maximum_volume = 30
	return medicine_cow

