/obj/item/weapon/grenade/chronogrenade
	name = "chrono grenade"
	desc = "This experimental weapon will halt the progression of time in the local area for ten seconds."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "chrono_grenade"
	item_state = "flashbang"
	flags = FPRINT | TIMELESS
	var/duration = 10 SECONDS
	var/radius = 5		//in tiles

/obj/item/weapon/grenade/chronogrenade/prime()
	timestop(src, duration, radius)
	qdel(src)

/obj/item/weapon/grenade/chronogrenade/future
	desc = "This experimental weapon will send all entities in the local area ten seconds into the future."
	icon_state = "future_grenade"

/obj/item/weapon/grenade/chronogrenade/future/prime()
	future_rift(src, duration, radius)
	qdel(src)

/proc/future_rift(atom/A, var/duration, var/range = 7)	//Sends all non-timeless atoms in range duration time into the future.
	if(!A || !duration)
		return

	var/turf/ourturf = get_turf(A)
	var/list/targets = circlerangeturfs(A, range)
	spawn()
		for(var/client/C in clients)
			if(C.mob)
				C.mob.see_fall(ourturf, range)
		spawn(10)
			for(var/client/C in clients)
				if(C.mob)
					C.mob.see_fall()

	playsound(A, 'sound/effects/fall.ogg', 100, 0, 0, 0, 0)

	for(var/turf/T in targets)
		for(var/atom/movable/everything in T)
			if(everything.flags & TIMELESS)
				continue
			everything.send_to_future(duration)
			if(ismob(everything))
				var/mob/M = everything
				M.playsound_local(everything, 'sound/effects/fall2.ogg', 100, 0, 0, 0, 0)
	spawn(duration)
		spawn(1)	//so that mobs deafened by the effect will still hear the sound when it ends
			playsound(ourturf, 'sound/effects/fall.ogg', 100, 0, 0, 0, 0)
		for(var/client/C in clients)
			if(C.mob)
				C.mob.see_fall(ourturf, range)
		spawn(10)
			for(var/client/C in clients)
				if(C.mob)
					C.mob.see_fall()