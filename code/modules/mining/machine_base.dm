/******************Base Machine**********************/

/obj/machinery/mineral/
	name = "mining machine"
	desc = "Does non-specific mining stuff."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"
	density = 1
	anchored = 1
	var/atom/movable/mover //Virtual atom used to check passing ability on the out turf.
	var/in_dir = NORTH
	var/out_dir = SOUTH
	var/list/allowed_types = list(/obj/item/stack/sheet) //What does this machine accept?
	var/max_moved = INFINITY
	var/frequency = FREQ_DISPOSAL //Same as conveyors

/obj/machinery/mineral/New()
	. = ..()
	mover = new
	if(ticker)
		initialize()

/obj/machinery/mineral/Destroy()
	QDEL_NULL(mover)
	. = ..()

/obj/machinery/mineral/stacking_machine/initialize()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/mineral/process() //Basic proc for filtering types to act on, otherwise rejects on out_dir
	var/turf/in_T = get_step(src, in_dir)
	var/turf/out_T = get_step(src, out_dir)

	if(!in_T.Enter(mover, mover.loc, TRUE) || !out_T.Enter(mover, mover.loc, TRUE))
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

/obj/machinery/mineral/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[1439]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag")]</li>
		<li><b>Input: </b><a href='?src=\ref[src];changedir=1'>[capitalize(dir2text(in_dir))]</a></li>
		<li><b>Output: </b><a href='?src=\ref[src];changedir=2'>[capitalize(dir2text(out_dir))]</a></li>
	</ul>
	"}

//For the purposes of this proc, 1 = in, 2 = out.
//Yes the implementation is overkill but I felt bad for hardcoding it with gigantic if()s and shit.
//(Moved to base file)
/obj/machinery/mineral/multitool_topic(mob/user, list/href_list, obj/item/device/multitool/P)
	if("changedir" in href_list)
		var/changingdir = text2num(href_list["changedir"])
		changingdir = clamp(changingdir, 1, 2)//No runtimes from HREF exploits.

		var/newdir = input("Select the new direction", name, "North") as null|anything in list("North", "South", "East", "West")
		if(!newdir)
			return 1
		newdir = text2dir(newdir)

		var/list/dirlist = list(in_dir, out_dir) //Behold the idea I got on how to do this.
		var/olddir = dirlist[changingdir] //Store this for future reference before wiping it next line.
		dirlist[changingdir] = -1 //Make the dir that's being changed -1 so it doesn't see itself.

		var/conflictingdir = dirlist.Find(newdir) //Check if the dir is conflicting with another one
		if(conflictingdir) //Welp, it is.
			dirlist[conflictingdir] = olddir //Set it to the olddir of the dir we're changing.

		dirlist[changingdir] = newdir //Set the changindir to the selected dir.

		in_dir = dirlist[1]
		out_dir = dirlist[2]

		return MT_UPDATE
		//Honestly I didn't expect that to fit in, what, 10 lines of code?

	return ..()
