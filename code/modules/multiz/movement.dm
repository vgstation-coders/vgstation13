/mob/verb/up()
	set name = "Move Upwards"
	set category = "IC"

	if(zMove(UP))
		to_chat(src, "<span class='notice'>You move upwards.</span>")

/mob/verb/down()
	set name = "Move Down"
	set category = "IC"

	if(zMove(DOWN))
		to_chat(src, "<span class='notice'>You move down.</span>")

/mob/proc/zMove(direction)
	//if(eyeobj) This probably belongs in AIMove
	//	return eyeobj.zMove(direction)
	if(!can_ztravel())
		to_chat(src, "<span class='warning'>You lack means of travel in that direction.</span>")
		return

	var/turf/start = loc
	if(!istype(start))
		to_chat(src, "<span class='notice'>You are unable to move from here.</span>")
		return 0

	var/turf/destination = (direction == UP) ? GetAbove(src) : GetBelow(src)
	if(!destination)
		to_chat(src, "<span class='notice'>There is nothing of interest in this direction.</span>")
		return 0

	if(!start.CanZPass(src, direction))
		to_chat(src, "<span class='warning'>\The [start] is in the way.</span>")
		return 0

	if(!destination.CanZPass(src, direction))
		to_chat(src, "<span class='warning'>\The [destination] blocks your way.</span>")
		return 0

	var/area/area = get_area(src)
	if(direction == UP && area.gravity)
		var/obj/structure/lattice/lattice = locate() in destination.contents
		if(lattice && held_items.len && size != SIZE_TINY) // We need hands and to be big enough
			var/pull_up_time = max(5 SECONDS + (src.movement_delay() * 10), 1)
			to_chat(src, "<span class='notice'>You grab \the [lattice] and start pulling yourself upward...</span>")
			destination.visible_message("<span class='notice'>You hear something climbing up \the [lattice].</span>")
			if(do_after(src, pull_up_time))
				to_chat(src, "<span class='notice'>You pull yourself up.</span>")
			else
				to_chat(src, "<span class='warning'>You gave up on pulling yourself up.</span>")
				return 0
		else if(!flying)
			if(ishuman(src)) // Weird way to handle jetpack stuff
				var/mob/living/carbon/human/H = src
				if(istype(H.back, /obj/item/weapon/tank/jetpack)) // Finally, jetpacks allow it
					var/obj/item/weapon/tank/jetpack/J = H.back
					if(H.lying || (!J.allow_thrust(0.01, src)))
						to_chat(src, "<span class='warning'>Gravity stops you from moving upward.</span>")
						return 0
				else
					to_chat(src, "<span class='warning'>Gravity stops you from moving upward.</span>")
					return 0

			else if(isrobot(src)) // Weird way to handle jetpack stuff, robot edition
				var/mob/living/silicon/robot/R = src
				if(R.module) // Finally, jetpacks allow it
					for(var/obj/item/weapon/tank/jetpack/J in R.module.modules)
						if(!J || !istype(J, /obj/item/weapon/tank/jetpack) || !J.allow_thrust(0.01, src))
							to_chat(src, "<span class='warning'>Gravity stops you from moving upward.</span>")
							return 0
				else
					to_chat(src, "<span class='warning'>Gravity stops you from moving upward.</span>")
					return 0
			else
				to_chat(src, "<span class='warning'>Gravity stops you from moving upward.</span>")
				return 0

	for(var/atom/A in destination)
		if(!A.Cross(src, start, 1.5, 0))
			to_chat(src, "<span class='warning'>\The [A] blocks you.</span>")
			return 0
	if(!Move(destination))
		return 0
	return 1

/mob/dead/observer/zMove(direction)
	var/turf/destination = (direction == UP) ? GetAbove(src) : GetBelow(src)
	if(destination)
		forceMove(destination)
	else
		to_chat(src, "<span class='notice'>There is nothing of interest in this direction.</span>")

/mob/camera/zMove(direction)
	var/turf/destination = (direction == UP) ? GetAbove(src) : GetBelow(src)
	if(destination)
		forceMove(destination)
	else
		to_chat(src, "<span class='notice'>There is nothing of interest in this direction.</span>")

/mob/proc/can_ztravel()
	return flying

/mob/dead/observer/can_ztravel()
	return 1

/mob/living/carbon/human/can_ztravel()
	if(incapacitated())
		return 0

	if(Process_Spacemove())
		return 1
	
	if(flying)
		return 1

	if(istype(back, /obj/item/weapon/tank/jetpack)) // Finally, jetpacks allow it
		var/obj/item/weapon/tank/jetpack/J = back
		if(!lying && (J.allow_thrust(0.01, src)))
			return 1

/*  This would be really easy to implement but let's talk about if we WANT it.

	if(Check_Shoegrip())	//scaling hull with magboots
		for(var/turf/simulated/T in trange(1,src))
			if(T.density)
				return 1 */

/mob/living/silicon/robot/can_ztravel()
	if(incapacitated())
		return 0

	if(Process_Spacemove()) //Checks for active jetpack
		return 1

	if(flying)
		return 1
	
	if(module) // Finally, jetpacks allow it
		for(var/obj/item/weapon/tank/jetpack/J in module.modules)
			if(J && istype(J, /obj/item/weapon/tank/jetpack))
				if(J.allow_thrust(0.01, src))
					return 1
	
/* Same as above, hull scaling discussion pending

	for(var/turf/simulated/T in trange(1,src)) //Robots get "magboots"
		if(T.density)
			return 1*/