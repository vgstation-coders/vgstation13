/obj/effect/blob/resource
	name = "resource blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_resource"
	health = 30
	fire_resist = 2
	var/mob/camera/blob/overmind = null
	var/resource_delay = 0

/obj/effect/blob/resource/update_icon()
	if(health <= 0)
		playsound(get_turf(src), 'sound/effects/blobsplatspecial.ogg', 50, 1)
		qdel(src)
		return
	return

/obj/effect/blob/resource/run_action()
	if(resource_delay > world.time)
		return 0

	resource_delay = world.time + (4 SECONDS)

	if(overmind)
		overmind.add_points(1)
	return 1
