/obj/mecha/combat/roswell
	desc = "An exosuit from another world."
	name = "Roswell"
	icon_state = "roswell"
	initial_icon = "roswell"
	step_in = 1
	dir_in = 1 //Facing North.
	health = 300
	deflect_chance = 15
	damage_absorption = list("brute"=0.75,"fire"=1,"bullet"=0.8,"laser"=0.7,"energy"=0.85,"bomb"=1)
	max_temperature = 25000
	infra_luminosity = 6
	wreckage = /obj/effect/decal/mecha_wreckage/roswell
	internal_damage_threshold = 35
	max_equip = 3
	plane = ABOVE_HUMAN_PLANE
	layer = VEHICLE_LAYER

/obj/mecha/combat/roswell/mechturn(direction)
	dir = direction
	return 1

/obj/mecha/combat/roswell/mechstep(direction)
	return step(src,direction)

/obj/mecha/combat/roswell/mechsteprand()
	return step_rand(src)
    
/obj/mecha/combat/roswell/Process_Spacemove(var/check_drift = 0) //invaders from outer spaaace
	if(has_charge(step_energy_drain))
		return TRUE //doesn't drift in space if it has power
	return FALSE

/obj/mecha/combat/roswell/can_apply_inertia()
	if(has_charge(step_energy_drain))
		return FALSE //doesn't drift in space if it has power
	return TRUE

//duplicate of parent proc, but without space drifting
/obj/mecha/combat/roswell/dyndomove(direction)
	stopMechWalking()
	if(!can_move)
		return 0
	if(src.pr_inertial_movement.active())
		return 0
	if(!has_charge(step_energy_drain))
		return 0
	var/move_result = 0
	startMechWalking()
	if(hasInternalDamage(MECHA_INT_CONTROL_LOST))
		move_result = mechsteprand()
	else if(src.dir!=direction)
		move_result = mechturn(direction)
	else
		move_result	= mechstep(direction)
	if(move_result)
		can_move = 0
		use_power(step_energy_drain)
		/*if(istype(src.loc, /turf/space))
			if(!src.check_for_support())
				src.pr_inertial_movement.start(list(src,direction))
				src.log_message("Movement control lost. Inertial movement started.")*/
		spawn(step_in)
			can_move = 1
		return 1
	return 0

/obj/mecha/combat/roswell/preloaded/New()
	..()
	new /obj/item/mecha_parts/mecha_equipment/tool/ayy/abductor(src)
	new /obj/item/mecha_parts/mecha_equipment/tool/ayy/prober(src)

/obj/effect/decal/mecha_wreckage/roswell
    name = "downed weather balloon"
    desc = "Seems legit"
    icon_state = "roswell-broken"