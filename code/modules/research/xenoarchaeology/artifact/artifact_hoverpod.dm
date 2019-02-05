
/obj/mecha/working/hoverpod
	name = "hover pod"
	icon_state = "engineering_pod"
	initial_icon = "engineering_pod"
	desc = "Stubby and round, it has a human sized access hatch on the top."
	step_energy_drain = 2
	step_in = 1
	wreckage = /obj/effect/decal/mecha_wreckage/hoverpod

/obj/mecha/working/hoverpod/check_for_support()
	return 1

/obj/mecha/working/hoverpod/startMechWalking()
	..()
	var/turf/mech_turf = get_turf(src)
	if(!istype(mech_turf, /turf))
		return
	var/datum/gas_mixture/environment = mech_turf.return_air()
	var/pressure = environment.return_pressure()
	if(pressure > 50)
		step_in = 4
	else
		step_in = 1

//these three procs overriden to play different sounds
/obj/mecha/working/hoverpod/mechturn(direction)
	dir = direction
	//playsound(src,'sound/machines/hiss.ogg',40,1)
	return 1

/obj/mecha/working/hoverpod/mechstep(direction)
	var/result = step(src,direction)
	if(result)
		playsound(src,'sound/machines/hiss.ogg',40,1)
	return result


/obj/mecha/working/hoverpod/mechsteprand()
	var/result = step_rand(src)
	if(result)
		playsound(src,'sound/machines/hiss.ogg',40,1)
	return result

/obj/mecha/working/hoverpod/can_apply_inertia()
	if(has_charge(step_energy_drain))
		return 0 //doesn't drift in space if it has power
	return 1

/obj/effect/decal/mecha_wreckage/hoverpod
	name = "Hover pod wreckage"
	icon_state = "engineering_pod-broken"

	/*New()
		..()
		var/list/parts = list(

		for(var/i=0;i<2;i++)
			if(!isemptylist(parts) && prob(40))
				var/part = pick(parts)
				welder_salvage += part
				parts -= part
		return*/
