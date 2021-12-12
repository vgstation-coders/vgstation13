/obj/effect/overlay
	name = "overlay"
	w_type=NOT_RECYCLABLE
	plane = ABOVE_HUMAN_PLANE
	mouse_opacity = 1
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
	anchored = 1
	var/tmp/atom/BeamSource

	// light
	lighting_flags = IS_LIGHT_SOURCE
	light_range = 1
	light_power = 3 // very bright
	light_color = LIGHT_COLOR_RED

/obj/effect/overlay/beam/New(var/turf/loc, var/lifetime = 10, var/fade = 0, var/src_icon = 'icons/effects/beam.dmi', var/icon_state = "b_beam", var/base_damage = 30, var/col_override = null, var/col_shift = null, var/emit_light = TRUE, var/_light_power, var/_light_color)
	if (!emit_light)
		lighting_flags = 0
	if (_light_power)
		light_power = _light_power
	if (_light_color)
		light_color = _light_color

	light_power = round(light_power*max(1,loc.last_beam_damage)/max(1,base_damage))

	..()
	alpha = round(255*(max(1,loc.last_beam_damage)/max(1,base_damage)))
	icon = src_icon
	src.icon_state = icon_state
	if (col_override)
		color = col_override
	spawn if(fade)
		if (col_shift)
			animate(src, alpha=0, color=col_shift, time=lifetime)
		else
			animate(src, alpha=0, time=lifetime)
	spawn(lifetime)
		qdel(src)

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

/obj/effect/overlay/puddle/Destroy()
	processing_objects.Remove(src)
	..()

/obj/effect/overlay/puddle/process()
	if(world.time >= lifespan)
		qdel(src)

/obj/effect/overlay/puddle/Crossed(atom/movable/AM)

	if (!isliving(AM))
		return ..()
	var/mob/living/L = AM
	if (!L.ApplySlip(src))
		return ..()

/obj/effect/overlay/holywaterpuddle
	name = "Puddle"
	icon = 'icons/effects/water.dmi'
	icon_state = "holy_floor"
	anchored = 1
	mouse_opacity = 0
	var/lifespan

/obj/effect/overlay/holywaterpuddle/New(var/turf/T)
	. = ..()
	lifespan = world.time + HOLYWATER_DURATION
	processing_objects.Add(src)

/obj/effect/overlay/holywaterpuddle/process()
	if(world.time >= lifespan)
		qdel(src)

/obj/effect/overlay/wallrot
	name = "Wallrot"
	desc = "Ick..."
	icon = 'icons/effects/wallrot.dmi'
	anchored = TRUE
	density = TRUE
	mouse_opacity = 0

/obj/effect/overlay/wallrot/New()
	..()
	pixel_x += rand(-10, 10) * PIXEL_MULTIPLIER
	pixel_y += rand(-10, 10) * PIXEL_MULTIPLIER


