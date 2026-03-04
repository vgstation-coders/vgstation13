
//frame assembly

/obj/item/mounted/frame/rust_fuel_assembly_port
	name = "Fuel Assembly Port frame"
	icon = 'icons/obj/machines/rust.dmi'
	icon_state = "port2"
	w_class = W_CLASS_LARGE
	mount_reqs = list("simfloor", "nospace")
	flags = FPRINT
	siemens_coefficient = 1

/obj/item/mounted/frame/rust_fuel_assembly_port/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (W.is_wrench(user))
		new /obj/item/stack/sheet/plasteel( get_turf(src.loc), 12 )
		qdel(src)
		return
	..()

/obj/item/mounted/frame/rust_fuel_assembly_port/do_build(turf/on_wall, mob/user)
	new /obj/machinery/rust_fuel_assembly_port(get_turf(user), get_dir(user, on_wall), 1)
	qdel(src)

//construction steps
/obj/machinery/rust_fuel_assembly_port/New(turf/loc, var/ndir, var/building=0)
	..()

	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (building)
		dir = ndir
	else
		construct_progress = 3
		icon_state = "port0"

	//20% easier to read than apc code
	pixel_x = (dir & 3)? 0 : (dir == 4 ? WORLD_ICON_SIZE : -WORLD_ICON_SIZE)
	pixel_y = (dir & 3)? (dir ==1 ? WORLD_ICON_SIZE : -WORLD_ICON_SIZE) : 0

/obj/machinery/rust_fuel_assembly_port/attackby(obj/item/W, mob/user)

	if (istype(user, /mob/living/silicon) && get_dist(src,user)>1)
		return src.attack_hand(user)
	if (iscrowbar(W) && construct_progress == 1)
		W.playtoolsound(src, 50)
		to_chat(user, "You begin removing the circuitboard.")
		if(do_after(user, src, 50))
			user.visible_message(\
				"<span class='warning'>[user.name] has removed the circuitboard from [src.name]!</span>",\
				"<span class='notice'>You remove the circuitboard board.</span>")
			new /obj/item/weapon/module/rust_fuel_port(loc)
			construct_progress = 0
		return
	else if (W.is_screwdriver(user) && construct_progress >= 2)
		if(cur_assembly)
			to_chat(user, "<span class='warning'>You cannot open the cover while there is a fuel assembly inside.</span>")
			return
		if(construct_progress == 3)
			to_chat(user, "<span class='notice'>You open the maintenance cover.</span>")
			construct_progress = 2
			icon_state = "port2"
		else
			to_chat(user, "<span class='notice'>You close the maintenance cover.</span>")
			construct_progress = 3
			icon_state = "port0"
		W.playtoolsound(src, 50)
		return
	else if (istype(W, /obj/item/stack/cable_coil) && construct_progress == 1)
		var/obj/item/stack/cable_coil/C = W
		if(C.amount < 10)
			to_chat(user, "<span class='warning'>You need more wires.</span>")
			return
		to_chat(user, "You start adding cables to the frame...")
		W.playtoolsound(src, 50)
		if(do_after(user, src, 20) && C.amount >= 10)
			C.use(10)
			user.visible_message(\
				"<span class='warning'>[user.name] has added cables to the port frame!</span>",\
				"You add cables to the port frame.")
			construct_progress = 2
		return

	else if (W.is_wirecutter(user) && construct_progress == 2)
		to_chat(user, "You begin to cut the cables...")
		W.playtoolsound(src, 50)
		if(do_after(user, src, 50))
			new /obj/item/stack/cable_coil(loc,10)
			user.visible_message(\
				"<span class='warning'>[user.name] cut the cabling inside the port.</span>",\
				"You cut the cabling inside the port.")
			construct_progress = 1
		return

	else if (istype(W, /obj/item/weapon/module/rust_fuel_port) && construct_progress == 0)
		to_chat(user, "You try to insert the port control board into the frame...")
		W.playtoolsound(src, 50)
		if(do_after(user, src, 10))
			construct_progress = 1
			to_chat(user, "You place the port control board inside the frame.")
			qdel(W)
		return

	else if (iswelder(W) && construct_progress == 0)
		var/obj/item/tool/weldingtool/WT = W
		to_chat(user, "You start welding the port frame...")
		if (WT.do_weld(user, src, 50, 3))
			new /obj/item/mounted/frame/rust_fuel_assembly_port(loc)
			user.visible_message(\
				"<span class='warning'>[src] has been cut away from the wall by [user.name].</span>",\
				"You detached the port frame.",\
				"<span class='warning'>You hear welding.</span>")
			qdel(src)
		return

	..()
