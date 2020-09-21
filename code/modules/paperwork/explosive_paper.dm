/obj/item/paper/explosive
	var/fuse_time = 5 SECONDS
	var/detonating = FALSE

/obj/item/paper/explosive/examine(mob/user)
	if(user.range_check(src))
		detonate()
	..()

/obj/item/paper/explosive/attackby(obj/item/P as obj, mob/user as mob)
	if(istype(P, /obj/item/pen) || istype(P, /obj/item/toy/crayon))
		if(!(istype(P, /obj/item/pen/robopen) && P:mode == 2))
			detonate()
	..()

/obj/item/paper/explosive/proc/detonate()
	if(!detonating)
		if(info)
			info += "<BR><BR>THIS MESSAGE WILL SELF-DESTRUCT IN [fuse_time/10] SECONDS"
			updateinfolinks()
			detonating = TRUE
			spawn(fuse_time)
				explosion(get_turf(src), -1, 0, 2)
				qdel(src)