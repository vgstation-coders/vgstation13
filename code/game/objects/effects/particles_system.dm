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
	new_holder.main_holder = src
	new_holder.particles = new particle_type
	new_holder.special_setup()
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
/atom/proc/adjust_particles(var/adjustment, var/new_value, var/particle_string)
	if (!particle_string) //If we don't specify which particle we want to shift, just shift all of them
		for (var/string in particle_systems)
			adjust_particles(adjustment ,new_value, string)
		return
	if (!(particle_string in particle_systems))
		return

	var/obj/abstract/particles_holder/holder = particle_systems[particle_string]

	switch(adjustment)
		if (PVAR_SPAWNING)
			holder.particles.spawning = new_value
		if (PVAR_POSITION)
			holder.particles.position = new_value
		if (PVAR_VELOCITY)
			holder.particles.velocity = new_value
		if (PVAR_ICON_STATE)
			holder.particles.icon_state = new_value
		if (PVAR_COLOR)
			holder.particles.color = new_value
		if (PVAR_SCALE)
			holder.particles.scale = new_value
		if (PVAR_PLANE)
			holder.plane = new_value
		if (PVAR_LAYER)
			holder.layer = new_value
		if (PVAR_PIXEL_X)
			holder.pixel_x = new_value
		if (PVAR_PIXEL_Y)
			holder.pixel_y = new_value
		//add more as needed

//HOLDER
/obj/abstract/particles_holder
	mouse_opacity = 0
	icon = 'icons/effects/32x32.dmi'
	icon_state = "blank"
	var/atom/main_holder

/obj/abstract/particles_holder/proc/special_setup(var/particle_string)
	if (particles.plane)
		plane = particles.plane
	if (particles.appearance_flags)
		appearance_flags = particles.appearance_flags
	if (particles.blend_mode)
		blend_mode = particles.blend_mode
	layer = particles.layer
	pixel_x = particles.pixel_x
	pixel_y = particles.pixel_y

//////////////////////////////////////PARTICLES///////////////////////////////////

var/list/particle_string_to_type = list(
	PS_STEAM = /particles/steam,
	PS_TEAR_REALITY = /particles/tear_reality,
	PS_CANDLE = /particles/candle,
	PS_CANDLE2 = /particles/candle_alt,
	PS_CULT_GAUGE = /particles/cult_gauge,
	PS_CULT_SMOKE = /particles/cult_smoke,
	PS_CULT_SMOKE2 = /particles/cult_smoke/alt,
	PS_CULT_SMOKE_BOX = /particles/cult_smoke/box,
	PS_CULT_HALO = /particles/cult_halo,
	PS_SPACE_RUNES = /particles/space_runes,
	PS_NARSIEHASRISEN1 = /particles/narsie_has_risen,
	PS_NARSIEHASRISEN2 = /particles/narsie_has_risen/next,
	PS_NARSIEHASRISEN3 = /particles/narsie_has_risen/last,
	)

/particles
	var/plane = 0
	var/layer = 0
	var/pixel_x = 0
	var/pixel_y = 0
	var/appearance_flags = 0
	var/blend_mode = 0

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

	plane = NOIR_BLOOD_PLANE

//CANDLE
/particles/candle
	width = 32
	height = 64
	count = 5
	spawning = 0.02

	lifespan = 1.5 SECONDS
	fade = 0.7 SECONDS
	icon = 'icons/effects/effects_particles.dmi'
	icon_state = "candle"
	position = generator("box", list(-1,12), list(1,12))
	velocity = list(0,3)
	friction = 0.3
	drift = generator("box", list(-0.2,-0.2), list(0.2,0.2))

	appearance_flags = RESET_COLOR
	blend_mode = BLEND_ADD
	plane = ABOVE_LIGHTING_PLANE

/particles/candle_alt
	width = 32
	height = 64
	count = 5
	spawning = 0.05

	lifespan = 1 SECONDS
	fade = 0.3 SECONDS
	icon = 'icons/effects/effects_particles.dmi'
	icon_state = "candle"
	position = generator("box", list(-1,12), list(1,12))
	velocity = list(0,3)
	friction = 0.3
	drift = generator("sphere", 0, 1)

	appearance_flags = RESET_COLOR
	blend_mode = BLEND_ADD
	plane = ABOVE_LIGHTING_PLANE

//CULT GAUGE
/particles/cult_gauge
	width = 600
	height = 64
	count = 20
	spawning = 1

	lifespan = 1 SECONDS
	fade = 0.5 SECONDS
	icon = 'icons/effects/effects_particles.dmi'
	icon_state = "blood_gauge"
	position = generator("box", list(-16,-1), list(-16,-14))
	velocity = list(0,0)

	plane = HUD_PLANE
	layer = MIND_UI_BUTTON+0.5

//CULT SMOKE
/particles/cult_smoke
	width = 32
	height = 64
	count = 20
	spawning = 0
	//spawning = 0.6
	color = "#FFFFFF99"

	lifespan = 8.5
	fadein = 3
	fade = 5
	icon = 'icons/effects/effects_particles.dmi'
	icon_state = "darkness"
	position = list(0,-12)
	scale = generator("num", 0.40,0.45)
	velocity = generator("box", list(-1,4), list(-2,4))
	drift = generator("box", list(0.1,0), list(0.2,0))
	rotation = generator("num", 0,360)

	plane = FLOAT_PLANE

/particles/cult_smoke/alt
	velocity = generator("box", list(1,4), list(2,4))
	drift = generator("box", list(-0.1,0), list(-0.2,0))

/particles/cult_smoke/box
	spawning = 0.8
	position = generator("box", list(-12,-12), list(12,12))
	velocity = list(0,4)
	drift = generator("box", list(-0.2,0), list(0.2,0))

	plane = FLOAT_PLANE

//CULT HALO
/particles/cult_halo
	width = 32
	height = 64
	count = 20
	spawning = 0.1

	lifespan = 20
	fadein = 5
	fade = 10
	icon = 'icons/effects/effects_particles.dmi'
	icon_state = "cult_halo4"
	position = list(0,8)
	drift = generator("box", list(-0.02,-0.02), list(0.02,0.02))

	plane = ABOVE_LIGHTING_PLANE

//SPACE RUNES
/particles/space_runes
	width = 64
	height = 64
	count = 2
	spawning = 0.01

	lifespan = 20
	fadein = 5
	fade = 10
	icon = 'icons/effects/effects_particles.dmi'
	icon_state = list("rune-1","rune-2","rune-4","rune-8","rune-16","rune-32","rune-64","rune-128","rune-256","rune-512",)
	drift = generator("box", list(-0.02,-0.02), list(0.02,0.02))


//NAR-SIE HAS RISEN
/particles/narsie_has_risen
	width = 300
	height = 64
	count = 20
	spawning = 0.2

	lifespan = 20
	fadein = 5
	fade = 10
	icon = 'icons/ui/bloodcult/223x37.dmi'
	icon_state = "narsie"
	drift = generator("box", list(-0.05,-0.05), list(0.05,0.05))

	plane = ABOVE_HUD_PLANE

/particles/narsie_has_risen/next
	icon_state = "has"

	plane = ABOVE_HUD_PLANE

/particles/narsie_has_risen/last
	icon_state = "risen"

	plane = ABOVE_HUD_PLANE
