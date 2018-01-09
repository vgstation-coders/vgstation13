//conveyor2 is pretty much like the original, except it supports corners, but not diverters.
//note that corner pieces transfer stuff clockwise when running forward, and anti-clockwise backwards.

// May need to be increased.
#define CONVEYOR_CONTROL_RANGE 30

/obj/machinery/conveyor
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor0"
	name = "conveyor belt"
	desc = "A conveyor belt.\
	<br><span class='info'>It can be pried into a different direction using a crowbar, but cannot be moved without welding it apart.</span>"
	anchored = 1

	var/operating = 0	// 1 if running forward, -1 if backwards, 0 if off
	var/operable = 1	// true if can operate (no broken segments in this belt run)
	var/in_reverse = 0  // Swap forwards/reverse dirs. (Good for diagonals)
	var/forwards		// this is the default (forward) direction, set by the map dir
	var/backwards		// hopefully self-explanatory
	var/movedir			// the actual direction to move stuff in

	var/list/affecting	// the list of all items that will be moved this ptick
	var/id_tag = ""			// the control ID	- must match controller ID

	var/frequency = 1367
	var/datum/radio_frequency/radio_connection

	var/max_moved = 25

	machine_flags = SCREWTOGGLE | CROWDESTROY | MULTITOOL_MENU

	var/smoothed = 0 //States whether or not a diagonal smoothed with its straight line neighbor

/obj/machinery/conveyor/centcom_auto
	id_tag = "round_end_belt"

// Auto conveyour is always on unless unpowered

/obj/machinery/conveyor/auto/New(loc, newdir)
	..(loc, newdir)
	operating = 1
	setmove()

/obj/machinery/conveyor/auto/update()
	if(stat & BROKEN)
		icon_state = "conveyor-broken"
		operating = 0
		return
	else if(!operable)
		operating = 0
	else if(stat & NOPOWER)
		operating = 0
	else
		operating = 1
	icon_state = "conveyor[operating]"

/obj/machinery/conveyor/initialize()
	if(frequency)
		set_frequency(frequency)
	update()

/obj/machinery/conveyor/proc/set_frequency(var/new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_CONVEYORS)

/obj/machinery/conveyor/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption)
		return

	if(id_tag != signal.data["tag"] || !signal.data["command"])
		return
	switch(signal.data["command"])
		if("forward")
			operating = 1
			setmove()
			return 1
		if("reverse")
			operating = -1
			setmove()
			return 1
		if("stop")
			operating = 0
			update()
			return 1
		else
			testing("Got unknown command \"[signal.data["command"]]\" from [src]!")


/*
 * Create a conveyor.
 */
/obj/machinery/conveyor/New(loc, newdir = null, building = 0)
	. = ..(loc)

	//Gotta go fast!
	machines -= src
	fast_machines += src

	if(newdir)
		dir = newdir

	updateConfig(!building)

	if(!id_tag) //Without an ID tag we'll never work, so let's try to copy it from one of our neighbors.
		copy_radio_from_neighbors()

	update_nearby_conveyors() //smooth with diagonals

/obj/machinery/conveyor/Destroy()
	var/turf/T = loc
	var/list/directions = conveyor_directions(dir, in_reverse) //Save where we were pointing
	..() //Remove ourselves
	for(var/direction in directions)
		var/obj/machinery/conveyor/C = locate() in get_step(T, direction)
		if(C)
			C.check_unsmooth() //Unsmooth from nearby diagonals

/obj/machinery/conveyor/update_dir(newdirection)
	var/turf/T = loc
	var/list/directions = conveyor_directions(dir, in_reverse) //Find what directions it was

	dir = 0 //Remove ourselves from the calculation
	for(var/direction in directions)
		var/obj/machinery/conveyor/C = locate() in get_step(T, direction)
		if(C)
			C.check_unsmooth() //Try to unsmooth from nearby diagonals

	dir = newdirection
	update_nearby_conveyors() //Try to resmooth with nearby diagonals
	updateConfig()
	setmove()

/obj/machinery/conveyor/proc/copy_radio_from_neighbors()
	var/obj/machinery/conveyor_switch/lever = locate() in orange(src,1)
	if(lever && lever.id_tag)
		id_tag = lever.id_tag
		frequency = lever.frequency
		spawn(5) // Need to wait for the radio_controller to wake up.
			updateConfig()
		return
	//We didn't find any levers close so let's just try to copy any conveyors nearby
	for(var/direction in cardinal)
		var/obj/machinery/conveyor/domino = locate() in get_step(src, direction)
		if(domino && domino.id_tag)
			id_tag = domino.id_tag
			frequency = domino.frequency
			spawn(5) // Yeah I copied this twice so what
				updateConfig()
			return

/obj/machinery/conveyor/proc/update_nearby_conveyors()
	if(!(dir & dir-1) || smoothed) //straight line segments or previously smoothed diagonals
		var/list/directions = conveyor_directions(dir, in_reverse) //what directions do we point
		for(var/i = 1 to 2) //Going through our two directions to "smooth" with any diagonals
			var/turf/T = get_step(loc, directions[i])
			var/obj/machinery/conveyor/C = locate() in T
			if(C && (C.dir & C.dir-1) && !C.smoothed) //found an unsmoothed diagonal conveyor belt
				var/list/secondarydirections = conveyor_directions(C.dir) //retrieve its dirs
				if(directions[i] == reverse_direction(secondarydirections[i])) //check if the direction it is pointing is towards/away from us, if necessary reverse it
					in_reverse = 1
					C.smoothed = 1
					C.update_nearby_conveyors() //For diagonal to smooth out the other connected diagonals
				else if(directions[1+!(i-1)] == secondarydirections[1+!(i-1)])//1+!(i-1) ? literal wallhacks to get 1 instead of 2, and 2 instead of 1
					C.smoothed = 1
					C.update_nearby_conveyors() //For diagonal to smooth out the other connected diagonals

/obj/machinery/conveyor/proc/check_unsmooth()
	if(dir & dir-1)
		var/list/directions = conveyor_directions(dir, in_reverse) //what directions do we point
		for(var/i = 1 to 2) //Going through our two directions to "smooth" with any diagonals
			var/turf/T = get_step(loc, directions[i])
			var/obj/machinery/conveyor/C = locate() in T
			if(C)
				var/list/secondarydirections = conveyor_directions(C.dir) //retrieve its dirs
				if(directions[i] != secondarydirections[i] || directions[1+!(i-1)] == secondarydirections[1+!(i-1)])
					return //it's still smoothed with something
		smoothed = 0 //We're no longer smoothing with anything

/proc/conveyor_directions(var/dir, var/reverse = 0)
	var/list/dirs = list()
	switch(dir)
		if(NORTH)
			dirs = list(NORTH, SOUTH)
		if(SOUTH)
			dirs = list(SOUTH, NORTH)
		if(EAST)
			dirs = list(EAST, WEST)
		if(WEST)
			dirs = list(WEST, EAST)
		if(NORTHEAST)
			dirs = list(NORTH, EAST)
		if(NORTHWEST)
			dirs = list(WEST, NORTH)
		if(SOUTHEAST)
			dirs = list(EAST, SOUTH)
		if(SOUTHWEST)
			dirs = list(SOUTH, WEST)
	if(reverse)
		dirs.Swap(1,2)
	return dirs

/obj/machinery/conveyor/proc/updateConfig(var/startup=0)
	var/list/dirs = conveyor_directions(dir, in_reverse)
	forwards = dirs[1]
	backwards = dirs[2]

	if(!startup) // Need to wait for the radio_controller to wake up.
		initialize()

/obj/machinery/conveyor/proc/setmove()
	if(operating == 1)
		movedir = forwards
	else
		movedir = backwards
	update()

/obj/machinery/conveyor/proc/update()
	if(stat & BROKEN)
		icon_state = "conveyor-broken"
		operating = 0
		return
	if(!operable)
		operating = 0
	if(stat & NOPOWER)
		operating = 0
	var/disp_op = operating
	if(in_reverse && disp_op!=0)
		disp_op = -operating
	icon_state = "conveyor[disp_op]"

	// machine process
	// move items to the target location
/obj/machinery/conveyor/process()
	if(stat & (BROKEN | NOPOWER))
		return
	if(!operating)
		return
	use_power(100)

	affecting = loc.contents - src		// moved items will be all in loc
	spawn(1)	// slight delay to prevent infinite propagation due to map order	//TODO: please no spawn() in process(). It's a very bad idea
		var/items_moved = 0
		for(var/atom/movable/A in affecting)
			if(!A.anchored)
				if(A.loc == src.loc) // prevents the object from being affected if it's not currently here.
					A.set_glide_size(DELAY2GLIDESIZE(SS_WAIT_FAST_MACHINERY))
					step(A,movedir)
					items_moved++
			if(items_moved >= max_moved)
				break

/obj/machinery/conveyor/togglePanelOpen(var/obj/item/toggle_item, mob/user)
	return

/obj/machinery/conveyor/crowbarDestroy(mob/user)
	return

/obj/machinery/conveyor/attackby(obj/item/W, mob/user)
	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			playsound(get_turf(src), 'sound/items/Welder2.ogg', 50, 1)
			if(do_after(user, src, 30))
				user.visible_message("<span class='warning'>Plates of metal are cut off \the [src] by [user.name] with the welding tool.</span>", \
				"<span class='warning'>You cut the metal plates off \the [src] with the welding tool.</span>", \
				"<span class='warning'>You hear welding.</span>")
				new /obj/structure/conveyor_assembly(loc,dir)
				getFromPool(/obj/item/stack/sheet/metal, loc, 3)
				qdel(src)
			return 1
	. = ..()
	if(.)
		return .
	user.drop_item(W, src.loc)

/obj/machinery/conveyor/MouseDrop(over_object,src_location,over_location,src_control,over_control,params)
	var/mob/user = usr
	if(user.incapacitated() || user.lying)
		return
	if(!isturf(over_location) || !Adjacent(user))
		return
	var/obj/O = user.get_active_hand()
	if(iscrowbar(O))
		update_dir(get_dir(src, over_location))
		playsound(get_turf(src), 'sound/items/Crowbar.ogg', 25, 1)
		to_chat(user, "You change the direction of \the [src] using \the [O].")
		return
	return ..()

/obj/machinery/conveyor/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	//var/obj/item/device/multitool/P = get_multitool(user)
	var/dis_id_tag="-----"
	if(id_tag!=null && id_tag!="")
		dis_id_tag=id_tag
	return {"
	<ul>
		<li><b>Direction:</b>
			<a href="?src=\ref[src];setdir=[NORTH]" title="North">[src.in_reverse ? "&darr;" : "&uarr;"]</a>
			<a href="?src=\ref[src];setdir=[EAST]" title="East">[src.in_reverse ? "&larr;" : "&rarr;"]</a>
			<a href="?src=\ref[src];setdir=[SOUTH]" title="South">[src.in_reverse ? "&uarr;" : "&darr;"]</a>
			<a href="?src=\ref[src];setdir=[WEST]" title="West">[src.in_reverse ? "&rarr;" : "&larr;"]</a>
			<a href="?src=\ref[src];setdir=[NORTHEAST]" title="Northeast">[src.in_reverse ? "&#8601;" : "&#8599;"]</a>
			<a href="?src=\ref[src];setdir=[NORTHWEST]" title="Northwest">[src.in_reverse ? "&#8598;" : "&#8600;"]</a>
			<a href="?src=\ref[src];setdir=[SOUTHEAST]" title="Southeast">[src.in_reverse ? "&#8600;" : "&#8598;"]</a>
			<a href="?src=\ref[src];setdir=[SOUTHWEST]" title="Southwest">[src.in_reverse ? "&#8599;" : "&#8601;"]</a>
			<a href="?src=\ref[src];reverse" title="Reverse Direction">&#8644;</a>
		</li>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=1367">Reset</a>)</li>
		<li><b>ID Tag:</b> <a href="?src=\ref[src];set_id=1">[dis_id_tag]</a></li>

		<li>To quickly copy configuration: Add a Conveyor or a Conveyor Switch into buffer, activate the Multitool in your hand to enable Cloning Mode, then use it on another Conveyor.</li>
		<li>To make counter-clockwise corners: Use the Reverse Direction button in this menu. Diagonals will attempt to auto set direction based on connected straight line segments.</li>
	</ul>"}


/obj/machinery/conveyor/multitool_topic(var/mob/user,var/list/href_list,var/obj/O)
	. = ..()
	if(.)
		return .
	if("setdir" in href_list)
		operating=0
		update_dir(text2num(href_list["setdir"]))
		return MT_UPDATE
	if("reverse" in href_list)
		operating=0
		in_reverse=!in_reverse
		updateConfig()
		return MT_UPDATE

/obj/machinery/conveyor/canClone(var/obj/machinery/O)
	return is_type_in_list(O, list(/obj/machinery/conveyor_switch, /obj/machinery/conveyor))

/obj/machinery/conveyor/clone(var/obj/machinery/O)
	if(istype(O, /obj/machinery/conveyor))
		var/obj/machinery/conveyor/it = O
		operating = 0
		id_tag = it.id_tag
		frequency = it.frequency
	else if(istype(O, /obj/machinery/conveyor_switch))
		var/obj/machinery/conveyor_switch/it = O
		id_tag = it.id_tag
		frequency = it.frequency
	updateConfig()
	return 1

// attack with hand, move pulled object onto conveyor
/obj/machinery/conveyor/attack_hand(mob/user as mob)
	user.Move_Pulled(src)

// make the conveyor broken
// also propagate inoperability to any connected conveyor with the same ID
/obj/machinery/conveyor/proc/broken()
	stat |= BROKEN
	update()

	/*
	var/obj/machinery/conveyor/C = locate() in get_step(src, dir)
	if(C)
		C.set_operable(dir, id, 0)

	C = locate() in get_step(src, turn(dir,180))
	if(C)
		C.set_operable(turn(dir,180), id, 0)
	*/


//set the operable var if ID matches, propagating in the given direction

/obj/machinery/conveyor/proc/set_operable(stepdir, match_id, op)
	if(id_tag != match_id)
		return
	operable = op

	update()
	var/obj/machinery/conveyor/C = locate() in get_step(src, stepdir)
	if(C)
		C.set_operable(stepdir, id_tag, op)

/*
/obj/machinery/conveyor/verb/destroy()
	set src in view()
	src.broken()
*/

/obj/machinery/conveyor/power_change()
	..()
	update()

/obj/machinery/conveyor/dropFrame()
	new /obj/structure/conveyor_assembly(src.loc, src.dir)

// the conveyor control switch
//
//

/obj/machinery/conveyor_switch
	name = "conveyor switch"
	desc = "A conveyor control switch."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	var/position = 0			// 0 off, -1 reverse, 1 forward
	var/last_pos = -1			// last direction setting
	var/convdir = 0 			// lock to one direction. -1 = reverse, 0 = not locked, 1 = forward
	var/operated = 1			// true if just operated

	var/id_tag = "" 			// must match conveyor IDs to control them

	var/frequency = 1367
	var/datum/radio_frequency/radio_connection
	machine_flags = MULTITOOL_MENU

	anchored = 1

/obj/machinery/conveyor_switch/oneway //Use these instances for mapping
	convdir = 1

/obj/machinery/conveyor_switch/oneway/reverse
	convdir = -1

/obj/machinery/conveyor_switch/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption)
		return
	if(src == signal.source)
		return

	if(id_tag != signal.data["tag"] || !signal.data["command"])
		return
	if(!convdir)
		switch(signal.data["command"])
			if("forward")
				position = 1
				last_pos = 0
			if("reverse")
				position = -1
				last_pos = 0
			if("stop")
				last_pos = position
				position = 0
			else
				testing("Got unknown command \"[signal.data["command"]]\" from [src]!")
				return
	else
		switch(signal.data["command"])
			if("forward")
				if(convdir==1)
					position = 1
			if("reverse")
				if(convdir==-1)
					position = -1
			if("stop")
				position = 0
			else
				testing("Got unknown command \"[signal.data["command"]]\" from [src]!")
				return
	update()

/obj/machinery/conveyor_switch/New()
	..()
	if(!id_tag)
		id_tag = "[rand(9999)]"
		set_frequency(frequency) //I tried just assigning the ID tag during initialize(), but that didn't work somehow, probably because it makes TOO MUCH SENSE
	update()
	spawn(5)		// allow map load
		updateConfig()

/obj/machinery/conveyor_switch/proc/updateConfig()
	//initialize()

// update the icon depending on the position

/obj/machinery/conveyor_switch/proc/update()
	if(position<0)
		icon_state = "switch-rev"
	else if(position>0)
		icon_state = "switch-fwd"
	else
		icon_state = "switch-off"

/obj/machinery/conveyor_switch/initialize()
	if(frequency)
		set_frequency(frequency)
	update()

/obj/machinery/conveyor_switch/proc/set_frequency(var/new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_CONVEYORS)

// attack with hand, switch position
/obj/machinery/conveyor_switch/attack_hand(mob/user)
	if(isobserver(usr) && !canGhostWrite(user,src,"toggled"))
		to_chat(usr, "<span class='warning'>Nope.</span>")
		return 0
	if(!convdir)
		if(position == 0)
			if(last_pos < 0)
				position = 1
				last_pos = 0
				send_command("forward")
			else
				position = -1
				last_pos = 0
				send_command("reverse")
		else
			last_pos = position
			position = 0
			send_command("stop")
	else
		if(position == 0)
			position = convdir
			send_command(convdir==1?"forward":"reverse")
		else
			position = 0
			send_command("stop")

	update()

/obj/machinery/conveyor_switch/proc/send_command(var/command)
	if(radio_connection)
		var/datum/signal/signal = getFromPool(/datum/signal)
		signal.source=src
		signal.transmission_method = 1 //radio signal
		signal.data["tag"] = id_tag
		signal.data["timestamp"] = world.time

		signal.data["command"] = command

		radio_connection.post_signal(src, signal, range = CONVEYOR_CONTROL_RANGE)

/obj/machinery/conveyor_switch/attackby(var/obj/item/W, mob/user)
	. = ..()
	if(.)
		return .
	if(iswrench(W))
		to_chat(user, "<span class='notice'>Deconstructing \the [src]...</span>")
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
		if(do_after(user, src,50))
			to_chat(user, "<span class='notice'>You disassemble \the [src].</span>")
			var/turf/T=get_turf(src)
			new /obj/item/device/assembly/signaler(T)
			new /obj/item/stack/rods(T,1)
			qdel(src)
		return 1

/obj/machinery/conveyor_switch/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	var/dis_id_tag="-----"
	if(id_tag!=null && id_tag!="")
		dis_id_tag=id_tag
	return {"
		<ul>
			<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=1367">Reset</a>)</li>
			<li><b>ID Tag:</b> <a href="?src=\ref[src];set_id=1">[dis_id_tag]</a></li>
			<li><b>Restrict Pulling: </b>
				[convdir == -1 ? "<b>&larr;</b>" : {"<a href="?src=\ref[src];setconvdir=-1">&larr;</a>"}]
				[convdir ==  0 ? "<b>No</b>" 	 : {"<a href="?src=\ref[src];setconvdir= 0">No</a>"}]
				[convdir ==  1 ? "<b>&rarr;</b>" : {"<a href="?src=\ref[src];setconvdir= 1">&rarr;</a>"}]
			</li>
			<li>To quickly copy configuration: Add a Conveyor or a Conveyor Switch into buffer, activate the Multitool in your hand to enable Cloning Mode, then use it on another Conveyor.</li>
			<li><i>Cloning from a Conveyor Switch will only copy the Frequency and ID Tag, not direction.</i></li>
		</ul>"}

/obj/machinery/conveyor_switch/multitool_topic(var/mob/user,var/list/href_list,var/obj/O)
	. = ..()
	if(.)
		return
	if("setconvdir" in href_list)
		convdir = text2num(href_list["setconvdir"])
		updateConfig()
		return MT_UPDATE

/obj/machinery/conveyor_switch/npc_tamper_act(mob/living/L)
	attack_hand(L)
