/obj/item/weapon/grenade/chronogrenade
	name = "chrono grenade"
	desc = "This experimental weapon will halt the progression of time in the local area for ten seconds."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "chrono_grenade"
	item_state = "flashbang"
	flags = FPRINT | TIMELESS
	var/duration = 10 SECONDS
	var/radius = 5		//in tiles
	mech_flags = MECH_SCAN_FAIL

/obj/item/weapon/grenade/chronogrenade/prime()
	timestop(src, duration, radius)
	qdel(src)
	
/obj/item/weapon/grenade/chronogrenade/carbon
	name = "chrono-carbon grenade"
	desc = "This experimental weapon will halt the progression of time in the local area for ten seconds. Carbon lifeforms are not affected by the field."
	icon_state = "past_grenade"
	duration = 15 SECONDS

/obj/item/weapon/grenade/chronogrenade/carbon/prime()
	timestop(src, duration, radius, 0, /mob/living/carbon/)
	qdel(src)	
	
/obj/item/weapon/grenade/chronogrenade/future
	desc = "This experimental weapon will send all entities in the local area ten seconds into the future."
	icon_state = "future_grenade"

/obj/item/weapon/grenade/chronogrenade/future/prime()
	future_rift(src, duration, radius)
	qdel(src)

/proc/future_rift(atom/A, var/duration, var/range = 7, var/ignore_timeless = FALSE, var/single_target = FALSE)	//Sends all non-timeless atoms in range duration time into the future.
	if(!A || !duration)
		return

	var/turf/ourturf = get_turf(A)
	var/list/targets = circlerangeturfs(A, range)
	spawn()
		showrift(ourturf, range)

	playsound(A, 'sound/effects/fall.ogg', 100, 0, 0, 0, 0)

	if(single_target)
		if(istype(A, /atom/movable))
			var/atom/movable/AM = A
			AM.attempt_future_send(duration, ignore_timeless)
	else
		for(var/turf/T in targets)
			for(var/atom/movable/everything in T)
				everything.attempt_future_send(duration, ignore_timeless)
	spawn(duration)
		spawn(1)	//so that mobs deafened by the effect will still hear the sound when it ends
			playsound(ourturf, 'sound/effects/fall.ogg', 100, 0, 0, 0, 0)
		showrift(ourturf, range)

/atom/movable/proc/attempt_future_send(var/duration, var/ignore_timeless = FALSE)
	if(!duration)
		return
	if(!ignore_timeless && flags & TIMELESS)
		return
	if(being_sent_to_past)	//allowing future grenades to interact with past-tethered atoms would be a nightmare
		return
	send_to_future(duration)
	if(ismob(src))
		var/mob/M = src
		M.playsound_local(M, 'sound/effects/fall2.ogg', 100, 0, 0, 0, 0)


/obj/item/weapon/grenade/chronogrenade/past
	desc = "This experimental weapon will, 30 seconds after detonation, reset everything in the local area at the time of detonation to its state at the time of detonation."
	icon_state = "past_grenade"
	duration = 30 SECONDS

/obj/item/weapon/grenade/chronogrenade/past/prime()
	past_rift(src, duration, radius)
	qdel(src)

/proc/past_rift(atom/A, var/duration, var/range = 7, var/ignore_timeless = FALSE, var/single_target = FALSE)	//After duration time, resets all non-timeless atoms in range at detonation to their current state.
	if(!A || !duration)
		return

	var/turf/ourturf = get_turf(A)
	var/list/targets = circlerangeturfs(A, range)
	spawn()
		showrift(ourturf, range)

	playsound(A, 'sound/effects/fall.ogg', 100, 0, 0, 0, 0)

	if(single_target)
		A.attempt_past_send(duration, ignore_timeless)
	else
		for(var/turf/T in targets)
			for(var/atom/movable/everything in T)
				everything.attempt_past_send(duration, ignore_timeless)
			T.send_to_past(duration)
	spawn(duration)
		spawn(1)
			playsound(ourturf, 'sound/effects/fall.ogg', 100, 0, 0, 0, 0)
		showrift(ourturf, range)

/atom/proc/attempt_past_send(var/duration, var/ignore_timeless = FALSE)
	if(!duration)
		return
	if(!ignore_timeless && flags & TIMELESS)
		return
	if(being_sent_to_past)	//no stacking past-tethering
		return
	send_to_past(duration)
	if(ismob(src))
		var/mob/M = src
		M.playsound_local(M, 'sound/effects/fall2.ogg', 100, 0, 0, 0, 0)

/proc/showrift(var/turf/T, var/range)
	for(var/client/C in clients)
		if(C.mob)
			C.mob.see_fall(T, range)
	spawn(10)
		for(var/client/C in clients)
			if(C.mob)
				C.mob.see_fall()