/obj/item/mounted/frame/wreath
	name = "wreath"
	desc = "w"
	icon = 'icons/obj/christmas.dmi'
	icon_state = "wreath_bow"
	flags = FPRINT
	starting_materials = list(MAT_IRON = 2*CC_PER_SHEET_METAL)
	melt_temperature = MELTPOINT_STEEL
	w_type = RECYK_METAL


/obj/structure/wreath
	icon = 'icons/obj/christmas.dmi'
	icon_state = "wreath_bow"

/obj/structure/wreath/New(var/newloc, var/ndir, var/built = 1)
	if(!built) //mapped in ones will not break thanks to this
		pixel_x = (ndir & 3) ? 0 : (ndir == 4 ? 24 * PIXEL_MULTIPLIER: -24 * PIXEL_MULTIPLIER)
		pixel_y = (ndir & 3) ? (ndir ==1 ? 24 * PIXEL_MULTIPLIER: -24 * PIXEL_MULTIPLIER) : 0
		dir = ndir
	..()

/obj/item/mounted/frame/wreath/do_build(turf/on_wall, mob/user)
	new /obj/structure/wreath(get_turf(src), get_dir(on_wall, user), 1)
	qdel(src)