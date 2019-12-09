var/datum/subsystem/map_handlers/SSmaph

/datum/subsystem/map_handlers
	name          = "Map handlers"
	wait          = 1 SECONDS
	flags         = SS_NO_INIT | SS_KEEP_TIMING
	priority      = SS_PRIORITY_MAPHANDLER
	display_order = SS_DISPLAY_MAPHANDLER

	var/list/currentrun


/datum/subsystem/map_handlers/New()
	NEW_SS_GLOBAL(SSmaph)


/datum/subsystem/map_handlers/stat_entry()
	..("P:[map_handlers.len]")


/datum/subsystem/map_handlers/fire(resumed = FALSE)
	if (!resumed)
		currentrun = map_handlers.Copy()

	while (currentrun.len)
		var/datum/map_handler/M = currentrun[currentrun.len]
		currentrun.len--

		if (!M || M.gcDestroyed || M.paused)
			continue

		M.Process()

		if (MC_TICK_CHECK)
			return

/datum/map_handler
	var/paused = FALSE
	var/list/spawners = list()
	var/cleanup = 120
	var/area/map

/datum/map_handler/New(var/area/A)
	map = A
	for(var/obj/abstract/spawner/S in A)
		S.handler = src
		S.respawn()
	map_handlers.Add(src)


//Loops through every registered spawner
//If it has a respawn value left, we tick it down by 1
//If it did have a respawn value left that was ticked down, and it is now 0, we handle it.
/datum/map_handler/proc/Process()
	for(var/obj/abstract/spawner/i in spawners)
		if(spawners[i] > 0)
			spawners[i]--
			if(spawners[i] == 0)
				handle_spawner(i)
	if(--cleanup <= 0)
		cleanup = initial(cleanup)
		for(var/obj/item/I in map)
			var/obj/abstract/spawner/S = locate() in get_turf(I)
			if(S && S.spawned == I)
				continue //It has been spawned and not picked up
			qdel(I)
		for(var/mob/living/M in map)
			if(M.stat == DEAD)
				qdel(M)

/datum/map_handler/proc/handle_spawner(var/obj/abstract/spawner/I)
	spawners[I] = null
	spawners.Remove(I)
	I.respawn()

/obj/abstract/spawner
	var/item_to_spawn
	var/respawn_time //As seconds (or however much time the map sub is on)
	var/obj/item/spawned
	var/datum/map_handler/handler
	var/on_pickup_event_key

/obj/abstract/spawner/proc/respawn()
	spawned = new item_to_spawn(loc)
	on_pickup_event_key = spawned.on_pickup.Add(src, "on_pickup")

/obj/abstract/spawner/proc/on_pickup(var/list/args)
	spawned.on_pickup.Remove(on_pickup_event_key)
	spawned = null
	handler.spawners.Add(src)
	handler.spawners[src] = respawn_time

/obj/abstract/spawner/shotgun
	name = "shotgun spawner"
	item_to_spawn = /obj/item/weapon/gun/projectile/shotgun/pump
	respawn_time = 90

/obj/abstract/spawner/grenade
	name = "grenade spawner"
	item_to_spawn = /obj/item/weapon/grenade/syndigrenade
	respawn_time = 20

/obj/abstract/spawner/smg
	name = "smg spawner"
	item_to_spawn = /obj/item/weapon/gun/projectile/automatic/uzi
	respawn_time = 60

/obj/abstract/spawner/ricochet
	name = "ricochet spawner"
	item_to_spawn = /obj/item/weapon/gun/energy/ricochet
	respawn_time = 90

/obj/abstract/spawner/shield
	name = "energy shield spawner"
	item_to_spawn = /obj/item/weapon/shield/energy
	respawn_time = 120

/obj/abstract/spawner/medical
	name = "medical spawner"
	item_to_spawn = /obj/item/weapon/storage/pill_bottle/mednanobots
	respawn_time = 40