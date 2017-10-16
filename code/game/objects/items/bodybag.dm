//Also contains /obj/structure/closet/body_bag because I doubt anyone would think to look for bodybags in /object/structures

/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"

/obj/item/bodybag/attack_self(mob/user)
	var/obj/structure/closet/body_bag/R = new /obj/structure/closet/body_bag(user.loc)
	R.add_fingerprint(user)
	qdel(src)


/obj/item/weapon/storage/box/bodybags
	name = "body bag kit"
	desc = "A kit specifically designed to fit bodybags."
	icon_state = "bodybags" //Consider respriting this to a kit some day
	fits_max_w_class = 3
	max_combined_w_class = 21
	can_only_hold = list("/obj/item/bodybag") //Needed due to the last two variables, figures

/obj/item/weapon/storage/box/bodybags/New()
		..()
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)


/obj/structure/closet/body_bag
	name = "body bag"
	desc = "A plastic bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_closed"
	icon_closed = "bodybag_closed"
	icon_opened = "bodybag_open"
	density = 0


/obj/structure/closet/body_bag/attackby(W as obj, mob/user as mob)
	if(istype(W,/obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/S = W
		if(S.amount<5)
			return
		S.use(5)
		new /obj/structure/morgue(src.loc)
		qdel(src)
	else if(istype(W, /obj/item/weapon/pen) || istype(W, /obj/item/device/flashlight/pen))
		set_tiny_label(user)
	else if(iswirecutter(W))
		remove_label()
		to_chat(user, "<span class='notice'>You cut the tag off the bodybag.</span>")

/obj/structure/closet/body_bag/set_labeled()
	..()
	src.overlays += image(src.icon, "bodybag_label")

/obj/structure/closet/body_bag/remove_label()
	..()
	src.overlays.len = 0


/obj/structure/closet/body_bag/close()
	if(..())
		density = 0
		return 1
	return 0


/obj/structure/closet/body_bag/MouseDrop(over_object, src_location, over_location)
	..()
	if((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
		if((!ishuman(usr) && !ismartian(usr)) || usr.incapacitated() || usr.lying)
			return
		if(opened)
			return 0
		if(contents.len)
			return 0
		visible_message("[usr] folds up the [src.name]")
		new/obj/item/bodybag(get_turf(src))
		spawn(0)
			qdel(src)
		return

/obj/structure/closet/body_bag/update_icon()
	if(!opened)
		icon_state = icon_closed
	else
		icon_state = icon_opened

//Cryobag (statis bag) below, not currently functional it seems

/obj/item/bodybag/cryobag
	name = "stasis bag"
	desc = "A folded, non-reusable bag designed for the preservation of an occupant's brain by stasis."
	icon = 'icons/obj/cryobag.dmi'
	icon_state = "bodybag_folded"

/obj/item/bodybag/cryobag/attack_self(mob/user)
	var/obj/structure/closet/body_bag/cryobag/R = new /obj/structure/closet/body_bag/cryobag(user.loc)
	R.add_fingerprint(user)
	qdel(src)

/obj/structure/closet/body_bag/cryobag
	name = "stasis bag"
	desc = "A non-reusable plastic bag designed for the preservation of an occupant's brain by stasis."
	icon = 'icons/obj/cryobag.dmi'
	icon_state = "bodybag_closed"
	icon_closed = "bodybag_closed"
	icon_opened = "bodybag_open"
	density = 0

	var/used = 0

/obj/structure/closet/body_bag/cryobag/open()
	. = ..()
	if(used)
		var/obj/item/O = new/obj/item(src.loc)
		O.name = "used stasis bag"
		O.icon = src.icon
		O.icon_state = "bodybag_used"
		O.desc = "Pretty useless now.."
		qdel(src)

/obj/structure/closet/body_bag/cryobag/MouseDrop(over_object, src_location, over_location)
	if((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
		if((!ishuman(usr) && !ismartian(usr)) || usr.incapacitated() || usr.lying)
			return
		to_chat(usr, "<span class='warning'>You can't fold that up anymore.</span>")
	..()
