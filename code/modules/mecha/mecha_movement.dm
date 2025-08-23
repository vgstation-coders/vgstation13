//////////////////////////////////
////////  Movement procs  ////////
//////////////////////////////////

/obj/mecha/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	.=..()
	pressure_act() // this goes here until I can figure out how new processing works

/obj/mecha/relaymove(mob/user,direction)
	..()
	if(user != src.occupant) //While not "realistic", this piece is player friendly.
		user.forceMove(get_turf(src))
		to_chat(user, "You climb out from [src]")
		return 0
	if(connected_port)
		occupant_message("Unable to move while connected to the air system port.", TRUE)
		return 0
	if(lock_controls) //No moving while using the Gravpult!
		return 0
	if(throwing)
		return 0
	if(state)
		occupant_message("<span class='red'>Maintenance protocols in effect.</span>", TRUE)
		return
	return domove(direction)

/obj/mecha/proc/set_control_lock(var/lock=0,var/delay=0)
	spawn(delay)
		lock_controls = lock

/obj/mecha/proc/domove(direction)
	return call((proc_res["dyndomove"]||src), "dyndomove")(direction)

/obj/mecha/proc/get_step_delay(var/tally = 0)

	if(equipment.len)
		for(var/obj/item/mecha_parts/mecha_equipment/ME in equipment)
			if(ME.get_step_delay())
				tally += ME.get_step_delay()

	for(var/slot in internal_components)
		var/obj/item/mecha_parts/component/C = internal_components[slot]
		if(C && C.get_step_delay())
			tally += C.get_step_delay()

	if(tally <= weight_max)
		tally = 0
	else
		tally -= weight_max

	var/obj/item/mecha_parts/component/actuator/actuator = internal_components[MECH_ACTUATOR]
	if(!actuator || actuator.integrity <= 0)
		tally += 300
	else
		tally += 0.5 * (1 - actuator.get_efficiency())

	if(overload)
		tally = min(100, round(tally/2))

	tally /= 100

	return step_in + max(1, round(tally, 0.1))

/obj/mecha/proc/dyndomove(direction)
	var/obj/item/mecha_parts/component/electrical/EC = internal_components[MECH_ELECTRIC]
	var/weight_excess = (get_step_delay() * 100)
	stopMechWalking()
	if(!can_move)
		return 0
	if(src.pr_inertial_movement.active())
		return 0
	if(!has_charge(step_energy_drain))
		return 0
	if(lock_controls) //No moving while using the Gravpult!
		return 0
	if(flipped)
		return 0
	var/move_result = 0
	startMechWalking()
	var/stepped = TRUE
	if(hasInternalDamage(MECHA_INT_CONTROL_LOST))
		move_result = mechsteprand()
		if(prob(35))
			TryFlip(TRUE, FALSE, TRUE)
	else if(src.dir!=direction && !lock_dir)
		move_result = mechturn(direction)
		stepped = FALSE
	else
		move_result	= mechstep(direction)
	if(move_result)
		for(var/obj/item/mecha_parts/mecha_equipment/ME in equipment)
			if(stepped)
				ME.on_mech_step()
			else
				ME.on_mech_turn()
		can_move = 0
		if(EC && EC.integrity > 0)
			use_power(step_energy_drain * (EC.charge_cost_mod * max(get_step_delay(), 1)))
		else
			use_power(step_energy_drain * 10)
		if(istype(src.loc, /turf/space))
			if(!src.check_for_support())
				src.pr_inertial_movement.start(list(src,direction))
				src.log_message("Movement control lost. Inertial movement started.")
		if(weight_excess * 1.5 > weight_max && prob(15)) // 1.5x forgiveness
			TryFlip(TRUE, FALSE, TRUE)
		sleep(get_step_delay())
		if(!src)
			return
		can_move = 1
		return 1
	return 0

/obj/mecha/proc/startMechWalking()

/obj/mecha/proc/stopMechWalking()
	icon_state = initial_icon

/obj/mecha/proc/mechturn(direction)
	dir = direction
	playsound(src,'sound/mecha/mechturn.ogg',40,1)
	return 1

/obj/mecha/proc/mechstep(direction)
	var/current_dir = dir
	set_glide_size(DELAY2GLIDESIZE(get_step_delay()))
	var/result = step(src,direction)
	if(lock_dir)
		dir = current_dir
	if(result)
	 playsound(src, get_sfx("mechstep"),40,1)
	return result


/obj/mecha/proc/mechsteprand()
	set_glide_size(DELAY2GLIDESIZE(get_step_delay()))
	var/result = step_rand(src)
	if(result)
	 playsound(src, get_sfx("mechstep"),40,1)
	return result

/obj/mecha/to_bump(atom/obstacle)
	.=..()
	if(ismovable(obstacle))
		var/atom/movable/A = obstacle
		if(!A.anchored)
			step(obstacle, src.dir)

/obj/mecha/throw_impact(atom/obstacle)
	var/breakthrough = 0
	if(istype(obstacle, /obj/structure/window/))
		var/obj/structure/window/W = obstacle
		W.shatter()
		breakthrough = 1

	else if(istype(obstacle, /obj/structure/grille/))
		var/obj/structure/grille/G = obstacle
		G.health = (0.25*initial(G.health))
		G.healthcheck()
		breakthrough = 1

	else if(istype(obstacle, /obj/structure/table))
		var/obj/structure/table/T = obstacle
		T.destroy()
		breakthrough = 1

	else if(istype(obstacle, /obj/structure/rack))
		new /obj/item/weapon/rack_parts(obstacle.loc)
		qdel(obstacle)
		breakthrough = 1

	else if(istype(obstacle, /obj/structure/reagent_dispensers))
		var/obj/structure/reagent_dispensers/R = obstacle
		R.explode(src.occupant)

	else if(istype(obstacle, /mob/living))
		var/mob/living/L = obstacle
		if (L.flags & INVULNERABLE)
			stopMechWalking()
			src.throwing = 0
			src.crashing = null
		else if (!(L.status_flags & CANKNOCKDOWN) || (M_HULK in L.mutations) || istype(L,/mob/living/silicon))
			//can't be knocked down? you'll still take the damage.
			stopMechWalking()
			src.throwing = 0
			src.crashing = null
			L.take_overall_damage(5,0)
			if(L.locked_to)
				L.locked_to.unlock_atom(L)
		else
			var/hit_sound = list('sound/weapons/genhit1.ogg','sound/weapons/genhit2.ogg','sound/weapons/genhit3.ogg')
			L.take_overall_damage(5,0)
			if(L.locked_to)
				L.locked_to.unlock_atom(L)
			L.Stun(5)
			L.Knockdown(5)
			L.apply_effect(5, STUTTER)
			playsound(src, pick(hit_sound), 50, 0, 0)
			breakthrough = 1
	else
		stopMechWalking()
		src.throwing = 0//so mechas don't get stuck when landing after being sent by a Mass Driver
		src.crashing = null

	if(breakthrough)
		if(crashing && !istype(crashing,/turf/space))
			spawn(1)
				src.throw_at(crashing, 50, src.throw_speed)
		else
			spawn(1)
				crashing = get_distant_turf(get_turf(src), dir, 3)//don't use get_dir(src, obstacle) or the mech will stop if he bumps into a one-direction window on his tile.
				src.throw_at(crashing, 50, src.throw_speed)
