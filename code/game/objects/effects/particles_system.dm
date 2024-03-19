//Because BYOND only lets atoms have 1 type of particles at a given time, we use holders to let atoms stack particle effects

/atom
	var/list/particle_systems = list()

//-----------------------------------------------
/atom/proc/add_to_vis(var/stuff)
	return

/turf/add_to_vis(var/stuff)
	vis_contents += stuff

/atom/movable/add_to_vis(var/stuff)
	vis_contents += stuff

//-----------------------------------------------
/atom/proc/remove_from_vis(var/stuff)
	return

/turf/remove_from_vis(var/stuff)
	vis_contents -= stuff

/atom/movable/remove_from_vis(var/stuff)
	vis_contents -= stuff

//-----------------------------------------------
/atom/proc/add_particles(var/particle_string)
	if (!particle_string)
		return
	if (particle_string in particle_systems)
		return

	var/particle_type = particle_string_to_type[particle_string]
	var/obj/abstract/particles_holder/new_holder = new
	new_holder.special_setup(particle_string)
	new_holder.main_holder = src
	new_holder.particles = new particle_type
	particle_systems[particle_string] = new_holder
	add_to_vis(particle_systems[particle_string])

//-----------------------------------------------
/atom/proc/remove_particles(var/particle_string)
	if (!particle_string) //If we don't specify which particle we want to remove, just remove all of them
		for (var/string in particle_systems)
			remove_particles(string)
		return
	if (!(particle_string in particle_systems))
		return

	remove_from_vis(particle_systems[particle_string])
	var/obj/abstract/particles_holder/holder = particle_systems[particle_string]
	if (holder.main_holder == src)
		qdel(holder)
	particle_systems -= particle_string

//-----------------------------------------------
/atom/proc/transfer_particles(var/atom/target, var/particle_string)
	if (!target)
		return
	if (!particle_string) //If we don't specify which particle we want to move, just move all of them
		for (var/string in particle_systems)
			transfer_particles(target, string)
		return
	if (!(particle_string in particle_systems))
		return

	var/obj/abstract/particles_holder/holder = particle_systems[particle_string]
	if (particle_string in target.particle_systems)
		target.remove_particles(particle_string)
	target.particle_systems[particle_string] = holder
	target.add_to_vis(holder)
	holder.main_holder = target
	particle_systems -= particle_string
	remove_from_vis(holder)

//-----------------------------------------------
/atom/proc/link_particles(var/atom/target, var/particle_string) //Similar to transfer_particles but doesn't change the main holder, instead just adding the vis_contents
	if (!target)
		return
	if (!particle_string) //If we don't specify which particle we want to link, just link all of them
		for (var/string in particle_systems)
			link_particles(target, string)
		return
	if (!(particle_string in particle_systems))
		return

	var/obj/abstract/particles_holder/holder = particle_systems[particle_string]
	if (particle_string in target.particle_systems)
		if (target.particle_systems[particle_string] == holder)//particle is already linked
			return
		target.remove_particles(particle_string)
	target.particle_systems[particle_string] = holder
	target.add_to_vis(holder)

//-----------------------------------------------
/atom/proc/shift_particles(var/shifting, var/particle_string)
	if (!particle_string) //If we don't specify which particle we want to shift, just shift all of them
		for (var/string in particle_systems)
			shift_particles(shifting, string)
		return
	if (!(particle_string in particle_systems))
		return

	var/obj/abstract/particles_holder/holder = particle_systems[particle_string]
	holder.particles.position = shifting


//HOLDER
/obj/abstract/particles_holder
	mouse_opacity = 0
	icon = 'icons/effects/32x32.dmi'
	icon_state = "blank"
	var/atom/main_holder

/obj/abstract/particles_holder/proc/special_setup(var/particle_string)
	switch(particle_string)
		if ("Candle")
			appearance_flags = RESET_COLOR
			blend_mode = BLEND_ADD
			plane = ABOVE_LIGHTING_PLANE

//////////////////////////////////////PARTICLES///////////////////////////////////

var/list/particle_string_to_type = list(
	"Steam" = /particles/steam,
	"Tear Reality" = /particles/tear_reality,
	"Candle" = /particles/candle,
	)

//STEAM
/particles/steam
	width = 64
	height = 64
	count = 20
	spawning = 0

	lifespan = 1 SECONDS
	fade = 1 SECONDS
	icon = 'icons/effects/effects_particles.dmi'
	icon_state = "steam"
	color = "#FFFFFF99"
	position = 0
	velocity = 1
	scale = list(0.6, 0.6)
	grow = list(0.05, 0.05)
	rotation = generator("num", 0,360)


//TEAR REALITY DARKNESS
/particles/tear_reality
	width = 64
	height = 64
	count = 30
	spawning = 0.1

	lifespan = 1 SECONDS
	fade = 1 SECONDS
	icon = 'icons/effects/effects_particles.dmi'
	icon_state = "darkness"
	color = "#FFFFFF99"
	position = 0
	velocity = 0
	scale = list(1, 1)
	grow = list(0.05, 0.05)
	rotation = generator("num", 0,360)


//STEAM
/particles/candle
	width = 32
	height = 64
	count = 5
	spawning = 0.1
	//spawning = generator("num", 0.03, 0.2)

	lifespan = 1.3 SECONDS
	fade = 1 SECONDS
	icon = 'icons/effects/effects_particles.dmi'
	icon_state = "candle"
	position = list(0, 12)
	velocity = list(0,3)
	friction = 0.3
	drift = generator("sphere", 0, 2)
