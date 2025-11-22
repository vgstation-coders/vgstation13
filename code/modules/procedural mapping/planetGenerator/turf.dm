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

/turf/unsimulated/floor/planetary/dirt
	name = "dirt"
	icon = 'icons/turf/planetary/grass.dmi'
	icon_state = "dirt.1"
	base_icon_state = "dirt."
	min_icon_states = 2
	max_icon_states = 4
	variance = 40
	turf_flags = NO_RUINS

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

/turf/unsimulated/floor/planetary/lava/attackby(obj/item/attacking_item, mob/user, params)
	..()
	if(istype(attacking_item, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = attacking_item
		var/obj/structure/lattice/H = locate(/obj/structure/lattice, src)
		if(H)
			to_chat(user, span_warning("There is already a lattice here!"))
			return
		if(R.use(1))
			to_chat(user, span_notice("You construct a lattice."))
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			new /obj/structure/lattice(locate(x, y, z))
		else
			to_chat(user, span_warning("You need one rod to build a heatproof lattice."))
		return
	return FALSE

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
