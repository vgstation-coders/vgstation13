
/obj/effect/overlay
	name = "overlay"
	unacidable = 1
	w_type=NOT_RECYCLABLE
	var/i_attached//Added for possible image attachments to objects. For hallucinations and the like.

/obj/effect/overlay/cultify()
	return

/obj/effect/overlay/singuloCanEat()
	return 0

/obj/effect/overlay/singularity_act()
	return

/obj/effect/overlay/singularity_pull()
	return

/obj/effect/overlay/beam//Not actually a projectile, just an effect.
	name="beam"
	icon='icons/effects/beam.dmi'
	icon_state="b_beam"
	layer = 13
	mouse_opacity = 0
	var/tmp/atom/BeamSource

/obj/effect/overlay/beam/New(turf/loc, var/lifetime = 10)
	..()
	spawn(lifetime/4)	alpha = 192
	spawn(lifetime/2)	alpha = 128
	spawn(3*lifetime/4)	alpha = 64
	spawn(lifetime)	qdel(src)


/obj/effect/overlay/palmtree_r
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm1"
	density = 1
	layer = 5
	anchored = 1

/obj/effect/overlay/palmtree_l
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm2"
	density = 1
	layer = 5
	anchored = 1

/obj/effect/overlay/coconut
	name = "Coconuts"
	icon = 'icons/misc/beach.dmi'
	icon_state = "coconuts"


/obj/effect/overlay/bluespacify
	name = "Bluespace"
	icon = 'icons/turf/space.dmi'
	icon_state = "bluespacify"
	layer = LIGHTING_LAYER