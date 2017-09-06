/obj/item/mounted/frame/extinguisher_cabinet
	name = "extinguisher cabinet frame"
	desc = "For easy storage of extinguishers."
	icon = 'icons/obj/closet.dmi'
	icon_state = "extinguisher_empty"
	mount_reqs = list("nospace")

/obj/item/mounted/frame/extinguisher_cabinet/do_build(turf/on_wall, mob/user)
	new /obj/structure/extinguisher_cabinet/empty(get_turf(src), get_dir(user, on_wall), 1)
	qdel(src)