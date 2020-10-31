
/datum/map_element/vault/anomalylab
	name = "Anomaly Facility"
	file_path = "maps/randomvaults/anomalycenter.dmm"

/datum/map_element/vault/anomalylab/initialize(list/objects)
	..()

	var/area/vault/anomalylab/S = locate(/area/vault/anomalylab)
	S.setup()

/area/vault/anomalylab
	name = "Anomaly Facility"
	flags = NO_PORTALS | NO_TELEPORT
	jammed = 2

	var/lockdown = FALSE

	var/datum/map_element/vault/anomalylab/map_element
	var/list/visceratorspawns = list()
	var/obj/effect/landmark/anomalylab/statue_spawn/statuespawn
	var/list/lights = list()
	var/list/doors = list()

/area/vault/anomalylab/spawned_by_map_element(datum/map_element/ME)
	if(istype(ME, /datum/map_element/vault/anomalylab))
		map_element = ME

	..()


/area/vault/anomalylab/proc/setup()
	spawn()

		for(var/obj/machinery/chem_dispenser/scp_294/coffee in contents)
			coffee.lazy_register_event(/lazy_event/on_moved, src, .proc/coffee_stolen)
		for(var/obj/effect/landmark/anomalylab/viscerator_spawn/L in contents)
			visceratorspawns += L
		for(var/obj/effect/landmark/anomalylab/statue_spawn/L in contents)
			statuespawn = L
			break
		for(var/obj/machinery/light/L in contents)
			lights += L
		for(var/obj/machinery/door/airlock/A in contents)
			doors += A

/area/vault/anomalylab/proc/coffee_stolen(atom/movable/mover)
	if(lockdown)
		return


	for(var/mob/living/M in contents)
		to_chat(M, "<span class='userdanger'>As you try to move the machine, a loud alarm start to blare!</span>")
		M << 'sound/machines/warning-buzzer.ogg'

	for(var/obj/effect/landmark/anomalylab/viscerator_spawn/L in visceratorspawns)
		var/mob/living/simple_animal/hostile/viscerator/V = new /mob/living/simple_animal/hostile/viscerator(L.loc)
		V.visible_message("<span class='warning'>\The [V] ejects itself from the floor and activates!</span>")

	var/mob/living/simple_animal/scp_173/S = new /mob/living/simple_animal/scp_173(statuespawn.loc)
	S.visible_message("<span class='warning'>\The [S] suddenly appears!</span>")

	for(var/obj/machinery/light/L in lights)
		L.broken()
	for(var/obj/machinery/door/airlock/A in doors)
		A.close()
		A.locked = TRUE

	mover.lazy_unregister_event(/lazy_event/on_moved, src, .proc/coffee_stolen)
	lockdown = TRUE

/obj/effect/landmark/anomalylab/viscerator_spawn
	name = "Viscerator Spawn"

/obj/effect/landmark/anomalylab/statue_spawn
	name = "SCP-173 Spawn"
