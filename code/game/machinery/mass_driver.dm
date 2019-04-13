var/list/mass_drivers = list()
/obj/machinery/mass_driver
	name = "mass driver"
	desc = "Shoots things into space."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mass_driver"
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 50
	machine_flags = EMAGGABLE | MULTITOOL_MENU
	layer = BELOW_TABLE_LAYER

	var/power = 1.0
	var/code = 1.0
	var/id_tag = "default"
	var/drive_range = 50 //this is mostly irrelevant since current mass drivers throw into space, but you could make a lower-range mass driver for interstation transport or something I guess.

/obj/machinery/mass_driver/New()
	..()
	mass_drivers += src
	check_competition()

/obj/machinery/mass_driver/proc/check_competition(var/turf/T = get_turf(src))
	for(var/obj/machinery/mass_driver/M in T)
		if(M == src)
			continue
		else
			message_admins("Two mass drivers were placed on the same tile. This should not happen.(<A href='?_src_=holder;jumpto=\ref[T]'><b>Jump to</b></A>)")
			qdel(src)
			break

/obj/machinery/mass_driver/Destroy()
	mass_drivers -= src
	..()

/obj/machinery/mass_driver/attackby(obj/item/weapon/W, mob/user as mob)

	. = ..()
	if(.)
		return .

	if(W.is_screwdriver(user))
		to_chat(user, "You begin to unscrew the bolts off the [src]...")
		playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
		if(do_after(user, src, 30))
			var/obj/machinery/mass_driver_frame/F = new(get_turf(src))
			F.dir = src.dir
			F.anchored = 1
			F.build = 4
			F.update_icon()
			qdel(src)
		return 1

	return ..()

/obj/machinery/mass_driver/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
	<ul>
	<li>[format_tag("ID Tag","id_tag")]</li>
	</ul>"}

/obj/machinery/mass_driver/proc/drive(amount)
	if(stat & (BROKEN|NOPOWER))
		return
	use_power(500*power)
	var/O_limit = 0
	var/atom/target = get_edge_target_turf(src, dir)
	for(var/atom/movable/O in loc)
		if(!O.anchored||istype(O, /obj/mecha))//Mechs need their launch platforms.
			O_limit++
			if(istype(O,/obj/mecha))
				var/obj/mecha/M = O
				M.crashing = null
			if(O_limit >= 20)//so no more than 20 items are sent at a time, probably for counter-lag purposes
				break
			use_power(500)
			spawn()
				var/coef = 1
				if(emagged)
					coef = 5
				O.throw_at(target, drive_range * power * coef, power * coef)
	flick("mass_driver1", src)
	return

/obj/machinery/mass_driver/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return
	drive()
	..(severity)

/obj/machinery/mass_driver/emag(mob/user)
	if(!emagged)
		emagged = 1
		if(user)
			to_chat(user, "You hack the Mass Driver, radically increasing the force at which it'll throw things. Better not stand in its way.")
		return 1
	return -1 //GROSS

////////////////MASS BUMPER///////////////////

/obj/machinery/mass_driver/bumper
	name = "mass bumper"
	desc = "Now you're here, now you're over there."
	density = 1

/obj/machinery/mass_driver/bumper/Bumped(M as mob|obj)
	setDensity(FALSE)
	step(M, get_dir(M,src))
	spawn(1)
		setDensity(TRUE)
	drive()
	return

////////////////MASS DRIVER FRAME///////////////////

/obj/machinery/mass_driver_frame
	name = "mass driver frame"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mass_driver_b0"
	density = 0
	anchored = 0
	var/build = 0

/obj/machinery/mass_driver_frame/proc/check_competition(var/turf/T = get_turf(src))
	var/competition_found = 0
	for(var/obj/machinery/M in T)
		if(M == src)
			continue
		if(istype(M, /obj/machinery/mass_driver_frame) || istype(M, /obj/machinery/mass_driver))
			competition_found=1
			break

	return competition_found

/obj/machinery/mass_driver_frame/attackby(var/obj/item/W as obj, var/mob/user as mob)
	switch(build)
		if(0) // Loose frame
			if(iswelder(W))
				var/obj/item/weapon/weldingtool/WT = W
				to_chat(user, "You begin to cut the frame apart...")
				if(WT.do_weld(user, src, 30) && (build == 0))
					to_chat(user, "<span class='notice'>You detach the plasteel sheets from each others.</span>")
					new /obj/item/stack/sheet/plasteel(get_turf(src),3)
					qdel(src)
				return 1
			if(iswrench(W))
				if(check_competition())
					to_chat(user, "<span class = 'notice'>You can't anchor \the [src], as there's a mass driver in that location already.</span>")
					return
				to_chat(user, "You begin to anchor \the [src] on the floor.")
				playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
				if(do_after(user, src, 10) && (build == 0))
					to_chat(user, "<span class='notice'>You anchor \the [src]!</span>")
					anchored = 1
					build++
					update_icon()
				return 1
		if(1) // Fixed to the floor
			if(iswrench(W))
				to_chat(user, "You begin to de-anchor \the [src] from the floor.")
				playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
				if(do_after(user, src, 10) && (build == 1))
					build--
					update_icon()
					anchored = 0
					to_chat(user, "<span class='notice'>You de-anchored \the [src]!</span>")
				return 1
			if(iswelder(W))
				var/obj/item/weapon/weldingtool/WT = W
				to_chat(user, "You begin to weld \the [src] to the floor...")
				if(WT.do_weld(user, src, 40) && (build == 1))
					to_chat(user, "<span class='notice'>You welded \the [src] to the floor.</span>")
					build++
					update_icon()
				return 1
		if(2) // Welded to the floor
			if(iswelder(W))
				var/obj/item/weapon/weldingtool/WT = W
				to_chat(user, "You begin to unweld \the [src] to the floor...")
				if(WT.do_weld(user, src, 40) && (build == 2))
					to_chat(user, "<span class='notice'>You unwelded \the [src] to the floor.</span>")
					build--
					update_icon()
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C=W
				to_chat(user, "You start adding cables to \the [src]...")
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				if(do_after(user, src, 20) && (C.amount >= 3) && (build == 2))
					C.use(3)
					to_chat(user, "<span class='notice'>You've added cables to \the [src].</span>")
					build++
					update_icon()
		if(3) // Wired
			if(iswirecutter(W))
				to_chat(user, "You begin to remove the wiring from \the [src].")
				if(do_after(user, src, 10) && (build == 3))
					new /obj/item/stack/cable_coil(loc,3)
					playsound(src, 'sound/items/Wirecutter.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You've removed the cables from \the [src].</span>")
					build--
					update_icon()
				return 1
			if(istype(W, /obj/item/stack/rods))
				var/obj/item/stack/rods/R=W
				to_chat(user, "You begin to complete \the [src]...")
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				if(do_after(user, src, 20) && (R.amount >= 3) && (build == 3))
					R.use(3)
					to_chat(user, "<span class='notice'>You've added the grille to \the [src].</span>")
					build++
					update_icon()
				return 1
		if(4) // Grille in place
			if(iscrowbar(W))
				to_chat(user, "You begin to pry off the grille from \the [src]...")
				playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
				if(do_after(user, src, 30) && (build == 4))
					new /obj/item/stack/rods(loc,2)
					build--
					update_icon()
				return 1
			if(W.is_screwdriver(user))
				to_chat(user, "You finalize the Mass Driver...")
				playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
				var/obj/machinery/mass_driver/M = new(get_turf(src))
				M.dir = src.dir
				qdel(src)
				return 1
	..()

/obj/machinery/mass_driver_frame/update_icon()
	icon_state = "mass_driver_b[build]"

/obj/machinery/mass_driver_frame/verb/rotate()
	set category = "Object"
	set name = "Rotate Frame"
	set src in view(1)

	if (usr.isUnconscious() || usr.restrained())
		return

	src.dir = turn(src.dir, -90)
	return
