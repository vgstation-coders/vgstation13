/obj/structure/transit_tube_pod
	name = "transit pod"
	icon = 'icons/obj/pipes/transit_tube_pod.dmi'
	icon_state = "pod"
	animate_movement = FORWARD_STEPS
	anchored = 1.0
	density = 1
	var/moving = 0
	var/datum/gas_mixture/air_contents = new()

/obj/structure/transit_tube_pod/New(loc)
	..(loc)

	// Give auto tubes time to align before trying to start moving
	spawn(5)
		follow_tube()

/obj/structure/transit_tube_pod/Destroy()
	for(var/atom/movable/AM in contents)
		AM.loc = loc

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

/obj/structure/transit_tube_pod/proc/empty_pod(atom/location)
	if(!location)
		location = get_turf(src)
	for(var/atom/movable/M in contents)
		M.forceMove(location)
	update_icon()
	
/obj/structure/transit_tube_pod/Process_Spacemove()
	if(moving) //No drifting while moving in the tubes
		return TRUE
	else
		return ..()
	
/obj/structure/transit_tube_pod/proc/follow_tube(var/reverse_launch)
	if(moving)
		return

	moving = 1

	spawn()
		var/obj/structure/transit_tube/current_tube = null
		var/next_dir
		var/next_loc
		var/last_delay = 0
		var/exit_delay

		if(reverse_launch)
			dir = turn(dir, 180) // Back it up

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
			loc = next_loc // When moving from one tube to another, skip collision and such.
			density = current_tube.density

			if(current_tube && current_tube.should_stop_pod(src, next_dir))
				current_tube.pod_stopped(src, dir)
				break

		density = 1

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
		
/obj/structure/transit_tube_pod/examine(mob/user)
	..()
	show_occupants(user)

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


// When the player moves, check if the pod is currently stopped at a station.
//  if it is, check the direction. If the direction matches the direction of
//  the station, try to exit. If the direction matches one of the station's
//  tube directions, launch the pod in that direction.
/obj/structure/transit_tube_pod/relaymove(mob/mob, direction)
	if(istype(mob, /mob) && mob.client)
		// If the pod is not in a tube at all, you can get out at any time.
		if(!(locate(/obj/structure/transit_tube) in loc))
			mob.loc = loc
			mob.client.Move(get_step(loc, direction), direction)
			mob.reset_view(null)

			//if(moving && istype(loc, /turf/space))
				// Todo: If you get out of a moving pod in space, you should move as well.
				//  Same direction as pod? Direcion you moved? Halfway between?

		if(!moving)
			for(var/obj/structure/transit_tube/station/station in loc)
				if(dir in station.directions())
					if(!station.pod_moving)
						if(direction == station.dir)
							if(station.icon_state == "open")
								mob.loc = loc
								mob.client.Move(get_step(loc, direction), direction)
								mob.reset_view(null)

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