/mob/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0)) return 1

	if(ismob(mover))
		var/mob/moving_mob = mover

		if ((other_mobs && moving_mob.other_mobs))
			return 1

	return (!mover.density || !density || lying)

/client/North()
	..()


/client/South()
	..()


/client/West()
	..()


/client/East()
	..()


/client/Northeast()
	swap_hand()
	return


/client/Southeast()
	attack_self()
	return


/client/Southwest()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.toggle_throw_mode()
	else
		usr << "\red This mob type cannot throw items."
	return


/client/Northwest()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(!C.get_active_hand())
			usr << "\red You have nothing to drop in your hand."
			return
		drop_item()
	else
		usr << "\red This mob type cannot drop items."
	return

//This gets called when you press the delete button.
/client/verb/delete_key_pressed()
	set hidden = 1

	if(!usr.pulling)
		usr << "\blue You are not pulling anything."
		return
	usr.stop_pulling()

/client/verb/swap_hand()
	set hidden = 1
	if(istype(mob, /mob/living/carbon))
		mob:swap_hand()
	if(istype(mob,/mob/living/silicon/robot/mommi))
		return // MoMMIs only have one tool slot.
	if(istype(mob,/mob/living/silicon/robot))//Oh nested logic loops, is there anything you can't do? -Sieve
		var/mob/living/silicon/robot/R = mob
		if(!R.module_active)
			if(!R.module_state_1)
				if(!R.module_state_2)
					if(!R.module_state_3)
						return
					else
						R:inv1.icon_state = "inv1"
						R:inv2.icon_state = "inv2"
						R:inv3.icon_state = "inv3 +a"
						R:module_active = R:module_state_3
				else
					R:inv1.icon_state = "inv1"
					R:inv2.icon_state = "inv2 +a"
					R:inv3.icon_state = "inv3"
					R:module_active = R:module_state_2
			else
				R:inv1.icon_state = "inv1 +a"
				R:inv2.icon_state = "inv2"
				R:inv3.icon_state = "inv3"
				R:module_active = R:module_state_1
		else
			if(R.module_active == R.module_state_1)
				if(!R.module_state_2)
					if(!R.module_state_3)
						return
					else
						R:inv1.icon_state = "inv1"
						R:inv2.icon_state = "inv2"
						R:inv3.icon_state = "inv3 +a"
						R:module_active = R:module_state_3
				else
					R:inv1.icon_state = "inv1"
					R:inv2.icon_state = "inv2 +a"
					R:inv3.icon_state = "inv3"
					R:module_active = R:module_state_2
			else if(R.module_active == R.module_state_2)
				if(!R.module_state_3)
					if(!R.module_state_1)
						return
					else
						R:inv1.icon_state = "inv1 +a"
						R:inv2.icon_state = "inv2"
						R:inv3.icon_state = "inv3"
						R:module_active = R:module_state_1
				else
					R:inv1.icon_state = "inv1"
					R:inv2.icon_state = "inv2"
					R:inv3.icon_state = "inv3 +a"
					R:module_active = R:module_state_3
			else if(R.module_active == R.module_state_3)
				if(!R.module_state_1)
					if(!R.module_state_2)
						return
					else
						R:inv1.icon_state = "inv1"
						R:inv2.icon_state = "inv2 +a"
						R:inv3.icon_state = "inv3"
						R:module_active = R:module_state_2
				else
					R:inv1.icon_state = "inv1 +a"
					R:inv2.icon_state = "inv2"
					R:inv3.icon_state = "inv3"
					R:module_active = R:module_state_1
			else
				return
	return



/client/verb/attack_self()
	set hidden = 1
	if(mob)
		mob.mode()
	return


/client/verb/toggle_throw_mode()
	set hidden = 1
	if(!istype(mob, /mob/living/carbon))
		return
	if (!mob.stat && isturf(mob.loc) && !mob.restrained())
		mob:toggle_throw_mode()
	else
		return


/client/verb/drop_item()
	set hidden = 1
	if(!isrobot(mob))
		mob.drop_item_v()
	return


/client/Center()
	/* No 3D movement in 2D spessman game. dir 16 is Z Up
	if (isobj(mob.loc))
		var/obj/O = mob.loc
		if (mob.canmove)
			return O.relaymove(mob, 16)
	*/
	return

/client/proc/Move_object(direct)
	if(mob && mob.control_object)
		if(mob.control_object.density)
			step(mob.control_object,direct)
			if(!mob.control_object)	return
			mob.control_object.dir = direct
		else
			mob.control_object.loc = get_step(mob.control_object,direct)
	return

/client/Move(loc,dir)
	if(!mob)
		return // Moved here to avoid nullrefs below. - N3X

	// /vg/ - Deny clients from moving certain mobs. (Like cluwnes :^)
	if(mob.deny_client_move)
		src << "<span class='warning'>You cannot move this mob.</span>"
		return

	if(mob.control_object)	Move_object(dir)

	if(isobserver(mob))	return mob.Move(loc, dir)

	if(moving)	return 0

	if(world.time < move_delay)	return

	if(locate(/obj/effect/stop/, mob.loc))
		for(var/obj/effect/stop/S in mob.loc)
			if(S.victim == mob)
				return

	if(mob.stat==2)	return

	if(isAI(mob))	return AIMove(loc,dir,mob)

	if(mob.monkeyizing)	return//This is sota the goto stop mobs from moving var

	if(isliving(mob))
		var/mob/living/L = mob
		if(L.incorporeal_move)//Move though walls
			Process_Incorpmove(dir)
			return

	if(Process_Grab())	return

	if(mob.buckled)							//if we're buckled to something, tell it we moved.
		return mob.buckled.relaymove(mob, dir)

	if(!mob.canmove)	return

	//if(istype(mob.loc, /turf/space) || (mob.flags & NOGRAV))
	//	if(!mob.Process_Spacemove(0))	return 0

	if(!mob.lastarea)
		mob.lastarea = get_area(mob.loc)

	if((istype(mob.loc, /turf/space)) || ((mob.lastarea.has_gravity == 0) && (!istype(mob.loc, /obj/spacepod))))  // last section of if statement prevents spacepods being unable to move when the gravity goes down
		if(!mob.Process_Spacemove(0))	return 0


	if(isobj(mob.loc) || ismob(mob.loc))//Inside an object, tell it we moved
		var/atom/O = mob.loc
		return O.relaymove(mob, dir)

	if(isturf(mob.loc))

		if(mob.restrained())//Why being pulled while cuffed prevents you from moving
			for(var/mob/M in range(mob, 1))
				if(M.pulling == mob)
					if(!M.restrained() && M.stat == 0 && M.canmove && mob.Adjacent(M))
						src << "\blue You're restrained! You can't move!"
						return 0
					else
						M.stop_pulling()

		if(mob.pinned.len)
			src << "\blue You're pinned to a wall by [mob.pinned[1]]!"
			return 0

		move_delay = world.time//set move delay
		mob.last_move_intent = world.time + 10
		switch(mob.m_intent)
			if("run")
				if(mob.drowsyness > 0)
					move_delay += 6
				move_delay += 1+config.run_speed
			if("walk")
				move_delay += 7+config.walk_speed
		move_delay += mob.movement_delay()

		if(config.Tickcomp)
			move_delay -= 1.3
			var/tickcomp = ((1/(world.tick_lag))*1.3)
			move_delay = move_delay + tickcomp




		//We are now going to move
		moving = 1
		//Something with pulling things
		if(locate(/obj/item/weapon/grab, mob))
			move_delay = max(move_delay, world.time + 7)
			var/list/L = mob.ret_grab()
			if(istype(L, /list))
				if(L.len == 2)
					L -= mob
					var/mob/M = L[1]
					if(M)
						if ((get_dist(mob, M) <= 1 || M.loc == mob.loc))
							var/turf/T = mob.loc
							. = ..()
							if (isturf(M.loc))
								var/diag = get_dir(mob, M)
								if ((diag - 1) & diag)
								else
									diag = null
								if ((get_dist(mob, M) > 1 || diag))
									step(M, get_dir(M.loc, T))
				else
					for(var/mob/M in L)
						M.other_mobs = 1
						if(mob != M)
							M.animate_movement = 3
					for(var/mob/M in L)
						spawn( 0 )
							step(M, dir)
							return
						spawn( 1 )
							M.other_mobs = null
							M.animate_movement = 2
							return

		else if(mob.confused)
			step_rand(mob)
			mob.last_movement=world.time
		else
			. = ..()
			mob.last_movement=world.time

		moving = 0

		return .

	return


///Process_Grab()
///Called by client/Move()
///Checks to see if you are being grabbed and if so attemps to break it
/client/proc/Process_Grab()
	if(locate(/obj/item/weapon/grab, locate(/obj/item/weapon/grab, mob.grabbed_by.len)))
		var/list/grabbing = list()
		if(istype(mob.l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = mob.l_hand
			grabbing += G.affecting
		if(istype(mob.r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = mob.r_hand
			grabbing += G.affecting
		for(var/obj/item/weapon/grab/G in mob.grabbed_by)
			if((G.state == 1)&&(!grabbing.Find(G.assailant)))	del(G)
			if(G.state == 2)
				move_delay = world.time + 10
				if(!prob(25))	return 1
				mob.visible_message("\red [mob] has broken free of [G.assailant]'s grip!")
				del(G)
			if(G.state == 3)
				move_delay = world.time + 10
				if(!prob(5))	return 1
				mob.visible_message("\red [mob] has broken free of [G.assailant]'s headlock!")
				del(G)
	return 0


///Process_Incorpmove
///Called by client/Move()
///Allows mobs to run though walls
/client/proc/Process_Incorpmove(direct)
	var/turf/mobloc = get_turf(mob)
	if(!isliving(mob))
		return
	var/mob/living/L = mob
	switch(L.incorporeal_move)
		if(1)
			L.loc = get_step(L, direct)
			L.dir = direct
		if(2)
			if(prob(50))
				var/locx
				var/locy
				switch(direct)
					if(NORTH)
						locx = mobloc.x
						locy = (mobloc.y+2)
						if(locy>world.maxy)
							return
					if(SOUTH)
						locx = mobloc.x
						locy = (mobloc.y-2)
						if(locy<1)
							return
					if(EAST)
						locy = mobloc.y
						locx = (mobloc.x+2)
						if(locx>world.maxx)
							return
					if(WEST)
						locy = mobloc.y
						locx = (mobloc.x-2)
						if(locx<1)
							return
					else
						return
				L.loc = locate(locx,locy,mobloc.z)
				spawn(0)
					var/limit = 2//For only two trailing shadows.
					for(var/turf/T in getline(mobloc, L.loc))
						spawn(0)
							anim(T,L,'icons/mob/mob.dmi',,"shadow",,L.dir)
						limit--
						if(limit<=0)	break
			else
				spawn(0)
					anim(mobloc,mob,'icons/mob/mob.dmi',,"shadow",,L.dir)
				L.loc = get_step(L, direct)
			L.dir = direct
	return 1


///Process_Spacemove
///Called by /client/Move()
///For moving in space
///Return 1 for movement 0 for none
/mob/proc/Process_Spacemove(var/check_drift = 0)
	//First check to see if we can do things
	if(restrained())
		return 0

	/*
	if(istype(src,/mob/living/carbon))
		if(src.l_hand && src.r_hand)
			return 0
	*/

	var/dense_object = 0
	for(var/turf/turf in oview(1,src))
		if(istype(turf,/turf/space))
			continue

		if(istype(src,/mob/living/carbon/human/))  // Only humans can wear magboots, so we give them a chance to.
			if((istype(turf,/turf/simulated/floor)) && (src.lastarea.has_gravity == 0) && !(istype(src:shoes, /obj/item/clothing/shoes/magboots) && (src:shoes:flags & NOSLIP)))
				continue


		else
			if((istype(turf,/turf/simulated/floor)) && (src.lastarea && src.lastarea.has_gravity == 0)) // No one else gets a chance.
				continue



		/*
		if(istype(turf,/turf/simulated/floor) && (src.flags & NOGRAV))
			continue
		*/


		dense_object++
		break

	if(!dense_object && (locate(/obj/structure/lattice) in oview(1, src)))
		dense_object++

	//Lastly attempt to locate any dense objects we could push off of
	//TODO: If we implement objects drifing in space this needs to really push them
	//Due to a few issues only anchored and dense objects will now work.
	if(!dense_object)
		for(var/obj/O in oview(1, src))
			if((O) && (O.density) && (O.anchored))
				dense_object++
				break

	//Nothing to push off of so end here
	if(!dense_object)
		return 0



	//Check to see if we slipped
	if(prob(Process_Spaceslipping(5)))
		src << "\blue <B>You slipped!</B>"
		src.inertia_dir = src.last_move
		step(src, src.inertia_dir)
		return 0
	//If not then we can reset inertia and move
	inertia_dir = 0
	return 1


/mob/proc/Process_Spaceslipping(var/prob_slip = 5)
	//Setup slipage
	//If knocked out we might just hit it and stop.  This makes it possible to get dead bodies and such.
	if(stat)
		prob_slip = 0  // Changing this to zero to make it line up with the comment.

	prob_slip = round(prob_slip)
	return(prob_slip)