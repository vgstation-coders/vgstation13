/******************Base Machine**********************/

/obj/machinery/mineral/
	name = "mining machine"
	desc = "Does non-specific mining_stuff"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"
	density = 1
	anchored = 1
	var/atom/movable/mover //Virtual atom used to check passing ability on the out turf.
	var/in_dir = NORTH
	var/out_dir = SOUTH
	var/list/allowed_types = list(/obj/item/stack/sheet) //What does this machine accept?
	var/max_moved = INFINITY

/obj/machinery/mineral/New()
    . = ..()
    mover = new

/obj/machinery/mineral/Destroy()
	qdel(mover)
	mover = null
	. = ..()

/obj/machinery/mineral/process() //Basic proc for filtering types to act on, otherwise rejects on out_dir
	var/turf/in_T = get_step(src, in_dir)
	var/turf/out_T = get_step(src, out_dir)

	if(!in_T.Cross(mover, in_T) || !in_T.Enter(mover) || !out_T.Cross(mover, out_T) || !out_T.Enter(mover))
		return
	
	var/moved = 0
	for(var/atom/movable/A in in_T)
		if(A.anchored)
			continue

		if(!is_type_in_list(A, allowed_types))
			A.forceMove(out_T)
			continue
		
		process_inside(A)
		moved ++
		if(moved >= max_moved)
			break

/obj/machinery/mineral/proc/process_inside(atom/movable/A) //Base proc, does nothing, handled in subtypes
	return