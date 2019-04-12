// The assembly piece. I'm not entirely sure if it should be a child of machinery, but it is.
//
//

/obj/item/stack/conveyor_assembly
	name = "conveyor belt assembly"
	singular_name = "conveyor belt"
	desc = "Stick them to the ground to make your very own baggage claim."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor_folded"
	max_amount = 20
	var/active
	var/image/placeimage
	var/placeloc

/obj/item/stack/conveyor_assembly/dropped()
	..()
	if(active)
		returnToPool(active)
		active = null

/obj/item/stack/conveyor_assembly/attack_self(mob/user)
	if(!active) //Start click drag construction
		active = getFromPool(/obj/abstract/screen/draggable, src, user)
		to_chat(user, "Beginning conveyor construction mode, click and drag screen in direction you wish conveyor to go.")
		return
	else
		returnToPool(active)
		active = null

/obj/item/stack/conveyor_assembly/drag_mousedown(mob/user, turf/origin)
	if(istype(origin) && user.Adjacent(origin) && (!locate(/obj/structure/conveyor_assembly) in origin) && (!locate(/obj/machinery/conveyor) in origin) && !origin.density)
		placeimage = image(icon = 'icons/obj/recycling.dmi', icon_state = "conveyor0")
		placeimage.loc = origin
		user.client.images += placeimage
		placeloc = origin
	else
		returnToPool(active)
		active = null

/obj/item/stack/conveyor_assembly/can_drag_use(mob/user, turf/T)
	return placeimage.dir != get_dir(placeloc, T)

/obj/item/stack/conveyor_assembly/drag_use(mob/user, turf/T)
	var/direction = get_dir(placeloc, T)

	var/image/arrow = image(icon = 'icons/mob/screen1.dmi', icon_state = "arrow")
	var/matrix/M = matrix()
	M.Translate(0,-WORLD_ICON_SIZE*1.5)
	M.Turn(dir2angle(direction) + 180)
	arrow.transform = M

	placeimage.dir = direction
	placeimage.overlays = null
	placeimage.overlays += arrow

/obj/item/stack/conveyor_assembly/drag_success(mob/user, turf/T)
	var/direction = get_dir(placeloc, T)
	if(!direction && placeimage.dir)
		direction = placeimage.dir
	var/placelocation = placeloc

	if(user.Adjacent(placeloc) && direction && use(1))
		new /obj/structure/conveyor_assembly(placelocation, direction)
	if(amount && !disposed)
		spawn()
			active = getFromPool(/obj/abstract/screen/draggable, src, user)

/obj/item/stack/conveyor_assembly/end_drag_use(mob/user)
	if(placeimage && user && user.client)
		user.client.images -= placeimage
	placeimage = null
	placeloc = null
	active = null

/obj/item/stack/conveyor_assembly/attackby(obj/item/W, mob/user)
	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal)
			user.visible_message("<span class='warning'>[src] is shaped into metal by [user.name] with the welding tool.</span>", \
			"<span class='warning'>You shape the [src] into metal with the welding tool.</span>", \
			"<span class='warning'>You hear welding.</span>")
			use(1)
			user.put_in_hands(M)
		return 1
	return ..()


/obj/structure/conveyor_assembly
	name = "conveyor belt assembly"
	desc = "At last, your very own baggage claim."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor-assembly"
	density = 0
	anchored = 1

/obj/structure/conveyor_assembly/New(loc, var/newdir)
	. = ..(loc)
	if(newdir)
		dir = newdir

/obj/structure/conveyor_assembly/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It needs some metal sheets applied as plating.</span>")

/obj/structure/conveyor_assembly/attackby(obj/item/P, mob/user)
	if(iscrowbar(P))
		playsound(src, 'sound/items/Crowbar.ogg', 75, 1)
		if(do_after(user, src, 10))
			to_chat(user, "<span class='notice'>You unhinge the frame.</span>")
			getFromPool(/obj/item/stack/conveyor_assembly, src.loc)
			qdel(src)
			return
	else if(istype(P, /obj/item/stack/sheet/metal))
		var/obj/item/stack/S = P
		if(S.amount > 4)
			playsound(src, 'sound/items/Ratchet.ogg', 75, 1)
			if(do_after(user, src, 30) && S.amount > 4)
				S.use(4)
				to_chat(user, "<span class='notice'>You add the plates to \the [src].</span>")
				new /obj/machinery/conveyor(src.loc, src.dir)
				qdel(src)
