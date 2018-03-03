/obj/item/weapon/grenade/inflatable
	name = "inflatable barrier grenade"
	desc = "An inflatable barrier conveniently packaged into a casing for remote delivery. Non-reusable."
	var/deploy_path = /obj/structure/inflatable/wall
	mech_flags = null

/obj/item/weapon/grenade/inflatable/prime()
	playsound(src, 'sound/items/zip.ogg', 75, 1)
	var/obj/structure/inflatable/R = new deploy_path(get_turf(src))
	R.spawn_undeployed = FALSE
	qdel(src)

/obj/item/weapon/grenade/inflatable/door
	name = "inflatable door grenade"
	desc = "An inflatable door conveniently packaged into a casing for remote delivery. Non-reusable."
	deploy_path = /obj/structure/inflatable/door