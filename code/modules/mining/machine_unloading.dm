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

	var/selectable_types = list(/obj/item = "All items") //List of types we can move -kanef
	var/item_moved = FALSE //Variable for loop detection, only used in chaining

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

// Make conveyors work on these too, why not. Also helps with chaining these, and other fun stuff -kanef
/obj/machinery/mineral/unloading_machine/conveyor_act(atom/movable/A)
	if(A.anchored)
		return FALSE

	if(is_type_in_list(A, allowed_types))
		return check_move(A)
	return FALSE

// Mutual function for both conveyor and process(), as suggested by github user help-maint in a seperate PR to cut down on code -kanef
/obj/machinery/mineral/unloading_machine/proc/check_move(atom/movable/A)
	var/turf/out_T = get_step(src, out_dir)

	// Check for another unloading machine in the output tile, can chain these!
	for(var/atom/movable/AM in out_T)
		if(istype(AM,/obj/machinery/mineral/unloading_machine))
			var/obj/machinery/mineral/unloading_machine/UM = AM
			// Consistent types throughout
			// Also check to make sure the direction towards this unloader from another isn't its output dir
			// Or hasn't moved the item in this chain before
			// Or it causes horrible infinite loops that crash MC
			if(!is_type_in_list(A,UM.allowed_types) || get_dir(UM,src) == UM.out_dir || UM.item_moved == TRUE)
				// Give feedback to players that this thing cannot be moved right
				visible_message("<span class='notice'>[src] beeps: Item could not be moved</span>")
				// If check fails, reset the chain values to false
				reset_move_check()
				return FALSE
			else
				// Otherwise, it's true, this is important for later to detect loops
				item_moved = TRUE
		// Cryo pods, etc work too
		if(AM.conveyor_act(A))
			if (!item_moved)
				reset_move_check()
			return TRUE
	// Call it again for good measure, now that conveyor and unloader checks are done, we don't need this variable outside of chaining
	if (!item_moved)
		reset_move_check()
	// Otherwise, just act normal and put stuff on the other side
	if(out_T.Cross(mover, out_T) && out_T.Enter(mover))
		A.forceMove(out_T)
		return TRUE
	return FALSE

// The process used to reset all "are we chaining a move?" checks on each item to false, when done or in failure -kanef
/obj/machinery/mineral/unloading_machine/proc/reset_move_check()
	// First, reset it here
	item_moved = FALSE
	// Then check the in_dir location for the one behind it in the chain
	var/turf/in_T = get_step(src, in_dir)
	for(var/atom/movable/AM in in_T)
		// Did we find the unloader?
		if(istype(AM,/obj/machinery/mineral/unloading_machine))
			// If so, do the work
			var/obj/machinery/mineral/unloading_machine/UM = AM
			// Nothing to reset? Stop here
			if (!UM.item_moved)
				return
			// Otherwise, reset each one recursively, follow logic above
			UM.reset_move_check()

// Couldn't inherit most of this sadly -kanef
/obj/machinery/mineral/unloading_machine/process()
	var/turf/in_T = get_step(src, in_dir)

	if(!in_T.Cross(mover, in_T) || !in_T.Enter(mover))
		return

	for (var/obj/structure/ore_box/BOX in in_T)
		BOX.dump_everything(in_T)

	for(var/atom/movable/A in in_T)
		if(A.anchored)
			continue

		if(is_type_in_list(A, allowed_types))
			check_move(A)