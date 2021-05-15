/**********************Unloading unit**************************/


/obj/machinery/mineral/unloading_machine
	name = "unloading machine"
	desc = "Used to unload ore from ore boxes."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"
	density = 1
	anchored = 1
	allowed_types = list(/obj/item)
	machine_flags |= MULTITOOL_MENU
	
	var/selectable_types = list(/obj/item)
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

/obj/machinery/mineral/unloading_machine/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	return {"
	<ul>
		<li><b>In direction:</b>
			<a href="?src=\ref[src];setindir=[NORTH]" title="North">&uarr;</a>
			<a href="?src=\ref[src];setindir=[EAST]" title="East">&rarr;</a>
			<a href="?src=\ref[src];setindir=[SOUTH]" title="South">&darr;</a>
			<a href="?src=\ref[src];setindir=[WEST]" title="West">&larr;</a>
		</li>
		<li><b>Out direction:</b>
			<a href="?src=\ref[src];setoutdir=[NORTH]" title="North">&uarr;</a>
			<a href="?src=\ref[src];setoutdir=[EAST]" title="East">&rarr;</a>
			<a href="?src=\ref[src];setoutdir=[SOUTH]" title="South">&darr;</a>
			<a href="?src=\ref[src];setoutdir=[WEST]" title="West">&larr;</a>
		</li>
	</ul>"}

/obj/machinery/mineral/unloading_machine/multitool_topic(var/mob/user,var/list/href_list,var/obj/O)
	. = ..()
	if(.)
		return .
	if("setindir" in href_list)
		in_dir = text2num(href_list["setindir"])
		return MT_UPDATE
	if("setoutdir" in href_list)
		out_dir = text2num(href_list["setoutdir"])
		return MT_UPDATE