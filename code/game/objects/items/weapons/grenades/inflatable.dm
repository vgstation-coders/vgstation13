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
	var/turf/source = get_turf(src)
	var/list/possible_trash = subtypesof(/obj/item/trash)-typesof(/obj/item/trash/mannequin)
	var/list/full_affected_area = circleviewturfs(source, range)
	for(var/mob/living/M in view(source, range))
		if(get_turf(M) == source)
			M.gib()
			continue
		to_chat(M, "<span class = 'warning'>You are bounced away from \the [src] as it deploys!</span>")
		M.throw_at(get_ranged_target_turf(source, get_dir(source, M), range*3), 50, 3)
	var/list/interior = circleviewturfs(src, range-1)
	for(var/turf/T in full_affected_area)
		if(!(interior.Find(T)))
			var/obj/structure/inflatable/R
			if(cardinal.Find(get_dir(T, source)))
				R = new /obj/structure/inflatable/door(T)
			else
				R = new /obj/structure/inflatable/wall(T)
			R.spawn_undeployed = FALSE
		if(prob(30) && interior.Find(T))
			var/new_trash = pick(possible_trash)
			new new_trash(T)
		if(istype(T, get_base_turf(T.z)))
			T.ChangeTurf(/turf/simulated/floor/inflatable/air)

	var/obj/structure/inflatable/R = new /obj/structure/inflatable/wall(source)
	R.spawn_undeployed = FALSE
	qdel(src)