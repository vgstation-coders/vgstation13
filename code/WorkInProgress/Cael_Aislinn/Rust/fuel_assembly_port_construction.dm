
//frame assembly

/obj/item/mounted/frame/rust_fuel_assembly_port
	name = "Fuel Assembly Port frame"
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "port2"
	w_class = W_CLASS_LARGE
	mount_reqs = list("simfloor", "nospace")
	flags = FPRINT
	siemens_coefficient = 1

/obj/item/mounted/frame/rust_fuel_assembly_port/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (iswrench(W))
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
		has_electronics = 3
		opened = 0
		icon_state = "port0"

	//20% easier to read than apc code
	pixel_x = (dir & 3)? 0 : (dir == 4 ? WORLD_ICON_SIZE : -WORLD_ICON_SIZE)
	pixel_y = (dir & 3)? (dir ==1 ? WORLD_ICON_SIZE : -WORLD_ICON_SIZE) : 0

/obj/machinery/rust_fuel_assembly_port/attackby(obj/item/W, mob/user)

	if (istype(user, /mob/living/silicon) && get_dist(src,user)>1)
		return src.attack_hand(user)
	if (iscrowbar(W))
		if(opened)
			if(has_electronics & 1)
				playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
				to_chat(user, "You begin removing the circuitboard")//lpeters - fixed grammar issues

				if(do_after(user, src, 50))
					user.visible_message(\
						"<span class='warning'>[user.name] has removed the circuitboard from [src.name]!</span>",\
						"<span class='notice'>You remove the circuitboard.</span>")
					has_electronics = 0
					new /obj/item/weapon/module/rust_fuel_port(loc)
					has_electronics &= ~1
			else
				opened = 0
				icon_state = "port0"
				to_chat(user, "<span class='notice'>You close the maintenance cover.</span>")
		else
			if(cur_assembly)
				to_chat(user, "<span class='warning'>You cannot open the cover while there is a fuel assembly inside.</span>")
			else
				opened = 1
				to_chat(user, "<span class='notice'>You open the maintenance cover.</span>")
				icon_state = "port2"
		return

	else if (istype(W, /obj/item/stack/cable_coil) && opened && !(has_electronics & 2))
		var/obj/item/stack/cable_coil/C = W
		if(C.amount < 10)
			to_chat(user, "<span class='warning'>You need more wires.</span>")
			return
		to_chat(user, "You start adding cables to the frame...")
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, src, 20) && C.amount >= 10)
			C.use(10)
			user.visible_message(\
				"<span class='warning'>[user.name] has added cables to the port frame!</span>",\
				"You add cables to the port frame.")
			has_electronics &= 2
		return

	else if (iswirecutter(W) && opened && (has_electronics & 2))
		to_chat(user, "You begin to cut the cables...")
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, src, 50))
			new /obj/item/stack/cable_coil(loc,10)
			user.visible_message(\
				"<span class='warning'>[user.name] cut the cabling inside the port.</span>",\
				"You cut the cabling inside the port.")
			has_electronics &= ~2
		return

	else if (istype(W, /obj/item/weapon/module/rust_fuel_port) && opened && !(has_electronics & 1))
		to_chat(user, "You try to insert the port control board into the frame...")
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, src, 10))
			has_electronics &= 1
			to_chat(user, "You place the port control board inside the frame.")
			qdel(W)
		return

	else if (iswelder(W) && opened && !has_electronics)
		var/obj/item/weapon/weldingtool/WT = W
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
