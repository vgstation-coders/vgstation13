//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/effect/accelerated_particle
	name = "Accelerated Particles"
	desc = "Small things moving very fast."
	icon = 'icons/obj/machines/particle_accelerator2.dmi'
	icon_state = "particle1"//Need a new icon for this
	anchored = 1
	density = 1
	var/movement_range = 10
	var/energy = 20		//energy in eV
	var/mega_energy = 0	//energy in MeV
	var/frequency = 1
	var/ionizing = 0
	var/particle_type
	var/additional_particles = 0
	var/turf/target
	var/turf/source
	var/movetotarget = 1

/obj/effect/accelerated_particle/resetVariables()
	..("movement_range", "target", "ionizing", "particle_type", "source", "movetotarget", args)
	movement_range = 10
	target = null
	ionizing = 0
	particle_type = null
	source = null
	movetotarget = 1

/obj/effect/accelerated_particle/weak
	movement_range = 8
	energy = 10
	icon_state="particle0"
	resetVariables()
		..("energy", "movement_range")
		movement_range = 8
		energy = 10

/obj/effect/accelerated_particle/strong
	movement_range = 15
	energy = 30
	icon_state="particle2"
	resetVariables()
		..("energy", "movement_range")
		energy = 30
		movement_range = 15

/obj/effect/accelerated_particle/powerful
	movement_range = 20
	energy = 100
	icon_state="particle3"
	resetVariables()
		..("energy", "movement_range")
		energy = 100
		movement_range = 20

/obj/effect/accelerated_particle/New(loc, dir = 2, move = 0)
	. = ..()
	src.loc = loc
	src.dir = dir

/obj/effect/accelerated_particle/proc/startMove(move = 0)
	if(movement_range > 20)
		movement_range = 20
	if(move)
		spawn(0)
			move(1)

/obj/effect/accelerated_particle/Bump(atom/A)
	if (A)
		if(ismob(A))
			toxmob(A)
		if((istype(A,/obj/machinery/the_singularitygen))||(istype(A,/obj/machinery/singularity/)))
			A:energy += energy
		else if( istype(A,/obj/effect/rust_particle_catcher) )
			var/obj/effect/rust_particle_catcher/collided_catcher = A
			if(particle_type && particle_type != "neutron")
				if(collided_catcher.AddParticles(particle_type, 1 + additional_particles))
					collided_catcher.parent.AddEnergy(energy,mega_energy)
					loc = null
		else if( istype(A,/obj/machinery/power/rust_core) )
			var/obj/machinery/power/rust_core/collided_core = A
			if(particle_type && particle_type != "neutron")
				if(collided_core.AddParticles(particle_type, 1 + additional_particles))
					var/energy_loss_ratio = abs(collided_core.owned_field.frequency - frequency) / 1e9
					collided_core.owned_field.mega_energy += mega_energy - mega_energy * energy_loss_ratio
					collided_core.owned_field.energy += energy - energy * energy_loss_ratio
					loc = null
	return


/obj/effect/accelerated_particle/Bumped(atom/A)
	if(ismob(A))
		Bump(A)
	return

/obj/effect/accelerated_particle/ex_act(severity)
	returnToPool(src)
	return

/obj/effect/accelerated_particle/proc/toxmob(var/mob/living/M)
	var/radiation = (energy)
/*			if(istype(M,/mob/living/carbon/human))
		if(M:wear_suit) //TODO: check for radiation protection
			radiation = round(radiation/2,1)
	if(istype(M,/mob/living/carbon/monkey))
		if(M:wear_suit) //TODO: check for radiation protection
			radiation = round(radiation/2,1)*/
	M.apply_effect((radiation*3),IRRADIATE,0)
	M.updatehealth()
//	to_chat(M, "<span class='warning'>You feel odd.</span>")
	return


/obj/effect/accelerated_particle/proc/move(var/lag)
	if(!loc) return 0
	if(target)
		if(movetotarget)
			if(!step_towards(src,target))
				src.loc = get_step(src, get_dir(src,target))
			if(get_dist(src,target) < 1)
				movetotarget = 0
		else
			if(!step(src, get_step_away(src,source)))
				src.loc = get_step(src, get_step_away(src,source))
	else
		if(!step(src,dir))
			src.loc = get_step(src,dir)
	movement_range--
	if(movement_range <= 0)
		returnToPool(src)
		loc = null
		return 0
	else
		sleep(lag)
		move(lag)
