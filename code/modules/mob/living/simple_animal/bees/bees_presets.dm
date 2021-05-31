
////////////////////////////BEE PRESETS/////////////////////////////////////

///////////////REGULAR BEES

/mob/living/simple_animal/bee/adminSpawned/New(loc, var/obj/machinery/apiary/new_home)
	..()
	initialize()

/mob/living/simple_animal/bee/adminSpawned/initialize()
	var/datum/bee/B = new()
	addBee(B)
	update_icon()

/mob/living/simple_animal/bee/adminSpawnedQueen/New(loc, var/obj/machinery/apiary/new_home)
	..()
	initialize()

/mob/living/simple_animal/bee/adminSpawnedQueen/initialize()
	var/datum/bee/queen_bee/B = new()
	B.colonizing = 1//so it can start a colony if someone places it in an empty hive
	addBee(B)
	update_icon()

/mob/living/simple_animal/bee/adminSpawnedSwarm/New(loc, var/obj/machinery/apiary/new_home)
	..()
	initialize()

/mob/living/simple_animal/bee/adminSpawnedSwarm/initialize()
	for (var/i = 1 to MAX_BEES_PER_SWARM)
		var/datum/bee/B = new()
		addBee(B,FALSE)
	updateDamage()

/mob/living/simple_animal/bee/adminSpawnedSwarm/angry/initialize()
	..()
	mood_change(BEE_OUT_FOR_ENEMIES)
	update_icon()

//a single angry bee, used in Bee-Nades and the Bee Gatling Gun
/mob/living/simple_animal/bee/angry/New(loc, var/obj/machinery/apiary/new_home)
	..()
	initialize()

/mob/living/simple_animal/bee/angry/initialize()
	var/datum/bee/B = new()
	B.species = bees_species[BEESPECIES_NORMAL]
	B.toxic = 50
	B.damage = 2
	addBee(B)
	mood_change(BEE_OUT_FOR_ENEMIES)
	updateDamage()
	update_icon()

/mob/living/simple_animal/bee/hornetgun/New(loc, var/obj/machinery/apiary/new_home)
	..()
	initialize()

/mob/living/simple_animal/bee/hornetgun/initialize()
	var/datum/bee/hornet/B = new()
	B.toxic = 25
	B.damage = 4
	addBee(B)
	mood_change(BEE_OUT_FOR_ENEMIES)
	updateDamage()
	update_icon()

/mob/living/simple_animal/bee/chillgun/New(loc, var/obj/machinery/apiary/new_home)
	..()
	initialize()

/mob/living/simple_animal/bee/chillgun/initialize()
	var/datum/bee/chill/B = new()
	B.toxic = 0
	B.damage = 0
	addBee(B)
	mood_change(BEE_OUT_FOR_PLANTS)
	updateDamage()
	update_icon()

//a swarm of angry bees, used in the Bee-iefcase
/mob/living/simple_animal/bee/swarm/New(loc, var/obj/machinery/apiary/new_home)
	..()
	initialize()

/mob/living/simple_animal/bee/swarm/initialize()
	for (var/i = 1 to MAX_BEES_PER_SWARM)
		var/datum/bee/B = new()
		B.toxic = 50
		B.damage = 2
		B.wild = 1
		addBee(B,FALSE)
	mood_change(BEE_OUT_FOR_ENEMIES)
	updateDamage()

///////////////CHILL BUGS

/mob/living/simple_animal/bee/adminSpawned_chill/New(loc, var/obj/machinery/apiary/new_home)
	..()
	initialize()

/mob/living/simple_animal/bee/adminSpawned_chill/initialize()
	var/datum/bee/chill/B = new()
	addBee(B)
	update_icon()

/mob/living/simple_animal/bee/adminSpawnedQueen_chill/New(loc, var/obj/machinery/apiary/new_home)
	..()
	initialize()

/mob/living/simple_animal/bee/adminSpawnedQueen_chill/initialize()
	var/datum/bee/queen_bee/chill/B = new()
	B.colonizing = 1//so it can start a colony if someone places it in an empty hive
	addBee(B)
	update_icon()

/mob/living/simple_animal/bee/adminSpawnedSwarm_chill/New(loc, var/obj/machinery/apiary/new_home)
	..()
	initialize()

/mob/living/simple_animal/bee/adminSpawnedSwarm_chill/initialize()
	..()
	for (var/i = 1 to MAX_BEES_PER_SWARM)
		var/datum/bee/chill/B = new()
		addBee(B,FALSE)
	updateDamage()

///////////////HORNETS

/mob/living/simple_animal/bee/adminSpawned_hornet/New(loc, var/obj/machinery/apiary/new_home)
	..()
	initialize()

/mob/living/simple_animal/bee/adminSpawned_hornet/initialize()
	var/datum/bee/hornet/B = new()
	addBee(B)
	update_icon()

/mob/living/simple_animal/bee/adminSpawned_hornet/angry/initialize()
	..()
	mood_change(BEE_OUT_FOR_ENEMIES)
	update_icon()

/mob/living/simple_animal/bee/adminSpawnedQueen_hornet/New(loc, var/obj/machinery/apiary/new_home)
	..()
	initialize()

/mob/living/simple_animal/bee/adminSpawnedQueen_hornet/initialize()
	var/datum/bee/queen_bee/hornet/B = new()
	B.colonizing = 1//so it can start a colony if someone places it in an empty hive
	addBee(B)
	update_icon()

/mob/living/simple_animal/bee/adminSpawnedSwarm_hornet/New(loc, var/obj/machinery/apiary/new_home)
	..()
	initialize()

/mob/living/simple_animal/bee/adminSpawnedSwarm_hornet/initialize()
	for (var/i = 1 to MAX_BEES_PER_SWARM)
		var/datum/bee/hornet/B = new()
		B.toxic = 25
		B.damage = 4
		addBee(B,FALSE)
	mood_change(BEE_OUT_FOR_ENEMIES)
	updateDamage()
