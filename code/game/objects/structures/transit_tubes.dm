#define TUBE_POD_UNLOAD_LIMIT 20

// Basic transit tubes. Straight pieces, curved sections,
//  and basic splits/joins (no routing logic).
// Mappers: you can use "Generate Instances from Icon-states"
//  to get the different pieces.
/obj/structure/transit_tube
	name = "transit tube"
	icon = 'icons/obj/pipes/transit_tube.dmi'
	icon_state = "E-W"
	density = 1
	layer = ABOVE_OBJ_LAYER
	anchored = 1.0
	pixel_x = -8
	pixel_y = -8
	var/list/tube_dirs = null
	var/exit_delay = 0
	var/enter_delay = 1



// A place where tube pods stop, and people can get in or out.
// Mappers: use "Generate Instances from Directions" for this
//  one.
/obj/structure/transit_tube/station
	name = "transit tube station"
	icon = 'icons/obj/pipes/transit_tube_station.dmi'
	icon_state = "closed"
	exit_delay = 4
	enter_delay = 4
	pixel_x = 0
	pixel_y = 0
	var/pod_moving = 0
	var/automatic_launch_time = 100
	var/open = FALSE

	var/const/OPEN_DURATION = 6
	var/const/CLOSE_DURATION = 6



/obj/structure/transit_tube_pod
	name = "transit pod"
	icon = 'icons/obj/pipes/transit_tube_pod.dmi'
	icon_state = "pod"
	animate_movement = FORWARD_STEPS
	anchored = 1.0
	density = 1
	var/moving = 0
	var/datum/gas_mixture/air_contents = new()

/obj/structure/transit_tube_pod/Destroy()
	for(var/atom/movable/AM in contents)
		AM.forceMove(loc)

	..()

// When destroyed by explosions, properly handle contents.
/obj/structure/transit_tube_pod/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/AM in contents)
				AM.forceMove(loc)
				// TODO: What the fuck are you doing
				AM.ex_act(severity++)

			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/AM in contents)
					AM.forceMove(loc)
					AM.ex_act(severity++)

				qdel(src)
				return
		if(3.0)
			return

/obj/structure/transit_tube_pod/New(var/loc, var/dir_override = null)
	. = ..(loc)

	if(dir_override)
		dir = dir_override

	air_contents.adjust_multi_temp(
		GAS_OXYGEN, MOLES_O2STANDARD, T20C,
		GAS_NITROGEN, MOLES_N2STANDARD, T20C)

	// Give auto tubes time to align before trying to start moving
	spawn (5)
		follow_tube()

/obj/structure/transit_tube/New(var/loc, var/icon_state_override = null, var/dir_override = null)
	. = ..(loc)

	if(dir_override)
		dir = dir_override

	if(icon_state_override)
		icon_state = icon_state_override

	if (tube_dirs == null)
		init_dirs()

/obj/structure/transit_tube/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	if(test_blocked(get_dir(src, mover)))
		return ..() //If there's an opening on the side they're trying to enter, only let them do so if they can normally pass dense structures.
	return TRUE //Otherwise, whatever.


/obj/structure/transit_tube/station/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	if(open && get_dir(src, mover) == dir) //This actually isn't necessary right now, but will be if BYOND movecode ever becomes not flaming garbage.
		return FALSE
	return ..()


/obj/structure/transit_tube/Crossed(atom/movable/mover)
	if(density && isliving(mover)) //Don't want it showing up for ghosts, etc.
		to_chat(mover, "<span class='info'>You slip under the tube.</span>")


/obj/structure/transit_tube/station/Crossed(atom/movable/mover)
	if(!open) //Don't show the text if they're getting out of the pod. This also stops them from getting it if they just walk under it from behind while it's open, but oh well. Thanks BYOND.
		return ..()


/obj/structure/transit_tube/Bumped(atom/movable/mover)
	to_chat(mover, "<span class='warning'>The tube's support pylons block your way.</span>")


/obj/structure/transit_tube/station/Bumped(atom/movable/mover)
	if(!pod_moving && open && (get_dir(src, mover) == dir) && isliving(mover))
		var/mob/living/L = mover
		if(allowed(L))
			var/obj/structure/transit_tube_pod/pod = locate() in loc
			if(pod && !pod.moving && (pod.dir in directions()))
				mover.forceMove(pod)
				return
		else
			to_chat(L, "<span class='warning'>Access denied.</span>")
	..()

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

/obj/structure/transit_tube_pod/attackby(obj/item/W as obj, mob/user as mob)
	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		to_chat(user, "<span class='notice'>You begin to cut the glass off...</span>")
		if(WT.do_weld(user, src, 4 SECONDS))
			to_chat(user, "<span class='notice'>You detach the glass from the [src].</span>")
			new /obj/item/stack/sheet/glass/rglass(get_turf(src), 2)
			var/obj/structure/transit_tube_frame/pod/TTFP = new /obj/structure/transit_tube_frame/pod(get_turf(src), dir)
			TTFP.circuitry = new /obj/item/weapon/circuitboard/mecha/transitpod(TTFP)
			qdel(src)
		return 1

/obj/structure/transit_tube/station/attack_hand(mob/user)
	if(!pod_moving)
		for(var/obj/structure/transit_tube_pod/pod in loc)
			if(!pod.moving && (pod.dir in directions()))
				if(open)
					if(!user.lying && user.loc != pod)
						var/unloaded = 0
						var/incomplete = FALSE

						for(var/atom/movable/AM in pod)
							if(isobserver(AM))
								continue
							if(unloaded >= TUBE_POD_UNLOAD_LIMIT)
								incomplete = TRUE
								break
							AM.forceMove(get_step(loc, dir))
							unloaded++

						if(unloaded)
							user.visible_message("<span class='notice'>[user] unloads [incomplete ? "some things" : "everything"] from the tube pod.</span>", \
							"<span class='notice'>You unload [incomplete ? "some things" : "everything"] from the tube pod.</span>")
							return

					close_animation()

				else
					open_animation()


/obj/structure/transit_tube/station/attack_robot(mob/user)
	if(Adjacent(user))
		attack_hand(user)


/obj/structure/transit_tube_pod/examine(mob/user)
	..()
	show_occupants(user)


/obj/structure/transit_tube/examine(mob/user)
	..()
	for(var/obj/structure/transit_tube_pod/pod in loc)
		pod.show_occupants(user)


/obj/structure/transit_tube_pod/proc/show_occupants(mob/user)
	if(contents.len)
		var/list/occupants = contents.Copy()
		for(var/atom/movable/O in occupants)
			if(O.invisibility > user.see_invisible)
				occupants -= O
		if(occupants.len)
			to_chat(user, "<span class='info'>The tube pod contains [english_list(occupants)].</span>")
			return

	to_chat(user, "<span class='info'>The tube pod looks empty.</span>")


/obj/structure/transit_tube/station/proc/open_animation()
	if(icon_state == "closed")
		playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
		icon_state = "opening"
		spawn(OPEN_DURATION)
			if(icon_state == "opening")
				icon_state = "open"
				open = TRUE



/obj/structure/transit_tube/station/proc/close_animation()
	if(icon_state == "open")
		playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
		icon_state = "closing"
		spawn(CLOSE_DURATION)
			if(icon_state == "closing")
				icon_state = "closed"
				open = FALSE



/obj/structure/transit_tube/station/proc/launch_pod()
	for(var/obj/structure/transit_tube_pod/pod in loc)
		if(!pod.moving && (pod.dir in directions()))
			spawn(5)
				pod_moving = 1
				close_animation()
				sleep(CLOSE_DURATION + 2)

				//reverse directions for automated cycling
				var/turf/next_loc = get_step(loc, pod.dir)
				var/obj/structure/transit_tube/nexttube
				for(var/obj/structure/transit_tube/tube in next_loc)
					if(tube.has_entrance(pod.dir))
						nexttube = tube
						break
				if(!nexttube)
					pod.dir = turn(pod.dir, 180)

				if(!open && pod)
					pod.follow_tube()

				pod_moving = 0

			return



// Called to check if a pod should stop upon entering this tube.
/obj/structure/transit_tube/proc/should_stop_pod(pod, from_dir)
	return 0



/obj/structure/transit_tube/station/should_stop_pod(pod, from_dir)
	return 1



// Called when a pod stops in this tube section.
/obj/structure/transit_tube/proc/pod_stopped(pod, from_dir)
	return



/obj/structure/transit_tube/station/pod_stopped(obj/structure/transit_tube_pod/pod, from_dir)
	pod_moving = 1
	spawn(5)
		open_animation()
		sleep(OPEN_DURATION + 2)
		pod_moving = 0
		pod.mix_air()

		if(automatic_launch_time)
			var/const/wait_step = 5
			var/i = 0
			while(i < automatic_launch_time)
				sleep(wait_step)
				i += wait_step

				if(pod_moving || !open)
					return

			launch_pod()



// Returns a /list of directions this tube section can connect to.
//  Tubes that have some sort of logic or changing direction might
//  override it with additional logic.
/obj/structure/transit_tube/proc/directions()
	return tube_dirs



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

/obj/structure/transit_tube/proc/test_blocked(in_dir)	//You can now only squeeze under transit tubes if you can go out the same way you came in.
	return (get_exit(in_dir) || get_exit(turn(in_dir, 180)))



// Return how many BYOND ticks to wait before entering/exiting
//  the tube section. Default action is to return the value of
//  a var, which wouldn't need a proc, but it makes it possible
//  for later tube types to interact in more interesting ways
//  such as being very fast in one direction, but slow in others
/obj/structure/transit_tube/proc/exit_delay(pod, to_dir)
	return exit_delay

/obj/structure/transit_tube/proc/enter_delay(pod, to_dir)
	return enter_delay



/obj/structure/transit_tube_pod/proc/follow_tube()
	if(moving)
		return

	moving = 1

	spawn()
		var/obj/structure/transit_tube/current_tube = null
		var/next_dir
		var/next_loc
		var/last_delay = 0
		var/exit_delay

		for(var/obj/structure/transit_tube/tube in loc)
			if(tube.has_exit(dir))
				current_tube = tube
				break

		while(current_tube)
			next_dir = current_tube.get_exit(dir)

			if(!next_dir)
				break

			exit_delay = current_tube.exit_delay(src, dir)
			last_delay += exit_delay

			sleep(exit_delay)

			next_loc = get_step(loc, next_dir)

			current_tube = null
			for(var/obj/structure/transit_tube/tube in next_loc)
				if(tube.has_entrance(next_dir))
					current_tube = tube
					break

			if(current_tube == null)
				dir = next_dir
				Move(get_step(loc, dir)) // Allow collisions when leaving the tubes.
				break

			last_delay = current_tube.enter_delay(src, next_dir)
			sleep(last_delay)
			dir = next_dir
			forceMove(next_loc) // When moving from one tube to another, skip collision and such.
			setDensity(current_tube.density)

			if(current_tube && current_tube.should_stop_pod(src, next_dir))
				current_tube.pod_stopped(src, dir)
				break

		setDensity(TRUE)

		// If the pod is no longer in a tube, move in a line until stopped or slowed to a halt.
		//  /turf/inertial_drift appears to only work on mobs, and re-implementing some of the
		//  logic allows a gradual slowdown and eventual stop when passing over non-space turfs.
		if(!current_tube && last_delay <= 10)
			do
				sleep(last_delay)

				if(!istype(loc, /turf/space))
					last_delay++

				if(last_delay > 10)
					break

			while(isturf(loc) && Move(get_step(loc, dir)))

		moving = 0


// Should I return a copy here? If the caller edits or del()s the returned
//  datum, there might be problems if I don't...
//	Shut up bitch, let's do it MY way
/obj/structure/transit_tube_pod/return_air()
	return air_contents

/obj/structure/transit_tube_pod/assume_air(datum/gas_mixture/giver)
	return air_contents.merge(giver)

/obj/structure/transit_tube_pod/remove_air(amount)
	return air_contents.remove(amount)



// Called when a pod arrives at, and before a pod departs from a station,
//  giving it a chance to mix its internal air supply with the turf it is
//  currently on.
/obj/structure/transit_tube_pod/proc/mix_air()
	ASSERT(isturf(loc))

	var/datum/gas_mixture/environment = loc.return_air()
	if(istype(loc, /turf/simulated)) //An obnoxious hack to prevent super slow draining to space.
		air_contents.share_tiles(environment, 6) //6 simply corresponds to the closest to the previous behavior. I think.
	else
		air_contents.share_space(environment, 6)



// When the player moves, check if the pos is currently stopped at a station.
//  if it is, check the direction. If the direction matches the direction of
//  the station, try to exit. If the direction matches one of the station's
//  tube directions, launch the pod in that direction.
/obj/structure/transit_tube_pod/relaymove(mob/mob, direction)
	if(istype(mob, /mob) && mob.client)
		// If the pod is not in a tube at all, you can get out at any time.
		if(!(locate(/obj/structure/transit_tube) in loc))
			mob.forceMove(loc)
			mob.client.Move(get_step(loc, direction), direction)

			//if(moving && istype(loc, /turf/space))
				// Todo: If you get out of a moving pod in space, you should move as well.
				//  Same direction as pod? Direcion you moved? Halfway between?

		if(!moving)
			for(var/obj/structure/transit_tube/station/station in loc)
				if(dir in station.directions())
					if(!station.pod_moving)
						if(direction == station.dir)
							if(station.open)
								if(allowed(mob))
									mob.forceMove(loc)
									mob.client.Move(get_step(loc, direction), direction)
								else
									to_chat(mob, "<span class='warning'>Access denied.</span>")

							else
								station.open_animation()

						else if(direction in station.directions())
							dir = direction
							station.launch_pod()
					return

			for(var/obj/structure/transit_tube/tube in loc)
				if(dir in tube.directions())
					if(tube.has_exit(direction))
						dir = direction
						return



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

		if(findtextEx(icon_state, "Pass"))
			setDensity(FALSE)



// Tube station directions are simply 90 to either side of
//  the exit.
/obj/structure/transit_tube/station/init_dirs()
	tube_dirs = list(turn(dir, 90), turn(dir, -90))



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



// A copy of text2dir, extended to accept one and two letter
//  directions, and to clearly return 0 otherwise.
/obj/structure/transit_tube/proc/text2dir_extended(direction)
	switch(uppertext(direction))
		if("NORTH", "N")
			return NORTH
		if("SOUTH", "S")
			return SOUTH
		if("EAST", "E")
			return EAST
		if("WEST", "W")
			return WEST
		if("NORTHEAST", "NE")
			return NORTHEAST
		if("NORTHWEST", "NW")
			return NORTHWEST
		if("SOUTHEAST", "SE")
			return SOUTHEAST
		if("SOUTHWEST", "SW")
			return SOUTHWEST
		else
	return 0



// A copy of dir2text, which returns the short one or two letter
//  directions used in tube icon states.
/obj/structure/transit_tube/proc/dir2text_short(direction)
	switch(direction)
		if(NORTH)
			return "N"
		if(SOUTH)
			return "S"
		if(EAST)
			return "E"
		if(WEST)
			return "W"
		if(NORTHEAST)
			return "NE"
		if(SOUTHEAST)
			return "SE"
		if(NORTHWEST)
			return "NW"
		if(SOUTHWEST)
			return "SW"
		else
	return

/obj/structure/transit_tube/proc/iconstate2framedir()
	switch(icon_state)
		if("N-S","NE-SW","N-SW","N-SE","N-SW-SE","N-SE-SW","N-S-pass")
			return NORTH
		if("S-NE","S-NW","S-NE-NW","S-NW-NE")
			return SOUTH
		if("E-W","NW-SE","E-NW","E-SW","E-NW-SW","E-SW-NW","E-W-pass")
			return EAST
		if("W-SE","W-NE","W-SE-NE","W-NE-SE")
			return WEST
		if("closed","open","closing","opening")
			return dir
	return 0

#undef TUBE_POD_UNLOAD_LIMIT
