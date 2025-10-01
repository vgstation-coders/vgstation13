///baseturf

/turf/simulated/floor/plating/asteroid/basalt
	name = "basalt"
	icon = 'icons/turf/planetary/lava.dmi'
	icon_state = "basalt"
	base_icon_state = "basalt"
	floor_variance = 0
	light_color = LIGHT_COLOR_LAVA

/turf/simulated/floor/plating/asteroid/basalt/lava_land_surface

/turf/simulated/floor/plating/asteroid/basalt/lava_land_surface/lit
	light_range = 2
	light_power = 0.6

///Sand

/turf/simulated/floor/plating/asteroid/purple
	name = "volcanic sand"
	desc = "Sand, filled with a wide array of volcanic minerals have turned it a soft black color. Suprisingly good for plants, all things considered"
	icon = 'icons/turf/planetary/volcanicsand.dmi'

	icon_state = "sand_1"
	base_icon_state = "sand"

	light_color = LIGHT_COLOR_LAVA

	floor_variance = 83
	var/max_icon_states = 5


/turf/simulated/floor/plating/asteroid/purple/New()
	. = ..()
	if(prob(floor_variance))
		add_overlay("sandalt_[rand(1,max_icon_states)]")

/turf/simulated/floor/plating/asteroid/purple/lit
	light_range = 2
	light_power = 0.3

///Grass

/turf/simulated/floor/plating/asteroid/dirt/grass/lavaland
	name = "crimson grass"
	desc = "This grass has adapted extremely well to the hot enviroments of lava planets, as it is adept at absorbing the red light that passes the atmosphere."
	icon = 'icons/turf/planetary/redgrass.dmi'
	base_icon_state = "grass"
	light_range = 2
	light_power = 0.6
	light_color = LIGHT_COLOR_LAVA

/turf/simulated/floor/plating/asteroid/dirt/grass/lavaland/New()
	icon_state = "[base_icon_state]_[rand(1,3)]"

///The Moss
/turf/simulated/floor/plating/moss
	name = "mossy carpet"
	desc = "When the forests burned away and the sky grew dark, the moss learned to feed on the falling ash."
	icon_state = "moss"
	icon = 'icons/turf/planetary/lava_moss.dmi'
	base_icon_state = "moss"
	gender = PLURAL
	light_power = 1
	light_range = 2
	pixel_x = -9
	pixel_y = -9

///Ruin Turfs (to-do, move all ruin turfs into their own bespoke files)

/turf/simulated/floor/concrete/pavement/lava
	light_range = 2
	light_power = 0.6
	light_color = LIGHT_COLOR_LAVA

/turf/simulated/floor/concrete/lava
	light_range = 2
	light_power = 0.6
	light_color = LIGHT_COLOR_LAVA

/turf/simulated/floor/concrete/slab_1/lava
	light_range = 2
	light_power = 0.6
	light_color = LIGHT_COLOR_LAVA

/turf/simulated/floor/plating/lava
	light_range = 2
	light_power = 0.6
	light_color = LIGHT_COLOR_LAVA

/turf/simulated/floor/plating/rust/lava
	light_range = 2
	light_power = 0.6
	light_color = LIGHT_COLOR_LAVA

/turf/simulated/floor/plasteel/white/lava
	light_range = 2
	light_power = 0.6
	light_color = LIGHT_COLOR_LAVA

/turf/simulated/floor/plasteel/dark/lava
	light_range = 2
	light_power = 0.6
	light_color = LIGHT_COLOR_LAVA

/turf/simulated/floor/plating/asteroid/obsidian
	name = "obsidian"
	desc = "Cooled magma forms a dark, cool glass."
	icon = 'icons/turf/planetary/lava.dmi'
	icon_state = "obsidian"
	base_icon_state = "obsidian"
	floor_variance = 0

/turf/simulated/floor/plating/asteroid/obsidian/lit
	light_range = 2
	light_power = 0.6
	light_color = LIGHT_COLOR_LAVA

///LAVA
/turf/simulated/floor/lava
	name = "lava"
	icon_state = "lava"
	gender = PLURAL //"That's some lava."

	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_FLARE

	var/particle_emitter = /obj/effect/particle_emitter/lava
	var/particle_prob = 15

/turf/simulated/floor/lava/New()
	. = ..()
	if(prob(particle_prob) && ispath(particle_emitter, /obj/effect/particle_emitter))
		particle_emitter = new particle_emitter(src)

/turf/simulated/floor/lava/Destroy()
	. = ..()
	if(isatom(particle_emitter))
		QDEL_NULL(particle_emitter)

/turf/simulated/floor/lava/Entered(atom/movable/AM)
	. = ..()
	AM.ignite()

/turf/simulated/floor/lava/Exited(atom/movable/Obj, atom/newloc)
	. = ..()
	if(isliving(Obj))
		var/mob/living/L = Obj
		if(!istype(newloc,/turf/simulated/floor/lava) && !L.on_fire)
			L.ignite()

/turf/simulated/floor/lava/hitby(atom/movable/AM)
	AM.ignite()

/turf/simulated/floor/lava/singularity_act()
	return

/turf/simulated/floor/lava/attackby(obj/item/attacking_item, mob/user, params)
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

/obj/effect/particle_holder
	name = ""
	anchored = TRUE
	mouse_opacity = 0

/obj/effect/particle_emitter/New()
	. = ..()

/obj/effect/particle_emitter/lava
	particles = new/particles/candle
