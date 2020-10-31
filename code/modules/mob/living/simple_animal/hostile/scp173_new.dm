//SCP-173 II: Electric Boogaloo
/mob/living/simple_animal/scp_173
	name = "SCP-173"
	desc = "It's some kind of hastily-painted human-size stone sculpture. Just looking at it makes you feel nervous."
	icon = 'icons/mob/scp.dmi'
	icon_state = "sculpture"
	icon_living = "sculpture"
	icon_dead = "sculpture"
	emote_hear = list("makes a faint scraping sound")
	emote_see = list("twitches slightly", "shivers")
	response_help  = "touches the"
	response_disarm = "pushes the"
	response_harm   = "hits the"
	meat_type = null
	see_in_dark = 8 
	mob_property_flags = MOB_SUPERNATURAL|MOB_CONSTRUCT
	status_flags = CANSTUN|CANKNOCKDOWN|CANPARALYSE|CANPUSH|UNPACIFIABLE

	var/is_chasing_target = FALSE
	var/mob/living/carbon/human/current_target
	var/jump_size = 4	//Number of tiles per jump.

/mob/living/simple_animal/scp_173/New()
	. = ..()
	flags |= INVULNERABLE

/mob/living/simple_animal/scp_173/Life()
	if(timestopped)
		return 0 //Under effects of time magick
	if(is_chasing_target)
		return

	findtarget()	//Try to find the nearest target

	if(current_target)  //We have a target? Start chasing them.
		visible_message("The [src] starts to chase!")
		chasetarget()
	else
		visible_message("The [src] is idle.")	//for testing


/mob/living/simple_animal/scp_173/proc/findtarget()

	//Find out what mobs we can see for targetting purposes
	var/list/conscious = list()
	for(var/mob/living/carbon/human/H in view(12, src))
		if(H.stat == CONSCIOUS) //He's up and running
			conscious.Add(H)

	//Pick the nearest valid conscious target
	var/mob/living/carbon/human/target
	for(var/mob/living/carbon/human/H in conscious)
		if(!target || get_dist(src, H) < get_dist(src, target))
			target = H

	current_target = target

/mob/living/simple_animal/scp_173/proc/chasetarget()

	is_chasing_target = TRUE

	while(is_hidden())
		var/turf/target_turf = get_turf(current_target)
		var/turf/our_turf = get_turf(src)
		if(get_dist(our_turf, target_turf) > 12)	//The target escaped...
			break
		if(our_turf.z != target_turf.z)	//the target is on a different z level, ABORT
			break
		
		var/turf/next_jump_turf
		var/nextX = min(target_turf.x, our_turf.x + jump_size)
		var/nextY = min(target_turf.y, our_turf.y + jump_size)
		
		next_jump_turf = locate(nextX, nextY, our_turf.z)

		//We have the turf we want to move on to, now we check to see if theres a clear path.
		attempt_move(next_jump_turf)

		if(get_turf(src) == get_turf(current_target))	//We met the target, snap their neck!
			visible_message("[src] snaps the neck of [current_target]!")
			//snap_neck(current_target)
			break

		//we moved, but we didn't reach the target yet
		sleep(5)

	is_chasing_target = FALSE


/mob/living/simple_animal/scp_173/proc/attempt_move(var/turf/target_turf)
	var/turf/turf_to_check
	var/turf/previous_turf = get_turf(src)

	while(turf_to_check != target_turf)
		turf_to_check = get_step_towards(previous_turf, target_turf)

		//Somebody can see us if we move to the next turf. Let's settle with moving to the previous one then.
		if(!is_hidden(turf_to_check))
			forceMove(previous_turf)
			return
		
		//Smash and/or open everything we can in the path
		for(var/obj/structure/window/W in turf_to_check)
			W.shatter()
		for(var/obj/structure/table/O in turf_to_check)
			O.ex_act(1)
		for(var/obj/structure/closet/C in turf_to_check)
			C.ex_act(1)
		for(var/obj/structure/grille/G in turf_to_check)
			G.ex_act(1)
		for(var/obj/machinery/door/airlock/A in turf_to_check)
			if(A.welded || A.locked) 
				continue
			A.open()
		for(var/obj/machinery/door/D in turf_to_check)
			D.open()

		//We still can't cross the turf. Let's settle with moving to the previous one then.
		if(!turf_to_check.Cross(src, turf_to_check))
			forceMove(previous_turf)
			return 

		//We've reached our destination
		if(turf_to_check == target_turf)
			forceMove(turf_to_check)
			return

		previous_turf = turf_to_check



//Check if somebody can 'see' 173. If provided a turf the proc will check if someone can see that turf instead. 		
/mob/living/simple_animal/scp_173/proc/is_hidden(var/turf/T)

	var/turf/check_turf
	if(T)
		check_turf = T
	else 
		check_turf = get_turf(src)

	//If SCP-173 is in darkness, nothing can see it
	if(istype(check_turf, /turf/simulated)) //Simulated turfs only
		var/turf/simulated/sim = check_turf
		if(!sim.affecting_lights || !sim.affecting_lights.len) //Check if there is any light on that turf. If not, we're in darkness and can move freely.
			return 1

	//Note that humans have a 180 degrees field of vision for the purposes of this proc
	for(var/mob/living/carbon/human/H in view(7, check_turf))	//Lets just assume that all humans have default vision-distance. Binoculars and far-sighted people be damned.
		if(H.stat)	//dead people can't see
			continue
		if(H.is_blind())	//blind people can't see
			continue

		var/x_diff = H.x - check_turf.x
		var/y_diff = H.y - check_turf.y

		if(y_diff != 0) //If we are not on the same vertical plane (up/down), mob is either above or below src
			if(y_diff < 0 && H.dir == NORTH) //Mob is below src and looking up
				return 0
			else if(y_diff > 0 && H.dir == SOUTH) //Mob is above src and looking down
				return 0
		if(x_diff != 0) //If we are not on the same horizontal plane (left/right), mob is either left or right of src
			if(x_diff < 0 && H.dir == EAST) //Mob is left of src and looking right
				return 0
			else if(x_diff > 0 && H.dir == WEST) //Mob is right of src and looking left
				return 0


	return 1 //Success, let's move