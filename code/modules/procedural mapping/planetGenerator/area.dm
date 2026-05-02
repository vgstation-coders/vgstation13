//Collection of areas used only for procgen.
/area/planet
	name = "Planet"
	flags = NO_PERSISTENCE|CAVES_ALLOWED|FLORA_ALLOWED|MOB_SPAWN_ALLOWED
	requires_power = 0
	dynamic_lighting = 1
	construction_zone = TRUE
	forbid_apc = TRUE
	var/silent_weather = FALSE
	/// Pre-computed flag replacing isopensurface() macro during planet generation
	var/is_open_surface = TRUE

/area/planet/Entered(atom/movable/Obj, atom/OldLoc)
	. = ..()
	if(istype(Obj, /mob/living))
		var/mob/living/L = Obj
		L.update_weather_sounds(silent_weather)

/area/planet/Exited(atom/movable/Obj, atom/NewLoc)
	. = ..()
	if(istype(Obj, /mob/living))
		var/mob/living/L = Obj
		L.update_weather_sounds(TRUE)

/area/planet/beach
	name = "Beach"

/area/planet/cave
	name = "Cave"
	silent_weather = TRUE
	is_open_surface = FALSE

/area/planet/desert
	name = "Desert Planet"

/area/planet/lava
	name = "Lava Planet"

/area/planet/snow
	name = "Frozen Planet"

/area/planet/grass
	name = "Grass Planet"

/area/planet/xeno
	name = "Xeno Planet"

/area/planet/jungle
	name = "Jungle Planet"

/area/planet/urban
	name = "Urban Planet"

// Example with flora and caves disabled
// /area/planet/moon
// 	name = "Moon"
// 	flags = NO_PERSISTENCE|MOB_SPAWN_ALLOWED
