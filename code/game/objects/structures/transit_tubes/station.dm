#define TUBE_POD_UNLOAD_LIMIT 20

/obj/structure/transit_tube/station/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	if(open && get_dir(src, mover) == dir) //This actually isn't necessary right now, but will be if BYOND movecode ever becomes not flaming garbage.
		return FALSE
	return ..()

/obj/structure/transit_tube/station/Crossed(atom/movable/mover)
	if(!open) //Don't show the text if they're getting out of the pod. This also stops them from getting it if they just walk under it from behind while it's open, but oh well. Thanks BYOND.
		return ..()
		
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

/obj/structure/transit_tube/station/should_stop_pod(pod, from_dir)
	return 1

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
			
// Tube station directions are simply 90 to either side of
//  the exit.
/obj/structure/transit_tube/station/init_dirs()
	tube_dirs = list(turn(dir, 90), turn(dir, -90))

#undef TUBE_POD_UNLOAD_LIMIT