/obj/effect/blob/shield
	name = "strong blob"
	desc = "Some blob creature thingy"
	health = 75
	fire_resist = 2


/obj/effect/blob/shield/update_health()
	if(health <= 0)
		playsound(get_turf(src), 'sound/effects/blobsplat.ogg', 50, 1)
		qdel(src)
		return
	return

/obj/effect/blob/shield/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/effect/blob/shield/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover) && mover.checkpass(PASSBLOB))	return 1
	return 0

/obj/effect/blob/shield/run_action()
	if(health >= 50)
		return 0

	health += 10
	return 1
