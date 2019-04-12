/obj/item/mounted/frame/wreath
	name = "wreath"
	desc = "A festive holiday wreath"
	icon = 'icons/obj/christmas.dmi'
	icon_state = "wreath_bow"
	flags = FPRINT
	starting_materials = list(MAT_IRON = 2*CC_PER_SHEET_METAL)
	melt_temperature = MELTPOINT_STEEL
	w_type = RECYK_METAL

/obj/structure/wreath
	desc = "A festive holiday wreath"
	icon = 'icons/obj/christmas.dmi'
	icon_state = "wreath_bow"

/obj/structure/wreath/wreath_bow
	name = "wreath"
	desc = "A festive holiday wreath"
	icon_state = "wreath_bow"

/obj/structure/wreath/wreath_bow/attackby(obj/item/W as obj, mob/user as mob)
	if(iscrowbar(W))
		to_chat(user, "You begin prying \the [src] off the wall.")
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, src,10))
			to_chat(user, "<span class='notice'>You pry \the [src] off of the wall.</span>")
			new /obj/item/mounted/frame/wreath/wreath_bow(get_turf(user))
			qdel(src)
		return
	return ..()

/obj/structure/wreath/New(var/newloc, var/ndir, var/built = 1)
	if(built) //mapped in ones will not break thanks to this
		pixel_x = (ndir & 3) ? 0 : (ndir == 4 ? -24 * PIXEL_MULTIPLIER: 24 * PIXEL_MULTIPLIER)
		pixel_y = (ndir & 3) ? (ndir == 1 ? -24 * PIXEL_MULTIPLIER: 24 * PIXEL_MULTIPLIER) : 0
		dir = ndir
	..()

/obj/item/mounted/frame/wreath/wreath_bow/do_build(turf/on_wall, mob/user)
	new /obj/structure/wreath/wreath_bow(get_turf(src), get_dir(on_wall, user), 1)
	qdel(src)

/obj/item/mounted/frame/wreath/wreath_nobow
	desc = "A holiday wreath decked with holly"
	icon_state = "wreath_nobow"

/obj/structure/wreath/wreath_nobow
	name = "wreath"
	desc = "A holiday wreath decked with holly"
	icon_state = "wreath_nobow"

/obj/structure/wreath/wreath_nobow/attackby(obj/item/W as obj, mob/user as mob)
	if(iscrowbar(W))
		to_chat(user, "You begin prying \the [src] off the wall.")
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, src,10))
			to_chat(user, "<span class='notice'>You pry \the [src] off of the wall.</span>")
			new /obj/item/mounted/frame/wreath/wreath_nobow(get_turf(user))
			qdel(src)
		return
	return ..()

/obj/item/mounted/frame/wreath/wreath_nobow/do_build(turf/on_wall, mob/user)
	new /obj/structure/wreath/wreath_nobow(get_turf(src), get_dir(on_wall, user), 1)
	qdel(src)