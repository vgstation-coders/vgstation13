/obj/structure/grille/window_spawner
	icon = 'icons/obj/window_grille_spawner.dmi'
	icon_state = "window_grille"
	var/window_path = /obj/structure/window
	var/full_path

/obj/structure/grille/window_spawner/initialize()
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille0"
	. = ..()
	if(~flags & ATOM_INITIALIZED)
		if(full_path)
			new full_path(loc)

		for(var/direction in cardinal)
			var/turf/there = get_step(src, direction)
			var/found_connection = FALSE
			if(locate(/obj/structure/grille/window_spawner) in there)
				found_connection = TRUE
			else if(locate(/obj/structure/grille) in there)
				for(var/obj/structure/window/window_there in there)
					if(window_there.type == window_path && window_there.dir == get_dir(there, src))
						found_connection = TRUE
						break
			if(!found_connection)
				var/obj/structure/window/new_window = new window_path(loc)
				new_window.change_dir(direction)
				new_window.update_nearby_tiles()

/obj/structure/grille/window_spawner/full
	full_path = /obj/structure/window/full

/obj/structure/grille/window_spawner/reinforced
	icon_state = "reinforced_window_grille"
	window_path = /obj/structure/window/reinforced

/obj/structure/grille/window_spawner/reinforced/tinted
	window_path = /obj/structure/window/reinforced/tinted

/obj/structure/grille/window_spawner/reinforced/full
	full_path = /obj/structure/window/full/reinforced

/obj/structure/grille/window_spawner/plasma
	icon_state = "reinforced_plasma_window_grille"
	window_path = /obj/structure/window/plasma

/obj/structure/grille/window_spawner/plasma/full
	full_path = /obj/structure/window/full/plasma

/obj/structure/grille/window_spawner/reinforced_plasma
	icon_state = "reinforced_plasma_window_grille"
	window_path = /obj/structure/window/reinforced/plasma

/obj/structure/grille/window_spawner/reinforced_plasma/full
	full_path = /obj/structure/window/full/reinforced/plasma
