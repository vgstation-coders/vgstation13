var/list/flora_types = list(
									/obj/structure/flora/ausbushes/lavendergrass = 10,
									/obj/structure/flora/ausbushes/sparsegrass = 30,
	                             	/obj/structure/flora/ausbushes/fullgrass = 20,
								  	/obj/structure/flora/rock/pile = 15,
									/obj/structure/flora/rock = 6,
									/obj/structure/flora/ausbushes/leafybush = 3,
									/obj/structure/flora/ausbushes/palebush = 3,
									/obj/structure/flora/ausbushes/stalkybush = 3,
									/obj/structure/flora/ausbushes/sunnybush = 3,
									/obj/structure/flora/ausbushes/genericbush = 3,
									/obj/structure/flora/ausbushes/pointybush = 3,
									/obj/structure/seedbush = 10,
							 )

var/list/animal_types = list(
									/mob/living/simple_animal/hostile/retaliate/goat = 5,
									/mob/living/simple_animal/cow = 8,
									/mob/living/simple_animal/hostile/retaliate/box/pig = 9,
									/mob/living/simple_animal/chicken = 14,
									/mob/living/simple_animal/rabbit = 12,
									/mob/living/simple_animal/rabbit/bunny = 12,
									/mob/living/carbon/complex/gondola = 1,
									/mob/living/simple_animal/capybara = 1,
							 )

var/list/cave_decor_types = list(
								  	/obj/structure/flora/rock/pile = 40,
									/obj/structure/flora/rock = 15,
									/obj/item/device/flashlight/torch = 8,
									/obj/item/weapon/pickaxe/shovel = 3,
									/obj/item/weapon/melee/bone_club = 1,
									/obj/item/weapon/melee/wooden_club = 1,
							 )

var/list/ignored_cave_deletion_types = list(/obj/structure/window, /obj/machinery/door/airlock/external, /obj/structure/grille, /obj/structure/plasticflaps/mining)

var/list/medicine_cow_possible_reagents = list(ALLICIN, TANNIC_ACID, THYMOL, PHYTOCARISOL, PHYTOSINE)

var/list/seedbush_spawns = list(
		/obj/item/seeds/bananaseed = 10,
		/obj/item/seeds/berryseed = 10,
		/obj/item/seeds/carrotseed = 10,
		/obj/item/seeds/chantermycelium = 10,
		/obj/item/seeds/chiliseed = 10,
		/obj/item/seeds/cornseed = 10,
		/obj/item/seeds/eggplantseed = 10,
		/obj/item/seeds/potatoseed = 10,
		/obj/item/seeds/dionanode = 10,
		/obj/item/seeds/soyaseed = 10,
		/obj/item/seeds/sunflowerseed = 10,
		/obj/item/seeds/tomatoseed = 10,
		/obj/item/seeds/towermycelium = 10,
		/obj/item/seeds/wheatseed = 10,
		/obj/item/seeds/appleseed = 10,
		/obj/item/seeds/poppyseed = 10,
		/obj/item/seeds/ambrosiavulgarisseed = 10,
		/obj/item/seeds/whitebeetseed = 10,
		/obj/item/seeds/sugarcaneseed = 10,
		/obj/item/seeds/watermelonseed = 10,
		/obj/item/seeds/limeseed = 10,
		/obj/item/seeds/lemonseed = 10,
		/obj/item/seeds/orangeseed = 10,
		/obj/item/seeds/grassseed = 10,
		/obj/item/seeds/cloverseed = 10,
		/obj/item/seeds/cocoapodseed = 10,
		/obj/item/seeds/cabbageseed = 10,
		/obj/item/seeds/grapeseed = 10,
		/obj/item/seeds/pumpkinseed = 10,
		/obj/item/seeds/cherryseed = 10,
		/obj/item/seeds/plastiseed = 10,
		/obj/item/seeds/riceseed = 10,
		/obj/item/seeds/cinnamomum = 10,
		/obj/item/seeds/avocadoseed = 10,
		/obj/item/seeds/pearseed = 10,
		/obj/item/seeds/peanutseed = 10,
		/obj/item/seeds/mustardplantseed = 10,
		/obj/item/seeds/flaxseed = 10,
		/obj/item/seeds/amanitamycelium = 6,
		/obj/item/seeds/glowshroom = 6,
		/obj/item/seeds/libertymycelium = 6,
		/obj/item/seeds/nettleseed = 6,
		/obj/item/seeds/plumpmycelium = 6,
		/obj/item/seeds/reishimycelium = 6,
		/obj/item/seeds/harebell = 6,
)

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
				break_room(target)
				caveify_room(target)
				generate_bear_den(target)
			else if(istype(target, /area/maintenance))
				if(prob(80))
					clear_objects_in_room(target, ignored_cave_deletion_types)
					break_room(target)
					caveify_room(target)
				else
					break_room(target)
					grassify_room(target, spawn_flora=TRUE)
			else
				if(prob(92))
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
			T.ChangeTurf(/turf/simulated/floor/planetary_grass)
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
	for(var/obj/machinery/door/unpowered/shuttle/S in target)
		new /obj/machinery/door/mineral/wood/log(S.loc)
		qdel(S)
	for(var/obj/machinery/door/poddoor/P in target)
		qdel(P)

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
				new/obj/structure/flora/tree/shitty(F)

	if(spawn_animals)
		for(var/turf/simulated/floor/F in target)
			if(!F.has_dense_content() && prob(4))
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
			T.ChangeTurf(/turf/unsimulated/mineral/random/air, tell_universe = 1)

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

	for(var/obj/machinery/M in target)
		if(!istype(M, /obj/machinery/computer) && prob(50))
			M.stat |= BROKEN

	for(var/obj/machinery/camera/C in target)
		C.deactivate(null)

	// Recursive check to uncharge all cells. Bit laggy!
	for(var/turf/T in target)
		uncharge_all_cells_recursive(T)

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



/obj/structure/seedbush
	name = "seed bush"
	desc = "This mysterious bush of grass is genetically modified to produce a type of seed when harvested."
	icon = 'icons/obj/flora/ausflora.dmi'
	icon_state = "grassybush_1"

/obj/structure/seedbush/New()
	..()
	icon_state = "grassybush_[rand(1, 4)]"

/obj/structure/seedbush/attack_hand(mob/user)
	var/seed_type = pickweight(seedbush_spawns)
	var/obj/item/seeds/harvested_seed = new seed_type(user.loc)
	user.put_in_active_hand(harvested_seed)
	playsound(loc, "sound/effects/plant_rustle.ogg", 50, 1, -1)
	user.visible_message("<span class='notice'>[user] harvests \the [harvested_seed] from \the [src].</span>", "You harvest \the [harvested_seed] from \the [src].")
	if(prob(60))
		qdel(src)



/turf/simulated/floor/planetary_grass
	name = "Grass"
	icon = 'icons/turf/floors.dmi'
	icon_state = "grass1"
	plane = PLATING_PLANE
	var/dirt_left = 10

/turf/simulated/floor/planetary_grass/update_icon()
	return

/turf/simulated/floor/planetary_grass/create_floor_tile()
	return

/turf/simulated/floor/planetary_grass/New()
	icon_state = "grass[pick("1","2","3","4")]"
	..()
	spawn(4)
		if(src)
			update_icon()
			for(var/direction in cardinal)
				if(istype(get_step(src,direction),/turf/simulated/floor))
					var/turf/simulated/floor/FF = get_step(src,direction)
					FF.update_icon()

/turf/simulated/floor/planetary_grass/canBuildLattice()
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(!(locate(/obj/structure/lattice) in contents))
		return BUILD_SUCCESS

/turf/simulated/floor/planetary_grass/canBuildCatwalk()
	return BUILD_FAILURE

/turf/simulated/floor/planetary_grass/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(isshovel(W))
		if(dirt_left > 0)
			user.visible_message("<span class='notice'>[user] digs out some dirt with \the [W].</span>", \
			"<span class='notice'>You dig out some dirt with \the [W].</span>")
			playsound(src, 'sound/items/shovel.ogg', 50, 1)
			var/amount = min(dirt_left, 2)
			dirt_left -= amount
			drop_stack(/obj/item/stack/ore/glass, src, amount)
			user.delayNextAttack(20)
		else
			to_chat(user, "<span class='notice'>There's not enough dirt left here to dig anymore!</span>")
		return


/obj/structure/flora/tree/shitty
	icon = 'icons/obj/flora/trees.dmi'
	icon_state = "shittytree"
	randomize_on_creation = FALSE
