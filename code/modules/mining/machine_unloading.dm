/**********************Unloading unit**************************/


/obj/machinery/mineral/unloading_machine
	name = "unloading machine"
	desc = "Used to unload ore from ore boxes."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"
	density = 1
	anchored = 1
	allowed_types = list(/obj/item)
	machine_flags = SCREWTOGGLE | CROWDESTROY | MULTITOOL_MENU | EJECTNOTDEL
	
	var/selectable_types = list(/obj/item = "All items")
	var/selected_type = /obj/item

/obj/machinery/mineral/unloading_machine/process()
	var/turf/in_T = get_step(src, in_dir)
	var/turf/out_T = get_step(src, out_dir)

	if(!in_T.Cross(mover, in_T) || !in_T.Enter(mover) || !out_T.Cross(mover, out_T) || !out_T.Enter(mover))
		return

	var/obj/structure/ore_box/BOX = locate(/obj/structure/ore_box, in_T.loc)
	if (BOX)
		BOX.dump_everything(in_T)
	
	for(var/atom/movable/A in in_T)
		if(A.anchored)
			continue

		if(is_type_in_list(A, allowed_types))
			A.forceMove(out_T)
