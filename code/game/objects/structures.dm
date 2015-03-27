obj/structure
	icon = 'icons/obj/structures.dmi'

obj/structure/blob_act()
	if(prob(50))
		del(src)

obj/structure/ex_act(severity)
	if(prob(min(severity, 100)))
		if(contents)
			for(var/atom/movable/A in contents)
				A.loc = src.loc
				A.ex_act(severity)
		qdel(src)
	return

obj/structure/meteorhit(obj/O as obj)
	del(src)

/obj/structure/Destroy()
	if(hascall(src, "unbuckle"))
		src:unbuckle()

	..()