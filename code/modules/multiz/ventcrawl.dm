/obj/machinery/atmospherics/pipe/zpipe/up/verb/ventcrawl_move_up()
	set name = "Ventcrawl Upwards"
	set desc = "Climb up through a pipe."
	set category = "Abilities"
	set src = usr.loc
	var/obj/machinery/atmospherics/target = check_ventcrawl(GetAbove(loc))
	if(target)
		ventcrawl_to(usr, target, UP)

/obj/machinery/atmospherics/pipe/zpipe/down/verb/ventcrawl_move_down()
	set name = "Ventcrawl Downwards"
	set desc = "Climb down through a pipe."
	set category = "Abilities"
	set src = usr.loc
	var/obj/machinery/atmospherics/target = check_ventcrawl(GetBelow(loc))
	if(target)
		ventcrawl_to(usr, target, DOWN)

/obj/machinery/atmospherics/pipe/zpipe/proc/check_ventcrawl(var/turf/target)
	if(!istype(target))
		return
	if(node1 in target)
		return node1
	if(node2 in target)
		return node2
	return


//We used the relaymove in atmospherics.dm to handle this previously, but it was similar so now that calls this
/obj/machinery/atmospherics/proc/ventcrawl_to(var/mob/living/user, var/obj/machinery/atmospherics/target_move, var/direction)
	if(target_move)
		if(is_type_in_list(target_move, ventcrawl_machinery) && target_move.can_crawl_through())
			if(user.special_delayer.blocked())
				return
			user.delayNextSpecial(10)
			user.visible_message("Something is squeezing through the ducts...", "You start crawling out the ventilation system.")
			target_move.shake(2, 3)
			spawn(0)
				if(do_after(user, target_move, 10))
					user.remove_ventcrawl()
					user.forceMove(target_move.loc) //handles entering and so on
					user.visible_message("You hear something squeeze through the ducts.", "You climb out the ventilation system.")
		else if(target_move.can_crawl_through())
			if(target_move.return_network(target_move) != return_network(src))
				user.remove_ventcrawl()
				user.add_ventcrawl(target_move)
			if (user.client.prefs.stumble && ((world.time - user.last_movement) > 5))
				user.delayNextMove(3)	//if set, delays the second step when a mob starts moving to attempt to make precise high ping movement easier
			user.forceMove(target_move)
			user.client.eye = target_move //if we don't do this, Byond only updates the eye every tick - required for smooth movement
			user.last_movement=world.time
			if(world.time - user.last_played_vent > VENT_SOUND_DELAY)
				user.last_played_vent = world.time
				playsound(src, 'sound/machines/ventcrawl.ogg', 50, 1, -3)
	else
		if((direction & initialize_directions) || is_type_in_list(src, ventcrawl_machinery) && src.can_crawl_through()) //if we move in a way the pipe can connect, but doesn't - or we're in a vent
			user.remove_ventcrawl()
			user.forceMove(src.loc, glide_size_override = DELAY2GLIDESIZE(1))
			user.visible_message("You hear something squeezing through the pipes.", "You climb out the ventilation system.")
	user.canmove = 0
	spawn(1)
		user.canmove = 1
