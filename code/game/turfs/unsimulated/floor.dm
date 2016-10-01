/turf/unsimulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "Floor3"

/turf/unsimulated/floor/ex_act(severity)
	switch(severity)
		if(1.0)
			new/obj/effect/decal/cleanable/soot(src)
		if(2.0)
			if(prob(65))
				new/obj/effect/decal/cleanable/soot(src)
		if(3.0)
			if(prob(20))
				new/obj/effect/decal/cleanable/soot(src)

/turf/unsimulated/floor/attack_paw(user as mob)
	return src.attack_hand(user)

/turf/unsimulated/floor/cultify()
	if((icon_state != "cult")&&(icon_state != "cult-narsie"))
		name = "engraved floor"
		icon_state = "cult"
		turf_animation('icons/effects/effects.dmi',"cultfloor",0,0,MOB_LAYER-1,anim_plane = OBJ_PLANE)


/turf/unsimulated/floor/grass
	icon_state = "grass1"

/turf/unsimulated/floor/grass/New()
	..()
	icon_state = "grass[rand(1,4)]"

/turf/unsimulated/floor/mars
	name = "surface"
	icon_state = "ironsand1"

	carbon_dioxide = MOLES_CO2MARS
	nitrogen = MOLES_N2MARS
	oxygen = 0
	temperature = T20C

/turf/unsimulated/floor/mars/New()
	..()

	if(prob(30))
		icon_state = "ironsand[rand(1,15)]"

/turf/unsimulated/floor/mars/air
	carbon_dioxide = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C

/turf/unsimulated/floor/mars/border
	icon_state = "magenta" //Makes it visible while mapping
	density = 1

/turf/unsimulated/floor/mars/border/New()
	icon_state = "ironsand1"

	..()
