// A place where tube pods stop, and people can get in or out.
// Mappers: use "Generate Instances from Directions" for this
//  one.
/obj/structure/transit_tube/station
	name = "station tube station"
	icon = 'icons/obj/pipes/transit_tube_station.dmi'
	icon_state = "closed"
	pixel_x = 0
	pixel_y = 0
	enter_delay = 2
	exit_delay = 1
	layer = ABOVE_OBJ_LAYER
	var/pod_moving = 0
	var/cooldown_delay = 50
	var/launch_cooldown = 0
	var/reverse_launch = 0
	var/const/OPEN_DURATION = 2
	var/const/CLOSE_DURATION = 2

/obj/structure/transit_tube/station/New()
	..()
	processing_objects += src

/obj/structure/transit_tube/station/Destroy()
	processing_objects -= src
	..()

//Attacks

/obj/structure/transit_tube/station/attack_hand(mob/user)
	if(!pod_moving)
		for(var/obj/structure/transit_tube_pod/pod in loc)
			if(!pod.moving && (pod.dir in directions()))
				if(icon_state == "closed")
					open_animation()
				else
					if(!user.lying && user.loc != pod)
						var/unloaded = 0
						var/incomplete = FALSE

						for(var/atom/movable/AM in pod)
							if(isobserver(AM))
								continue
							if(unloaded >= 20)
								incomplete = TRUE
								break
							AM.forceMove(get_step(loc, dir))
							unloaded++

						if(unloaded)
							user.visible_message("<span class='notice'>[user] unloads [incomplete ? "some things" : "everything"] from the tube pod.</span>", \
							"<span class='notice'>You unload [incomplete ? "some things" : "everything"] from the tube pod.</span>")
							return
					close_animation()

/obj/structure/transit_tube/station/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/grab) && icon_state == "open")
		var/obj/item/weapon/grab/G = W
		if(ismob(G.affecting) && G.state >= GRAB_AGGRESSIVE)
			var/mob/GM = G.affecting
			for(var/obj/structure/transit_tube_pod/pod in loc)
				pod.visible_message("<span class='warning'>[user] starts putting [GM] into the [pod]!</span>")
				if(do_after(user, 60) && GM && G && G.affecting == GM)
					src.Bumped(GM)
					qdel(G)
				break
		return
	..()

/obj/structure/transit_tube/station/attack_robot(mob/user)
	if(Adjacent(user))
		attack_hand(user)

/obj/structure/transit_tube/station/proc/handleGrab(obj/item/weapon/grab/G as obj, mob/user as mob)
	if(do_after(user, src, 1) && G && G.affecting)
		if(!pod_moving && icon_state == "open" && (get_dir(src, user) == dir))
			if(allowed(G.affecting))
				var/obj/structure/transit_tube_pod/pod = locate() in loc
				if(pod && !pod.moving && (pod.dir in directions()))
					var/mob/M = G.affecting
					if(M.client)
						M.client.perspective = EYE_PERSPECTIVE
						M.client.eye = src
					M.forceMove(src)
					//WIP src.occupant = M
					qdel(G)
					update_icon()
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")

/obj/structure/transit_tube/station/MouseDropTo(mob/target, mob/user)
	if(!pod_moving && icon_state == "open" && (get_dir(src, user) == dir))
		if(allowed(target))
			var/obj/structure/transit_tube_pod/pod = locate() in loc
			if(pod && !pod.moving && (pod.dir in directions()))
				target.forceMove(pod)
				if(user.client)
					user.client.perspective = EYE_PERSPECTIVE
					user.client.eye = src
					//WIP src.occupant = user
					update_icon()
				return
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

//This doesn't work
/obj/structure/transit_tube/station/Bumped(atom/movable/mover)
	if(!pod_moving && icon_state == "open" && (get_dir(src, mover) == dir) && isliving(mover))
		var/mob/living/L = mover
		if(allowed(L))
			var/obj/structure/transit_tube_pod/pod = locate() in loc
			if(pod && !pod.moving && (pod.dir in directions()))
				mover.forceMove(pod)
				return
		else
			to_chat(L, "<span class='warning'>Access denied.</span>")
	..()

/obj/structure/transit_tube/station/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	return TRUE

//Pod stationed

/obj/structure/transit_tube/station/proc/open_animation()
	if(icon_state == "closed")
		icon_state = "opening"
		spawn(OPEN_DURATION)
			if(icon_state == "opening")
				icon_state = "open"

/obj/structure/transit_tube/station/proc/close_animation()
	if(icon_state == "open")
		icon_state = "closing"
		spawn(CLOSE_DURATION)
			if(icon_state == "closing")
				icon_state = "closed"

/obj/structure/transit_tube/station/proc/launch_pod()
	if(launch_cooldown >= world.time)
		return
	for(var/obj/structure/transit_tube_pod/pod in loc)
		if(!pod.moving && (turn(pod.dir, (reverse_launch ? 180 : 0)) in directions()))
			spawn(0)
				pod_moving = 1
				close_animation()
				sleep(CLOSE_DURATION + 2)
				if(icon_state == "closed" && pod)
					pod.follow_tube(reverse_launch)
				pod_moving = 0
			return 1
	return 0

/obj/structure/transit_tube/station/process()
	if(!pod_moving)
		launch_pod()

// Stations which will send the tube in the opposite direction after their stop.
/obj/structure/transit_tube/station/reverse
	reverse_launch = 1

/obj/structure/transit_tube/station/should_stop_pod(pod, from_dir)
	return 1


/obj/structure/transit_tube/station/pod_stopped(obj/structure/transit_tube_pod/pod, from_dir)
	pod_moving = 1
	spawn(5)
		launch_cooldown = world.time + cooldown_delay
		open_animation()
		sleep(OPEN_DURATION + 2)
		pod_moving = 0
		pod.mix_air()

// Tube station directions are simply 90 to either side of
//  the exit.
/obj/structure/transit_tube/station/init_dirs()
	tube_dirs = list(turn(dir, 90), turn(dir, -90))
