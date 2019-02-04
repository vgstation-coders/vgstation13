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

/obj/item/weapon/grenade/inflatable/station
	name = "Discount Dans Inflatable Station in a can"
	desc = "Packed full of inflatable bits! Do not chew."
	var/range = 7


/**
	Makes an instant inflatable station
**/
/obj/item/weapon/grenade/inflatable/station/prime()
	playsound(src, 'sound/items/zip.ogg', 75, 1)
	var/list/possible_trash = subtypesof(/obj/item/trash)-typesof(/obj/item/trash/mannequin)
	var/turf/source = get_turf(src)
	for(var/mob/living/M in view(source, range))
		if(get_turf(M) == source)
			M.gib()
			continue
		to_chat(M, "<span class = 'warning'>You are bounced away from \the [src] as it deploys!</span>")
		M.throw_at(get_ranged_target_turf(source, get_dir(source, M), range*3), 50, 3)
	var/list/interior = generate_room(source, range, /obj/structure/inflatable/wall, /turf/simulated/floor/inflatable/air, /obj/structure/inflatable/door)
	var/obj/structure/inflatable/R = new /obj/structure/inflatable/wall(source)
	for(var/turf/T in interior)
		if(prob(30))
			var/new_trash = pick(possible_trash)
			new new_trash(T)
	R.spawn_undeployed = FALSE
	qdel(src)