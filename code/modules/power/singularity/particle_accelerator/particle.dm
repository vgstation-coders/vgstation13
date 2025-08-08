//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

#define PARTICLE_ENERGY 20
#define WEAK_PARTICLE_ENERGY (PARTICLE_ENERGY / 2)
#define STRONG_PARTICLE_ENERGY (PARTICLE_ENERGY * 1.5)
#define POWERFUL_PARTICLE_ENERGY (PARTICLE_ENERGY * 5)

#define PARTICLE_RANGE 16
#define WEAK_PARTICLE_RANGE 12
#define STRONG_PARTICLE_RANGE 20
#define POWERFUL_PARTICLE_RANGE 25

/obj/effect/accelerated_particle
	name = "Accelerated Particles"
	desc = "Small things moving very fast."
	icon = 'icons/obj/machines/particle_accelerator2.dmi'
	icon_state = "particle1"//Need a new icon for this
	anchored = 1
	density = 1
	var/movement_range = PARTICLE_RANGE
	var/energy = PARTICLE_ENERGY		//energy in eV
	var/mega_energy = 0	//energy in MeV
	var/frequency = 1
	var/ionizing = 0
	var/particle_type
	var/additional_particles = 0
	var/turf/target
	var/turf/source
	var/movetotarget = 1
	var/moody_icon = 'icons/lighting/moody_lights.dmi'

/obj/effect/accelerated_particle/New()
	..()
	update_moody_light(moody_icon, "overlay_particle")

/obj/effect/accelerated_particle/wide
	icon = 'icons/obj/machines/96x96particles.dmi'
	moody_icon = 'icons/lighting/moody_lights_96x96.dmi'
	pixel_x = -WORLD_ICON_SIZE
	pixel_y = -WORLD_ICON_SIZE
	luminosity = 3

/obj/effect/accelerated_particle/wide/weak
	movement_range = WEAK_PARTICLE_RANGE
	energy = WEAK_PARTICLE_ENERGY
	icon_state="particle0"


/obj/effect/accelerated_particle/wide/strong
	movement_range = STRONG_PARTICLE_RANGE
	energy = STRONG_PARTICLE_ENERGY
	icon_state="particle2"

/obj/effect/accelerated_particle/wide/powerful
	movement_range = POWERFUL_PARTICLE_RANGE
	energy = POWERFUL_PARTICLE_ENERGY
	icon_state="particle3"


/obj/effect/accelerated_particle/New(loc, dir = 2, move = 0)
	. = ..()
	src.forceMove(loc)
	src.dir = dir

/obj/effect/accelerated_particle/wide/New()
	. = ..()
	if(dir in list(EAST, WEST))
		bound_height = 3 * WORLD_ICON_SIZE
		bound_y = -WORLD_ICON_SIZE
	else
		bound_width = 3 * WORLD_ICON_SIZE
		bound_x = -WORLD_ICON_SIZE

/obj/effect/accelerated_particle/proc/startMove(move = 0)
	if(movement_range > 25)
		movement_range = 25
	if(move)
		spawn(0)
			move(1)

/obj/effect/accelerated_particle/to_bump(atom/A)
	if (A)
		if(ismob(A))
			toxmob(A)
			return
		if(istype(A,/obj/machinery/the_singularitygen))
			var/obj/machinery/the_singularitygen/TSG = A
			TSG.energy += energy
			return
		if( istype(A,/obj/effect/rust_particle_catcher) )
			var/obj/effect/rust_particle_catcher/collided_catcher = A
			if(particle_type && particle_type != "neutron")
				if(collided_catcher.AddParticles(particle_type, 1 + additional_particles))
					collided_catcher.parent.AddEnergy(energy,mega_energy)
					loc = null
			return
		if( istype(A,/obj/machinery/power/rust_core) )
			var/obj/machinery/power/rust_core/collided_core = A
			if(particle_type && particle_type != "neutron")
				if(collided_core.AddParticles(particle_type, 1 + additional_particles))
					var/energy_loss_ratio = abs(collided_core.owned_field.frequency - frequency) / 1e9
					collided_core.owned_field.mega_energy += mega_energy - mega_energy * energy_loss_ratio
					collided_core.owned_field.energy += energy - energy * energy_loss_ratio
					loc = null
			return
		if (istype(A,/obj/machinery/power/supermatter/))
			var/obj/machinery/power/supermatter/collided_SM = A
			collided_SM.power += energy * 4 //multiplier to make comparable to emitters
			return
	return


/obj/effect/accelerated_particle/Bumped(atom/A)
	if(ismob(A))
		to_bump(A)
	return

/obj/effect/accelerated_particle/ex_act(severity)
	qdel(src)
	return

/obj/effect/accelerated_particle/proc/toxmob(var/mob/living/M)
	var/radiation = (energy)
/*			if(istype(M,/mob/living/carbon/human))
		if(M:wear_suit) //TODO: check for radiation protection
			radiation = round(radiation/2,1)
	if(istype(M,/mob/living/carbon/monkey))
		if(M:wear_suit) //TODO: check for radiation protection
			radiation = round(radiation/2,1)*/
	M.apply_radiation((radiation*3),RAD_EXTERNAL)
	M.updatehealth()
	return


//step_x and step_y are passed to forceMove() below because of weird BYOND behavior related to objects with large hitboxes.
//If more bugs due to this behavior crop up, perhaps forceMove() should be changed so that not changing the step_x/y vars is the default.
//A better solution here would be to just... make this not work this way at all
/obj/effect/accelerated_particle/proc/move(var/lag)
	if(!loc)
		return 0
	if(target)
		if(movetotarget)
			if(!step_towards(src,target))
				src.forceMove(get_step(src, get_dir(src,target)), step_x, step_y)
			if(get_dist(src,target) < 1)
				movetotarget = 0
		else
			if(!step(src, get_step_away(src,source)))
				src.forceMove(get_step(src, get_step_away(src,source)), step_x, step_y)
	else
		if(!step(src,dir))
			src.forceMove(get_step(src,dir), step_x, step_y)
	movement_range--
	if(movement_range <= 0)
		qdel(src)
		loc = null
		return 0
	else
		sleep(lag)
		move(lag)

/obj/effect/accelerated_particle/singularity_act()
	. = energy
	qdel(src)

#undef PARTICLE_ENERGY
#undef WEAK_PARTICLE_ENERGY
#undef STRONG_PARTICLE_ENERGY
#undef POWERFUL_PARTICLE_ENERGY
#undef PARTICLE_RANGE
#undef WEAK_PARTICLE_RANGE
#undef STRONG_PARTICLE_RANGE
#undef POWERFUL_PARTICLE_RANGE
