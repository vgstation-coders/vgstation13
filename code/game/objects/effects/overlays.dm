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

/obj/effect/overlay/beam/New(var/turf/loc, var/lifetime = 10, var/fade = 0, var/src_icon = 'icons/effects/beam.dmi', var/icon_state = "b_beam", var/base_damage = 30, var/col_override = null, var/col_shift = null)
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
	plane = ABOVE_TURF_PLANE
	var/wet = TURF_WET_LUBE
	var/lifespan
	mouse_opacity = 0

/obj/effect/overlay/puddle/ice
	name = "Ice"
	icon_state = "icy_floor"
	wet = TURF_WET_ICE
	var/current_temp
	var/ice_thickness = 5
	// Alternative option to use /obj/effect/overlay/puddle's lifespan variable to dictate when the ice puddle is destroyed instead of
	// the HP system.
	var/time_based_melt = FALSE


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

/obj/effect/overlay/puddle/ice/New(var/turf/T, var/zone/zone)
	..()
	current_temp = T.temperature
	if( zone != null )
		// Refactor suggestion: zone SHOULD be managing ice_puddle_list, puddle should not have to worry about this at all.
		zone.ice_puddle_list += src

/obj/effect/overlay/puddle/ice/Destroy()
	..()
	var/turf/T = get_turf(src)
	if(istype(T, /turf/simulated))
		var/turf/simulated/S = T
		if(S.zone)
			S.zone.ice_puddle_list -= src

/obj/effect/overlay/puddle/ice/process()
	if(time_based_melt && world.time >= lifespan){
		qdel(src)
	}
	else{
		var/temp_delta = current_temp - T0C
		// Increase or decrease HP based on temperature. Scales logarithmically, so ever-hotter temperatures cause it to melt faster.
		if(temp_delta != 0)
			ice_thickness = min( 100, ice_thickness + ((temp_delta < 0) ? 1 : -1 * log(8, abs(temp_delta)) / rand(1,3)))
		if(ice_thickness < 0)
			new /obj/effect/overlay/puddle(get_turf(src))
			qdel(src)
	}


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


