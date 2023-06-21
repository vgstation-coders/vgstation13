/obj/effect/blob/shield
	name = "strong blob"
	icon_state = "strong"
	desc = "A dense part of a blob."
	health = 75
	maxHealth = 75
	fire_resist = 2
	layer = BLOB_SHIELD_LAYER
	spawning = 0
	destroy_sound = "sound/effects/blobsplat.ogg"
	icon_new = "strong"
	icon_classic = "blob_idle"

//obj/effect/blob/shield/New(loc,newlook = "new")
/obj/effect/blob/shield/New(turf/loc,newlook = null,no_morph = 0)
	..()
	flick("morph_strong",src)

/obj/effect/blob/shield/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/effect/blob/shield/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover) && mover.checkpass(pass_flags_self))
		return 1
	return 0

/obj/effect/blob/shield/run_action()
	if(health >= 50)
		return 0

	health += 10
	return 1

/obj/effect/blob/shield/update_icon(var/spawnend = 0)
	if(icon_size == 64)
		spawn(1)
			overlays.len = 0
			underlays.len = 0

			underlays += image(icon,"roots")

			if(!spawning)
				for(var/obj/effect/blob/B in orange(src,1))
					overlays += image(icon,"strongconnect",dir = get_dir(src,B))
			if(spawnend)
				spawn(10)
					update_icon()

			..()
