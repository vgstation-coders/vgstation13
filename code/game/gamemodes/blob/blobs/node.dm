/obj/effect/blob/node
	name = "blob node"
	icon_state = "node"
	health = 100
	maxhealth = 100
	fire_resist = 2
	custom_process=1
	layer = 6.8
	spawning = 0

/obj/effect/blob/node/New(loc, var/h = 100)
	blob_nodes += src
	processing_objects.Add(src)
	..(loc, h)
	flick("morph_node",src)

/obj/effect/blob/node/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/effect/blob/node/Destroy()
	blob_nodes -= src
	processing_objects.Remove(src)
	..()

/obj/effect/blob/node/Life()
	if(timestopped) return 0 //under effects of time magick

	anim(target = loc, a_icon = 'icons/mob/blob_64x64.dmi', flick_anim = "nodepulse", sleeptime = 15, lay = 12, offX = -16, offY = -16, alph = 150)
	for(var/mob/M in viewers(src))
		M.playsound_local(loc, 'sound/effects/blob_pulse.ogg', 50, 0, null, FALLOFF_SOUNDS, 0)

	for(var/i = 1; i < 8; i += i)
		Pulse(5, i)
	health = min(maxhealth, health + 1)

/obj/effect/blob/node/update_health()
	if(health <= 0)
		playsound(get_turf(src), 'sound/effects/blobsplatspecial.ogg', 50, 1)
		Delete()
		return
	return

/obj/effect/blob/node/run_action()
	return 0

/obj/effect/blob/node/update_icon(var/spawnend = 0)
	spawn(1)
		overlays.len = 0

		overlays += image(icon,"roots", layer = 3)

		if(!spawning)
			for(var/obj/effect/blob/B in orange(src,1))
				overlays += image(icon,"nodeconnect",dir = get_dir(src,B), layer = layer+0.1)
		if(spawnend)
			spawn(10)
				update_icon()


		..()

