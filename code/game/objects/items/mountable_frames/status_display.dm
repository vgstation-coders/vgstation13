/obj/item/mounted/frame/status_display
	name = "status display frame"
	desc = "Used for building status displays."
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	flags = FPRINT
	w_type = RECYK_METAL
	mount_reqs = list("nospace", "simfloor")

/obj/item/mounted/frame/status_display/do_build(turf/on_wall, mob/user)
	new /obj/machinery/status_display(get_turf(src), get_dir(user, on_wall), 0)
	qdel(src)
