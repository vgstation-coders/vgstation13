// Basic transit tubes. Straight pieces, curved sections,
//  and basic splits/joins (no routing logic).
// Mappers: you can use "Generate Instances from Icon-states"
//  to get the different pieces.
/obj/structure/transit_tube
	name = "transit tube"
	icon = 'icons/obj/pipes/transit_tube.dmi'
	icon_state = "E-W"
	layer = ABOVE_OBJ_LAYER
	anchored = 1.0
	pixel_x = -8
	pixel_y = -8
	var/list/tube_dirs = null
	var/exit_delay = 0
	var/enter_delay = 1



/obj/structure/transit_tube/New(var/loc, var/icon_state_override = null, var/dir_override = null)
	. = ..(loc)

	if(dir_override)
		dir = dir_override

	if(icon_state_override)
		icon_state = icon_state_override

	if (tube_dirs == null)
		init_dirs()

/obj/structure/transit_tube/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	return TRUE //Otherwise, whatever.

// Called to check if a pod should stop upon entering this tube.
/obj/structure/transit_tube/proc/should_stop_pod(pod, from_dir)
	return 0



// Returns a /list of directions this tube section can connect to.
//  Tubes that have some sort of logic or changing direction might
//  override it with additional logic.
/obj/structure/transit_tube/proc/directions()
	return tube_dirs



// Searches for an exit direction within 45 degrees of the
//  specified dir. Returns that direction, or 0 if none match.
/obj/structure/transit_tube/proc/get_exit(in_dir)
	var/near_dir = 0
	var/in_dir_cw = turn(in_dir, -45)
	var/in_dir_ccw = turn(in_dir, 45)

	for(var/direction in directions())
		if(direction == in_dir)
			return direction

		else if(direction == in_dir_cw)
			near_dir = direction

		else if(direction == in_dir_ccw)
			near_dir = direction

	return near_dir



// Return how many BYOND ticks to wait before entering/exiting
//  the tube section. Default action is to return the value of
//  a var, which wouldn't need a proc, but it makes it possible
//  for later tube types to interact in more interesting ways
//  such as being very fast in one direction, but slow in others
/obj/structure/transit_tube/proc/exit_delay(pod, to_dir)
	return exit_delay

/obj/structure/transit_tube/proc/enter_delay(pod, to_dir)
	return enter_delay

// Called when a pod stops in this tube section.
/obj/structure/transit_tube/proc/pod_stopped(pod, from_dir)
	return

/obj/structure/transit_tube/attackby(obj/item/W as obj, mob/user as mob)
	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		to_chat(user, "<span class='notice'>You begin to cut the glass off...</span>")
		if(WT.do_weld(user, src, 4 SECONDS))
			to_chat(user, "<span class='notice'>You detach the glass from the [src].</span>")
			new /obj/item/stack/sheet/glass/rglass(get_turf(src), 2)
			var/obj/structure/transit_tube_frame/TTF
			switch(icon_state)
				if("N-S","E-W")
					TTF = new /obj/structure/transit_tube_frame(get_turf(src), iconstate2framedir())
				if("NE-SW","NW-SE")
					TTF = new /obj/structure/transit_tube_frame/diag(get_turf(src), iconstate2framedir())
				if("N-SW","S-NE","E-NW","W-SE")
					TTF = new /obj/structure/transit_tube_frame/bent(get_turf(src), iconstate2framedir())
				if("N-SE","S-NW","E-SW","W-NE")
					TTF = new /obj/structure/transit_tube_frame/bent_invert(get_turf(src), iconstate2framedir())
				if("N-SW-SE","S-NE-NW","E-NW-SW","W-SE-NE")
					TTF = new /obj/structure/transit_tube_frame/fork(get_turf(src), iconstate2framedir())
				if("N-SE-SW","S-NW-NE","E-SW-NW","W-NE-SE")
					TTF = new /obj/structure/transit_tube_frame/fork_invert(get_turf(src), iconstate2framedir())
				if("N-S-pass","E-W-pass")
					TTF = new /obj/structure/transit_tube_frame/pass(get_turf(src), iconstate2framedir())
				if("closed","open","closing","opening")
					TTF = new /obj/structure/transit_tube_frame/station(get_turf(src), iconstate2framedir())
			if(TTF)
				TTF.anchored = 1
				if(istype(TTF,/obj/structure/transit_tube_frame/station))
					var/obj/structure/transit_tube_frame/station/TTS = TTF
					if(req_access && req_access.len > 0)
						TTS.electronics.conf_access = req_access
					else if(req_one_access && req_one_access.len > 0)
						TTS.electronics.conf_access = req_one_access
						TTS.electronics.one_access = 1
					TTS.electronics.dir_access = req_access_dir
					TTS.electronics.access_nodir = access_not_dir
			qdel(src)
		return 1

/obj/structure/transit_tube/examine(mob/user)
	..()
	for(var/obj/structure/transit_tube_pod/pod in loc)
		pod.show_occupants(user)


// Parse the icon_state into a list of directions.
// This means that mappers can use Dream Maker's built in
//  "Generate Instances from Icon-states" option to get all
//  variations. Additionally, as a separate proc, sub-types
//  can handle it more intelligently.
/obj/structure/transit_tube/proc/init_dirs()
	if(icon_state == "auto")
		// Additional delay, for map loading.
		spawn(1)
			init_dirs_automatic()
	else
		tube_dirs = parse_dirs(icon_state)

		if(copytext(icon_state, 1, 3) == "D-" || findtextEx(icon_state, "Pass"))
			density = 0


/obj/structure/transit_tube/proc/has_entrance(from_dir)
	from_dir = turn(from_dir, 180)

	for(var/direction in directions())
		if(direction == from_dir)
			return 1

	return 0

/obj/structure/transit_tube/proc/has_exit(in_dir)
	for(var/direction in directions())
		if(direction == in_dir)
			return 1

	return 0


/obj/structure/transit_tube/proc/test_blocked(in_dir)	//You can now only squeeze under transit tubes if you can go out the same way you came in.
	return (get_exit(in_dir) || get_exit(turn(in_dir, 180)))



// Initialize dirs by searching for tubes that do/might connect
//  on nearby turfs.
// Pick two directions, preferring tubes that already connect
//  to loc, or other auto tubes if there aren't enough connections.
/obj/structure/transit_tube/proc/init_dirs_automatic()
	var/list/connected = list()
	var/list/connected_auto = list()

	for(var/direction in alldirs)
		var/location = get_step(loc, direction)
		for(var/obj/structure/transit_tube/tube in location)
			if(tube.directions() == null && tube.icon_state == "auto")
				connected_auto += direction
				break

			else if(turn(direction, 180) in tube.directions())
				connected += direction
				break

	connected += connected_auto

	tube_dirs = select_automatic_dirs(connected)

	if(length(tube_dirs) == 2 && alldirs.Find(tube_dirs[1]) > alldirs.Find(tube_dirs[2]))
		tube_dirs.Swap(1, 2)

	select_automatic_icon_state(tube_dirs)




// Given a list of directions, look a pair that forms a 180 or
//  135 degree angle, and return a list containing the pair.
//  If none exist, return list(connected[1], turn(connected[1], 180)
/obj/structure/transit_tube/proc/select_automatic_dirs(connected)
	if(length(connected) < 1)
		return list()

	for(var/i = 1, i <= length(connected), i++)
		for(var/j = i + 1, j <= length(connected), j++)
			var/d1 = connected[i]
			var/d2 = connected[j]

			if(d1 == turn(d2, 135) || d1 == turn(d2, 180) || d1 == turn(d2, 225))
				return list(d1, d2)

	return list(connected[1], turn(connected[1], 180))



/obj/structure/transit_tube/proc/select_automatic_icon_state(directions)
	if(length(directions) == 2)
		icon_state = "[dir2text_short(directions[1])]-[dir2text_short(directions[2])]"

// Uses a list() to cache return values. Since they should
//  never be edited directly, all tubes with a certain
//  icon_state can just reference the same list. In theory,
//  reduces memory usage, and improves CPU cache usage.
//  In reality, I don't know if that is quite how BYOND works,
//  but it is probably safer to assume the existence of, and
//  rely on, a sufficiently smart compiler/optimizer.
/obj/structure/transit_tube/proc/parse_dirs(text)
	var/global/list/direction_table = list()

	if(text in direction_table)
		return direction_table[text]

	var/list/split_text = splittext(text, "-")

	var/list/directions = list()

	for(var/text_part in split_text)
		var/direction = text2dir_extended(text_part)

		if(direction > 0)
			directions += direction

	direction_table[text] = directions
	return directions
