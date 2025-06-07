/obj/effect/blob/node
	name = "blob node"
	icon_state = "node"
	desc = "A part of a blob."
	health = 100
	maxHealth = 100
	fire_resist = 2
	custom_process=1
	layer = BLOB_NODE_LAYER
	spawning = 0
	destroy_sound = "sound/effects/blobsplatspecial.ogg"

	icon_new = "node"
	icon_classic = "blob_node"

//obj/effect/blob/node/New(loc,newlook = "new",no_morph = 0) HALLOWEEN
/obj/effect/blob/node/New(loc,newlook = null,no_morph = 0)
	blob_nodes += src
	processing_objects.Add(src)
	..(loc, newlook)

	if((icon_size == 64) && !no_morph)
		flick("morph_node",src)

/obj/effect/blob/node/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/effect/blob/node/Destroy()
	blob_nodes -= src
	if(!manual_remove && overmind)
		to_chat(overmind,"<span class='warning'>A node blob that you had created has been destroyed.</span> <b><a href='?src=\ref[overmind];blobjump=\ref[loc]'>(JUMP)</a></b>")
	if(overmind)
		overmind.special_blobs -= src
		overmind.DisplayUI("Blob")
		overmind.max_blob_points -= BLOBNDPOINTINC
	processing_objects.Remove(src)
	..()

/obj/effect/blob/node/update_looks(var/right_now = 0)
	..()
	var/icon/I = new(icon)
	light_color = I.GetPixel(1,1,"node_color")
	set_light(1, 3, light_color)

/obj/effect/blob/node/Life()
	if(timestopped)
		return 0 //under effects of time magick

	if(asleep)
		return

	if(icon_size == 64)
		anim(target = loc, a_icon = icon, flick_anim = "nodepulse", sleeptime = 15, lay = ABOVE_LIGHTING_LAYER, offX = -16, offY = -16, alph = 150, plane = ABOVE_LIGHTING_PLANE)
		for(var/mob/M in viewers(src))
			M.playsound_local(loc, adminblob_beat, 50, 0, null, FALLOFF_SOUNDS, 0)

	for(var/i = 1; i < 8; i += i)
		Pulse(5, i, overmind)

	if(health < maxHealth)
		health = min(maxHealth, health + 1)
		update_icon()

/obj/effect/blob/node/VisiblePulse(var/pulse = 0)
	if (pulse > 5)
		return
	..(pulse)

/obj/effect/blob/node/run_action()
	return 0

/obj/effect/blob/node/update_icon(var/spawnend = 0)
	if(icon_size == 64)
		spawn(1)
			overlays.len = 0
			underlays.len = 0

			underlays += image(icon,"roots")

			if(!spawning)
				for(var/obj/effect/blob/B in orange(src,1))
					overlays += image(icon,"nodeconnect",dir = get_dir(src,B))
			if(spawnend)
				spawn(10)
					update_icon()


			..()
