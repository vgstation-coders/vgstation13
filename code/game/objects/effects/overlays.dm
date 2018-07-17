
/obj/effect/overlay
	name = "overlay"
	w_type=NOT_RECYCLABLE
	plane = ABOVE_HUMAN_PLANE
	var/i_attached//Added for possible image attachments to objects. For hallucinations and the like.

/obj/effect/overlay/cultify()
	return

/obj/effect/overlay/singularity_act()
	return

/obj/effect/overlay/singularity_pull()
	return

/obj/effect/overlay/blob_act()
	return

/obj/effect/overlay/beam//Not actually a projectile, just an effect.
	name="beam"
	icon='icons/effects/beam.dmi'
	icon_state="b_beam"
	mouse_opacity = 0
	var/tmp/atom/BeamSource

/obj/effect/overlay/beam/New(turf/loc, var/lifetime = 10, var/fade = 0, var/src_icon = 'icons/effects/beam.dmi')
	..()
	icon = src_icon
	spawn if(fade)
		animate(src, alpha=0, time=lifetime)
	spawn(lifetime)
		returnToPool(src)

/obj/effect/overlay/beam/persist/New()
	return

/obj/effect/overlay/palmtree_r
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm1"
	density = 1
	anchored = 1

/obj/effect/overlay/palmtree_l
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm2"
	density = 1
	anchored = 1

/obj/effect/overlay/coconut
	plane = OBJ_PLANE
	name = "Coconuts"
	icon = 'icons/misc/beach.dmi'
	icon_state = "coconuts"


/obj/effect/overlay/bluespacify
	name = "Bluespace"
	icon = 'icons/turf/space.dmi'
	icon_state = "bluespacify"
	layer = LIGHTING_LAYER

/obj/effect/overlay/puddle
	name = "Puddle"
	icon = 'icons/effects/water.dmi'
	icon_state = "wet_floor"
	anchored = 1
	var/wet = TURF_WET_LUBE
	var/lifespan
	mouse_opacity = 0

/obj/effect/overlay/puddle/New(var/turf/T, var/new_wet, var/new_lifespan)
	..()
	wet = new_wet
	lifespan = world.time + new_lifespan
	processing_objects.Add(src)

/obj/effect/overlay/puddle/process()
	if(world.time >= lifespan)
		qdel(src)

/obj/effect/overlay/puddle/Crossed(atom/movable/AM)
	//Check what can slip
	if(isliving(AM))
		var/mob/living/M = AM
		if(!M.on_foot()) //Checks lying, flying and locked.to
			return ..()


	if(isslime(AM)) //Slimes just don't slip, end of story. Hard to slip when you're a living puddle.
		return ..()

	if(iscarbon(AM))
		var/mob/living/carbon/M = AM
		switch(src.wet)
			if(1) //Water
				if (M.Slip(5, 3))
					step(M, M.dir)
					M.visible_message("<span class='warning'>[M] slips on the wet floor!</span>", \
					"<span class='warning'>You slip on the wet floor!</span>")

			if(2) //Lube
				step(M, M.dir)
				spawn(1)
					if(!M.locked_to)
						step(M, M.dir)
				spawn(2)
					if(!M.locked_to)
						step(M, M.dir)
				spawn(3)
					if(!M.locked_to)
						step(M, M.dir)
				spawn(4)
					if(!M.locked_to)
						step(M, M.dir)
				M.take_organ_damage(2) // Was 5 -- TLE
				M.visible_message("<span class='warning'>[M] slips on the floor!</span>", \
				"<span class='warning'>You slip on the floor!</span>")
				playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
				M.Knockdown(10)

			if(3) // Ice
				if(prob(30) && M.Slip(4, 3))
					step(M, M.dir)
					M.visible_message("<span class='warning'>[M] slips on the icy floor!</span>", \
					"<span class='warning'>You slip on the icy floor!</span>")

	if(isrobot(AM) && wet == 1) //Only exactly water makes borgs glitch
		var/mob/living/silicon/robot/R = AM
		if(R.Slip(5,3))
			//Don't step forward as a robot, we're not slipping just glitching.
			R.visible_message("<span class='warning'>[R] short circuits on the water!</span>", \
					"<span class='warning'>You short circuit on the water!</span>")
