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

/obj/machinery/mineral/New()
    . = ..()
    mover = new

/obj/machinery/mineral/Destroy()
	qdel(mover)
	mover = null
	. = ..()

/obj/machinery/mineral/process()
    var/turf/in_T = get_step(src, in_dir)
	var/turf/out_T = get_step(src, out_dir)

	if(!in_T.Cross(mover, in_T) || !in_T.Enter(mover) || !out_T.Cross(mover, out_T) || !out_T.Enter(mover))
		return