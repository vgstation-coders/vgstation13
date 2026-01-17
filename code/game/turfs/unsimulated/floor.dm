/turf/unsimulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "Floor3"
	plane = TURF_PLANE

	holomap_draw_override = HOLOMAP_DRAW_PATH

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

/turf/unsimulated/floor/New()
	..()
	footstep_sound = sounds_floor
	footstep_sound_barefoot = sounds_floor_barefoot
	footstep_sound_claw = sounds_floor_claw

/turf/unsimulated/floor/attack_paw(user as mob)
	return src.attack_hand(user)

/turf/unsimulated/floor/add_dust()
	if(!(locate(/obj/effect/decal/cleanable/dirt) in contents))
		new/obj/effect/decal/cleanable/dirt(src)

/turf/unsimulated/floor/cultify()
	if((icon_state != "cult")&&(icon_state != "cult-narsie"))
		name = "engraved floor"
		icon_state = "cult"
		turf_animation('icons/effects/effects.dmi',"cultfloor",0,0,MOB_LAYER-1,anim_plane = OBJ_PLANE)

/turf/unsimulated/floor/canBuildLattice()
	if(!planet)
		return BUILD_FAILURE
	else if(!(locate(/obj/structure/lattice) in contents))
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/unsimulated/floor/canBuildPlating()
	if(!planet)
		return BUILD_FAILURE
	else if(locate(/obj/structure/lattice) in contents)
		return BUILD_SUCCESS
	return BUILD_FAILURE


/turf/unsimulated/floor/grass
	name = "grass"
	icon_state = "grass1"
	base_icon_state = "grass"
	min_icon_states = 2
	max_icon_states = 4
	variance = 50
	plane = PLATING_PLANE
	var/soil_turf_type=null //when you remove the grass it turns into this. set to null if you don't want this to happen.
	var/grass_removal_time=0

/turf/unsimulated/floor/grass/New()
	..()
	footstep_sound = sounds_grass
	footstep_sound_barefoot = sounds_grass
	footstep_sound_claw = sounds_grass

/turf/unsimulated/floor/grass/attackby(var/obj/item/I, var/mob/user)
	var/uprooting_speed=check_can_uproot(I,user)
	if(uprooting_speed)
		to_chat(user, "<span class='notice'>You start breaking up the soil</span>")
		if(do_after(user, src, floor(grass_removal_time/uprooting_speed)))
			return uproot()
		else
			return FALSE
	return ..()

/turf/unsimulated/floor/grass/proc/check_can_uproot(var/obj/item/I,var/mob/user)
	if(!soil_turf_type || !I || !user)
		return 0.0
	if(istype(I,/obj/item/weapon/pickaxe) && !istype(I,/obj/item/weapon/pickaxe/shovel))
		return (1/I.toolspeed)/2.5 //default toolspeed is 0.4. do this math because lower=faster, but we want higher=faster.
	if(istype(I,/obj/item/tool/crowbar))
		if(istype(I,/obj/item/tool/crowbar/halligan)) //halligans have a pick end.
			return 0.75
		return 0.5
	if(istype(I,/obj/item/weapon/kitchen/utensil/knife))  //for those daring prison escapes, also because it's funny.
		return 0.1
	return 0.0

/turf/unsimulated/floor/grass/proc/uproot(var/obj/item/I,var/mob/user)
	ChangeTurf(soil_turf_type)
	new /obj/item/stack/tile/grass(src,1)
	return TRUE


/turf/unsimulated/floor/grass/ex_act(severity)
	if(soil_turf_type)
		switch(severity)
			if(1)
				ChangeTurf(soil_turf_type)
			if(2)
				if(prob(65))
					ChangeTurf(soil_turf_type)
			if(3)
				if(prob(20))
					ChangeTurf(soil_turf_type)
		..()
	
/turf/unsimulated/floor/mars
	name = "surface"
	icon_state = "ironsand1"
	base_icon_state = "ironsand"
	min_icon_states = 2
	max_icon_states = 15
	variance = 30

	carbon_dioxide = MOLES_CO2MARS
	nitrogen = MOLES_N2MARS
	oxygen = 0
	temperature = T20C

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

/turf/unsimulated/floor/fake_supermatter
	name = "Supermatter"
	desc = ""
	icon='icons/turf/space.dmi'
#ifdef BLUESPACELEAK_FLAT
	icon_state = "bluespace"
#else
	icon_state = "bluespacecrystal1"
#endif

	//To differentiate between fake and real supermatter when mapping
	color = "#777777"

/turf/unsimulated/floor/fake_supermatter/New()
	..()

	color = "#FFFFFF"

/turf/unsimulated/floor/brimstone
	icon_state = "ironsand1"
	base_icon_state = "ironsand"
	min_icon_states = 2
	max_icon_states = 15
	variance = 30

/turf/unsimulated/floor/brimstone/New()
	..()
	if(Holiday == APRIL_FOOLS_DAY)
		ChangeTurf(/turf/unsimulated/floor/snow) // hell froze over
		return
	overlays.Cut()
	var/image/fire = image('icons/effects/fire.dmi', "[rand(1,3)]")
	fire.blend_mode = BLEND_ADD
	fire.layer = TURF_FIRE_LAYER
	fire.plane = ABOVE_TURF_PLANE
	overlays += fire

/turf/unsimulated/floor/brimstone/Destroy()
	overlays.Cut()
	..()


/turf/unsimulated/floor/brimstone/mob_life_effects(mob/living/affected)
	affected.FireBurn(11, 9001, ONE_ATMOSPHERE) // lag free weird way of doing it
	affected.ignite() // ffffFIRE!!!! FIRE!!! FIRE!!
