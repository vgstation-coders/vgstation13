/obj/machinery/door/window
	name = "interior door"
	desc = "A strong door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	layer = ABOVE_WINDOW_LAYER
	closingLayer = ABOVE_WINDOW_LAYER
	resistance_flags = ACID_PROOF
	var/base_state = "left"
	max_integrity = 150 //If you change this, consider changing ../door/window/brigdoor/ max_integrity at the bottom of this .dm file
	integrity_failure = 0
	armor = list("melee" = 20, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 70, "acid" = 100)
	visible = FALSE
	flags_1 = ON_BORDER_1
	opacity = 0
	CanAtmosPass = ATMOS_PASS_PROC
	var/obj/item/electronics/airlock/electronics = null
	var/reinf = 0
	var/shards = 2
	var/rods = 2
	var/cable = 1
	var/list/debris = list()

/obj/machinery/door/window/Initialize(mapload, set_dir)
	. = ..()
	if(set_dir)
		setDir(set_dir)
	if(src.req_access && src.req_access.len)
		src.icon_state = "[src.icon_state]"
		src.base_state = src.icon_state
	for(var/i in 1 to shards)
		debris += new /obj/item/shard(src)
	if(rods)
		debris += new /obj/item/stack/rods(src, rods)
	if(cable)
		debris += new /obj/item/stack/cable_coil(src, cable)

/obj/machinery/door/window/Destroy()
	density = FALSE
	for(var/I in debris)
		qdel(I)
	if(obj_integrity == 0)
		playsound(src, "shatter", 70, 1)
	electronics = null
	return ..()

/obj/machinery/door/window/update_icon()
	if(density)
		icon_state = base_state
	else
		icon_state = "[src.base_state]open"

/obj/machinery/door/window/proc/open_and_close()
	open()
	if(src.check_access(null))
		sleep(50)
	else //secure doors close faster
		sleep(20)
	close()

/obj/machinery/door/window/CollidedWith(atom/movable/AM)
	if( operating || !src.density )
		return
	if (!( ismob(AM) ))
		if(ismecha(AM))
			var/obj/mecha/mecha = AM
			if(mecha.occupant && src.allowed(mecha.occupant))
				open_and_close()
			else
				do_animate("deny")
		return
	if (!( SSticker ))
		return
	var/mob/M = AM
	if(M.restrained() || ((isdrone(M) || iscyborg(M)) && M.stat))
		return
	bumpopen(M)

/obj/machinery/door/window/bumpopen(mob/user)
	if( operating || !src.density )
		return
	src.add_fingerprint(user)
	if(!src.requiresID())
		user = null

	if(allowed(user))
		open_and_close()
	else
		do_animate("deny")
	return

/obj/machinery/door/window/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		return !density
	if(istype(mover, /obj/structure/window))
		var/obj/structure/window/W = mover
		if(!valid_window_location(loc, W.ini_dir))
			return FALSE
	else if(istype(mover, /obj/structure/windoor_assembly))
		var/obj/structure/windoor_assembly/W = mover
		if(!valid_window_location(loc, W.ini_dir))
			return FALSE
	else if(istype(mover, /obj/machinery/door/window) && !valid_window_location(loc, mover.dir))
		return FALSE
	else
		return 1

/obj/machinery/door/window/CanAtmosPass(turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return 1

//used in the AStar algorithm to determinate if the turf the door is on is passable
/obj/machinery/door/window/CanAStarPass(obj/item/card/id/ID, to_dir)
	return !density || (dir != to_dir) || (check_access(ID) && hasPower())

/obj/machinery/door/window/CheckExit(atom/movable/mover as mob|obj, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/machinery/door/window/open(forced=0)
	if (src.operating == 1) //doors can still open when emag-disabled
		return 0
	if(!forced)
		if(!hasPower())
			return 0
	if(forced < 2)
		if(obj_flags & EMAGGED)
			return 0
	if(!src.operating) //in case of emag
		operating = TRUE
	do_animate("opening")
	playsound(src.loc, 'sound/machines/windowdoor.ogg', 100, 1)
	src.icon_state ="[src.base_state]open"
	sleep(10)

	density = FALSE
//	src.sd_set_opacity(0)	//TODO: why is this here? Opaque windoors? ~Carn
	air_update_turf(1)
	update_freelook_sight()

	if(operating == 1) //emag again
		operating = FALSE
	return 1

/obj/machinery/door/window/close(forced=0)
	if (src.operating)
		return 0
	if(!forced)
		if(!hasPower())
			return 0
	if(forced < 2)
		if(obj_flags & EMAGGED)
			return 0
	operating = TRUE
	do_animate("closing")
	playsound(src.loc, 'sound/machines/windowdoor.ogg', 100, 1)
	src.icon_state = src.base_state

	density = TRUE
	air_update_turf(1)
	update_freelook_sight()
	sleep(10)

	operating = FALSE
	return 1

/obj/machinery/door/window/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/effects/glasshit.ogg', 90, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)


/obj/machinery/door/window/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1) && !disassembled)
		for(var/obj/fragment in debris)
			fragment.forceMove(get_turf(src))
			transfer_fingerprints_to(fragment)
			debris -= fragment
	qdel(src)

/obj/machinery/door/window/narsie_act()
	add_atom_colour("#7D1919", FIXED_COLOUR_PRIORITY)

/obj/machinery/door/window/ratvar_act()
	var/obj/machinery/door/window/clockwork/C = new(loc, dir)
	C.name = name
	qdel(src)

/obj/machinery/door/window/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + (reinf ? 1600 : 800))
		take_damage(round(exposed_volume / 200), BURN, 0, 0)
	..()

/obj/machinery/door/window/emag_act(mob/user)
	if(!operating && density && !(obj_flags & EMAGGED))
		obj_flags |= EMAGGED
		operating = TRUE
		flick("[src.base_state]spark", src)
		playsound(src, "sparks", 75, 1)
		sleep(6)
		operating = FALSE
		desc += "<BR><span class='warning'>Its access panel is smoking slightly.</span>"
		open(2)

/obj/machinery/door/window/attackby(obj/item/I, mob/living/user, params)

	if(operating)
		return

	add_fingerprint(user)
	if(!(flags_1&NODECONSTRUCT_1))
		if(istype(I, /obj/item/screwdriver))
			if(density || operating)
				to_chat(user, "<span class='warning'>You need to open the door to access the maintenance panel!</span>")
				return
			I.play_tool_sound(src)
			panel_open = !panel_open
			to_chat(user, "<span class='notice'>You [panel_open ? "open":"close"] the maintenance panel of the [src.name].</span>")
			return

		if(istype(I, /obj/item/crowbar))
			if(panel_open && !density && !operating)
				user.visible_message("[user] removes the electronics from the [src.name].", \
									 "<span class='notice'>You start to remove electronics from the [src.name]...</span>")
				if(I.use_tool(src, user, 40, volume=50))
					if(panel_open && !density && !operating && src.loc)
						var/obj/structure/windoor_assembly/WA = new /obj/structure/windoor_assembly(src.loc)
						switch(base_state)
							if("left")
								WA.facing = "l"
							if("right")
								WA.facing = "r"
							if("leftsecure")
								WA.facing = "l"
								WA.secure = TRUE
							if("rightsecure")
								WA.facing = "r"
								WA.secure = TRUE
						WA.anchored = TRUE
						WA.state= "02"
						WA.setDir(src.dir)
						WA.ini_dir = src.dir
						WA.update_icon()
						WA.created_name = src.name

						if(obj_flags & EMAGGED)
							to_chat(user, "<span class='warning'>You discard the damaged electronics.</span>")
							qdel(src)
							return

						to_chat(user, "<span class='notice'>You remove the airlock electronics.</span>")

						var/obj/item/electronics/airlock/ae
						if(!electronics)
							ae = new/obj/item/electronics/airlock( src.loc )
							if(req_one_access)
								ae.one_access = 1
								ae.accesses = src.req_one_access
							else
								ae.accesses = src.req_access
						else
							ae = electronics
							electronics = null
							ae.forceMove(drop_location())

						qdel(src)
				return
	return ..()

/obj/machinery/door/window/try_to_crowbar(obj/item/I, mob/user)
	if(!hasPower())
		if(density)
			open(2)
		else
			close(2)
	else
		to_chat(user, "<span class='warning'>The door's motors resist your efforts to force it!</span>")

/obj/machinery/door/window/do_animate(animation)
	switch(animation)
		if("opening")
			flick("[src.base_state]opening", src)
		if("closing")
			flick("[src.base_state]closing", src)
		if("deny")
			flick("[src.base_state]deny", src)


/obj/machinery/door/window/brigdoor
	name = "secure door"
	icon_state = "leftsecure"
	base_state = "leftsecure"
	var/id = null
	max_integrity = 300 //Stronger doors for prison (regular window door health is 200)
	reinf = 1
	explosion_block = 1

/obj/machinery/door/window/brigdoor/security/cell
	name = "cell door"
	desc = "For keeping in criminal scum."
	req_access = list(ACCESS_BRIG)

/obj/machinery/door/window/brigdoor/security/holding
	name = "holding cell door"
	req_one_access = list(ACCESS_SEC_DOORS, ACCESS_LAWYER) //love for the lawyer

/obj/machinery/door/window/clockwork
	name = "brass windoor"
	desc = "A thin door with translucent brass paneling."
	icon_state = "clockwork"
	base_state = "clockwork"
	shards = 0
	rods = 0
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/made_glow = FALSE

/obj/machinery/door/window/clockwork/Initialize(mapload, set_dir)
	. = ..()
	for(var/i in 1 to 2)
		debris += new/obj/item/clockwork/alloy_shards/medium/gear_bit/large(src)
	change_construction_value(2)

/obj/machinery/door/window/clockwork/setDir(direct)
	if(!made_glow)
		var/obj/effect/E = new /obj/effect/temp_visual/ratvar/door/window(get_turf(src))
		E.setDir(direct)
		made_glow = TRUE
	..()

/obj/machinery/door/window/clockwork/Destroy()
	change_construction_value(-2)
	return ..()

/obj/machinery/door/window/clockwork/emp_act(severity)
	if(prob(80/severity))
		open()

/obj/machinery/door/window/clockwork/ratvar_act()
	if(GLOB.ratvar_awakens)
		obj_integrity = max_integrity

/obj/machinery/door/window/clockwork/hasPower()
	return TRUE //yup that's power all right

/obj/machinery/door/window/clockwork/narsie_act()
	take_damage(rand(30, 60), BRUTE)
	if(src)
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

/obj/machinery/door/window/clockwork/allowed(mob/M)
	if(is_servant_of_ratvar(M))
		return 1
	return 0

/obj/machinery/door/window/northleft
	dir = NORTH

/obj/machinery/door/window/eastleft
	dir = EAST

/obj/machinery/door/window/westleft
	dir = WEST

/obj/machinery/door/window/southleft
	dir = SOUTH

/obj/machinery/door/window/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/brigdoor/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/security/cell/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/security/cell/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/security/cell/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/security/cell/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/holding/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/security/holding/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/security/holding/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/security/holding/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/security/holding/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/holding/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/holding/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/holding/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"
