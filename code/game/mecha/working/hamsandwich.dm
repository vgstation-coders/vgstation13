/obj/mecha/working/hamsandwich
	desc = "Combining man and machine for a better, stronger engineer."
	name = "Hamsandwich"
	icon_state = "hamsandwich"
	initial_icon = "hamsandwich"
	step_in = 1
	step_energy_drain = 2
	max_temperature = 100000
	health = 100
	wreckage = /obj/effect/decal/mecha_wreckage/ripley
	var/image/thruster_overlay

/obj/mecha/working/hamsandwich/New()
	..()
	thruster_overlay = image('icons/mecha/mecha.dmi', src, "[initial(icon_state)]-thruster_overlay")

/obj/mecha/working/hamsandwich/check_for_support()
	return 1

/obj/mecha/working/hamsandwich/mechturn(direction)
	dir = direction
	playsound(src,'sound/mecha/mechmove01.ogg',40,1)
	return 1

/obj/mecha/working/hamsandwich/mechstep(direction)
	if(istype(get_turf(src), /turf/space))
		overlays += thruster_overlay
	else
		overlays -= thruster_overlay
	var/result = step(src,direction)
	return result

/obj/mecha/working/hamsandwich/mechsteprand()
	var/result = step_rand(src)
	return result

/obj/mecha/working/hamsandwich/Process_Spacemove(var/check_drift = 0)
	return TRUE

/obj/mecha/working/hamsandwich/startMechWalking()
	icon_state = initial_icon + "-move"