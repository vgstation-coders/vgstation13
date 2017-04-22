/obj/effect/blob/shield
	name = "strong blob"
	icon_state = "strong"
	desc = "A dense part of a blob."
	health = 75
	maxhealth = 75
	fire_resist = 2
	layer = BLOB_SHIELD_LAYER
	spawning = 0
	destroy_sound = "sound/effects/blobsplat.ogg"

	icon_new = "strong"
	icon_classic = "blob_idle"

/obj/effect/blob/shield/New(loc,newlook = "new")
	..()
	flick("morph_strong",src)

/obj/effect/blob/shield/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/effect/blob/shield/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover) && mover.checkpass(PASSBLOB))
		return 1
	if(mover)
		mover.Bump(src) //Only automatic for dense objects
	return 0

/obj/effect/blob/shield/run_action()
	if(health >= 50)
		return 0

	health += 10
	return 1
/*
/obj/effect/blob/shield/Pulse(var/pulse = 0, var/origin_dir = 0)
	..()
	if(blob_looks[looks] == 64)
		anim(target = loc, a_icon = 'icons/mob/blob_64x64.dmi', flick_anim = "strongpulse", sleeptime = 15, lay = 12, offX = -16, offY = -16, alph = 51)
*/
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
