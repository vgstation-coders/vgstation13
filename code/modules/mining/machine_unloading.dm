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
	max_moved = 100
	in_dir = EAST
	out_dir = WEST
	
	var/selectable_types = list(/obj/item = "All items")

/obj/machinery/mineral/stacking_machine/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/unloading_machine,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/capacitor
	)

	RefreshParts()

/obj/machinery/mineral/unloading_machine/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/bin in component_parts)
		T += bin.rating
	max_moved = initial(max_moved) * (T / 3)

	T = 0 //reusing T here because muh RAM.
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		T += C.rating - 1
	idle_power_usage = initial(idle_power_usage) - (T * (initial(idle_power_usage) / 4))//25% power usage reduction for an advanced capacitor, 50% for a super one.

/obj/machinery/mineral/unloading_machine/conveyor_act(atom/movable/A)
	if(A.anchored)
		return FALSE

	if(is_type_in_list(A, allowed_types))
		return check_move(A,out_T)
	return FALSE

/obj/machinery/mineral/unloading_machine/proc/check_move(atom/movable/A)
	var/turf/out_T = get_step(src, out_dir)

	for(var/atom/movable/AM in out_T)
		if(istype(AM,/obj/machinery/mineral/unloading_machine))
			var/obj/machinery/mineral/unloading_machine/UM = AM
			if(!is_type_in_list(A,UM.allowed_types))
				return FALSE
		if(AM.conveyor_act(A))
			return TRUE

	if(out_T.Cross(mover, out_T) && out_T.Enter(mover))
		A.forceMove(out_T)
		return TRUE
	return FALSE

/obj/machinery/mineral/unloading_machine/process()
	var/turf/in_T = get_step(src, in_dir)

	if(!in_T.Cross(mover, in_T) || !in_T.Enter(mover))
		return

	var/obj/structure/ore_box/BOX = locate(/obj/structure/ore_box, in_T.loc)
	if (BOX)
		BOX.dump_everything(in_T)
	
	for(var/atom/movable/A in in_T)
		if(A.anchored)
			continue

		if(is_type_in_list(A, allowed_types))
			check_move(A)