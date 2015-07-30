/obj/effect/decal/cleanable
	var/list/random_icon_states = list()
	var/targeted_by = null			// Used so cleanbots can't claim a mess.
	mouse_opacity=0 // So it's not completely impossible to fix the brig after some asshole bombs and then dirt grenades the place. - N3X
	w_type=NOT_RECYCLABLE

/obj/effect/decal/cleanable/New()
	if (random_icon_states && length(src.random_icon_states) > 0)
		src.icon_state = pick(src.random_icon_states)
	..()


/obj/effect/decal/cleanable/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O,/obj/item/weapon/mop))
		return ..()
	return 0 // No more "X HITS THE BLOOD WITH AN RCD"

/obj/effect/decal/cleanable/proc/messcheck(var/obj/effect/decal/cleanable/M)

	if(istype(M, /obj/effect/decal/cleanable/blood))
		score["mess"]++
	if(istype(M, /obj/effect/decal/cleanable/vomit))
		score["mess"]++
	if(istype(M, /obj/effect/decal/cleanable/mucus))
		score["mess"]++
	if(istype(M, /obj/effect/decal/cleanable/dirt))
		score["mess"]++
	if(istype(M, /obj/effect/decal/cleanable/liquid_fuel)) //Quite the mess
		score["mess"]++
	if(istype(M, /obj/effect/decal/cleanable/ash))
		score["mess"]++
	if(istype(M, /obj/effect/decal/cleanable/flour))
		score["mess"]++
	if(istype(M, /obj/effect/decal/cleanable/tomato_smudge))
		score["mess"]++
	if(istype(M, /obj/effect/decal/cleanable/egg_smudge))
		score["mess"]++
	if(istype(M, /obj/effect/decal/cleanable/pie_smudge))
		score["mess"]++
	if(istype(M, /obj/effect/decal/cleanable/soot))
		score["mess"]++
