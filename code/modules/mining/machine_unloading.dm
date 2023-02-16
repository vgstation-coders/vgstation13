/**********************Unloading unit**************************/


/obj/machinery/mineral/unloading_machine
	name = "unloading machine"
	desc = "Used to unload ore from ore boxes, but generally to put things on conveyors."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"
	density = 1
	anchored = 1
	allowed_types = list(/obj/item)
	machine_flags = SCREWTOGGLE | CROWDESTROY | MULTITOOL_MENU
	max_moved = 25//as many items as conveyors can move
	in_dir = EAST
	out_dir = WEST
	var/list/to_unload = list()

/obj/machinery/mineral/unloading_machine/New()
	. = ..()
	overlays += image(icon, src, "unloader-overlay", ABOVE_OBJ_LAYER, dir)
	component_parts = newlist(
		/obj/item/weapon/circuitboard/unloading_machine,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/capacitor
	)
	RefreshParts()
	in_dir = opposite_dirs[dir]
	out_dir = dir

/obj/machinery/mineral/unloading_machine/RefreshParts()
	var/parts_rating = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/bin in component_parts)
		parts_rating += bin.rating
	max_moved = round(initial(max_moved) * (parts_rating / 3))//up to 25 items unloaded per process by default. All the way up to 100.
	parts_rating = 0
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		parts_rating += C.rating - 1
	idle_power_usage = initial(idle_power_usage) - (parts_rating * (initial(idle_power_usage) / 4))//25% power usage reduction for an advanced capacitor, 50% for a super one.

/obj/machinery/mineral/unloading_machine/multitool_topic(mob/user, list/href_list, obj/item/device/multitool/P)
	if("changedir" in href_list)
		var/changingdir = text2num(href_list["changedir"])
		changingdir = clamp(changingdir, 1, 2)
		var/newdir = input("This will rotate the entire machine. Which direction should the ore [(changingdir == 1) ? "enter" : "exit"] from?", name, "North") as null|anything in list("North", "South", "East", "West")
		if(!newdir)
			return 1
		newdir = text2dir(newdir)
		if (changingdir == 1)
			dir = opposite_dirs[newdir]
		else
			dir = newdir
		in_dir = opposite_dirs[dir]
		out_dir = dir
		return MT_UPDATE
	return ..()

/obj/machinery/mineral/unloading_machine/process()
	var/turf/T = get_step(src,opposite_dirs[dir])

	for(var/atom/movable/A in T)
		if(A.anchored)
			continue
		if(is_type_in_list(A, allowed_types))
			playsound(loc, 'sound/machines/door_open.ogg',50,1)
			new /obj/effect/unloader_grabber(loc, src)
			break

	for (var/obj/structure/ore_box/box_to_unload in T)
		if (Adjacent(box_to_unload) && box_to_unload.stored_ores?.len)
			playsound(loc, 'sound/machines/door_close.ogg',50,1)
			flick("unloader-unload", src)
			box_to_unload.dump_everything()

	if (to_unload?.len)
		unload()

/obj/machinery/mineral/unloading_machine/proc/unload()
	var/turf/T = get_step(src,dir)
	var/i = 1
	for (var/atom/movable/AM in to_unload)
		to_unload -= AM
		AM.forceMove(loc)
		spawn(1)//smooth animation
			step(AM,dir)
		for(var/atom/movable/receptacle in T)
			if (Adjacent(receptacle) && receptacle.conveyor_act(AM))
				continue
		i++
		if (i >= max_moved)
			break

////////////////////////////Why have a separate effect do the grabbing you ask? Because it looks nice that's why.
/obj/effect/unloader_grabber
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "grabber-extend"
	anchored = 1
	density = 0
	mouse_opacity = 0
	var/obj/machinery/mineral/unloading_machine/unloader
	var/image/stack_of_items

/obj/effect/unloader_grabber/Destroy()
	if (stack_of_items)
		QDEL_NULL(stack_of_items)
	unloader = null
	if (loc)
		for (var/atom/movable/AM in contents)
			AM.forceMove(loc)
	else
		for (var/atom/movable/AM in contents)
			qdel(AM)
	..()

/obj/effect/unloader_grabber/New(turf/loc, var/obj/machinery/mineral/unloading_machine/source)
	if (!source)
		qdel(src)
		return

	unloader = source
	dir = unloader.dir
	stack_of_items = image('icons/effects/effects.dmi',src,"nothing")

	switch(dir)
		if(NORTH)
			pixel_y = -12
		if(SOUTH)
			pixel_y = 12
		if(EAST)
			pixel_x = -12
		if(WEST)
			pixel_x = 12

	spawn(5)
		if (gcDestroyed)
			return
		if (unloader.gcDestroyed)
			qdel(src)
			return
		icon_state = "grabber-retract-3"
		for (var/atom/movable/AM in get_step(src,opposite_dirs[dir]))
			if (Adjacent(AM) && is_type_in_list(AM, unloader.allowed_types))
				stack_of_items.overlays +=  image(AM.icon,src,AM.icon_state)
				AM.forceMove(src)

		stack_of_items.pixel_x = pixel_x
		stack_of_items.pixel_y = pixel_y
		overlays += stack_of_items
		sleep(1)
		icon_state = "grabber-retract-2"
		overlays.len = 0
		if (pixel_x)
			stack_of_items.pixel_x += -4 * sgn(pixel_x)
		if (pixel_y)
			stack_of_items.pixel_y += -4 * sgn(pixel_y)
		overlays += stack_of_items
		sleep(1)
		icon_state = "grabber-retract-1"
		overlays.len = 0
		if (pixel_x)
			stack_of_items.pixel_x += -4 * sgn(pixel_x)
		if (pixel_y)
			stack_of_items.pixel_y += -4 * sgn(pixel_y)
		overlays += stack_of_items
		sleep(1)
		if (gcDestroyed)
			return
		if (unloader.gcDestroyed)
			qdel(src)
			return
		for (var/atom/movable/AM in contents)
			unloader.to_unload += AM
			AM.forceMove(unloader)
		qdel(src)
