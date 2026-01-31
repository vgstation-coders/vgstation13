/// Planetary turfs used in procedural planet generation
//Border turf
/turf/unsimulated/border
	name = "border"
	icon = 'icons/turf/space.dmi'
	icon_state = "black"
	plane = ABOVE_PARALLAX_PLANE
	mouse_opacity = 0
	density = 1
	opacity = 1
	blocks_air = 1
	explosion_block = 9999
	turf_flags = NOJAUNT

//Baseturf
/turf/unsimulated/floor/planetary
	name = "planetary floor"
	plane = PLATING_PLANE
	carbon_dioxide = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C
	can_border_transition=TRUE //allows zlevel transitions. you must also enable it in the zlevel.
	var/plated_icon_override_icon=null //set to an icon path to be used when you plate a tile
	var/plated_icon_override_state=null //ditto.
	var/pickaxe_conversion_turf=null
	var/pickaxe_conversion_time=0
	var/shovel_conversion_turf=null
	var/shovel_conversion_time=0

/turf/unsimulated/floor/planetary/canBuildLattice()
	if(!(locate(/obj/structure/lattice) in contents))
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/unsimulated/floor/planetary/canBuildPlating()
	if(locate(/obj/structure/lattice) in contents)
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/unsimulated/floor/planetary/canBuildCatwalk()
	if(locate(/obj/structure/lattice) in contents)
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/unsimulated/floor/planetary/proc/item_shovel_ability(var/obj/item/I,var/mob/user) // returns a number in the form of a divisor applied to turf manipulation duration. this means that lower numbers are worse. 0 means it just can't do it, and should be ignored, also because div 0.
	if(!I || !user)
		return 0.0
	if(istype(I,/obj/item/weapon/pickaxe/shovel))
		return (1/I.toolspeed)/2.5
	if(istype(I,/obj/item/weapon/kitchen/utensil/spoon) || istype(I,/obj/item/weapon/kitchen/utensil/spork))  //because it's funny.
		return 0.1
	return 0.0
	
/turf/unsimulated/floor/planetary/proc/item_pickaxe_ability(var/obj/item/I,var/mob/user) //see above
	if(!I || !user)
		return 0.0
	if(istype(I,/obj/item/weapon/pickaxe) && !istype(I,/obj/item/weapon/pickaxe/shovel))
		return (1/I.toolspeed)/2.5 //default toolspeed is 0.4. do this math because lower=faster, but we want higher=faster.
	if(istype(I,/obj/item/tool/crowbar))
		if(istype(I,/obj/item/tool/crowbar/halligan)) //halligans have a pick end.
			return 0.75
		return 0.5
	if(istype(I,/obj/item/weapon/kitchen/utensil/knife))
		return 0.1
	return 0.0

/turf/unsimulated/floor/planetary/proc/shovel_modify(var/obj/item/I,var/mob/user,var/speedfactor=1.0)
	to_chat(user, "<span class='notice'>You start digging into \the [src]</span>")
	if(do_after(user, src, shovel_conversion_time/speedfactor ))
		ChangeTurf(shovel_conversion_turf)
		return TRUE
	else
		return FALSE

/turf/unsimulated/floor/planetary/proc/pickaxe_modify(var/obj/item/I,var/mob/user,var/speedfactor=1.0)
	to_chat(user, "<span class='notice'>You start breaking up \the [src]</span>")
	if(do_after(user, src, pickaxe_conversion_time/speedfactor ))
		ChangeTurf(pickaxe_conversion_turf)
		return TRUE
	else
		return FALSE
	

/turf/unsimulated/floor/planetary/attackby(var/obj/item/I, var/mob/user)
	if(pickaxe_conversion_turf)
		var/pickaxe_factor=item_pickaxe_ability(I,user)
		if(pickaxe_factor)
			return pickaxe_modify(I,user,pickaxe_factor)
	if(shovel_conversion_turf)
		var/shovel_factor=item_shovel_ability(I,user)
		if(shovel_factor)
			return shovel_modify(I,user,shovel_factor)
	return ..()

//Caves
/turf/unsimulated/floor/planetary/cave
	name = "cave floor"
	icon_state = "cavefl_1"
	base_icon_state = "cavefl_"
	min_icon_states = 1
	max_icon_states = 4

/turf/unsimulated/floor/planetary/cave/xeno

/turf/unsimulated/floor/planetary/cave/xeno/New()
	..()
	new /obj/effect/alien/weeds(src)

/turf/unsimulated/mineral/cave
	name = "cave wall"
	icon_state = "cave_wall"
	mined_type = /turf/unsimulated/floor/asteroid/underground
	turf_flags = NO_RUINS|NO_FLORA|NO_LOOT

//Floors
/turf/unsimulated/floor/planetary/desert
	name = "desert"
	icon = 'icons/turf/planetary/desert.dmi'
	icon_state = "desert"
	base_icon_state = "desert"
	edge_priority = SAND_EDGE_PRIORITY
	edge_flags = EDGE_CARDINAL|EDGE_OUTER_DIAGONAL

/turf/unsimulated/floor/planetary/dry_basin
	name = "dry basin"
	icon = 'icons/turf/planetary/desert.dmi'
	icon_state = "drydesert"

/turf/unsimulated/floor/planetary/grass
	name = "grass"
	icon = 'icons/turf/planetary/grass.dmi'
	icon_state = "grass0"
	base_icon_state = "grass"
	min_icon_states = 1
	max_icon_states = 3
	variance = 40
	edge_priority = GRASS_EDGE_PRIORITY
	edge_flags = ALL_EDGES

/turf/unsimulated/floor/planetary/grass/New()
	..()
	footstep_sound = sounds_grass
	footstep_sound_barefoot = sounds_grass
	footstep_sound_claw = sounds_grass

/turf/unsimulated/floor/planetary/grass/pickaxe_modify(var/obj/item/I,var/mob/user)
	.=..()
	if(.)
		new /obj/item/stack/tile/grass(src,1)

/turf/unsimulated/floor/planetary/grass/ex_act(severity)
	if(shovel_conversion_turf)
		switch(severity)
			if(1.0)
				ChangeTurf(shovel_conversion_turf)
			if(2.0)
				if(prob(65))
					ChangeTurf(shovel_conversion_turf)
			if(3.0)
				if(prob(20))
					ChangeTurf(shovel_conversion_turf)
		..()


/turf/unsimulated/floor/planetary/dirt
	name = "dirt"
	icon = 'icons/turf/planetary/grass.dmi'
	icon_state = "dirt.1"
	base_icon_state = "dirt."
	min_icon_states = 2
	max_icon_states = 4
	variance = 40

/turf/unsimulated/floor/planetary/dirt/New()
	..()
	if(!map.zProcGen || z != map.zProcGen)
		name = "Soil"
		desc = "A mixture of sediments, clays, and decomposed matter."
		icon_state = "ironsand1"


/turf/unsimulated/floor/snow/glacier
	name = "glacier"
	temperature = T0C
	var/glacier_processed = FALSE

/turf/unsimulated/floor/planetary/snow_cave
	name = "icy cave floor"
	icon = 'icons/turf/new_snow.dmi'
	icon_state = "permafrost_full"

/turf/unsimulated/floor/planetary/wasteland
	name = "wasteland"
	icon = 'icons/turf/planetary/battlefield.dmi'
	icon_state = "wasteland"
	base_icon_state = "wasteland"
	variance = 60
	min_icon_states = 0
	max_icon_states = 32
	edge_flags = EDGE_CARDINAL
	edge_priority = SAND_EDGE_PRIORITY

/turf/unsimulated/floor/planetary/toxic //gives mobs rads
	name = "no man's land"
	desc = "The toxic remnants of an irradiated battlefield."
	icon = 'icons/turf/planetary/wasteplanet.dmi'
	icon_state = "wasteplanet0"
	base_icon_state = "wasteplanet"
	variance = 40
	max_icon_states = 12

/turf/unsimulated/floor/planetary/toxic/mob_life_effects(mob/living/affected)
	affected.apply_radiation(0.5, RAD_EXTERNAL)

/turf/unsimulated/floor/planetary/toxic/New()
	..()
	if(prob(variance))
		set_light(2, 1, "#00ff00")

/turf/unsimulated/floor/planetary/basalt
	name = "basalt"
	icon = 'icons/turf/planetary/lava.dmi'
	icon_state = "basalt"
	base_icon_state = "basalt"
	min_icon_states = 0
	max_icon_states = 12
	edge_flags = EDGE_CARDINAL|EDGE_OUTER_DIAGONAL
	edge_priority = CAVE_FLOOR_EDGE_PRIORITY

/turf/unsimulated/floor/planetary/sand/volcanic
	name = "volcanic sand"
	desc = "Sand, filled with a wide array of volcanic minerals have turned it a soft black color. Suprisingly good for plants, all things considered"
	icon = 'icons/turf/planetary/volcanicsand.dmi'
	icon_state = "volcsand1"
	base_icon_state = "volcsand"
	variance = 50
	min_icon_states = 1
	max_icon_states = 5
	edge_flags = EDGE_CARDINAL|EDGE_OUTER_DIAGONAL
	edge_priority = SAND_EDGE_PRIORITY

/turf/unsimulated/floor/planetary/grass/lavaland
	name = "crimson grass"
	desc = "This grass has adapted extremely well to the hot enviroments of lava planets, as it is adept at absorbing the red light that passes the atmosphere."
	icon = 'icons/turf/planetary/redgrass.dmi'
	icon_state = "redgrass1"
	base_icon_state = "redgrass"
	variance = 100
	max_icon_states = 3

/turf/unsimulated/floor/planetary/moss
	name = "mossy carpet"
	desc = "When the forests burned away and the sky grew dark, the moss learned to feed on the falling ash."
	icon_state = "moss"
	icon = 'icons/turf/planetary/lava.dmi'
	base_icon_state = "moss"
	gender = PLURAL
	light_power = 1
	light_range = 2

/turf/unsimulated/floor/planetary/obsidian
	name = "obsidian"
	desc = "Cooled magma forms a dark, cool glass."
	icon = 'icons/turf/planetary/lava.dmi'
	icon_state = "obsidian"

/turf/unsimulated/floor/planetary/lava
	name = "lava"
	icon_state = "lava"
	temperature = MELTPOINT_GLASS
	gender = PLURAL //"That's some lava."
	turf_flags = NO_RUINS|NO_FLORA|NO_LOOT

	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_FLARE

	var/particle_emitter = /obj/effect/particle_emitter/lava
	var/particle_prob = 15

/turf/unsimulated/floor/planetary/lava/New()
	. = ..()
	if(prob(particle_prob) && ispath(particle_emitter, /obj/effect/particle_emitter))
		particle_emitter = new particle_emitter(src)

/turf/unsimulated/floor/planetary/lava/Destroy()
	. = ..()
	if(isatom(particle_emitter))
		QDEL_NULL(particle_emitter)

/turf/unsimulated/floor/planetary/lava/Entered(atom/movable/AM,atom/OldLoc)
	. = ..()
	if(istype(OldLoc,/turf/unsimulated/floor/planetary/lava))
		return
	if(ishuman(AM)) //igniting all mobs causes a mass extinction event in lavaland
		var/mob/living/carbon/human/L = AM
		L.ignite()

/turf/unsimulated/floor/planetary/lava/canBuildCatwalk()
	if(!planet)
		return BUILD_FAILURE
	else if(!(locate(/obj/structure/lattice) in contents))
		return BUILD_SUCCESS
	return BUILD_FAILURE

/obj/effect/particle_emitter/lava
	particles = new/particles/candle

/turf/unsimulated/floor/planetary/xeno/desert
	name = "purple sand desert"
	icon = 'icons/turf/planetary/shrouded.dmi'
	icon_state = "shrouded0"
	base_icon_state = "shrouded"
	variance = 80
	min_icon_states = 1
	max_icon_states = 8
	edge_flags = EDGE_CARDINAL|EDGE_OUTER_DIAGONAL
	edge_priority = SAND_EDGE_PRIORITY

/turf/unsimulated/floor/planetary/xeno/desert/white
	name = "white sand desert"
	icon = 'icons/turf/planetary/whitesands.dmi'
	base_icon_state = "wsand"
	icon_state = "wsand"
	max_icon_states = 0
	edge_flags = EDGE_CARDINAL|EDGE_OUTER_DIAGONAL
	edge_priority = SAND_EDGE_PRIORITY


/obj/effect/overlay/water_turf
	icon = 'icons/misc/beach.dmi'
	icon_state = "water5"
	anchored      = TRUE
	name=""	
	plane            = ABOVE_OBJ_PLANE
	mouse_opacity    = 0
	invisibility     = INVISIBILITY_LIGHTING

/obj/effect/overlay/water_turf/forceMove(atom/destination, step_x = 0, step_y = 0, no_tp = FALSE, harderforce = FALSE, glide_size_override = 0)
	if(harderforce)
		. = ..()
/obj/effect/overlay/water_turf/ex_act(severity)
	return 0
/obj/effect/overlay/water_turf/shuttle_act()
	return 0
/obj/effect/overlay/water_turf/can_shuttle_move()
	return 0
/obj/effect/overlay/water_turf/send_to_future(var/duration)
	return
/obj/effect/overlay/water_turf/send_to_past(var/duration)
	return
/obj/effect/overlay/water_turf/clean_act(var/cleanliness)
	return
	
/turf/unsimulated/floor/planetary/water
	name = "water"
	desc = "Of course it's wet, are you stupid?"
	icon = 'icons/misc/beach.dmi'
	icon_state = "water5"
	turf_reagents = list(WATER=1.0)
	reagent_interaction_flags = TURF_REAGENT_ENTER | TURF_REAGENT_FILLS_CONTAINERS
	turf_reagent_amount = 5
	turf_flags = NO_FLORA
	edge_flags = ALL_EDGES
	edge_priority = WATER_EDGE_PRIORITY
	edge_overlay_type = /obj/effect/edge_overlay/water
	turf_speed_multiplier=2.0
	var/water_overlay_icon='icons/misc/beach.dmi' //water uses a 2 sprite system. 1 sprite lays on the turf layer as the "base"
	var/water_overlay_state="water5" //the second sprite lays above the turf, and can layer over other objects
	var/backing_trurf_icon=null //this gives the illusion that the water has depth, and looks quite nice
	var/backing_trurf_state=null //it's also very flexible, since you can use any icon on either, as long as water_overlay_icon has trasparency.
	var/obj/effect/overlay/water_turf/wateroverlay=null

/turf/unsimulated/floor/planetary/water/New()
	..()
	update_icon()
	footstep_sound = sounds_water
	footstep_sound_barefoot = sounds_water
	footstep_sound_claw = sounds_water
	icon=backing_trurf_icon ? backing_trurf_icon : icon
	icon_state = backing_trurf_state ? backing_trurf_state : icon_state
	wateroverlay=new(src)
	wateroverlay.icon = water_overlay_icon ? water_overlay_icon : icon
	wateroverlay.icon_state = water_overlay_state ? water_overlay_state : icon_state

/turf/unsimulated/floor/planetary/water/Destroy()
	qdel(wateroverlay)
	..()


/turf/unsimulated/floor/planetary/sand
	name="Sand"
	desc="Rocks which have been eroded over countless centuries into a fine powder. A wonderful material for castles!"
	icon = 'icons/misc/beach.dmi'
	icon_state = "sand"
	
/turf/unsimulated/floor/planetary/sand/New()
	..()
	footstep_sound = sounds_sand
	footstep_sound_barefoot = sounds_sand
	footstep_sound_claw = sounds_sand


/turf/unsimulated/floor/planetary/mud
	name="Mud"
	desc="A viscous mixture of water and soil."
	icon='icons/turf/planetary/jungle.dmi'
	icon_state = "mud"
	edge_flags = 0
	edge_priority = 1
	turf_speed_multiplier=1.75 //mud is difficult to travel over

/turf/unsimulated/floor/planetary/mud/New()	
	..()
	footstep_sound = sounds_water
	footstep_sound_barefoot = sounds_water
	footstep_sound_claw = sounds_water


/turf/unsimulated/floor/planetary/concrete
	name="Concrete"
	desc="Or is it asphalt?"
	icon='icons/turf/new_snow.dmi'
	icon_state = "concrete"


///////// Gas Vents /////////
var/list/datum/vent/gas_vents = list() // Global list of all gas vents

/datum/vent
	var/overlay_icon = 'icons/turf/overlays.dmi'
	var/overlay_state = "vent"
	var/gas_type = GAS_OXYGEN
	var/datum/weakref/turf_ref
	var/icon/gas_overlay
	var/mols
	var/initial_mols // The original amount of mols when the vent was created

/datum/vent/New(var/turf)
	..()
	mols = rand(10,50) * MOLES_CELLSTANDARD
	initial_mols = mols
	gas_vents += src
	turf_ref = makeweakref(turf)
	var/turf/unsimulated/T = turf_ref.get()
	if(!istype(T))
		T = null
		Destroy()
		return
	gas_type = pickweight(T.planet.vent_types)
	var/particle_color = "#808080ff"
	switch(gas_type)
		if(GAS_OXYGEN)
			particle_color = "#808080ff"
		if(GAS_PLASMA)
			particle_color = "#B233CCff"
		if(GAS_SLEEPING)
			particle_color = "#FFFFFFff"
		if(GAS_CARBON)
			particle_color = "#808080ff"
		if(GAS_NITROGEN)
			particle_color = "#808080ff"
		if(GAS_CRYOTHEUM)
			particle_color = "#50AFDEff"
		if(GAS_RADON)
			particle_color = "#629700ff"
	gas_overlay = icon(overlay_icon, overlay_state)
	T.overlays += gas_overlay
	T.add_particles(PS_GAS_VENT)
	T.adjust_particles(PS_GAS_VENT, PVAR_COLOR, particle_color)
	T = null

/datum/vent/Destroy()
	gas_vents -= src
	var/turf/unsimulated/T = turf_ref.get()
	if(istype(T))
		T.overlays -= gas_overlay
		T.remove_particles(PS_GAS_VENT)
	T = null
	..()