/obj/effect/blob/resource
	name = "resource blob"
	icon_state = "resource"
	health = 30
	maxhealth = 30
	fire_resist = 2
	var/mob/camera/blob/overmind = null
	var/resource_delay = 0
	spawning = 0
	layer = 6.4

/obj/effect/blob/resource/New(loc)
	..()
	flick("morph_resource",src)

/obj/effect/blob/resource/update_health()
	if(health <= 0)
		playsound(get_turf(src), 'sound/effects/blobsplatspecial.ogg', 50, 1)
		qdel(src)
		return
	return

/obj/effect/blob/resource/run_action()
	if(resource_delay > world.time)
		return 0

	resource_delay = world.time + (4 SECONDS)

	anim(target = loc, a_icon = 'icons/mob/blob_64x64.dmi', flick_anim = "resourcepulse", sleeptime = 15, lay = 7.2, offX = -16, offY = -16, alph = 220)

	if(overmind)
		overmind.add_points(1)
	return 1

/obj/effect/blob/resource/update_icon(var/spawnend = 0)
	spawn(1)
		overlays.len = 0

		overlays += image(icon,"roots", layer = 3)

		if(!spawning)
			for(var/obj/effect/blob/B in orange(src,1))
				overlays += image(icon,"resourceconnect",dir = get_dir(src,B), layer = layer+0.1)
		if(spawnend)
			spawn(10)
				update_icon()

		..()
