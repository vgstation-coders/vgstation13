/datum/event/old_vendotron_teleport
	endWhen = 15
	announceWhen = 5

/datum/event/old_vendotron_teleport/can_start()
	return 15

/datum/event/old_vendotron_teleport/setup()
	startWhen = rand(5, 15)

/datum/event/old_vendotron_teleport/announce()
	command_alert(/datum/command_alert/old_vendotron_teleport)

/datum/event/old_vendotron_teleport/start()
	teleportVendor()

/datum/event/old_vendotron_teleport/proc/teleportVendor()
	var/turf/vendT = vendSpawnDecide()
	to_chat(world, "Spawn location is x[vendT.x] y[vendT.y] z[vendT.z]")
	fancyEntrance(vendT)

/datum/event/old_vendotron_teleport/proc/vendSpawnDecide()
	var/list/dontSpawnHere = list(
		/area/derelictparts,
		/area/solar,
		/area/assembly,	//Because I don't know what that is
		/area/shuttle/administration/station,
		/area/ai_monitored/storage/emergency,
		/area/arrival,
	)
	var/list/vendSpawnAreas = the_station_areas - dontSpawnHere
	var/area/toSpawn = pick(vendSpawnAreas)
	toSpawn = locate(toSpawn)
	to_chat(world, "toSpawn is [toSpawn.name]")
	var/list/turf/simulated/floor/vendSpawn = list()
	for(var/turf/simulated/floor/F in toSpawn)
		if(!F.has_dense_content())
			vendSpawn.Add(F)
	if(!vendSpawn.len)	//Copy paste from infestation
		message_admins("Old Vendotron event has failed! Could not find any viable turfs in [toSpawn].")
		announceWhen = -1
		endWhen = 0
		return
	return pick(vendSpawn)

/datum/event/old_vendotron_teleport/proc/fancyEntrance(var/turf/vendT)
	var/obj/effect/old_vendotron_entrance/E = new /obj/effect/old_vendotron_entrance(vendT)
	to_chat(world, "made the portal")
	E.aestheticEntrance()
	to_chat(world, "entrance got fancy")
	playsound(E, 'sound/effects/eleczap.ogg', 100, 1)
	spawn(4 SECONDS)
		to_chat(world, "Been 4 seconds")
		var/obj/machinery/vending/old_vendotron/OV = new /obj/machinery/vending/old_vendotron(vendT)
		playsound(OV, 'sound/effects/coins.ogg', 100, 1)

/obj/effect/old_vendotron_entrance
	name = "unknown bluespace tear"
	icon_state = "anom"
	alpha = 0

/obj/effect/old_vendotron_entrance/New()
	..()
	for(var/mob/dead/observer/people in observers)
		to_chat(people, "<span class = 'notice'>\An old vendotron has been teleported onto the station, <a href='?src=\ref[people];follow=\ref[src]'>Follow it</a></span>")

/obj/effect/old_vendotron_entrance/proc/aestheticEntrance()
	to_chat(world, "Starting entrance")
	animate(src, alpha = 255, transform = matrix()*2, time = 3 SECONDS)
	to_chat(world, "phase 2")
	spawn(3 SECONDS)
		animate(src, icon_state = "bhole3", transform = matrix()*0.1, time = 3 SECONDS)
	spawn(35)
		qdel(E)
